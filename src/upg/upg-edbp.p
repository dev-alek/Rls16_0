block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upg-edbp.p $
$Archive: upg/upg-edbp.p $

создание и изменение BatchProcess с типом {&btpr-type-autoupg}

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/
define input parameter p-action   as character no-undo .
define input parameter p-step     as integer   no-undo .
define input parameter p-db-num   as integer   no-undo .
define input parameter p-flag     as character no-undo .
define input parameter p-msg      as character no-undo .
define input parameter p-date     as date      no-undo .
define input parameter p-time     as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: upg-edbp.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/upg-edbp.p $":U .
def var vss-description as character no-undo init "создание и изменение BatchProcess с типом {&btpr-type-autoupg}".

{ cmp/str-glbl.i }

do
on error undo, return error
:

  define variable v-ret-val as character no-undo .
  define variable v-write   as logical   no-undo .

  define buffer buf_BatchProcess for ub.BatchProcess .

  assign
    v-write = true
  .

  if p-step <> 0 then do:
    find first buf_BatchProcess
      where buf_BatchProcess.BP_Type     = {&btpr-type-autoupg}
        and buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.Key#_One    = p-db-num
        and buf_BatchProcess.Key#_Three  = 0
        and buf_BatchProcess.CharKey_One = p-action
      no-error
    .
    if available buf_BatchProcess then do:
      assign
        v-write = false
      .
    end.
  end.

  if v-write = true then do:
    find first buf_BatchProcess
      where buf_BatchProcess.BP_Type     = {&btpr-type-autoupg}
        and buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.Key#_One    = p-db-num
        and buf_BatchProcess.Key#_Three  = p-step
        and buf_BatchProcess.CharKey_One = p-action
      no-error
    .
    if not available buf_BatchProcess
      and p-flag = "Run":U
    then do:
      create buf_BatchProcess.
      assign
        buf_BatchProcess.BatchProcess# = next-value (s-btpr, {&db-name_schema})
        buf_BatchProcess.BP_Type       = {&btpr-type-autoupg}
        buf_BatchProcess.BP_Status     = {&btpr-normal}
        buf_BatchProcess.Key#_One      = p-db-num
        buf_BatchProcess.Key#_Three    = p-step
        buf_BatchProcess.CharKey_One   = p-action
      .
    end.
    if available buf_BatchProcess then do:
      assign
        buf_BatchProcess.Key#_Two          = ( if p-flag = "Ok":U then 1 else 0 )
        buf_BatchProcess.CharKey_Two       = p-flag
        buf_BatchProcess.User_ID           = p-msg
        buf_BatchProcess.BP_SysDate        = p-date
        buf_BatchProcess.BP_ExecSysDate    = p-date
        buf_BatchProcess.BP_SysTimeInt     = p-time
        buf_BatchProcess.BP_SysTime        = string(p-time, 'HH:MM:SS':U)
        buf_BatchProcess.BP_ExecSysTimeInt = p-time
        buf_BatchProcess.BP_ExecSysTime    = string(p-time, 'HH:MM:SS':U)
      .
      release buf_BatchProcess.
    end.
  end.
  case p-flag :
    when "Ok":U then do:
      assign
        v-ret-val = substitute( "Шаг &1 upgrade в БД &2 выполнен", p-step, p-db-num )
      .
    end.
    when "Err":U then do:
      assign
        v-ret-val = substitute( "Ошибка при выполнении шага &1 upgrade в БД &2", p-step, p-db-num )
      .
    end.
    when "Run":U then do:
      assign
        v-ret-val = substitute( "Получена команда на выполнение шага &1 upgrade в БД &2", p-step, p-db-num )
      .
    end.
  end case.

end.

return v-ret-val .

/* $Workfile: upg-edbp.p $ end */