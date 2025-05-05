import os
import joblib
import numpy as np
from django.conf import settings
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .serializers import CropPredictionSerializer
from .models import Crop, Prediction
from datetime import datetime

# Build absolute paths to model files
MODEL_DIR = os.path.join(settings.BASE_DIR, 'predictor', 'models')
KNN_MODEL_PATH = os.path.join(MODEL_DIR, 'knn_model.pkl')
ANN_MODEL_PATH = os.path.join(MODEL_DIR, 'ann_model.pkl')
ANN_SCALER_PATH = os.path.join(MODEL_DIR, 'ann_scaler.pkl')
ENCODERS_PATH = os.path.join(MODEL_DIR, 'label_encoders.pkl')

# Load models
try:
    knn_model = joblib.load(KNN_MODEL_PATH)
    ann_model = joblib.load(ANN_MODEL_PATH)
    # ann_scaler = joblib.load(ANN_SCALER_PATH)
    label_encs = joblib.load(ENCODERS_PATH)
except FileNotFoundError as e:
    raise FileNotFoundError(f"Could not load model file: {e.filename}")

@api_view(['POST'])
def predict_growth(request):
    print("Received predict_growth request:", request.data)
    serializer = CropPredictionSerializer(data=request.data)
    if not serializer.is_valid():
        print("Serializer errors:", serializer.errors)
        return Response(serializer.errors, status=400)

    data = serializer.validated_data
    features = np.array([[
        data['moisture'], data['temperature'], data['sunlight'],
        data['humidity'], data['rainfall'], data['soil_ph']
    ]])
    growth_stage_num = knn_model.predict(features)[0]
    
    # Map numerical output to categorical growth stage
    if growth_stage_num < 25:
        growth_stage = 'Seedling'
    elif growth_stage_num < 50:
        growth_stage = 'Vegetative'
    elif growth_stage_num < 75:
        growth_stage = 'Reproductive'
    else:
        growth_stage = 'Maturity'

    crop, _ = Crop.objects.get_or_create(
        crop_type=data['crop_type'],
        soil_type=data['soil_type'],
        planting_date=data['planting_date'],
        defaults={
            'moisture': data['moisture'],
            'temperature': data['temperature'],
            'sunlight': data['sunlight'],
            'humidity': data['humidity'],
            'rainfall': data['rainfall'],
            'soil_ph': data['soil_ph'],
        }
    )
    prediction_date = datetime.strptime(data['planting_date'], '%Y-%m-%d').date()
    Prediction.objects.create(
        crop=crop,
        growth_stage=growth_stage,
        predicted_yield=0.0,
        prediction_date=prediction_date
    )
    return Response({'growth_stage': growth_stage})

@api_view(['POST'])
def predict_yield(request):
    print("Received predict_yield request:", request.data)
    serializer = CropPredictionSerializer(data=request.data)
    if not serializer.is_valid():
        print("Serializer errors:", serializer.errors)
        return Response(serializer.errors, status=400)

    data = serializer.validated_data
    try:
        ct = label_encs['Crop_Type'].transform([data['crop_type']])[0]
        st = label_encs['Soil_Type'].transform([data['soil_type']])[0]
    except Exception:
        return Response({"error": "Invalid crop_type or soil_type"}, status=400)

    features = np.array([[
        ct, st,
        data['N'], data['P'], data['K'],
        data['Temperature'], data['Humidity'],
        data['Wind_Speed'], data['Soil_pH']
    ]])
    predicted_yield = float(ann_model.predict(features)[0])

    crop, _ = Crop.objects.get_or_create(
        crop_type=data['crop_type'],
        soil_type=data['soil_type'],
        planting_date=data['planting_date'],
        defaults={
            'moisture': data.get('moisture', None),
            'temperature': data['Temperature'],
            'sunlight': data.get('sunlight', 0.0),
            'humidity': data['Humidity'],
            'rainfall': data.get('rainfall', 0.0),
            'soil_ph': data['Soil_pH'],
        }
    )
    # Convert planting_date string to date object
    prediction_date = datetime.strptime(data['planting_date'], '%Y-%m-%d').date()
    Prediction.objects.create(
        crop=crop,
        growth_stage='N/A',
        predicted_yield=predicted_yield,
        prediction_date=prediction_date
    )
    return Response({'predicted_yield': round(predicted_yield, 2)})