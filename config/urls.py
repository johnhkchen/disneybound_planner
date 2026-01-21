"""
URL configuration for Disneybound Planner.
"""

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from django.views.generic import TemplateView

urlpatterns = [
    # Admin
    path("admin/", admin.site.urls),
    # Authentication (django-allauth)
    path("accounts/", include("allauth.urls")),
    # Home
    path("", TemplateView.as_view(template_name="pages/home.html"), name="home"),
    # Health check (for Fly.io monitoring)
    path("", include("apps.core.urls")),
    # Apps
    path("characters/", include("apps.characters.urls", namespace="characters")),
    path("outfits/", include("apps.outfits.urls", namespace="outfits")),
    path("trips/", include("apps.trips.urls", namespace="trips")),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
