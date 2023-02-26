# About

A RESTful Web Api for a simple blog article application.

## How to Run

Developed using MariaDB version

    SELECT VERSION(); -- 10.4.12-MariaDB-1:10.4.12+maria~bionic

### with [Docker](https://www.docker.com/)

1. run in bash/cmd ([more info](https://hub.docker.com/_/mariadb))

        docker run --name article-mariadb -e MYSQL_ROOT_PASSWORD=rZ7#VQkH3wKm^L$mR56g@m*n76YtUaxs -d mariadb --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

2. again run in bash/cmd

        docker exec -i article-mariadb sh -c 'exec mysql -uroot -prZ7#VQkH3wKm^L$mR56g@m*n76YtUaxs' < 

    absolute_path_to_[this](https://github.com/bali-ibrahim/article.api/blob/master/Repository/DDL.sql)_file.sql

3. Open [API.sln](https://github.com/bali-ibrahim/article.api/blob/master/API/API.sln) using Visual Studio and hit F5 or run

        dotnet publish -c Release

    and register the folder in IIS ensure the db configuration is valid in appSettings.json

### without Docker

1. Install [MariaDB](https://mariadb.org/download/) using the appropriate binary for your environment.
2. Run [this](https://github.com/bali-ibrahim/article.api/blob/master/Repository/DDL.sql) file against the created DB
3. Same as above

## Design Patterns

### Repository

Basically allows one to hide (or decouple) the details of data access, modification, persistence from other layers, thus allows isolating maintenance, development, and replacement of data access to a single layer.
This, as it enforces modularization, in that layer allows one to focus business logic and data model in other layers, thus improves maintenance and development lifecycle in general.

### UnitOfWork

This pattern besides allowing one to improve expressing the business logic on a higher level of abstraction by hiding the details, also enforces operations that modify or access multiple objects to a single transaction, thus enforcing data integrity.

### Dependency Injection

It decouples a class' construction from the construction of its dependencies. The dependency is added (injected) on a much higher level, thus allows to build almost entirely on interfaces. Building on interfaces decouples the contracts (interface) from implementation. Again this makes the code modular and easier to develop.

In this project the injection is done in Startup.cs. Which allows the configuration to be centralized, thus easier to maintain too.

## Future Work

### Development

The ideas here aim to improve the application consistency and code integrity & maintainability

- [ ] Adopt a more code-first approach to lower the amount designed manually, e.g schema creation
- [ ] Automate build process, at least have a script to generate the environment the app runs in
- [ ] Automate Tests
- [ ] Logging capabilities
- [ ] Service availability service (warn the maintainer if the service is down or in trouble etc.)

### Feature

- [ ] Authorized access
- [ ] Liking & commenting on articles
- [ ] Author & user relational integrity (e.g more articles from the author A)

## Technology

- .Net Core Framework (1 year experience)
- C# (2 years experience mainly in api & service applications)
- EntityFramework (MySQL wrapper)  (*No prior* experience, 1 year experience with [Dapper](https://github.com/StackExchange/Dapper))
- MariaDB (2.5 years experience mainly on MySQL 5.7)
- Git/Github (2.5 years experience)
