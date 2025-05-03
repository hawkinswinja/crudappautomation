# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app
RUN dotnet tool install --global dotnet-ef --version 8.*
COPY . ./
RUN dotnet restore
RUN dotnet build --configuration Release
# Build and publish a release
RUN dotnet publish -c Release -o out
RUN /root/.dotnet/tools/dotnet-ef migrations bundle --runtime linux-x64 -o migrationsbundle
# ./migrationsbundle -- --environment Production
 
# Build runtime image
FROM base
WORKDIR /app
COPY --from=build-env /app/out /app/migrationsbundle /app/
CMD ["dotnet", "Authentication.dll"]
 