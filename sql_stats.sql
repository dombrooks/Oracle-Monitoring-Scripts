select sn.snap_id
,      to_char(sn.end_interval_time,'DD-MON-YYYY HH24:MI') dt
,      st.instance_number inst
,      st.sql_id
,      st.plan_hash_value
,      st.fetches_delta     fchs
,      rows_processed_delta rws
,      executions_delta     execs
,      elapsed_time_delta/1000/1000   elp
,      round(elapsed_time_delta/1000/1000/nvl(nullif(executions_delta,0),1),2)   elpe
,      cpu_time_delta/1000/1000       cpu
,      buffer_gets_delta    gets
,      iowait_delta/1000/1000         io
,      clwait_delta/1000/1000         cl
,      ccwait_delta/1000/1000         cc
,      apwait_delta/1000/1000         ap
,      plsexec_time_total/1000/1000   pl
,      round(disk_reads_delta)         disk_reads
,      round(direct_writes_delta)       direct_writes
from   dba_hist_snapshot sn
,      dba_hist_sqlstat  st
where  st.snap_id            = sn.snap_id
and    sn.instance_number = st.instance_number
and    st.sql_id             IN ('7vc631m2ayz8k')
order by sn.snap_id desc; 
