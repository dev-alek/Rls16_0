/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mt-route.p $
$Archive: gbl/mt-route.p $

Маршрутизатор сообщений радиотерминала

Автор: Хныкин Павел Андреевич
Дата создания: 07/24/08
Author: Pavel Khnykin
Creation date: 07/24/08

1  - Валидация настроек мягких чеков
2  - Открытие чека на кассе
3  - Ввод строки чека
4  - Закрытие чека
5  - Аннуляция чека
6  - Изменение строки чека
7  - Удаление строки чека
8  -
9  -
10 -
11 -
12 - Авторизация пользователя. Открытие сессии.
13 - Завершение сессии.
14 -
15 -
16 -
17 -
18 -
19 -
20 -
21 -
22 -
23 -
24 -
25 -
26 -

*/
using Ibs.Th.Gbl.XmlFilder.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mt-route.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mt-route.p $":U .
define variable vss-description as character no-undo init "Маршрутизатор сообщений радиотерминала ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/cur-time.i }

define temp-table tt-session no-undo
  field session-id        as character
  field last-update-date  as date
  field last-update-time  as integer
index pi is primary unique
  session-id
.


define buffer buf_tt-session for tt-session.

define variable v-xml-filder  as class XmlFilder  no-undo .

define variable v-data-valid        as logical   no-undo .
define variable v-err-message       as character no-undo .
define variable v-device-id         as character no-undo .

define variable v-mt-route_session-timeout  as integer   no-undo .
define variable v-mt-route_user-num         as integer   no-undo .
define variable v-mt-route_pos-code         as integer   no-undo .
define variable v-mt-route_parenthandle     as handle    no-undo .

procedure mt-route_init :
  define input  parameter parparentproc     as handle    no-undo .
  define input  parameter p-pos-code        as integer   no-undo .
  define input  parameter p-user-num        as integer   no-undo .
  define input  parameter p-session-timeout as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    v-mt-route_pos-code         = p-pos-code
    v-mt-route_user-num         = p-user-num
    v-mt-route_session-timeout  = p-session-timeout
    v-mt-route_parenthandle     = parparentproc
  .

end.

end procedure. /* mt-route_init */


procedure mt-route_init-session :
  define input  parameter p-session-id  as character no-undo .
  define output parameter p-registred   as logical   no-undo .
  define output parameter p-message     as character no-undo .

do
on error undo, return error return-value
:
  define variable v-session-num     as integer   no-undo .
  define variable v-session-valid   as logical   no-undo .
  define variable v-message         as character no-undo .

  run mt-route_check-session in this-procedure ( input p-session-id
                                               , input no
                                               , output v-session-valid
                                               , output v-message
                                               ) .
  if v-session-valid = yes
  then do:
    assign
      p-registred = yes
    .
    return . /* --->>>--- */
  end.

  for each buf_tt-session:
    assign
      v-session-num = v-session-num + 1
    .
  end.

  if v-session-num < v-mt-route_user-num
  then do:
    find first buf_tt-session
      where buf_tt-session.session-id = p-session-id
    no-error .
    if not available buf_tt-session
    then do:
      define variable v-date as date      no-undo .
      define variable v-time as integer   no-undo .

      run cur-time in this-procedure ( output v-date
                                     , output v-time
                                     ) .
      create buf_tt-session.
      assign
        buf_tt-session.session-id       = p-session-id
        buf_tt-session.last-update-date = v-date
        buf_tt-session.last-update-time = v-time
        v-session-num                   = v-session-num + 1
        p-registred                     = yes
      .
      run mt-serv_write-user-num  in v-mt-route_parenthandle ( input v-session-num ) .
    end.
  end.
  else do:
    assign
      p-message = substitute( "Превышено максимальное число пользователей. Сейчас в системе: &1 ."
                            , v-session-num
                            )
    .
  end.

end.

end procedure. /* mt-route_init-session */


procedure mt-route_delete-session :
  define input  parameter p-session-id as character no-undo .
do
on error undo, return error return-value
:
  define variable v-session-num as integer   no-undo .

  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if available buf_tt-session
  then do:
    delete buf_tt-session .
    for each buf_tt-session:
      assign
        v-session-num = v-session-num + 1
      .
    end.
    run mt-serv_write-user-num in v-mt-route_parenthandle ( input v-session-num ) .
  end.
end.

end procedure. /* mt-route_delete-session */


procedure mt-route_check-session :
  define input  parameter p-session-id      as character no-undo .
  define input  parameter p-update-session  as logical   no-undo .
  define output parameter p-session-valid   as logical   no-undo .
  define output parameter p-message         as character no-undo .

do
on error undo, return error return-value
:
  define variable v-date    as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-timeout as integer   no-undo .


  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if not available buf_tt-session
  then do:
    assign
      p-session-valid = false
      p-message      = substitute(" Не найдена сессия &1" , p-session-id)
    .
    return . /* --->>>--- */
  end.

  /*
      TODO
        08/06/08 12:51
    Проверку дат
  */

  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .

  if buf_tt-session.last-update-date > v-date
  then do:
    assign
      p-session-valid = false
      p-message      = substitute("Календарная дата открытия сесии &1 отличается." , p-session-id)
    .
    return . /* --->>>--- */

  end.
  assign
    v-timeout = v-time - buf_tt-session.last-update-time
  .

  if v-timeout > v-mt-route_session-timeout
  then do:
    assign
      p-session-valid = false
      p-message      = substitute( "Превышен таймаут сессии &1.&2Таймаут: &3"
                                  , p-session-id
                                  , {&new-line}
                                  , string(v-timeout, "hh:mm:ss")
                                  )
    .
    run mt-route_delete-session in this-procedure (input p-session-id) .
    return . /* --->>>--- */
  end.

  if p-update-session = yes
  then do:
    assign
      buf_tt-session.last-update-date = v-date
      buf_tt-session.last-update-time = v-time
    .
  end.

  assign
    p-session-valid = true
  .
end.

end procedure. /* mt-route_check-session */


procedure mt-route_update-session :
  define input  parameter p-session-id    as character no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if available buf_tt-session
  then do:
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .

    run cur-time in this-procedure ( output v-date
                                    , output v-time
                                    ) .
    assign
      buf_tt-session.last-update-date = v-date
      buf_tt-session.last-update-time = v-time
    .
  end.
end.

end procedure. /* mt-route_update-session */


procedure mt-route_process-request :
  define input  parameter parparentproc   as handle    no-undo .
  define input  parameter p-req-num       as integer   no-undo .
  define input  parameter p-message-str   as character no-undo .
  define output parameter p-send-message  as character no-undo .

do
on error undo, return error return-value
:
  v-xml-filder = new XmlFilder() .
  run mt-route_init-route in this-procedure ( input   parparentproc
                                            , input   p-req-num
                                            , input   p-message-str
                                            , output  p-send-message
                                            ).

  delete object v-xml-filder.
  assign
    v-xml-filder = ?
    p-send-message = codepage-convert( p-send-message , "UTF-8" )
  .

end.

end procedure. /* mt-route_process-route */

/* ----------------------------------------------------------------- */
procedure mt-route_init-route :
  define input  parameter parparentproc   as handle    no-undo .
  define input  parameter p-req-num       as integer   no-undo .
  define input  parameter p-message-str   as character no-undo .
  define output parameter p-send-message  as character no-undo .
do
on error undo, return error return-value
:

/* =========================================================== */
&scop check-data-valid if v-data-valid <> yes then do: ~
  run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2' ~
                                                                     , p-req-num ~
                                                                     , v-err-message ~
                                                                     ) ~
                                                   , output p-send-message ~
                                                   ) . ~
  return. /* --->>>--- */ ~
end.


/* =========================================================== */
&scop check-session-valid ~
define variable v-session-valid~{&seqnum~}   as logical   no-undo . ~
define variable v-session-message~{&seqnum~} as character no-undo . ~
run mt-route_check-session in this-procedure ( input  v-device-id ~
                                             , input yes ~
                                             , output v-session-valid~{&seqnum~} ~
                                             , output v-session-message~{&seqnum~} ~
                                             ) no-error . ~
if error-status :error ~
then do: ~
  run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session." ~
                                                             , output p-send-message ~
                                                             ) . ~
  return . /* --->>>--- */ ~
end. ~
if v-session-valid~{&seqnum~} <> true ~
then do: ~
  run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message~{&seqnum~} ~
                                                             , output p-send-message ~
                                                             ) . ~
  return . /* --->>>--- */ ~
end. ~
/* =========================================================== */


  define variable v-msg-str as character no-undo .

  assign
    v-msg-str = /*codepage-convert(*/ p-message-str /* , "1251" )*/
  .

  case p-req-num:
    when 1
    then do:

      define variable v-user-login-1        as character no-undo .
      define variable v-user-password-1     as character no-undo .
      define variable v-obj-type-1          as character no-undo .
      define variable v-obj-code-1          as integer   no-undo .


      run parse-req-1 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-1
                                        , output v-obj-type-1
                                        , output v-obj-code-1
                                        ).
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run gbl/mtreq001.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-1
                         , input  v-obj-type-1
                         , input  v-obj-code-1
                         , output p-send-message
                         ).
    end.
    when 2
    then do:
      define variable v-user-login-2        as character no-undo .
      define variable v-user-password-2     as character no-undo .
      define variable v-obj-type-2          as character no-undo .
      define variable v-obj-code-2          as integer   no-undo .

      run parse-req-2 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-2
                                        , output v-obj-type-2
                                        , output v-obj-code-2
                                        ).
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}
      run gbl/mtreq002.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-2
                         , input  v-obj-type-2
                         , input  v-obj-code-2
                         , input  v-mt-route_pos-code
                         , output p-send-message
                         ).


    end.
    when 3
    then do:
      define variable v-3-doc-code       as character no-undo .
      define variable v-3-line-num       as integer   no-undo .
      define variable v-3-mode           as character no-undo .
      define variable v-3-src-code       as character no-undo .
      define variable v-3-src-qnty       as decimal   no-undo .
      define variable v-3-pump           as integer   no-undo .
      define variable v-3-nozzle-code    as integer   no-undo .
      define variable v-3-pl-code        as integer   no-undo .
      define variable v-3-write-off-code as integer   no-undo .
      define variable v-3-pass-gds       as integer   no-undo .
      define variable v-3-fbr-depart     as integer   no-undo .
      define variable v-3-user-login     as character no-undo .
      define variable v-3-user-password  as character no-undo .
      define variable v-3-obj-type       as character no-undo .
      define variable v-3-obj-code       as integer   no-undo .

      run parse-req-3 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-3-user-login
                                        , output v-3-obj-type
                                        , output v-3-obj-code
                                        , output v-3-doc-code
                                        , output v-3-line-num
                                        , output v-3-mode
                                        , output v-3-src-code
                                        , output v-3-src-qnty
                                        , output v-3-pump
                                        , output v-3-nozzle-code
                                        , output v-3-pl-code
                                        , output v-3-write-off-code
                                        , output v-3-pass-gds
                                        , output v-3-fbr-depart
                                        ) .
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run gbl/mtreq003.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-3-user-login
                         , input  v-3-obj-type
                         , input  v-3-obj-code
                         , input  v-3-doc-code
                         , input  v-3-line-num
                         , input  v-3-mode
                         , input  v-3-src-code
                         , input  v-3-src-qnty
                         , input  v-3-pump
                         , input  v-3-nozzle-code
                         , input  v-3-pl-code
                         , input  v-3-write-off-code
                         , input  v-3-pass-gds
                         , input  v-3-fbr-depart
                         , output p-send-message
                         ) .

    end.

    when 4
    then do :
      define variable v-doc-code-4       as character no-undo .
      run parse-req-4 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-doc-code-4
                                        ) .
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run gbl/mtreq004.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-doc-code-4
                         , output p-send-message
                         ) .
    end.

    when 5
    then do :
      define variable v-5-doc-code       as character no-undo .

      run parse-req-5 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-5-doc-code
                                        ) .
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run gbl/mtreq005.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-5-doc-code
                         , output p-send-message
                         ) .
    end.

    when 6
    then do :
      define variable v-doc-code-6       as character no-undo .
      define variable v-line-num-6       as integer   no-undo .
      define variable v-mode-6           as character no-undo .
      define variable v-src-code-6       as character no-undo .
      define variable v-src-qnty-6       as decimal   no-undo .
      define variable v-pump-6           as integer   no-undo .
      define variable v-nozzle-code-6    as integer   no-undo .
      define variable v-pl-code-6        as integer   no-undo .
      define variable v-write-off-code-6 as integer   no-undo .
      define variable v-pass-gds-6       as integer   no-undo .
      define variable v-fbr-depart-6     as integer   no-undo .
      define variable v-user-login-6     as character no-undo .
      define variable v-user-password-6  as character no-undo .
      define variable v-obj-type-6       as character no-undo .
      define variable v-obj-code-6       as integer   no-undo .

      run parse-req-6 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-6
                                        , output v-obj-type-6
                                        , output v-obj-code-6
                                        , output v-doc-code-6
                                        , output v-line-num-6
                                        , output v-mode-6
                                        , output v-src-code-6
                                        , output v-src-qnty-6
                                        , output v-pump-6
                                        , output v-nozzle-code-6
                                        , output v-pl-code-6
                                        , output v-write-off-code-6
                                        , output v-pass-gds-6
                                        , output v-fbr-depart-6
                                        ) .
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}
      run gbl/mtreq006.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-6
                         , input  v-obj-type-6
                         , input  v-obj-code-6
                         , input  v-doc-code-6
                         , input  v-line-num-6
                         , input  v-mode-6
                         , input  v-src-code-6
                         , input  v-src-qnty-6
                         , input  v-pump-6
                         , input  v-nozzle-code-6
                         , input  v-pl-code-6
                         , input  v-write-off-code-6
                         , input  v-pass-gds-6
                         , input  v-fbr-depart-6
                         , output p-send-message
                         ) .

    end.

    when 7
    then do :
      define variable v-doc-code-7       as character no-undo .
      define variable v-line-num-7       as integer   no-undo .
      define variable v-mode-7           as character no-undo .
      define variable v-src-code-7       as character no-undo .
      define variable v-src-qnty-7       as decimal   no-undo .
      define variable v-pump-7           as integer   no-undo .
      define variable v-nozzle-code-7    as integer   no-undo .
      define variable v-pl-code-7        as integer   no-undo .
      define variable v-write-off-code-7 as integer   no-undo .
      define variable v-pass-gds-7       as integer   no-undo .
      define variable v-fbr-depart-7     as integer   no-undo .
      define variable v-user-login-7     as character no-undo .
      define variable v-user-password-7  as character no-undo .
      define variable v-obj-type-7       as character no-undo .
      define variable v-obj-code-7       as integer   no-undo .

      run parse-req-7 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-7
                                        , output v-obj-type-7
                                        , output v-obj-code-7
                                        , output v-doc-code-7
                                        , output v-line-num-7
                                        , output v-mode-7
                                        , output v-src-code-7
                                        , output v-src-qnty-7
                                        , output v-pump-7
                                        , output v-nozzle-code-7
                                        , output v-pl-code-7
                                        , output v-write-off-code-7
                                        , output v-pass-gds-7
                                        , output v-fbr-depart-7
                                        ) .
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run gbl/mtreq007.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-7
                         , input  v-obj-type-7
                         , input  v-obj-code-7
                         , input  v-doc-code-7
                         , input  v-line-num-7
                         , input  v-mode-7
                         , input  v-src-code-7
                         , input  v-src-qnty-7
                         , input  v-pump-7
                         , input  v-nozzle-code-7
                         , input  v-pl-code-7
                         , input  v-write-off-code-7
                         , input  v-pass-gds-7
                         , input  v-fbr-depart-7
                         , output p-send-message
                         ) .
    end.


    when 12
    then do:
      define variable v-user-login-12        as character no-undo .
      define variable v-user-password-12     as character no-undo .
      define variable v-obj-type-12          as character no-undo .
      define variable v-obj-code-12          as integer   no-undo .
      define variable v-logged-in            as logical   no-undo .

      run parse-req-12 in this-procedure ( input v-msg-str
                                         , output v-data-valid
                                         , output v-err-message
                                         , output v-device-id
                                         , output v-user-login-12
                                         , output v-user-password-12
                                         ).
      {&check-data-valid}
      run gbl/mtreq012.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-12
                         , input  v-user-password-12
                         , output v-logged-in
                         , output p-send-message
                         ).
      if v-logged-in
      then do:
        define variable v-registred   as logical   no-undo .
        define variable v-reg-message as character no-undo .

        run mt-route_init-session in this-procedure ( input  v-device-id
                                                    , output v-registred
                                                    , output v-reg-message
                                                    ).
        if v-registred <> true
        then do:
          run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-reg-message
                                                                     , output p-send-message
                                                                     ) .
        end.
      end.


    end.
    when 13
    then do:
      run parse-req-13 in this-procedure ( input v-msg-str
                                         , output v-data-valid
                                         , output v-err-message
                                         , output v-device-id
                                         ).
      {&check-data-valid}
      &scop seqnum {&sequence}
      {&check-session-valid}

      run mt-route_delete-session in this-procedure ( input v-device-id ) .
      return.
    end.
    otherwise do:
      run mt-serv_write-error-message in parparentproc ( input substitute( 'Неизвестный номер запроса &1', p-req-num )
                                                       , output p-send-message
                                                       ) .
    end.
  end case.

end.

end procedure. /* init-route */


/* ----------------------------------------------------------------- */
procedure parse-req-1 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-obj-type          as character no-undo .
  define output parameter p-obj-code          as integer   no-undo .

  define variable v-log         as logical          no-undo .
  define variable v-user-login  as character        no-undo .
  define variable v-object-type as character        no-undo .
  define variable v-object-code as character        no-undo .


do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc") .

  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    P-user-login  = v-xml-filder :get-tag( "user" , v-log ) .
    P-obj-type    = v-xml-filder :get-tag( "objt" , v-log ) .
    v-object-code = v-xml-filder :get-tag( "objc" , v-log ) .
    p-device-id   = v-xml-filder :get-tag( "deviceid" , v-log ) .

    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if v-object-code = ""
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  v-object-code   /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output P-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = substitute( "Ошибка преобразования кода объекта &1. &2"
                                        , v-object-code
                                        , v-error-message
                                        )
      .
      return . /* --->>>--- */
    end.

  end.
end.

end procedure. /* parse-req-1 */

/* ----------------------------------------------------------------- */
procedure parse-req-2 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-obj-type          as character no-undo .
  define output parameter p-obj-code          as integer   no-undo .

  define variable v-log         as logical          no-undo .
  define variable v-user-login  as character        no-undo .
  define variable v-object-type as character        no-undo .
  define variable v-object-code as character        no-undo .


do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc") .

  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id   = v-xml-filder :get-tag( "deviceid" , v-log ) .
    P-user-login  = v-xml-filder :get-tag( "user" , v-log ) .
    P-obj-type    = v-xml-filder :get-tag( "objt" , v-log ) .
    v-object-code = v-xml-filder :get-tag( "objc" , v-log ) .

    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if v-object-code = ""
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  v-object-code   /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output p-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = substitute( "Ошибка преобразования кода объекта &1. &2"
                                        , v-object-code
                                        , v-error-message
                                        )
      .
      return . /* --->>>--- */
    end.

  end.
end.

end procedure. /* parse-req-2 */

/* ----------------------------------------------------------------- */
procedure parse-req-3 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .

  define variable v-device-id       as character no-undo .
  define variable v-user-login      as character no-undo .
  define variable v-obj-type        as character no-undo .
  define variable v-obj-code        as character no-undo .
  define variable v-doc-code        as character no-undo .
  define variable v-line-num        as character no-undo .
  define variable v-mode            as character no-undo .
  define variable v-src-code        as character no-undo .
  define variable v-src-qnty        as character no-undo .
  define variable v-pump            as character no-undo .
  define variable v-nozzle-code     as character no-undo .
  define variable v-pl-code         as character no-undo .
  define variable v-write-off-code  as character no-undo .
  define variable v-pass-gds        as character no-undo .
  define variable v-fbr-depart      as character no-undo .

  define variable v-log             as logical   no-undo .
  define variable v-data-valid      as logical   no-undo .
  define variable v-error-message   as character no-undo .

do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc,doccode,mode,barcode,gdslinenum,srcqnty,pump,nozzlecode,plcode,passgds,fbrdepart,writeoffcode") .

  v-log = v-xml-filder :parse(p-msg-str) .
  if v-log <> yes then do:
    assign
      p-err-message = v-xml-filder :error-message
    .
    return . /* --->>>--- */
  end.


  p-device-id      = v-xml-filder :get-tag( "deviceid" , v-log ) .
  p-user-login     = v-xml-filder :get-tag( "user" , v-log ) .
  p-obj-type       = v-xml-filder :get-tag( "objt" , v-log ) .
  v-obj-code       = v-xml-filder :get-tag( "objc" , v-log ) .
  p-doc-code       = v-xml-filder :get-tag( "doccode" , v-log ) .
  v-line-num       = v-xml-filder :get-tag( "gdslinenum" , v-log ) .
  v-mode           = v-xml-filder :get-tag( "mode" , v-log ) .
  p-src-code       = v-xml-filder :get-tag( "barcode" , v-log ) .
  v-src-qnty       = v-xml-filder :get-tag( "srcqnty" , v-log ) .
  v-pump           = v-xml-filder :get-tag( "pump" , v-log ) .
  v-nozzle-code    = v-xml-filder :get-tag( "nozzlecode" , v-log ) .
  v-pl-code        = v-xml-filder :get-tag( "plcode" , v-log ) .
  v-write-off-code = v-xml-filder :get-tag( "writeoffcode" , v-log ) .
  v-pass-gds       = v-xml-filder :get-tag( "passgds" , v-log ) .
  v-fbr-depart     = v-xml-filder :get-tag( "fbrdepart" , v-log ) .

  if v-obj-code = ""
  then do:
    assign
      p-data-valid        = no
      p-err-message = "Не задан код объекта"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-obj-code      /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-obj-code      /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования кода объекта &1. &2"
                                      , v-obj-code
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-line-num = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана строка чека"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-line-num      /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-line-num      /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования номера строки чека &1. &2"
                                      , v-line-num
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  case caps(v-mode) :
    when 'A'
    then do:
      assign
        p-mode = {&add-def}
      .
    end.
    when 'D'
    then do:
      assign
        p-mode = {&deletion}
      .
    end.
    when 'U'
    then do:
      assign
        p-mode = {&update}
      .
    end.
    otherwise do:
      assign
        p-data-valid  = no
        p-err-message = substitute( "Неверный режим работы с чеком : &1"
                                  , v-mode
                                  )
      .
      return . /* --->>>--- */
    end.
  end case.

  if v-src-qnty = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задано количество товара"
    .
    return . /* --->>>--- */
  end.

  assign
    p-src-qnty = decimal(v-src-qnty)
  no-error .
  if error-status :error
  then do:
    assign
      p-data-valid  = no
      p-err-message = substitute( "Ошибка преобразования количества &1"
                                , v-src-qnty
                                )
    .
    return . /* --->>>--- */

  end.



  if v-pump = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pump"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-pump          /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-pump          /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pump &1. &2"
                                      , v-pump
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-pump = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pump"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-pump          /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-pump          /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pump &1. &2"
                                      , v-pump
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-nozzle-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-nozzle-code"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-nozzle-code   /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-nozzle-code   /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-nozzle-code &1. &2"
                                      , v-nozzle-code
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-pl-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pl-code"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-pl-code       /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-pl-code       /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pl-code &1. &2"
                                      , v-pl-code
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-write-off-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-write-off-code"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-write-off-code  /* p-string      */
    ,input  false             /* p-allow-sign  */
    ,input  false             /* p-allow-comma */
    ,output p-write-off-code  /* p-value       */
    ,output v-data-valid      /* p-data-valid  */
    ,output v-error-message   /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-write-off-code &1. &2"
                                      , v-write-off-code
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  if v-pass-gds = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pass-gds"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-pass-gds      /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-pass-gds      /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pass-gds &1. &2"
                                      , v-pass-gds
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.


  if v-fbr-depart = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-fbr-depart"
    .
    return . /* --->>>--- */
  end.

  run integerm in this-procedure
    (input  v-fbr-depart    /* p-string      */
    ,input  false           /* p-allow-sign  */
    ,input  false           /* p-allow-comma */
    ,output p-fbr-depart    /* p-value       */
    ,output v-data-valid    /* p-data-valid  */
    ,output v-error-message /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-fbr-depart &1. &2"
                                      , v-fbr-depart
                                      , v-error-message
                                      )
    .
    return . /* --->>>--- */
  end.

  assign
    p-data-valid = yes
  .

end.

end procedure. /* parse-req-3 */

/* ----------------------------------------------------------------- */
procedure parse-req-4 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-doc-code        as character no-undo .

do
on error undo, return error return-value
:
  run parse-req-5 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-doc-code
                                    ) .

end.

end procedure. /* parse-req-4 */

/* ----------------------------------------------------------------- */
procedure parse-req-5 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-doc-code        as character no-undo .

  define variable v-device-id       as character no-undo .
  define variable v-doc-code        as character no-undo .

  define variable v-log             as logical   no-undo .
  define variable v-data-valid      as logical   no-undo .
  define variable v-error-message   as character no-undo .

do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,doccode") .

  v-log = v-xml-filder :parse(p-msg-str) .
  if v-log <> yes then do:
    assign
      p-err-message = v-xml-filder :error-message
    .
    return . /* --->>>--- */
  end.


  p-device-id      = v-xml-filder :get-tag( "deviceid" , v-log ) .
  p-doc-code       = v-xml-filder :get-tag( "doccode" , v-log ) .

  assign
    p-data-valid = yes
  .

end.

end procedure. /* parse-req-5 */

/* ----------------------------------------------------------------- */
procedure parse-req-6 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .

do
on error undo, return error return-value
:
  run parse-req-3 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-user-login
                                    , output p-obj-type
                                    , output p-obj-code
                                    , output p-doc-code
                                    , output p-line-num
                                    , output p-mode
                                    , output p-src-code
                                    , output p-src-qnty
                                    , output p-pump
                                    , output p-nozzle-code
                                    , output p-pl-code
                                    , output p-write-off-code
                                    , output p-pass-gds
                                    , output p-fbr-depart
                                    ) .

end.

end procedure. /* parse-req-6 */


/* ----------------------------------------------------------------- */
procedure parse-req-7 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .

do
on error undo, return error return-value
:
  run parse-req-3 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-user-login
                                    , output p-obj-type
                                    , output p-obj-code
                                    , output p-doc-code
                                    , output p-line-num
                                    , output p-mode
                                    , output p-src-code
                                    , output p-src-qnty
                                    , output p-pump
                                    , output p-nozzle-code
                                    , output p-pl-code
                                    , output p-write-off-code
                                    , output p-pass-gds
                                    , output p-fbr-depart
                                    ) .

end.

end procedure. /* parse-req-7 */

/* ----------------------------------------------------------------- */
procedure parse-req-12 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-user-password     as character no-undo .

  define variable v-log         as logical          no-undo .

do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,password") .

  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id     = v-xml-filder :get-tag( "deviceid" , v-log ) .
    P-user-login    = v-xml-filder :get-tag( "user" , v-log ) .
    P-user-password = v-xml-filder :get-tag( "password", v-log ) .


  end.
end.

end procedure. /* parse-req-12 */

/* ----------------------------------------------------------------- */
procedure parse-req-13 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .

  define variable v-log         as logical          no-undo .

do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid") .

  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id = v-xml-filder :get-tag( "deviceid" , v-log ) .
  end.
end.

end procedure. /* parse-req-13 */