 -- Question [https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset]
-- Identify the sport which was played in all summer olympics.

 With Total_Summer_game as (
Select 
	count ( distinct (Games)) Total_Summer_games
from	
	athlete_events
 where 
	Season='Summer' ),
 games_Sport as (
Select 
	distinct sport ,Games 
from
	athlete_events
  ),
 Count_Sport as (
Select 
	sport,count (games)as No_of_Games
from	
	games_Sport
group by
	sport
)
Select 
	* 
from 
	Count_Sport inner join Total_Summer_game
on
	Count_Sport.No_of_Games=Total_Summer_game.Total_Summer_games
	

--Fetch the top 5 athletes who have won the most gold medals.
	--1.Fetch athletes
	--2. where medals is gold
	--3. group by athletes
	--4. count medals 
	--5. select top 5
Create View  v_top_5_athletes_have_medal as
With Name_Medals_Gold_Count as (
Select 
	Name,COUNT (Medal)Count_Medal
from	
	athlete_events
where 
	Medal='gold'
group by
	Name

)

Select 
* 
From
	(Select 
			name ,
			Count_Medal, 
			dense_rank () over (order by Count_Medal desc)RN
		from 
				Name_Medals_Gold_Count
 )x
where 
	x.RN  <=5


---- List down total gold, silver and bronze medals won by each country.
--1. group country
	--where medals
	--column count
		--1	.gold 
		--2.silver
		--3.bronze
 --1 First Solution
Create View V_Gold_silver_bronze_medals_won_by_each_country
as
Select 
	distinct nr.region , 
		Sum (case when Medal ='Silver'then 1 else 0 end)Silver_Medals
		,
		Sum (case when Medal ='Bronze'then 1 else 0 end)Bronze_Medals
		,
		Sum (case when Medal ='Gold'then 1 else 0 end)Gold_Medals

from	
	noc_regions nr inner join athlete_events ah
	on ah.NOC=nr.noc
where
	Medal in ('Silver','Bronze','Gold')  
group by
	nr.region
	 

	-- 2 second Solution  Make a Solution Using Pivot Table

Select 
	* 
 from 
 (
	Select 
			nr.region,Medal
	from	
		noc_regions nr inner join athlete_events ah
		on ah.NOC=nr.noc
	where
		Medal in ('Silver','Bronze','Gold')  )as SourceData
	pivot (
	count(Medal)
	for 
		Medal in ([Silver],[Bronze],[Gold])
	)as PivotTable
order by 
	PivotTable.Silver desc ,PivotTable.Bronze desc , PivotTable.Gold desc

-- Identify which country won the most gold, most silver and most bronze medals
-- in each olympic games.

	--1. Group olympic games
	--2. get the gold , silver, bronze most in each olympic games
	--3. Lookup all CTE to Get the one table 
CREATE VIEW V_Gold_Silver_Bronze_top_in_each_Game AS
WITH Gold_Medal AS (
    SELECT 
        Games, 
        nr.region AS country,
        COUNT(Medal) AS gold,
        ROW_NUMBER() OVER (PARTITION BY Games ORDER BY COUNT(Medal) DESC) AS Rn
    FROM 
        noc_regions nr 
    INNER JOIN 
        athlete_events ah ON ah.NOC = nr.noc
    WHERE
        Medal = 'Gold'
    GROUP BY
        Games, nr.region
),
Silver_Medal AS (
    SELECT 
        Games, 
        nr.region AS country,
        COUNT(Medal) AS silver,
        ROW_NUMBER() OVER (PARTITION BY Games ORDER BY COUNT(Medal) DESC) AS Rn
    FROM 
        noc_regions nr 
    INNER JOIN 
        athlete_events ah ON ah.NOC = nr.noc
    WHERE
        Medal = 'Silver'
    GROUP BY
        Games, nr.region
),
Bronze_Medal AS (
    SELECT 
        Games, 
        nr.region AS country,
        COUNT(Medal) AS bronze,
        ROW_NUMBER() OVER (PARTITION BY Games ORDER BY COUNT(Medal) DESC) AS Rn
    FROM 
        noc_regions nr 
    INNER JOIN 
        athlete_events ah ON ah.NOC = nr.noc
    WHERE
        Medal = 'Bronze'
    GROUP BY
        Games, nr.region
)

SELECT
    g.games,
    g.country AS gold_country,
    g.gold,
    s.country AS silver_country,
    s.silver,
    b.country AS bronze_country,
    b.bronze
FROM 
    Gold_Medal g 
INNER JOIN 
    Silver_Medal s ON g.games = s.games
INNER JOIN 
    Bronze_Medal b ON b.games = s.games
WHERE
    g.Rn = 1 
    AND 
    s.Rn = 1
    AND
    b.Rn = 1;



--How many olympics games have been held?
Select
	count (distinct Games) [# Games]
from 
	athlete_events
 

--List down all Olympics games held so far.
Select 
	distinct (Games) 
from 
	athlete_events

--Mention the total no of nations who participated in each olympics game?
Select
	count (distinct Team)Team_Count
from	
	athlete_events


--Which year saw the highest and lowest no of countries participating in olympics?
Select 
	*
from
	athlete_events


--Which nation has participated in all of the olympic games?
With Team_and_Game as
( 
Select
	Distinct (noc.region)nation, Games
from	
	athlete_events ae inner join noc_regions noc
	on ae.NOC=noc.NOC
group by
	Games,noc.region

), 
Get_count_of_nation_in_all_games  as 
(
Select
	nation , count (nation)count_team 
from 
	Team_and_Game
group by
	nation
	)
Select 
	* 
from 
	Get_count_of_nation_in_all_games
where
	count_team in (Select count (distinct games)as Games_counts from athlete_events)


--Which year saw the highest and lowest no of countries participating in olympics?
With Region_Games as 
(
Select 
	distinct noc.region ,ae.Games 
from	
	athlete_events ae inner join noc_regions noc
on
	ae.NOC=noc.NOC
),
Games_count_region 
as (
Select 
	Games , count (region)region_Count
from	
	Region_Games
group by
	Games
)


Select 
	Distinct FIRST_VALUE (Games) over (order by region_Count desc ) Highest_Games
	,
		FIRST_VALUE (region_Count) over (order by region_Count desc ) Highest_Count_team

	,
	FIRST_VALUE (Games) over (order by region_Count asc ) Lowest_Games
	,
	FIRST_VALUE (region_Count) over (order by region_Count asc ) Lowest_Count_team


from 
	Games_count_region

-- Which Sports were just played only once in the olympics.
With SPORT_Games as (
Select 
	distinct Sport , Games
from	
	athlete_events
	)
,
Sport_and_Count as (

Select 
		 Sport ,  COUNT (Sport) sport_count
	from 
		SPORT_Games
group by
	Sport

)
		
Select 
	sc.sport , ae.Games,sc.sport_count 
from 
	Sport_and_Count sc inner join athlete_events ae
	on
	sc.Sport=ae.Sport
where 
	sport_count=1
	
--Fetch the total no of sports played in each olympic games.

Select 
	Games , Count (distinct Sport)Sport_count
from 
	athlete_events
group by
	Games

-- Fetch oldest athletes to win a gold medal

With Oldest_athlet
as (
Select 
	name , 
	sex, 
	height , 
	weight , 
	team , 
	games , 
	year , 
	season , 
	city , 
	sport, 
	cast ((case when age ='NA' then '0' else age end ) as int)age
from athlete_events
where 
	Medal='gold'
)
,
Rank_Data as (
Select 
	* , DENSE_RANK () over (order by age desc)as Rank
from 
	Oldest_athlet
 )
select 
	*
from 
	Rank_Data
where 
	rank =1

-- Fetch the top 5 athletes who have won the most gold medals.
With Rank_athletes_Gold_medal as 
(
Select
	name , noc.region, count(name)Medal_Count,dense_rank ()over (order by count(name)desc) RN
from 
	athlete_events ae inner join noc_regions noc
	on ae.NOc=noc.NOC
where
	Medal='gold'
group by
	name , noc.region
)
Select 
	*
from 
	Rank_athletes_Gold_medal
where	
	rn<=5

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

With Rank_athletes_medal as 
(
Select
	name , noc.region, count(Medal)Medal_Count,dense_rank ()over (order by count(Medal)desc) RN
from 
	athlete_events ae inner join noc_regions noc
	on ae.NOc=noc.NOC

group by
	name , noc.region
)
Select 
	*
from 
	Rank_athletes_medal
where	
	rn<=5



-



--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with top_countery as 
(
Select 
	noc.region  ,count (Medal)Medal_count, DENSE_RANK() over (order by count (Medal) desc)Rank
from	
	athlete_events ae inner join noc_regions noc
on
	ae.NOC=noc.noc
group by
	noc.region
)
select 
	*
from
	top_countery
where 
	rank <=5


--List down total gold, silver and bronze medals won by each country

Select * from 
(
SELECT 
    noc.region, 
    Medal
FROM
    athlete_events AS ae
INNER JOIN 
    noc_regions AS noc ON ae.NOC = noc.NOC
WHERE 
    ae.Medal <> 'NA')  Source
PIVOT 
    (COUNT(Medal) FOR Medal IN ([Gold], [bronze], [Silver])) AS pivot_table;


--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.


Select * from 
(
SELECT 
   Games, noc.region, 
    Medal 
FROM
    athlete_events AS ae
INNER JOIN 
    noc_regions AS noc ON ae.NOC = noc.NOC
WHERE 
    ae.Medal <> 'NA')  Source
PIVOT 
    (COUNT(Medal) FOR Medal IN ([Gold], [bronze], [Silver])) AS pivot_table;

--Which countries have never won gold medal but have won silver/bronze medals?

With meda_region as 
(
Select 
	ae.Medal , noc.region
from
		athlete_events ae inner join noc_regions noc
on
	ae.NOC=noc.NOC
where 
	Medal <>'NA'
) 
 
Select 
	* 
from
	meda_region 
pivot (count (medal) for medal in ([Gold],[Silver],[Bronze]))as pivotT
where
	[Gold]=0
	and
	[Silver]<>0
	and
	[Bronze]<>0

--In which Sport/event, Egypt has won highest medals.
With Egypt_sport_and_medal as
(
Select 
	noc.region 
	, Sport 
	, count (medal)medal 
	, ROW_NUMBER () over (order by  count (medal) desc)Rn
from 
	athlete_events  ae inner join noc_regions noc
on
	ae.NOC=noc.NOC
where 
	noc.region like '%egypt%'
group by
	noc.region , Sport
)
Select 
	*
from
	Egypt_sport_and_medal
where
		rn=1