from django.urls import path
from django.views.generic import TemplateView

app_name = "outfits"

urlpatterns = [
    path("", TemplateView.as_view(template_name="outfits/list.html"), name="list"),
    path(
        "create/",
        TemplateView.as_view(template_name="outfits/create.html"),
        name="create",
    ),
    path(
        "<int:pk>/",
        TemplateView.as_view(template_name="outfits/detail.html"),
        name="detail",
    ),
]
