# Use official Python image
FROM python:3.9-slim

WORKDIR /app

# Copy files
COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Run app
CMD ["python", "app.py"]
