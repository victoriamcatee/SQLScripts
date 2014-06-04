--Note: xml query plan output can be saved with .sqlplan file extension and can then be opened in management studio.

--TOP CPU OFFENDERS
select top 20	total_worker_time/1000,
	qs.creation_time as [compile time],
	qs.last_execution_time,
	qs.total_worker_time / 1000 / qs.execution_count as [avg cpu (ms)],
	qs.execution_count as [total execution count],
	@@servername as [server],
	isnull(db_name(st.dbid), 'Ad-Hoc or Prepared SQL') as [database],
	isnull(object_name(st.objectid), 'Ad-Hoc or Prepared SQL') as [object],
	substring(st.text, (qs.statement_start_offset / 2) + 1,((CASE WHEN qs.statement_end_offset = -1 THEN datalength(st.text) 
									ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1) as [query],
	qp.query_plan as [query plan]
FROM	sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as st
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
WHERE	last_execution_time > '04/24/14 10:00'
ORDER BY total_worker_time desc, [total execution count] desc;

--TOP READ OFFENDERS
SELECT TOP 20
	qs.creation_time as [compile time],
	qs.total_logical_reads / 1000 / qs.execution_count as [avg logical reads (ms)],
	qs.execution_count as [total execution count],
	@@servername as [server],
	isnull(db_name(st.dbid), 'Ad-Hoc or Prepared SQL') as [database],
	isnull(object_name(st.objectid), 'Ad-Hoc or Prepared SQL') as [object],
	substring(st.text, (qs.statement_start_offset / 2) + 1,((CASE WHEN qs.statement_end_offset = -1 THEN datalength(st.text)
									ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1) as [query],
	qp.query_plan as [query plan]
FROM	sys.dm_exec_query_stats as qs
	CROSS APPLY	sys.dm_exec_sql_text(qs.sql_handle) as st
	CROSS APPLY	sys.dm_exec_query_plan(qs.plan_handle) as qp
ORDER BY [avg logical reads (ms)] desc,[total execution count] desc;

--TOP WRITE OFFENDERS
SELECT TOP 20
	qs.creation_time as [compile time],
	qs.total_logical_writes / 1000 / qs.execution_count as [avg logical writes (ms)],
	qs.execution_count as [total execution count],
	@@servername as [server],
	isnull(db_name(st.dbid), 'Ad-Hoc or Prepared SQL') as [database],
	isnull(object_name(st.objectid), 'Ad-Hoc or Prepared SQL') as [object],
	substring(st.text, (qs.statement_start_offset / 2) + 1,	((case when qs.statement_end_offset = -1 
									THEN datalength(st.text) ELSE qs.statement_end_offset end - qs.statement_start_offset) / 2) + 1) as [query],
	qp.query_plan as [query plan]
FROM	sys.dm_exec_query_stats as qs
	CROSS APPLY	sys.dm_exec_sql_text(qs.sql_handle) as st
	CROSS APPLY	sys.dm_exec_query_plan(qs.plan_handle) as qp
order by
    [avg logical writes (ms)] desc,
    [total execution count] desc;
