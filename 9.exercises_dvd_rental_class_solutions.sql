--1. Scrivere una query per elencare il titolo del film, il nome e cognome del cliente, e la data di noleggio per tutti i noleggi effettuati nel 2005.

select film_id, Count (*) as c  from film_category 
group by film_id 
having COUNT(category_id) > 1
order by film_id;

select * from rental r where extract ('year' from rental_date)=2005
and return_date is NULL;

select * from film
join inventory on film.film_id=inventory.film_id 

select extract (year from rental_date) from rental r
--  tabelle: film, customer, rental
-- altre tabelle inventory 
select first_name, last_name, title,rental_date from film join inventory on inventory.film_id=film.film_id
join rental on rental.inventory_id = inventory.inventory_id
join customer on rental.customer_id = customer.customer_id
where extract ('year' from rental_date)=2005
order by rental_date asc

select  count (*) from film join inventory on inventory.film_id=film.film_id
join rental on rental.inventory_id = inventory.inventory_id
join customer on rental.customer_id = customer.customer_id
where extract ('year' from rental_date)=2005



--1. Scrivere una query per elencare il titolo del film, il nome e cognome del cliente, e la data di noleggio per tutti i noleggi effettuati nel 2005.


--  allora dobbiamo usare i seguenti operatori come select join e  where, ovviamente l'anno si usera luguale


--2. Scrivere una query per mostrare ogni cliente con il conteggio totale dei suoi noleggi, assicurandosi che il
-- risultato sia 0 per chi non ha mai noleggiato.

---le tabelle che ci servono: customer (ci servono id e nome e cognome)
select COUNT (*), rental.customer_id  from rental
join customer on customer.customer_id = rental.customer_id
group by rental.customer_id; 

select COUNT (*), customer_id  from rental
group by customer_id
order by COUNT (*) ASC; 

--se fai come segue non c'e' errore perche' individui anche tutti i rental NULL:
select * from rental r 
right join customer on r.customer_id = customer.customer_id
where r.customer_id is NULL;

select * from customer c 
LEFT join rental on c.customer_id = rental.customer_id
where rental.customer_id is NULL;

select count(*), c.customer_id, first_name, last_name from customer c 
LEFT join rental on c.customer_id = rental.customer_id
group by c.customer_id;

--3. Scrivere una query per elencare tutte le categorie con i film associati, includendo anche le categorie che non
--hanno alcun film.

select * 
from category cat
left join film_category fc on cat.category_id = fc.category_id;

-- tiriamo fuori anche i nomi dei film associati alle categorie

select  cat.category_id, f.title as film_title,  cat.name as category_name, f.film_id 
from category cat
left join film_category fc on cat.category_id = fc.category_id
join film f  on f.film_id = fc.film_id 



-- categorie senza film
select * 
from category cat
left join film_category fc on cat.category_id = fc.category_id
where fc.category_id is null

--4. Scrivere una query per identificare gli ID di inventario che sono presenti nella tabella inventory ma non nella
--tabella rental .
-- RIFRASATA
--4. Scrivere una query per identificare i valori della chiave (id) di inventario che sono presenti nella tabella inventory ma non nella tabella rental .

select i.inventory_id 
from inventory i
left join rental r on i.inventory_id = r.inventory_id
except
select i.inventory_id 
from inventory i 
join rental r on i.inventory_id = r.inventory_id

select i.inventory_id
from inventory i
left join rental r on i.inventory_id = r.inventory_id
except
	select r.inventory_id from rental r
	
select i.inventory_id
from inventory i
except
	select r.inventory_id from rental r

select i.inventory_id
from inventory i
left join rental r on i.inventory_id = r.inventory_id
where r.inventory_id is null

select i.inventory_id
from inventory i
left join rental r on i.inventory_id = r.inventory_id
where r.inventory_id is null

select *
from inventory i
left join rental r on i.inventory_id = r.inventory_id
where i.inventory_id = 5

select * from inventory i
where inventory_id not in (
				select inventory_id from rental);

--5. Scrivere una query per generare tutte le possibili combinazioni tra i paesi dei clienti e le lingue dei
--film.



--6. Scrivere una query per trovare le coppie di film che condividono almeno un attore.

select distinct f1.film_id as film1_id,
f2.film_id as film2_id,
f1.title as titolo_1,
f2.title as titolo_2
from film f1 
join film_actor fa1 on f1.film_id =fa1.film_id 
join film f2 on f1.film_id!=f2.film_id
join film_actor fa2 on f2.film_id=fa2.film_id
where fa1.actor_id=fa2.actor_id
order by film1_id,film2_id;




select f1.film_id as film1_id,
f2.film_id as film2_id,
f1.title as titolo_1,
f2.title as titolo_2,
fa1.actor_id as attore_1,
fa2.actor_id as attore_2
from film f1 
join film_actor fa1 on f1.film_id =fa1.film_id 
join film f2 on f1.film_id!=f2.film_id
join film_actor fa2 on f2.film_id=fa2.film_id
where fa1.actor_id=fa2.actor_id
order by film1_id,film2_id;


-- primo step

select f1.film_id as film1_id,
f1.title as titolo_1,
fa1.actor_id as attore_1
from (select * from film order by film_id limit 2) f1
join film_actor fa1 on f1.film_id =fa1.film_id 


select f1.film_id as film1_id,
f1.title as titolo_1,
fa1.actor_id as attore_1,
f2.film_id as film2_id,
f2.title as titolo_2,
fa2.actor_id as attore_2
from (select * from film order by film_id limit 2) f1
join film_actor fa1 on f1.film_id =fa1.film_id 
join (select * from film order by film_id limit 2) f2
-- f1.film_id = f2.film_id sto combinando le righe della f1 con quelle della f2 dove la colonna film_id su f1 e f2 ha lo stesso valore
-- f1.film_id != f2.film_id sto combinando le righe della f1 con quelle della f2 dove la colonna film_id su f1 e f2 non ha lo stesso valore quindi, sto combinando i film con tutti gli altri film
on f1.film_id != f2.film_id
join film_actor fa2 on f2.film_id=fa2.film_id
order by film1_id,titolo_1;


select f1.film_id as film1_id,
f1.title as titolo_1,
fa1.actor_id as attore_1,
f2.film_id as film2_id,
f2.title as titolo_2,
fa2.actor_id as attore_2
from (select * from film order by film_id limit 2) f1
join film_actor fa1 on f1.film_id =fa1.film_id 
join (select * from film order by film_id limit 2) f2
-- f1.film_id = f2.film_id sto combinando le righe della f1 con quelle della f2 dove la colonna film_id su f1 e f2 ha lo stesso valore
-- f1.film_id != f2.film_id sto combinando le righe della f1 con quelle della f2 dove la colonna film_id su f1 e f2 non ha lo stesso valore quindi, sto combinando i film con tutti gli altri film
on f1.film_id != f2.film_id
join film_actor fa2 on f2.film_id=fa2.film_id
where fa1.actor_id = fa2.actor_id
order by film1_id,titolo_1;

-- 6bis troviamo i film con almeno due attori in comune
select f1.film_id as film1_id,
f2.film_id as film2_id,
f1.title as titolo_1,
f2.title as titolo_2,
group_concat(fa1.actor_id::text)as attori_in_comune ,
count(*) as numero_attori_in_comune
from film f1 
join film_actor fa1 on f1.film_id =fa1.film_id 
join film f2 on f1.film_id!=f2.film_id
join film_actor fa2 on f2.film_id=fa2.film_id
where fa1.actor_id=fa2.actor_id
group by film1_id,film2_id
having count(*)>3
order by film1_id,film2_id;



SELECT version();

--7. Scrivere una query per restituire, per ogni cliente, la singola riga che corrisponde al suo primo noleggio in
--assoluto.

select min(rental_date) from  rental;

select rental_date from rental
order by rental_date asc limit 1;

select customer_id, min(rental_date) as primo_noleggio from rental
group by customer_id;

select * from
(select 
		rental_id,
		customer_id, 
		rental_date,
		row_number() over(
			partition by customer_id
			order by rental_date asc) as ordine 
from rental)
where ordine=1;

----
--Non si puo fare
select customer_id,
	inventory_id,
	rental_date,
	min(rental_date) as primo_noleggio 
from rental
group by customer_id,inventory_id,rental_id
order by customer_id asc;

select 
	rental_id, 
	rental_date::text::timestamp ,--faccio questa cosa perch'e dbeaver non capisce il tipo della colonna e sbaglia a visualizzare il risultato della query
	customer_id, 
	inventory_id--customer_id,rental_date::timestamp,inventory_id 
from
(select 
		rental_id,
		customer_id, 
		rental.rental_date,
		rental.inventory_id,
		row_number() over(
			partition by customer_id
			order by rental_date asc) as ordine 
from rental)
where ordine=1;

select customer_id, count(*) from (
	select 1 as customer_id, 1 as inventory_id, 3 as value
	union
	select 1 as customer_id, 2 as inventory_id, 4 as value
	union
	select 2 as customer_id, 1 as inventory_id, 5 as value
) group by customer_id 

select inventory_id, count(*) from (
	select 1 as customer_id, 1 as inventory_id, 3 as value
	union
	select 1 as customer_id, 2 as inventory_id, 4 as value
	union
	select 2 as customer_id, 1 as inventory_id, 5 as value
) group by inventory_id

select customer_id,inventory_id, count(*) from (
	select 1 as customer_id, 1 as inventory_id, 3 as value
	union
	select 1 as customer_id, 2 as inventory_id, 4 as value
	union
	select 2 as customer_id, 1 as inventory_id, 5 as value
) group by customer_id,inventory_id

select inventory_id,customer_id, count(*) from (
	select 1 as customer_id, 1 as inventory_id, 3 as value
	union
	select 1 as customer_id, 2 as inventory_id, 4 as value
	union
	select 2 as customer_id, 1 as inventory_id, 5 as value
) group by inventory_id,customer_id


create table gruppiamo_cose as 
select 1 as customer_id, 1 as inventory_id, 3 as value
	union
	select 1 as customer_id, 2 as inventory_id, 4 as value
	union
	select 2 as customer_id, 1 as inventory_id, 5 as value
	union
	select 2 as customer_id, 1 as inventory_id, 7 as value
	union
	select 5 as customer_id, 2 as inventory_id, 7 as value
	union
	select 12 as customer_id, 2 as inventory_id, 7 as value;

select * from gruppiamo_cose
order by customer_id, inventory_id

select count(*)
from (
	select distinct customer_id
	from gruppiamo_cose
) BIDONI

select customer_id, sum(value)
from gruppiamo_cose
group by customer_id

select count(*)
from (
	select distinct inventory_id
	from gruppiamo_cose
) BIDONI

select inventory_id, sum(value)
from gruppiamo_cose
group by inventory_id

select count(*)
from (
	select distinct inventory_id
	from gruppiamo_cose
) BIDONI

select inventory_id, customer_id
from gruppiamo_cose
group by inventory_id

-- quella che voleva Johanny
select customer_id,inventory_id
from gruppiamo_cose
order by  inventory_id asc,customer_id asc

select customer_id,inventory_id
from gruppiamo_cose
order by customer_id asc, inventory_id asc

--8. Scrivere una query per classificare i clienti per fatturato totale e mostrare la posizione di ognuno nella classifica generale.



select *, row_number () over (order by total_fatturato desc)as classifica
from 
(select customer_id, SUM (amount) as total_fatturato
from payment
group by customer_id)as t
order by total_fatturato desc;

select count (*), count(distinct total_fatturato) 
from 
(select customer_id, SUM (amount) as total_fatturato
from payment
group by customer_id)as t;

select *, dense_rank () over (order by total_fatturato desc)as classifica
from 
(select customer_id, SUM (amount) as total_fatturato
from payment
group by customer_id)as t
order by total_fatturato desc;
--9. Scrivere una query per visualizzare, per ciascun film, il numero progressivo di noleggi ordinati per data.

--10. Scrivere una query per **selezionare** i clienti che hanno generato un fatturato totale superiore a 100 dollari.
--
--11. Scrivere una query per **aggregare** gli incassi per categoria di film e mostrare anche il totale complessivo.
--
--12. Scrivere una query per **confrontare** il fatturato di ogni film con la media del fatturato della sua categoria.
--
--13. Scrivere una query per **mostrare** per ogni cliente il numero di noleggi per anno, includendo gli anni senza noleggi.
--
--14. Scrivere una query per **individuare** i clienti che hanno noleggiato film di almeno 3 categorie diverse.

select c.customer_id, f.film_id, count(distinct fc.category_id) 
from customer c
join rental r
on r.customer_id = c.customer_id
join inventory i
on r.inventory_id = i.inventory_id
join film f
on f.film_id = i.film_id
join film_category fc 
on fc.film_id = f.film_id 
group by c.customer_id,  f.film_id
having count(distinct fc.category_id) > 2
order by c.customer_id, f.film_id; 

select * from film_category fc 
join category c
on fc.category_id = c.category_id
where film_id = 228;

--15. Scrivere una query per **calcolare** per ogni cliente la spesa totale, il numero di noleggi e la spesa media per noleggio.
--
--16. Scrivere una query per **identificare** i film che non sono stati mai noleggiati.
--
--
--17. Scrivere una query per **calcolare** il fatturato per negozio e classificare i negozi dal più al meno redditizio.
--
--8. Scrivere una query per **calcolare** per ogni giorno il totale degli incassi e confrontarlo con il giorno precedente.  **(*N.B.* usa una window function e la funzione LAG)**
--
--19. Scrivere una query per **mostrare** l'andamento mensile degli incassi con la differenza percentuale rispetto al mese precedente. **(*N.B.*  usa una window function e la funzione LAG)**
--
--
--20. Scrivere una query per **calcolare** la media mobile degli incassi giornalieri su una finestra di 3 giorni. 
--**(*N.B.* usa una window function e la funzione ROWS BETWEEN )**


-- come funziona concat e la pipe
select 'a';
select 'a' as uno, 'b' as due, 'c' tre;

select concat('a','b','c');

select 'a'||'b'||'c';

select 'a'||''||'c';

select concat('a',' ','c');

select 'a'||NULL||'c';

select concat('a',NULL,'c');

select 'Marco' as nome, 'Rubiero' as cognome
union 
select 'Alessio', 'Pedrotti'
union 
select 'Giuditta', 'Coffari';

select * from 
(select 'Marco' as nome, 'Rubiero' as cognome
union 
select 'Giuditta', 'Coffari');

select concat(nome, cognome) from 
(select NULL as nome, 'Rubiero' as cognome
union 
select 'Giuditta', 'Coffari');

select nome|| cognome from 
(select NULL as nome, 'Rubiero' as cognome
union 
select 'Giuditta', 'Coffari');

select 'a' = 'b';

select 
case 
	when 'a' = 'a' or 'a' = 'A' then 'vero' 
	when 'a' = 'a' then 'case insensitive'
		else 'case sensitive'
end;
