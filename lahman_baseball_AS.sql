-- 1. What range of years for baseball games played does the provided database cover? 
SELECT *
FROM pitching
ORDER BY yearid ASC
--Answer: 1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT namefirst, namelast, teamid, height
FROM people
LEFT JOIN batting
USING (playerid)
WHERE playerid= 'gaedeed01'
ORDER by height ASC
--Eddie Gaedel: 43inches games played= 1, team= SLA

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT schoolname, namefirst, namelast, SUM(salary)AS sal
FROM schools
LEFT JOIN collegeplaying AS c
USING (schoolid)
LEFT JOIN people AS p
ON c.playerid=p.playerid
LEFT JOIN salaries AS s
ON p.playerid=s.playerid
WHERE schoolname = 'Vanderbilt University' 
GROUP BY schools.schoolname, p.namefirst, p.namelast
ORDER BY sal DESC
--David Price

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT
CASE WHEN pos = 'OF' THEN 'Outfield'
WHEN pos = 'SS' THEN 'Infield'
WHEN pos= '1B' THEN 'Infield'
WHEN pos= '2B' THEN 'Infield'
WHEN pos= '3B' THEN 'Infield'
WHEN pos= 'P' THEN 'Battery'
WHEN pos= 'C' THEN 'Battery'
END AS position, SUM(po)
FROM fielding
WHERE yearid= '2016'
GROUP BY position
   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '20s'
WHEN yearid BETWEEN 1930 AND 1939 THEN '30s'
WHEN yearid BETWEEN 1940 AND 1949 THEN '40s'
WHEN yearid BETWEEN 1950 AND 1959 THEN '50s'
WHEN yearid BETWEEN 1960 AND 1969 THEN '60s'
WHEN yearid BETWEEN 1970 AND 1979 THEN '70s'
WHEN yearid BETWEEN 1980 AND 1989 THEN '80s'
WHEN yearid BETWEEN 1990 AND 1999 THEN '90s'
WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
END AS decade, ROUND(AVG(so/g),2) AS so, CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '20s'
WHEN yearid BETWEEN 1930 AND 1939 THEN '30s'
WHEN yearid BETWEEN 1940 AND 1949 THEN '40s'
WHEN yearid BETWEEN 1950 AND 1959 THEN '50s'
WHEN yearid BETWEEN 1960 AND 1969 THEN '60s'
WHEN yearid BETWEEN 1970 AND 1979 THEN '70s'
WHEN yearid BETWEEN 1980 AND 1989 THEN '80s'
WHEN yearid BETWEEN 1990 AND 1999 THEN '90s'
WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
END AS decade, ROUND(AVG(hr/g),2) AS hr
FROM teams
GROUP BY decade
ORDER BY decade DESC
--There are much more strikeouts. SO and HR seem to get higher averages the higher the decade

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT playerid, namefirst, namelast, (sb*100)/sum(sb+cs) AS sbs
FROM batting
LEFT JOIN people
using (playerid)
Where (sb+cs)>= 20 AND yearid= 2016
GROUP BY batting.playerid, people.namefirst, people.namelast, batting.sb
ORDER BY sbs DESC
--Chris Owings


-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

with cte AS (SELECT yearid, (max(w))AS maxw
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND yearid NOT IN (1981)
GROUP BY yearid
ORDER BY yearid DESC),

cte2 AS (Select teamid, yearid, w, wswin
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016 AND yearid NOT IN (1981)
		ORDER BY w desc)
SELECT
SUM(CASE WHEN wswin= 'Y' THEN 1 ELSE 0 END) AS total_wins,
COUNT(DISTINCT cte.yearid), 
ROUND(SUM(CASE WHEN wswin= 'Y' THEN 1 ELSE 0 END)/COUNT(DISTINCT cte.yearid)::numeric, 2)*100
FROM cte2
LEFT JOIN cte
ON cte.yearid=cte2.yearid AND cte2.w=cte.maxw
WHERE cte.maxw IS NOT NULL


--116 most wins without winning the world series, 63 least amount of wins by world series winner, 26% of the time


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT team, p.park_name, AVG(attendance/games) AS avg_atten
FROM homegames as h
INNER JOIN parks as p
USING (park)
WHERE year= 2016 AND games>=10
GROUP BY team, p.park_name
ORDER BY avg_atten DESC
limit 5

SELECT team, p.park_name, AVG(attendance/games) AS avg_atten
FROM homegames as h
INNER JOIN parks as p
USING (park)
WHERE year= 2016 AND games>=10
GROUP BY team, p.park_name
ORDER BY avg_atten ASC
limit 5

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
--Final Code
SELECT Distinct namefirst, namelast, m.teamid
FROM awardsmanagers AS a
JOIN awardsmanagers AS am
USING (playerid)
INNER JOIN people AS p
USING (playerid)
INNER JOIN managers AS m
USING (playerid) 
WHERE a.awardid = 'TSN Manager of the Year' and am.awardid = 'TSN Manager of the Year' and ((am.lgid = 'AL' AND a.lgid = 'NL') OR (am.lgid = 'NL' AND a.lgid = 'AL')) AND m.yearid=a.yearid
----Jim Leyland (Detroit, Pittsburgh) and Davey Johnson (Baltimore, Washington)

with cte as (SELECT awardsmanagers.playerid as p, awardid, awardsmanagers.lgid, teamid, namefirst, namelast, managers.yearid as y
FROM awardsmanagers
INNER JOIN managers
USING (lgid)
INNER JOIN people
ON awardsmanagers.playerid= people.playerid
WHERE awardid= 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'),

ctee AS (SELECT awardsmanagers.playerid as p, awardid, awardsmanagers.lgid, teamid, namefirst, namelast, managers.yearid as y
FROM awardsmanagers
INNER JOIN managers
USING (lgid)
INNER JOIN people
ON awardsmanagers.playerid= people.playerid
WHERE awardid= 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL')

SELECT ctee.namefirst, ctee.namelast, ctee.teamid
FROM ctee
INNER JOIN cte
ON ctee.p=cte.p AND ctee.y=cte.y

with cte as (SELECT awardsmanagers.playerid, awardid, awardsmanagers.lgid, teamid, managers.yearid as y
FROM awardsmanagers
INNER JOIN managers
USING (lgid)
WHERE awardid= 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'),

ctee AS (SELECT playerid, awardid, lgid, namefirst, namelast, managers.yearid as y
FROM awardsmanagers
INNER JOIN people
USING (playerid)
WHERE awardid= 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL')

SELECT namefirst, namelast, teamid
FROM ctee
INNER JOIN cte
ON ctee.playerid=cte.playerid AND ctee.yearid=cte.yearid


SELECT Distinct namefirst, namelast, m.teamid
FROM awardsmanagers AS a
JOIN awardsmanagers AS am
USING (playerid)
INNER JOIN people AS p
USING (playerid)
INNER JOIN managers AS m
USING (playerid) 
WHERE a.awardid = 'TSN Manager of the Year' and am.awardid = 'TSN Manager of the Year' and ((am.lgid = 'AL' AND a.lgid = 'NL') OR (am.lgid = 'NL' AND a.lgid = 'AL')) AND m.yearid=a.yearid

SELECT *
FROM managers
FULL OUTER JOIN cte
ON cte.lgid = managers.lgid AND managersid= cte.lgid


INNER JOIN people
on am.playerid=people.playerid and a.playerid=people.playerid
INNER JOIN managers
on am.playerid = managers.playerid and a.playerid=managers.playerid


SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' and lgid= 'AL'

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  