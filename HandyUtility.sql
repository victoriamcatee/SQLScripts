SET NOCOUNT ON

CREATE TABLE #holdit
(	objectDB sysname NOT NULL,
	objectName sysname NOT NULL,
	objectType varchar(2) NOT NULL
)

DECLARE @t_stringList TABLE
(	rowNum int NOT  NULL IDENTITY(1,1),
	stringValue varchar(256)
)

DECLARE	@s_sqlstr varchar(4000),
	@n_maxRow int,
	@s_stringList varchar(8000),
	@n_loopNum int,
	@s_currString varchar(256)

SET	@s_stringList = 'someColumnName' --Comma delimited list of strings to test

INSERT	@t_stringList
(	stringValue
)
SELECT DISTINCT string
FROM master..fn_convertStrListToTable(',',@s_stringList)

SELECT	@n_maxRow = MAX(rowNum)
FROM	@t_stringList

SET	@n_loopNum = 1

WHILE	@n_loopNum <= @n_maxRow
BEGIN
	SELECT	@s_currString = stringValue
	FROM	@t_stringList
	WHERE	rowNum = @n_loopNum

	SET	@s_sqlstr = 'INSERT #holdit (objectDB, objectName, objectType)
				SELECT DISTINCT ''?'',a.name, a.type 
				FROM ?.dbo.sysobjects a (NOLOCK) 
				JOIN ?.dbo.syscomments b (NOLOCK) ON a.id = b.id
				AND b.text like ''%[^_a-z0-9]' + @s_currString + '[^_a-z0-9]%'''

	EXEC sp_msForEachDB @s_sqlstr

	SET	@n_loopNum = @n_loopNum + 1
END

SELECT	objectDB + '..' + objectName
FROM	#holdit
GROUP BY objectDB + '..' + objectName
HAVING COUNT(*) >= @n_maxRow
ORDER BY objectDB + '..' + objectName

DROP TABLE #holdit
SET NOCOUNT OFF
GO






