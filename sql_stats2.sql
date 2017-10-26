select trunc(sn.end_interval_time) dt
,      st.sql_id
,      sum(st.fetches_delta) fch
,      sum(rows_processed_delta) rws
,      sum(executions_delta)     execs
,      round(sum(elapsed_time_delta)/1000/1000)   elp
,      round(sum(elapsed_time_delta)/1000/1000/nvl(nullif(sum(executions_delta),0),1),2)   elpe
,      round(sum(cpu_time_delta)/1000/1000)       cpu
,      sum(buffer_gets_delta)    gets
,      round(sum(iowait_delta)/1000/1000)         io
,      round(sum(clwait_delta)/1000/1000)         cl
,      round(sum(ccwait_delta)/1000/1000)         cc
,      round(sum(apwait_delta)/1000/1000)         ap
,      round(sum(plsexec_time_total)/1000/1000)   pl
,      round(sum(disk_reads_delta))         disk_reads
,      round(sum(direct_writes_delta))        direct_writes
from   dba_hist_snapshot sn
,      dba_hist_sqlstat  st
where  st.snap_id            = sn.snap_id
and    sn.instance_number = st.instance_number
and    st.sql_id             IN ('drsgryg735xqu')
group by trunc(sn.end_interval_time), st.sql_id
order by trunc(sn.end_interval_time) desc, elp+cpu desc; 
