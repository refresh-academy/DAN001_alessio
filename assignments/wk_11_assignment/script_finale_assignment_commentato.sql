
-- scrivo da lavoro. non sono riuscito a commentare e forse alcuni pezzi mancano delle puntine virgola da chiudere percio' si rompe ma lensingole creazioni dovrebbero essere giuste

CREATE SCHEMA IF NOT EXISTS openbo_landing;
CREATE SCHEMA IF NOT EXISTS openbo_integration;
CREATE SCHEMA IF NOT EXISTS openbo_dwh;


SET search_path TO openbo_landing

-- ho perso tutto perche' ho importanto uno script invece di aprirlo
-- mareddu da investigare ndA era un problema in importazione che non ho avuto tempo di investigare, si tratta di un valore in una casella che mi ha dato problemi ma solo in import

--fare union non join perche' l'ha detto Andrea e non ho capito perche'


/* SELECT SELECT id, n_pg_atto, anno_pg_atto, oggetto, classificazione_incarichi, descrizione_classificazione_incarichi, norma_o_titolo_a_base_dell_attribuzione, importo_euro, settore_dipartimento_area, servizio, uo, dirigente, responsabile, ragione_sociale, partita_iva, codice_fiscale, durata_dal, durata_al, curriculum_link
FROM openbo_landing.incarichi_di_collaborazione;
union ALL
SELECT id, n_pg_atto, anno_pg_atto, classificazione_incarico, descrizione_incarico, data_inizio_incarico, data_fine_incarico, durata_incarico_gg, compenso_previsto_euro, struttura_conferente, responsabile_della_struttura_conferente
FROM openbo_landing.incarichi_conferiti;  */

-- cerco di fare una union con la maggior quantita' di colonne in comune e farci la DIM_FATTO

drop table if exists DIM_ATTO;

create table DIM_ATTO as

SELECT
    ROW_NUMBER() OVER (ORDER BY id) as ids_atto,
    n_pg_atto as numero_pg_atto,
    anno_pg_atto as anno_og_atto,
    NULL as oggetto,
    NULL as norma_titolo_base,
    'incarichi_conferiti' AS source_system
FROM openbo_landing.incarichi_conferiti;

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY id) as ids_atto,
    n_pg_atto as numero_pg_atto,
    anno_pg_atto as anno_og_atto,
    oggetto  as oggetto,
    norma_o_titolo_a_base_dell_attribuzione  as norma_titolo_base,
    'incarichi_di_collaborazione' AS source_system
FROM openbo_landing.incarichi_di_collaborazione;

-- devo controllare che non ci siano problemi con gli incarichi poeri una volta fatta. creerei una tabella temporanea da cui prendere i dati ma ora posso fare la union all


drop table if exists DIM_FATTO

create table DIM_FATTO as (
SELECT
    ROW_NUMBER() OVER (ORDER BY id) AS ids_atto,
    n_pg_atto AS numero_pg_atto,
    anno_pg_atto AS anno_pg_atto,
    'n/a' AS oggetto,
    'n/a' AS norma_titolo_base,
    'incarichi_conferiti' AS source_system
FROM openbo_landing.incarichi_conferiti
-- qui non vao messo n/a mi sono sbagliato, come da assignment
UNION ALL

SELECT
    -- ho messo un numero 1000 aggiungendono al row number cosi' non si sovrappone con la select precedente. in teoria non dovrebbe essere necessario ma ora faccio delle prove sia con che senza
    (ROW_NUMBER() OVER (ORDER BY id) + 1000) AS ids_atto,
	-- un altro modo per farlo e' fare in modo che queste due select siano dentro una subquery e fare il row number fuori
    -- cosi' non si sovrappongono mai
    n_pg_atto AS numero_pg_atto,
    -- qui andavano esclusi i null e si duplica se usi n_pg_atto
    -- fare partition by numero_pg_atto per evitare duplicati (dalla colonnao originale)
    anno_pg_atto AS anno_pg_atto,
    oggetto,
    norma_o_titolo_a_base_dell_attribuzione AS norma_titolo_base,
    'incarichi_di_collaborazione' AS source_system
FROM openbo_landing.incarichi_di_collaborazione
);


-- ora controllo quante sono le colonne

select count(*) as totale_colonna from openbo_landing.incarichi_conferiti; --813
select count(*) as totale_colonna from openbo_landing.incarichi_di_collaborazione; --715
select count(*) as totale_colonna from openbo_landing.dim_atto; --1528

-- questo e' sbagliato perche' questa e' una anagrafica e non un fatto 
-- le dimensioni sono anagrafiche

-- volendo posso farlo tutto in una tabellina 

SELECT
    'incarichi_conferiti' AS table_name,
    COUNT(*) AS row_count
FROM openbo_landing.incarichi_conferiti

UNION ALL

SELECT
    'incarichi_di_collaborazione' AS table_name,
    COUNT(*) AS row_count
FROM openbo_landing.incarichi_di_collaborazione

UNION ALL

SELECT
    'dim_fatto' AS table_name,
    COUNT(*) AS row_count
FROM openbo_landing.dim_fatto;

-- potrei aggugnere un calcolo e vedere se e' giusto tipo una validazione cmq ho fatto a mano e si vede che si'
-- per ora ci ho messo un'ora solo ad importare i dati e circa 2 ore per creare questa tabella. non mi sento molto efficiente :)
-- ora provo a vedere se tutto e' ok

select count(*) from openbo_landing.dim_fatto df
where df.source_system='incarichi_di_collaborazione';

-- anche qui la count mi risulta giusta e vorrei ci foss eun modo piu' semplice per fare tutti questi controlli assieme

-- ora potrei vedere quali valori sono null ed inserire un coalesce? proviamo

select * from openbo_landing.dim_fatto df
where df.oggetto is NULL;



SET search_path TO openbo_integration;

DROP TABLE IF EXISTS dim_classificazione_incarico;

CREATE TABLE dim_classificazione_incarico AS
select
    ROW_NUMBER() OVER (ORDER BY classificazione_incarichi) AS ids_classificazione_incarico,
    --qui creo la PK
    classificazione_incarichi AS id_classificazione_incarico,
    descrizione_classificazione_incarichi,
    'incarichi_di_collaborazione' AS source_system 
FROM 
    openbo_landing.incarichi_di_collaborazione
GROUP BY 
classificazione_incarichi, descrizione_classificazione_incarichi;
--questa group by dovrebbe servire a selezionare le cose in modo che non ci siano duplicazioni anche se non capisco bene come funziona

-- provo ad inserire il record fittizio ma qui potrei fare tutto con una nunion senza insert

INSERT INTO dim_classificazione_incarico (ids_classificazione_incarico, id_classificazione_incarico, descrizione_classificazione_incarichi, source_system)
VALUES (
    -- 1. Chiave Surrogata: -1
    -1,
    'NA', 
    'Classificazione Fittizia/Mancante',
    --descrizione per chiarire che e' un dato finto
    -- source_system: 'ETL' come da requisito)
    'ETL' 
);

--ho voluto fare tutto a pezzi perche' non ho capito molto bene

ALTER TABLE dim_classificazione_incarico ADD PRIMARY KEY (ids_classificazione_incarico);
-- qui non server mettere la primary key ma siccome qui non inseriamo mai righe non mi interessa farlo
-- qui mi e' venuto il dubbio che facendo cosi' credo il -1 come chiave primaria e non so se va bene
-- forse sarebbe meglio fare un update e mettere -1 a tutti i record che hanno id_classificazione_incarico null

--ora provo a creare la DIM_STRUTTURA
DROP TABLE IF EXISTS dim_struttura;

CREATE TABLE dim_struttura AS 
SELECT DISTINCT ON (nome_struttura)
    ROW_NUMBER() OVER (ORDER BY nome_struttura) AS ids_struttura, 
    nome_struttura, 
    source_system 
FROM (
    SELECT 
        INITCAP("settore_dipartimento_area") AS nome_struttura, 
        'incarichi_di_collaborazione' AS source_system
    FROM openbo_landing.incarichi_di_collaborazione
    WHERE "settore_dipartimento_area" IS NOT NULL

    UNION ALL 
    
    SELECT 
        INITCAP(struttura_conferente) AS nome_struttura,
        'incarichi_conferiti' AS source_system
    FROM openbo_landing.incarichi_conferiti
    WHERE struttura_conferente IS NOT NULL
 
) AS strutture_unificate 
    
ORDER BY 
    nome_struttura, 
    source_system DESC;

--l'ultimo pezzo, creo la dimensione DIM_SOGGETTO_INCARICATO
DROP TABLE IF EXISTS dim_soggetto_incaricato;
CREATE TABLE dim_soggetto_incaricato AS
	select
	ROW_NUMBER() OVER (ORDER BY ragione_sociale, codice_fiscale) AS ids_soggetto_incaricato,
	--creo chiave surrogata ordinando 
	ragione_sociale,
   -- qui uso COALESCE per sostituire NULL con 'N/A' come da richiesta
    COALESCE(partita_iva, 'N/A') AS partita_iva, 
    COALESCE(codice_fiscale, 'N/A') AS codice_fiscale,
    'incarichi_di_collaborazione' AS source_system 
    FROM 
    openbo_landing.incarichi_di_collaborazione
WHERE
    ragione_sociale IS NOT NULL -- per sicurezza escludo i record senza niente
GROUP BY 
    ragione_sociale, partita_iva, codice_fiscale; -- rimuovo i duplicati sulla chiave naturale, passo necessario sempre da fare quando creo una anagrafica

-- l'ultimo pezzo e' ok e andava fatto tutto cosi' praticamente
-- ok fine :) ciaooo

