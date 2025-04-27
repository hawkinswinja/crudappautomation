# CRUD React App with Laravel Api and Dotnet for Authentication
- The example shows how to Building a React CRUD App with a Laravel API and using MySQL as a database, and Dotnet for authentication.

## Prerequisites
- Node.js
- Composer
- PHP 8.2
- dotnet
- MySQL
- Sql Server


## Installation
- Clone this repository `git clone https://github.com/stackpuz/Example-CRUD-React-18-Laravel-11 .`
- Change directory to React project. `cd view`
- Install the React dependencies. `npm install`
- Change directory to Laravel project. `cd ../api`
- Install the Laravel dependencies. `composer install`
- Create a new database and run [/database.sql](/database.sql) script to create tables and import data.
- Edit the database configuration in [/api/.env](/api/.env) file.
- Change directory to dotnet project. `cd ../Authentication`
- Update values for "DefaultConnection" in appsettings.json file with your sqlsserver credentials
- Update database with migrations. `dotnet ef database update`
- Build the project. `dotnet build` 

## Run project

- Run React project in view folder. `npm run dev`
- Run Laravel project `php artisan serve`
- Run dotnet project `dotnet run`
- Navigate to http://localhost:5173