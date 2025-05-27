CREATE TABLE hotel (
id_hotel int ,
ville_H VARCHAR(20),
pays VARCHAR(20),
code_postal_H NUMERIC,
CONSTRAINT PK_hotel PRIMARY KEY (id_hotel)
);
CREATE TABLE  type_chambre (
id_type INT ,
nom_type varchar (20),
tarif NUMERIC ,
CONSTRAINT PK_type PRIMARY KEY (id_type)
);
CREATE TABLE chambre (
id_chambre int ,
num_chambre NUMERIC ,
 etage NUMERIC,
fumeurs BINARY,
id_hotel int ,
id_type int ,
CONSTRAINT PK_chambre PRIMARY KEY (id_chambre),
CONSTRAINT fk_hotel_chambre FOREIGN KEY (id_hotel)REFERENCES hotel(id_hotel),
CONSTRAINT fk_type_chambre FOREIGN KEY (id_type)REFERENCES type_chambre(id_type)
);
CREATE TABLE prestation(
id_prestation int ,
prix NUMERIC ,
nom_prestation varchar (30),
CONSTRAINT PK_prestation PRIMARY KEY (id_prestation)
);
CREATE TABLE offre(
id_hotel int ,
id_prestation int ,
CONSTRAINT PK_offre PRIMARY KEY (id_hotel,id_prestation),
CONSTRAINT fk_hotel_offre FOREIGN KEY (id_hotel)REFERENCES hotel(id_hotel),
CONSTRAINT fk_prestation_offre FOREIGN KEY (id_prestation)REFERENCES prestation(id_prestation)
);
CREATE TABLE clien(
id_client INT ,
adresse VARCHAR (30),
ville_C VARCHAR (10),
code_postal_C NUMERIC,
email VARCHAR (30),
num_tel NUMERIC ,
NomComplet VARCHAR (30),
CONSTRAINT PK_CLIENT PRIMARY KEY (id_client)
);
CREATE TABLE evaluation (
id_evaluation INT,
date_arrivée DATE  ,
note NUMERIC ,
texte VARCHAR (50) ,
id_hotel INT ,
id_client INT,
CONSTRAINT PK_eval PRIMARY KEY (id_evaluation),
CONSTRAINT fk_hotel_eval FOREIGN KEY (id_hotel)REFERENCES hotel(id_hotel),
CONSTRAINT fk_client_eval FOREIGN KEY (id_client)REFERENCES clien(id_client)
);

CREATE TABLE reservation (
id_reservation INT ,
date_arrivée DATE ,
date_depart DATE ,
id_client INT ,
CONSTRAINT PK_reservation PRIMARY KEY (id_reservation),
CONSTRAINT fk_reservation_client FOREIGN KEY (id_client)REFERENCES clien(id_client)
);
CREATE TABLE concerner(
id_reservation int ,
id_type INT ,
CONSTRAINT PK_offre PRIMARY KEY (id_reservation,id_type),
CONSTRAINT fk_res_conc FOREIGN KEY (id_reservation)REFERENCES reservation(id_reservation),
CONSTRAINT fk_type_chambre_conc FOREIGN KEY (id_type)REFERENCES type_chambre(id_type)
);
INSERT INTO hotel 
VALUES (1, 'Paris', 'France', 75001) ,
(2, 'Lyon', 'France', 69002);

INSERT INTO type_chambre
VALUES (1, 'Simple', 80) ,
(2, 'Double', 120) ;

INSERT INTO chambre
VALUES (1, 201, 2, 0, 1, 1) ,
(2, 502, 5, 1, 1, 2) ,
(3, 305, 3, 0, 2, 1) ,
(4, 410, 4, 0, 2, 2) ,
(5, 104, 1, 1, 2, 2) ,
(6, 202, 2, 0, 1, 1) ,
(7, 307, 3, 1, 1, 2) ,
(8, 101, 1, 0, 1, 1) ;

INSERT INTO prestation
VALUES (1, 15, 'Petit-déjeuner') ,
(2, 30, 'Navette aéroport') ,
(3, 0, 'Wi-Fi gratuit') ,
(4, 50, 'Spa et bien-être'), 
(5, 20, 'Parking sécurisé') ;

ALTER TABLE clien MODIFY emailclien varchar(30);
INSERT INTO clien
VALUES (1, '12 Rue de Paris', 'Paris', 75001, 'jean.dupont@email.fr', 
'0612345678', 'Jean Dupont') ,
(2, '5 Avenue Victor Hugo', 'Lyon', 69002, 'marie.leroy@email.fr', 
'0623456789', 'Marie Leroy') ,
(3, '8 Boulevard Saint-Michel', 'Marseille', 13005, 
'paul.moreau@email.fr', '0634567890', 'Paul Moreau') ,
(4, '27 Rue Nationale', 'Lille', 59800, 'lucie.martin@email.fr', 
'0645678901', 'Lucie Martin') ,
(5, '3 Rue des Fleurs', 'Nice', 06000, 'emma.giraud@email.fr', 
'0656789012', 'Emma Giraud') ;

INSERT INTO evaluation
VALUES (1, '2025-06-15', 5, 'Excellent séjour, personnel très accueillant.', 
1,1) ,
(2, '2025-07-01', 4, 'Chambre propre, bon rapport qualité/prix.',2, 2) ,
(3, '2025-08-10', 3, 'Séjour correct mais bruyant la nuit.', 1,3) ,
(4, '2025-09-05', 5, 'Service impeccable, je recommande.', 2,4) ,
(5, '2025-09-20', 4, 'Très bon petit-déjeuner, hôtel bien situé.',1 ,5);

INSERT INTO reservation
VALUES  #Client 1 (Jean Dupont) 
(1, '2025-06-15', '2025-06-18', 1) ,
# Client 2 (Marie Leroy) 
(2, '2025-07-01', '2025-07-05', 2) ,
(7, '2025-11-12', '2025-11-14', 2) ,
(10, '2026-02-01', '2026-02-05', 2) ,
# Client 3 (Paul Moreau) 
(3, '2025-08-10', '2025-08-14', 3) ,
# Client 4 (Lucie Martin) 
(4, '2025-09-05', '2025-09-07', 4) ,
(9, '2026-01-15', '2026-01-18', 4) ,
# Client 5 (Emma Giraud) 
(5, '2025-09-20', '2025-09-25', 5) ;

INSERT INTO offre 
VALUES 
(1, 1),
(1, 3),
(1, 5),
(2, 1),
(2, 4),
(2, 2);

INSERT INTO concerner
VALUES 
(1, 1), 
(3, 2), 
(2, 2), 
(5, 1), 
(9, 2);

SELECT DISTINCT r.id_reservation, c.NomComplet, h.ville_H
FROM reservation r
JOIN clien c ON r.id_client = c.id_client
JOIN concerner co ON r.id_reservation = co.id_reservation
JOIN type_chambre tc ON co.id_type = tc.id_type
JOIN chambre ch ON tc.id_type = ch.id_type
JOIN hotel h ON ch.id_hotel = h.id_hotel;

SELECT NomComplet ,ville_C
FROM clien
WHERE ville_C = 'Paris';

SELECT c.id_client, c.NomComplet, COUNT(r.id_reservation) AS nb_reservations
FROM clien c
LEFT JOIN reservation r ON c.id_client = r.id_client
GROUP BY c.id_client, c.NomComplet;

SELECT tc.id_type, tc.nom_type, COUNT(ch.id_chambre) AS nb_chambres
FROM type_chambre tc
LEFT JOIN chambre ch ON tc.id_type = ch.id_type
GROUP BY tc.id_type, tc.nom_type;

SELECT ch.*
FROM chambre ch
WHERE ch.id_chambre NOT IN (
    SELECT DISTINCT ch2.id_chambre
    FROM chambre ch2
    JOIN type_chambre tc ON ch2.id_type = tc.id_type
    JOIN concerner co ON tc.id_type = co.id_type
    JOIN reservation r ON co.id_reservation = r.id_reservation
    WHERE r.date_arrivée <=2024-07-10   #@date_fin
      AND r.date_depart >=  202-07-01  #@date_debut
);
















 



