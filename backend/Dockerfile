FROM python:3.11-slim

# Install ping
RUN apt-get update && apt-get install -y iputils-ping && apt-get clean

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose Flask port
EXPOSE 5000

# Set environment (Flask runs on 0.0.0.0 inside Docker)
ENV FLASK_RUN_HOST=0.0.0.0

CMD ["python", "app.py"]
