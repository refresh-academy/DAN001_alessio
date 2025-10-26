
-- Preferenze alimentari in SQL prove varie varie
-- Assignment week 05

-- Riprendiamo l’assignment sulle preferenze alimentari e svolgiamo una serie di task in SQL.

-- Prerequisiti
---Aver creato la tabella con le preferenze alimentari su DBeaver. (ddl_e_dati)

-- Task
--	1. Creare una nuova tabella chiamata “tabella_scarti” e inserirgli tutte le righe che:
-- 	◦ Hanno ID NULL
--	◦ Hanno ID Duplicati: conservare solo il MAX ROWID
--	◦ Hanno Eta: NULL o >120, <10
--	◦ Hanno Citta: NULL

–- creo nuova tabella

CREATE TABLE tabella_scarti AS 
SELECT * 
	FROM preferenze_alimentari_italia 
WHERE 1=0;
-- WHERE scritto cosi’ consente di prndere tutte le colonne e copiarle

CREATE TABLE tabella_scarti AS
SELECT * FROM preferenze_alimentari_italia
WHERE 1=0;

--trovo i dati da scartare nella tabella scarti con ROWID 
SELECT ROWID, * FROM preferenze_alimentari_italia LIMIT 5;
-- verifico che esista ROWID

SELECT *
FROM preferenze_alimentari_italia
WHERE id IN (
  SELECT id
  FROM preferenze_alimentari_italia
  GROUP BY id
  HAVING COUNT(*) > 1
  -- questo trova gli ID con con piu' un count. almeno spero :)
)
AND ROWID NOT IN (
	-- ho visto che IN ha altre funzioni e qui gli dico di cercare tutti gli ID che NON SONO il massimo
  SELECT MAX(ROWID)
  FROM preferenze_alimentari_italia
  GROUP BY id
  HAVING COUNT(*) > 1
);


-- ora inserisco i dati
INSERT INTO tabella_scarti
SELECT *
	FROM preferenze_alimentari_italia
	WHERE id IS NULL OR (id IN (
				SELECT id FROM preferenze_alimentari_italia
				GROUP BY id
				HAVING COUNT(*) > 1
				) -- stavo impazzendo con le parentesi ed ho scperto adesso che ti fa vedere la parentesi prima se ci clicchi sopra
	AND ROWID NOT IN ( SELECT
	MAX(ROWID)
FROM preferenze_alimentari_italia
GROUP BY id
HAVING COUNT(*) > 1 ))
OR eta IS NULL OR eta > 120 OR eta < 10 
OR citta_residenza IS NULL OR citta_residenza = '';

-- 2. Contare il numero di righe della tabella “preferenze_alimentari” e della tabella degli scarti “tabella_scarti”

SELECT 'preferenze_alimenatari_italia' AS tabella, --qui creo il dato preferenza dentro una tabella temporanea
	COUNT(*) AS conteggio_totale
FROM preferenze_alimentari_italia
UNION ALL --ho deciso di usare UNION ALL perhce' avevo capito si dovessero unire due select e count perche' lo conoscevo
SELECT
   'tabella_scarti' AS tabella, -- qui inserisco direttamente la seconda riga nella colonna
   COUNT(*)
FROM tabella_scarti;


-- 3. Cancellare le righe del punto 1 dalla tabella “preferenze_alimentari” del dataset delle preferenze alimentari
-- Qui ho avuto molta difficolta’ ed ho cercato online non sapendo che ROWID esiste ed e’un valore che biosnga bloccare per creare la tabella nuova e quindi ho rifattp
--siccome qui non ho capito ninete mi sono rguardato tutti i dati ma non ho capito se mantiene il numero delle rowid

SELECT ROWID, * from preferenze_alimentari_italia pai
WHERE ID=35
OR
ID=63
OR
id=79
or
ID=79
OR
id=106
OR
ID=209
OR
ID=244
OR
ID=266
OR
ID=300
OR ID IS NULL

--siccome qui non ne uscivo ho deciso di cercare online ed ho scoperto che si puo mantenere il raw id quindi droppo la tabella e rifaccio

DROP TABLE IF EXISTS tabella_scarti;

CREATE TABLE tabella_scarti AS
SELECT ROWID AS rowid_originale, *
FROM preferenze_alimentari_italia
WHERE
--uno
id IS NULL
-- due
OR eta IS NULL OR eta > 120 OR eta < 10
--tre
OR citta_residenza IS NULL OR citta_residenza = ''
--quattro
OR (id IN (
	SELECT
	id FROM preferenze_alimentari_italia
	GROUP BY
	id HAVING COUNT(*) > 1
	) -- qui gli dico di cercare id che hanno conto superiore a 1
	AND ROWID NOT IN (
	SELECT MAX(ROWID) FROM preferenze_alimentari_italia
	GROUP BY id HAVING COUNT(*) > 1
));

--riprovo a vedere rowid
SELECT rowID, rowid_originale, *
FROM tabella_scarti ts


--ora posso cancellare tranquillo spero
--
DELETE FROM preferenze_alimentari_italia
WHERE ROWID IN (SELECT rowid_originale FROM tabella_scarti);


--    4. Verificare che il numero totale di righe dalla tabella “preferenze_alimentari” dopo il punto 3 sia uguale alla differenza tra il conteggio ottenuto al punto 2 e il conteggio delle righe della tabella degli scarti

--Verificare che il numero totale di righe dalla tabella “preferenze_alimentari” dopo il punto 3 sia uguale alla differenza tra il conteggio ottenuto al punto 2 e il conteggio delle righe della tabella degli scarti

SELECT
CASE WHEN
	(SELECT COUNT(*) FROM preferenze_alimentari_italia) +
	(SELECT COUNT(*) FROM tabella_scarti) = 307
	THEN 'OK'
	ELSE 'ERRORE'
	END AS verifica_307;

-- ma come si mette bene sta cosa in modo che la rileggo easy mi chiedo


--    5. Creare le seguenti anagrafiche esterne (ricorda che una tabella di anagrafica contiene i valori distinti della colonna selezionata e per ogni valore viene associato un id univoco):
--        ◦ Genere
--        ◦ Regione
--        ◦ Titolo studio
--        ◦ Città collegata a regione:
--            ▪ Per creare questa anagrafica dovete raggruppare il dataset originale “preferenze_alimentari” per città e regione e considerare per ogni città la sola regione che compare più volte (MAX). Non capisco perche’ si fa questa cosa ma ho eseguito creando delle tabelle con degli id univoci usando distinct


SELECT DISTINCT genere FROM preferenze_alimentari_italia pai;
CREATE TABLE anagrafica_genere (id_genere INTEGER PRIMARY KEY AUTOINCREMENT, genere TEXT UNIQUE);

--popolo la tabella
INSERT INTO anagrafica_genere (genere)
SELECT DISTINCT genere
FROM preferenze_alimentari_italia
WHERE genere IS NOT NULL;

SELECT distinct regione_residenza FROM preferenze_alimentari_italia pai;
CREATE TABLE anagrafica_regione_residenza (id_residenza INTEGER PRIMARY KEY AUTOINCREMENT, regione_residenza TEXT UNIQUE) 
-- ho avuto un idea qui... ma sto creando il dominio? non so perche' dovrei farlo


INSERT INTO anagrafica_regione_residenza (regione_residenza)
SELECT DISTINCT regione_residenza
FROM preferenze_alimentari_italia;


SELECT distinct titolo_studio FROM preferenze_alimentari_italia pai;
CREATE TABLE anagrafica_titolo_studio (id_titolo_studio INTEGER PRIMARY KEY AUTOINCREMENT, titolo_studio TEXT UNIQUE);
INSERT INTO anagrafica_titolo_studio (titolo_studio)
SELECT DISTINCT titolo_studio
FROM preferenze_alimentari_italia;



--        ◦ Città collegata a regione:
--            ▪ Per creare questa anagrafica dovete raggruppare il dataset originale “preferenze_alimentari” per città e regione e considerare per ogni città la sola regione che compare più volte (MAX)

CREATE TABLE anagrafica_citta (
   id_citta INTEGER PRIMARY KEY AUTOINCREMENT,
   citta TEXT UNIQUE,
   regione ); --qui ripeto tutto quello che ho fatto sopra

INSERT INTO anagrafica_citta (citta, regione)
SELECT
   citta_residenza,
   regione_residenza
FROM (
   SELECT
       citta_residenza,
       regione_residenza,
       COUNT(*) AS conteggio
   FROM preferenze_alimentari_italia
   GROUP BY citta_residenza, regione_residenza --qui prendo solo la prima riga visto che e' ordinato in maniera desc	
   ORDER BY citta_residenza, conteggio DESC
)
GROUP BY citta_residenza;


--    6. Creare anagrafica classe età. 
Per farlo create una nuova colonna classe di età nella tabella “preferenze_alimentari” con i seguenti valori e criteri:

--Valore
--Criterio
--“<=20”
--Età minore uguale di 20
--“21-30”
--Età compresa tra 21 e 30 anni
--“31-40”
--Età compresa tra 31 e 40 anni
--“41-50”
--Età compresa tra 41 e 50 anni
--…(continuate la sequenza)
--…
-->80
--Età maggiore di 80

--Dopo aver creato l’anagrafica arricchirla aggiungendo le seguenti colonne 
--        ◦ Età Inizio
--        ◦ Età Fine
--        ◦ Descrizione fascia

SELECT ID, eta,
CASE
	 WHEN eta < 20 THEN '<20'
       WHEN eta >= 20 AND eta < 30 THEN '20-29'
       WHEN eta >= 30 AND eta < 40 THEN '30-39'
       WHEN eta >= 40 AND eta < 50 THEN '40-49'
       WHEN eta >= 50 AND eta < 60 THEN '50-59'
       WHEN eta >= 60 AND eta < 70 THEN '60-69'
       WHEN eta >= 70 AND eta < 80 THEN '70-79'
       WHEN eta >= 80 THEN '80+'
END AS classe_eta
from preferenze_alimentari_italia pai
WHERE
eta <=100;


--inserisco tabella
ALTER TABLE preferenze_alimentari_italia ADD classe_eta TEXT;


--ci metto le fasce usando SET invece di insert
UPDATE preferenze_alimentari_italia
SET classe_eta = CASE
   WHEN eta < 20 THEN '<20'
   WHEN eta BETWEEN 20 AND 29 THEN '20-29'
   WHEN eta BETWEEN 30 AND 39 THEN '30-39'
   WHEN eta BETWEEN 40 AND 49 THEN '40-49'
   WHEN eta BETWEEN 50 AND 59 THEN '50-59'
   WHEN eta BETWEEN 60 AND 69 THEN '60-69'
   WHEN eta BETWEEN 70 AND 79 THEN '70-79'
   WHEN eta >= 80 THEN '80+'
   ELSE NULL
END
WHERE eta <= 100;



CREATE TABLE anagrafica_fasce_eta (id_fasce_eta INTEGER PRIMARY KEY AUTOINCREMENT, titolo_studio TEXT UNIQUE)
INSERT INTO anagrafica_titolo_studio (titolo_studio)

SELECT DISTINCT titolo_studio
FROM preferenze_alimentari_italia;

INSERT INTO preferenze_alimentari_italia (classe_eta)
 SELECT ID, eta,
	CASE
	WHEN eta < 20 THEN '<20'
	WHEN eta >= 20 AND eta < 30 THEN '20-29'
	WHEN eta >= 30 AND eta < 40 THEN '30-39'
	WHEN eta >= 40 AND eta < 50 THEN '40-49'
 	WHEN eta >= 50 AND eta < 60 THEN '50-59'
  	WHEN eta >= 60 AND eta < 70 THEN '60-69'
	WHEN eta >= 70 AND eta < 80 THEN '70-79'
 	WHEN eta >= 80 THEN '>80'
  	WHEN eta IS NULL THEN
END AS classe_eta
--poi creo anagrafica come ho fatto sopra


SELECT distinct classe_eta FROM preferenze_alimentari_italia pai WHERE eta is not null;
CREATE TABLE anagrafica_classe_eta (id_classe_eta INTEGER PRIMARY KEY AUTOINCREMENT, classe_eta TEXT UNIQUE);
INSERT INTO anagrafica_classe_eta (classe_eta)
SELECT DISTINCT classe_eta
FROM preferenze_alimentari_italia;
-- qui ho notato che mi ha preso un NULL e droppato la tabella e che non ci sono persone con piu' di 80 anni cosi'ho aggiunto a mano il dato. quindi qui ho sbagliato qualcosa quando sopra ho selezionato le eta nulle? Ho visto che rifacendo tutto per assignment con screenshot non mi prende piu’ null. Ma come si fa se una persona viene inserita ed ha 80 anni? Si fa di nuovo tutto? Quindi devo settare l’ultima riga come >80?

UPDATE anagrafica_classe_eta
SET classe_eta = '>80'
WHERE classe_eta IS NULL;
--considero di togliere anche i null nelle pref principali?


--Dopo aver creato l’anagrafica arricchirla aggiungendo le seguenti colonne
--Età Inizio
--Età Fine
--Descrizione fascia

ALTER TABLE anagrafica_classe_eta
ADD eta_inizio integer;
ALTER TABLE anagrafica_classe_eta
ADD eta_fine integer;
ALTER TABLE anagrafica_classe_eta
ADD descrizione varchar;
INSERT INTO anagrafica_classe_eta (eta_inizio, eta_fine, descrizione)
SELECT
   CASE
       WHEN classe_eta = '<20' THEN 0
       WHEN classe_eta LIKE '20-%' THEN 20
       WHEN classe_eta LIKE '30-%' THEN 30
       WHEN classe_eta LIKE '40-%' THEN 40
       WHEN classe_eta LIKE '50-%' THEN 50
       WHEN classe_eta LIKE '60-%' THEN 60
       WHEN classe_eta LIKE '70-%' THEN 70
       WHEN classe_eta = '>80' THEN 80
   END AS eta_inizio,
  
   CASE
       WHEN classe_eta = '<20' THEN 19
       WHEN classe_eta LIKE '20-%' THEN 29
       WHEN classe_eta LIKE '30-%' THEN 39
       WHEN classe_eta LIKE '40-%' THEN 49
       WHEN classe_eta LIKE '50-%' THEN 59
       WHEN classe_eta LIKE '60-%' THEN 69
       WHEN classe_eta LIKE '70-%' THEN 79
       WHEN classe_eta = '>80' THEN 999
   END AS eta_fine,
  
   CASE
       WHEN classe_eta = '<20' THEN 'minorie di 20 anni'
       WHEN classe_eta LIKE '20-%' THEN 'ventenne'
       WHEN classe_eta LIKE '30-%' THEN 'trentenne'
       WHEN classe_eta LIKE '40-%' THEN 'quarantenne'
       WHEN classe_eta LIKE '50-%' THEN 'cinquantenne'
       WHEN classe_eta LIKE '60-%' THEN 'sessantenne'
       WHEN classe_eta LIKE '70-%' THEN 'settantenne'
       WHEN classe_eta = '>80' THEN 'Over 80'
   END AS descrizione
FROM (
   SELECT DISTINCT classe_eta
   FROM preferenze_alimentari_italia
   WHERE classe_eta IS NOT NULL);


    7. (task opzionale):
        ◦ Creare un anagrafica con le tipologie di cucine
        ◦ Per ogni persona creare una riga che abbia come colonne ID, Tipo Cucina e valutazione. 
Per ogni persona ci devono essere N righe dove N è il numero di cucine su cui hanno espresso la preferenza. Ad esempio per ID 1 l’output dovrebbe essere così:
        ◦ 
ID
Tipo Cucina
Valutazione
1
Italiana
1
1
Cinese
4
1
Giapponese
1
1
Indiana

1
…
…

        ◦ Sulla tabella ottenuta al punto precedente aggiungere una nuova colonna per indicare il cibo preferito (una soluzione potrebbe prevedere comandi che non abbiamo ancora visto in classe)
ID
Tipo Cucina
Valutazione
Cibo Preferito
1
Italiana
1
Africana
1
Cinese
4
Africana
1
Giapponese
1
Africana
1
Indiana

Africana
1
…
…
Africana

        ◦ Cosa succede per le persone che hanno un punteggio massimo su più di una cucina?
Vincolo
    • E’ necessario tracciare le query utilizzate e l’output ottenuto in un google doc da salvare nelle propria cartelle personale

Data di consegna (per gli amici DEADLINE)
14/07/2025 entro le 13:00 UTC+1

