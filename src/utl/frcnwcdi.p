block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwcdi.p $
$Archive: utl/frcnwcdi.p $

Форсированная передача по новостям товаров, клиентов и т.д. по кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwcdi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwcdi.p $":U .
define variable vss-description as character no-undo init "Форсированная передача по новостям товаров, клиентов и и т.д. по кассе".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

if not p-install then do:
  message vss-workfile vss-revision vss-description skip
  "Вы уверены, что хотите запустить пересылку по новостям товаров, клиентов и т.д. по кассе"
  view-as alert-box question buttons yes-no update loc#log as logical  .
  if not loc#log then return.
end.


main-block:
do on error undo, return error
:
  for each ub.cash-desk no-lock
  where ub.cash-desk.db-num = g#db-num
  on error undo, return error
  :
    if not (ub.cash-desk.pos-type = {&cd-type-maria}
          or
          ub.cash-desk.pos-type = {&cd-type-r-keeper}
          ) then next.
    for each ub.cd-clu no-lock where
            ub.cd-clu.obj-type = {&shop}
        and ub.cd-clu.obj-code = ub.cash-desk.obj-code
        and ub.cd-clu.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_cd-clu}
        ,input (buffer ub.cd-clu:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.cd-dlu no-lock where
            ub.cd-dlu.obj-type = {&shop}
        and ub.cd-dlu.obj-code = ub.cash-desk.obj-code
        and ub.cd-dlu.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_cd-dlu}
        ,input (buffer ub.cd-dlu:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.cd-grp no-lock where
            ub.cd-grp.obj-type = {&shop}
        and ub.cd-grp.obj-code = ub.cash-desk.obj-code
        and ub.cd-grp.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_cd-grp}
        ,input (buffer ub.cd-grp:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.cd-grp no-lock where
            ub.cd-grp.obj-type = {&shop}
        and ub.cd-grp.obj-code = ub.cash-desk.obj-code
        and ub.cd-grp.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_cd-grp}
        ,input (buffer ub.cd-grp:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-clu no-lock where
            ub.c-cd-clu.obj-type = {&shop}
        and ub.c-cd-clu.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-clu.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-clu}
        ,input (buffer ub.c-cd-clu:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-dlu no-lock where
            ub.c-cd-dlu.obj-type = {&shop}
        and ub.c-cd-dlu.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-dlu.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-dlu}
        ,input (buffer ub.c-cd-dlu:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-grp no-lock where
            ub.c-cd-grp.obj-type = {&shop}
        and ub.c-cd-grp.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-grp.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-grp}
        ,input (buffer ub.c-cd-grp:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-grp no-lock where
            ub.c-cd-grp.obj-type = {&shop}
        and ub.c-cd-grp.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-grp.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-grp}
        ,input (buffer ub.c-cd-grp:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-doc no-lock where
            ub.c-cd-doc.obj-type = {&shop}
        and ub.c-cd-doc.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-doc.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-doc}
        ,input (buffer ub.c-cd-doc:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    for each ub.c-cd-doc no-lock where
            ub.c-cd-doc.obj-type = {&shop}
        and ub.c-cd-doc.obj-code = ub.cash-desk.obj-code
        and ub.c-cd-doc.pos-type = ub.cash-desk.pos-type
    on error undo, return error
    :
      run str/callnews.p
        (input {&table_c-cd-doc}
        ,input (buffer ub.c-cd-doc:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
  end.
end.

if not p-install then do:
  message
  "Завершилась утилита пересылки по новостям товаров, клиентов и т.д. по кассе"
  view-as alert-box .
end.