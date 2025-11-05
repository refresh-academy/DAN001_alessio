/* Landing zone 

-- creo lo schema della landing zone: da eseguire solo una volta e quindi da tenere commentato

create schema openbo_landing;

*/


-- Integration Layer 

-- creo lo schema dell'integration layer

drop schema if exists openbo_integration cascade;
create schema openbo_integration;

set search_path to openbo_integration;

-- identifico errori nelle date per incarichi di collaborazione
drop table if exists ET_incarichi_collaborazione;

create table ET_incarichi_collaborazione as
-- seleziono gli errori in cui data fine minore di data inizio
select *, 'Warning: data fine minore di data inizio' as error_code
from openbo_landing."LT_INCARICHI_DI_COLLABORAZIONE"
where "DURATA_DAL">"DURATA_AL"
union all
-- seleziono gli errori in cui il responsabile e' mancante
select *, 'Warning: responsabile mancante' as error_code
from openbo_landing."LT_INCARICHI_DI_COLLABORAZIONE"
where "RESPONSABILE" is null or "RESPONSABILE"='' -- Si potrebbe anche scrivere coalesce("RESPONSABILE", '') = '' ma la lettura risulta meno intuitiva
union all
-- seleziono gli errori in cui l'importo e' null
select *, 'Error: importo mancante' as error_code
from openbo_landing."LT_INCARICHI_DI_COLLABORAZIONE"
where "IMPORTO" is null
;

-- identifico errori nelle date per incarichi conferiti

drop table if exists ET_incarichi_conferiti;

create table ET_incarichi_conferiti as
-- seleziono gli errori in cui data fine minore di data inizio
select *, 'Warning: data fine minore di data inizio' as error_code
from openbo_landing."LT_INCARICHI_CONFERITI"
where "DATA_INIZIO_INCARICO">"DATA_FINE_INCARICO"
union all
-- seleziono gli errori in cui il responsabile e' mancante
select *, 'Warning: responsabile mancante' as error_code
from openbo_landing."LT_INCARICHI_CONFERITI"
where "RESPONSABILE_DELLA_STRUTTURA_CONFERENTE" is null or "RESPONSABILE_DELLA_STRUTTURA_CONFERENTE"=''
union all
-- seleziono gli errori in cui l'importo e' null
select *, 'Error: importo mancante' as error_code
from openbo_landing."LT_INCARICHI_CONFERITI"
where "COMPENSO_PREVISTO" is null;


-- Creo una tabella temporanea con i nomi delle colonne target di incarichi di collaborazione
drop table if exists TT_incarichi_collaborazione;

create table TT_incarichi_collaborazione as
select row_number() over() as ids_riga,
"ID" as id_incarico,
"N_PG_ATTO" as numero_pg_atto,
"ANNO_PG_ATTO" as anno_pg_atto,
"OGGETTO" as oggetto,
"CLASSIFICAZIONE_INCARICHI" as id_classificazione_incarico,
"DESCRIZIONE_CLASSIFICAZIONE_INCARICHI" descrizione_classificazione_incarico,
"NORMA_O_TITOLO" as norma_titolo_base,
"IMPORTO"::decimal as importo,
INITCAP("SETTORE_DIPARTIMENTO_AREA") as nome_struttura,
-- "SERVIZIO", --Campo da trascurare
-- "UO", --Campo da trascurare
-- "DIRIGENTE", --Campo da trascurare
INITCAP("RESPONSABILE") as nominativo_responsabile,
INITCAP("RAGIONE_SOCIALE") as ragione_sociale,
"PARTITA_IVA" as partita_iva,
"CODICE_FISCALE" as codice_fiscale,
"DURATA_DAL" as giorno_inizio,
"DURATA_AL" as giorno_fine,
--"CURRICULUM_LINK" --Campo da trascurare
'Incarichi di collaborazione' as source_system,
now() as load_timestamp
from openbo_landing."LT_INCARICHI_DI_COLLABORAZIONE"
where "IMPORTO" is not null; -- come da specifica scarto le righe con importo nullo

-- Creo una tabella temporanea con i nomi delle colonne target di incarichi conferiti
drop table if exists TT_incarichi_conferiti;

create table TT_incarichi_conferiti as
select row_number() over() as ids_riga,
"ID" as id_incarico,
"N_PG_ATTO" as numero_pg_atto,
"ANNO_PG_ATTO" as anno_pg_atto,
"CLASSIFICAZIONE_INCARICO" as id_classificazione_incarico,
-- "DESCRIZIONE_INCARICO", --Campo da trascurare
"DATA_INIZIO_INCARICO" as giorno_inizio,
"DATA_FINE_INCARICO" as giorno_fine,
-- "DURATA_INCARICO", --Campo da trascurare: andra' ricalcolato
"COMPENSO_PREVISTO"::decimal as importo,
INITCAP("STRUTTURA_CONFERENTE") as nome_struttura,
INITCAP("RESPONSABILE_DELLA_STRUTTURA_CONFERENTE") as nominativo_responsabile,
'Incarichi conferiti' as source_system,
now() as load_timestamp
from openbo_landing."LT_INCARICHI_CONFERITI"
where "COMPENSO_PREVISTO" is not null; -- come da specifica scarto le righe con importo nullo


-- Creo la tabella temporanea degli atti da incarichi di collaborazione
/* In questo caso avendo diverse colonne costruisco 
 * la dimensione con dei passaggi intermedi e non in unica query
 * perche' usando subquery il codice sarebbe di difficile lettura
*/

drop table if exists TT_dim_atto_incarichi_collaborazione;

create table TT_dim_atto_incarichi_collaborazione as
--Per semplicita' si e' usato il max invece di raggruppare per tutti i valori in modo anche da avere sicurezza di unicita' di chiave
select numero_pg_atto, max(anno_pg_atto) as anno_pg_atto, max(oggetto) as oggetto, max(norma_titolo_base) as norma_titolo_base, max(source_system) as source_system
from TT_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto;

/* Nota: la semplificazione di usare il max puo' incontrare errori 
 * se la chiave fosse multipla e anno_pg_atto non fosse univoco
 * per verificarlo si e' ad esempio visto nella fase di data profiling
 * che le seguenti query restituiscono lo stesso valore distinct di atti (525)

 * ipotesi doppia chiave numero_pg_atto, anno_pg_atto

select count(*)
from 
(select numero_pg_atto, anno_pg_atto
from TT_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto, anno_pg_atto)

 * ipotesi singola chiave numero_pg_atto

select count(*)
from 
(select numero_pg_atto
from TT_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto)

 * e l'ipotesi della singola chiave numero_pg_atto e' verificata
 *  */

-- Creo la tabella temporanea degli atti da incarichi conferiti
drop table if exists TT_dim_atto_incarichi_conferiti;

/* NB: i dati sono comunque disgiunti,
 * ossia gli atti di incarichi conferiti
 * non sono mai gli stessi di incarichi di collaborazione.
 * Ad ogni modo si segue la specifica data dalla business rule in casi come questi
 * perche' i dati potrebbero cambiare nel futuro e sovrapporsi.
 */

create table TT_dim_atto_incarichi_conferiti as
select a.numero_pg_atto, max(a.anno_pg_atto) as anno_pg_atto, max(a.source_system) as source_system --Per semplicita' si e' usato il max invece di raggruppare per tutti i valori in modo anche da avere sicurezza di unicita' di chiave
from TT_incarichi_conferiti a
left join TT_dim_atto_incarichi_collaborazione b -- In alternativa al left join in cui poi si verifica che siano disgiunti con "is null" si puo' procedere con una group by. Useremo questa modalita' per un altra dimensione
on a.numero_pg_atto=b.numero_pg_atto
where a.numero_pg_atto is not null
and b.numero_pg_atto is null -- escludo i dati corrispondenti a dei record nella tabella a destra del join e quindi in TT_dim_atto_incarichi_collaborazione
group by a.numero_pg_atto;


-- Creo la tabella dimensionale degli atti
drop table if exists IT_dim_atto;

create table IT_dim_atto as
select row_number() over() as ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
from
	(
	select numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
	from TT_dim_atto_incarichi_collaborazione
	union
	select numero_pg_atto, anno_pg_atto, null as oggetto, null as norma_titolo_base, source_system
	from TT_dim_atto_incarichi_conferiti
	);

-- inserisco un fittizio in atto

insert into IT_dim_atto (ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system)
values(-1, null, null, '*** Atto fittizio', null, 'ETL');

-- creo la dimensione classificazione incarico

drop table if exists IT_dim_classificazione_incarico;

create table IT_dim_classificazione_incarico as
select row_number() over() as ids_classificazione_incarico, id_classificazione_incarico, max(descrizione_classificazione_incarico) as descrizione_classificazione_incarico, max(source_system) as source_system
from TT_incarichi_collaborazione
group by id_classificazione_incarico;

-- inserisco un fittizio

INSERT INTO openbo_integration.IT_dim_classificazione_incarico
(ids_classificazione_incarico, id_classificazione_incarico, descrizione_classificazione_incarico, source_system)
VALUES(-1, NULL, '*** Classificazione fittizia', 'ETL');


-- Creo la tabella temporanea delle strutture da incarichi di collaborazione
drop table if exists IT_dim_struttura;

/* In questo caso avendo una sola colonna costruisco 
 * la dimensione con un unica query usando subquery in quanto
 * di semplice lettura
*/
create table IT_dim_struttura as
select row_number() over() as ids_struttura, nome_struttura, source_system
from 
	(
		(
		select nome_struttura, max(source_system) as source_system --source_system ha sempre lo stesso valore, si potrebbe mettere anche nel group by
		from TT_incarichi_collaborazione
		where nome_struttura is not null
		group by nome_struttura
		)
	union
		(
		select a.nome_struttura, max(a.source_system) as source_system
		from TT_incarichi_conferiti a
		left join TT_incarichi_collaborazione b
		on a.nome_struttura=b.nome_struttura
		where a.nome_struttura is not null
		and b.nome_struttura is null
		group by a.nome_struttura
		)
	)
;

-- Inserisco un fittizio
insert into IT_dim_struttura
(ids_struttura, nome_struttura, source_system)
values(-1, '*** Struttura fittizia', 'ETL');

-- creo la dimensione classificazione incarico

drop table if exists IT_dim_soggetto_incaricato;

create table IT_dim_soggetto_incaricato as
select row_number() over() as ids_soggetto_incaricato, ragione_sociale, MAX(partita_iva) as partita_iva, MAX(codice_fiscale) as codice_fiscale, max(source_system) as source_system --in questo caso l'uso dei max puo' portare a enormi semplificazioni ma si segue la specifica
from TT_incarichi_collaborazione
group by ragione_sociale;

/*
 * Si puo' verificare che le ragioni sociali compaiono con valori di partita iva e codice fiscali differenti

select count (*)
from
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from TT_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
);
-- restituisce 517


-- mentre:
select count (*)
from
(
select ragione_sociale
from TT_incarichi_collaborazione
group by ragione_sociale
);
-- restituisce 494

-- nello specifico alcuni casi in cui i record differiscono sono:

select *
from
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from TT_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
) a
left join
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from TT_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
) b
on a.ragione_sociale=b.ragione_sociale
left join IT_dim_soggetto_incaricato c
on a.ragione_sociale=c.ragione_sociale
where (a.partita_iva<>b.partita_iva
or a.codice_fiscale<>b.codice_fiscale);

 * da cui si vede che spesso sono informazioni incomplete 
 * di partite IVA o codici fiscali mancanti che si sistemano
 * con un max. Si vedono anche casi di inserimenti con errori 
 * come esempio codici fiscali leggermente differenti il cui
 * risultato con un max e' casuale ma non risolvibile senza un
 * calcolatore di codici fiscali
 * 
 * Ci sarebbe anche la possibilita' di ridurre le occorrenze escludendo
 * certi prefissi come Avv. etc. ma con il rischio di commettere errori
 * per cui per semplicita' si sono tenuti cosi'





*/

-- inserisco fittizio
insert into IT_dim_soggetto_incaricato
(ids_soggetto_incaricato, ragione_sociale, partita_iva, codice_fiscale, source_system)
values(-1, '*** Soggetto fittizio', NULL, NULL, 'ETL');

-- creo una tabella temporanea per il responsabile da usare per poi passare al risultato finale

-- per poter poi fare sia il mapping che gestire come da requisito la tracciabilita'
drop table if exists TT_dim_responsabile;

create table TT_dim_responsabile as
select
    trim( -- eseguo un trim per rimuovere spazi iniziali e finali
        case
            when substring(nominativo_responsabile, 1, 4) = 'Ing.' -- verifico se i primi 4 caratteri sono "Ing."
                then substring(nominativo_responsabile, 5) -- escludo i primi 4 e seleziono solo dal 5 in poi
            when substring(nominativo_responsabile, 1, 5) = 'Arch.' 
                then substring(nominativo_responsabile, 6)
            when substring(nominativo_responsabile, 1, 4) = 'Avv.' 
                then substring(nominativo_responsabile, 5)
            when substring(nominativo_responsabile, 1, 4) = 'Avv,' 
                then substring(nominativo_responsabile, 5)
            when substring(nominativo_responsabile, 1, 8) = 'Avvocato' 
                then substring(nominativo_responsabile, 9)
            when substring(nominativo_responsabile, 1, 30) = 'Il Direttore Del Settore Dott.' 
                then substring(nominativo_responsabile, 31)
            when substring(nominativo_responsabile, 1, 31) = 'Direttore Settore Entrate Dott.' 
                then substring(nominativo_responsabile, 32)
            when substring(nominativo_responsabile, 1, 8) = 'Dott.Ssa' 
                then substring(nominativo_responsabile, 9)
            when substring(nominativo_responsabile, 1, 5) = 'Dott.' 
                then substring(nominativo_responsabile, 6)
            when substring(nominativo_responsabile, 1, 6) = 'Dr.Ssa' 
                then substring(nominativo_responsabile, 7)
            when substring(nominativo_responsabile, 1, 3) = 'Dr.' 
                then substring(nominativo_responsabile, 4)
            else nominativo_responsabile
        end
    ) as nominativo_responsabile, nominativo_responsabile as nominativo_responsabile_originale, source_system
from
	(
	select nominativo_responsabile, source_system
	from TT_incarichi_collaborazione
	union
	select nominativo_responsabile, source_system
	from TT_incarichi_conferiti
	)
where trim(nominativo_responsabile) !=''; -- escludo le stringhe vuote

/*
 * -- Alternativa usando una espressione regolare

create table TT_dim_responsabile as
select
    trim( -- eseguo un trim per rimuovere spazi iniziali e finali
        regexp_replace(
            nominativo_responsabile,
            'Arch\.|Avv\.|Avv,|Avvocato|Direttore Settore Entrate Dott\.|Dott\.|Dott\.Ssa|Dr\.|Dr\.Ssa|Il Direttore Del Settore Dott\.|Ing\.',
            '',
            'gi'
        )
    ) as nominativo_responsabile, nominativo_responsabile as nominativo_responsabile_originale, source_system
from
	(
	select nominativo_responsabile, source_system
	from TT_incarichi_collaborazione
	union
	select nominativo_responsabile, source_system
	from TT_incarichi_conferiti
	)
where trim(nominativo_responsabile) !='';

 */


-- parte facoltativa: riduciamo i nomi parziali e i ruoli ad interim (A.I.) associandoli allo stesso nome

drop table if exists TT_dim_responsabile_v2;

create table TT_dim_responsabile_v2 as
select 
	trim( -- eseguo un trim per rimuovere spazi iniziali e finali
		case
            when right(nominativo_responsabile, 3) = 'A.I' -- verifico se gli ultimi 3 caratteri sono "A.I"
                then substring(nominativo_responsabile, 1, length(nominativo_responsabile)-3) -- escludo gli ultimi 3 caratteri
            when right(nominativo_responsabile, 4) = 'A.I.' 
                then substring(nominativo_responsabile, 1, length(nominativo_responsabile)-4)
            when nominativo_responsabile = 'Labriola' 
                then 'Ada Labriola'
             when nominativo_responsabile = 'Ada Simona Labriola'
             	then 'Ada Labriola'
             when nominativo_responsabile = 'Anronella Trentini'
             	then 'Antonella Trentini'
             when nominativo_responsabile = 'Trentini Antonella'
             	then 'Antonella Trentini'
             when nominativo_responsabile = 'Bruni Raffela'
             	then 'Bruni Raffaela'
             when nominativo_responsabile = 'Cattoli Monica'
             	then 'Monica Cattoli'
             when nominativo_responsabile = 'Cazzola Lorenzo'
             	then 'Lorenzo Cazzola'
             when nominativo_responsabile = 'Chirs Tomesani'
             	then 'Chris Tomesani'
             when nominativo_responsabile = 'Daniela Gemell'
             	then 'Daniela Gemelli'
             when nominativo_responsabile = 'Gemelli Daniela'
             	then 'Daniela Gemelli'
             when nominativo_responsabile = 'Fanco Chiarini'
             	then 'Franco Chiarini'
             when nominativo_responsabile = 'Franco Chiarii'
             	then 'Franco Chiarini'
             when nominativo_responsabile = 'Franco Evangelisti'
             	then 'Francesco Evangelisti'
             when nominativo_responsabile = 'Giulia Carstia'
             	then 'Giulia Carestia'
             when nominativo_responsabile = 'Mariagrazia Bonzagbi'
             	then 'Mariagrazia Bonzagni'
             when nominativo_responsabile = 'Mariagrazioa Bonzagni'
             	then 'Mariagrazia Bonzagni'
             when nominativo_responsabile = 'Bonzagni Mariagrazia'
             	then 'Mariagrazia Bonzagni'
             when nominativo_responsabile = 'Garifo Katiuscia'
             	then 'Katiuscia Garifo'
             when nominativo_responsabile = 'Muzzi Mauro'
             	then 'Mauro Muzzi'
            else nominativo_responsabile
        end
	) as nominativo_responsabile, nominativo_responsabile_originale, source_system
from TT_dim_responsabile;

/* creo una tabella di mapping con le occorrenze distinct 
 * per fare il mapping dei responsabili che servira' 
 * per ricondurre i fatti all'anagrafica in seguito
 */
drop table if exists MT_mapping_responsabile;

create table MT_mapping_responsabile as
select distinct nominativo_responsabile, nominativo_responsabile_originale --importante il distinct altrimenti i dati si moltiplicano facendo il mapping!
from TT_dim_responsabile_v2;


-- creo la dimensione responsabile

drop table if exists IT_dim_responsabile;

create table IT_dim_responsabile as
select row_number() over() as ids_responsabile, nominativo_responsabile, source_system
from
	(
	/* la specifica indica di dare priorita' a 'Incarichi di collaborazione'
	 * rispetto a 'Incarichi conferiti'. Come nel caso della dimensione dim atto
	 * si potrebbe usare un left join. Visto che
	 * la stringa 'Incarichi di collaborazione'>'Incarichi conferiti'
 	 * useremo in questo caso il trucco di fare un group by e poi scegliere il max:
 	 * se presente in entrambi risultera' 'Incarichi di collaborazione'
 	 * se presente solo in 'Incarichi conferiti' dara' come risultato quest'ultimo
 	 */
	select nominativo_responsabile, max(source_system) as source_system
	from TT_dim_responsabile_v2
	group by nominativo_responsabile
	order by 1
	);

-- inserisco un fittizio
insert into IT_dim_responsabile
(ids_responsabile, nominativo_responsabile, source_system)
values(-1, '*** Responsabile fittizio', 'ETL');

-- Imposto il locale a Italiano cosi' da avere le descrizioni dei mesi e dei giorni della settimana in italiano
set lc_time = 'it_IT.UTF-8';

-- creo la dimensione tempo inizio (si potrebbero creare assieme inizio e fine e selezionare solo le occorrenze utili)

drop table if exists IT_dim_tempo_inizio;

create table IT_dim_tempo_inizio as
select
	(extract(year from giorno_inizio)*10000+extract(month from giorno_inizio)*100+extract(day from giorno_inizio))::int as ids_giorno, -- importante fare il cast a int
	giorno_inizio as giorno,
	extract(month from giorno_inizio)::int as mese,
	extract(year from giorno_inizio)::int as anno,
	to_char(giorno_inizio, 'TMMonth') as nome_mese,
	'Q' || extract(quarter from giorno_inizio) as trimestre, -- calcolo il trimestre in formato Q1, Q2, Q3, Q4
	to_char(giorno_inizio, 'TMDay') as giorno_settimana,
	'ETL' as source_system
from 
	(
	select giorno_inizio
	from TT_incarichi_collaborazione
	union
	select giorno_inizio
	from TT_incarichi_conferiti
	)
where giorno_inizio is not null
order by giorno_inizio;

-- inserisco un fittizio
insert into IT_dim_tempo_inizio
(ids_giorno, giorno, mese, anno, nome_mese, trimestre, giorno_settimana, source_system)
values(-1, date '1900-01-01', 1, 1900, '*** Mese fittizio', '*** Trimestre fittizio', '*** Giorno fittizio', 'ETL');

-- creo la dimensione tempo fine

drop table if exists IT_dim_tempo_fine;

create table IT_dim_tempo_fine as
select
	(extract(year from giorno_fine)*10000+extract(month from giorno_fine)*100+extract(day from giorno_fine))::int as ids_giorno_fine,
	giorno_fine,
	extract(month from giorno_fine)::int as mese_fine,
	extract(year from giorno_fine)::int as anno_fine,
	to_char(giorno_fine, 'TMMonth') as nome_mese_fine,
	'Q' || extract(quarter from giorno_fine) as trimestre_fine,
	to_char(giorno_fine, 'TMDay') as giorno_settimana_fine,
	'ETL' as source_system
from 
	(
	select giorno_fine
	from TT_incarichi_collaborazione
	union
	select giorno_fine
	from TT_incarichi_conferiti
	)
where giorno_fine is not null
order by giorno_fine;

-- inserisco un fittizio
insert into IT_dim_tempo_fine
(ids_giorno_fine, giorno_fine, mese_fine, anno_fine, nome_mese_fine, trimestre_fine, giorno_settimana_fine, source_system)
values(-1, date '1900-01-01', 1, 1900, '*** Mese fittizio', '*** Trimestre fittizio', '*** Giorno fittizio', 'ETL');

-- creo una tabella per il fatto su cui poter fare test e in cui lasciamo colonne che poi non porteremo nel data mart

drop table if exists IT_fact_incarichi;

create table IT_fact_incarichi as
select
	fi.ids_riga, -- mantengo il campo per controlli: insieme a source_system fornisce una chiave per ogni riga
	fi.id_incarico,
	coalesce(ds.ids_struttura,-1) as ids_struttura, --se non fa match associo a fittizio
	coalesce(dci.ids_classificazione_incarico,-1) as ids_classificazione_incarico, --se non fa match associo a fittizio
	coalesce(extract(year from giorno_inizio)*10000+extract(month from giorno_inizio)*100+extract(day from giorno_inizio),-1)::int as ids_giorno, --se non fa match associo a fittizio
	coalesce(extract(year from giorno_fine)*10000+extract(month from giorno_fine)*100+extract(day from giorno_fine),-1)::int as ids_giorno_fine, --se non fa match associo a fittizio
	coalesce(dsi.ids_soggetto_incaricato,-1) as ids_soggetto_incaricato, --se non fa match associo a fittizio
	coalesce(dr.ids_responsabile,-1) as ids_responsabile, --se non fa match associo a fittizio
	coalesce(da.ids_atto,-1) as ids_atto, --se non fa match associo a fittizio
	fi.importo,
	--calcolo la durata
	case
		when fi.giorno_inizio>fi.giorno_fine
			then null
		else (fi.giorno_fine-fi.giorno_inizio)
	end as durata_giorni,
	-- mantengo i campi nell'integration layer per verifiche future che non importeremo nel data mart
	fi.numero_pg_atto,
	fi.anno_pg_atto,
	fi.id_classificazione_incarico_originale,
	fi.id_classificazione_incarico,
	fi.nome_struttura,
	fi.giorno_inizio,
	fi.giorno_fine,
	fi.nominativo_responsabile,
	fi.ragione_sociale,
	fi.source_system,
	fi.load_timestamp
from
	(
	select ids_riga, id_incarico, numero_pg_atto, anno_pg_atto, id_classificazione_incarico as id_classificazione_incarico_originale,
		-- come da specifica associo a Z5 se trovo Z1
		case
			when id_classificazione_incarico = 'Z1' 
				then 'Z5'
			else id_classificazione_incarico
		end as id_classificazione_incarico,	
		nome_struttura, giorno_inizio, giorno_fine, nominativo_responsabile, ragione_sociale, importo, source_system, load_timestamp
	from TT_incarichi_collaborazione
	union all -- Attenzione quando si tratta di fatti si fanno sempre union all, non vanno persi dati
	select ids_riga, id_incarico, numero_pg_atto, anno_pg_atto, id_classificazione_incarico as id_classificazione_incarico_originale,
		-- come da specifica associo a Z5 se trovo Z1
		case
			when id_classificazione_incarico = 'Z1' 
				then 'Z5'
			else id_classificazione_incarico
		end as id_classificazione_incarico,	
		nome_struttura, giorno_inizio, giorno_fine, nominativo_responsabile, null as ragione_sociale, importo, source_system, load_timestamp
	from TT_incarichi_conferiti
	) fi
-- non faccio join sul tempo perche' non avendo scartato dati non serve (potrei aver pensato regole tipo scartare date antecedenti al 1950)
left join IT_dim_struttura ds
on fi.nome_struttura=ds.nome_struttura
left join IT_dim_classificazione_incarico dci
on fi.id_classificazione_incarico=dci.id_classificazione_incarico
left join IT_dim_soggetto_incaricato dsi
on fi.ragione_sociale=dsi.ragione_sociale
left join IT_dim_atto da
on fi.numero_pg_atto=da.numero_pg_atto
--per andare in join sulla dimensione responsabile devo usare la tabella di mapping intermedia e fare un doppio join
left join MT_mapping_responsabile mr
on fi.nominativo_responsabile=mr.nominativo_responsabile_originale --qui non serve indicare "mr." ma e' buona prassi farlo per rendere il join piu' velocemente leggibile
left join IT_dim_responsabile dr
on mr.nominativo_responsabile=dr.nominativo_responsabile
;




-- Presentation Layer: DWH

-- Creo il Data Mart

drop schema if exists openbo_dwh cascade;
create schema openbo_dwh;

SET search_path TO openbo_dwh;

-- Creo il Fatto Incarichi
drop table if exists Fact_Incarichi;

create table Fact_Incarichi as
-- non seleziono tutte le colonne ma solo quelle da specifica
select ids_riga, id_incarico, ids_struttura, ids_classificazione_incarico, ids_giorno, ids_giorno_fine, ids_soggetto_incaricato, ids_responsabile, ids_atto, importo, durata_giorni, source_system, load_timestamp
from openbo_integration.it_fact_incarichi;


-- Creo la Dimensione Atto
drop table if exists Dim_Atto;

create table Dim_Atto as
select ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
from openbo_integration.IT_dim_atto
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_atto in
	(
	select ids_atto from Fact_Incarichi
	);

-- Creo la Dimensione Classificazione Incarico
drop table if exists Dim_Classificazione_Incarico;

create table Dim_Classificazione_Incarico as
select ids_classificazione_incarico, id_classificazione_incarico, descrizione_classificazione_incarico, source_system
from openbo_integration.IT_dim_classificazione_incarico
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_classificazione_incarico in
	(
	select ids_classificazione_incarico from Fact_Incarichi
	);

-- Creo la Dimensione Struttura
drop table if exists Dim_Struttura;

create table Dim_Struttura as
select ids_struttura, nome_struttura, source_system
from openbo_integration.IT_dim_struttura
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_struttura in
	(
	select ids_struttura from Fact_Incarichi
	);

-- Creo la Dimensione Soggetto Incaricato
drop table if exists Dim_Soggetto_Incaricato;

create table Dim_Soggetto_Incaricato as
select ids_soggetto_incaricato, ragione_sociale, partita_iva, codice_fiscale, source_system
from openbo_integration.IT_dim_soggetto_incaricato
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_soggetto_incaricato in
	(
	select ids_soggetto_incaricato from Fact_Incarichi
	);

-- Creo la Dimensione Responsabile
drop table if exists Dim_Responsabile;

create table Dim_Responsabile as
select ids_responsabile, nominativo_responsabile, source_system
from openbo_integration.IT_dim_responsabile
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_responsabile in
	(
	select ids_responsabile from Fact_Incarichi
	);


-- Creo la Dimensione Tempo Inizio
drop table if exists Dim_Tempo_Inizio;

create table Dim_Tempo_Inizio as
select ids_giorno, giorno, mese, anno, nome_mese, trimestre, giorno_settimana, source_system
from openbo_integration.IT_dim_tempo_inizio
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_giorno in
	(
	select ids_giorno from Fact_Incarichi
	);

-- Creo la Dimensione Tempo Fine
drop table if exists Dim_Tempo_Fine;

create table Dim_Tempo_Fine as
select ids_giorno_fine, giorno_fine, mese_fine, anno_fine, nome_mese_fine, trimestre_fine, giorno_settimana_fine, source_system
from openbo_integration.IT_dim_tempo_fine
-- verifico con una in sul fatto per eliminare occorrenze non utili
where ids_giorno_fine in
	(
	select ids_giorno_fine from Fact_Incarichi
	);

/*
* Eseguo i test di quadratura richiesti
*/
drop table if exists check_importo;

create table check_importo as
select sum("COMPENSO_PREVISTO"::decimal) as importo, 'Incarichi conferiti' as source_system, 'openbo_landing' as layer
from openbo_landing."LT_INCARICHI_CONFERITI"
union
select sum("IMPORTO"::decimal) as importo, 'Incarichi di collaborazione' as source_system, 'openbo_landing' as layer
from openbo_landing."LT_INCARICHI_DI_COLLABORAZIONE"
union
select sum(importo) as importo, source_system, 'openbo_integration' as layer
from openbo_integration.IT_fact_incarichi
group by source_system
union
select sum(importo) as importo, source_system, 'openbo_dwh' as layer
from
	(
	select importo, fi.source_system
	from openbo_dwh.Fact_Incarichi fi
	join openbo_dwh.Dim_Struttura ds
	on fi.ids_struttura=ds.ids_struttura
	join openbo_dwh.Dim_Classificazione_Incarico dci
	on fi.ids_classificazione_incarico=dci.ids_classificazione_incarico
	join openbo_dwh.Dim_Soggetto_Incaricato dsi
	on fi.ids_soggetto_incaricato=dsi.ids_soggetto_incaricato
	join openbo_dwh.Dim_Atto da
	on fi.ids_atto=da.ids_atto
	join openbo_dwh.Dim_Responsabile dr
	on fi.ids_responsabile=dr.ids_responsabile
	join openbo_dwh.Dim_Tempo_Inizio dti
	on fi.ids_giorno=dti.ids_giorno
	join openbo_dwh.Dim_Tempo_Fine dtf
	on fi.ids_giorno_fine=dtf.ids_giorno_fine
	)
group by source_system
;


/*
 * quello che segue serve solo a graficare meglio lo schema

alter table openbo_dwh.dim_atto
ADD CONSTRAINT dim_atto_pkey PRIMARY KEY  (ids_atto);

alter table openbo_dwh.dim_classificazione_incarico
ADD CONSTRAINT dim_classificazione_incarico_pkey PRIMARY KEY  (ids_classificazione_incarico);

alter table openbo_dwh.dim_responsabile
ADD CONSTRAINT dim_responsabile_pkey PRIMARY KEY  (ids_responsabile);

alter table openbo_dwh.dim_soggetto_incaricato
ADD CONSTRAINT dim_soggetto_incaricato_pkey PRIMARY KEY  (ids_soggetto_incaricato);

alter table openbo_dwh.dim_struttura
ADD CONSTRAINT dim_struttura_pkey PRIMARY KEY  (ids_struttura);

alter table openbo_dwh.dim_tempo_inizio
ADD CONSTRAINT dim_tempo_inizio_pkey PRIMARY KEY  (ids_giorno);

alter table openbo_dwh.dim_tempo_fine
ADD CONSTRAINT dim_tempo_fine_pkey PRIMARY KEY  (ids_giorno_fine);

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi1_fkey
    FOREIGN KEY (ids_atto) REFERENCES openbo_dwh.dim_atto (ids_atto) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi2_fkey
    FOREIGN KEY (ids_classificazione_incarico) REFERENCES openbo_dwh.dim_classificazione_incarico (ids_classificazione_incarico) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi3_fkey
    FOREIGN KEY (ids_responsabile) REFERENCES openbo_dwh.dim_responsabile (ids_responsabile) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi4_fkey
    FOREIGN KEY (ids_soggetto_incaricato) REFERENCES openbo_dwh.dim_soggetto_incaricato (ids_soggetto_incaricato) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi5_fkey
    FOREIGN KEY (ids_struttura) REFERENCES openbo_dwh.dim_struttura (ids_struttura) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi6_fkey
    FOREIGN KEY (ids_giorno) REFERENCES openbo_dwh.dim_tempo_inizio (ids_giorno) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE openbo_dwh.fact_incarichi ADD CONSTRAINT fact_incarichi7_fkey
    FOREIGN KEY (ids_giorno_fine) REFERENCES openbo_dwh.dim_tempo_fine (ids_giorno_fine) ON DELETE NO ACTION ON UPDATE NO ACTION;

 */
