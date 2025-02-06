/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT * 
FROM `Facilities` 
WHERE membercost != 0;

/* Q2: How many facilities do not charge a fee to members? */

5

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT * 
FROM `Facilities` 
WHERE membercost > 0
   AND membercost / monthlymaintenance < 0.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT *, 
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
    	 WHEN monthlymaintenance <= 100 THEN 'cheap'
	END AS expense_label
FROM `Facilities`;






/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT *
FROM `Members`
WHERE joindate = (SELECT MAX(joindate) FROM `Members`);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT Distinct
    b1.memid,
    b1.facid,
    m1.*,
    CASE 
        WHEN b1.facid = 0 THEN 'Tennis Court 1'
        WHEN b1.facid = 1 THEN 'Tennis Court 2'
    END AS facility_name
FROM Bookings AS b1
LEFT JOIN Members AS m1
    ON b1.memid = m1.memid
WHERE b1.facid IN (0, 1)

ORDER BY surname


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


WITH set1 AS (
    SELECT
        b1.slots,
        b1.starttime,
        b1.bookid,
        f1.*, 
        m1.*,
        CASE 
            WHEN DATE(b1.starttime) = '2012-09-14' AND m1.memid = 0 THEN f1.guestcost * b1.slots
            WHEN DATE(b1.starttime) = '2012-09-14' AND m1.memid > 0 THEN f1.membercost * b1.slots
        END AS cost
    FROM 
        Bookings AS b1
    INNER JOIN 
        Facilities AS f1 ON b1.facid = f1.facid
    INNER JOIN 
        Members AS m1 ON m1.memid = b1.memid
)
SELECT
    CONCAT(
        CASE 
            WHEN set1.memid = 0 THEN CONCAT(set1.name, ': ', set1.firstname, ' $', set1.cost)
            WHEN set1.memid > 0 THEN CONCAT(set1.name, ': ', set1.firstname, ' ', set1.surname, ' $', set1.cost)
        END
    ) AS Output
FROM set1 
WHERE set1.cost > 30
ORDER BY set1.cost DESC;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */



SELECT
    CONCAT(
        CASE 
            WHEN set1.memid = 0 THEN CONCAT(set1.name, ': ', set1.firstname, ' $', set1.cost)
            WHEN set1.memid > 0 THEN CONCAT(set1.name, ': ', set1.firstname, ' ', set1.surname, ' $', set1.cost)
        END
    ) AS Output
FROM (
    SELECT
        b1.slots,
        b1.starttime,
        b1.bookid,
        f1.*, 
        m1.*,
        CASE 
            WHEN DATE(b1.starttime) = '2012-09-14' AND m1.memid = 0 THEN f1.guestcost * b1.slots
            WHEN DATE(b1.starttime) = '2012-09-14' AND m1.memid > 0 THEN f1.membercost * b1.slots
        END AS cost
    FROM 
        Bookings AS b1
    INNER JOIN 
        Facilities AS f1 ON b1.facid = f1.facid
    INNER JOIN 
        Members AS m1 ON m1.memid = b1.memid
) AS set1
WHERE set1.cost > 30
ORDER BY set1.cost DESC;






/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

import sqlite3
import pandas as pd

connect4 = sqlite3.connect('sqlite_db_pythonsqlite.db')

query6 = '''
WITH set1 AS (
    SELECT 
        f1.name,
        m1.memid,
        CASE
            WHEN m1.memid = 0 THEN f1.guestcost * b1.slots
            WHEN m1.memid > 0 THEN f1.membercost * b1.slots
        END AS Revenue
    FROM 
        Bookings AS b1
    INNER JOIN 
        Facilities AS f1 ON b1.facid = f1.facid
    INNER JOIN 
        Members AS m1 ON m1.memid = b1.memid
)
SELECT 
    set1.name,
    SUM(CASE WHEN set1.memid = 0 THEN set1.Revenue ELSE 0 END) AS Guest_Revenue_by_Facility,
    SUM(CASE WHEN set1.memid > 0 THEN set1.Revenue ELSE 0 END) AS Member_Revenue_by_Facility,
    SUM(set1.Revenue) AS Total_Revenue_by_Facility
FROM 
    set1
GROUP BY 
    set1.name
HAVING 
    SUM(set1.Revenue) > 1000
ORDER BY 
    set1.name;

'''

df6 = pd.read_sql_query(query6, connect4)

connect4.close()

df6








/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

import sqlite3
import pandas as pd

connect = sqlite3.connect('sqlite_db_pythonsqlite.db')

query4 = '''
SELECT m1.surname, m1.firstname,
       m2.surname AS recommender_surname, m2.firstname AS recommender_firstname
FROM 'Members' AS m1
JOIN 'Members' AS m2 ON m1.recommendedby = m2.memid
WHERE m1.recommendedby != 0
ORDER BY recommender_surname, recommender_firstname;
'''

df3 = pd.read_sql_query(query4, connect)

connect.close()

df3


/* Q12: Find the facilities with their usage by member, but not guests */

import sqlite3
import pandas as pd

connect3 = sqlite3.connect('sqlite_db_pythonsqlite.db')

query5 = '''
SELECT 
	f1.name,
    m1.surname,
    m1.firstname,
    m1.memid,
    COUNT(m1.memid) AS Times_Used,
    SUM(b1.slots) AS Slots_Used
FROM 
    Bookings AS b1
INNER JOIN 
    Facilities AS f1 ON b1.facid = f1.facid
INNER JOIN 
    Members AS m1 ON m1.memid = b1.memid
WHERE m1.memid > 0
GROUP BY m1.memid, f1.name;
'''

df5 = pd.read_sql_query(query5, connect3)

connect3.close()

df5


/* Q13: Find the facilities usage by month, but not guests */

import sqlite3
import pandas as pd

connect2 = sqlite3.connect('sqlite_db_pythonsqlite.db')

query4 = '''
SELECT 
    f1.name,
    CASE 
        WHEN DATE(b1.starttime) LIKE '2012-09%' THEN 'September 2012'
        WHEN DATE(b1.starttime) LIKE '2012-08%' THEN 'August 2012'
        ELSE 'July 2012'
    END AS Usage_Month,
    COUNT(*) AS Times_Used_by_Month,
    SUM(b1.slots) AS Slots_Used_by_Month
FROM 
    Bookings AS b1
INNER JOIN 
    Facilities AS f1 ON b1.facid = f1.facid
GROUP BY 
    Usage_Month, f1.name
ORDER BY 
    Usage_Month, f1.name
'''

df4 = pd.read_sql_query(query4, connect2)

connect2.close()

df4






