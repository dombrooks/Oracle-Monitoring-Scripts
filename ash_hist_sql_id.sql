select trunc(sql_exec_start,'HH24') period, sql_id, sql_exec_id, sql_exec_start, count(*), min(sample_time), max(sample_time)
from   dba_hist_active_sess_history h
where  h.sql_id = 'cpuwsrbz9m96a'
group by trunc(sql_exec_start,'HH24'),sql_id, sql_exec_id, sql_exec_start
order by trunc(sql_exec_start,'HH24') desc, count(*) desc;
