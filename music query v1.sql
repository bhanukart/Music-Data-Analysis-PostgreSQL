-- Q1 Who is the most Senior employee based on title

SELECT employee_id,first_name,last_name, title,levels
FROM employee
ORDER BY levels desc
limit 1;


-- Q2 Which countries have the most invoices
SELECT billing_country, COUNT(*) as InvoiceCount
FROM invoice
GROUP BY billing_country
ORDER BY InvoiceCount desc;


-- Q3 What are the top 3 values of Total Invoices?
SELECT total
FROM invoice
ORDER BY total desc
limit 3;

-- Q4 Which City has the best Customers? Clients would like to arrange a
-- Music Festival in that city. Give city name and the total of invoices

SELECT billing_city, SUM(total) as InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal desc
LIMIT 1;

-- Return the best customer with highest spends

SELECT * FROM customer;
SELECT * FROM invoice;

SELECT c.first_name,c.last_name,SUM(i.total) as totalspent
FROM customer c
join invoice i ON c.customer_id = i.customer_id
group by c.customer_id
ORDER BY totalspent desc
LIMIT 1;

-- Alphabetically ordered details of Rock music listeners

SELECT DISTINCT c.email,c.first_name,c.last_name, g.name 
FROM customer c 
join invoice i ON c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t ON t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- OR

SELECT DISTINCT c.email,c.first_name,c.last_name
FROM customer c 
join invoice i ON c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
WHERE il.track_id IN (
			SELECT t.track_id FROM track t
			JOIN genre g on t.genre_id = g.genre_id
			WHERE g.name LIKE '%Rock%')
ORDER BY c.email;

-- Return Artist name of top 10 Rock music bands

SELECT artist.name,artist.artist_id,COUNT(artist.artist_id) as totalsongs
FROM track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE '%Rock%'
GROUP BY artist.artist_id, artist.name
ORDER BY totalsongs desc
LIMIT 10;

-- Track name and lengths of Tracks having length 
-- greater than the average length of all songs

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds desc;

-- Amount spent by earch customer on each artists

SELECT customer.first_name, artist.name,SUM(invoice_line.unit_price*invoice_line.quantity) as total
FROM invoice 
join customer ON customer.customer_id = invoice.customer_id
join invoice_line ON invoice_line.invoice_id = invoice.invoice_id
join track ON track.track_id = invoice_line.track_id
join album ON album.album_id = track.album_id
join artist ON artist.artist_id = album.artist_id
GROUP BY customer.customer_id, artist.name


-- Top genres countrywise
select * from invoice
SELECT invoice.billing_country, genre.name,SUM(invoice_line.unit_price*invoice_line.quantity) as price
,DENSE_RANK() OVER(PARTITION BY invoice.billing_country order by SUM(invoice_line.unit_price*invoice_line.quantity))
FROM invoice
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
GROUP BY billing_country,genre.name
ORDER BY billing_country ASC, price DESC

-- OR

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- Highest spending customer country wise

WITH data AS (
SELECT i.billing_country, c.first_name,c.last_name,SUM(i.total) as totalspent
,ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY i.billing_country, SUM(i.total) desc) AS RowNo
FROM invoice i
JOIN customer c on c.customer_id = i.customer_id
GROUP BY i.billing_country, c.first_name,c.last_name
Order BY totalspent desc)

SELECT * FROM data WHERE RowNo<=1

