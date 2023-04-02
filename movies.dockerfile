# Set the base image to use for containers
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

# Set the working directory to /app
WORKDIR /app

# Copy the csproj files to the container
COPY Movies.Api/Movies.Api.csproj Movies.Api/
COPY Movies.Application/Movies.Application.csproj Movies.Application/
COPY Movies.Contracts/Movies.Contracts.csproj Movies.Contracts/
COPY Helpers/Identity.Api/Identity.Api.csproj Helpers/Identity.Api/

# Restore dependencies
RUN dotnet restore Movies.Api/Movies.Api.csproj
RUN dotnet restore Movies.Application/Movies.Application.csproj
RUN dotnet restore Movies.Contracts/Movies.Contracts.csproj
RUN dotnet restore Helpers/Identity.Api/Identity.Api.csproj

# Publish the app
RUN dotnet publish Movies.Api/Movies.Api.csproj -c Release -o out

# Copy the remaining files to the container
COPY . ./

# Build the app
RUN dotnet build Movies.Api/Movies.Api.csproj -c Release

# Publish the app
RUN dotnet publish Movies.Api/Movies.Api.csproj -c Release -o out

# List the contents of the output directory
RUN ls -la /app/Movies.Api
RUN ls -la /app/Movies.Api/out

# Set the base image to use for containers
FROM mcr.microsoft.com/dotnet/aspnet:7.0

# Set the working directory to /app
WORKDIR /app

# Copy the remaining files to the container
COPY --from=build-env /app/Movies.Api/out .

# Expose the port used by the app
EXPOSE 80

# Set the entry point for the container
ENTRYPOINT ["dotnet", "Movies.Api.dll"]