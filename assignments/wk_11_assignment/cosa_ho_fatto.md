ho analizzato i due dataset facendo un mini landing su postres. ho fatto un po' di casino con le due tabelle e i loro nomi ma alla fine ce l'ho fatta. ho dovuto mettere ogni volta bologna. davanti al nome della tabella perche' non avevo messo lo schema di default a bologna e quindi dbeaver non lo trovava credo.


**1. “Che informazioni contiene ogni dataset?”**

prima di tutto importo i dati con PostgreSQL per fare un mini landing zone visto che i dati sono un po' sporchi

mi da il seguente errore:
ERROR: value too long for type character varying(500)

che risolvo importanto ogni colonna come varchar 
e poi facendo un alter table per cambiare il tipo di dato delle colonne che mi interessano

(per esempio la colonna ID ho voluto che fosse un integer)
faccio la stessa altra cosa per la colonna che contiene le date e il numero atto (una rapida ricerca mi rivela che PG significa protocollo generale)


```sql 
   alter table incarichi_di_collaborazione 
   ALTER COLUMN id TYPE integer USING id::integer;

   alter table incarichi_conferiti 
   ALTER COLUMN id TYPE integer USING id::integer;
```

Per importare il secondo database faccio direttamente con l'import di Dbeaver, stando attendo a mettere tutte le colonne come varchar.
Questo probabilmente succede perche il Comune, oltre ad aver anonimizzato i dati, non ha fatto un buon lavoro di pulizia e formattazione dei dati prima di pubblicarli e quando li esporto in csv e poi li importo in PostgreSQL mi da questi errori.

I dataset contengono informazioni sugli incarichi di collaborazione e di consulenza conferiti dal Comune di Bologna in ottemperanza alla legge sulla trasparenza (L. 190/2012) - ho dovuto studiarla per un concorso pubblico a cui ho partecipato per la regione lol

**2. “Quali colonne sono piú importanti?”**

Per il primo dataset (incarichi_conferiti) le colonne piú importanti sono:

```sql
SELECT * FROM incarichi_conferiti LIMIT 10;
```

id e n_pg_atto sono gli identificativi univoci dell'incarico
non ho visto ripetizioni in questi campi ma di n_pg_atto si potrebbe fare un controllo piú approfondito tramite una query

```sql 
SELECT n_pg_atto, COUNT(*) as count
FROM incarichi_conferiti
GROUP BY n_pg_atto
HAVING COUNT(*) > 1
order by count DESC;
```
ci sono molti duplicati quindi id e' l'identificativo univoco credo.
inoltre ci sono ben 79 righe vuote il che significa che ci sono 79 incarichi senza numero di atto, qualcuno non e' stato registrato correttamente :) ahi ahi ahi
farei notare la cosa al Comune di Bologna ad ogni modo

facendo
```sql
select conf.responsabile_della_struttura_conferente, count(*) as totale
FROM bologna.incarichi_conferiti as conf
where conf.n_pg_atto = ''
group by conf.responsabile_della_struttura_conferente 
order by totale DESC
```

vedo che Maria Grazia Bonzagni risulta essere la responsabile di ben 39 incarichi senza numero di atto 15 dei quali sono maiuscolo ed ovviamente dovrei controllare se sono duplicati e forse fare una join con se stessa (pero' preferisco andare avanti coll'analisi dei dati perche' altrimenti mi perdo nel dettaglio e non riesco a vedere il quadro generale) ad ogni modo l'ho cercata su google ed e' capo dipartimento dati digitale e pari opportunita
https://www.comune.bologna.it/amministrazione/politici/mariagrazia-bonzagni

secondariamente analizzerei le colonne dei compensi erogati e le date di inizio e fine incarico per curiosita
per vedere i costi:

```sql
SELECT SUM(NULLIF(compenso_previsto_euro, '')::numeric) as totale_compenso
FROM bologna.incarichi_conferiti;
```   

ho usato :: per forzare la conversione in numerico e NULLIF per evitare gli errori di conversione che mi venivano fuori

wow 755788.16 euro in incarichi conferiti in 813 incarichi LOL

per il secondo dataset (incarichi_di_collaborazione) le colonne piú importanti sono:

```sql
SELECT * FROM incarichi_di_collaborazione LIMIT 10;
```   

anche qui ho avuto problemi con colonne e nomi e tipi di dati e quindi ho convertito tutto in varchar e poi ho fatto un alter table per cambiare i tipi di dato delle colonne che mi interessano per i calcoli (ma non sempre. ora che ho scoperto ::  posso usarlo per fare le conversioni al volo)


**3. “I dati dei due dataset comunicano(possono essere collegati) tra loro?”**
“Quanto sono affidabili/puliti questi dataset?”


credo che i dati siano abbastanza puliti ma non ho idea di come possano essere considerati puliti. ci sono errori nelle date e caselle vuote in campi che non dovrebbero essere vuoti (per esempio n_pg_atto) e questo non e' un buon segno sicuramente
considerando il primo database analizzato (incarichi_conferiti) e facendo una rapida conta i 79 incarichi senza numero di atto su 813 totali sono circa il 10% del totale comunque.

**4. “Quali insights (osservazioni) potrei ricavare/ottenere da questi dati?”**

ho provato a fare varie query per vedere chi sono i piu' pagati, chi ha ricevuto piu' incarichi, quali sono le strutture che conferiscono piu' incarichi ecc
per esempio per vedere chi ha dato piu' incarichi ho fatto:

```sql
SELECT conf.responsabile_della_struttura_conferente, conf.struttura_conferente, COUNT(conf.responsabile_della_struttura_conferente) as totale
FROM bologna.incarichi_conferiti as conf
GROUP BY conf.responsabile_della_struttura_conferente, conf.struttura_conferente 
ORDER BY totale DESC;
```   
questa e' la parte che ho fatto per prima cosa mentre ero a lezione nei tempi morti.
poi a casa ho rifatto tutto da capo perche' non mi ricordavo piu' come avevo fatto e me lo ritrovo qui nel github ahah

quindi quali sono gli insights che posso ricavare da questi dati?
- il totale degli incarichi conferiti e' di 755788.16 euro abbiamo visto sopra

- il totale degli incarichi di collaborazione e' di 202750.00 euro

```sql
select SUM(nullif (importo_euro, '')::numeric) as totale_importi
FROM bologna.incarichi_di_collaborazione;
```
il totale e' di 5551445.47 che e' troppo
questo perche' la conversione in numerico non e' riuscita perche' ci sono dei valori non convertibili oppure il solito problema america italia LOL
quindi devo convertire i valori in qualche modo
pensavo di suare trim per togliere gli spazi e replace per togliere il simbolo dell'euro e i punti 

```sql
SELECT 
  SUM(
    NULLIF(
      REPLACE(
        REPLACE(TRIM(importo_euro), '.', ''), 
        ',', '.'
      ), 
      ''
    )::numeric
  ) AS totale_importi
FROM bologna.incarichi_di_collaborazione;
```
mi da 213270,061 che mi sembra meglio. gli errori con la virgola erano presenti anche a lavoro molto spesso 
quindi ora rifaccio anche incarich_conferiti

```sql
SELECT 
  SUM(
    NULLIF(
      REPLACE(
        REPLACE(TRIM(compenso_previsto_euro), '.', ''), 
        '€', ''
      ), 
      ''
    )::numeric
  ) AS totale_compenso
FROM bologna.incarichi_conferiti;
```

che mi da' 46935,830
mi chiedo se ci sia un modo per fare queste conversioni in automatico, tipo settare u singolo database come "italiano" e non tutto dbeaver
ha senso?

poi si potrebbe vedere chi ha conferito piu' incarichi, chi e' stato pagato di piu', quale struttura ha conferito piu' incarichi ecc
ho cercato il collaboratore che ha ricevuto piu' pagato ed e' stato gabriele bonora 

qui e' successo che e' morto il pc
avevo ricercato questo qui che aveva preso piu' soldi ed aprendo il link dentro il db al suo curriculum il pc mi e' crashato
e non avevo salvato
per fortuna vsc aveva salvato una bozza (credo)

ora penso che vi saluto!

questo assignment mi ha richiesto tutta la mattina e un'oretta dopo pranzo ma mi sono divertito molto a farlo
avrei potuto sicuramente scrivere di piu' ma ho pensato che avreste avuto troppoa roba da leggere
inoltre lavorare da casa per me e' deleterio, non sono abituato e mi distraggo troppo :(

  p.s. mi sono dimenticatodi inserire il data catalogue che sto facendo ora

 

