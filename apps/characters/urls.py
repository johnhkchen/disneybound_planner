from django.urls import path

from . import views

app_name = "characters"

urlpatterns = [
    path("", views.character_list, name="list"),
    path("search/", views.search, name="search"),
    path("<int:pk>/", views.character_detail, name="detail"),
]
