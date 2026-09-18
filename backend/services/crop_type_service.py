from pathlib import Path
from typing import Any

import numpy as np
import tensorflow as tf
from PIL import Image


BASE_DIR = Path(__file__).resolve().parents[1]
MODEL_PATH = BASE_DIR / "models" / "crop_type" / "crop_type_float32.tflite"
LABELS_PATH = BASE_DIR / "models" / "crop_type" / "labels.txt"


class CropTypeService:
    def __init__(self) -> None:
        if not MODEL_PATH.exists():
            raise FileNotFoundError(f"Crop model not found: {MODEL_PATH}")

        if not LABELS_PATH.exists():
            raise FileNotFoundError(f"Crop labels not found: {LABELS_PATH}")

        self.labels = [
            line.strip()
            for line in LABELS_PATH.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]

        self.interpreter = tf.lite.Interpreter(
            model_path=str(MODEL_PATH)
        )
        self.interpreter.allocate_tensors()

        self.input_details = self.interpreter.get_input_details()[0]
        self.output_details = self.interpreter.get_output_details()[0]

        input_shape = tuple(self.input_details["shape"].tolist())

        if input_shape != (1, 640, 640, 3):
            raise ValueError(
                f"Unexpected crop model input shape: {input_shape}"
            )

        if self.input_details["dtype"] != np.float32:
            raise ValueError(
                f"Unexpected crop model input dtype: "
                f"{self.input_details['dtype']}"
            )

        if tuple(self.output_details["shape"].tolist()) != (1, 12):
            raise ValueError(
                "Unexpected crop model output shape: "
                f"{tuple(self.output_details['shape'].tolist())}"
            )

        if len(self.labels) != 12:
            raise ValueError(
                f"Expected 12 crop labels, found {len(self.labels)}"
            )

    @staticmethod
    def _preprocess(image: Image.Image) -> np.ndarray:
        image = image.convert("RGB")

        width, height = image.size

        if width <= 0 or height <= 0:
            raise ValueError("Invalid image dimensions")

        # Equivalent to:
        # Resize(shortest side -> 640) + CenterCrop(640, 640)
        scale = 640.0 / min(width, height)

        resized_width = max(640, round(width * scale))
        resized_height = max(640, round(height * scale))

        image = image.resize(
            (resized_width, resized_height),
            Image.Resampling.BILINEAR,
        )

        left = (resized_width - 640) // 2
        top = (resized_height - 640) // 2

        image = image.crop(
            (left, top, left + 640, top + 640)
        )

        array = np.asarray(image, dtype=np.float32)

        # ToTensor-style scaling: uint8 [0,255] -> float32 [0,1]
        array /= 255.0

        return np.expand_dims(array, axis=0)

    def predict(self, image: Image.Image) -> dict[str, Any]:
        input_tensor = self._preprocess(image)

        self.interpreter.set_tensor(
            self.input_details["index"],
            input_tensor,
        )
        self.interpreter.invoke()

        probabilities = self.interpreter.get_tensor(
            self.output_details["index"]
        )[0]

        probabilities = np.asarray(
            probabilities,
            dtype=np.float32,
        )

        if probabilities.shape != (12,):
            raise ValueError(
                f"Unexpected prediction shape: {probabilities.shape}"
            )

        top_indices = np.argsort(probabilities)[::-1][:3]

        top_predictions = []

        for index in top_indices:
            class_index = int(index)
            confidence = float(probabilities[class_index])

            top_predictions.append(
                {
                    "classIndex": class_index,
                    "className": self.labels[class_index],
                    "confidence": confidence,
                    "confidencePercentage": round(
                        confidence * 100.0,
                        2,
                    ),
                }
            )

        best_index = int(top_indices[0])
        best_confidence = float(probabilities[best_index])
        best_class = self.labels[best_index]

        return {
            "cropClass": best_class,
            "cropType": best_class.replace("_", " "),
            "cropTypeConfidence": best_confidence,
            "cropTypeConfidencePercentage": round(
                best_confidence * 100.0,
                2,
            ),
            "topPredictions": top_predictions,
        }


crop_type_service = CropTypeService()
