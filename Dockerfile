FROM python:3.10-slim-bookworm

# 1. Set environment variables (Standard for Python Docker)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

WORKDIR /app

# 2. Install system-level dependencies as ROOT
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 3. Create the user BEFORE installing Python packages
RUN useradd -m appuser

# 4. Copy requirements and install AS THE USER
# This avoids the permission error because the user owns their own home dir
COPY requirements.txt .
USER appuser
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --user -r requirements.txt

# 5. Copy the rest of the code with correct ownership
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



