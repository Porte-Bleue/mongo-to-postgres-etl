# trino-mongo

## TODO

- replicate the demo
  - create Postgres DB in heroku
  - create preset.io free tier account and connect to Postgres DB
  - create .env file with secrets
  - run main.py with `python main.py`
  - make sure everything worked and that you can create a Preset query with

  ```sql
  select
      unit_of_measure,
      count(id)
  from product
  group by 1;
  ```

- list your usecases in Preset: what queries do you want? -> what SQL tables do you need? -> what MongoDB collections do you need to Extract/Load?
- add a model in models.py + a table name to the different places in main.py for each table you need

Useful commands:

```sh
pip install pgcli
pgcli postgres://user:pwd@host:5432/dbname
pgcli> drop table products;
```

## Overview

### Option A: trino aka le paquebot

Extract + Load = trino deployed on ???? - Heroku for free but hard - AWS EC2 not free but maybe free tier

Preset.io free tier connected to trino as Postgres

### Option B: cousu main

Extract + Load = custom python script deployed on https://www.prefect.io/pricing free tier

⚠️ custom python script to be written cf https://kb.objectrocket.com/postgresql/migrate-mongodb-nosql-to-postgres-with-python-860
OR use an open source pipeline like https://docs.airbyte.com/ with MongoDb source https://airbyte.com/connectors/mongodb and https://airbyte.com/connectors/postgresql-destination

Preset.io free tier connected to trino as Postgres

### Option C: AWS Athena

https://docs.aws.amazon.com/athena/latest/ug/athena-prebuilt-data-connectors-docdb.html but it's AWS, it's gonna be a nightmare
⚠️ no free tier but very cheap thanks to serverless https://aws.amazon.com/athena/pricing/

Preset.io connect to Athena with https://superset.apache.org/docs/databases/athena

## Option A details: Trino

### Run trino locally

```sh
docker build -t trino-mongo .
docker run -p 8080:8080 --name trino trino-mongo
docker exec -it trino trino
```

### Run trino on Heroku

```sh
export HEROKU_APP_NAME=afternoon-beach-06678
docker tag trino-mongo registry.heroku.com/afternoon-beach-06678/worker
docker push registry.heroku.com/afternoon-beach-06678/worker
```

```sh
heroku container:release worker
heroku open
```
