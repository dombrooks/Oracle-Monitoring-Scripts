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
,    io_stats AS
     (SELECT ss.*
     ,      bv.event_name
     ,      ev.time_waited_micro_fg - bv.time_waited_micro_fg time_waited_micro
     ,      ev.total_waits_fg       - bv.total_waits_fg       waits
     FROM   subq_snaps            ss
     ,      dba_hist_system_event bv
     ,      dba_hist_system_event ev
     WHERE  bv.dbid                   = ss.dbid
     AND    bv.snap_id                = ss.b_snap  
     AND    bv.instance_number        = ss.inst
     AND    bv.event_name            IN ('db file sequential read','direct path read','direct path read temp','db file scattered read','db file parallel read')
     AND    ev.dbid                   = ss.dbid
     AND    ev.snap_id                = ss.e_snap
     AND    ev.instance_number        = ss.inst
     AND    ev.event_id               = bv.event_id)
,   time_model AS
    (SELECT ss.*
     ,      bm.stat_name
     ,      em.value - bm.value value
     FROM   subq_snaps              ss
     ,      dba_hist_sys_time_model em  
     ,      dba_hist_sys_time_model bm  
     WHERE bm.dbid                   = ss.dbid
     AND   bm.snap_id                = ss.b_snap  
     AND   bm.instance_number        = ss.inst
     AND   em.dbid                   = ss.dbid
     AND   em.snap_id                = ss.e_snap
     AND   em.instance_number        = ss.inst
     AND   bm.stat_id                = em.stat_id)
SELECT ss.inst
,      ss.b_snap
,      ss.e_snap
,      ss.b_time
,      ss.e_time
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END)/1000000/60,2),'999999990.99')                   db_time
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END)/(ss.duration*1000000),1),'999999990.99')        aas
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
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'DB CPU' THEN tm.value END)/1000000,2),'999999990.99')                                      db_cpu
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'sql execute elapsed time' THEN tm.value END)/1000000,2),'999999990.99')                    sql_time
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'PL/SQL execution elapsed time' THEN tm.value END)/1000000,2),'999999990.99')               plsql_time
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'parse time elapsed' THEN tm.value END)/1000000,2),'999999990.00')                          parse_time
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'failed parse elapsed time' THEN tm.value END)/1000000,2),'999999990.99')                   failed_parse
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'hard parse (sharing criteria) elapsed time' THEN tm.value END)/1000000,2),'999999990.99')  hard_parse_sharing
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'RMAN cpu time (backup/restore)' THEN tm.value END)/1000000,2),'999999990.99')              rman_cpu
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'connection management call elapsed time' THEN tm.value END)/1000000,2),'999999990.99')     connection_mgmt
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'sequence load elapsed time' THEN tm.value END)/1000000,2),'999999990.99')                  sequence_load
,      TO_CHAR(ROUND(100*MAX(CASE WHEN tm.stat_name = 'DB CPU' THEN tm.value END) 
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                           db_cpu_perc
,      TO_CHAR(ROUND(100*MAX(CASE WHEN tm.stat_name = 'sql execute elapsed time' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                           sql_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'PL/SQL execution elapsed time' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                           plsql_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'parse time elapsed' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                parse_time_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'failed parse elapsed time' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                failed_parse_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'hard parse (sharing criteria) elapsed time' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                hard_parse_sharing_perc
,      TO_CHAR(ROUND(MAX(CASE WHEN tm.stat_name = 'RMAN cpu time (backup/restore)' THEN tm.value END)
           / NULLIF(MAX(CASE WHEN tm.stat_name = 'DB time' THEN tm.value END),0),2),'999999990.99')                                rman_cpu_perc
,      MAX(CASE WHEN event_name = 'db file sequential read' THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END) END) single_waits
,      MAX(CASE WHEN event_name = 'db file scattered read'  THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END) END) multi_waits
,      MAX(CASE WHEN event_name = 'db file parallel read'   THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END) END) prefch_wait
,      MAX(CASE WHEN event_name = 'direct path read'        THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits  END) END) direct_waits
,      MAX(CASE WHEN event_name = 'direct path read temp'   THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END) END)  temp_waits
,      MAX(CASE WHEN event_name = 'db file sequential read' THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END/ss.duration) END) iops_single
,      MAX(CASE WHEN event_name = 'db file sequential read' THEN ROUND(CASE WHEN time_waited_micro/1000/1000 < 0 THEN NULL ELSE time_waited_micro/1000/1000 END) END) single_secs_total
,      MAX(CASE WHEN event_name = 'db file sequential read' THEN ROUND((time_waited_micro/1000)/NULLif(waits,0)) END) single_avg
,      MAX(CASE WHEN event_name = 'db file scattered read'  THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END/ss.duration) END) iops_multi
,      MAX(CASE WHEN event_name = 'db file scattered read'  THEN ROUND(CASE WHEN time_waited_micro/1000/1000 < 0 THEN NULL ELSE time_waited_micro/1000/1000 END) END) multi_secs_total
,      MAX(CASE WHEN event_name = 'db file scattered read'  THEN ROUND((time_waited_micro/1000)/NULLif(waits,0)) END) multi_avg
,      MAX(CASE WHEN event_name = 'db file parallel read'   THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END/ss.duration) END) iops_prefch
,      MAX(CASE WHEN event_name = 'db file parallel read'   THEN ROUND(CASE WHEN time_waited_micro/1000/1000 < 0 THEN NULL ELSE time_waited_micro/1000/1000 END) END) prefch_secs_total
,      MAX(CASE WHEN event_name = 'db file parallel read'   THEN ROUND((time_waited_micro/1000)/NULLif(waits,0)) END) prefch_avg
,      MAX(CASE WHEN event_name = 'direct path read'        THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits  END/ss.duration) END) iops_direct
,      MAX(CASE WHEN event_name = 'direct path read'        THEN ROUND(CASE WHEN time_waited_micro/1000/1000 < 0 THEN NULL ELSE time_waited_micro/1000/1000 END) END) direct_secs_total
,      MAX(CASE WHEN event_name = 'direct path read'        THEN ROUND((time_waited_micro/1000)/NULLif(waits,0)) END) direct_avg
,      MAX(CASE WHEN event_name = 'direct path read temp'   THEN ROUND(CASE WHEN waits < 0 THEN NULL ELSE waits END/ss.duration) END) iops_temp
,      MAX(CASE WHEN event_name = 'direct path read temp'   THEN ROUND(CASE WHEN time_waited_micro/1000/1000 < 0 THEN NULL ELSE time_waited_micro/1000/1000 END) END) temp_secs_total
,      MAX(CASE WHEN event_name = 'direct path read temp'   THEN ROUND((time_waited_micro/1000)/NULLif(waits,0)) END) temp_avg
FROM  subq_snaps       ss
LEFT JOIN time_model   tm
ON   (tm.dbid        = ss.dbid
AND   tm.b_snap      = ss.b_snap  
AND   tm.inst        = ss.inst)
LEFT JOIN io_stats     io
ON   (io.dbid        = ss.dbid
AND   io.b_snap      = ss.b_snap  
AND   io.inst        = ss.inst)
GROUP BY 
       ss.dbid
,      ss.inst
,      ss.b_day
,      ss.b_snap
,      ss.e_snap
,      ss.b_time
,      ss.e_time
,      ss.duration
HAVING ss.b_day NOT IN (6,7)
--AND    inst = 2 
--AND b_snap = 18673
--AND    e_time = '17:00'
ORDER BY ss.b_snap DESC NULLS LAST;
