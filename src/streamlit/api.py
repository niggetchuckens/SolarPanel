import math
import os
import subprocess
import sys
import time
from typing import Any, Dict

import requests

URL_SIMULATE = "http://127.0.0.1:5000/api/simulate"
URL_CALCULATE = "http://127.0.0.1:5000/api/calculate"
URL_ENERGY = "http://127.0.0.1:5000/api/energy"
URL_SURFACE = "http://127.0.0.1:5000/api/surface"
URL_OPTIMAL = "http://127.0.0.1:5000/api/optimal"
URL_DIRECTIONAL_DERIVATIVE = "http://127.0.0.1:5000/api/directional-derivative"
URL_HESSIAN = "http://127.0.0.1:5000/api/hessian"


def ensure_backend_running() -> bool:
    try:
        r = requests.get("http://127.0.0.1:5000/api/health", timeout=0.5)
        if r.status_code == 200:
            return True
    except Exception:
        pass

    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    app_path = os.path.join(root_dir, "src", "api", "app.py")
    if os.path.exists(app_path):
        try:
            subprocess.Popen(
                [sys.executable, app_path],
                cwd=root_dir,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
            for _ in range(10):
                time.sleep(0.5)
                try:
                    r = requests.get("http://127.0.0.1:5000/api/health", timeout=0.5)
                    if r.status_code == 200:
                        return True
                except Exception:
                    continue
        except Exception:
            pass
    return False


def _safe_post(url: str, json_data: Dict[str, Any], timeout: int = 10) -> Dict[str, Any]:
    try:
        response = requests.post(url, json=json_data, timeout=timeout)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        if ensure_backend_running():
            try:
                response = requests.post(url, json=json_data, timeout=timeout)
                response.raise_for_status()
                return response.json()
            except requests.exceptions.RequestException as e2:
                return {"status": "error", "message": str(e2)}
        return {"status": "error", "message": str(e)}


def simular(
    latitude, longitude, width, height, season="summer", date=None, power_gen_kw=1.0
) -> Dict[str, Any]:
    datos = {
        "latitude": latitude,
        "longitude": longitude,
        "width_m": width,
        "height_m": height,
        "season": season,
        "date": date,
        "power_gen_kw": power_gen_kw,
    }
    return _safe_post(URL_SIMULATE, datos, timeout=30)


def calcular(
    latitude, longitude, delta_theta, delta_phi, power_gen=1.0
) -> Dict[str, Any]:
    datos = {
        "latitude": latitude,
        "longitude": longitude,
        "delta_theta": delta_theta,
        "delta_phi": delta_phi,
        "power_gen": power_gen,
    }
    return _safe_post(URL_CALCULATE, datos, timeout=10)


def obtener_energia(theta, phi, A, theta0, phi0) -> Dict[str, Any]:
    datos = {
        "theta": theta,
        "phi": phi,
        "A": A,
        "theta0": theta0,
        "phi0": phi0,
    }
    return _safe_post(URL_ENERGY, datos, timeout=10)


def obtener_superficie(A, theta0, phi0, res=40) -> Dict[str, Any]:
    datos = {
        "A": A,
        "theta0": theta0,
        "phi0": phi0,
        "res": res,
    }
    return _safe_post(URL_SURFACE, datos, timeout=10)


def obtener_optimo(latitude, power_gen) -> Dict[str, Any]:
    datos = {
        "latitude": latitude,
        "power_gen": power_gen,
    }
    return _safe_post(URL_OPTIMAL, datos, timeout=10)


def obtener_derivada_direccional(theta, phi, A, theta0, phi0, alpha) -> Dict[str, Any]:
    datos = {
        "theta": theta,
        "phi": phi,
        "A": A,
        "theta0": theta0,
        "phi0": phi0,
        "alpha": alpha,
    }
    return _safe_post(URL_DIRECTIONAL_DERIVATIVE, datos, timeout=10)


def obtener_hessiano(theta, phi, A, theta0, phi0) -> Dict[str, Any]:
    datos = {
        "theta": theta,
        "phi": phi,
        "A": A,
        "theta0": theta0,
        "phi0": phi0,
    }
    return _safe_post(URL_HESSIAN, datos, timeout=30)
