from django.contrib import admin

from .models import Character


@admin.register(Character)
class CharacterAdmin(admin.ModelAdmin):
    list_display = ["name", "movie", "category", "thumbnail_url", "created_at"]
    list_filter = ["category", "created_at"]
    search_fields = ["name", "movie", "search_queries"]
    readonly_fields = ["created_at", "updated_at"]
