-- Applicant Behaviour Analysis --

select * from applicantbehaviordb.applicantbehavior;
												
-- uppercase "id" column to "ID" -- 
alter table applicantbehaviordb.applicantbehavior
rename column id  to ID;
#all columns are standardize to ,all columns values dtypes are correct,all columns values are in capitalize case.

-- check duplicates by "ID" column
select ID, row_number() over(partition by ID order by ID) as dup_count from applicantbehaviordb.applicantbehavior;
#no duplicate found

-- check duplicates by "ID, Page, EventType, StepOrder, DurationSeconds, ConversionFlag, SessionID, Timestamp, Source" column
select ID, Page, EventType, StepOrder, DurationSeconds, ConversionFlag, SessionID, Timestamp, Source,
 row_number() over(partition by ID, Page, EventType, StepOrder, DurationSeconds, ConversionFlag, SessionID, Timestamp, Source order by ID) as dup_count
 from applicantbehaviordb.applicantbehavior;
 #there is no duplicate found by grouping all columns.
 
 -- check null values --
 select count(*) as total_rows, sum(case when page is null then 1 else 0 end ) as page_count,
 sum(case when EventType is null then 1 else 0 end ) as event_count,
sum(case when StepOrder is null then 1 else 0 end ) as step_count,
sum(case when durationseconds is null then 1 else 0 end ) as duration_count,
sum(case when conversionflag is null then 1 else 0 end ) as conversion_count,
sum(case when sessionid is null then 1 else 0 end ) as session_count,
sum(case when timestamp is null then 1 else 0 end ) as timesatmp_count,
sum(case when source is null then 1 else 0 end ) as source_count
from applicantbehaviordb.applicantbehavior;
#page  have 9,eventtype have 5 and source have 3 null values.

-- Count row more than 1 null values --
select count(*) as r from applicantbehaviordb.applicantbehavior
where (case when page is null then 1 else 0 end +
case when EventType is null then 1 else 0 end +
case when StepOrder is null then 1 else 0 end +
case when durationseconds is null then 1 else 0 end +
case when conversionflag is null then 1 else 0 end +
case when sessionid is null then 1 else 0 end +
case when timestamp is null then 1 else 0 end  +
case when source is null then 1 else 0 end )is null >1;
#no row found 

-- Fill null values page column --
update applicantbehaviordb.applicantbehavior
set page = coalesce(page,null,"Unknown");

-- fill null values source column and eventtype column -- 
update applicantbehaviordb.applicantbehavior
set source = coalesce(source,null,"Unknown"),
eventtype = coalesce(eventtype,null,"Unknown");

-- check unique values --
select distinct(page) as page 
from applicantbehaviordb.applicantbehavior;
select distinct(eventtype) as event
from applicantbehaviordb.applicantbehavior;
select distinct(Source) as source
from applicantbehaviordb.applicantbehavior;

 -- check outliars --
 select min(steporder),max(steporder),min(durationseconds),max(DurationSeconds)
 from applicantbehaviordb.applicantbehavior;
 # no outlair found in steporser column range(1-5) and duratopnseconds column range(5-120)
 
-- Q1 Find the total number of sessions and unique applicants? --
select count(distinct(sessionid)) as total_session, count(distinct(id)) as applicant
from applicantbehaviordb.applicantbehavior;
# there are total 96 unique session in which 100 unique applicants are participated.

-- Q2 Find the number of applicants visits per page? -- 
select page,count((id)) as applicant 
from applicantbehaviordb.applicantbehavior
group by page
order by applicant desc;
#applyform has highest 24 applicant and conformation has lowest 14, 3 values are unknown.alter

-- Q3 Find the average time spent on each page? --
select page,round(avg(DurationSeconds),2) as avg_time
from applicantbehaviordb.applicantbehavior
group by page
order by avg_time desc;
# home page and conformation page have highest avg_time in seconds.

-- Q4 Count the total completed applications and total drop-offs? --
select id,ConversionFlag,count(ConversionFlag)  over(partition by conversionflag order by id) as count_applicants
from applicantbehaviordb.applicantbehavior;
# 48 applicants drop_offs and 52 applicants completed the applications.

-- Q5 Identify drop-off points (pages where applicants exited)? --
with cte as (
select page,steporder,conversionflag,count(*) over(partition by ConversionFlag,page,steporder) as applicant_exited
from applicantbehaviordb.applicantbehavior)
select page,steporder,applicant_exited
from cte
where conversionflag = 0;
# applyform has highest in step order 4 where 5 applicant exited.
# confirmation has highest 3 applicant who exited in steporder 1 and 4.
# Home page has highest 3 applicant who exited in steporder 3 and 4.
# job detail has highest 4 applicnat who exited in steporder 5.

-- Q6 Find the conversion rate by source (Organic, Ads, Social)? --
select source,(count(conversionflag)/100) * 100 as conversion_rate
from applicantbehaviordb.applicantbehavior
group by source;
# unknow source is 10 percent while organic have highest conversion rate 34%.

-- Q7 Count the number of sessions per month? --
select monthname(Timestamp),COUNT(SESSIONID) AS TOT_SESSIONS
from applicantbehaviordb.applicantbehavior GROUP BY monthname(TIMESTAMP) ORDER BY TOT_SESSIONS DESC;
# July has highest session 10 and january has 9 sessions.alter

-- Q8 Calculate the monthly conversion rate? --
with cte as(select * , monthname(timestamp) as m,year(Timestamp) as y from applicantbehaviordb.applicantbehavior),
cte1 as (select y,m,count(conversionflag) over (partition by y,m  order by y,m) as conversion_rate
from cte)
select *
from cte1
order by conversion_rate desc;
# may 2025 highest rate 14.
# june 2025 have 4 rate.