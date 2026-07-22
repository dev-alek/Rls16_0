block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: loadcfg.p $
$Archive: adm/loadcfg.p $

Загрузка параметров настройки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/* ***************************  Definitions  ************************** */
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U.
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
def var vss-workfile    as character no-undo init "$Workfile: loadcfg.p $":U.
def var vss-archive     as character no-undo init "$Archive: adm/loadcfg.p $":U.
def var vss-description as character no-undo init "Загрузка конфигурационных параметров".

{ cmp/vssrevis.i }
{ adm/cnf-inc.i &new = "new"}
{ adm/cfg-pr.i &new = "new"}

/* входящие параметры   */

define input parameter  cnf-fname        as character no-undo . /* файл с параметрами,
                                                           если передано пустое, то выполняется попытка
                                                           найти файл с именем по умолчанию в ProPath
                                                           (см. CNF-inc.i) config.cfg */
define input parameter  cnf-struct-fname as character no-undo . /* файл с настройкой
                                                            если передано пустое, то выполняется попытка
                                                            найти файл с именем по умолчанию в ProPath
                                                            (см. CNF-inc.i)  config.txt */
define input parameter  log-fname        as character no-undo . /* файл для вывода ошибок,
                                                            если передано пустое, то создается файл с
                                                            именем {&log-file} в текущей директории */
define input parameter  app-parameter    as logical   no-undo . /* Параметры добавлять к существующим */
define input parameter  app-message      as logical   no-undo . /* Писать сообщения в конец существующего файла */
define input parameter  chg-encode       as logical   no-undo . /* Разрешить изменение кодированных параметров */
define input parameter  err-block        as integer   no-undo . /* Уровень ошибок, блокирующих запись
                                                                   1 - все ошибки, 2 - очень серьезные */

define output parameter result           as integer   no-undo . /* код завершени
                                                                     0    - удачно
                                                                     1, 2 - ошибки загрузки параметров
                                                                     3    - полный облом
                                                                 */

&scop log-file "err-conf.txt"

&scop return-3 do: result = 3 . run go-out in this-procedure . return. end.


do
on error undo, return error return-value
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .

  create widget-pool .
  define variable w-loadcfg as widget-handle no-undo.
  create window w-loadcfg
  assign
    title              = "Загрузка параметров конфигурации"
    column             = 31.5
    row                = 9
    height             = 2.0
    width              = 35
    resize             = false
    scroll-bars        = false
    status-area        = false
    three-d            = true
    message-area       = false
    sensitive          = true
    visible            = true
  .

  assign
    current-window = w-loadcfg
  .

  define variable Cnf-hdl      as handle    no-undo .       /* ссылка на библиотеку работы с настройкой конфигурации*/
  define variable CurCnf-hdl   as handle    no-undo .       /* ссылка на библиотеку работы с конфигурацией */
  define variable dbCnf-hdl    as handle    no-undo .       /* ссылка на библиотеку работы с базой */
  define variable v-err-code   as integer   no-undo .

  assign
    result = 0
  .

  /* загружаем библиотеки */
  run adm/cnf-str.p persistent set cnf-hdl no-error.
  if not valid-handle (cnf-hdl) then do:
    {&return-3}
  end.
  if log-fname = "" then do:
    assign
      log-fname = {&log-file}
    .
  end.
  run init in cnf-hdl
    (input  log-fname   /* имя протокола */
    ,input  no         /* сообщения пользователю не выводим никогда! */
    ,input  app-message
    ) no-error .
  if return-value <> "":U then do:
    {&return-3}          /* не смогли записать протокол */
  end.
  run adm/cnf-db.p persistent set dbCnf-hdl no-error.
  if not valid-handle (dbCnf-hdl) then do:
    {&return-3}
  end.
  run init in dbCnf-hdl
    ( input cnf-hdl
    ) no-error.
  if return-value <> "":U then do:
    {&return-3}          /* не смогли записать протокол */
  end.
  run adm/cnf-cnf.p persistent set CurCnf-hdl no-error.
  if not valid-handle (CurCnf-hdl) then do:
    {&return-3}
  end.
  run init in CurCnf-hdl
    ( input cnf-hdl
    , input dbcnf-hdl
    ) no-error.
  if return-value <> "":U then do:
    {&return-3}
  end.

  if cnf-struct-fname = "":U then do:
    assign
      cnf-struct-fname = search( {&cnf-struct-file} )
    .
    if cnf-struct-fname = ? then do:
      run log-sys-error in cnf-hdl( "Не найден файл схемы конфигурации" ).
      {&return-3}
    end.
  end.

  /* чтение схемы конфигурации */
  run fill-cnf-struct in this-procedure
    ( input cnf-struct-fname
    ) no-error.
  if error-status :error then do:
    run log-sys-error in cnf-hdl( "Ошибка при чтении файл схемы конфигурации" ).
    {&return-3}
  end.

  /* читаем ключ текущей базы */
  find first buf_sys-ctrl no-lock no-error.
  if not available buf_sys-ctrl then do:
    run log-sys-error in cnf-hdl( "Ошибка при чтении sys-ctrl" ).
    {&return-3}
  end.
  /* загружаем параметры */
  if app-parameter = true then do:
      run LoadDB in dbCnf-hdl
        no-error.
      if error-status:error then do:
        run log-sys-error in cnf-hdl (substitute( "&1", return-value ) ).
        {&return-3}
      end.
      if return-value <> "" then do:
        assign
          v-err-code = integer( return-value )
        .
        if v-err-code > 1 then do:
          assign
            result = v-err-code
          .
          run go-out in this-procedure .
          return.
        end.
      end.
  end.

  run import in CurCnf-hdl
    ( input cnf-fname
     ,input no
     ,input yes
     ,input no
     ,input (if buf_sys-ctrl.db-num = 0 then "":U else string( buf_sys-ctrl.db-num ) )
    ) no-error.
  if error-status:error then do:
    run log-sys-error in cnf-hdl (substitute( "&1", return-value ) ).
    {&return-3}
  end.
  if return-value <> "" then do:
    assign
      v-err-code = integer( return-value )
    .
    if v-err-code > 1 then do:
      assign
        result = v-err-code
      .
      run go-out in this-procedure .
      return.
    end.
  end.

  /* осталось только сохранить */
  run save-cfg in dbcnf-hdl
    ( input chg-encode
    ) no-error.
  if error-status:error then do:
    run log-sys-error in cnf-hdl (substitute( "&1", return-value ) ).
    {&return-3}
  end.
  if return-value <> "" then do:
    assign
      v-err-code = integer( return-value )
    .
    if v-err-code > 1 then do:
      assign
        result = v-err-code
      .
      run go-out in this-procedure .
      return.
    end.
  end.

  /* и удалить библиотеки */
  run go-out in this-procedure .

  delete object w-loadcfg .
end.



procedure go-out :
  /* корректный выход с удаление библиотек */

  if valid-handle (cnf-hdl)
  then do:
    run kill in cnf-hdl no-error.
  end.
  if valid-handle (curcnf-hdl)
  then do:
    run kill in curcnf-hdl no-error.
  end.
  if valid-handle (dbcnf-hdl)
  then do:
    run kill in dbcnf-hdl no-error.
  end.
  return.
end procedure.