

-- Q1. Are there any trends or patterns in the frequency of hosting Olympic Games?

SELECT
    games_year,
    (games_year - LAG(games_year) OVER (ORDER BY games_year)) AS year_gap
FROM games
ORDER BY games_year;


-- Q2. How has the duration of Olympic Games changed over time?


SELECT
    games_year,
    (games_year - LAG(games_year) OVER (ORDER BY games_year)) AS year_gap
FROM games
ORDER BY games_year;



-- Q3. Are there any notable events or occurrences associated with specific Olympic Games?


SELECT
    g.games_year,
    g.games_name,
    COUNT(DISTINCT gc.person_id) AS total_participants
FROM games g
JOIN games_competitor gc
    ON g.id = gc.games_id
GROUP BY
    g.games_year, g.games_name;



-- 4. Are there any emerging sports that have been recently added to the Olympics?


SELECT
    g.games_year,
    g.games_name,
    s.sport_name,
    COUNT(DISTINCT gc.person_id) AS participants
FROM games g
JOIN games_competitor gc
    ON g.id = gc.games_id
JOIN competitor_event ce
    ON gc.id = ce.competitor_id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
GROUP BY
    g.games_year,
    g.games_name,
    s.sport_name
ORDER BY
    g.games_year,
    s.sport_name;



-- 5. How has the popularity of certain sports changed over the years?


SELECT
    g.games_year,
    g.games_name,
    s.sport_name,
    COUNT(DISTINCT gc.person_id) AS total_participants
FROM games g
JOIN games_competitor gc
    ON g.id = gc.games_id
JOIN competitor_event ce
    ON gc.id = ce.competitor_id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
GROUP BY
    g.games_year,
    g.games_name,
    s.sport_name
ORDER BY
    s.sport_name,
    g.games_year;


-- 6. Are there any sports that are specific to a particular region or culture?


SELECT
    s.sport_name,
    nr.region_name,
    COUNT(DISTINCT gc.person_id) AS total_participants
FROM sport s
JOIN event e
    ON s.id = e.sport_id
JOIN competitor_event ce
    ON e.id = ce.event_id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person p
    ON gc.person_id = p.id
JOIN person_region pr
    ON p.id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
GROUP BY
    s.sport_name,
    nr.region_name
ORDER BY
    s.sport_name,
    total_participants DESC;


-- 7. Are there any sports that have a higher number of events for one gender compared to others?


SELECT
    s.sport_name,
    p.gender,
    COUNT(DISTINCT e.id) AS total_events
FROM sport s
JOIN event e
    ON s.id = e.sport_id
JOIN competitor_event ce
    ON e.id = ce.event_id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person p
    ON gc.person_id = p.id
GROUP BY
    s.sport_name,
    p.gender
ORDER BY
    s.sport_name,
    total_events DESC;
	


-- 8. Are there any new events that have been introduced in recent editions of the Olympics?	


SELECT
    e.event_name,
    s.sport_name,
    MIN(g.games_year) AS first_olympic_year
FROM event e
JOIN sport s
    ON e.sport_id = s.id
JOIN competitor_event ce
    ON e.id = ce.event_id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN games g
    ON gc.games_id = g.id
GROUP BY
    e.event_name,
    s.sport_name
ORDER BY
    first_olympic_year DESC;


-- 9. Are there any events that have been discontinued or removed from the Olympics?


SELECT
    e.event_name,
    s.sport_name,
    MAX(g.games_year) AS last_olympic_year
FROM event e
JOIN sport s
    ON e.sport_id = s.id
JOIN competitor_event ce
    ON e.id = ce.event_id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN games g
    ON gc.games_id = g.id
GROUP BY
    e.event_name,
    s.sport_name
ORDER BY
    last_olympic_year;


-- 10. Are there any notable trends in the height and weight of participants over time?	


SELECT
    g.games_year,
    g.games_name,
    ROUND(AVG(p.height), 2) AS avg_height_cm,
    ROUND(AVG(p.weight), 2) AS avg_weight_kg
FROM games g
JOIN games_competitor gc
    ON g.id = gc.games_id
JOIN person p
    ON gc.person_id = p.id
WHERE p.height IS NOT NULL
  AND p.weight IS NOT NULL
GROUP BY
    g.games_year,
    g.games_name
ORDER BY
    g.games_year;



-- 11. Are there any dominant countries or regions in specific sports or events?


SELECT
    s.sport_name,
    nr.region_name,
    COUNT(*) AS total_medals
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    s.sport_name,
    nr.region_name
ORDER BY
    s.sport_name,
    total_medals DESC;



-- 12. What factors contribute to the success or performance of participants from different countries?


SELECT
    nr.region_name,
    COUNT(DISTINCT gc.person_id) AS total_participants,
    COUNT(*) FILTER (
        WHERE m.medal_name <> 'No medal'
    ) AS total_medals
FROM games_competitor gc
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
JOIN competitor_event ce
    ON gc.id = ce.competitor_id
JOIN medal m
    ON ce.medal_id = m.id
GROUP BY
    nr.region_name
ORDER BY
    total_medals DESC;


-- 13. Are there any countries that consistently perform well in multiple Olympic editions?


SELECT
    nr.region_name,
    COUNT(DISTINCT gc.games_id) AS olympic_editions,
    COUNT(*) FILTER (
        WHERE m.medal_name <> 'No medal'
    ) AS total_medals
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    nr.region_name
HAVING COUNT(DISTINCT gc.games_id) >= 5
ORDER BY
    olympic_editions DESC,
    total_medals DESC;



-- 14. Are there any sports or events that have a higher number of medalists from a specific region?


SELECT
    s.sport_name,
    nr.region_name,
    COUNT(*) AS total_medals
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    s.sport_name,
    nr.region_name
ORDER BY
    s.sport_name,
    total_medals DESC;



-- 15. What are some notable instances of unexpected or surprising medal wins?


SELECT
    nr.region_name,
    s.sport_name,
    COUNT(*) AS total_medals
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    nr.region_name,
    s.sport_name
ORDER BY
    total_medals ASC;



-- 16. Are there any regions that have experienced significant growth or decline in Olympic participation?


SELECT
    g.games_year,
    g.games_name,
    nr.region_name,
    COUNT(DISTINCT gc.person_id) AS total_participants
FROM games g
JOIN games_competitor gc
    ON g.id = gc.games_id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
GROUP BY
    g.games_year,
    g.games_name,
    nr.region_name
ORDER BY
    nr.region_name,
    g.games_year;



-- 17. How do cultural or geographical factors influence the performance of regions in specific sports?

	
SELECT
    nr.region_name,
    s.sport_name,
    COUNT(*) AS total_medals,
    COUNT(DISTINCT gc.person_id) AS medalists
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN event e
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    nr.region_name,
    s.sport_name
ORDER BY
    s.sport_name,
    total_medals DESC;


-- 18. Are there any regions that have had a notable impact on the overall medal tally?

	
SELECT
    nr.region_name,
    COUNT(*) AS total_medals
FROM competitor_event ce
JOIN medal m
    ON ce.medal_id = m.id
JOIN games_competitor gc
    ON ce.competitor_id = gc.id
JOIN person_region pr
    ON gc.person_id = pr.person_id
JOIN noc_region nr
    ON pr.region_id = nr.id
WHERE m.medal_name <> 'No medal'
GROUP BY
    nr.region_name
ORDER BY
    total_medals DESC;
	

