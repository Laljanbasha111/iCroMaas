from fastapi import FastAPI, File, UploadFile, HTTPException
from PIL import Image
import io

from services.crop_type_service import crop_type_service


app = FastAPI(
    title="iCroMaas API",
    version="1.0.0",
)


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


@app.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Please upload an image file",
        )

    contents = await image.read()

    if not contents:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty",
        )

    try:
        img = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception as exc:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid image file: {exc}",
        )

    try:
        crop_result = crop_type_service.predict(img)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Crop model inference failed: {exc}",
        )

    return {
        "status": "ok",
        "message": "Crop analysis completed",
        "filename": image.filename,
        "image_size": {
            "width": img.width,
            "height": img.height,
        },
        "analysis": {
            "cropType": crop_result["cropType"],
            "cropClass": crop_result["cropClass"],
            "cropTypeConfidence": crop_result["cropTypeConfidence"],
            "cropTypeConfidencePercentage": crop_result[
                "cropTypeConfidencePercentage"
            ],
            "topPredictions": crop_result["topPredictions"],
            "biomass": None,
            "nitrogen": None,
            "geminiExplanation": None,
        },
    }
