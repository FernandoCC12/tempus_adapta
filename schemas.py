from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    deadline: Optional[datetime] = None

class ProjectCreate(ProjectBase):
    pass

class Project(ProjectBase):
    id: int
    class Config:
        from_attributes = True

class ActivityBase(BaseModel):
    name: str
    project_id: Optional[int] = None
    duration_minutes: int
    energy_level: int
    status: str = "pending"

class ActivityCreate(ActivityBase):
    pass

class Activity(ActivityBase):
    id: int
    class Config:
        from_attributes = True

class EventBase(BaseModel):
    name: str
    start_time: datetime
    end_time: datetime
    is_fixed: bool = True

class EventCreate(EventBase):
    pass

class Event(EventBase):
    id: int
    class Config:
        from_attributes = True
