select * from incarichi_conferiti limit 10;

SELECT n_pg_atto, COUNT(*) as count
FROM incarichi_conferiti
GROUP BY n_pg_atto
HAVING COUNT(*) > 1
order by count DESC;

SELECT id, n_pg_atto, anno_pg_atto, classificazione_incarico, descrizione_incarico, data_inizio_incarico, data_fine_incarico, durata_incarico_gg, compenso_previsto_euro, struttura_conferente, responsabile_della_struttura_conferente
FROM bologna.incarichi_conferiti;

select conf.responsabile_della_struttura_conferente, count(*) as totale,
SUM(COUNT(8)) OVER() AS somma
FROM bologna.incarichi_conferiti as conf
where conf.n_pg_atto = ''
group by conf.responsabile_della_struttura_conferente 
order by totale DESC;

SELECT conf.responsabile_della_struttura_conferente, conf.struttura_conferente, COUNT(conf.responsabile_della_struttura_conferente) as totale
FROM bologna.incarichi_conferiti as conf
GROUP BY conf.responsabile_della_struttura_conferente, conf.struttura_conferente 
ORDER BY totale DESC;

SELECT SUM(NULLIF(compenso_previsto_euro, '')::numeric) as totale_compenso
FROM bologna.incarichi_conferiti;

SELECT * FROM incarichi_di_collaborazione LIMIT 10;


grou



select count(n_pg_atto ) from bologna.incarichi_conferiti;


select count(*) from incarichi_di_collaborazione;

alter table incarichi_di_collaborazione 
ALTER COLUMN id TYPE integer USING id::integer;

alter table incarichi_conferiti
ALTER COLUMN data_inizio_incarico TYPE date USING data_inizio_incarico::date;



