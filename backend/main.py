from fastapi import FastAPI  # <- corregido

app = FastAPI()  # <- corregido


@app.get("/")
def index():
    return {"message": "Holi"}  # <- mejor devolver un diccionario
