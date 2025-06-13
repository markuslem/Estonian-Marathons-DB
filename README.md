# Estonian-Marathons-DB
Authors: Markus Lemberg, Aksel Kaasik, Kristjan Säärits

## Installation (local)
Follow the instructions on official website: https://www.postgresql.org/download/

#### Create postgres user
You may need to create a user postgres and set a password via psql. <br>

#### Then create the database:
```$ createdb -h localhost -U postgres jooksumaraton```

#### Deploy the Schema with mock data
```$ psql -h localhost -U postgres -d jooksumaraton -f jooksumaraton.sql```

## Installation (Docker)
Make sure that the port can be used <br>
```# docker-compose up -d```
<br>
```# docker start estonian_marathons_db```

## Connect to the jooksumaraton database using psql client (default password with docker: "password")
```$ psql -h localhost -U postgres -d jooksumaraton```


## About the Project

The database tables were designed using DB Designer. Our project: https://erd.dbdesigner.net/designer/schema/1710503520-jooksumaraton 

### Comments about the relations (in Estonian)
* Kui jooksja ei finišeeri, siis tulemuste tabeli atribuudid finišiaeg, koht ja koht_vanuseklassis on NULL.
* Kui jooksja ei saanud enda tulemusega ühtegi auhinda, siis on tulemused_auhinnad relatisioonis atribuut auhind_id NULL.
* Kui auhinnal sponsori panus puudub, siis atribuut sponsori_panus=NULL
* Igal maratonil on unikaalne nimi
* Igal rajal on unikaalne nimi
* Igal maratonide sarjal on unikaalne nimi
* Igal sponsoril on unikaalne sponsori_nimi
* Sponsori e-mail võib olla NULL, kui see ei ole teada
* Me oletame, et kõigil maratonidel on peasponsor

### Views
V_top3_distants - Loome vaate, mis kuvab kõikide maratonide peale kokku kõige rohkem jooksnud sportlased. Esitame parimad 3. 

V_võidetudauhinnad - kuvab inimesed ja nende võidetud auhindade väärtused kahanevas järjekorras.

### Functions 
f_joksjatulemused(jooksja_id int) - võtab parameetriks jooksja id ja kuvab tabeli, kus on näha selle jooksja kõiki tulemusi.

f_klubiliikmed(klubi_nimi varchar) - Võtab parameetriks klubi nime ja kuvab selle klubi kõik liikmed ja ka selles klubis olevad treenerid.

### Stored Procedures
Sp_uus_maratonide_sari- Lisab uue maratoni. Kui sobivat sponsorit pole, siis annab sellest kasutajale teada ja ei lisa sarja.

sp_uus_klubi(klubi_nimi varchar, klubi_asukoht varchar) - Võtab parameetriks klubi nime, ning asukoha ja lisab selle “klubid” tabelisse. Peale lisamist annab teate, et klubi on lisatud.
