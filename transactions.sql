select s.machine
,      lo.inst_id  
,      lo.object_id  
,      lo.session_id  
,      lo.os_user_name  
,      lo.process  
,      lo.locked_mode  
,      ob.owner  
,      ob.object_name  
,      ob.subobject_name
,      tx.addr  
,      tx.start_time txn_start_time  
,      tx.status  
,      tx.xid
,      s.*  
from   gv$locked_object lo  
,      dba_objects      ob  
,      gv$transaction    tx  
,      gv$session        s  
where  ob.object_id = lo.object_id  
and    tx.xidusn    (+) = lo.xidusn  
and    tx.xidslot   (+) = lo.xidslot  
and    tx.xidsqn    (+) = lo.xidsqn  
and    s.taddr      (+) = tx.addr
order by txn_start_time, session_id, object_name;
