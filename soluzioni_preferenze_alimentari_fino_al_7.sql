-- 2
SELECT COUNT (*)
FROM preferenze_alimentari_italia 
-- 3
SELECT COUNT(*)
FROM (SELECT DISTINCT * FROM preferenze_alimentari_italia)
-- 4
SELECT *
FROM preferenze_alimentari_italia
WHERE id =209

SELECT COUNT(*)
FROM preferenze_alimentari_italia
WHERE id =209
--5
SELECT DISTINCT *
FROM preferenze_alimentari_italia
WHERE id =209
--6
SELECT id, id % 10, id/10 
FROM preferenze_alimentari_italia	

SELECT *
FROM preferenze_alimentari_italia	
where id %10=0

SELECT *
FROM preferenze_alimentari_italia	
where MOD(id,10)=0

--7
SELECT 	id,
		data_nascita,
		SUBSTRING(data_nascita,7,4) AS anno,
		SUBSTRING(data_nascita,4,2) AS mese,
		SUBSTRING(data_nascita,1,2) AS giorno
FROM 
	preferenze_alimentari_italia;

SELECT id,
		data_nascita,
		strftime("%d",
		CONCAT(
			SUBSTR(data_nascita,7,4) ,'-', 
			SUBSTR(data_nascita,4,2),'-',
			SUBSTR(data_nascita,1,2))
		) as giorno,
		strftime("%m",
		CONCAT(
			SUBSTR(data_nascita,7,4) ,'-', 
			SUBSTR(data_nascita,4,2),'-',
			SUBSTR(data_nascita,1,2))
		) as mese,
		strftime("%Y",
		CONCAT(
			SUBSTR(data_nascita,7,4) ,'-', 
			SUBSTR(data_nascita,4,2),'-',
			SUBSTR(data_nascita,1,2))
		) as anno
FROM preferenze_alimentari_italia;


SELECT id,
		data_nascita,
		strftime("%d",
			SUBSTR(data_nascita,7,4) || '-' || 
			SUBSTR(data_nascita,4,2) || '-' ||
			SUBSTR(data_nascita,1,2)
		) as giorno,
		strftime("%m",
			SUBSTR(data_nascita,7,4) || '-' || 
			SUBSTR(data_nascita,4,2) || '-' ||
			SUBSTR(data_nascita,1,2)
		) as mese,
		strftime("%Y",
			SUBSTR(data_nascita,7,4) || '-' || 
			SUBSTR(data_nascita,4,2) || '-' ||
			SUBSTR(data_nascita,1,2)
		) as anno
FROM preferenze_alimentari_italia








