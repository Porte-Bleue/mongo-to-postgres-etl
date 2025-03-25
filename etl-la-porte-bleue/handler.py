import os
from bson.json_util import dumps
import json
from datetime import datetime, timedelta

import pymongo
import sqlalchemy
from sqlmodel import Session, SQLModel, create_engine
from models import Products, Families, FamilyMembers, VisitEvents, Operations, Collects

orm_classes = {
    "products": Products,
    "families": Families,
    "family_members": FamilyMembers,
    "visit_events": VisitEvents,
    "operations": Operations,
    "collects": Collects,
}

def extract(mongodb_secret: str, collection_name: str):
    """Extract data from MongoDB to local JSONLine file.

    Ref: https://realpython.com/introduction-to-mongodb-and-python/
    """
    client = pymongo.MongoClient(mongodb_secret)  # Connect to MongoDB instance
    db = client.porteBleue  # Access `porteBleue` database
    collection = db[collection_name]  # db.getCollection("products")

    with open(f"/tmp/{collection_name}.jsonl", "w") as fh:
        if collection_name == 'operations':
            # Filter operations from last 6 months
            six_months_ago = datetime.today() - timedelta(days=180)
            cursor = collection.find({"createdAt": {"$gte": six_months_ago}})
        else:
            cursor = collection.find()
            
        fh.writelines([dumps(doc) + "\n" for doc in cursor])


def load(postgre_secret: str, table_name: str):
    """Load data from local JSONLine file to PostgresSQL."""

    engine = create_engine(
        postgre_secret,
        connect_args={
            "sslmode": "require",
            "gssencmode": "disable",
            "connect_timeout": 30,            
            "application_name": "etl_production"
        }
    )  # Create engine to connect to Postgre database
    Class = orm_classes[table_name]
    connection = engine.connect()  # Connect to the database

    # Set the statement_timeout (in milliseconds) using an SQL query
    statement_timeout = 300000  # 5 minutes in milliseconds
    query_statement_timeout = sqlalchemy.text(
        f"SET statement_timeout = {statement_timeout};"
    )
    connection.execute(query_statement_timeout)  # Set the statement_timeout

    # Create the tables if they don't exist
    SQLModel.metadata.create_all(engine)

    # Truncate the table and its dependent objects (to remove all data but keep structure)
    truncate_query = sqlalchemy.text(
        f"TRUNCATE TABLE {table_name} CASCADE;"
    )
    connection.execute(truncate_query)
    connection.commit()

    with open(f"/tmp/{table_name}.jsonl", "r") as fh:
        objects = [Class(id=i, **json.loads(p)) for i, p in enumerate(fh.readlines())]

    # TODO: instead of writing all objects, only do an incremental write
    with Session(engine) as session:
        # print("Objects to be added to the session:", objects)
        session.add_all(objects)
        session.commit()
        session.close()

def main(event, context):
    if not os.path.exists('/tmp'):
        os.mkdtemp('/tmp')

    # Load credentials
    mongodb_secret = os.environ.get("MONGO_DB")
    postgre_secret = os.environ.get("POSTGRES_DB")

    tables_to_extract = [
        "products",
        "families",
        "family_members",
        "visit_events",
        "operations",
        "collects",
    ]

    for t in tables_to_extract:
        print(f"extracting collection: {t}")
        extract(mongodb_secret, collection_name=t)
        print(f"loading table: {t}")
        load(postgre_secret, table_name=t)


if __name__ == "__main__":
    main()
