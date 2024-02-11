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
	WHERE C.Date = '2023-01-15'
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
	WHERE N.Quantity >= 20 AND E.Name ILIKE '%yoga mat%'
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
WHERE C.Date > M.Quit_date


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
-- Explanation: 



-- F. Out of the members that have not quit, member with ID 6976 has been a customer for the shortest time. Out of the members that have not quit, return the ID of the member(s) that have been customer(s) for the longest time.
-- Explanation: 



-- G. How many class types have at least one equipment that costs more than 100.000 and at least one other equipment that costs less than 5.000?
-- Explanation: 



-- H. How many instructors have led a class in all gyms on the same day?
-- Explanation: 



-- I. How many instructors have not led classes of all different class types?
-- Explanation: 



-- J. The class type "Circuit training" has the lowest equipment cost per member, based on full capacity. Return the name of the class type that has the highest equipment cost per person, based on full capacity.
-- Explanation: 



-- K (BONUS). The hacker revealed in query C has left a message for the database engineers. This message may save the database!
-- Return the 5th letter of all members that started the gym on December 24th of any year and have at least 3 different odd numbers in their phone number, in a descending order of their IDs,
-- followed by the 8th letter of all instructors that have not led any "Trampoline Burn" classes, in an ascending order of their IDs.
-- Explanation: 

