select count(*) over (partition by h.sample_time, h.instance_number) sess_cnt
--,      h.user_id
,      (select username from dba_users u where u.user_id = h.user_id) u
--, h.service_hash,      xid, sample_id
, to_char(sample_time,'DD-MON HH24:MI:SS') st, session_state, session_id, session_serial#,sql_id, sql_exec_id, sql_exec_start, event
--, p1, mod(p1,16)
, blocking_session,blocking_session_serial#
,      (select object_name from dba_procedures p where p.object_id = h.plsql_entry_object_id and rownum = 1)||'.'||
       (select procedure_name from dba_procedures p where p.object_id = h.plsql_entry_object_id and p.subprogram_id = h.plsql_entry_subprogram_id) prog1
,      (select object_name from dba_procedures p where p.object_id = h.plsql_object_id and rownum = 1)||'.'||
       (select procedure_name from dba_procedures p where p.object_id = h.plsql_object_id and p.subprogram_id = h.plsql_subprogram_id) prog2
--, current_obj#
,      (select object_name||' - '||subobject_name from dba_objects where object_id = current_obj#) obj
--,      (select sql_fulltext from v$sql s where s.sql_id = h.sql_id and rownum = 1) sqltxt
,      (select sql_text from dba_hist_sqltext s where s.sql_id = h.sql_id and rownum = 1) sqltxt
, h.*
from   dba_hist_active_sess_history h
,      dba_hist_snapshot            s
where  h.dbid            = s.dbid
and    h.snap_id         = s.snap_id
and    h.instance_number = s.instance_number
and    s.end_interval_time between to_date('08/09/2015 10:55','DD/MM/YYYY HH24:MI') and to_date('08/09/2015 14:05','DD/MM/YYYY HH24:MI')
and    h.sample_time       between to_date('08/09/2015 11:00','DD/MM/YYYY HH24:MI') and to_date('08/09/2015 13:20','DD/MM/YYYY HH24:MI')
order by h.sample_id;
