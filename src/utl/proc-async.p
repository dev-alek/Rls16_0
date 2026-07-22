block-level on error undo, throw.
&glob defonly yes
{ adm/auto-def.i new}
{ cmp/trg-def.i new }

{ utl/proc-async.i beg_proc}
define variable mDbConnect as logical no-undo.
define variable mName as character  no-undo.
define variable mpassword as character  no-undo.

MAIN-BLOCK:
do on error   undo MAIN-BLOCK, retry MAIN-BLOCK
   on end-key undo MAIN-BLOCK, retry MAIN-BLOCK
   on stop    undo MAIN-BLOCK, retry MAIN-BLOCK:
   if retry
   then do:
      run SetGblError(?).
      leave MAIN-BLOCK.
   end.

writelogvalue = "AsyncProc". 
define variable mProc       as char no-undo.
define variable mParam      as character no-undo.
define variable mParamName  as character no-undo.
define variable mParamValue as character no-undo.
define variable mNumEntries as integer no-undo.
define variable mI          as integer no-undo.
define variable mSetGblPar  as logical no-undo.

mname = GetParamAsuncStr("User"):valueparam.
mpassword = GetParamAsuncStr("password"):valueparam.
mProc = GetParamAsuncStr("procedure"):valueparam.
mDbConnect = logical(GetParamAsuncStr("DbConnect"):valueparam).
mSetGblPar = logical(GetParamAsuncStr("SetGblPar"):valueparam).
if mSetGblPar eq ?
then
   mSetGblPar = true.
if     mProc ne ?
   and mProc ne ""
then do:   
      run adm/autoinit.p ( input mname
                             ,input mpassword
                     ) no-error.
      if error-status :error then do:
         run PutMesAsunc ("Error " + error-status:get-message (1)).
      end.
      else do:
         if mDbConnect
         then do:
            run adm/autoconn.p no-error.
            if error-status :error 
            then do:
               run PutMesAsunc ("Error Не удалось подключиться к БД: " + return-value) .
            end.
            else do:
               if     mname ne ""
                  and mSetGblPar
               then
               run gbl/set-gbl-async.p
                  (input  true
                  ,input  mName
                  ,input  mpassword
                  ).
             
               if search(mProc) ne ?
               then do:
                  run value(mProc) no-error.
                  if error-status :error 
                  then do:
                     run PutMesAsunc (substitute ("Error Ошибка запуска процедуры &1 : &2 ",mProc, return-value)) .
                  end.
               end.
            end.
            
         end.
         else do:
            if search(mProc) ne ?
            then do:
               run value(mProc) no-error.
               if error-status :error 
               then do:
                  run PutMesAsunc (substitute ("Error Ошибка запуска процедуры &1 : &2 ",mProc, return-value)) .
               end. 
            end.
         end.
      end.
   end.
/*   else do:                                                        */
/*      run PutMesAsunc ("Error Не задан пользователь или пароль.") .*/
/*   end.                                                            */
/*end.*/
else
   run PutMesAsunc ("Error Не переданы параметры.") .
end.
{ utl/proc-async.i end_proc}



