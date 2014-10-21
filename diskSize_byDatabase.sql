SELECT      sys.databases.name, 
	CAST(SUM(size) AS varchar) AS [Total disk space],
	CAST((SUM(size)*8.0/1024) AS varchar) +' MB' AS [Total disk space],
	CAST((SUM(size)*8.0/1048576) AS varchar) +' GB' AS [Total disk space]
FROM        sys.databases 
JOIN        sys.master_files
ON          sys.databases.database_id=sys.master_files.database_id
GROUP BY    sys.databases.name
ORDER BY    CAST((SUM(size)*8.0/1048576) AS varchar) +' GB' DESC

