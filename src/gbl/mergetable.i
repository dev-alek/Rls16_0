{gbl/tmprecid.i}
&if defined(bufSource) eq 0
&then
 &message не объявлен источник копирования bufSource
&endif
&if defined(bufSource) eq 0
&then
 &message не объявлен Приемник копирования bufTarget
&endif  
&if defined(tableKeyMerge) eq 0
&then
 &message не объявлен не заданы поля для поиска записей tableKeyMerge
&endif  

for each {&bufSource} 
&if defined (bufHead) ne 0
&then
where {gbl/findtbfortb.i {&bufSource} {&bufHead} no {&tableHeadKeyMerge}}
&endif
no-lock
on error  undo, return error
:
   &if defined(beforefind) <> 0 &then
     {&beforefind}
   &endif
   &glob modlock exclusive-lock
   {gbl/findtbfortb.i {&bufTarget} {&bufSource} {&tableKeyMerge}}
   if not available {&bufTarget}
   then do:
      create {&bufTarget}.
      buffer-copy {&bufSource} to {&bufTarget}.
   end.
   else
     buffer-copy {&bufSource} {&copy-except} to {&bufTarget}.
   validate {&bufTarget} no-error.
   if error-status:error
   then
      return error return-value.
&if defined (bufHead) ne 0
&then
   create tmprecid.
   assign 
      tmprecid.fTable = "{&bufTarget}"
      tmprecid.Frecid = recid({&bufTarget})
   .
&endif
end.
&if defined (bufHead) ne 0
&then
for each {&bufTarget} where {gbl/findtbfortb.i {&bufTarget} {&bufHead} no {&tableHeadKeyMerge}} {&addWhereMainTbl}
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "{&bufTarget}"
                         and tmprecid.Frecid = recid({&bufTarget})
   no-lock no-error.
   if not available tmprecid
   then
      delete {&bufTarget}.
end.
empty temp-table tmprecid.
&endif