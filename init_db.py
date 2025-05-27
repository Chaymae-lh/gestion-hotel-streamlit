import sqlite3

# Connexion ou création de la base SQLite
conn = sqlite3.connect("hotel.db")
cursor = conn.cursor()

# Lire et exécuter le fichier de création des tables
with open("creation_tables.sql", "r", encoding="utf-8") as f:
    creation_script = f.read()
    cursor.executescript(creation_script)

# Lire et exécuter le fichier d'initialisation des données
with open("initialisation_tables.sql", "r", encoding="utf-8") as f:
    insertion_script = f.read()
    cursor.executescript(insertion_script)

# Valider les changements et fermer
conn.commit()
conn.close()

print("✅ Base de données SQLite 'hotel.db' créée avec succès.")
