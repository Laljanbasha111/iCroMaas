from pathlib import Path
import gc
import math

import numpy as np
import tensorflow as tf
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware


# ============================================================
# APP
# ============================================================

app = FastAPI(
    title="iCroMaas Crop Analysis API",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models"

CROP_MODEL = BASE_DIR / "models" / "crop_type" / "crop_type_float32.tflite"
CROP_LABELS = BASE_DIR / "models" / "crop_type" / "labels.txt"

BIOMASS_DIR = MODEL_DIR / "biomass"
NITROGEN_DIR = MODEL_DIR / "nitrogen"


# ============================================================
# CROP LABELS
# ============================================================

DEFAULT_CROP_LABELS = [
    "Chick_pea",
    "Common_bean",
    "Cow_pea",
    "Finger_Millet",
    "Finger_millet",
    "Ground_nut",
    "Maize",
    "Mung_bean",
    "Pearl_Millet",
    "Pearl_millet",
    "Pigeon_pea",
    "Sorghum",
]


def load_labels():
    if CROP_LABELS.exists():
        labels = [
            line.strip()
            for line in CROP_LABELS.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        if labels:
            return labels

    return DEFAULT_CROP_LABELS


CROP_LABELS_LIST = load_labels()


# ============================================================
# MODEL NAME MAPPING
# ============================================================

BIOMASS_FILES = {
    "chickpea": "multimodal_biomass_chickpea_float32.tflite",
    "common_bean": "multimodal_biomass_common_bean_float32.tflite",
    "cow_pea": "multimodal_biomass_cow_pea_float32.tflite",
    "finger_millet": "multimodal_biomass_finger_millet_float32.tflite",
    "groundnut": "multimodal_biomass_groundnut_float32.tflite",
    "maize": "multimodal_biomass_maize_float32.tflite",
    "mung_bean": "multimodal_biomass_mung_bean_float32.tflite",
    "pearl_millet": "multimodal_biomass_pearl_millet_float32.tflite",
    "sorghum": "multimodal_biomass_sorghum_float32.tflite",
}


NITROGEN_FILES = {
    "chickpea": "nitrogen_chick_pea_resnet50_float32.tflite",
    "common_bean": "nitrogen_common_bean_resnet50_float32.tflite",
    "cow_pea": "nitrogen_cow_pea_resnet50_float32.tflite",
    "finger_millet": "nitrogen_finger_millet_resnet50_float32.tflite",
    "groundnut": "nitrogen_ground_nut_resnet50_float32.tflite",
    "maize": "nitrogen_maize_resnet50_float32.tflite",
    "mung_bean": "nitrogen_mung_bean_resnet50_float32.tflite",
    "pearl_millet": "nitrogen_pearl_millet_resnet50_float32.tflite",
    "pigeon_pea": "nitrogen_pigeon_pea_resnet50_float32.tflite",
    "sorghum": "nitrogen_sorghum_resnet50_float32.tflite",
}


# ============================================================
# CROP NORMALIZATION
# ============================================================

def normalize_crop_name(crop_name: str) -> str:
    name = crop_name.strip().lower().replace("-", "_").replace(" ", "_")

    aliases = {
        "chick_pea": "chickpea",
        "chickpea": "chickpea",
        "common_bean": "common_bean",
        "cow_pea": "cow_pea",
        "finger_millet": "finger_millet",
        "finger_millet_": "finger_millet",
        "ground_nut": "groundnut",
        "groundnut": "groundnut",
        "maize": "maize",
        "mung_bean": "mung_bean",
        "pearl_millet": "pearl_millet",
        "pigeon_pea": "pigeon_pea",
        "sorghum": "sorghum",
    }

    return aliases.get(name, name)


# ============================================================
# MODEL LOADING
# ============================================================

_crop_interpreter = None


def create_interpreter(model_path: Path):
    if not model_path.exists():
        raise FileNotFoundError(f"Model not found: {model_path}")

    interpreter = tf.lite.Interpreter(
        model_path=str(model_path),
        num_threads=2,
    )
    interpreter.allocate_tensors()
    return interpreter


def get_crop_interpreter():
    global _crop_interpreter

    if _crop_interpreter is None:
        _crop_interpreter = create_interpreter(CROP_MODEL)

    return _crop_interpreter


# ============================================================
# IMAGE PREPROCESSING
# ============================================================

IMAGENET_MEAN = np.array(
    [0.485, 0.456, 0.406],
    dtype=np.float32,
)

IMAGENET_STD = np.array(
    [0.229, 0.224, 0.225],
    dtype=np.float32,
)


def image_to_rgb(image_bytes: bytes) -> Image.Image:
    image = Image.open(
        __import__("io").BytesIO(image_bytes)
    ).convert("RGB")

    return image


def preprocess_crop_image(image: Image.Image) -> np.ndarray:
    # Crop-type model expects 640x640 RGB float32.
    width, height = image.size

    scale = 640.0 / min(width, height)

    new_width = max(640, int(round(width * scale)))
    new_height = max(640, int(round(height * scale)))

    resized = image.resize(
        (new_width, new_height),
        Image.Resampling.BILINEAR,
    )

    left = (new_width - 640) // 2
    top = (new_height - 640) // 2

    cropped = resized.crop(
        (left, top, left + 640, top + 640)
    )

    arr = np.asarray(cropped, dtype=np.float32) / 255.0

    return np.expand_dims(arr, axis=0)


def preprocess_224_image(image: Image.Image) -> np.ndarray:
    resized = image.resize(
        (224, 224),
        Image.Resampling.BILINEAR,
    )

    arr = np.asarray(
        resized,
        dtype=np.float32,
    ) / 255.0

    arr = (arr - IMAGENET_MEAN) / IMAGENET_STD

    return np.expand_dims(arr, axis=0).astype(np.float32)


# ============================================================
# CROP TYPE INFERENCE
# ============================================================

def softmax(values: np.ndarray) -> np.ndarray:
    values = values.astype(np.float64)

    maximum = np.max(values)
    exp_values = np.exp(values - maximum)

    return exp_values / np.sum(exp_values)


def predict_crop_type(image: Image.Image):
    interpreter = get_crop_interpreter()

    inputs = interpreter.get_input_details()
    outputs = interpreter.get_output_details()

    image_input_index = None

    for item in inputs:
        if item["name"] == "images":
            image_input_index = item["index"]
            break

    if image_input_index is None:
        image_input_index = inputs[0]["index"]

    input_data = preprocess_crop_image(image)

    interpreter.set_tensor(
        image_input_index,
        input_data,
    )

    interpreter.invoke()

    output_data = interpreter.get_tensor(
        outputs[0]["index"]
    )[0]

    probabilities = softmax(output_data)

    predicted_index = int(np.argmax(probabilities))

    confidence = float(
        probabilities[predicted_index]
    )

    if predicted_index < len(CROP_LABELS_LIST):
        crop_label = CROP_LABELS_LIST[predicted_index]
    else:
        crop_label = f"class_{predicted_index}"

    return {
        "index": predicted_index,
        "cropType": crop_label,
        "confidence": confidence,
        "probabilities": probabilities.tolist(),
    }


# ============================================================
# MULTIMODAL REGRESSION INFERENCE
# ============================================================

def find_named_input(inputs, name):
    for item in inputs:
        if item["name"] == name:
            return item

    return None


def predict_multimodal(
    model_path: Path,
    image: Image.Image,
):
    interpreter = create_interpreter(model_path)

    try:
        inputs = interpreter.get_input_details()
        outputs = interpreter.get_output_details()

        image_input = find_named_input(
            inputs,
            "image_input",
        )

        tabular_input = find_named_input(
            inputs,
            "tabular_input",
        )

        if image_input is None:
            image_input = inputs[0]

        if tabular_input is None:
            if len(inputs) < 2:
                raise RuntimeError(
                    "Model does not contain the required second input."
                )
            tabular_input = inputs[1]

        image_tensor = preprocess_224_image(image)

        # The exported models require [1,2].
        # Feature semantics are not documented in the supplied files.
        # Biomass conversion explicitly used two zero-padding values.
        # We therefore use zeros until the original feature definitions
        # are recovered.
        tabular_tensor = np.zeros(
            (1, 2),
            dtype=np.float32,
        )

        interpreter.set_tensor(
            image_input["index"],
            image_tensor,
        )

        interpreter.set_tensor(
            tabular_input["index"],
            tabular_tensor,
        )

        interpreter.invoke()

        output = interpreter.get_tensor(
            outputs[0]["index"]
        )

        value = float(
            np.asarray(output).reshape(-1)[0]
        )

        if not math.isfinite(value):
            raise RuntimeError(
                f"Model returned non-finite value: {value}"
            )

        return value

    finally:
        del interpreter
        gc.collect()


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "status": "online",
        "service": "iCroMaas",
        "version": "2.0.0",
        "models": {
            "crop_type": CROP_MODEL.exists(),
            "biomass_models": len(BIOMASS_FILES),
            "nitrogen_models": len(NITROGEN_FILES),
        },
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "crop_type_model": CROP_MODEL.exists(),
        "biomass_models_available": len(
            [
                f for f in BIOMASS_FILES.values()
                if (BIOMASS_DIR / f).exists()
            ]
        ),
        "nitrogen_models_available": len(
            [
                f for f in NITROGEN_FILES.values()
                if (NITROGEN_DIR / f).exists()
            ]
        ),
    }


# ============================================================
# ANALYZE
# ============================================================

@app.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    try:
        image_bytes = await image.read()

        if not image_bytes:
            raise HTTPException(
                status_code=400,
                detail="Empty image received.",
            )

        pil_image = image_to_rgb(image_bytes)

        # ----------------------------------------------------
        # 1. REAL CROP TYPE MODEL
        # ----------------------------------------------------

        crop_result = predict_crop_type(
            pil_image
        )

        detected_crop = normalize_crop_name(
            crop_result["cropType"]
        )

        # ----------------------------------------------------
        # 2. MATCHING BIOMASS MODEL
        # ----------------------------------------------------

        biomass_value = None

        biomass_filename = BIOMASS_FILES.get(
            detected_crop
        )

        if biomass_filename:
            biomass_path = (
                BIOMASS_DIR / biomass_filename
            )

            if biomass_path.exists():
                biomass_value = predict_multimodal(
                    biomass_path,
                    pil_image,
                )

        # ----------------------------------------------------
        # 3. MATCHING NITROGEN MODEL
        # ----------------------------------------------------

        nitrogen_value = None

        nitrogen_filename = NITROGEN_FILES.get(
            detected_crop
        )

        if nitrogen_filename:
            nitrogen_path = (
                NITROGEN_DIR / nitrogen_filename
            )

            if nitrogen_path.exists():
                nitrogen_value = predict_multimodal(
                    nitrogen_path,
                    pil_image,
                )

        # ----------------------------------------------------
        # RESPONSE
        # ----------------------------------------------------

        return {
            "status": "success",
            "analysis": {
                "cropType": crop_result["cropType"],
                "cropTypeConfidence": crop_result["confidence"],
                "biomass": biomass_value,
                "nitrogen": nitrogen_value,
                "biomassModel": biomass_filename,
                "nitrogenModel": nitrogen_filename,
                "geminiExplanation": None,
            },
        }

    except HTTPException:
        raise

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        )


# ============================================================
# STARTUP
# ============================================================

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
    )