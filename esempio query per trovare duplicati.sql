
--dammi i valori della colonna che hanno dei duplicati
select colonna_che_forse_ha_duplicati, 
	COUNT(colonna_che_forse_ha_duplicati)
	FROM tabella_con_colonna_con_forse_i_duplicati
	group by colonna_che_forse_ha_duplicati
	having COUNT(colonna_che_forse_ha_duplicati)>1

select  colonna_che_forse_ha_duplicati, 
	COUNT(colonna_che_forse_ha_duplicati)
	FROM tabella_con_colonna_con_forse_i_duplicati
	group by colonna_che_forse_ha_duplicati
	order by 
	COUNT(colonna_che_forse_ha_duplicati) asc
	