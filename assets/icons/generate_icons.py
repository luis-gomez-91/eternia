"""Genera candidatos de íconos de habilidades con Gemini (GUIA-VISUAL.md, Íconos).

Lee las instrucciones de prompts.json (estilo común + color de la clase + motivo),
pide imágenes cuadradas a la API de Gemini y guarda cada candidato en
assets/icons/candidates/<Id>/<modelo>_<n>.png (sin subir a Git). Lleva la cuenta
de imágenes pedidas en candidates/usage.json para no pasarse del presupuesto.

Uso:
  python3 -I assets/icons/generate_icons.py Fireball Cleave --model gemini-3.1-flash-image --count 3
  python3 -I assets/icons/generate_icons.py all --count 3
  python3 -I assets/icons/generate_icons.py all --prompts assets/concepts/prompts.json --count 2

Con --prompts sirve para otras imágenes (por ejemplo, los conceptos de arte): los
candidatos van a la carpeta candidates/ junto a ese prompts.json. Cada entrada puede
tener "class" (agrega el color de la clase) y "aspect" (por defecto 1:1). La cuenta
de imágenes es una sola para todo el proyecto.

La clave va en .env como GEMINI_API_KEY.
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
OUT_DIR = os.path.join(HERE, "candidates")
USAGE = os.path.join(OUT_DIR, "usage.json")
API = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
MAX_IMAGES = 150  # tope de seguridad para la prueba (presupuesto de 10 USD)


def load_key():
    key = os.environ.get("GEMINI_API_KEY")
    if key:
        return key
    with open(os.path.join(ROOT, ".env")) as f:
        for line in f:
            name, _, value = line.strip().partition("=")
            if name == "GEMINI_API_KEY" and value:
                return value.strip().strip('"')
    sys.exit("Falta GEMINI_API_KEY en .env")


def load_usage():
    if os.path.exists(USAGE):
        with open(USAGE) as f:
            return json.load(f)
    return {"images": 0, "by_model": {}}


def save_usage(usage):
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(USAGE, "w") as f:
        json.dump(usage, f, indent=2)


def build_prompt(prompts, ability_id):
    entry = prompts["abilities"][ability_id]
    accent = prompts.get("class", {}).get(entry.get("class"), "")
    return " ".join(part for part in (prompts["style"], accent, f"Motif: {entry['prompt']}") if part)


def generate(key, model, prompt, aspect="1:1"):
    """Pide una imagen con curl (el Python de python.org no trae certificados SSL).
    La clave va por la entrada estándar, no en los argumentos del proceso."""
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE"], "imageConfig": {"aspectRatio": aspect}},
    }
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
        json.dump(body, f)
        body_path = f.name
    try:
        result = subprocess.run(
            [
                "curl", "-s", "--max-time", "180",
                "-H", "@-",
                "-H", "Content-Type: application/json",
                "--data-binary", f"@{body_path}",
                API.format(model=model),
            ],
            input=f"x-goog-api-key: {key}\n",
            capture_output=True,
            text=True,
        )
    finally:
        os.unlink(body_path)
    if result.returncode != 0:
        raise RuntimeError(f"curl falló ({result.returncode}): {result.stderr[:300]}")
    data = json.loads(result.stdout)
    if "error" in data:
        raise RuntimeError(f"API: {json.dumps(data['error'])[:500]}")
    for candidate in data.get("candidates", []):
        for part in candidate.get("content", {}).get("parts", []):
            inline = part.get("inlineData") or part.get("inline_data")
            if inline:
                return base64.b64decode(inline["data"]), inline.get("mimeType", "image/png"), data.get("usageMetadata", {})
    raise RuntimeError(f"Sin imagen en la respuesta: {json.dumps(data)[:500]}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("abilities", nargs="+", help="Ids de prompts.json, o 'all'")
    parser.add_argument("--model", default="gemini-3.1-flash-image")
    parser.add_argument("--count", type=int, default=3)
    parser.add_argument("--prompts", default=os.path.join(HERE, "prompts.json"))
    args = parser.parse_args()

    with open(args.prompts) as f:
        prompts = json.load(f)
    out_dir = os.path.join(os.path.dirname(os.path.abspath(args.prompts)), "candidates")
    ids = list(prompts["abilities"]) if args.abilities == ["all"] else args.abilities
    for ability_id in ids:
        if ability_id not in prompts["abilities"]:
            sys.exit(f"No existe en prompts.json: {ability_id}")

    usage = load_usage()
    planned = len(ids) * args.count
    if usage["images"] + planned > MAX_IMAGES:
        sys.exit(f"Se pasaría del tope: {usage['images']} pedidas + {planned} > {MAX_IMAGES}")

    key = load_key()
    for ability_id in ids:
        folder = os.path.join(out_dir, ability_id)
        os.makedirs(folder, exist_ok=True)
        prompt = build_prompt(prompts, ability_id)
        aspect = prompts["abilities"][ability_id].get("aspect", "1:1")
        for _ in range(args.count):
            # siguiente número libre, sin importar la extensión (Gemini suele devolver .jpg)
            taken = {os.path.splitext(f)[0] for f in os.listdir(folder)}
            n = 1
            while f"{args.model}_{n}" in taken:
                n += 1
            name = f"{args.model}_{n}"
            try:
                image, mime, meta = generate(key, args.model, prompt, aspect)
            except RuntimeError as err:
                print(f"{ability_id}: error: {err}", flush=True)
                if "RESOURCE_EXHAUSTED" in str(err) or '"code": 429' in str(err):
                    sys.exit("Se llegó al tope de gasto o de uso de Google: se detiene sin seguir pidiendo.")
                continue
            usage["images"] += 1
            usage["by_model"][args.model] = usage["by_model"].get(args.model, 0) + 1
            save_usage(usage)
            ext = ".png" if "png" in mime else ".jpg"
            path = os.path.join(folder, name + ext)
            with open(path, "wb") as f:
                f.write(image)
            tokens = meta.get("candidatesTokenCount", "?")
            print(f"{ability_id}: {os.path.relpath(path, ROOT)} ({tokens} tokens de salida)", flush=True)
    print(f"Imágenes pedidas en total: {usage['images']}")


if __name__ == "__main__":
    main()
