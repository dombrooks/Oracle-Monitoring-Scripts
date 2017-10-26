WITH subq_snaps AS
(SELECT dbid                dbid
 ,      instance_number     inst
 ,      snap_id             e_snap
 ,      lag(snap_id) over (partition by instance_number, startup_time order by snap_id) b_snap
 ,      TO_CHAR(begin_interval_time,'D') b_day
 ,      TO_CHAR(begin_interval_time,'DD-MON-YYYY HH24:MI') b_time
 ,      TO_CHAR(end_interval_time,'HH24:MI')   e_time
 ,    ((extract(day    from (end_interval_time - begin_interval_time))*86400)
     + (extract(hour   from (end_interval_time - begin_interval_time))*3600)
     + (extract(minute from (end_interval_time - begin_interval_time))*60)
     + (extract(second from (end_interval_time - begin_interval_time)))) duration
 FROM   dba_hist_snapshot)
SELECT ss.inst
,      ss.b_snap
,      ss.e_snap
,      ss.b_time
,      ss.e_time
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END)/1000000/60,2),'999999990.99')                                  db_time
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END)/(ss.duration*1000000),1),'999999990.99')        aas
,      (SELECT round(average,2)
        FROM   dba_hist_sysmetric_summary sm
        WHERE  sm.dbid            = ss.dbid
        AND    sm.snap_id         = ss.e_snap
        AND    sm.instance_number = ss.inst
        AND    sm.metric_name     = 'Average Synchronous Single-Block Read Latency'
        AND    sm.group_id        = 2)                                                                                                                   assbl     
,      (SELECT round(average,2)
        FROM   dba_hist_sysmetric_summary sm
        WHERE  sm.dbid            = ss.dbid
        AND    sm.snap_id         = ss.e_snap
        AND    sm.instance_number = ss.inst
        AND    sm.metric_name     = 'Host CPU Utilization (%)'
        AND    sm.group_id        = 2)                                                                                                                   cpu_util
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'DB CPU' THEN em.value - bm.value END)/1000000,2),'999999990.99')                                      db_cpu
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'sql execute elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')                    sql_time
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'PL/SQL execution elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')               plsql_time
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'parse time elapsed' THEN em.value - bm.value END)/1000000,2),'999999990.00')                          parse_time
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'failed parse elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')                   failed_parse
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'hard parse (sharing criteria) elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')  hard_parse_sharing
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'RMAN cpu time (backup/restore)' THEN em.value - bm.value END)/1000000,2),'999999990.99')              rman_cpu
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'connection management call elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')     connection_mgmt
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'sequence load elapsed time' THEN em.value - bm.value END)/1000000,2),'999999990.99')                  sequence_load
,      TO_CHAR(ROUND(100*MAX(CASE WHEN bm.stat_name = 'DB CPU' THEN em.value - bm.value END) 
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           db_cpu_perc
,      TO_CHAR(ROUND(100*MAX(CASE WHEN bm.stat_name = 'sql execute elapsed time' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           sql_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'PL/SQL execution elapsed time' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           plsql_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'parse time elapsed' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           parse_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'failed parse elapsed time' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           failed_parse_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'hard parse (sharing criteria) elapsed time' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           hard_parse_sharing_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN bm.stat_name = 'RMAN cpu time (backup/restore)' THEN em.value - bm.value END)
           / NULLIF(MAX(CASE WHEN bm.stat_name = 'DB time' THEN em.value - bm.value END),0),2),'999999990.99')                                           rman_cpu_perc
FROM  subq_snaps              ss
,     dba_hist_sys_time_model em  
,     dba_hist_sys_time_model bm  
WHERE bm.dbid                   = ss.dbid
AND   bm.snap_id                = ss.b_snap  
AND   bm.instance_number        = ss.inst
AND   em.dbid                   = ss.dbid
AND   em.snap_id                = ss.e_snap
AND   em.instance_number        = ss.inst
AND   bm.stat_id                = em.stat_id  
GROUP BY 
       ss.dbid
,      ss.inst
,      ss.b_day
,      ss.b_snap
,      ss.e_snap
,      ss.b_time
,      ss.e_time
,      ss.duration
HAVING b_day NOT IN (6,7)
AND    inst = 2 
--AND b_snap = 18673
--AND    e_time = '17:00'
ORDER BY b_snap DESC;
