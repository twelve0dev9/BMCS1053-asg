-- Interactive query for organizations with looping control

SET VERIFY OFF
SET LINESIZE 100
SET PAGESIZE 1000

ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy';

TTITLE CENTER 'Query out organizations by participation status, participation type, & organization types'
TTITLE CENTER '-------------------------------------------------------------------------------------------------' SKIP 2

-- Show participation types
PROMPT
PROMPT Participation Type:
PROMPT 1 = Invited (participate by invited by us)
PROMPT 2 = Applying (participate by applying for it)
PROMPT 0 = All
ACCEPT p_type NUMBER PROMPT 'Enter participation type (0--2): '

-- Show statuses' options
PROMPT
PROMPT Status:
PROMPT 1 = Accepted
PROMPT 2 = Declined
PROMPT 3 = Pending
PROMPT 0 = All
ACCEPT p_status NUMBER PROMPT 'Enter participation status (0--3): '

-- Show types of organization to choose
PROMPT
PROMPT Which types of organization would you like to view?
PROMPT 1 = Exhibitor
PROMPT 2 = Sponsor
PROMPT 3 = Universities
PROMPT 4 = Marketing Firm
PROMPT 5 = Consultancy Agency
PROMPT 6 = F&B Provider
PROMPT 0 = All
ACCEPT o_orgtype NUMBER PROMPT 'Enter choice (0--6): '

-- Define column formatting
COL Org_Name HEADING "Organization Name"
COL ParticipateBy FORMAT A20 HEADING "Participated By"
COL Status FORMAT A10 HEADING "Status"

-- Query to display organizations based on chosen filters
SELECT DISTINCT 
    o.OrgID, 
    o.Org_Name, 
    p.ParticipateBy, 
    p.Status
FROM Organizations o
JOIN Participations p 
    ON p.OrgID = o.OrgID
WHERE 
    (
        (&p_type = 0) OR
        (&p_type = 1 AND p.ParticipateBy = 'Invited') OR
        (&p_type = 2 AND p.ParticipateBy = 'Applying')
    ) 
    AND
    (
        (&p_status = 0) OR
        (&p_status = 1 AND p.Status = 'Accepted') OR
        (&p_status = 2 AND p.Status = 'Declined') OR 
        (&p_status = 3 AND p.Status = 'Pending')
    )
    AND 
    (
        (&o_orgtype = 0) OR 
        (&o_orgtype = 1 AND REGEXP_LIKE(o.OrgID, '^E')) OR
        (&o_orgtype = 2 AND REGEXP_LIKE(o.OrgID, '^S')) OR
        (&o_orgtype = 3 AND REGEXP_LIKE(o.OrgID, '^U')) OR
        (&o_orgtype = 4 AND REGEXP_LIKE(o.OrgID, '^M')) OR
        (&o_orgtype = 5 AND REGEXP_LIKE(o.OrgID, '^CA')) OR
        (&o_orgtype = 6 AND REGEXP_LIKE(o.OrgID, '^F'))
    )
ORDER BY p.status, p.ParticipateBy, o.orgid;

-- Ask to continue
ACCEPT exit_flag CHAR PROMPT 'Would you like to continue? (Y = Yes | N = No): '

-- Decide next step (loop or stop)
COLUMN cont NEW_VALUE cont_flag
SELECT CASE WHEN UPPER('&exit_flag') = 'Y' 
            THEN 'org_query' 
            ELSE 'stop' 
       END cont
FROM dual;

-- Jump
