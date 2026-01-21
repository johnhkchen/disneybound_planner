from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.postgres.indexes import GinIndex


class Character(models.Model):
    """Cached Disney character data from LLM search results."""

    # Core identification
    name = models.CharField(max_length=255, db_index=True)
    movie = models.CharField(max_length=255)
    category = models.CharField(max_length=100)
    description = models.TextField()

    # Search metadata - queries that matched this character
    search_queries = ArrayField(
        models.CharField(max_length=255),
        default=list,
        blank=True,
    )

    # Visual assets
    thumbnail_url = models.URLField(max_length=500, blank=True)
    image_attribution = models.CharField(max_length=500, blank=True)

    # Color palette (list of dicts with name, hex, usage)
    colors = models.JSONField(default=list)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            GinIndex(fields=["search_queries"], name="character_queries_gin"),
        ]

    def __str__(self):
        return f"{self.name} ({self.movie})"

    def to_result_dict(self):
        """Convert to dict format matching BAML SearchCharacter result."""
        return {
            "found": True,
            "name": self.name,
            "movie": self.movie,
            "category": self.category,
            "description": self.description,
            "colors": self.colors,
            "thumbnail_url": self.thumbnail_url,
            "image_attribution": self.image_attribution,
        }
