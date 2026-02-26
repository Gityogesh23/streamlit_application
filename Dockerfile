# --- Stage 1: Builder ---
FROM python:3.10-slim-bookworm AS builder

# Prevent python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies into a temporary location
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Stage 2: Final Runtime ---
FROM python:3.10-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

WORKDIR /app

# Create a non-root user for security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Copy ONLY the installed python packages from the builder stage
# This leaves behind build-essential, git, and pip cache (saving ~1GB+)
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
# FROM python:3.10-slim-bookworm
# # Expose the standard Streamlit port.
# EXPOSE 8501

# # Set the working directory first.
# WORKDIR /app

# # Copy the core file needed for dependency installation first.
# # FIX: Simplified copy destination to '.' (which means /app) to prevent path errors.
# COPY requirements.txt .

# # Install required system packages in a single 'RUN' command and clean up immediately
# # to save space. We use --no-install-recommends to keep the image minimal.
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     git \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# Install Python dependencies, optimizing for size and speed.
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt --root-user-action=ignore

# Now copy the rest of the application files (app.py, etc.).
# FIX: Simplified copy destination to '.' (which means /app).
# The .dockerignore file ensures large, unnecessary files are skipped.
COPY . .

# --- ENTRYPOINT ---
# Use ENTRYPOINT for the primary command and the standard 8501 port.
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



