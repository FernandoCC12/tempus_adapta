from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from .db import Base

class Project(Base):
    __tablename__ = "projects"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, nullable=True)
    deadline = Column(DateTime, nullable=True)
    activities = relationship("Activity", back_populates="project")

class Activity(Base):
    __tablename__ = "activities"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=True)
    duration_minutes = Column(Integer)
    energy_level = Column(Integer) # e.g. 1-5
    status = Column(String, default="pending")
    project = relationship("Project", back_populates="activities")

class Event(Base):
    __tablename__ = "events"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    is_fixed = Column(Boolean, default=True)
