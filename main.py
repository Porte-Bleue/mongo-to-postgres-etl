import os
from bson.json_util import dumps
import json

import pymongo
from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine
from models import Products, Families, FamilyMembers, VisitEvents, Operations

load_dotenv()

orm_classes = {
    "products": Products,
    "families": Families,
    "family_members": FamilyMembers,
    "visit_events": VisitEvents,
    # "operations": Operations, ## The table is too heavy
}


def extract(table_name: str):
    """Extract data from MongoDB to local JSONLine file.

    Ref: https://realpython.com/introduction-to-mongodb-and-python/
    """
    client = pymongo.MongoClient(os.environ.get("MONGO_DB"))
    db = client.porteBleue  # use porteBleue
    table = db[table_name]  # db.getCollection("products")

    with open(f"data/{table_name}.jsonl", "w") as fh:
        fh.writelines([dumps(doc) + "\n" for doc in table.find()])


def load(table_name: str):
    """Load data from local JSONLine file to PostgresSQL."""
    engine = create_engine(os.environ.get("POSTGRES_DB"))
    Class = orm_classes[table_name]
    Class.__table__.drop(engine, checkfirst=True) # drop the table if existing
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
        # "operations" ## The table is too heavy
    ]
    for t in tables_to_extract:
        print(f"extracting table: {t}")
        extract(table_name=t)
        print(f"loading table: {t}")
        load(table_name=t)
