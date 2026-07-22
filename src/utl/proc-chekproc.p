block-level on error undo, throw.

.session:debug-alert = yes.

{ utl/proc-async.i proc_def}
if        StopCheck()
then do:
   run PutstatAsunc(substitute("error   Получение проверка была преврвана пользователем или по TimeOut.") ).
   { utl/proc-async.i proc_end}
   return.
end.
if userid("ub") ne ""
then do:
    run PutstatAsunc(substitute("error   Не правильное подключение к Базе. ") ).
   { utl/proc-async.i proc_end}
     
return.
end.
define variable v-num-parameters as integer no-undo.
define variable mProc-name as character no-undo.
define variable mparparentproc as logical   no-undo.
define variable mKey as integer  no-undo.
define variable MChekSum as character no-undo.
define variable m-parameter1 as character no-undo.
define variable m-parameter2 as character no-undo.
define variable m-parameter3 as character no-undo.
mProc-name        =          GetPARAMAsunc(1).
v-num-parameters  = integer (GetPARAMAsunc(2)).
mparparentproc    = logical (GetPARAMAsunc(3)).
mkey              = integer (GetPARAMAsunc(4)).
m-parameter1      =          GetPARAMAsunc(5).
m-parameter2      =          GetPARAMAsunc(6).
m-parameter3      =          GetPARAMAsunc(7).


if     v-num-parameters ne ? 
   and mparparentproc   ne ? 
   and mkey     ne ?
then do:
   case v-num-parameters :
      when 0
      then do:
         if mparparentproc
         then do:
            run value (mProc-name)
                   (input  mkey,
                    output MChekSum,
                    input ?
                   ) no-error.
         end.
         else do:
            run value (mProc-name)
                   (input  mkey,
                    output MChekSum
                    )no-error.
         end.
      end.
      when 1
      then do:
         if mparparentproc
         then do:
              run value (mproc-name)
                (input  mkey,
                 output MChekSum,
                 input  ?
                ,input  m-parameter1
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey,
                 output MChekSum,
                 input m-parameter1
                )no-error.
         end.
      end.
      when 2
      then do:
         if mparparentproc 
         then do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input ?
                ,input m-parameter1
                ,input m-parameter2
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input m-parameter1
                ,input m-parameter2
                )no-error.
         end.
      end.
      when 3
      then do:
         if mparparentproc
         then do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input ?
                ,input m-parameter1
                ,input m-parameter2
                ,input m-parameter3
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input m-parameter1
                ,input m-parameter2
                ,input m-parameter3
                )no-error.
         end.
      end.
   end case.

   def var v-counter as int no-undo. 
   if error-status:error 
   then do v-counter = 1 to error-status :num-messages
       :
        run PutstatAsunc(substitute("error  &1",error-status:get-message (v-counter)) ).
   end.
   else 
   run PutMesAsuncNoTime ( string(MChekSum) ).
   
   { utl/proc-async.i proc_end}
   
end.    
      
