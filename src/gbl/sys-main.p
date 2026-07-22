block-level on error undo, throw.
/*

$Revision: 56df01381172, 3646, test $
$Author: EShklyar $
$Date: 2024/01/25 16:33:00 $
$Workfile: sys-main.p $
$Archive: gbl/sys-main.p $

Головной модуль системы

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 56df01381172, 3646, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2024/01/25 16:33:00 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sys-main.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sys-main.p $":U .
define variable vss-description as character no-undo init "Головной модуль системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i new }
{ gbl/cur-time.i }
{ gbl/cmptime.i  }
{ gbl/sys-time.i }
{ gbl/get-ro.i   }

define variable conf-par               as character no-undo .
define variable par-type               as character no-undo .
define variable v-today                as date      no-undo .
define variable v-time                 as integer   no-undo .
define variable v-diff-time            as decimal   no-undo .
define variable v-max-diff-minute      as integer   no-undo initial 3 .
define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .
define variable v-connect-usr          as integer   no-undo .
define variable v-connect-device       as character no-undo .
define variable v-userio-id            as integer   no-undo .

define variable v-get-ro_read-only     as logical   no-undo .

define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .

define buffer buf_sys-ctrl     for ub.sys-ctrl .
define buffer buf_user-account for ub.user-account .
define buffer buf_user-login   for ub.user-login .
define buffer buf_db           for ub.db .

define variable v-TH-name as character no-undo .

do
on error undo, return error return-value
:

  run sys-time_get-comp-user-name in this-procedure
    (output v-computer-name
    ,output v-computer-login-name
    ,output v-computer-process-pid
    ) .

  run cmptime in this-procedure
    (output v-diff-time
    ).

  if absolute(v-diff-time) > v-max-diff-minute
  then do:
    v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=110" + {&delim-par} + "Description=Время на компьютере отличается от времени на сервере" .
    run trg/video-action.p (input 50,
                        input v-vid-param,
                        output v-vid-ok,
                        output v-vid-mes) .
    message
      "Текущее время на Вашем компьютере " skip
      "" (if v-diff-time < 0 then "больше" else "меньше" ) " времени на сервере " skip
      "на " truncate( abs( v-diff-time ), 0 ) "минут(ы)" skip (1)
      substitute("Время на компьютере и время на сервере не должны различаться более чем на &1 минуты."
                ,v-max-diff-minute
                ) skip (1)
      substitute("Вход в систему с компьютера &1 невозможен", v-computer-name) skip
      view-as alert-box error .
    return . /* --->>>-- */
  end.

  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  do transaction
  on error undo, return error return-value
  :
    /* при выходе из блока на запись buf_user-account будет наложена блокировка share-lock */
    /* до конца работы пользователя в системе */
    find first buf_sys-ctrl no-lock .

    if v-get-ro_read-only = false then do:
      find buf_user-login exclusive-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = {&uls-normal}
          and buf_user-login.user-login = p-user-login
        no-error no-wait .
    end.
    else do:
      find buf_user-login no-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = {&uls-normal}
          and buf_user-login.user-login = p-user-login
        no-error .
    end.
    if not available buf_user-login
    then do:
      if locked buf_user-login
        and v-get-ro_read-only = false
      then do:
        find buf_user-login no-lock
          where buf_user-login.db-num     = buf_sys-ctrl.db-num
            and buf_user-login.status_    = {&uls-normal}
            and buf_user-login.user-login = p-user-login
          no-error .
        if available buf_user-login
        then do:

          define variable v-user-name as character no-undo .
          { gbl/usrfulnm.i
            buf_user-login.user-id
            v-user-name
          }
          
          v-vid-param = "Login=" + p-user-login + {&delim-par} + "THname=" + v-user-name + {&delim-par} + "RESULT=111" + {&delim-par} + "Description=Такой пользователь уже работает в системе." .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .

          message
            substitute("Пользователь &1 уже работает в системе", p-user-login) skip
            "Идентификатор пользователя"   buf_user-login.user-id skip
            "Имя пользователя"             v-user-name skip
            "Компьютер"                    buf_user-login.last-login-computer-name skip
            "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
            "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
            "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
            "Идентификатор процесса"       buf_user-login.last-login-process-id skip
            "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
            "Дата и время входа в систему" sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd) skip
            view-as alert-box error .
        end.
        else do:
          v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=112" + {&delim-par} + "Description=Такой пользователь уже работает в системе." .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
          message
            substitute("Пользователь &1 уже работает в системе", p-user-login) skip
            view-as alert-box error .
        end.
      end.
      else do:
        v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=113" + {&delim-par} + "Description=Не найден такой пользователь." .
        run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
        message
          substitute("Не найден пользователь &1", p-user-login) skip
          "Невозможно продолжить работу системы" skip
          view-as alert-box error .
      end.
      return.
    end.
    define variable v-last-login-mjd as decimal   no-undo .
    assign
      v-last-login-mjd = sys-time_get-mjd-func()
    .

    run gbl/getconn.p
      (output v-connect-usr
      ,output v-connect-device
      ,output v-userio-id
      ) .

    run gbl/tcp-info.p
      (output v-computer-tcp-name
      ,output v-computer-ip-addr
      ) .

    if v-get-ro_read-only = false then do:
      assign
        buf_user-login.last-login-computer-name     = v-computer-name
        buf_user-login.last-login-computer-user     = v-computer-login-name
        buf_user-login.last-login-computer-tcp-name = v-computer-tcp-name
        buf_user-login.last-login-computer-ip-addr  = v-computer-ip-addr
        buf_user-login.last-login-process-id        = v-computer-process-pid
        buf_user-login.last-login-connection-id     = v-connect-usr
        buf_user-login.last-login-mjd               = v-last-login-mjd
      .
    end.
   /* нельзя переносить ниже так как тогда создастся не правильно история по пользователю */
    run gbl/set-gbl.p
    (input false                  /* p-auto        */
    ,input buf_user-login.user-id /* p-user-id     */
    ,input p-user-password        /* p-user-passwd */
    ) no-error .
    if error-status :error
    then do:
       v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=114" + {&delim-par} + "Description=Ошибка при установке глобальных переменных." .
       run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
       message
      vss-workfile vss-revision vss-description skip
      "Ошибка при установке глобальных переменных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
       return .
     end.
  end.

  do transaction:
    find first buf_db exclusive-lock where buf_db.db-num = buf_sys-ctrl.db-num and buf_db.reserve2-char = "deferred-callnews" no-error.
    if available (buf_db)
    then do:
      buf_db.reserve2-char = "".
      release buf_db.
    end. 
  end.
  
  { gbl/conf-rd.i
    "'lcns-lim':U"
    "'':U"
    "'':U"
    0
    "'':U"
    "'':U"
    "'':U"
    yes
    conf-par
    par-type
    no-error
  }
  if error-status :error
  then do:
    return. /* --->>>--- */
  end.
  if par-type <> {&type-date}
  then do:
    message
      "Неправильный тип параметра lcns-lim (должно быть date)."
      view-as alert-box error.
    return. /* --->>>--- */
  end.
  if date (conf-par) <> ?
  then do:
    /* ограничение срока лицензии включено */
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).
    define variable v-license-left-day as integer   no-undo .
    assign
      v-license-left-day = date (conf-par) - v-today
    .
    if v-license-left-day <= 15
    then do:
      message
        "Срок действия лицензии истекает" date (conf-par) skip
        substitute("Осталось &1 дней", v-license-left-day) skip
        view-as alert-box error.
    end.
    if v-license-left-day < 0
    then do:
      v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=115" + {&delim-par} + "Description=Срок действия лицензии закончился." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Срок действия лицензии закончился" date (conf-par) skip
        "Вход в систему невозможен" skip
        view-as alert-box error.
      return . /* --->>>--- */
    end.
  end.

  if v-get-ro_read-only = false then do:
    { gbl/conf-rd.i
      "'usr-num':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      yes
      conf-par
      par-type
      no-error
    }
    if error-status :error
    then do:
      return. /* --->>>--- */
    end.
    if par-type <> {&type-int}
    then do:
      message
        "Неправильный тип параметра usr-num (должно быть integer)."
        view-as alert-box error .
      return. /* --->>>--- */
    end.
    define variable v-license-usr-num as integer   no-undo .
    define variable v-work-usr-num    as integer   no-undo .
    assign
      v-license-usr-num = integer (conf-par)
    .

    /* определить общее количество пользователей */
    run adm/isanybdy.p
      (input  false          /* p-check-menu-group */
      ,input  0              /* p-menu-group-id    */
      ,input  '':U           /* p-menu-group-id    */
      ,output v-work-usr-num /* p-total-user-num   */
      ).
    if v-license-usr-num = ?
    then do:
      v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=116" + {&delim-par} + "Description=Не задано количество пользователей системы." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Доступ запрещен: не задано количество пользователей системы" conf-par skip
        view-as alert-box error.
      return.
    end.
    if v-work-usr-num >= v-license-usr-num
    then do:
      v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=117" + {&delim-par} + "Description=Превышено число пользователей системы." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Доступ запрещен: превышено число пользователей" conf-par skip
        view-as alert-box error.
      return .
    end.


    /* принудительная инициализация некоторых особо важных сиквенсов */
    if current-value (s-bcgb-code, {&db-name_schema}) < 100000
    then do:
      assign
        current-value (s-bcgb-code, {&db-name_schema}) = 100000
      .
    end.
    if current-value (s-sclc-code, {&db-name_schema}) < 100
    then do:
      assign
        current-value (s-sclc-code, {&db-name_schema}) = 100
      .
    end.
    if current-value (s-scgb-code, {&db-name_schema}) < 100
    then do:
      assign
        current-value (s-scgb-code, {&db-name_schema}) = 100
      .
    end.
    if current-value (s-news-ord, {&db-name_schema}) < 0
    then do:
      assign
        current-value (s-news-ord, {&db-name_schema}) = 0
      .
    end.
  end.

  run gbl/update.p no-error .
  if error-status :error then do:
    v-vid-param = "Login=" + p-user-login + {&delim-par} + "RESULT=118" + {&delim-par} + "Description=Ошибка при проверке соответствия r-cod-ов внутренним структурам данных." .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.

  if v-get-ro_read-only = false then do:
    run adm/infdbnws.p no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при анализе/записи информации о БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return .
    end.
  end.
  
  run ibs/th/adm/upd/sendschedule.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при отправке начальных расписаний автозаданий в 1С" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  
  if available buf_user-login
  then do :
      
          { gbl/usrfulnm.i
            buf_user-login.user-id
            v-TH-name
          }
      
  end.
  
  v-vid-param = "Login=" + p-user-login + {&delim-par} + 
                (if v-TH-name <> "" then ("THname=" + v-TH-name + {&delim-par}) else "") +
                "RESULT=0" + {&delim-par} + 
                "Description=" .
  run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .

  run gbl/mainmenu.w
    (input v-computer-process-pid
    ,input buf_user-login.user-id
    ,input p-user-password
    ) no-error .
  if error-status :error
  then do:
    message
      "Ошибка вызова основного окна системы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error.
  end.
end.