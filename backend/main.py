from fastapi import FastAPI, File, UploadFile, HTTPException
from PIL import Image
import io

from services.crop_type_service import crop_type_service


app = FastAPI(
    title="iCroMaas API",
    version="1.0.0",
)


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "iCroMaas API",
        "message": "Backend is running",
        "models": {
            "crop_type": "loaded",
            "biomass": "not_configured",
            "nitrogen": "not_configured",
        },
    }


# ============================================================
# CROP ANALYSIS
# ============================================================

@app.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    # --------------------------------------------------------
    # Read uploaded file
    # --------------------------------------------------------

    contents = await image.read()

    if not contents:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty",
        )

    # --------------------------------------------------------
    # Validate that the uploaded bytes are actually an image
    # --------------------------------------------------------

    try:
        img = Image.open(io.BytesIO(contents))
        img.load()
        img = img.convert("RGB")

    except Exception as exc:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid image file: {exc}",
        )

    # --------------------------------------------------------
    # Crop type model inference
    # --------------------------------------------------------

    try:
        crop_result = crop_type_service.predict(img)

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Crop model inference failed: {exc}",
        )

    # --------------------------------------------------------
    # Return analysis result
    # --------------------------------------------------------

    return {
        "status": "ok",
        "message": "Crop analysis completed",
        "filename": image.filename,

        "image_size": {
            "width": img.width,
            "height": img.height,
        },

        "analysis": {
            # Crop type
            "cropType": crop_result["cropType"],
            "cropClass": crop_result["cropClass"],
            "cropTypeConfidence": crop_result[
                "cropTypeConfidence"
            ],
            "cropTypeConfidencePercentage": crop_result[
                "cropTypeConfidencePercentage"
            ],
            "topPredictions": crop_result[
                "topPredictions"
            ],

            # These will be connected later
            "biomass": None,
            "nitrogen": None,

            # Gemini is intentionally not used
            "geminiExplanation": None,
        },
    }