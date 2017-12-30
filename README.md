# Oracle-Monitoring-Scripts
Oracle Monitoring Scripts

Contains scripts for monitoring Oracle database via V$ views, ASH & AWR
Note: that usage of ASH & AWR requires Diagnostic Pack License

active-sessions.sql: a list of sessions currently actively working or actively waiting, excludes some "idle" events

ash.sql: a template query against in-memory active session history

ash-hist.sql: a template query against repository active session history

ash-hist-sql-exec.sql: looking at historic executions of a particular query, joining to dba_hist_snapshot is more efficient when wanting to restrict to certain time windows

ash-hist-sql-id.sql: looking at historic executions of a particular query

ash-hist-sql-plan: looking at where one particular historic execution of a query spent most of its time (limited view due to nature of ash data)

awr-io-profile.sql: looking at the io profile over awr snapshots, should match the numbers from an awr report

awr-time-profile.sql: looking at where the database time was spent over awr snapshots, should match the numbers from an awr report

awr-time-io_profile.sql: combines awr-io-profile.sql and awr-time-profile.sql

curr-io.sql: looks at recent average of host cpu utilisation and io single block read times

hist-io.sql: looks at historic average of host cpu utilisation and io single block read times

sql-stats.sql: aggregated sql executions by plan phv from awr

sql-stats2.sql: aggregated sql executions from awr

top-awr-sql.sql: reports the top N sql statements recorded in awr, top by cumulative elapsed time (line 25)

transactions.sql: Which transactions are holding locks on which objects. 

transactions2.sql: sessions with transaction information
