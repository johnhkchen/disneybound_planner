from django.shortcuts import render
from django.http import HttpRequest, HttpResponse
from django.views.decorators.http import require_http_methods

from baml_client.sync_client import b as baml


@require_http_methods(["POST"])
def search(request: HttpRequest) -> HttpResponse:
    """Search for a Disney character by name using AI."""
    query = request.POST.get("q", "").strip()

    if not query:
        return render(request, "characters/partials/search_results.html", {
            "error": "Please enter a character name to search."
        })

    try:
        result = baml.SearchCharacter(query=query)
        return render(request, "characters/partials/search_results.html", {
            "result": result,
            "query": query,
        })
    except Exception as e:
        return render(request, "characters/partials/search_results.html", {
            "error": f"Search failed: {str(e)}",
            "query": query,
        })
