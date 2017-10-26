select sql_plan_line_id, sql_plan_operation, current_obj#, count(*), min(sample_time), max(sample_time)
,      (select object_name||' - '||subobject_name from dba_objects where object_id = current_obj#) obj
from   dba_hist_active_sess_history h
,      dba_hist_snapshot            s
where  h.dbid            = s.dbid
and    h.snap_id         = s.snap_id
and    h.instance_number = s.instance_number
and    s.end_interval_time between to_date('15/12/2015 00:00','DD/MM/YYYY HH24:MI') and to_date('16/12/2015 00:00','DD/MM/YYYY HH24:MI')
and    h.sample_time       between to_date('15/12/2015 00:00','DD/MM/YYYY HH24:MI') and to_date('16/12/2015 00:00','DD/MM/YYYY HH24:MI')
and    h.sql_id = 'cpuwsrbz9m96a' and h.sql_exec_id = 33554433
and    h.instance_number = 2
group by sql_plan_line_id, sql_plan_operation, current_obj#
order by sql_plan_line_id ;
