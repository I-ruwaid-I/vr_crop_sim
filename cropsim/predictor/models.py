from django.db import models

class Crop(models.Model):
    CROP_TYPES = [
        ('Wheat', 'Wheat'),
        ('Rice', 'Rice'),
        ('Maize', 'Maize'),
        ('Barley', 'Barley'),
        ('Soybean', 'Soybean'),
    ]

    SOIL_TYPES = [
        ('Loamy', 'Loamy'),
        ('Clay', 'Clay'),
        ('Sandy', 'Sandy'),
        ('Peaty', 'Peaty'),
    ]

    crop_type = models.CharField(max_length=50, choices=CROP_TYPES)
    soil_type = models.CharField(max_length=50, choices=SOIL_TYPES)
    planting_date = models.DateField()
    moisture = models.FloatField(null=True)  # Moisture content in %
    temperature = models.FloatField()  # Temperature in °C
    sunlight = models.FloatField()  # Sunlight in hours/day
    humidity = models.FloatField()  # Humidity in %
    rainfall = models.FloatField()  # Rainfall in mm
    soil_ph = models.FloatField()  # Soil pH level

    def __str__(self):
        return f"{self.crop_type} - {self.planting_date}"

class Prediction(models.Model):
    GROWTH_STAGES = [
        ('Seedling', 'Seedling'),
        ('Vegetative', 'Vegetative'),
        ('Reproductive', 'Reproductive'),
        ('Maturity', 'Maturity'),
    ]
    
    crop = models.ForeignKey(Crop, related_name='predictions', on_delete=models.CASCADE)
    growth_stage = models.CharField(max_length=50, choices=GROWTH_STAGES)
    predicted_yield = models.FloatField()  # Predicted yield in kg
    prediction_date = models.DateField(auto_now_add=True)

    def __str__(self):
        return f"{self.crop} - {self.growth_stage}"