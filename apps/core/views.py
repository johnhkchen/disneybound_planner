"""Core views including health check endpoint."""

from django.db import connection
from django.http import JsonResponse


def health_check(request):
    """
    Health check endpoint for Fly.io.

    Returns JSON with status and database connectivity.
    Returns 200 if healthy, 503 if unhealthy.
    """
    checks = {
        "status": "healthy",
        "database": "ok",
    }

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
    except Exception as e:
        checks["database"] = f"error: {e}"
        checks["status"] = "unhealthy"
        return JsonResponse(checks, status=503)

    return JsonResponse(checks)
