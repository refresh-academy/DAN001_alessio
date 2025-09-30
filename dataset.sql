-- dataset definition

DROP TABLE IF EXISTS dataset;


CREATE TABLE dataset(
  id INT,
  nome TEXT,
  cognome TEXT,
  data_nascita,
  eta INT,
  anno_nascita TEXT,
  nazione_provenienza TEXT,
  citta_provenienza TEXT,
  citta_residenza TEXT,
  lingue_parlate TEXT,
  titolo_studio TEXT,
  professione TEXT,
  hobbies TEXT,
  attivita_non_piacciono TEXT,
  anni_ingresso_italia INT,
  stato_civile TEXT,
  anno_matrimonio INT,
  anni_in_italia INT,
  numero_fratelli_sorelle TEXT,
  numero_cugini TEXT,
  eta_imparato_nuotare TEXT,
  numero_figli INT,
  numero_animali_domestici INT,
  indirizzo_scuola_superiore TEXT,
  luogo_scuola_superiore TEXT,
  nazione_scuola_superiore TEXT,
  nomi_animali_domestici TEXT,
  film_preferito TEXT
);

INSERT INTO dataset (id,nome,cognome,data_nascita,eta,anno_nascita,nazione_provenienza,citta_provenienza,citta_residenza,lingue_parlate,titolo_studio,professione,hobbies,attivita_non_piacciono,anni_ingresso_italia,stato_civile,anno_matrimonio,anni_in_italia,numero_fratelli_sorelle,numero_cugini,eta_imparato_nuotare,numero_figli,numero_animali_domestici,indirizzo_scuola_superiore,luogo_scuola_superiore,nazione_scuola_superiore,nomi_animali_domestici,film_preferito) VALUES
	 (1,'Giorgio','Patuelli','1959-10-26',65,'1959','Italia','Faenza','Imola','italiano','Laurea Magistrale','Insegnante','Scultura','bracconaggio',NULL,'divorziato',2010,65,'0','','0',0,3,'  ','Vai bellearti, 54','Italia','Bella Diana Fufi','I 3 giorni del Condor'),
	 (2,'Claudia','Rivelli','1986-08-28',38,'1986','Italia','Napoli','Bologna','italiano, inglese','Laurea','Training Specialist','cinema','conoscere fascisti',NULL,'convivente',NULL,38,'0','15','8',0,3,'Liceo Artistico','Napoli','','Margot, Leyla, Kaly','Robin Hood: un uomo in calzamaglia'),
	 (3,'Rafael','Taufer','--',49,'1975','Brasile','Caxias do Sul','Bologna','Portoghese, Inglese, Italiano, Spagnolo','Master','Key Account Executive','Surf, Musica, Cinema','stirare',2024,'coniugato',2014,1,'1','1','6',1,0,'Liceo Scientifico','Caxias do Sul','Brasile','nessuno','City of God'),
	 (4,'Miguel','Vera','--',45,'1979','Peru','San Isidro','Bologna','Spagnolo','Diploma','Ristorazione','Natura','',NULL,'libero',NULL,25,'0','0','',NULL,NULL,'Istituto Superiore Professionale','','n.d','',''),
	 (5,'Alessio','Pedrotti','--',NULL,'nd','Italia','Bologna','Bologna','Italiano, Inglese','Diploma','Commesso','filosfia, MMO, acquarelli, Magic the Gathering, GDR','',NULL,'libero',NULL,NULL,'1','9','10',0,0,'Liceo Psico-Pedagogico','Trento','Italia','',''),
	 (6,'Vittorio','Parnolfi','--',36,'1989','Italia','Bologna','primo maggio','italiano','Diploma','meccatronico','cani,film,relax','correre',NULL,'convivente',NULL,36,'2','20','6anni',1,0,'Istituto Tecnico-Tecnologico ','corticella','Italia','nessuno',''),
	 (7,'Christine','Castillo','1996-05-03',29,'1996','Peru','Huánuco','Bologna','Spagnolo, inglese ','Laurea','Ingegnere Ambientale','pizza, nuotare, gatti','Correre, cucinare',2024,'coniugato',2024,0,'1','15','6',0,1,'n.d','Peru','Perù','Kratos','The Dead Poets Society'),
	 (8,'Rehman','Abdul','--',25,'1999','Pakistan','Gujranwala','Bologna','urdu','Diploma','Studente','Giocare a biliardo,Nuotare','cucinare,Litigare',2023,'libero',NULL,2,'3','29','12anni                                          ',0,0,'n.d','pakistan','Pakistan','',''),
	 (9,'Giuditta','Coffari','1995-04-12',30,'1995','Italia','Firenze','Bologna','italiano, inglese, spagnolo','Laurea Magistrale','disoccupata','natura, lettura','andare in palestra',1995,'coniugato',2024,30,'3','3','5',0,0,'Liceo Classico','Firenze','Italia','','Balla coi lupi'),
	 (10,'Brayan','Peña Velasquez','--',25,'2000','Colombia','Medellin','Italia','Italiano, spagnolo, francese','Diploma','Studente','Musica , Suonare, disegnare, cantare, calcio, allenarmi','Stare fermo',2005,'libero',NULL,19,'2 fratelli','','4',0,0,'Istituto Superiore Professionale','Pistoia','Italia','','Fast and Furious 6');
INSERT INTO dataset (id,nome,cognome,data_nascita,eta,anno_nascita,nazione_provenienza,citta_provenienza,citta_residenza,lingue_parlate,titolo_studio,professione,hobbies,attivita_non_piacciono,anni_ingresso_italia,stato_civile,anno_matrimonio,anni_in_italia,numero_fratelli_sorelle,numero_cugini,eta_imparato_nuotare,numero_figli,numero_animali_domestici,indirizzo_scuola_superiore,luogo_scuola_superiore,nazione_scuola_superiore,nomi_animali_domestici,film_preferito) VALUES
	 (11,'Dimitri','Papadoulis','--',46,'1979','Italia','Bologna','Bologna','Italiano','Diploma','Disoccupato','ecovillaggi arti marziali danza scacchi giocoleria','',NULL,'libero',NULL,NULL,'0','13','5',0,2,'Istituto Superiore Professionale','Bologna','Italia','Merlino Saetta',''),
	 (12,'Johanny Rosario','Ordonez','2025-10-15',43,'1981','Peru','Ica','Italia','spagnolo, italiano, inglese.','Laurea','Ingegnere ','leggere, studiare, cantare, ballare, nuotare.','Caccia',2008,'separato',2008,17,'4','25','5',0,0,'n.d','Ica','Perù','','A Beautiful Mind'),
	 (13,'Luca','Brida','--',35,'1989','Italia','Avellino','Bologna','italiano, inglese,Tedesco,Francese','Laurea','Disoccupato','lingue straniere, letteratura, film','pescare',NULL,'libero',NULL,NULL,'3','6','6',0,1,'Liceo Linguistico','Frigento','Italia','Light ','Un tram che si chiama desiderio'),
	 (14,'Alice','Innocenti','2003-05-12',22,'2003','Italia','Lucca','Bologna','italiano, inglese','Laurea','studentessa','amante degli animali,studiare, leggere, videogiochi','faticare',NULL,'convivente',NULL,NULL,'0','4','5',0,0,'Liceo delle Scienze Umane','Pescia','Italia','',''),
	 (15,'Clair','Goncalves Ramalho','--',41,'1984','Brasile','San Paolo','Bologna','Portoghese','Master','Pedagogista in Melanina kids','Attività cucito creativo, imparare cose nuove, uscia con amici','Stirare',2014,'coniugato',2018,7,'3','5','NO',1,0,'n.d','Brasile','Brasile','',''),
	 (16,'Giorgio','Bettini','2000-01-23',25,'2000','Italia','Bologna','Rastignano','Italiano, Inglese, Spagnolo','Licenza Media','','Stare al PC, giocare ai videogiochi, andare in bici','Fare cose inutili',NULL,'libero',NULL,25,'1','1','4',0,1,'Liceo Scientifico','San Lazzaro','Italia','Missi','Jurassic Park'),
	 (17,'Rosy','Hudur','1985-01-08',40,'1985','Turchia','Istanbul','Bologna','inglese, italiano, turco','Laurea','Disoccupata','andare al mare','stirare',2016,'coniugato',2016,8,'1','3','5',1,NULL,'Liceo Scientifico','Istanbul','Turchia','ciko','Gemide (On Board)'),
	 (18,'Vito Enrico','Fanizzi','--',30,'1995','Italia','Taranto','Bologna','italiano, francese, inglese','Laurea Magistrale','maggiordomo ','libri belli, pugilato, trazioni e TEKKEN e Final Fantasy','leggere il libro di Vannacci',NULL,'libero',NULL,30,'10','54','6',0,0,'Liceo delle Scienze Umane','ITC ENRICO MATTEI','Italia','Torello Furioso','Ghost in the Shell primo doppiaggio in italiano 1995'),
	 (19,'Roberta','Zorzi','1979-11-13',45,'1979','Italia','Treviso','Granarolo dell''Emilia','Italiano, Inglese, Francese, Russo, Tedesco','Laurea','Export Specialist, Assistente di Direzione','lettura, scrittura, tecniche evolutive, passeggiate, inventare giochi ','guardare reality show',1979,'convivente',NULL,45,'1','5','8',NULL,1,'Liceo Linguistico','Treviso','Italia','Fiocco','The Greatest Showman'),
	 (20,'Alessia','Urru','2001-01-30',24,'2001','Italia','Bologna','Sasso Marconi','Italiano, Inglese, Francese, Spagnolo','Diploma','','Videogiochi, disegno','Attività fisica',NULL,'libero',NULL,NULL,'0','8','7',0,1,'Liceo Linguistico','Casalecchio di Reno','Italia','Andromeda','I Saw The TV Glow');
INSERT INTO dataset (id,nome,cognome,data_nascita,eta,anno_nascita,nazione_provenienza,citta_provenienza,citta_residenza,lingue_parlate,titolo_studio,professione,hobbies,attivita_non_piacciono,anni_ingresso_italia,stato_civile,anno_matrimonio,anni_in_italia,numero_fratelli_sorelle,numero_cugini,eta_imparato_nuotare,numero_figli,numero_animali_domestici,indirizzo_scuola_superiore,luogo_scuola_superiore,nazione_scuola_superiore,nomi_animali_domestici,film_preferito) VALUES
	 (21,'Hamza','El  Mahi','1993-08-09',30,'1993','Marocco','Casablanca','Bologna','ita,ing, arabo, francese','Laurea','Cuoco, Ragioniere','sport, lettura, studio','',1995,'libero',NULL,29,'2','troppi','5',NULL,NULL,'Istituto Superiore Tecnico','Bologna','Italia','','Il Gladiatore'),
	 (22,'Giulia','Marchesi','--',27,'1997','Italia','Bologna','Bologna','ita, ingl, spa (poco) –> 3','Diploma','Gdo, asssitente vendita','lettura, gaming, anime','cucinare',1997,'convivente',NULL,27,'0','14','4',0,1,'Liceo delle Scienze Umane','ancona','Italia','sunny',''),
	 (23,'Alessandro','Alvisi','1980-10-08',44,'1980','Italia','Castel San Pietro Terme','Imola','italiana,inglese','Laurea','Tecnico automazione
Help desk','sport, lettura,film','cucinare',NULL,'libero',NULL,44,'0','','6',0,0,'Istituto Superiore Tecnico','Imola','Italia','','Salvate il soldato Ryan'),
	 (24,'Jasser','Bougraira','--',19,'2005','Tunisia','Monastire','Bologna','Arabo, italiano','Licenza Media','Fabbro, metalmetccanico, imbianchino','Puglato, correre, stare al telefono','calcio ',2023,'libero',NULL,2,'2','troppi','5',NULL,NULL,'n.d','','n.d','','');

