import os
from bson.json_util import dumps
import json

import pymongo
from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine
# from models import Products, Families, FamilyMembers, VisitEvents
from models import Families, FamilyMembers

load_dotenv()

orm_classes = {
    # "products": Products,
    "family_members": FamilyMembers,
    "families": Families,
    # "visit_events": VisitEvents,
}

engine = create_engine(os.environ.get("POSTGRES_DB"))

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
    Class = orm_classes[table_name]
    # Class.__table__.drop(engine, checkfirst=True) # drop the table if existing
    SQLModel.metadata.create_all(engine)

    with open(f"data/{table_name}.jsonl", "r") as fh:
        objects = [Class(id=i, **json.loads(p)) for i, p in enumerate(fh.readlines())]

    # TODO: instead of writing all objects, only do an incremental write
    session.add_all(objects)


if __name__ == "__main__":
    tables_to_extract = [
        # "products",
        "family_members",
        "families",
        # "visit_events"
    ]
    with Session(engine) as session:
        for t in tables_to_extract:
            print(f"extracting table: {t}")
            extract(table_name=t)
            print(f"loading table: {t}")
            load(table_name=t)
        session.commit()
        session.close()