block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: update.p $
$Archive: gbl/update.p $

Проверка соответствия r-cod- ов внутренним структурам данных и запуск выправляющих утилит

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/22/04
Author: Bakhtadze Natalya
Creation date: 11/22/04

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: update.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/update.p $":U .
define variable vss-description as character no-undo init "Проверка соответствия r-cod- ов внутренним структурам данных и запуск выправляющих утилит".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/get-ro.i   }

define buffer buf_sys-ctrl for ub.sys-ctrl.

define variable v-proc-name        as character no-undo .
define variable v-sys-key          as character no-undo .
define variable v-get-ro_read-only as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.

  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  run trg/fixattrp.p ( input no
                      ,input v-get-ro_read-only
                       ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация атрибутов)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fixdr.p ( input no
                   ,input v-get-ro_read-only
                  ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Правила скидок)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fixhn.p ( input no
                   ,input v-get-ro_read-only
                   ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Настройка ист/маршр)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fixcstml.p ( input no
                      ,input v-get-ro_read-only
                     ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация настраиваемых полей)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fix-gate.p ( input no
                      ,input v-get-ro_read-only
                     ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация Gate)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fixrum.p ( input no
                    ,input v-get-ro_read-only
                  ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация RUM)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
  run trg/fix-lay.p ( input no
                      ,input v-get-ro_read-only) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация раскладок)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.

  run trg/fixthbj.p ( input no
                      ,input v-get-ro_read-only) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных (Конфигурация настроек по объектам TH)" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.

  run adm/fix-par.p ( input no
                    , input v-get-ro_read-only
                    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке/инициализации параметров при запуске ТН" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.

  run adm/fix-atgo.p ( input no
                      , input v-get-ro_read-only
                      ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке/инициализации атрибутов при запуске ТН" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.

  /*сюда добавлять новые процедуры проверки и обновления конфигурации*/


/*проверка и обновления конфигурации под текущего заказчика*/

  find first buf_sys-ctrl no-lock .
  assign
    v-sys-key   = buf_sys-ctrl.sys-key
    v-proc-name = search( substitute("utl/&1_on.r", v-sys-key))
  .
  if v-proc-name = ?
  or v-proc-name = '' then do:
    assign
      v-proc-name = search( substitute("utl/&1_on.p", v-sys-key))
    .
  end.

  if v-proc-name <> ?
  and v-proc-name <> '' then do:
    run value(v-proc-name) ( input ?
                           , input v-get-ro_read-only
                           ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при специфической проверке и обновлении корректности текущей конфигурации &1", v-sys-key) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.
  end.
end. /*doe*/