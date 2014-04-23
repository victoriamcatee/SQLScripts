--Identify which type of tempdb objects are consuming  space
SELECT	SUM (user_object_reserved_page_count) * 8 AS 'userObjects_KB', --If userObjects_KB is the highest consumer, then you that objects are being created by user queries like local or global temp tables or table variables. Also don’t forget to check if there are any permanent tables created in TempDB. Very rare, but I’ve seen this happening.
	SUM (internal_object_reserved_page_count) * 8 AS 'internalObjects_KB',
	SUM (version_store_reserved_page_count) * 8 AS 'versionStore_KB', --If versionStore_KB is the highest consumer, then it means that the version store is growing faster than the clean up. Most likely there are long running transactions or open transaction (Sleeping state), which are preventing the cleanup and hence not release tempdb space back.
	SUM (unallocated_extent_page_count) * 8 AS 'freeSpace_KB',
	SUM (mixed_extent_page_count) * 8 AS 'mixedExtent_KB'
FROM	sys.dm_db_file_space_usage

--Query that identifies the currently active offender
SELECT	c.host_name,
	c.login_name,
	c.program_name,
	d.dbid AS 'queryExecContextDBID',
	DB_NAME(d.dbid) AS 'queryExecContextDBNAME',
	d.objectid AS 'moduleObjectId',
	SUBSTRING(d.text, b.statement_start_offset/2 + 1,(CASE WHEN b.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max),d.text)) * 2 ELSE b.statement_end_offset END - b.statement_start_offset)/2) AS 'queryText',
	a.session_id,
	a.request_id,
	a.exec_context_id,
	(a.user_objects_alloc_page_count - a.user_objects_dealloc_page_count) AS 'outStanding_user_objects_page_counts',
	(a.internal_objects_alloc_page_count - a.internal_objects_dealloc_page_count) AS 'outStanding_internal_objects_page_counts',
	b.start_time,
	b.command,
	b.open_transaction_count,
	b.percent_complete,
	b.estimated_completion_time,
	b.cpu_time,
	b.total_elapsed_time,
	b.reads,
	b.writes,
	b.logical_reads,
	b.granted_query_memory
FROM	sys.dm_db_task_space_usage a
	JOIN sys.dm_exec_requests b  ON a.session_id = b.session_id and a.request_id = b.request_id
	JOIN sys.dm_exec_sessions c ON a.session_id = c.session_id
	CROSS APPLY sys.dm_exec_sql_text(b.sql_handle) d
WHERE	( a.internal_objects_alloc_page_count + a.user_objects_alloc_page_count ) > 0
ORDER BY ( a.user_objects_alloc_page_count - a.user_objects_dealloc_page_count) + ( a.internal_objects_alloc_page_count - a.internal_objects_dealloc_page_count ) DESC

/*
Tempdb and the Version Store

The version stored (SQL 2005 onwards) is a collection of objects that are used when Snapshot Isolation or Read-Committed Snapshot Isolation (RCSI) or online index rebuild etc. are used in a database.

Version store contains the committed rows which is how a SELECT operation does not get blocked when another UPDATE/DELETE is operating on the same row,
	because the SELECT reads the row from the version store, instead of the actual base table.
	When you enable this, the row has to be stored somewhere and tempdb happens to be the place.
	A row is maintained in the version store when there are transactions operating on that row in questions.
	When the transaction is committed, the row is cleaned up from the version store tables.

You can check the version store using the DMV sys.dm_tran_version_store

At times, when there are long running transactions or orphaned transactions, you might notice tempdb growth due to the version store.

You can use the following query to find the oldest transactions that are active and using row versioning.
*/

SELECT TOP 5 a.session_id,
	a.transaction_id,
	a.transaction_sequence_num,
	a.elapsed_time_seconds,
	b.program_name,
	b.open_tran,
	b.status
FROM	sys.dm_tran_active_snapshot_database_transactions a
	JOIN sys.sysprocesses b ON a.session_id = b.spid
ORDER BY a.elapsed_time_seconds DESC

;WITH taskSpaceUsage AS (
	--SUM alloc/delloc pages
	SELECT	session_id,
		request_id,
		SUM(internal_objects_alloc_page_count) AS 'allocPages',
		SUM(internal_objects_dealloc_page_count) AS 'deallocPages'
	FROM	sys.dm_db_task_space_usage WITH (NOLOCK)
	WHERE session_id <> @@SPID
	GROUP BY session_id, request_id
)

SELECT	a.session_id,
	a.allocPages * 1.0 / 128 AS 'internalObjectMBSpace',
	a.deallocPages * 1.0 / 128 AS 'internalObjectDeallocMBSpace',
	c.text,
	--getSQL
	ISNULL(NULLIF(SUBSTRING(c.text, b.statement_start_offset / 2, CASE WHEN b.statement_end_offset < b.statement_start_offset THEN 0
										ELSE( b.statement_end_offset - b.statement_start_offset ) / 2 END
				), ''), c.text) AS 'sqlText',
	d.query_plan
FROM	taskSpaceUsage AS a
--FIND ONLY ACTIVE
--INNER JOIN sys.dm_exec_requests b WITH (NOLOCK)
	LEFT OUTER JOIN sys.dm_exec_requests b WITH (NOLOCK)	ON	a.session_id = b.session_id
								AND	a.request_id = b.request_id
	OUTER APPLY sys.dm_exec_sql_text(b.sql_handle) AS c
	OUTER APPLY sys.dm_exec_query_plan(b.plan_handle) AS d
WHERE	c.text IS NOT NULL
OR	d.query_plan IS NOT NULL
ORDER BY 3 DESC;

--dbcc inputbuffer

--FOR TRANSACTIONS
SELECT	a.database_transaction_log_bytes_reserved,
	b.session_id,
	d.[text],
	[statement] = COALESCE(NULLIF(SUBSTRING(d.[text],c.statement_start_offset / 2, CASE WHEN c.statement_end_offset < c.statement_start_offset THEN 0
												ELSE( c.statement_end_offset - c.statement_start_offset ) / 2 END
						), ''), d.[text])
FROM	sys.dm_tran_database_transactions a
	JOIN sys.dm_tran_session_transactions b ON b.transaction_id = a.transaction_id
	LEFT OUTER JOIN sys.dm_exec_requests c ON c.session_id = b.session_id
	OUTER APPLY sys.dm_exec_sql_text(c.plan_handle) AS d
WHERE a.database_id = 2;

;WITH s AS
(	SELECT	s.session_id,
		[pages] = SUM(s.user_objects_alloc_page_count + s.internal_objects_alloc_page_count)
	FROM	sys.dm_db_session_space_usage s
	GROUP BY s.session_id
	HAVING SUM(s.user_objects_alloc_page_count + s.internal_objects_alloc_page_count) > 0
)

SELECT	s.session_id,
	s.[pages],
	t.[text],
	[statement] = COALESCE(NULLIF(SUBSTRING(t.[text],r.statement_start_offset / 2,	CASE WHEN r.statement_end_offset < r.statement_start_offset THEN 0 
											ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 
											END
						), ''),t.[text])
FROM	s
	JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
	OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
ORDER BY s.[pages] DESC;
