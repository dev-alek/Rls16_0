block-level on error undo, throw.

.session:debug-alert = yes.
/*{ utl/setpwd.i }*/
/*{cmp/trg-def.i }*/

{ utl/proc-async.i proc_def}

if    StopCheck()
then do:
   run PutstatAsunc(substitute("error   Получение счетчика было преврвано пользователем или по TimeOut.") ).
   { utl/proc-async.i proc_end}
   
   return.
end.

define variable  mfilename as character no-undo.

mfilename = GetPARAMAsunc(1).
define variable mKey as character   no-undo.
mkey = GetPARAMAsunc(2).
define variable  mCode as character no-undo.
mCode  = GetPARAMAsunc(3).
define variable  mParam as character no-undo.
mParam  = GetPARAMAsunc(4).
if     mfilename ne ? 
   and mkey      ne ? 
   and mCode     ne ?
then do:
   /*v-connpar = "-db ub -ld ub  -H localhost -S 44441 ".*/
   define variable mCounterValue as int64 no-undo.
   define variable mCounterStor as class ibs.th.ref.counter.counterstorage.
   mCounterStor = new ibs.th.ref.counter.counterstorage(). 
   mCounterValue = mCounterStor:GetNextcount(mFileName, mKey, mcode,mParam).
   delete object mCounterStor.
   run PutMesAsuncNoTime(string(mCounterValue)).
end.    

{ utl/proc-async.i proc_end}
   
