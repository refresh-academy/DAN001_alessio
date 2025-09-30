SELECT DISTINCT citta_residenza FROM dataset;

DROP TABLE IF EXISTS citta ;

CREATE TABLE citta AS 
	SELECT ROW_NUMBER() OVER() as id, a.citta_residenza as citta FROM
	(
	SELECT DISTINCT citta_residenza 
	FROM 			dataset
	) a;

SELECT * FROM citta;

SELECT * FROM dataset

CREATE TABLE dataset_citta AS
	SELECT 
	ds.id, nome, cognome, data_nascita, eta, anno_nascita, nazione_provenienza, citta_provenienza, c.id as citta_residenza,
	lingue_parlate, titolo_studio, professione, hobbies, attivita_non_piacciono, anni_ingresso_italia, stato_civile, anno_matrimonio, anni_in_italia, numero_fratelli_sorelle, numero_cugini, eta_imparato_nuotare, numero_figli, numero_animali_domestici, indirizzo_scuola_superiore, luogo_scuola_superiore, nazione_scuola_superiore, nomi_animali_domestici, film_preferito
	FROM dataset ds
	JOIN citta c
		ON ds.citta_residenza = c.citta;
		
	
SELECT c.citta ,dc.* 
FROM dataset_citta dc 
	JOIN citta c 
		ON c.id =dc.citta_residenza
	