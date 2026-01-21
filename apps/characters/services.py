"""
Character caching and TMDB integration services.
"""

import logging
from typing import Optional

import httpx
from django.conf import settings
from django.db.models.functions import Lower

from .models import Character

logger = logging.getLogger(__name__)


def normalize_query(query: str) -> str:
    """Normalize search query for consistent matching."""
    return query.lower().strip()


def find_cached_character(query: str) -> Optional[Character]:
    """
    Check database for a cached character matching the query.

    Matches on:
    - Exact name match (case-insensitive)
    - Query exists in search_queries array
    """
    normalized = normalize_query(query)

    # Try exact name match first (case-insensitive)
    character = (
        Character.objects.annotate(name_lower=Lower("name"))
        .filter(name_lower=normalized)
        .first()
    )

    if character:
        return character

    # Check if query exists in search_queries array
    character = Character.objects.filter(search_queries__contains=[normalized]).first()  # type: ignore[assignment]

    return character


def save_character_from_result(result, query: str) -> Optional[Character]:
    """
    Save a BAML SearchCharacter result to the database.

    Args:
        result: BAML CharacterSearchResult object
        query: The original search query

    Returns:
        Character instance if saved, None if character wasn't found
    """
    if not result.found:
        return None

    normalized_query = normalize_query(query)

    # Check if character already exists by name
    existing = (
        Character.objects.annotate(name_lower=Lower("name"))
        .filter(name_lower=result.name.lower())
        .first()
    )

    if existing:
        # Add query to search_queries if not already present
        if normalized_query not in existing.search_queries:
            existing.search_queries.append(normalized_query)
            existing.save(update_fields=["search_queries", "updated_at"])
        return existing

    # Convert colors from BAML objects to dicts
    colors_data = []
    for color in result.colors:
        colors_data.append(
            {
                "hex": color.hex,
                "name": color.name,
                "usage": color.usage,
            }
        )

    # Create new character
    character = Character.objects.create(
        name=result.name,
        movie=result.movie,
        category=result.category,
        description=result.description,
        colors=colors_data,
        search_queries=[normalized_query],
    )

    return character


def fetch_character_thumbnail(character: Character) -> bool:
    """
    Fetch character thumbnail from TMDB API.

    Searches for the movie first, then looks for the character in credits.

    Args:
        character: Character instance to update

    Returns:
        True if thumbnail was found and saved, False otherwise
    """
    if not settings.TMDB_API_KEY:
        logger.warning("TMDB_API_KEY not configured, skipping thumbnail fetch")
        return False

    if character.thumbnail_url:
        # Already has a thumbnail
        return True

    headers = {
        "Authorization": f"Bearer {settings.TMDB_API_KEY}",
        "accept": "application/json",
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            # Extract movie name without year for better search results
            movie_name = character.movie.split("(")[0].strip()

            # Search for the movie
            search_url = f"{settings.TMDB_BASE_URL}/search/movie"
            response = client.get(
                search_url,
                params={"query": movie_name},
                headers=headers,
            )
            response.raise_for_status()
            search_results = response.json()

            if not search_results.get("results"):
                logger.info(f"No TMDB results for movie: {movie_name}")
                return False

            movie_id = search_results["results"][0]["id"]

            # Get movie credits
            credits_url = f"{settings.TMDB_BASE_URL}/movie/{movie_id}/credits"
            response = client.get(credits_url, headers=headers)
            response.raise_for_status()
            credits = response.json()

            # Look for character in cast
            character_name_lower = character.name.lower()
            for cast_member in credits.get("cast", []):
                cast_character = cast_member.get("character", "").lower()
                if (
                    character_name_lower in cast_character
                    or cast_character in character_name_lower
                ):
                    profile_path = cast_member.get("profile_path")
                    if profile_path:
                        character.thumbnail_url = (
                            f"{settings.TMDB_IMAGE_BASE_URL}{profile_path}"
                        )
                        character.image_attribution = "Image from TMDB"
                        character.save(
                            update_fields=[
                                "thumbnail_url",
                                "image_attribution",
                                "updated_at",
                            ]
                        )
                        logger.info(f"Found thumbnail for {character.name}")
                        return True

            logger.info(f"Character {character.name} not found in TMDB credits")
            return False

    except httpx.HTTPError as e:
        logger.error(f"TMDB API error: {e}")
        return False
    except Exception as e:
        logger.error(f"Error fetching thumbnail: {e}")
        return False
