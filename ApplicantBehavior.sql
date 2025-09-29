create database applicantbehaviordb;
use applicantbehaviordb;
CREATE TABLE ApplicantBehavior (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Page VARCHAR(20),
    EventType VARCHAR(20),
    StepOrder INT,DurationSeconds INT,ConversionFlag INT,
    SessionID VARCHAR(20),
    Timestamp DATE,
    Source VARCHAR(20)
);

-- Insert 200 rows of synthetic data
INSERT INTO ApplicantBehavior (Page, EventType, StepOrder, DurationSeconds, ConversionFlag, SessionID, Timestamp, Source)
SELECT
    -- Page (5% chance NULL)
    CASE WHEN RAND() < 0.05 THEN NULL
         ELSE ELT(FLOOR(RAND()*5)+1, 'Home','JobList','JobDetail','ApplyForm','Confirmation')
    END,
    -- EventType (5% chance NULL)
    CASE WHEN RAND() < 0.05 THEN NULL
         ELSE ELT(FLOOR(RAND()*4)+1, 'PageView','ClickApply','FormSubmit','Exit')
    END,
    -- StepOrder 1-5
    FLOOR(RAND()*5)+1,
    -- DurationSeconds 5-120
    FLOOR(RAND()*116)+5,
    -- ConversionFlag 0 or 1
    FLOOR(RAND()*2),
    -- SessionID S001-S200
    CONCAT('S', LPAD(FLOOR(RAND()*1000), 4, '0')),
    -- Timestamp between 2024-09-27 and 2025-09-27
    DATE_ADD('2024-09-27', INTERVAL FLOOR(RAND()*366) DAY),
    -- Source (5% chance NULL)
    CASE WHEN RAND() < 0.05 THEN NULL
         ELSE ELT(FLOOR(RAND()*3)+1, 'Organic','Ads','Social')
    END
FROM
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) t1,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) t2;
