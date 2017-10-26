select count(*) over (partition by h.sample_time) sess_cnt
,      h.user_id
,      (select username from dba_users u where u.user_id = h.user_id) u, h.service_hash
,      xid, sample_id, sample_time, session_state, session_id, session_serial#,sql_id, sql_exec_id, sql_exec_start, event, p1, mod(p1,16), blocking_session,blocking_session_serial#, current_obj#
,      (select object_name||' - '||subobject_name from dba_objects where object_id = current_obj#) obj
--,      (select sql_fulltext from v$sql s where s.sql_id = h.sql_id and rownum = 1) sqltxt
,      (select sql_text from dba_hist_sqltext s where s.sql_id = h.sql_id and rownum = 1) sqltxt
, h.*
from   v$active_session_history h
order by h.sample_id desc;
