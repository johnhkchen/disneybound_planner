ARG PYTHON_VERSION=3.13-slim

FROM python:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies including Node.js for Tailwind
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install Python dependencies
COPY pyproject.toml uv.lock /code/
RUN uv sync --frozen --no-dev

# Copy application code
COPY . /code

# Build Tailwind CSS using the CLI directly
# Build Tailwind CSS
RUN npm install tailwindcss @tailwindcss/cli \
    && npx @tailwindcss/cli -i ./static/css/main.css -o ./static/css/compiled.css --minify \
    && mv ./static/css/compiled.css ./static/css/main.css

# Collect static files
ARG SECRET_KEY="build-time-placeholder"
ENV SECRET_KEY=${SECRET_KEY}
RUN uv run python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["uv", "run", "gunicorn", "--bind", ":8000", "--workers", "2", "config.wsgi"]
