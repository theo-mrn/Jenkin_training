# Utilise une image Python officielle légère
FROM python:3.9-slim

# Définit le dossier de travail dans le conteneur
WORKDIR /app

# Copie le fichier des dépendances
COPY requirements.txt .

# Installe les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copie le reste de l'application
COPY . .

# Expose le port 5000 pour Flask
EXPOSE 5000

# Commande de démarrage
CMD ["python", "app.py"]
