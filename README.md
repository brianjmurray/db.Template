# Introduction

This is a database project to track changes to schema of your database and include setup business data.

# Getting Started

1. Installation process
   1. Install [VSCode](https://code.visualstudio.com) or [Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio); or both.
   2. Install the [Database Projects extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.sql-database-projects-vscode)
2. Pull down the project
   1. Click the sideways ellipsis in the top-right corner for More Actions
   2. Select Clone
   3. Generate a Git Credential and save the password somewhere
   4. Click the Clone in VS Code button.

## Build and Test

In the database projects extension, right-click on the top of the database project tree and select Build.
You should see the build process running in the Output tab. If there are any errors you'll see the count at the end of the output. You can ctrl/cmd+click on the links to any of the files in the project to open and correct the issue.
Keep in mind a single error in a file can have a cascading affect. An error in a file that defines a table can cause errors in other files that reference that table. Make small changes and build often.
Case Warnings have been disabled in this project. If you want to include them remove the following line from the sqlproj file.
`<SuppressTSqlWarnings>71558</SuppressTSqlWarnings>`

## CI\CD

### Dev

A merge into the dev branch will trigger the dev build pipeline.
In my environment, if it completes successfully the dev release pipeline will be triggered.

I have similar setup for my main branch to deploy to a uat and prod environment.

## Documentation

### Diagram

[Database Diagram](http://localhost:8080/) TODO: Update link to the static site for your blob storage

## Pull changes in from existing database

###### This can happen if changes are made to the database directly. The changes need to be pulled into the project if you want to retain them.

1. Open the project in [Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio/). You'll need to install the database project extension if you haven't already.
2. Right click on the project and select Schema Compare.
3. Select the source database (the one you want to pull changes from) and the target of the database project.
4. In options you can specify the objects you want to compare. For example, if you only want to pull in changes to tables, you can uncheck everything except Tables.
5. Click Compare.
6. Review the changes and click Update to pull them into the project. If you don't want to pull in a change, uncheck the Include checkbox next to the object. You may need to make manual edits if there are changes to the source and edits that you want to keep for an object.

## Permissions for Service Prinicpal

### Server Level Roles

- server role ##MS_DatabaseConnector##
- server role ##MS_DatabaseManager##
- role loginmanager

### Database Level Roles

- db_owner

## References

- [SQL Database Projects extension](https://learn.microsoft.com/en-us/sql/azure-data-studio/extensions/sql-database-project-extension?view=sql-server-ver16)
- [SqlProj documentation](https://www.nuget.org/packages/MSBuild.Sdk.SqlProj)
