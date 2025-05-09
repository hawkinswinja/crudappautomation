#!/bin/sh
set -e
./migrationsbundle -- --environment Production
dotnet Authentication.dll