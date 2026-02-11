from fastapi import FastAPI
from pydantic import BaseModel
import faiss
import numpy as np

app = FastAPI()

dimension = 128
index = faiss.IndexFlatL2(dimension)


class SearchRequest(BaseModel):
    query: list[float]
    k: int = 5


@app.post("/add")
def add_vector(vectors: list[list[float]]):
    arr = np.array(vectors).astype("float32")
    index.add(arr)
    return {"status": "ok", "total": index.ntotal}


@app.post("/search")
def search(req: SearchRequest):
    arr = np.array([req.query]).astype("float32")
    distances, indices = index.search(arr, req.k)

    return {
        "distances": distances.tolist(),
        "indices": indices.tolist()
    }


@app.get("/health")
def health():
    return {"status": "running"}
