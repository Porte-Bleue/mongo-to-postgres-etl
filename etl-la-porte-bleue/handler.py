import os
from bson.json_util import dumps
import json
from datetime import datetime, timedelta

import pymongo
import sqlalchemy
from sqlmodel import Session, SQLModel, create_engine
from models import Products, Families, FamilyMembers, VisitEvents, Operations

orm_classes = {
    "products": Products,
    "families": Families,
    "family_members": FamilyMembers,
    "visit_events": VisitEvents,
    "operations": Operations, 
}

def extract(mongodb_secret: str, collection_name: str):
    """Extract data from MongoDB to local JSONLine file.

    Ref: https://realpython.com/introduction-to-mongodb-and-python/
    """
    client = pymongo.MongoClient(mongodb_secret) # Connect to MongoDB instance
    db = client.porteBleue  # Access `porteBleue` database
    collection = db[collection_name]  # db.getCollection("products")

    with open(f"data/{collection_name}.jsonl", "w") as fh:
        if collection_name == 'operations':
            fh.writelines([dumps(doc) + "\n" for doc in collection.find({"createdAt":{"$gte":datetime.today() - timedelta(7)}})]) # Limit the extract to last 7 days from the `operations` collection
        else:
            fh.writelines([dumps(doc) + "\n" for doc in collection.find()])

def load(postgre_secret: str, table_name: str):
    """Load data from local JSONLine file to PostgresSQL."""
    engine = create_engine(postgre_secret) # Create engine to connect to Postgre database
    Class = orm_classes[table_name] 
    connection = engine.connect() # Connect to the database
    sql_query = sqlalchemy.text(f"drop table if exists {table_name} cascade;") # Transaction to drop the table and its dependent objects. 
    connection.execute(sql_query) # Execute transaction
    connection.commit() # Commit the transaction
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
# Load credentials
mongodb_secret = os.environ.get('MONGO_DB')
postgre_secret = os.environ.get("POSTGRES_DB")
for t in tables_to_extract:
    print(f"extracting collection: {t}")
    extract(mongodb_secret, collection_name=t)
    print(f"loading table: {t}")
    load(postgre_secret, table_name=t)
