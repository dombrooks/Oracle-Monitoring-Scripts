select s.inst_id,s.sid,s.module
,      CASE WHEN state = 'WAITING' AND event like 'enq%' THEN mod(p1,16) END AS lck
,      count(*) over (partition by CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END) ev_cnt 
,      count(*) over (partition by sql_id) sql_cnt 
,      s.seconds_in_wait wait,s.blocking_session blks,s.final_blocking_session f_blk_s
,      CASE WHEN state != 'WAITING' THEN 'WORKING' ELSE 'WAITING' END AS state
,      CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END AS sw_event
,      s.sql_id,s.sql_exec_id,to_char(s.sql_exec_start,'DD-MON-YYYY HH24:MI:SS') exec_start
, round((sysdate - s.sql_exec_start)*24*60*60) duration
,      (select px_servers_allocated||'/'||px_servers_requested from v$sql_monitor m where m.sql_id = s.sql_id and s.sql_exec_id = m.sql_exec_id and m.sql_exec_Start = s.sql_exec_Start and process_name not like 'p%') px_details
,      (select sql_fulltext from v$sql t where t.sql_id = s.sql_id and rownum = 1) txt
,      s.*
from   gv$session      s
where  s.status    = 'ACTIVE'
and    s.username IS NOT NULL
and    s.sid != (select sid from v$mystat where rownum = 1)
AND    s.event NOT IN 
       ('Null event','client message','KXFX: Execution Message Dequeue - Slave','PX Deq: Execution Msg','KXFQ: kxfqdeq - normal dequeue','PX Deq: Table Q Normal',
        'Wait for credit - send blocked','PX Deq Credit: send blkd','Wait for credit - need buffer to send','PX Deq Credit: need buffer','Wait for credit - free buffer',
        'PX Deq Credit: free buffer','parallel query dequeue wait','PX Deque wait','Parallel Query Idle Wait - Slaves','PX Idle Wait','slave wait','dispatcher timer',
        'virtual circuit status','pipe get','rdbms ipc message','rdbms ipc reply','pmon timer','smon timer','PL/SQL lock timer','SQL*Net message from client','WMON goes to sleep',
        'Streams AQ: waiting for messages in the queue','class slave wait')
        order by 1,3 DESC, 4;
