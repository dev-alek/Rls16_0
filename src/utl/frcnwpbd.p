block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwpbd.p $
$Archive: utl/frcnwpbd.p $

Форсированная передача prod-bc-db по новостям

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwpbd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwpbd.p $":U .
define variable vss-description as character no-undo init "Форсированная передача prod-bc-db".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/scl-attr.i }
define variable p-news as logical no-undo .

if not p-install then do:
  message vss-workfile vss-revision vss-description skip
  "Вы уверены, что хотите запустить пересылку prod-bc-db по новостям"
  view-as alert-box question buttons yes-no update loc#log as logical  .
  if not loc#log then return.
end.


main-block:
do on error undo, return error
:
  for each ub.prod-bc-db no-lock
  where ub.prod-bc-db.db-num = g#db-num
  on error undo, return error
  :

    run str/callnews.p
      (input "prod-bc-db"
      ,input (buffer ub.prod-bc-db:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error return-value .
    end.
  end.
end.

if not p-install then do:
  message
  "Завершилась утилита пересылки prod-bc-db по новостям"
  view-as alert-box .
end.