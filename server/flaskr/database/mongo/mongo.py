from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from pymongo.collection import Collection
from pymongo.database import Database

from flask import g
import os 

db_username = os.environ.get("mongo_db_username")
db_password = os.environ.get("mongo_db_password")

uri = f"mongodb+srv://{db_username}:{db_password}@cluster0.i6crl7k.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

def get_collection(collection_name: str) -> Collection:
    db = _get_db()
    return db[collection_name]

def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.client.close()

def create_db():
    db = _get_db()
    users_collection = db['users']
    users_collection.create_index([("email", 1)], unique=True)
  
def _get_db() -> Database:
    client = MongoClient(uri, server_api=ServerApi('1'))
    return client['database']
