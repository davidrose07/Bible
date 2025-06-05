FROM python:3.10.12-slim

# Set working directory
WORKDIR /Bible

# Install system dependencies needed to build PyHyphen
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    libtool \
    libglib2.0-0 \
    libglib2.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Try to install PyHyphen separately (and fail gracefully)
RUN pip install PyHyphen==4.0.3 || echo "Warning: PyHyphen installation failed, continuing..."

# Copy project files
COPY . .

# Set entry point
CMD ["python", "-m", "bible.main"]
