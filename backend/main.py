import os, uuid, json
from datetime import datetime, timedelta
from typing import List, Optional, Any, Dict

from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import create_engine, Column, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from passlib.context import CryptContext
from jose import jwt, JWTError

SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me")
ALGORITHM = "HS256"
EXPIRE_MIN = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "10080"))
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./droidcraft.db")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Project(Base):
    __tablename__ = "projects"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    name = Column(String, nullable=False)
    template = Column(String, default="blank")
    data = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


Base.metadata.create_all(bind=engine)


class SignupIn(BaseModel):
    name: str = Field(min_length=1)
    email: EmailStr
    password: str = Field(min_length=6)


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: Dict[str, Any]


class UserOut(BaseModel):
    id: str
    name: str
    email: EmailStr


class ProjectIn(BaseModel):
    name: str
    template: str = "blank"
    screens: List[Dict[str, Any]]


class ProjectOut(BaseModel):
    id: str
    name: str
    template: str
    screens: List[Dict[str, Any]]
    updatedAt: str


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def hash_pw(p: str) -> str:
    return pwd_context.hash(p)


def verify_pw(p: str, h: str) -> bool:
    return pwd_context.verify(p, h)


def create_token(uid: str) -> str:
    exp = datetime.utcnow() + timedelta(minutes=EXPIRE_MIN)
    return jwt.encode({"sub": uid, "exp": exp}, SECRET_KEY, algorithm=ALGORITHM)


def current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    err = HTTPException(status_code=401, detail="Invalid authentication token")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        uid = payload.get("sub")
        if not uid:
            raise err
    except JWTError:
        raise err
    u = db.query(User).filter(User.id == uid).first()
    if not u:
        raise err
    return u


def project_out(p: Project) -> ProjectOut:
    return ProjectOut(
        id=p.id,
        name=p.name,
        template=p.template,
        screens=json.loads(p.data).get("screens", []),
        updatedAt=p.updated_at.isoformat(),
    )


app = FastAPI(title="DroidCraft API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def seed():
    db = SessionLocal()
    try:
        for name, email in [("Alex", "alex@demo.com"), ("Sam", "sam@demo.com")]:
            if not db.query(User).filter(User.email == email).first():
                db.add(User(name=name, email=email, password_hash=hash_pw("demo1234")))
        db.commit()
    finally:
        db.close()


@app.get("/")
def root():
    return {"service": "DroidCraft API", "status": "ok"}


@app.post("/auth/signup", response_model=TokenOut)
def signup(body: SignupIn, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == body.email.lower()).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    u = User(name=body.name.strip(), email=body.email.lower(), password_hash=hash_pw(body.password))
    db.add(u)
    db.commit()
    db.refresh(u)
    return TokenOut(
        access_token=create_token(u.id),
        user={"id": u.id, "name": u.name, "email": u.email},
    )


@app.post("/auth/login", response_model=TokenOut)
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    u = db.query(User).filter(User.email == form.username.lower()).first()
    if not u or not verify_pw(form.password, u.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return TokenOut(
        access_token=create_token(u.id),
        user={"id": u.id, "name": u.name, "email": u.email},
    )


@app.get("/auth/me", response_model=UserOut)
def me(u: User = Depends(current_user)):
    return UserOut(id=u.id, name=u.name, email=u.email)


@app.get("/projects", response_model=List[ProjectOut])
def list_projects(u: User = Depends(current_user), db: Session = Depends(get_db)):
    rows = db.query(Project).filter(Project.user_id == u.id).order_by(Project.updated_at.desc()).all()
    return [project_out(p) for p in rows]


@app.post("/projects", response_model=ProjectOut, status_code=201)
def create_project(body: ProjectIn, u: User = Depends(current_user), db: Session = Depends(get_db)):
    p = Project(
        user_id=u.id,
        name=body.name.strip() or "Untitled App",
        template=body.template,
        data=json.dumps({"screens": body.screens}),
    )
    db.add(p)
    db.commit()
    db.refresh(p)
    return project_out(p)


@app.get("/projects/{pid}", response_model=ProjectOut)
def get_project(pid: str, u: User = Depends(current_user), db: Session = Depends(get_db)):
    p = db.query(Project).filter(Project.id == pid, Project.user_id == u.id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Project not found")
    return project_out(p)


@app.put("/projects/{pid}", response_model=ProjectOut)
def update_project(pid: str, body: ProjectIn, u: User = Depends(current_user), db: Session = Depends(get_db)):
    p = db.query(Project).filter(Project.id == pid, Project.user_id == u.id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Project not found")
    p.name = body.name.strip() or p.name
    p.template = body.template
    p.data = json.dumps({"screens": body.screens})
    p.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(p)
    return project_out(p)


@app.delete("/projects/{pid}", status_code=204)
def delete_project(pid: str, u: User = Depends(current_user), db: Session = Depends(get_db)):
    p = db.query(Project).filter(Project.id == pid, Project.user_id == u.id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Project not found")
    db.delete(p)
    db.commit()
    return None
