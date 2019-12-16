/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT *
FROM country_club.Facilities
WHERE membercost > 0.0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM country_club.Facilities
WHERE membercost = 0.0

4 of them = Badminton Court, Table Tennis, Snooker Table, and Pool Table

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, 
       name, 
       membercost, 
       monthlymaintenance,
       CASE WHEN membercost < monthlymaintenance *20 /100 THEN "yes"
       ELSE "no" END AS "Membercost is less than 20% of Monthlymaintenancecost"
FROM country_club.Facilities


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities AS Facilities
RIGHT JOIN country_club.Bookings AS Bookings ON Facilities.facid = Bookings.facid
WHERE Facilities.facid =1
UNION
SELECT *
FROM country_club.Facilities AS Facilities
RIGHT JOIN country_club.Bookings AS Bookings ON Facilities.facid = Bookings.facid
WHERE Bookings.facid =5


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS 'COST'
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname, 
	   firstname, 
	   MAX(joindate) AS joindate
FROM country_club.Members
ORDER BY joindate DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT firstname, surname, name
FROM country_club.Members
INNER JOIN country_club.Bookings ON Members.memid = Bookings.memid
INNER JOIN country_club.Facilities ON Bookings.facid = Facilities.facid
WHERE Bookings.facid
IN ( 0, 1 )
ORDER BY 3



/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS facility, CONCAT(Members.firstname,  ' ', Members.surname ) AS name, 
CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots END AS cost
FROM country_club.Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
AND Bookings.starttime LIKE  '2012-09-14%'
AND ((Bookings.memid =0) AND (Facilities.guestcost * Bookings.slots >30))
OR ((Bookings.memid !=0) AND (Facilities.membercost * Bookings.slots >30))
INNER JOIN Members ON Bookings.memid = Members.memid
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT *
FROM(
SELECT Facilities.name AS facility, CONCAT(Members.firstname,  ' ', Members.surname) AS name, 
CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots END AS cost
FROM country_club.Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
AND Bookings.starttime LIKE  '2012-09-14%'
INNER JOIN Members ON Bookings.memid = Members.memid
) subq
WHERE subq.cost > 30
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT * 
FROM (
SELECT subq.facility, SUM( subq.cost ) AS total_revenue
FROM (
SELECT Facilities.name AS facility, 
CASE WHEN Bookings.memid =0
THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END AS cost
FROM country_club.Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
INNER JOIN Members ON Bookings.memid = Members.memid
)sub
GROUP BY subq.facility
)subq2
WHERE subq2.total_revenue <1000
