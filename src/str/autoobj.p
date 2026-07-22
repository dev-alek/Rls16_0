block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: autoobj.p $
$Archive: str/autoobj.p $

Возвращает имя объекта по умолчанию для экрана покупател

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/13/09
Author: Dmitry Ukhanov
Creation date: 10/13/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 07/10/06

*/
define input  parameter p-user-login  as character no-undo .
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-state    as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: autoobj.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/autoobj.p $":U .
define variable vss-description as character no-undo initial "Возвращает имя объекта по умолчанию для экрана покупателя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }

define variable v-dflt-cntxt-valid           as logical   no-undo .
define variable v-dflt-cntxt-menu-code       as integer   no-undo .
define variable v-dflt-cntxt-menu-group-code as integer   no-undo .
define variable v-dflt-cntxt-level           as character no-undo .
define variable v-dflt-cntxt-host-code-obj   as integer   no-undo .
define variable v-dflt-cntxt-obj-type        as character no-undo .
define variable v-dflt-cntxt-obj-code        as integer   no-undo .

define buffer buf_sys-ctrl     for ub.sys-ctrl .
define buffer buf_user-login     for ub.user-login .

do
on error undo, return error return-value
:
  assign
    p-state = no
  .
  find first buf_sys-ctrl no-lock.
  find first buf_user-login
       where buf_user-login.db-num =  buf_sys-ctrl.db-num
       and   buf_user-login.user-login = p-user-login
       no-lock
       no-error
       .
  IF NOT AVAILABLE buf_user-login
  THEN RETURN ERROR.

  run gbl/cntxtget.p
    (input  buf_user-login.db-num        /* p-cntxt-db-num          */
    ,input  buf_user-login.user-id       /* p-cntxt-user-id         */
    ,output v-dflt-cntxt-valid           /* p-cntxt-valid           */
    ,output v-dflt-cntxt-menu-code       /* p-cntxt-menu-code       */
    ,output v-dflt-cntxt-menu-group-code /* p-cntxt-menu-group-code */
    ,output v-dflt-cntxt-level           /* p-cntxt-level           */
    ,output v-dflt-cntxt-host-code-obj   /* p-cntxt-host-code-obj   */
    ,output v-dflt-cntxt-obj-type        /* p-cntxt-obj-type        */
    ,output v-dflt-cntxt-obj-code        /* p-cntxt-obj-code        */
    ) .

  find first ub.clients no-lock
    where ub.clients.obj-type = v-dflt-cntxt-obj-type
      and ub.clients.obj-code = v-dflt-cntxt-obj-code
    no-error .
  if available ub.clients
  and (ub.clients.obj-type = {&stock} or ub.clients.obj-type = {&shop})
  then do:
    assign
      p-state    = yes
      p-obj-type = ub.clients.obj-type
      p-obj-code = ub.clients.obj-code
    .
  end.
  else do:
    /*Выбор объекта*/
    run str/chs-obj.w
      (input  buf_user-login.user-id
      ,input  {&stock} + "," + {&shop}
      ,output p-obj-type
      ,output p-obj-code
      ) no-error.
    if error-status :error
    or p-obj-code = ?
    then do:
      /* */
    end.
    else do:
      assign
        p-state = yes
      .
    end.
  end.
end.