
FROM python:3.10-slim-bookworm
# Expose the standard Streamlit port.
EXPOSE 8501

# Set the working directory first.
WORKDIR /app

# Copy the core file needed for dependency installation first.
# FIX: Simplified copy destination to '.' (which means /app) to prevent path errors.
COPY requirements.txt .

# Install required system packages in a single 'RUN' command and clean up immediately
# to save space. We use --no-install-recommends to keep the image minimal.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
