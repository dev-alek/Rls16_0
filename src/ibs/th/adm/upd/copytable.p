
define input parameter iTableList as character no-undo.

define variable vi as integer no-undo.
define variable vTableList as character no-undo.
{ utl/proc-async.i proc_def}

vTableList = trim(iTableList,'"').

function copytable returns logical (itable_old as character, itable_new as character ) forward.

run putStatAsunc in this-procedure ("Копирование данных в новую структуру...").
def var mtablename as char no-undo.
do vi = 1 to num-entries (vTableList,"|"):
   mtablename  = entry(vi,vTableList,"|").
   run putStatAsunc in this-procedure ("Копирование данных в новую структуру. Обработка таблицы " + mtablename ).
   copytable(mtablename + "_old", mtablename).
end.
{ utl/proc-async.i proc_end}

function copytable returns logical (itable_old as character, itable_new as character ):
   define variable vBufTargetTable as handle no-undo.
   define variable vBufSourseTable as handle no-undo.
   define variable vQuery          as handle no-undo.
   
   define variable vi as int64 no-undo.
   
   create buffer vBufTargetTable for table itable_new.
   vBufTargetTable:disable-load-triggers (false).
   create buffer vBufSourseTable for table itable_old.
   create query vQuery.

   vQuery:set-buffers(vBufSourseTable).
   vQuery:query-prepare("preselect EACH " + vBufSourseTable:name + " no-lock").
   vQuery:query-open().
   vQuery:get-first().
   
   do while vBufSourseTable:available:
      
      if vi mod 1000 = 0 then 
        run putStatAsunc in this-procedure 
          (substitute("Копирование данных в новую структуру. Oбработка таблицы &1. Обработано записей: &2 из &3.",
          itable_new, vi, vQuery:num-results)).
      do transaction:
         vBufTargetTable:buffer-create ().
         vBufTargetTable:buffer-copy (vBufSourseTable).
         vBufTargetTable:buffer-release ().
         vBufSourseTable:find-current (exclusive-lock).
         vBufSourseTable:buffer-delete ().  
      end.
      vi = vi + 1.
      vQuery:get-next().
   end.
   vQuery:query-close().
   delete object vQuery.
   delete object vBufTargetTable.
   delete object vBufSourseTable.
end.
