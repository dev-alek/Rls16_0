block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: menunews.p $
$Archive: utl/menunews.p $

Отправить меню пользователя по новостям

Автор: Белоусов Илья Александрович
Дата создания: 03/27/08
Author: Ilia Belousov
Creation date: 03/27/08

"user-menu-group"          "trg/usmndgpd.p"  "trg/usmndgpd.p"

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menunews.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/menunews.p $":U .
define variable vss-description as character no-undo init "Отправить меню пользователя по новостям".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable v-ind      as integer   no-undo .
define variable v-ok       as logical   no-undo .
define variable v-db-num   as integer   no-undo.

define buffer buf_user-menu-group   for ub.user-menu-group .
define buffer buf_sys-ctrl          for ub.sys-ctrl .


do
on error undo, return error return-value
:
  /*
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
  */

  find first buf_sys-ctrl
       no-lock
       .

  assign
    v-db-num = buf_sys-ctrl.db-num
  .

  message
    vss-description
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return . /* --->>>--- */
  end.

  if v-db-num <> 0
  then do:
    for each buf_user-menu-group exclusive-lock
      where buf_user-menu-group.db-num = v-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-menu-group}
        ,input (buffer buf_user-menu-group:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
  end.
  run waitfram-hide in this-procedure .

  message
    vss-description skip
    "Утилита закончила работу" skip
    "Отправлено записей" v-ind skip
    view-as alert-box information .


end.