 
“Che informazioni contiene ogni dataset?”



“Quali colonne sono piú importanti?”

“I dati dei due dataset comunicano(possono essere collegati) tra loro?”
“Quanto sono affidabili/puliti questi dataset?”
“Quali insights (osservazioni) potrei ricavare/ottenere da questi dati?”

 
 alter table incarichi_conferiti 
ALTER COLUMN data_inizio_incarico TYPE date USING data_inizio_incarico::date;

non funziona perche' ci sono dei vuoti
 
 
---


 
 importo i dati in un database PostgreSQL per fare un mini landing zone visto che i dati sono un po' sporchi

mi da il seguente errore:
ERROR: value too long for type character varying(500)

che risolvo importanto ogni colonna come varchar 
e poi facendo un alter table per cambiare il tipo di dato delle colonne che mi interessano

(per esempio la colonna ID ho voluto che fosse un integer)
faccio la stessa altra cosa per la colonna che contiene le date e il numero atto

    alter table incarichi_di_collaborazione 
    ALTER COLUMN id TYPE integer USING id::integer;

    alter table incarichi_conferiti 
    ALTER COLUMN id TYPE integer USING id::integer;
