# BioBD_SGBDBio
A repository for a BioBD_SGBD (DBMS) to represent Biological Sequences and an interface for access.

This README will briefly instruct on how to install and use the following code.

If you want to run locally, here's what to do:

- Download pgAdmin (https://www.pgadmin.org/download/) which is the GUI for PostgreSQL, the program that runs the database.
- Follow-up the installation instructions and choose a name and password for the connection to the server that will run locally, using port 5432.
- Run pgAdmin, that will load a page on the internet browser, then connect to the server and create the database right-clicking on "Databases" and choosing "Create > Database...", choosing its name and owner (which usually is "postgres").
- After that, open "Databases", right-click on the recently-created database and choose "Query Tool...".
- Copy, paste and run the content inside the files "ddl.sql", "insert.sql" and "functions.sql", one by one.
- Your database is configured. If you want, you can run "test.sql" just like the other files to test it and check if the results are correct.
