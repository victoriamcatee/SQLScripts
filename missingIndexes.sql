SELECT	a.user_seeks * a.avg_total_user_cost * ( a.avg_user_impact * 0.01 ) AS 'indexAdvantage',
	a.last_user_seek ,
	c.[statement] AS 'Database.Schema.Table',
	c.equality_columns ,
	c.inequality_columns ,
	c.included_columns ,
	a.unique_compiles ,
	a.user_seeks ,
	a.avg_total_user_cost ,
	a.avg_user_impact
FROM	sys.dm_db_missing_index_group_stats a WITH ( NOLOCK )
	JOIN sys.dm_db_missing_index_groups b WITH ( NOLOCK ) ON a.group_handle = b.index_group_handle
	JOIN sys.dm_db_missing_index_details c WITH ( NOLOCK ) ON b.index_handle = c.index_handle
WHERE	c.database_id = DB_ID()
ORDER BY indexAdvantage DESC;
