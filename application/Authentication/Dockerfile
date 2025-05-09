# Base image for runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
USER $APP_UID
EXPOSE 8080
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /src

# Install EF tools globally
RUN dotnet tool install --global dotnet-ef --version 8.*

# Copy project files
COPY ["Authentication.csproj*", "./"]
RUN dotnet restore

# Copy the rest of the application files
COPY . ./
WORKDIR /src
RUN dotnet build --configuration Release --no-restore
RUN dotnet publish --configuration Release --no-restore --output /app/out

# Bundle EF migrations
RUN /root/.dotnet/tools/dotnet-ef migrations bundle --runtime linux-x64 -o /app/out/migrationsbundle

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=build-env /app/out ./
COPY entrypoint.sh ./
CMD [ "./entrypoint.sh" ]