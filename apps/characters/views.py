import logging
import threading

from django.shortcuts import render, get_object_or_404
from django.http import HttpRequest, HttpResponse
from django.views.decorators.http import require_http_methods

from baml_client.sync_client import b as baml

from .models import Character
from .services import (
    find_cached_character,
    save_character_from_result,
    fetch_character_thumbnail,
    normalize_query,
)

logger = logging.getLogger(__name__)


def character_list(request: HttpRequest) -> HttpResponse:
    """Display the character catalog with search."""
    category = request.GET.get("category", "")

    characters = Character.objects.all().order_by("-updated_at")

    if category:
        characters = characters.filter(category__iexact=category)

    # Get distinct categories for the filter dropdown
    categories = Character.objects.values_list("category", flat=True).distinct()

    return render(request, "characters/list.html", {
        "characters": characters,
        "categories": sorted(set(categories)),
        "selected_category": category,
    })


def character_detail(request: HttpRequest, pk: int) -> HttpResponse:
    """Display a single character's details."""
    character = get_object_or_404(Character, pk=pk)
    return render(request, "characters/detail.html", {
        "character": character,
    })


def _fetch_thumbnail_async(character):
    """Fetch thumbnail in background thread."""
    try:
        fetch_character_thumbnail(character)
    except Exception as e:
        logger.error(f"Background thumbnail fetch failed: {e}")


@require_http_methods(["POST"])
def search(request: HttpRequest) -> HttpResponse:
    """Search for a Disney character by name using AI with caching."""
    query = request.POST.get("q", "").strip()

    if not query:
        return render(request, "characters/partials/search_results.html", {
            "error": "Please enter a character name to search."
        })

    # Normalize query for consistent matching
    normalized = normalize_query(query)

    # Check cache first
    cached_character = find_cached_character(normalized)

    if cached_character:
        logger.info(f"Cache hit for query: {query}")

        # Trigger background thumbnail fetch if missing
        if not cached_character.thumbnail_url:
            thread = threading.Thread(
                target=_fetch_thumbnail_async,
                args=(cached_character,),
                daemon=True,
            )
            thread.start()

        return render(request, "characters/partials/search_results.html", {
            "result": cached_character.to_result_dict(),
            "query": query,
            "cached": True,
        })

    # Cache miss - call BAML
    try:
        logger.info(f"Cache miss for query: {query}, calling LLM")
        result = baml.SearchCharacter(query=query)

        # Save to cache if character was found
        if result.found:
            character = save_character_from_result(result, query)
            if character:
                # Trigger background thumbnail fetch
                thread = threading.Thread(
                    target=_fetch_thumbnail_async,
                    args=(character,),
                    daemon=True,
                )
                thread.start()

        return render(request, "characters/partials/search_results.html", {
            "result": result,
            "query": query,
            "cached": False,
        })
    except Exception as e:
        logger.error(f"Search failed: {e}")
        return render(request, "characters/partials/search_results.html", {
            "error": f"Search failed: {str(e)}",
            "query": query,
        })
