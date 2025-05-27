import streamlit as st
import sqlite3
import base64
from datetime import date
import pandas as pd

# Connexion à la base de données
conn = sqlite3.connect("hotel.db", check_same_thread=False)
cursor = conn.cursor()

# Image en fond
def get_base64_image(image_path):
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode()

img_base64 = get_base64_image("image.png")

# CSS : fond + style
st.markdown(f"""
    <style>
        .stApp {{
            background-image: url("data:image/png;base64,{img_base64}");
            background-size: cover;
            background-attachment: fixed;
            backdrop-filter: blur(3px);
        }}
        h1 {{
            color: #CC5500;
            text-align: center;
        }}
        .custom-table {{
            background: rgba(255, 255, 255, 0.85);
            padding: 1rem;
            border-radius: 10px;
            color: black;
            font-weight: bold;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        th, td {{
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }}
        th {{
            background-color: #E77D22;
            color: white;
        }}
                button[kind="secondary"] {{
        background-color: #FF8800 !important;
        color: white !important;
        border-radius: 8px;
        font-weight: bold;
        border: none;
    }}
    button[kind="secondary"]:hover {{
        background-color: #e67300 !important;
    }}


    </style>
""", unsafe_allow_html=True)

# Titre principal
st.markdown("<h1>Gestion Hôtelière 🏨</h1>", unsafe_allow_html=True)

# === MENU CENTRÉ AVEC BOUTONS PERSISTANTS ===
if "menu" not in st.session_state:
    st.session_state.menu = "Accueil"

st.markdown("<h2 style='text-align:center;'>Menu Principal</h2>", unsafe_allow_html=True)

col1, col2, col3 = st.columns(3)
with col1:
    if st.button("📅 Réservations"):
        st.session_state.menu = "📅 Réservations"
    if st.button("🛏 Chambres Dispo"):
        st.session_state.menu = "🛏 Chambres Dispo"
with col2:
    if st.button("🧑 Clients"):
        st.session_state.menu = "🧑 Clients"
    if st.button("➕ Ajouter Client"):
        st.session_state.menu = "➕ Ajouter Client"
with col3:
    if st.button("📝 Ajouter Réservation"):
        st.session_state.menu = "📝 Ajouter Réservation"

menu = st.session_state.menu

# === AFFICHAGES SELON CHOIX ===
if menu == "Accueil":
    st.markdown("<h3 style='text-align: center;'>Bienvenue dans l'application de gestion hôtelière 🌟</h3>", unsafe_allow_html=True)

elif menu == "📅 Réservations":
    st.subheader("📅 Liste des réservations")
    cursor.execute("SELECT * FROM reservation")
    data = cursor.fetchall()
    colonnes = [desc[0] for desc in cursor.description]
    df = pd.DataFrame(data, columns=colonnes).iloc[:, 1:]
    st.markdown(df.to_html(classes='custom-table', index=False), unsafe_allow_html=True)

elif menu == "🧑 Clients":
    st.subheader("🧑 Liste des clients")
    cursor.execute("SELECT * FROM clien")
    data = cursor.fetchall()
    colonnes = [desc[0] for desc in cursor.description]
    df = pd.DataFrame(data, columns=colonnes).iloc[:, 1:]
    st.markdown(df.to_html(classes='custom-table', index=False), unsafe_allow_html=True)

elif menu == "🛏 Chambres Dispo":
    st.subheader("🛏 Recherche de chambres disponibles")
    date_arrivee = st.date_input("Date d'arrivée", date.today())
    date_depart = st.date_input("Date de départ", date.today())
    if st.button("🔍 Rechercher"):
        cursor.execute("""
            SELECT * FROM chambre
            WHERE id_chambre NOT IN (
                SELECT c.id_chambre
                FROM chambre c
                JOIN concerner con ON c.id_type = con.id_type
                JOIN reservation r ON con.id_reservation = r.id_reservation
                WHERE r.date_arrivée <= ? AND r.date_depart >= ?
            )
        """, (date_depart, date_arrivee))
        dispo = cursor.fetchall()
        colonnes = [desc[0] for desc in cursor.description]
        if dispo:
            st.success(f"{len(dispo)} chambre(s) disponible(s).")
            df = pd.DataFrame(dispo, columns=colonnes)
            st.markdown(df.to_html(classes='custom-table', index=False), unsafe_allow_html=True)
        else:
            st.warning("Aucune chambre disponible.")

elif menu == "➕ Ajouter Client":
    st.subheader("➕ Ajouter un nouveau client")
    with st.form("form_client"):
        nom = st.text_input("Nom complet")
        adresse = st.text_input("Adresse")
        ville = st.text_input("Ville")
        code_postal = st.text_input("Code postal")
        email = st.text_input("Email")
        tel = st.text_input("Téléphone")
        submitted = st.form_submit_button("✅ Ajouter le client")
        if submitted:
            cursor.execute(
                "INSERT INTO clien (adresse, ville_C, code_postal_C, email, num_tel, NomComplet) VALUES (?, ?, ?, ?, ?, ?)",
                (adresse, ville, code_postal, email, tel, nom)
            )
            conn.commit()
            st.success("Client ajouté avec succès.")

elif menu == "📝 Ajouter Réservation":
    st.subheader("📝 Ajouter une réservation")
    cursor.execute("SELECT id_client, NomComplet FROM clien")
    clients = cursor.fetchall()
    client_dict = {nom: idc for idc, nom in clients}
    with st.form("form_reservation"):
        client_nom = st.selectbox("Sélectionnez un client", list(client_dict.keys()))
        date_arrivee = st.date_input("Date d'arrivée")
        date_depart = st.date_input("Date de départ")
        submitted = st.form_submit_button("✅ Ajouter la réservation")
        if submitted:
            id_client = client_dict[client_nom]
            cursor.execute(
                "INSERT INTO reservation (date_arrivée, date_depart, id_client) VALUES (?, ?, ?)",
                (date_arrivee, date_depart, id_client)
            )
            conn.commit()
            st.success("Réservation ajoutée avec succès.")
