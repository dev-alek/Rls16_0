block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwscd.p $
$Archive: utl/frcnwscd.p $

Форсированная передача касс по новостям

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwscd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwscd.p $":U .
define variable vss-description as character no-undo init "Форсированная передача касс по новостям".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }



if not p-install then do:
  message vss-workfile vss-revision vss-description skip
  "Вы уверены, что хотите запустить пересылку данных по кассам по новостям"
  view-as alert-box question buttons yes-no update loc#log as logical  .
  if not loc#log then return.
end.



do on error undo, return error
:
  for each ub.cash-desk no-lock
  on error undo, return error
  :
      run str/callnews.p
        ( input "cash-desk":u
         ,input (buffer ub.cash-desk:handle)
        ) .
  end.
end.

if not p-install then do:

  message "Завершилась утилита пересылки касс по новостям"
  view-as alert-box .


end.