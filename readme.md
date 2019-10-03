# Using Docker for Local Development

## Setting up init data

### Oracle

- Download the oracle linuxX64 12.0.0.2.0 basic binary
- Download the oracle linuxX64 12.0.0.2.0 sdk binary
- move these binaries to the dock-files directory
- place a schema dump in the OracleDB directory named oracle_schema.sql

### MySQL

- place a schema to import in the MySqlDB directory named schema.sql

## Installing local resources to run Docker Container

  1. Ensure that Docker for Windows ( or other operating system ) is installed and running.
  2. Run command : docker network create traefik_webgateway
  3. Run command : docker network create internal
  4. Run command : docker-compose up --build in the root directory of this project
  5. Run scripts to populate local database schemas
     1. ORACLE -
         1. docker exec -it oracle-database bash
         2. sqlplus SYSTEM/Oradoc_db1@ORCLCDB
         3. ALTER SESSION SET "_ORACLE_SCRIPT"=true;
         4. CREATE TABLESPACE "ORACLEDB" DATAFILE 'oracledb.dbf' size 4000M;
         5. CREATE TEMPORARY TABLESPACE "temp_tablespace" TEMPFILE 'temp_tablespace.dbf' size 4000M;
         6. Run command : CREATE USER ORACLEDB IDENTIFIED BY adminpassword5 DEFAULT TABLESPACE "ORACLEDB" TEMPORARY TABLESPACE "temp_tablespace"  QUOTA UNLIMITED ON "ORACLEDB";
         7. Run command : GRANT create session TO ORACLEDB;
         8. Run command : GRANT create table TO ORACLEDB;
         9. Run command : GRANT create view TO ORACLEDB;
         10. Run command : GRANT create any trigger TO ORACLEDB;
         11. Run command : GRANT create any procedure TO ORACLEDB;
         12. Run command : GRANT create sequence TO ORACLEDB;
         13. Run command : GRANT create synonym TO ORACLEDB;
         14. Run command : ALTER USER SYSTEM QUOTA UNLIMITED ON ORACLEDB;
         15. Run command : alter tablespace ORACLEDB add datafile '/u01/app/oracle/product/12.2.0/dbhome_1/dbs/oracledb2.dbf' size 2000M autoextend on;
         16. Run command : alter tablespace UNDOTBS1 add datafile '/u01/app/oracle/product/12.2.0/dbhome_1/dbs/undotbs1.dbf' size 2000M autoextend on;
         17. Run command : @/opt/oracle_schema.sql
     2. MySQL -
        1. docker exec -t -i mysql-database /bin/bash -c "mysql -uroot -pmysql_root_password1 MYSQL < /opt/schema.sql;"
  6. run follow up creation script from root project directory : sh startup.sh or ./startup.sh

## Regular Usage

- <https://github.com/wsargent/docker-cheat-sheet> DOCKER CHEAT SHEET
- start container : docker-compose up  / docker-compose up --d (run container without log tail)  / docker-compose up --build (run container and rebuild needed resources)
- stop container : docker-compose down
- access terminal within container : docker exec -it (container name) bash
- list running containers : docker container ls
- list running networks : docker network ls
- list downloaded images : docker image ls
  
### use custom .bashrc or .vimrc

- from within root project directory, while container is running, run command : docker cp c:\path\to\local\file (container_name):~

## TODO

- add to helpers.php line 50 (the path index will not be set in newer php versions if in root directory) -
            $relativeURL = '';
            if (array_key_exists('path', $parsedURL)) {
                $relativeURL = $parsedURL['path'];
            }
- create a dockerhub account to house base images
- create images with just databases for temps
- it seems like adding phpcs globally isnt working right, add to the project composer.json

## Troubleshooting

### Docker using too much space

- periodically run the command : docker system prune  - this command will remove any orphan resources
- <https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes> see this for other helpful cleanup tips and commands

## VS Code specific

### Docker Container Management

- Install the official Docker VSCode plugin

*Name: Docker*
*Id: ms-azuretools.vscode-docker*
*Description: Adds syntax highlighting, commands, hover tips, and linting for Dockerfile and docker-c*ompose files.
*Version: 0.8.1*
*Publisher: Microsoft*
*VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker>*

### XDebug for VSCode with Docker

full article : <https://medium.com/@jasonterando/debugging-with-visual-studio-code-xdebug-and-docker-on-windows-b63a10b0dec>

- install the php debug extenstion
  *Name: PHP Debug*
  *Id: felixfbecker.php-debug*
  *Description: Debug support for PHP with XDebug*
  *Version: 1.13.0*
  *Publisher: Felix Becker*
  *VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug>*

- open launch.json in VSCode

- ensure that the first entry in the configurations key matches below :
            ```{
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9000,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            },
              "xdebugSettings": {
                  "max_data": 65535,
                  "show_hidden": 1,
                  "max_children": 100,
                  "max_depth": 5
              }
          }```

### VSCode PHP Intellisense

- Install the following extension

*Name: PHP Intelephense*
*Id: bmewburn.vscode-intelephense-client*
*Description: PHP code intelligence for Visual Studio Code*
*Version: 1.2.3*
*Publisher: Ben Mewburn*
*VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client>*

### VSCode php code sniffer

- to be added later

## Additional Tools

### PHP Code Sniffer

- PHP Code Sniffer will inspect the code base for psr2 errors
- Run Command: docker exec -i --user=1000:1000 cebs2  phpcs --ignore=*vendor/*,*tests/*,*node_modules/*,*storage/*,*.js --standard=psr2 --encoding=utf-8 ../

### PHP Code Beautifier

- PHP Code Beautifier will attempt to automatically fix psr2 error in the project
- Run Command : docker exec -i --user=1000:1000 cebs2 phpcbf --standard=psr2 ../

### Git Hooks

- Git hooks are added automatically when the container is started
- These hooks are copied out of the dock-files/hooks folder
