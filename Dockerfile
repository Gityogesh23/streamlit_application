# --- STAGE 1: Builder (The "Heavy" Stage) ---
FROM python:3.10-slim-bookworm AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install only what's needed to compile dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies to a specific folder
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- STAGE 2: Runtime (The "Tiny" Stage) ---
FROM python:3.10-slim-bookworm

# Standard Python pathing for the /install folder
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:/install/bin:${PATH}" \
    PYTHONPATH="/install/lib/python3.10/site-packages"

WORKDIR /app

# Create a non-privileged user
RUN useradd -m appuser && chown -R appuser /app

# COPY ONLY the installed packages from the builder (Stripping out build-essential/gcc)
COPY --from=builder --chown=appuser:appuser /install /install
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8501

# Best practice: use ["executable", "param"] syntax
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



