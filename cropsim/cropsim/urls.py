from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/crop/', include('predictor.urls')),  # API endpoints
]

