FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
USER $APP_UID 
EXPOSE 8000
# EXPOSE 8000 2222
# COPY entrypoint.sh ./
# RUN chmod u+x ./entrypoint.sh
# Start and enable SSH
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends dialog \
#     && apt-get install -y --no-install-recommends openssh-server \
#     && echo "root:Docker!" | chpasswd \
#     && chmod u+x ./entrypoint.sh
# COPY sshd_config /etc/ssh/


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
ENTRYPOINT ["dotnet", "Authentication.dll" ]