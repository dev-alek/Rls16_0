&if defined(starterasunc) eq 0
&then
define input  parameter iType            as character no-undo. 
define input  parameter i-parent-handle  as handle no-undo.

procedure addtask:
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   run addtaskType  (iType,iProc,iParam).
end.   
procedure addtaskType:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   run addtask in i-parent-handle (ITask,iProc,iParam).
end.   

procedure waitproc:
   define input  parameter itext  as character no-undo.
   run waitProcLable in i-parent-handle (itext).
end.  

&else
{ adm/auto-def-log.i }
define variable mLableText as character no-undo.
define variable mStartTime as datetime-tz no-undo init ?.

procedure addtask:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   if mStartTime ne ?
   then
      mAsyncHelper:AddTask (ITask,iProc,iParam,mStartTime).
   else
      mAsyncHelper:AddTask (ITask,iProc,iParam).
   unsubscribe "PutFileLogAsunc".
end.   
procedure addTaskTime:
   define input  parameter ITask      as character no-undo.
   define input  parameter iProc      as character no-undo.
   define input  parameter iParam     as character no-undo.
   define input  parameter iStartTime as datetime-tz no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   mAsyncHelper:AddTask (ITask,iProc,iParam,iStartTime).
   unsubscribe "PutFileLogAsunc".
end.  

procedure waitproc:
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,?,1,itext + " " + mLableText).
   unsubscribe "PutFileLogAsunc".
end.  

procedure waitProcLable:
   define input  parameter itext  as character no-undo.
   mLableText = itext.
end. 

procedure waitProcShed:
   define input  parameter iSched as character no-undo.
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,iSched,1,itext).
   unsubscribe "PutFileLogAsunc".
end.  


procedure WriteLogAsync:
   define input  parameter iFile as character no-undo.
   define variable vText as character no-undo.
   define variable vFile as longchar  no-undo.
   define variable vfileName as character no-undo.
   define variable vi as int64 no-undo.
   define variable vStr  as character no-undo.
         
   vfileName = mAsyncHelper:objExists(iFile,"f").
   if vfileName ne ?
   then do:
      copy-lob from file vfileName to vFile no-error.
      if error-status:error
      then do:
         run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).
      end.
      else do:
          vFile = replace (vFile,{&carriage-return} + {&new-line},{&new-line}).
          do vi = 1 to num-entries(vFile,{&new-line}) - 1:
            
            run write-to-log-notime (entry(vi, vFile,{&new-line})).
         end.
      end.
   end.
   else do:
       assign
           vtext = substitute ("Процедура обработки данных не завершена. &1",ifile).
       run write-to-log (vtext).
   end.
end.
&endif