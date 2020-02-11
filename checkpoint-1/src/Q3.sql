select count(id), officer_on_duty from trr_trr
where EXTRACT(YEAR FROM trr_datetime) < 2015
group by officer_on_duty;

select count(id), officer_on_duty from trr_trr
where EXTRACT(YEAR FROM trr_datetime) >= 2015
group by officer_on_duty;

/*By street*/ 
select street, count(*) from trr_trr
where officer_on_duty = false AND EXTRACT(YEAR FROM trr_datetime) < 2015
group by street 
ORDER BY count(*) DESC;

select street, count(*) from trr_trr
where officer_on_duty = false AND EXTRACT(YEAR FROM trr_datetime) >= 2015
group by street 
ORDER BY count(*) DESC;

/*By rank*/ 
select officer_rank, count(*) from trr_trr
where officer_on_duty = false  AND EXTRACT(YEAR FROM trr_datetime) >= 2015
group by officer_rank 
ORDER BY count(*) DESC;

/*By beat ID*/ 
select beat, count(*) from trr_trr
where officer_on_duty = false AND EXTRACT(YEAR FROM trr_datetime) >= 2015
group by beat 
ORDER BY count(*) DESC;

select beat, count(*) from trr_trr
where officer_on_duty = false AND EXTRACT(YEAR FROM trr_datetime) < 2015
group by beat 
ORDER BY count(*) DESC;