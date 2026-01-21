from django.urls import path
from django.views.generic import TemplateView

app_name = "trips"

urlpatterns = [
    path("", TemplateView.as_view(template_name="trips/list.html"), name="list"),
    path("create/", TemplateView.as_view(template_name="trips/create.html"), name="create"),
    path("<int:pk>/", TemplateView.as_view(template_name="trips/detail.html"), name="detail"),
]
