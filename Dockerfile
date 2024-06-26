# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
# (Optional: if you have a requirements.txt, uncomment the next two lines)
# COPY requirements.txt /app/
 RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . /app

# Make port 80 available to the world outside this container
EXPOSE 80
EXPOSE 8501

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["streamlit","run", "app.py","--server.port","80"]