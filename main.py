import os
from bson.json_util import dumps
import json
from datetime import datetime, timedelta

import pymongo
import sqlalchemy
from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine
import prefect
from prefect import task, Flow
from prefect.client.secrets import Secret
from models import Products, Families, FamilyMembers, VisitEvents, Operations

load_dotenv()

orm_classes = {
    "products": Products,
    "families": Families,
    "family_members": FamilyMembers,
    "visit_events": VisitEvents,
    "operations": Operations, 
}

logger = prefect.context.get("logger")

@task
def extract(collection_name: str):
    """Extract data from MongoDB to local JSONLine file.

    Ref: https://realpython.com/introduction-to-mongodb-and-python/
    """
    mongodb_secret = Secret("PREFECT__MONGO_DB")
    logger.info(mongodb_secret.get())
    client = pymongo.MongoClient(os.environ.get("PREFECT__MONGO_DB"))
    db = client.porteBleue  # use porteBleue
    collection = db[collection_name]  # db.getCollection("products")

    with open(f"data/{collection_name}.jsonl", "w") as fh:
        if collection_name == 'operations':
            fh.writelines([dumps(doc) + "\n" for doc in collection.find({"createdAt":{"$gte":datetime.today() - timedelta(7)}})]) # Limit the extract to last 7 days from the `operations` collection
        else:
            fh.writelines([dumps(doc) + "\n" for doc in collection.find()])

@task
def load(table_name: str):
    """Load data from local JSONLine file to PostgresSQL."""
    postgre_secret = Secret("PREFECT__POSTGRES_DB")
    logger.info(postgre_secret.get())
    engine = create_engine(os.environ.get("PREFECT__POSTGRES_DB"))
    Class = orm_classes[table_name]
    connection = engine.connect()
    sql_query = sqlalchemy.text(f"drop table if exists {table_name} cascade;")
    connection.execute(sql_query)
    connection.commit()
    SQLModel.metadata.create_all(engine)

    with open(f"data/{table_name}.jsonl", "r") as fh:
        objects = [Class(id=i, **json.loads(p)) for i, p in enumerate(fh.readlines())]

    # TODO: instead of writing all objects, only do an incremental write
    with Session(engine) as session:
        session.add_all(objects)
        session.commit()
        session.close()


if __name__ == "__main__":
    tables_to_extract = [
        "products",
        "families",
        "family_members",
        "visit_events",
        "operations"
    ]
    with Flow("ETL From MongoDB To Postgres") as flow:
        for t in tables_to_extract:
            print(f"extracting collection: {t}")
            t1 = extract(collection_name=t)
            print(f"loading table: {t}")
            t2 = load(table_name=t, upstream_tasks=[t1])

# Deploy Prefect flow
flow.register(project_name="analytics-la-porte-bleue")
