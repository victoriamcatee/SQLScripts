/*
This procedure takes four parameters:

Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc... 
Log file type: 1 or NULL = error log, 2 = SQL Agent log 
Search string 1: String one you want to search for 
Search string 2: String two you want to search for to further refine the results
If you do not pass any parameters this will return the contents of the current error log.
*/

--EXEC sys.sp_readerrorlog 0,1,'trace'
EXEC sys.sp_readerrorlog 0,1,'error'
EXEC sys.sp_readerrorlog 0,1,'fail'

--EXEC sys.sp_readerrorlog 1,1,'trace'
EXEC sys.sp_readerrorlog 1,1,'error'
EXEC sys.sp_readerrorlog 1,1,'fail'
EXEC sys.sp_readerrorlog 2,1,'error'
EXEC sys.sp_readerrorlog 2,1,'fail'
EXEC sys.sp_readerrorlog 3,1,'error'
EXEC sys.sp_readerrorlog 3,1,'fail'
EXEC sys.sp_readerrorlog 4,1,'error'
EXEC sys.sp_readerrorlog 4,1,'fail'
EXEC sys.sp_readerrorlog 5,1,'error'
EXEC sys.sp_readerrorlog 5,1,'fail'
EXEC sys.sp_readerrorlog 6,1,'error'
EXEC sys.sp_readerrorlog 6,1,'fail'
EXEC sys.sp_readerrorlog 7,1,'error'
EXEC sys.sp_readerrorlog 7,1,'fail'

EXEC sys.sp_readerrorlog 8,1,'error'
EXEC sys.sp_readerrorlog 9,1,'error'
EXEC sys.sp_readerrorlog 10,1,'error'
EXEC sys.sp_readerrorlog 11,1,'error'
EXEC sys.sp_readerrorlog 12,1,'error'
EXEC sys.sp_readerrorlog 13,1,'error'
EXEC sys.sp_readerrorlog 14,1,'error'
EXEC sys.sp_readerrorlog 15,1,'error'
	EXEC sys.sp_readerrorlog 16,1,'error'
EXEC sys.sp_readerrorlog 17,1,'error'
EXEC sys.sp_readerrorlog 18,1,'error'
