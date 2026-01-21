from django.urls import path
from django.views.generic import TemplateView

app_name = "characters"

urlpatterns = [
    path("", TemplateView.as_view(template_name="characters/list.html"), name="list"),
    path("<slug:slug>/", TemplateView.as_view(template_name="characters/detail.html"), name="detail"),
]
