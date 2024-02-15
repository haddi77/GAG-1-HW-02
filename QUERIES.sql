-- HW2
-- Student names: Haddi

-- A. 447 different members attended at least one class on January 10th. How many different members attended at least one class on January 15th?
-- Explanation: We select distinct MID (member id's) from attends table, joining it to the class table in order to be able to
-- use where to filter on class Date, the whole thing is wrapped in select count to get the count

SELECT COUNT(*)
FROM (
	SELECT DISTINCT A.MID
	FROM Attends A
	JOIN Class C
		ON A.CID = C.ID
	WHERE EXTRACT(DAY FROM C.Date) = 15 AND EXTRACT(MONTH FROM C.Date) = 1
) tmp;

-- B. 4 different class types require more than 20 light dumbbells. How many class types require more than 20 yoga mats?
-- Explanation: We select from Type table , joining needs table on type id to get the equipment that each class type needs along with
-- the quantity and also we join equipment table to be able to filter by equipment name (using ILIKE and wildcards)
-- we also filter on the quantity needed and finally wrap the whole thing in a count select


SELECT COUNT(*)
FROM (
	SELECT T.ID
	FROM Type T
	JOIN Needs N
		ON T.ID = N.TID
	JOIN Equipment E
		ON E.ID = N.EID
	WHERE N.Quantity > 20 AND E.Name ILIKE '%yoga mat%'
) tmp;


-- C. Oh no! Some member hacked the database and is still attending classes but has quit according to the database. Write a query to reveal their name!
-- Explanation: We use select distinct on the name column of the Member table, but also join the attends table on member id and the class table on the
-- class id from the attends table, in order to be able to compare the class date of the classed the members have attended to the quit_date of the member
-- if there were multiple members doing this this query would return a list of them

SELECT DISTINCT M.Name
FROM Member M
JOIN Attends A
	ON M.ID = A.MID
JOIN Class C
	ON A.CID = C.ID
WHERE C.Date > M.Quit_date;


-- D. How many members have a personal trainer with the same first name as themselves, but have never attended a class that their personal trainer led?
-- Explanation: We select distinct members and join instructors table, comparing with substring if the first name is the same
-- we also compare if said members are NOT IN a subquery that finds members that have attended classes led by their own personal trainer
-- finally it's all wrapped in a count

SELECT COUNT(*)
FROM (
	SELECT DISTINCT M.ID
	FROM Member M
	JOIN Instructor I
		ON M.IID = I.ID
	WHERE SUBSTRING(M.Name, 0, POSITION(' ' IN M.Name)) = SUBSTRING(I.Name, 0, POSITION(' ' IN I.Name))
	AND M.ID NOT IN (
		SELECT DISTINCT M.ID
		FROM Member M
		JOIN Instructor I
			ON M.IID = I.ID
		JOIN Attends A
			ON M.ID = A.MID
		JOIN Class C
			ON A.CID = C.ID
		WHERE C.IID = M.IID
	)
);


-- E. For every class type, return its name and whether it has an average rating higher or equal to 7, or lower than 7, in a column named "Rating" with values "Good" or "Bad", respectively.
-- Explanation: We select from Type table the name of each class table, we join class table and attends table to get the ratings, group by type id and then use AVG to get the average rating
-- for each type of class, however since we wan't not the actual rating but good or bad we but a CASE WHEN in the select to output Good when rating is greater than or equal to 7 and bad for
-- ratings less than 7, we Put the word 'Rating' after the end keyword of the CASE statement to name the output column

Select T.Name,
	CASE
		WHEN AVG(A.Rating) >= 7 THEN
		'Good'
		ELSE 'Bad'
	END Rating
FROM Type T
JOIN Class C
	ON T.ID = C.TID
JOIN Attends A
	ON C.ID = A.CID
GROUP BY T.ID;

-- F. Out of the members that have not quit, member with ID 6976 has been a customer for the shortest time. Out of the members that have not quit, return the ID of the member(s) that have been customer(s) for the longest time.
-- Explanation: We select the maximum among new - start_date from members table to get the longest memberships, we then use that as a subquery and select members that have membership length equal to the maximum and also have not quit

SELECT M.ID
FROM Member M
WHERE M.quit_date IS NULL
AND NOW() - M.start_date IN (
	SELECT MAX(NOW() - M.start_date)
	FROM Member M
);

-- G. How many class types have at least one equipment that costs more than 100.000 and at least one other equipment that costs less than 5.000?
-- Explanation: We select from the type table joining needs on type id and then equipment on eqpuiment id from needs, we group by type id and
-- filter with having so we get only class types that have equipment with price less than 5000 and with equipoment costin more than 100.000
-- finally we wrap the whole thing in a count select, also, it's crossfit

SELECT COUNT(*)
FROM (
	SELECT T.ID
	FROM Type T
	JOIN Needs N
		ON N.TID = T.ID
	JOIN Equipment E
		ON E.ID = N.EID
	GROUP BY T.ID
	HAVING MIN(E.Price) < 5000 AND MAX(E.Price) > 100000
) tmp;

-- H. How many instructors have led a class in all gyms on the same day?
-- Explanation: We select from Class table, grouping by both instructor id and Date, thus getting one row for each 
-- instructor on each day, we filter these results with having count of distinct gym id equal to count distinct 
-- gym id in the gym table (counting the total rows), we wrap this in a select count(*) to find out no one has
-- achieved this feat, however quite a few have held classes in all but one gym on the same date

SELECT COUNT(*)
FROM (
	SELECT C.IID
	FROM Class C
	GROUP BY C.IID, C.Date
	HAVING COUNT(DISTINCT C.GID) = (
		SELECT COUNT(DISTINCT G.ID)
		FROM Gym G
	)
) tmp;

-- I. How many instructors have not led classes of all different class types?
-- Explanation: We create a list of id's of instructors that have tought all types of classes, similarly to the previous on
-- by grouping class table on instructor id having count distinct type id equal to count distinct type id from type table
-- we then use this result as a subquery when selecting from all instructor checking that we only select those that are not
-- in the previous list, finally the whole thing is wrapped with a select count(*)

SELECT COUNT(*)
FROM (
    SELECT I.ID
    FROM Instructor I
    WHERE I.ID NOT IN (
        SELECT C.IID
        FROM Class C
        GROUP BY C.IID
        HAVING COUNT(DISTINCT C.TID) = (
            SELECT COUNT(DISTINCT T.ID)
            FROM Type T
        )
    )
) tmp;

-- J. The class type "Circuit training" has the lowest equipment cost per member, based on full capacity. Return the name of the class type that has the highest equipment cost per person, based on full capacity.
-- Explanation: Starting from the innermost subquery we select the Type table joining the needs table on type id and the equipment table on equipment id, we group by type and use the sum aggreate function to sum
-- cost per person for the class type ( Needs.Quantity * Equipment.Price / ClassType.Capacity), this select is then wrapped in a select max(*) to get the highest value of cost per person
-- finally this is wrapped in another query which is almost identical to the innermost query except it selects Type Name, HAVING cos per person equal to the max value given by the two subqueries

SELECT T.Name
FROM Type T
JOIN Needs N
    ON N.TID = T.ID
JOIN Equipment E
    ON E.ID = N.EID
GROUP BY T.ID
HAVING SUM(N.Quantity * E.Price / T.Capacity) = (
    SELECT MAX(priceper)
    FROM (
        SELECT SUM(N.Quantity * E.Price / T.Capacity) AS priceper
        FROM Type T
        JOIN Needs N
            ON N.TID = T.ID
        JOIN Equipment E
            ON E.ID = N.EID
        GROUP BY T.ID
    )
);

-- K (BONUS). The hacker revealed in query C has left a message for the database engineers. This message may save the database!
-- Return the 5th letter of all members that started the gym on December 24th of any year and have at least 3 different odd numbers in their phone number, in a descending order of their IDs,
-- followed by the 8th letter of all instructors that have not led any "Trampoline Burn" classes, in an ascending order of their IDs.
-- Explanation: 

SELECT STRING_AGG(Character, '')
FROM (
    SELECT *
    FROM (
        SELECT SUBSTRING(M.Name, 5, 1) AS Character
        FROM Member M
        WHERE EXTRACT(MONTH FROM M.start_date) = 12 AND EXTRACT(DAY FROM M.start_date) = 24
        AND M.ID IN (
            SELECT M.ID
            FROM (
                SELECT M.ID, COUNT(DISTINCT M.Digit)
                FROM (
                    SELECT M.ID, UNNEST(STRING_TO_ARRAY(CAST(M.Phone AS VARCHAR), NULL)) AS Digit
                    FROM Member M
                ) AS M
                WHERE CAST(Digit AS INTEGER) % 2 != 0
                GROUP BY M.ID
            ) AS M
            WHERE M.Count >= 3
        )
        ORDER BY M.ID DESC
    ) AS MEMBERLETTERS
    UNION ALL
    SELECT *
    FROM (
        SELECT SUBSTRING(I.Name, 8, 1) AS Character
        FROM Instructor I
        WHERE I.ID NOT IN (
            SELECT DISTINCT I.ID
            FROM Instructor I
            JOIN Class C
                ON C.IID = I.ID
            JOIN Type T
                ON T.ID = C.TID
            WHERE T.Name ILIKE '%Trampoline Burn%'
        )
        ORDER BY I.ID ASC
    ) AS INSTRUCTORLETTERS
);