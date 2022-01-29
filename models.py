from typing import Optional
from pydantic import validator
from sqlmodel import Field, SQLModel
from datetime import datetime


def to_camel(name):
    return "".join(
        x.capitalize() if i > 0 else x for i, x in enumerate(name.split("_"))
    )


class Products(SQLModel, table=True):
    id: str = Field(default=None, primary_key=True, alias='_id')
    name: str
    unit_of_measure: str
    quantity_for_one_foodstuff: int
    created_at: datetime
    updated_at: datetime
    created_by: str
    category: str
    cupboard: str
    updated_by: str
    current_stock: int

    @validator("id", "created_by", "category", "cupboard", "updated_by", pre=True)
    def unnest_id(cls, v):
        return v["$oid"]

    @validator("created_at", "updated_at", pre=True)
    def unnest_date(cls, v):
        return v["$date"]

    class Config:
        alias_generator = to_camel
        allow_population_by_field_name = True


# class Categories

# class Families
