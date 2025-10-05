

CREATE TABLE netflix_project (
  show_id VARCHAR(20) PRIMARY KEY,
  type VARCHAR(10),
  title VARCHAR(255),
  director TEXT,
  casts TEXT,
  country TEXT,
  date_added VARCHAR(50),
  release_year INT,
  rating VARCHAR(20),
  duration VARCHAR(50),
  listed_in TEXT,
  description TEXT
);


-- 1.type count
select type, count(*) as count from netflix_project group by type;

--2.highest no of rating
select type,rating  from(
select type,
rating ,
count(*),
   rank() over(partition by type order by count(*) desc ) as ranking
from netflix_project
group by 1,2
) as t1
where ranking =1;

--3. list all movies realeased in year 2020

select title from netflix_project
where 
	type='Movie'
	and
	release_year=2020;
	

--4.top 5 countries with most content

select 
unnest(string_to_array(country,',')) as new_country,
count(show_id) as total from netflix_project
group by 1
order by count(*) desc limit 5;


--5.identify longest movie

SELECT title, duration
FROM netflix_project
WHERE type = 'Movie' 
  AND duration IS NOT NULL
ORDER BY REPLACE(duration, ' min', '')  DESC
LIMIT 1;


--6.find content added in the last 5 years




select * from netflix_project
where
to_date(date_added,'month dd,yyyy')>=current_date-interval'5 years';


--7. all movies/tv shows directed by 'rajiv chilaka'

select 
type,title
from netflix_project
where director ilike '%Rajiv Chilaka%';

--like will not work if name is 'rajiv chilaka' because of case sensitive but ilike will 


--8.all tv shows with more than 5 seasons

select type,title,director ,duration from netflix_project
where 
	type = 'TV Show'
	and 
	split_part(duration,' ',1)::numeric >5


--9.count no of content in each genre



select 
unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total from netflix_project
group by 1
order by count(*) desc ;


--10.Find each year and the average numbers of content release in India on netflix.

-- select * from netflix_project;

select release_year,count(show_id)
from netflix_project
where country='India'
group by 1
order by 1 asc;

-- if we want  year in which it was added then

select 
extract(year from to_date(date_added,'Month dd,yyyy')) as year,
count(show_id) as total,
  round(count(show_id)::numeric/
  (select count(show_id) from netflix_project where country='India')*100::numeric,2) as average
from netflix_project
where country='India'
group by 1
order by average desc limit 5


--11.List All Movies that are Documentaries

select title from netflix_project
where type='Movie'
and listed_in ilike '%Documentaries%'


--12.Find All Content Without a Director

select* from netflix_project
where director is null;


--13. Find in How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select *  from netflix_project
where casts ilike '%salman khan%'
and release_year>extract(year from current_date)-10;



--14.Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select unnest(string_to_array(casts,',')) as actor,
  count(*) as total_movies from netflix_project
  where country='India'
  group by actor
  order by total_movies desc limit 10;



--15.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise.
--Count the number of items in each category.

select 
category,count(*)
from(
select
	case
       when description ilike '%Kill%' or description ilike '%Violence%' then 'bad'
	   else 'good'
	end as category
from netflix_project) as c_table
group by category


--one more way to do
-- new_table is the name of table you can use any other name too

with new_table
as(
select
	case
       when description ilike '%Kill%' 
	   or description ilike '%Violence%' then 'bad'
	   else 'good'
	end  category
from netflix_project
)
select category,count(*) from new_table
group by 1;


