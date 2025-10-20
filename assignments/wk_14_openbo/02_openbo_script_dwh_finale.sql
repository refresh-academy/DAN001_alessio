-- drop schema if exists chinook_integration cascade  
-- questo lo commento xche' vorrei usarlo ma non ho avuto tempo

SET search_path TO openbo_dwh;


-- primo passo, creo una sorgente unica temporanea che poi non ho usato ma magari provo ad usarla dopo?

drop table if exists openbo_integration.tt_tempo_inizio;
create table openbo_integration.tt_tempo_inizio as
SELECT 
    NULLIF(openbo_landing.lt_incarichi_di_collaborazione.durata_dal, '')::DATE AS data_sorgente
FROM 
    openbo_landing.lt_incarichi_di_collaborazione
WHERE
    NULLIF(openbo_landing.lt_incarichi_di_collaborazione.durata_dal, '')::DATE IS NOT NULL 

UNION DISTINCT

SELECT 
   NULLIF(openbo_landing.lt_incarichi_conferiti.data_inizio_incarico, '')::DATE AS data_sorgente
FROM 
    openbo_landing.lt_incarichi_conferiti
WHERE
    nullif(openbo_landing.lt_incarichi_conferiti.data_inizio_incarico, '')::DATE is not null;

-- ok qui ho creato una tabella che non contiene null ma ha un problema perche' non mi casta integer correttamente. ci penso dopo

-- questa ho rifatto perche' ho usato adesso la tabella tt

drop table if exists openbo_dwh.dim_tempo_inizio ; 
create table openbo_dwh.dim_tempo_inizio as
select distinct
	-- ids giorno
    coalesce(
    	CAST(
        TO_CHAR(
        NULLIF(lt_incarichi_di_collaborazione.durata_dal, '')::DATE, 'YYYYMMDD'
        ) AS INTEGER),
        -1
    ) AS ids_giorno,
    
	-- giorno
	COALESCE(
		CAST(extract(day from nullif(lt_incarichi_di_collaborazione.durata_dal, '')::DATE) as INTEGER),
		-1
	) as giorno,
    
	-- mese
	coalesce(
		CAST(extract(month from nullif(lt_incarichi_di_collaborazione.durata_dal, '')::DATE) as INTEGER),
		-1
	)as mese,
    --anno
	coalesce(
		CAST(extract(year from nullif(lt_incarichi_di_collaborazione.durata_dal, '')::DATE) as INTEGER),
		-1
	)as anno,
	COALESCE(
        TRIM(INITCAP(TO_CHAR(
            NULLIF(lt_incarichi_di_collaborazione.durata_dal, '')::DATE, 
            'Month' -- restituisce il nome completo del mese 
            )
        )),
        'missing/mancante' -- per i nomi deve essere una stringa
  	) AS nome_mese,
  	COALESCE(TO_CHAR(
  	
            NULLIF(lt_incarichi_di_collaborazione.durata_dal, '')::DATE, 
            '"Q"Q' -- restituisce il quarter
            )
        ,
        'missing/mancante' -- per i nomi deve essere una stringa
  	) AS trimestre,
  		COALESCE(TO_CHAR(
  	
            NULLIF(lt_incarichi_di_collaborazione.durata_dal, '')::DATE, 
            'Day' -- restituisce il nome giorno
            )
        ,
        'missing/mancante' -- per i nomi deve essere una stringa
  	) AS giorno_settimana,
  	'ETL' as source_system
	
from openbo_landing.lt_incarichi_di_collaborazione;

-- qui ho fatto una prova per vedere maggio
/*SELECT
    nome_mese,
    COUNT(ids_giorno) AS numero_di_giorni_unici_presenti
FROM
    openbo_dwh.dim_tempo_inizio
GROUP BY
    nome_mese
ORDER BY
    numero_di_giorni_unici_presenti DESC;

select * from openbo_dwh.dim_tempo_inizio dti 
where nome_mese = 'May'
order by dti.ids_giorno */


-- ora provo a creare la dimensione fine 

drop table if exists openbo_integration.tt_tempo_fine;
create table openbo_integration.tt_tempo_fine as
select 
    nullif(lt_incarichi_di_collaborazione.durata_al, '')::date as data_sorgente_fine
from 
    openbo_landing.lt_incarichi_di_collaborazione
where
    nullif(lt_incarichi_di_collaborazione.durata_al, '')::date is not null 

-- correzione: usare solo union
union 

select 
   nullif(lt_incarichi_conferiti.data_fine_incarico, '')::date as data_sorgente_fine
from 
    openbo_landing.lt_incarichi_conferiti
where
    nullif(lt_incarichi_conferiti.data_fine_incarico, '')::date is not null;


-- controllo che non ci siano duplicati e ora lo commento

/*select
    data_sorgente_fine,
    count(*) as conteggio_duplicati
from
    openbo_landing.tt_tempo_fine
group by
    data_sorgente_fine  -- raggruppa tutte le righe con la stessa data
having
    count(*) > 1;       -- mostra solo le date che appaiono più di una volta

    
-- se voglio controllare per paranoia che la dim_tempo_inizio non abbia doppioni

    select
    ids_giorno,
    count(*) as conteggio_duplicati
from
    openbo_dwh.dim_tempo_inizio dti 
group by
    ids_giorno  -- raggruppa tutte le righe con la stessa data
having
    count(*) > 1;
    
-- ok qui mi sembra vada tutto bene! yeeeeh. ho il dubbio che sto usando pero' solo la parte di uno e non la union. proviamo a fare la union di tutte e due e dargli una tabella temporanea. 2025_10_20 ho passato qualche giorno lavorando soltanto e non ricordo cosa dovevo fare quindi ora faccio solo la union*/
    
/* select tti.data_sorgente from openbo_landing.tt_tempo_inizio tti 
 union
 select data_sorgente_fine  from openbo_landing.tt_tempo_fine*/
 
 --francamente non ho capito il ragionamento che ho fatto e passo oltre

drop table if exists openbo_dwh.dim_tempo_fine;
create table openbo_dwh.dim_tempo_fine as
select distinct
	-- ids giorno
    coalesce(
    	CAST(
        TO_CHAR(data_sorgente_fine, 'YYYYMMDD'
        ) AS INTEGER),
        -1
    ) AS ids_giorno_fine,
    
	-- giorno
	COALESCE(
			extract(
				day from data_sorgente_fine
				),
			-1
		) as giorno_fine,
    
	-- mese

	COALESCE(
			extract(
				month from data_sorgente_fine
				),
			-1
		) as mese_fine,
	

	COALESCE(
			extract(
				year from data_sorgente_fine
				),
			-1
		) as anno_fine,	
	
	--nome_mese
	
	COALESCE(
	        TRIM(
	        	INITCAP(
	        			to_char(data_sorgente_fine, 'Month')
	            )
	        ),
	        'missing/mancante' -- per i nomi deve essere una stringa
	  	) AS nome_mese_fine,
  	
  	--quarter
	  	
  	COALESCE(
  			TRIM(
  				INITCAP(
  						TO_CHAR(data_sorgente_fine, '"Q"Q')
  				)
  			),
  					'missing/mancante'
  	) AS trimestre_fine,
  	
  	--nome giorno
  	COALESCE(
  			TRIM(
  				INITCAP(
  					TO_CHAR(data_sorgente_fine, 'Day')
  					)
  				),
       				'missing/mancante'
  	) AS giorno_settimana_fine,
  	
  	
  	'ETL' as source_system
	
from openbo_integration.tt_tempo_fine;

-- qui semplicemente ho copincollato la creazione inizio e messo tutto dalla tabella tt di fine


-- ho cercato online un aiuto per scrivere dei nest della funzione replace, ho visto che e' possibile nestare un sacco di cose e quindi ho prima fatto "dottore" e poi "dott" ed ho messo tutto lower perche' prendesse tutto. per ora non ho sistemato ada labriola, voglio finire le tabelle, devo anche mettere initcap

-- ora faccio union x tabella temporanea responsabili pulendo nel mentre spazi e maiuscole minuscole che dovrebbe essere la mia tt_

drop table if exists openbo_integration.tt_responsabili;
create table openbo_integration.tt_responsabili as
select 
	coalesce(
		nullif(lower(trim(responsabile)), ''),
		'missing/mancante'
		) as responsabile_pulito,
	'incarichi_di_collaborazione' as source_system
	from openbo_landing.lt_incarichi_di_collaborazione lidc 

union

select coalesce(
		nullif(lower(trim(responsabile_della_struttura_conferente)), ''),
		'missing/mancante'
		) as responsabile_pulito,
'incarichi_conferiti' as source_system	
from openbo_landing.lt_incarichi_conferiti lic;



-- qui provo un primo abbozzo di dim_responsabile

set search_path to openbo_dwh;

drop table if exists openbo_dwh.dim_responsabile;

create table dim_responsabile as
select distinct
	trim( 
		replace(
			replace(
				replace(
					replace(
	                    replace(
	                        replace(
	                            replace(
	                                replace(
	                                    replace(
	                                   		replace(
	                                        	replace(lower(responsabile), 'arch.', ''), 
					                		'avvocato', ''),
				                		'avv,', ''),
			                		'avv.', ''),
			                		'il direttore del settore dott.', ''),
	                    		'direttore settore entrate dott.', ''),
	                		'dott.ssa', ''),
	            		'dott.', ''),
	        		'dr.ssa', ''),
	    		'dr.',''),		
		'ing.', ''
		)
	) as nominativo_responsabile,
	
'query' as ids_responsabile,
'ETL' as source_system

from openbo_landing.lt_incarichi_di_collaborazione;
