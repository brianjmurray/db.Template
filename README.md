# Introduction 
This is a database project to track changes to schema of the Embrace database (TODO) and include setup business data.

# Getting Started
1.	Installation process
    1. Install [VSCode](https://code.visualstudio.com) or [Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio); or both.
    2. Install the [Database Projects extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.sql-database-projects-vscode)
2.	Pull down the project
    1. Click the sideways elipsis in the top-right corner for More Actions
    2. Select Clone
    3. Generate a Git Credential and save the password somewhere
    4. Click the Clone in VS Code button.

# Contribute
## [Branching and Merging Strategy](https://dev.azure.com/EmbracePetInsurance/Embrace%20Pet%20Insurance/_wiki/wikis/Embrace%20Pet%20Insurance.wiki/152/Branching-Merging)
1. Create a branch off of main for your changes. (git checkout -b feature/jira-1234)
2. Make your changes.
4. Build the project
    * Correct any errors and repeat build until there are 0 errors and warnings.
3. Commit your changes to your branch. 
    * git status (This will show you the files that have been changed)
    * git add . (This will queue all files for next commit, or you can specify a file name or directory to include if you don't want to commit all changes)
    * git commit -m "message" (This will commit all files that have been added)
4. Push your changes to the remote branch.
    * The first time you push you'll need to specify the --set-upstream option
        * git push --set-upstream origin feature/jira-1234
        * After that git push will work

## Build and Test
In the database projects extension, right-click on the top of the database project tree and select Build.
You should see the build process running in the Output tab. If there are any errors you'll see the count at the end of the output. You cna ctrl/cmd+click on the links to any of the files in the project to open and correct the issue.
![Alt text](Images\BuildErrorExample.png)
Keep in mind a single error in a file can have a cascading affect. An error in a file that defines a table can cause errors in other files that reference that table. For example an error in the Support.User table definition can result in errors for all of the tables that have foreign keys to that table which is just about everything. Make small changes and build often.


## Pull Request
When your changes are ready to merge into dev go to devops and create a pull request.
1. Open the project in [Devops](https://dev.azure.com/EmbracePetInsurance/Embrace%20Pet%20Insurance%20Business%20Intelligence/_git/db.embrace?path=%2F&version=GBmain&_a=contents) in your browser.
2. Select the branch you want to merge.
3. Click the Create a pull request button.
4. Add pertinent details.
5. Confirm that your target branch is dev.
6. Review the Files tab that the changes you expect are included.
7. Click Create
8. The DBA team can approve pull requests. A build will also be run in devops to confirm that no errors are present

## CI\CD
### Dev
A merge into the dev branch will trigger the dev build pipeline.
If it completes successfully the dev release pipeline will be triggered.

### RC and Production
A merge into the main branch will trigger the main build pipeline.
If it completes successfully the release pipeline will be trigger. It will deploy to RC and a Sandox test database. Sandbox will create a copy of the production database and push the changes to confirm there shouldn't be any issues deploying to production. 
There is an approval gate before production that needs to be approved by the Data Wizards team.

## Documentation
### Diagram
[Database Diagram](documentation/EmbraceDiagram.html)

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
* server role ##MS_DatabaseConnector##
* server role ##MS_DatabaseManager##
* role loginmanager

### Database Level Roles
* db_owner

## References

* [SQL Database Projects extension](https://learn.microsoft.com/en-us/sql/azure-data-studio/extensions/sql-database-project-extension?view=sql-server-ver16)
* [SqlProj documentation](https://www.nuget.org/packages/MSBuild.Sdk.SqlProj)