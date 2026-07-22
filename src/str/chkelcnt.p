block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkelcnt.p $
$Archive: str/chkelcnt.p $

Проверка показаний электронного и механических счетчиков сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Хныкин Павел Андреевич
Дата создания1: 10/31/07

*/
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-rowid       as rowid         no-undo .
define input parameter p-silent      as logical       no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkelcnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkelcnt.p $":U .
define variable vss-description as character no-undo init "Проверка показаний электронного и механических счетчиков сверки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/ptrlprop.i def }

_main-block:
do
on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_rvs-doc         for ub.rvs-doc.
  define buffer prev_rvs-doc        for ub.rvs-doc.
  define buffer buf_rvs-line-pump   for ub.rvs-line-pump.
  define buffer prev_rvs-line-pump  for ub.rvs-line-pump.

  define variable v-is-overflow   as logical    no-undo .
  define variable v-log           as logical    no-undo .

  find first buf_rvs-doc no-lock
    where rowid(buf_rvs-doc) = p-rowid
    no-error .
  if not available buf_rvs-doc then do:
    undo _main-block, return error "Не найдена сверка для проверки показаний счетчиков.":U.
  end.

  if buf_rvs-doc.rvs-type <> {&rvs-shift} then do: /* делаем только для сменных сверок */
    return.
  end.

  { gbl/ptrlprop.i run buf_rvs-doc.obj-type buf_rvs-doc.obj-code }


  if ptrlprop-avtinvpm <> true then do:
    return .
  end.

  find first prev_rvs-doc no-lock
    where prev_rvs-doc.obj-type = buf_rvs-doc.obj-type
      and prev_rvs-doc.obj-code = buf_rvs-doc.obj-code
      and prev_rvs-doc.status_  = {&fact}
      and prev_rvs-doc.rvs-type = {&rvs-shift}
  no-error .
  if not available prev_rvs-doc then do:
    /*
       TODO
         11/16/07 6:28
         искать инвентаризацию?
    */
    return.
  end.

  _rvs-line-pump :
  for each buf_rvs-line-pump no-lock
    where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first prev_rvs-line-pump no-lock
      where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
        and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
        and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
        and prev_rvs-line-pump.pl-code      = buf_rvs-line-pump.pl-code
        and prev_rvs-line-pump.gds-code     = buf_rvs-line-pump.gds-code
        and prev_rvs-line-pump.pump-code    = buf_rvs-line-pump.pump-code
        and prev_rvs-line-pump.nozzle-code  = buf_rvs-line-pump.nozzle-code
    no-error .
    if available prev_rvs-line-pump then do:
      /* сравнить показания эл счетчиков по сверкам */
      if buf_rvs-line-pump.state-el-cnt < prev_rvs-line-pump.state-el-cnt then do:
        assign
          v-is-overflow  = yes
        .
        leave _rvs-line-pump.
      end.
    end.
  end.

  if v-is-overflow = yes then do:
    if p-silent = no then do:
      /* выводим предупреждение */
      message
        "ВНИМАНИЕ!" skip
        "Показания механического счетчика по сверке на конец смены МЕНЬШЕ, чем показания на начало смены." skip
        "Необходимо провести инвентаризацию счетчиков ТРК." skip
        "Сделать это автоматически?":U
      view-as alert-box question buttons yes-no update v-log.
      if v-log <> yes then do:
        undo _main-block, return error "Необходимо создать автоматический документ инвентаризации счетчиков ТРК":U .
      end.
    end.
    /* создаем автоматическую инвентаризацию счетчиков ТРК */
    run str/icntauto.p
      ( input parparentproc
       ,input p-rowid
      ) no-error .
    if error-status :error then do:
      undo _main-block, return error return-value .
    end.

    for each buf_rvs-line-pump no-lock
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
    on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      find first prev_rvs-line-pump no-lock
        where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
          and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
          and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
          and prev_rvs-line-pump.pl-code      = buf_rvs-line-pump.pl-code
          and prev_rvs-line-pump.gds-code     = buf_rvs-line-pump.gds-code
          and prev_rvs-line-pump.pump-code    = buf_rvs-line-pump.pump-code
          and prev_rvs-line-pump.nozzle-code  = buf_rvs-line-pump.nozzle-code
        no-error .
      if available prev_rvs-line-pump then do:
        /* сравнить показания мех счетчиков по сверкам */
        if buf_rvs-line-pump.state-mh-cnt < prev_rvs-line-pump.state-mh-cnt then do:
          undo _main-block, return error substitute( "Показания механического счетчика ТРК &1 пистолет &2 на конец смены меньше чем на начало.&3"
                                                     + "Невозможно закрыть сверку"
                                                    , prev_rvs-line-pump.pump-code
                                                    , prev_rvs-line-pump.nozzle-code
                                                    , {&new-line}
                                                    ).
        end.
      end.
    end.

  end.
end.