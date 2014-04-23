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
