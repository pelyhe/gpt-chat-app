from pydantic import BaseModel

class User(BaseModel):
    id: str
    username: str
    location: str
    favArtwork: list[str]
    favGallery: list[str]
    favArtist: list[str]
    goAuctions: bool
    goArtfairs: bool
    isVip: bool
