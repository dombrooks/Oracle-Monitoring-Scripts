select snap_id, instance_number
,      begin_time
,      end_time
,      max(case when metric_name = 'Host CPU Utilization (%)' then round(average,2) end) cpu_util
,      max(case when metric_name = 'Average Synchronous Single-Block Read Latency' then round(average,2) end) single_block_ms
from   dba_hist_sysmetric_summary
where  to_char(end_time,'D') not in (6,7)
and    metric_name    in ('Host CPU Utilization (%)','Average Synchronous Single-Block Read Latency')
--and    instance_number =2
group by snap_id
,      instance_number
,      begin_time
,      end_time
order by snap_id desc;
