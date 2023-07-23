
1.	How many olympics games have been held?

select count(distinct(games)) as total_olympic_games
from olympics_history

2.	List down all Olympics games held so far.

select distinct(year), season, city
from olympics_history
order by year

3.	Mention the total no of nations who participated in each olympics game?

select games, count(distinct(region)) as total_countries
from olympics_history oh
join noc_regions nr on nr.noc = oh.noc
group by games
order by games

4.	Which year saw the highest and lowest no of countries participating in olympics?

with all_countries as
              (select games, count(distinct(nr.region)) as total_countries
              from olympics_history oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games)  
      select distinct
      concat(first_value(games) over(order by total_countries), ' - ',
      first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc), ' - ',
      first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from all_countries
      order by 1;

5.	Which nation has participated in all of the olympic games?

select region, count(distinct(games)) as total_participated_games
from olympics_history oh
join noc_regions nr on nr.noc = oh.noc
group by region
having count(distinct(games)) = (select count(distinct(games))
						from olympics_history)

6.	Identify the sport which was played in all summer olympics.

select sport, count(distinct(games)) as total_olympics
from olympics_history
where season = 'Summer'
group by sport
having count(distinct(games)) = (select count(distinct(games))
			from olympics_history where season = 'Summer')

7.	Which Sports were just played only once in the olympics?

select sport, count(distinct(games)) as total_participated_games
from olympics_history
group by sport
having count(distinct(games)) = 1

8.	Fetch the total no of sports played in each olympic games.

select games, count(distinct(sport)) as total_sports
from olympics_history
group by games
order by 1

9.	Fetch details of the oldest athletes to win a gold medal.

with temp as
(select name, sex, cast(case when age = 'NA' then '0' else age end as int) as age, team, games, city, sport, event, medal
            from olympics_history),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;

10.	Find the Ratio of male and female athletes participated in all olympic games.

with t1 as
(select sex, count(*) as cnt, row_number() over(order by sex) as rn
        	from olympics_history
        	group by sex),
        min_cnt as
        	(select cnt from t1	where rn = 1),
        max_cnt as
        	(select cnt from t1	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;

11.	Fetch the top 5 athletes who have won the most gold medals.

select name, team, count(medal) as total_gold_medal
from olympics_history
where medal = 'Gold'
group by name, team
order by total_gold_medal desc
limit 5

12.	Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select name, team, count(medal) as total_medal
from olympics_history
where medal in ('Gold','Silver','Bronze')
group by name, team
order by total_medal desc
limit 5

13.	Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select region, count(medal) as total_medal
from olympics_history oh
join noc_regions as nr on nr.noc = oh.noc
where medal in ('Gold','Silver','Bronze')
group by region
order by total_medal desc
limit 5

14.	In which Sport/event, India has won highest medals.

select team, sport, count(medal) as total_medal
from olympics_history 
where team = 'India' and medal in ('Gold','Silver','Bronze')
group by sport, team
order by total_medal desc
limit 1

15.	Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

select team, sport, games, count(medal) as total_medal
from olympics_history 
where team = 'India' and sport = 'Hockey' and medal in ('Gold','Silver','Bronze')
group by sport, team, games
order by total_medal desc
