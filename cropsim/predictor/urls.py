from django.urls import path
from . import views

urlpatterns = [
    path('predict-growth/', views.predict_growth, name='predict_growth_old'),
    path('predict-yield/', views.predict_yield, name='predict_yield_old'),
]