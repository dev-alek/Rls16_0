block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwscl.p $
$Archive: utl/frcnwscl.p $

Форсированная передача весов по новостям

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwscl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwscl.p $":U .
define variable vss-description as character no-undo init "Форсированная передача весов по новостям".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/scl-attr.i }
define variable p-news as logical no-undo .

if not p-install then do:
  message vss-workfile vss-revision vss-description skip
  "Вы уверены, что хотите запустить пересылку данных по весам по новостям"
  view-as alert-box question buttons yes-no update loc#log as logical  .
  if not loc#log then return.
end.


main-block:
do on error undo, return error
:
  for each ub.scales no-lock
  where ub.scales.db-num = g#db-num
  on error undo, return error
  :

    run str/callnews.p
      (input "scales"
      ,input (buffer ub.scales:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error return-value .
    end.
    for each ub.scales-attr no-lock where
            ub.scales-attr.db-num = ub.scales.db-num
       AND  ub.scales-attr.scales-num = ub.scales.scales-num
    on error undo, return error
    :
      run scl-attr-news in this-procedure (
                                          input ub.scales-attr.attr-code
                                          ,output p-news) no-error.
      if p-news then do:
        run str/callnews.p
          (input "scales-attr"
          ,input (buffer ub.scales-attr:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block,  return error return-value .
        end.
      end.
    end.
    for each ub.scales-gds no-lock where
            ub.scales-gds.db-num = ub.scales.db-num
       AND  ub.scales-gds.scales-num = ub.scales.scales-num
    on error undo, return error
    :
      run str/callnews.p
        (input "scales-gds"
        ,input (buffer ub.scales-gds:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
  end.
  for each ub.scales-grp no-lock where
          ub.scales-grp.db-num = ub.scales.db-num
  on error undo, return error
  :

    run str/callnews.p
      (input "scales-grp"
      ,input (buffer ub.scales-grp:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error return-value .
    end.
  end.

end.

if not p-install then do:
  message
  "Завершилась утилита пересылки информации по весам по новостям"
  view-as alert-box .
end.