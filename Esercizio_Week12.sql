


drop table if exists ESERCIZIO;
CREATE TABLE ESERCIZIO
(
    esercizio_id INT NOT NULL,
    descrizione_esercizio VARCHAR(300)
);

INSERT INTO ESERCIZIO (esercizio_id, descrizione_esercizio) VALUES
    (1, 'Aprire il sito https://refresh-academy.org/'),
    (2, 'Eseguire tutte le query di questo script'),
    (3, 'Invia le 3 parole che seguono dopo "troverete" alla email andrea.scavolini@refresh-academy.org');

select * from troverete;