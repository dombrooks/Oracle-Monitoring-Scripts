select max(case when metric_name = 'Host CPU Utilization (%)' then round(average,2) end) cpu_util
,      max(case when metric_name = 'Average Synchronous Single-Block Read Latency' then round(average,2) end) single_block_ms
from   v$sysmetric_summary
where  metric_name    in ('Host CPU Utilization (%)','Average Synchronous Single-Block Read Latency');
