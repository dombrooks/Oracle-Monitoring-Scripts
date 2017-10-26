select s.machine
,      tx.start_time txn_start_time 
,      tx.xid
,      s.sid
,      CASE WHEN state != 'WAITING' THEN 'WORKING' ELSE 'WAITING' END AS state
,      CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END AS sw_event
,      s.seconds_in_wait, s.sql_exec_start, s.prev_exec_start
,      tx.addr  
,      tx.status  
,      s.*  
from   gv$transaction    tx  
,      gv$session        s  
where  s.taddr      (+) = tx.addr
order by txn_start_time, s.sid;
