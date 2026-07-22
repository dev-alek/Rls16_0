block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upgconnt.p $
$Archive: cmp/upgconnt.p $

процедура проверки правильности connect`а к старой БД казахстан

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/16/08
Author: Dmitry Ukhanov
Creation date: 12/16/08

*/

define input parameter p-check-version as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upgconnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/upgconnt.p $":U .
define variable vss-description as character no-undo init "процедура проверки правильности connect`а к старой БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_sys-ctrl for src.sys-ctrl .
  define buffer ub_sys-ctrl for ub.sys-ctrl .
  define buffer buf_config   for src.config .
  define buffer ub_config   for ub.config .
  define buffer buf_upgrade for src.upgrade .

  find first buf_sys-ctrl no-lock .
  find last buf_upgrade  where
          buf_upgrade.db-num      = buf_sys-ctrl.db-num no-error.
  if not available buf_upgrade
  or not (entry(1, buf_upgrade.version-num, ".") = p-check-version
          or
          (entry(1, buf_upgrade.version-num, ".") begins p-check-version
          and p-check-version = {&thth14-from-version}
          )
          )


  then do:
    return error substitute( 'Версия IBS TH подключаемой БД = &1, а предполагалось, что коннектимся к IBS TH версии &2'
                             , (if not available buf_upgrade
                                then {&question-mark}
                                else buf_upgrade.version-num)
                             , p-check-version
                             ) .
  end.
  /*
  if buf_sys-ctrl.db-num <> 0 then do:
    return error substitute( "Подключаться необходимо к ГБД, а данная БД &1", buf_sys-ctrl.db-num ) .
  end.
  */
  find first buf_config exclusive-lock
    where buf_config.param-code = "sys-key":U
    no-error .
  if not available buf_config then do:
    return error substitute( 'В подключаемой БД отсутствует параметр конфигурации sys-key' ) .
  end.
  find first ub_sys-ctrl no-lock.
  define variable v-sys-key as character no-undo .
  { gbl/currsysk.i
    v-sys-key
    no-error
  }
  if buf_config.param-value <> v-sys-key then do:
    /*
    return error substitute( 'Подключаться необходимо к ГБД с ТЕМ ЖЕ САМЫМ КЛЮЧОМ (sys-key) что и в НАШЕЙ БД (&2), а в подключаемой БД sys-key = &1'
                           , buf_config.param-value
                           , ub_config.param-value
                           ) .
    */
  end.
  return .

end.