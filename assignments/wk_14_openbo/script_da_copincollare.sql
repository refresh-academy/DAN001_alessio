/* landing zone
-- creo lo schema della landing zone: da eseguire solo una volta e quindi da tenere commentato
create schema openbo_landing;
*/
-- integration layer
-- creo lo schema dell'integration layer


drop schema if exists openbo_integration cascade;


create schema openbo_integration;


set search_path to openbo_integration;


-- creo una tabella temporanea con i nomi delle colonne target di incarichi di collaborazione
drop table if exists tt_incarichi_collaborazione;


create table tt_incarichi_collaborazione as
select row_number() over() as ids_riga,
"id" as id_incarico,
"n_pg_atto" as numero_pg_atto,
"anno_pg_atto" as anno_pg_atto,
"oggetto" as oggetto,
"classificazione_incarichi" as id_classificazione_incarico,
"descrizione_classificazione_incarichi" descrizione_classificazione_incarico,
"norma_o_titolo" as norma_titolo_base,
"importo"::decimal as importo,
initcap("settore_dipartimento_area") as nome_struttura,
-- "servizio", --campo da trascurare
-- "uo", --campo da trascurare
-- "dirigente", --campo da trascurare
initcap("responsabile") as nominativo_responsabile,
initcap("ragione_sociale") as ragione_sociale,
"partita_iva" as partita_iva,
"codice_fiscale" as codice_fiscale,
"durata_dal" as giorno_inizio,
"durata_al" as giorno_fine,
--"curriculum_link" --campo da trascurare
'incarichi di collaborazione' as source_system,
now() as load_timestamp
from openbo_landing.lt_incarichi_di_collaborazione
where "importo" is not null; -- come da specifica scarto le righe con importo nullo


-- creo una tabella temporanea con i nomi delle colonne target di incarichi conferiti
drop table if exists tt_incarichi_conferiti;


create table tt_incarichi_conferiti as
select row_number() over() as ids_riga,
id as id_incarico,
n_pg_atto as numero_pg_atto,
anno_pg_atto as anno_pg_atto,
classificazione_incarico as id_classificazione_incarico,
-- "descrizione_incarico", --campo da trascurare
data_inizio_incarico as giorno_inizio,
data_fine_incarico as giorno_fine,
-- "durata_incarico", --campo da trascurare: andra' ricalcolato
compenso_previsto::decimal as importo,
initcap("struttura_conferente") as nome_struttura,
initcap("responsabile_della_struttura_conferente") as nominativo_responsabile,
'incarichi conferiti' as source_system,
now() as load_timestamp
from openbo_landing.lt_incarichi_conferiti
where compenso_previsto is not null; 

-- come da specifica scarto le righe con importo nullo


-- creo la tabella temporanea degli atti da incarichi di collaborazione
/* in questo caso avendo diverse colonne costruisco
* la dimensione con dei passaggi intermedi e non in unica query
* perche' usando subquery il codice sarebbe di difficile lettura
*/
drop table if exists tt_dim_atto_incarichi_collaborazione;


create table tt_dim_atto_incarichi_collaborazione as
--per semplicita' si e' usato il max invece di raggruppare per tutti i valori in modo anche da avere sicurezza di unicita' di chiave
select numero_pg_atto, max(anno_pg_atto) as anno_pg_atto, max(oggetto) as oggetto, max(norma_titolo_base) as norma_titolo_base, max(source_system) as source_system
from tt_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto;


/* nota: la semplificazione di usare il max puo' incontrare errori
* se la chiave fosse multipla e anno_pg_atto non fosse univoco
* per verificarlo si e' ad esempio visto nella fase di data profiling
* che le seguenti query restituiscono lo stesso valore distinct di atti (525)


* ipotesi doppia chiave numero_pg_atto, anno_pg_atto
select count(*)
from
(select numero_pg_atto, anno_pg_atto
from tt_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto, anno_pg_atto)


* ipotesi singola chiave numero_pg_atto
select count(*)
from
(select numero_pg_atto
from tt_incarichi_collaborazione
where numero_pg_atto is not null
group by numero_pg_atto)


* e l'ipotesi della singola chiave numero_pg_atto e' verificata
*  */


-- creo la tabella temporanea degli atti da incarichi conferiti
drop table if exists tt_dim_atto_incarichi_conferiti;


/* nb: i dati sono comunque disgiunti,
* ossia gli atti di incarichi conferiti
* non sono mai gli stessi di incarichi di collaborazione.
* ad ogni modo si segue la specifica data dalla business rule in casi come questi
* perche' i dati potrebbero cambiare nel futuro e sovrapporsi.
*/
create table tt_dim_atto_incarichi_conferiti as
select a.numero_pg_atto, max(a.anno_pg_atto) as anno_pg_atto, max(a.source_system) as source_system --per semplicita' si e' usato il max invece di raggruppare per tutti i valori in modo anche da avere sicurezza di unicita' di chiave
from tt_incarichi_conferiti a
left join tt_dim_atto_incarichi_collaborazione b -- in alternativa al left join in cui poi si verifica che siano disgiunti con "is null" si puo' procedere con una group by. useremo questa modalita' per un altra dimensione
on a.numero_pg_atto=b.numero_pg_atto
where a.numero_pg_atto is not null
and b.numero_pg_atto is null -- escludo i dati corrispondenti a dei record nella tabella a destra del join e quindi in tt_dim_atto_incarichi_collaborazione
group by a.numero_pg_atto;


-- creo la tabella dimensionale degli atti
drop table if exists it_dim_atto;


create table it_dim_atto as
select row_number() over() as ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
from
	(
	select numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
	from tt_dim_atto_incarichi_collaborazione
	union
	select numero_pg_atto, anno_pg_atto, null as oggetto, null as norma_titolo_base, source_system
	from tt_dim_atto_incarichi_conferiti
	);
-- inserisco un fittizio in atto
insert into it_dim_atto (ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system)
values(-1, null, null, '*** atto fittizio', null, 'etl');


-- creo la dimensione classificazione incarico
drop table if exists it_dim_classificazione_incarico;


create table it_dim_classificazione_incarico as
select row_number() over() as ids_classificazione_incarico, id_classificazione_incarico, max(descrizione_classificazione_incarico) as descrizione_classificazione_incarico, max(source_system) as source_system
from tt_incarichi_collaborazione
group by id_classificazione_incarico;


-- inserisco un fittizio
insert into openbo_integration.it_dim_classificazione_incarico
(ids_classificazione_incarico, id_classificazione_incarico, descrizione_classificazione_incarico, source_system)
values(-1, null, '*** classificazione fittizia', 'etl');


-- creo la tabella temporanea delle strutture da incarichi di collaborazione
drop table if exists it_dim_struttura;


/* in questo caso avendo una sola colonna costruisco
* la dimensione con un unica query usando subquery in quanto
* di semplice lettura
*/
create table it_dim_struttura as
select row_number() over() as ids_struttura, nome_struttura, source_system
from
	(
		(
		select nome_struttura, max(source_system) as source_system --source_system ha sempre lo stesso valore, si potrebbe mettere anche nel group by
		from tt_incarichi_collaborazione
		where nome_struttura is not null
		group by nome_struttura
		)
	union
		(
		select a.nome_struttura, max(a.source_system) as source_system
		from tt_incarichi_conferiti a
		left join tt_incarichi_collaborazione b
		on a.nome_struttura=b.nome_struttura
		where a.nome_struttura is not null
		and b.nome_struttura is null
		group by a.nome_struttura
		)
	)
;


-- inserisco un fittizio
insert into it_dim_struttura
(ids_struttura, nome_struttura, source_system)
values(-1, '*** struttura fittizia', 'etl');


-- creo la dimensione classificazione incarico
drop table if exists it_dim_soggetto_incaricato;


create table it_dim_soggetto_incaricato as
--in questo caso l'uso dei max puo' portare a enormi semplificazioni ma sistema molti dei casi (vedi seguito)
select row_number() over() as ids_soggetto_incaricato, ragione_sociale, max(partita_iva) as partita_iva, max(codice_fiscale) as codice_fiscale, max(source_system) as source_system
from tt_incarichi_collaborazione
group by ragione_sociale;


/*
* si puo' verificare che le ragioni sociali compaiono con valori di partita iva e codice fiscali differenti


select count (*)
from
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from tt_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
);
-- restituisce 517


-- mentre:
select count (*)
from
(
select ragione_sociale
from tt_incarichi_collaborazione
group by ragione_sociale
);
-- restituisce 494


-- nello specifico alcuni icasi in cui i record differiscono sono:


select *
from
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from tt_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
) a
left join
(
select ragione_sociale, coalesce(partita_iva,'***missing') as partita_iva, coalesce(codice_fiscale,'***missing') as codice_fiscale
from tt_incarichi_collaborazione
group by ragione_sociale, coalesce(partita_iva,'***missing'), coalesce(codice_fiscale,'***missing')
) b
on a.ragione_sociale=b.ragione_sociale
left join it_dim_soggetto_incaricato c
on a.ragione_sociale=c.ragione_sociale
where (a.partita_iva<>b.partita_iva
or a.codice_fiscale<>b.codice_fiscale);


* da cui si vede che spesso sono informazioni incomplete
* di partite iva o codici fiscali mancanti che si sistemano
* con un max. si vedono anche casi di inserimenti con errori
* come esempio codici fiscali leggermente differenti il cui
* risultato con un max e' casuale ma non risolvibile senza un
* calcolatore di codici fiscali
*
* ci sarebbe anche la possibilita' di ridurre le occorrenze escludendo
* certi prefissi come avv. etc. ma con il rischio di commettere errori
* per cui per semplicita' si sono tenuti cosi'
*/


-- inserisco fittizio
insert into it_dim_soggetto_incaricato
(ids_soggetto_incaricato, ragione_sociale, partita_iva, codice_fiscale, source_system)
values(-1, '*** soggetto fittizio', null, null, 'etl');


-- presentation layer: dwh


-- creo il data mart
drop schema if exists openbo_dwh cascade;


create schema openbo_dwh;


set search_path to openbo_dwh;


-- creo la dimensione atto
drop table if exists dim_atto;


create table dim_atto as
select ids_atto, numero_pg_atto, anno_pg_atto, oggetto, norma_titolo_base, source_system
from openbo_integration.it_dim_atto;
-- sarebbe meglio caricare solo le occorrenze che fanno join con il fatto ma
-- ancora non essendo creato ci si ferma cosi'


-- creo la dimensione classificazione incarico
drop table if exists dim_classificazione_incarico;


create table dim_classificazione_incarico as
select ids_classificazione_incarico, id_classificazione_incarico, descrizione_classificazione_incarico, source_system
from openbo_integration.it_dim_classificazione_incarico;
-- sarebbe meglio caricare solo le occorrenze che fanno join con il fatto ma
-- ancora non essendo creato ci si ferma cosi'


-- creo la dimensione struttura
drop table if exists dim_struttura;


create table dim_struttura as
select ids_struttura, nome_struttura, source_system
from openbo_integration.it_dim_struttura;
-- sarebbe meglio caricare solo le occorrenze che fanno join con il fatto ma
-- ancora non essendo creato ci si ferma cosi'


-- creo la dimensione soggetto incaricato
drop table if exists dim_soggetto_incaricato;


create table dim_soggetto_incaricato as
select ids_soggetto_incaricato, ragione_sociale, partita_iva, codice_fiscale, source_system
from openbo_integration.it_dim_soggetto_incaricato;
-- sarebbe meglio caricare solo le occorrenze che fanno join con il fatto ma
-- ancora non essendo creato ci si ferma cosi'
