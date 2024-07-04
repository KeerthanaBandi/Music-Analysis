/* Q1: Who is the senior most employee based on job title? */
select first_name, last_name, levels
from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */
select billing_country, count(*) as total_invoices
from invoice
group by billing_country
order by total_invoices desc;

/* Q3: What are top 3 values of total invoice? */
select * 
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city, sum(total) as total
from invoice
group by billing_city
order by total desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select c.customer_id, c.first_name,c.last_name, sum(i.total) as total 
from invoice i join customer c on i.customer_id = c.customer_id
group by c.customer_id
order by total desc
limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select c.first_name, c.last_name, c.email, g.name
from customer c join invoice i
on c.customer_id = i.customer_id
join invoice_line il 
on i.invoice_id = il.invoice_id
join track t
on il.track_id = t.track_id
join genre g
on t.genre_id = g.genre_id 
where g.name = 'Rock'
order by c.email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.name, count(t.album_id) as total_track 
from track t
join album a on t.album_id = a.album_id
join artist ar on ar.artist_id = a.artist_id
join genre g on g.genre_id = t.genre_id
where g.name = 'Rock'
group by ar.name
order by total_track desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select t.name, t.milliseconds as song_length
from track t
where t.milliseconds > (select avg(t.milliseconds) from track t)
group by t.name,song_length
order by song_length desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


with best_selling_artist as
(select ar.artist_id as artistid, ar.name as artist_name, sum(il.unit_price*il.quantity)as total_spent
from artist ar join album a on ar.artist_id = a.artist_id
join track t on t.album_id = a.album_id
join invoice_line il on il.track_id = t.track_id
group by artistid, artist_name
order by 3 desc
limit 1)
select c.customer_id,c.first_name,c.last_name,bs.artist_name,sum(il.unit_price*il.quantity) as total_spent
from customer c join invoice i on c.customer_id = i.customer_id 
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join best_Selling_artist bs on bs.artistid = a.artist_id
group by 1,2,3,4
order by 5 desc ;

/* Q2: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where 
the maximum number of purchases is shared return all Genres. */

with cte as (
select i.billing_country as country, g.name as genre,
row_number() over(partition by i.billing_country order by count(g.name) desc) as row 
from invoice i 
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id 
group by country, genre
)
select * from cte where row = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with cte as (
select i.customer_id as cid, c.first_name, c.last_name, i.billing_country as country, sum(i.total) as total_spent,
row_number() over(partition by i.billing_country order by sum(total) desc) as row
from invoice i join customer c on c.customer_id = i.customer_id
group by 1,2,3,4 )
select * from cte where row = 1 ;

