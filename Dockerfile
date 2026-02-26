# --- Stage 1: Builder ---
FROM python:3.10-slim-bookworm AS builder

WORKDIR /app

# Install build tools needed for chroma-hnswlib and other C-extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install to a specific prefix to easily move it later
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Stage 2: Runtime ---
FROM python:3.10-slim-bookworm

# 1. Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:${PATH}" \
    PYTHONPATH="/install/lib/python3.10/site-packages"

WORKDIR /app

# 2. Security: Non-root user
RUN useradd -m appuser && chown -R appuser /app

# 3. Copy only the installed packages (saves ~800MB - 1GB of build bloat)
COPY --from=builder /install /install
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8501

# Healthcheck for Streamlit
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl --fail http://localhost:8501/_stcore/health || exit 1

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]


#FROM python:3.10-slim-bookworm

#WORKDIR /app

# Install only dependencies first (better caching, smaller layers)
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt

# Then copy source code
#COPY . .

#EXPOSE 8501
#ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]



