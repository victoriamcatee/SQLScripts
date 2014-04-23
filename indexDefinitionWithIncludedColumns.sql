SELECT	'[' + c.name + '].[' + b.[name] + ']' AS 'tableName',
	a.[name] AS 'indexName',
	SUBSTRING((	SELECT ', ' + g.name
			FROM	sys.tables d
				JOIN sys.indexes e ON d.object_id = e.object_id
				JOIN sys.index_columns f	ON	e.object_id = f.object_id
								AND	e.index_id = f.index_id
				JOIN sys.all_columns g	ON	d.object_id = g.object_id
							AND	f.column_id = g.column_id
			WHERE	a.object_id = e.object_id
			AND	a.index_id = e.index_id
			AND	f.is_included_column = 0
			ORDER BY f.key_ordinal
			FOR XML PATH('')
			
			),2,8000) AS 'keyColumns',
	SUBSTRING((	SELECT ', ' + g.name
			FROM	sys.tables AS d
				JOIN sys.indexes e ON d.object_id = e.object_id
				JOIN sys.index_columns f	ON	e.object_id = f.object_id
								AND	e.index_id = f.index_id
				JOIN sys.all_columns g	ON	d.object_id = g.object_id
							AND	f.column_id = g.column_id
			WHERE	a.object_id = e.object_id
			AND	a.index_id = e.index_id
			AND	f.is_included_column = 1
			ORDER BY f.key_ordinal
			FOR XML PATH('')
		),2,8000) AS 'includeColumns'
FROM	sys.indexes a
	JOIN sys.tables b ON b.object_id = a.object_id
	JOIN sys.schemas c ON  c.schema_id = b.schema_id
--WHERE b.name  = 'someTableName' -- uncomment to get single table indexes detail
ORDER BY tableName