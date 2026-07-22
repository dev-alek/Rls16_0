block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: checkcnf.p $
$Archive: adm/checkcnf.p $

Проверка наличия обязательных параметров, а так же загрузка любых параметров конфигурации системы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input  parameter p-action as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkcnf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/checkcnf.p $":U .
define variable vss-description as character no-undo init "Проверка наличия обязательных параметров, а так же загрузка любых параметров конфигурации системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ adm/cnf-inc.i &new = "new" }
{ adm/cfg-pr.i  &new = "new" }
{ cmp/trg-def.i new }
{ cmp/library.i  }
{ gbl/get-ro.i   }

&scop err-file "necescnf.txt":U
&scop del-file "del-cnf.txt":U

do
on error  undo, return error
:

  define variable v-ind            as integer       no-undo .
  define variable v-start-time     as int64         no-undo .
  define variable v-current-time   as character     no-undo .
  define variable w-login          as widget-handle no-undo.

  define buffer buf_config  for ub.config .
  define buffer buf1_config for ub.config .

  define stream txt-file . /* файл для импорта и экспорта конфигураций */
  define stream necescnf .
  define stream del-cnf .

  define variable counter       as integer                   no-undo .  /* счетчик считанных записей    */

  define variable p-value       like ub.config.param-value      no-undo .
  define variable p-type        like ub.config.param-type       no-undo .
  define variable err-cnf-param as char                      no-undo .
  define variable err-log       as logical                   no-undo .
  define variable err-code      as integer init -1           no-undo .
  define variable load-cfg-now  as logical init TRUE         no-undo .
  define variable fname-txt     as char                      no-undo .
  define variable fname-cfg     as char    init "config.cfg" no-undo .
  define variable str-hdl       as handle                    no-undo .

  define variable v-curr-db          as integer   no-undo .

  define variable v-check-db-num     as integer   no-undo .
  define variable v-check-user-id    as character no-undo .
  define variable v-check-user-admin as logical   no-undo .

  define variable v-get-ro_read-only as logical   no-undo .

  define frame a
    v-ind           format ">>>>>>>9"   label "Обработано параметров" skip
    v-current-time  format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Проверка конфигурационных параметров"
    .

  if p-action <> "cfg-check":U
    and p-action <> "cfg-load":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка задания входных параметров.") skip
      substitute("action = &1", p-action ) skip
      view-as alert-box error .
    return error.
  end.

  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  { gbl/getcurus.i
    v-check-db-num
    v-check-user-id
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей базы и текущего пользователя" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-curr-db = v-check-db-num
  .
  { gbl/user-adm.i
    v-check-db-num
    v-check-user-id
    v-check-user-admin
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении является ли пользователем администратор" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  create widget-pool .
  create window w-login
    assign
      title              = "Проверка параметров"
      column             = 31.5
      row                = 9
      height             = 2.0
      width              = 30
      resize             = false
      scroll-bars        = false
      status-area        = false
      three-d            = true
      message-area       = false
      sensitive          = true
      visible            = true
      .

  assign
    current-window   = w-login
    g#auto           = false
    g#news           = false
    g#news-source-db = -1
    g#db-num         = v-curr-db
    g#userid         = v-check-user-id
    g#passwd         = ""
  .

  if p-action <> "cfg-load":U then do:
    assign
      v-start-time = etime
    .
    view frame a.
    display
      v-ind
      v-current-time
      with frame a .

    run adm/cnf-str.p persistent set str-hdl no-error.
    if not valid-handle (str-hdl)  then do:
      message "Ошибка при попытке инициализировать работу со схемой конфигурации" view-as alert-box error.
      return error.
    end.

    for each cnf-struct
    on error undo, return error
    :
      delete cnf-struct.
    end.

    os-delete value( {&err-file} ) .


    assign
      fname-txt = {&cnf-struct-file}
    .
    if search( fname-txt ) = ? then do:
      message "Не найден файл схемы настроек" + {&space-char} + fname-txt view-as alert-box error.
      return error.
    end.
    assign
      fname-txt = search( fname-txt )
    .
  end.

  assign
    err-code = -1
    load-cfg-now = true
    .

  do while err-code <> 0 and load-cfg-now = true
  :

    assign
      v-ind         = 0
      err-cnf-param = ""
    .
    if p-action <> "cfg-load":U then do:
      /* чтение схемы конфигурации */
      run fill-cnf-struct in this-procedure
        ( input fname-txt
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при чтении текстового файла схемы!" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return error.
      end.

      for each cnf-struct no-lock
      on error undo, return error
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind mod 10 = 0 then do:
          assign
            v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
          .

          display
            v-ind
            v-current-time
            with frame a.
        end.

        assign
          err-log = false
        .
        find first buf_config no-lock
          where buf_config.param-code = cnf-struct.param-code
            and buf_config.db-num     = v-curr-db
          no-error .
        if available buf_config then do:
          run cnv-param-type in str-hdl (cnf-struct.data-type).
          assign
            cnf-struct.data-type = return-value
          .
          if lookup(cnf-struct.param-type, {&cnf-type-list-protect}) > 0
          then do:
            /* для кодированного параметра, кроме привязанных к АРМу, должено быть значение без привязок */
            { gbl/conf-rd.i
              buf_config.param-code
              '':U
              '':U
              0
              '':U
              '':U
              '':U
              no
              p-value
              p-type
              no-error
            }
            if error-status :error
            or buf_config.param-type <> cnf-struct.data-type
            or buf_config.conf-type  <> cnf-struct.param-type
            then do:
              assign
                err-log = true
              .
            end.
          end.
          for each buf1_config no-lock
              where buf1_config.param-code = cnf-struct.param-code
                and buf1_config.db-num     = v-curr-db
          on error undo, return error
          :
            { gbl/conf-rd.i
              buf1_config.param-code
              buf1_config.host-code
              buf1_config.obj-type
              buf1_config.obj-code
              '':U
              '':U
              '':U
              no
              p-value
              p-type
              no-error
            }
            if error-status:error
              or buf1_config.param-type <> cnf-struct.data-type
              or buf1_config.conf-type  <> cnf-struct.param-type
            then do:
              assign
                err-log = true
              .
            end.
          end.
        end.
        else do:
          if lookup(cnf-struct.param-type, {&cnf-type-list-mandatory}) > 0
          then do:
            assign
              err-log = true
            .
          end.
        end.
        if err-log then do:
          run write-err-conf-list in this-procedure
            ( input cnf-struct.param-code
            ,input v-curr-db
            ,input cnf-struct.param-type
            ,input err-cnf-param
            ).
          assign
            err-cnf-param = err-cnf-param + " ":U + cnf-struct.param-code
            .
        end.
      end.
      for each cnf-struct
      on error undo, return error
      :
        delete cnf-struct.
      end.
    end. /* if p-action <> "cfg-load":U then do: */

    if v-get-ro_read-only = false then do:
      if p-action = "cfg-load":U then do:
        assign
          load-cfg-now = true
        .
      end.
      else do:
        if trim( err-cnf-param ) <> "":U then do:
          if v-check-user-admin <> true then do:
            message
              "Требуется загрузка параметров конфигурации системы!" skip
              "Список требуемых параметров выведен в файл" {&space-char} {&err-file} skip
              "Обратитесь к администратору системы."
              view-as alert-box error.
            assign
              err-code     = 3
              load-cfg-now = false
            .
          end.
          else do:
            message
              "Требуется загрузка параметров конфигурации системы!" skip
              "Список требуемых параметров выведен в файл" {&space-char} {&err-file} skip
              "Список удаленных параметров выведен в файл" {&space-char} {&del-file} skip
              "Загрузить параметры сейчас?" skip
              view-as alert-box question buttons yes-no update load-cfg-now.
            if load-cfg-now <> true then do:
              assign
                err-code = 3
              .
            end.
          end.
        end.
        else do:
          assign
            err-code = 0
            load-cfg-now = false
          .
        end.
      end.
    end.
    else do:
      assign
        load-cfg-now = false
      .
      if trim( err-cnf-param ) <> "":U then do:
        assign
          err-code = 3
        .
        message
          "В ОСНОВНУЮ БД требуется загрузить параметры конфигурации системы!" skip
          "Список требуемых параметров выведен в файл" {&space-char} {&err-file} skip
          "Обратитесь к администратору системы."
          view-as alert-box error.
      end.
      else do:
        assign
          err-code = 0
        .
      end.
    end.

    if load-cfg-now = true then do:
      run adm/wloadcfg.w (input-output fname-cfg).
      if fname-cfg <> ""
        and fname-cfg <> ?
        and fname-cfg <> "?"
      then do:
        run adm/loadcfg.p (fname-cfg, "", "", yes, no, yes, 2, output err-code) no-error.
        if error-status:error then do:
          message error-status:get-message(1).
        end.
        if err-code = 0 then do:
          assign
            err-code = -1 /* для того чтобы проверить правильность всего набора параметров */
          .
          message
            "Параметры загружены успешно"
            view-as alert-box information .
        end.
        else do:
          message
            "Параметры не загружены!" skip
            "Код завершения: " err-code
             view-as alert-box error .
        end.
      end.
      else do:
        message
          "Параметры не загружены!" skip
          "Не задан файл конфигурации." skip
          view-as alert-box error .
        assign
          err-code     = 1
          load-cfg-now = false
          .
      end.
    end.
    if p-action = "cfg-load":U then do:
      assign
        err-code     = 0
        load-cfg-now = false
      .
    end.
  end.

  if p-action <> "cfg-load":U then do:
    run kill1 in str-hdl .
  end.

  hide frame a .

  delete object w-login .

end.

if err-code <> 0 then do:
  return error.
end.
else do:
  return.
end.

procedure write-err-conf-list :

  define input parameter par-code      like ub.config.param-code no-undo .
  define input parameter p-db-num      like ub.config.db-num     no-undo .
  define input parameter cnf-type      like ub.config.conf-type  no-undo .
  define input parameter err-cnf-param as   character            no-undo .

  do transaction
  on error undo, return error
  :
    define variable p-code      like ub.config.param-code no-undo .
    define variable list-p-code as   character            no-undo .
    define variable ind         as   integer              no-undo .

    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .
    define buffer buf_config   for ub.config .

    assign
      list-p-code = par-code
    .

    do ind = 1 to num-entries( list-p-code )
    on error undo, return error
    :
      assign
        p-code = entry( ind, list-p-code )
      .

      if v-check-user-admin = true
      then do:
        output stream del-cnf to {&del-file} page-size 0 append.
        for each buf_config exclusive-lock
          where buf_config.param-code = p-code
            and buf_config.db-num     = p-db-num
        on error undo, return error
        :
          if err-cnf-param = "":U then do:
            put stream del-cnf unformatted
              string("Дата удаления:" + " ":U + cur-time-string() )
              skip
            .
          end.
          export stream del-cnf buf_config .

          assign
            buf_config.stts = -1
          .
          delete buf_config .
        end.
        output stream del-cnf close.
      end.

      if err-cnf-param = "":U then do:
        output stream necescnf to {&err-file}.
        find first buf_sys-ctrl no-lock.
        find first buf_db no-lock
            where buf_db.db-num = buf_sys-ctrl.db-num
            .
        put stream necescnf unformatted
          string("Дата:" + " ":U + cur-time-string() )
          skip
          string("db: ":U + string(buf_db.db-num) + " db-name: ":U + buf_db.db-name + " db-key: ":U + buf_db.db-key )
          skip
        .
      end.
      else do:
        output stream necescnf to {&err-file} page-size 0 append.
      end.
      put stream necescnf unformatted p-code space(1) cnf-type skip.
      output stream necescnf close.
    end.
  end.
end procedure. /* write-err-conf-list */