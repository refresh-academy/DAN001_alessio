# openbo_prokect

questo e' il mio primo readme serio :)
ho pensato di mettere tutto su git

## cosa ho fatto
- estrazione: ho estratto i dati con lo script di andrea, messo tutto in minuscolo perche' in importazione io avevo preso tutto in miunscolo
- trasformazione: ho fatto qualche trasformazione, creando tutte le dimensioni
- nel file principale ci sono i commenti che dovrebbero aiutare a capire i passaggi

## come eseguire
- prima eseguire su dbeaver lo script
[text](01_openbo_script_landing_andrea.sql)
che permette di fare un landing indentico al mio 
- successivamente eseguire lo script
[text](02_openbo_script_dwh_finale)

che dovrebbe fare ottenere le tabelle pulite.

## cosa rimane da fare

1. Ultimare la dim_tempo_inizio e dim_tempo_fine
- rifare dim_tempo_inizio usando la tabella union (avendo io fatto tutto per prova solo da incarichi_conferiti)
- 'query da fare' as ids_responsabile, con la solita row number over per creare un id unico (prendo da chinook)
- 'ETL da fare meglio' as source_system

2. finire temporary table tt_responsabili
- rifare dim_responsabile con tt_resonsabili xche' come sopra ho fatto tutto on the fly da incarichi_conferiti
- sistemare ada labriolaa dentro al mega-replace
- sistemare franco chiarii dentro al mega-replace
- sistemare A.I. (facoltativo)

3. fare FACT_INCARICHI
4. ET_INCARICHI_COLLABORAZIONE e ET_INCARICHI_CONFERITI
5. fare CHECK_IMPORTI 

Mi piacerebbe provare a farli quindi branchero' da questo ultimo commit per provare a finire le cose.
cmq penso di aver capito e penso di riuscire a fare il resto con calma e tante google search

##  note
la cartella casini vari contiene gli script vari che ho usato che ora vado a copincollare in un unico script
p.s. GOBLIN ROCKS

p.p.s. SIIIIIII PRIMO SCRIPT COMPLETO CHE FUNZIONAAAAAAA AL PRIMO COLPOOO YEEEEEEEH
sono molto happy
volevo fare alcune cose in python ma non ce l'ho fatta sorry terry <3