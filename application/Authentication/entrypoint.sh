#!/bin/sh
set -e
./migrationsbundle -- --environment Production
exec dotnet Authentication.dll