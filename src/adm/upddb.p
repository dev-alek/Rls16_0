block-level on error undo, throw.
/*

$Revision: d855a480b4c6, 3515, rls $
$Author: DRuban $
$Date: 2023/10/25 15:17:32 $
$Workfile: upddb.p $
$Archive: adm/upddb.p $

Процедура обновления TH и схемы БД

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

using ibs.th.adm.upd.*.

{ cmp/str-glbl.i }

define input parameter p-connpar as character no-undo.
define output parameter p-isUpdShm as logical init false no-undo.
define variable updschmObj as class updschm no-undo.
define variable str as character no-undo.
define stream slogwrite.
output stream slogwrite to "update.log".
subscribe "WriteLogAsunc" anywhere.
subscribe "PutStatAsunc" anywhere run-procedure "WriteLogAsunc".
updschmObj = new updschm (input p-connpar,"",this-procedure).
if updschmObj:IsErr
then do:
  str = updschmObj:Msg.
  delete object updschmObj no-error.
  return error str.  
end.

if updschmObj:isNeedUpd
then do:
  updschmObj:upddbshm().
  if updschmObj:IsErr
  then do:
    str = updschmObj:Msg.
    delete object updschmObj no-error.
    return error str.  
  end.
end.

p-isUpdShm = updschmObj:isUpdShm.
delete object updschmObj.
unsubscribe "WriteLogAsunc".
unsubscribe "PutStatAsunc".
output stream slogwrite close.

procedure WriteLogAsunc:
   define input  parameter itext as character no-undo.
   define input  parameter iMes  as logical   no-undo.
   put stream slogwrite unformatted itext skip.
end.
   