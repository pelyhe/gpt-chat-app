from pydantic import BaseModel, SecretStr
from typing import Optional
from uuid import UUID, uuid4
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"])

class User(BaseModel):
    id: Optional[UUID] = uuid4
    username: str
