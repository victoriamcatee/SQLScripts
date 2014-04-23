DECLARE @numNeeded	int

SET	@numNeeded = 10 --How many keys in a row do you need 

SELECT	available_keyID,
	nextUsed-available_keyID AS 'numberAvail'
FROM	(
	SELECT	a.<keyColumnName> + 1 AS 'available_keyID',
		(SELECT	TOP 1 c.<keyColumnName> FROM myTable c (NOLOCK) WHERE c.<keyColumnName> > a.<keyColumnName>) AS 'nextUsed'
	FROM	myTable a
		LEFT JOIN myTable b ON b.<keyColumnName> = a.<keyColumnName> + 1
	WHERE	b.<keyColumnName> IS NULL
	) a
WHERE	nextUsed-available_keyID >= @numNeeded
ORDER BY available_keyID

