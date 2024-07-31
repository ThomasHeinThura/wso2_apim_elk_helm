# Datbase Creation Guide

## Create Databases

- To create database, Connect the Database IP `mysql -h <hostIP> -u <user> -p`

- Create users and passwords.

```sql
CREATE USER 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
```

or create user with native_password  
`CREATE USER 'wso2carbon'@'%' IDENTIFIED WITH 'mysql_nati ve_password' BY 'wso2carbon'`

- Create Databases of WSO2AM

```sql
CREATE DATABASE WSO2AM_DB character set latin1;
```

- Create a Database of WSO2AM_SHARED_DB

```sql
CREATE DATABASE WSO2AM_SHARED_DB character set latin1;
```

**Notes**: This grant to all IP. If you need specific IP use `wso2carbon@<IP-ADDress>`

- Grant the privilege to WSO2AM_DB

```sql
GRANT ALL ON WSO2AM_DB.* TO 'wso2carbon'@'%';
```

- Grant the privilege to WSO2AM_SHARED_DB

```sql
GRANT ALL ON WSO2AM_SHARED_DB.* TO 'wso2carbon'@'%';
```

- Flush the privileges

```sql
FLUSH PRIVILEGES;
```

## Create Tables and schema

**Notes**: To find the dbscript first to download the wso2 apim specfic version from website and unzip the file. you will the script.

- Create tables for apimdb

```sql
mysql -h <IP> -u wso2carbon -p -D WSO2AM_DB < '<API-M_HOME>/dbscripts/apimgt/mysql.sql';
```

- Create tables for shareddb

```sql
mysql -h <IP> -u wso2carbon -p -D WSO2AM_SHARED_DB < '<API-M_HOME>/dbscripts/mysql.sql';
```

- Check the Databases and connections.

```sql
mysql -h <IP> -u wso2carbon -p -e "show databases;"
```

- check there is a table

```sql
mysql -h <IP> -u wso2carbon -p -e "SELECT * FROM WSO2AM_DB.AM_API;"
```

Notes: For production, make sure to use security hardening
