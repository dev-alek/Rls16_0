block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: update.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/update.p $":U .
define variable vss-description as character no-undo init "Проверка соответствия r-cod- ов внутренним структурам данных и запуск выправляющих утилит".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info0, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info0 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define buffer buf_sys-ctrl for ub.sys-ctrl.
define variable v-proc-name        as character no-undo .
define variable v-sys-key          as character no-undo .
define variable v-get-ro_read-only as logical   no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
end.
