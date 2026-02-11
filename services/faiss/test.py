import requests
import numpy as np
import time

BASE_URL = "http://192.168.5.111:8001"


def wait_for_service():
    for _ in range(10):
        try:
            r = requests.get(f"{BASE_URL}/health")
            if r.status_code == 200:
                return
        except:
            pass
        time.sleep(1)
    raise Exception("Service not ready")


def test_health():
    r = requests.get(f"{BASE_URL}/health")
    assert r.status_code == 200
    print("✅ health OK")


def test_add():
    vectors = np.random.rand(3, 128).astype("float32").tolist()
    r = requests.post(f"{BASE_URL}/add", json=vectors)
    assert r.status_code == 200
    print("✅ add OK")


def test_search():
    vector = np.ones((1, 128)).astype("float32").tolist()
    requests.post(f"{BASE_URL}/add", json=vector)

    r = requests.post(f"{BASE_URL}/search", json={
        "query": [1.0] * 128,
        "k": 1
    })

    data = r.json()
    assert len(data["indices"][0]) == 1
    print("✅ search OK")


if __name__ == "__main__":
    print("Waiting for service...")
    wait_for_service()

    print("Running tests...\n")

    test_health()
    test_add()
    test_search()

    print("\n🎉 ALL TESTS PASSED")
