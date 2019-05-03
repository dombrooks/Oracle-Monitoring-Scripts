select x.*, (select sql_text from dba_hist_sqltext t where t.sql_id = x.sql_id and rownum = 1) txt
from (
select sn.snap_id
,      to_char(sn.end_interval_time,'DD-MON-YYYY HH24:MI') dt
,      st.sql_id
, st.sql_profile
,      st.instance_number inst
,      st.parsing_schema_name psn
,      st.plan_hash_value phv
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
,      round(sum(plsexec_time_delta)/1000/1000)   pl
,      round(sum(disk_reads_delta))         disk_reads
,      round(sum(direct_writes_delta))        direct_writes
,      row_number() over (partition by sn.snap_id, st.instance_number
                          order by sum(elapsed_time_delta) desc) rn
from   dba_hist_snapshot sn
,      dba_hist_sqlstat  st
where  st.snap_id            = sn.snap_id
and    sn.instance_number = st.instance_number
--and    sn.instance_number = 2
and    to_char(sn.end_interval_time,'D') not in (6,7)
--and    to_char(sn.end_interval_time,'HH24') >= 19
--and    st.sql_id = '7vc631m2ayz8k'
group by 
       sn.snap_id
,      sn.end_interval_time
,      st.sql_id, st.sql_profile
,      st.instance_number
,      st.parsing_schema_name
,      st.plan_hash_value
) x
where rn <= 10
order by snap_id desc, rn;
