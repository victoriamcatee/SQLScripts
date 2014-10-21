
select T.object_id, T.name, I.indid, I.rows 
  from Sys.tables T 
  left join Sys.sysindexes I 
    on (I.id = T.object_id and (indid =1 or indid =0 ))
 where T.type='U'


