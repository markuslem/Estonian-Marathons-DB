# Estonian-Marathons-DB
Authors: Markus Lemberg, Aksel Kaasik, Kristjan Säärits

## Installation (local)
Follow the instructions on official website: https://www.postgresql.org/download/

#### Create the Database
You may need to create a user postgres and set a password via psql. <br>
Then create the database: <br>
```createdb -h localhost -U postgres jooksumaraton```

### Deploy the Schema and Data
```psql -h localhost -U postgres -d jooksumaraton -f jooksumaraton.sql```

