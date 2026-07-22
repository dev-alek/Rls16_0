block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwst1.p $
$Archive: utl/frcnwst1.p $

Форсированная передача thbj-attr, рожденных в результатов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwst1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwst1.p $":U .
define variable vss-description as character no-undo init "Форсированная передача thbj-attr, рожденных в результатов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-ii as integer no-undo .
define variable v-list as character no-undo .
define variable v-entry as character no-undo .
define variable p-news as logical no-undo .

if not p-install then do:
  message vss-workfile vss-revision vss-description skip
  "Вы уверены, что хотите запустить пересылку данных thbj-attr по новостям"
  view-as alert-box question buttons yes-no update loc#log as logical  .
  if not loc#log then return.
end.

main-block:
do on error undo, return error
:
  v-list = {&attr-gds-ref}  + {&comma-char} +
           {&attr-gds-ref_obj} + {&comma-char} +
           {&attr-cli-all} + {&comma-char} +
           {&attr-cashpays} + {&comma-char} +
           {&attr-prt-glob} + {&comma-char} +
           {&attr-abc-global} + {&comma-char} +
           {&attr-ord-global} + {&comma-char} +
           {&attr-nakl_par}
           .
  do v-ii = 1 to num-entries(v-list):
    v-entry = entry(v-ii, v-list).
    for each ub.thbj-attr no-lock
    where ub.thbj-attr.upper-prop-code = v-entry
    on error undo, return error
    :
      run str/callnews.p
        (input  {&table_thbj-attr}
        ,input (buffer ub.thbj-attr:handle)
        ) no-error .
      if error-status:error then do:
        if not p-install then do:
          message error-status:get-message(1)  skip
          return-value
          view-as alert-box .

        end.
        undo main-block,  return error return-value .
      end.
    end.
  end. /*  do v-ii = 1 to num-entries(v-list):*/
end.

if not p-install then do:
  message
  "Завершилась утилита пересылки информации параметров объектов IBS TH по новостям"
  view-as alert-box .
end.