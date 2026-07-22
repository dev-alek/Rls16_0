block-level on error undo, throw.
/*

$Revision: 04f5f86ff8c4, 369, rls $
$Author: ASMorozov $
$Date: Fri Dec 25 19:12:41 2015 +0300 $
$Workfile: clclobwb.p $
$Archive: utl/clclobwb.p $

Очистка накладных.

Автор: Морозов Алекасандр Сергеевич
Дата создания: 24/12/15
Author: Alexand Morozov
Creation date: 24/12/15

*/


define variable vss-revision    as character no-undo init "$Revision: 04f5f86ff8c4, 369, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Dec 25 19:12:41 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clclobwb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/clclobwb.p $":U .
define variable vss-description as character no-undo init "Очистка накладных.".
{ cmp/vssrevis.i }

{ gbl/waitfram.i }

define variable v-log as logical no-undo.
define variable i     as integer no-undo.


do :
  i = 0.
  run waitfram-show in this-procedure ( "ЖДИТЕ...") .
  for each ub.clob-bind exclusive-lock where field-name_ begins 'egais'.
    delete ub.clob-bind.
  end.
  run waitfram-hide in this-procedure .
  message "Готово." view-as alert-box.
end.
