select sql_id, sql_exec_id, sql_exec_start, count(*), min(sample_time), max(sample_time)
from   dba_hist_active_sess_history h
,      dba_hist_snapshot            s
where  h.dbid            = s.dbid
and    h.snap_id         = s.snap_id
and    h.instance_number = s.instance_number
--and   h.instance_number = 2
--and    h.user_id = 342
and    h.sql_id = 'ga1k0tn5ncx9c'
and    s.end_interval_time between to_date('29/09/2015 17:00','DD/MM/YYYY HH24:MI') and to_date('29/09/2015 20:00','DD/MM/YYYY HH24:MI')
and    h.sample_time between to_date('29/09/2015 17:00','DD/MM/YYYY HH24:MI') and to_date('29/09/2015 20:00','DD/MM/YYYY HH24:MI')
group by sql_id, sql_exec_id, sql_exec_start
order by count(*) desc;
