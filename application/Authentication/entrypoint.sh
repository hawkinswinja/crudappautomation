#!/bin/sh
set -e
# service ssh start
exec ./migrationsbundle -- --environment Production && dotnet Authentication.dll
# exec apt-get update && apt-get upgrade