DEFINE BUFFER X_esys-pck-rcvd FOR esys-pck-rcvd.
DEFINE BUFFER X_esys-pck-sent FOR esys-pck-sent.
DEFINE BUFFER X_ext-system FOR ext-system.
define input  parameter parparentproc as widget-handle  no-undo.
define input  parameter p-log-handle as handle  no-undo.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы OpenXML".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
define  shared variable oxml-exch-dir as character no-undo .
define  shared variable oxml-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field esys-id         as integer
  field db-num          as integer
  field current-db-num  as integer
  field pack-num        as integer
  field rcvd-recs       as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
define variable log-res as logical no-undo .
define variable v-db-num as integer no-undo .
define variable v-key-passed-date as date no-undo .
define variable v-imp-err as character no-undo .
define buffer buf_db for ub.db .
define buffer buf_ext-system for ub.ext-system .
define buffer buf_sys-ctrl for ub.sys-ctrl.
DEFINE MENU MENU-b-other
       MENU-ITEM m_send-ora-rcpt LABEL "Квитанц. для ВС типа Oracle Retail".
DEFINE BUTTON b-conf-pck DEFAULT
     LABEL "Под&тверд."
     SIZE 10 BY 1 TOOLTIP "Подтвердить пакет".
DEFINE BUTTON b-create DEFAULT
     LABEL "Под&готовить новые"
     SIZE 20 BY 1 TOOLTIP "Подготовка новых пакетов для всех ВС"
     BGCOLOR 8 .
DEFINE BUTTON b-get DEFAULT
     LABEL "При&нять"
     SIZE 10 BY 1 TOOLTIP "Принять почту не разбирая пакет".
DEFINE BUTTON b-get-pck DEFAULT
     LABEL "&Принять/Разобрать"
     SIZE 20 BY 1 TOOLTIP "Принять и затем разобрать пришедшую почту".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-imp-err DEFAULT
     LABEL "&Ошибки"
     SIZE 10 BY 1 TOOLTIP "Ошибки импорта по пакету".
DEFINE BUTTON b-info DEFAULT
     LABEL "&Доп.инфо"
     SIZE 10 BY 1 TOOLTIP "Дополнительная информация о пакете".
DEFINE BUTTON b-other DEFAULT
     LABEL "&Другое"
     SIZE 10 BY 1 TOOLTIP "Другие действия".
DEFINE BUTTON b-packlist DEFAULT
     LABEL "&Сообщения"
     SIZE 16 BY 1 TOOLTIP "Список соббщений в отправленном пакете".
DEFINE BUTTON b-proc-pck DEFAULT
     LABEL "&Разобрать"
     SIZE 10 BY 1 TOOLTIP "Только разобрать пакет, не принимая новых".
DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из новостей"
     BGCOLOR 8 .
DEFINE BUTTON b-send DEFAULT
     LABEL "&Отправить"
     SIZE 10 BY 1 TOOLTIP "Отправить конкретный пакет с его переформированием".
DEFINE BUTTON b-send-all DEFAULT
     LABEL "Отпр. в&cе"
     SIZE 10 BY 1 TOOLTIP "Отправить все неподтвержденные пакеты с их переформированием".
DEFINE BUTTON b-send-new DEFAULT
     LABEL "Отпр&авить новые"
     SIZE 20 BY 1 TOOLTIP "Отправка новых и некоторых неподтвержденных пакетов"
     BGCOLOR 8 .
DEFINE BUTTON b-unsend DEFAULT
     LABEL "&Данные"
     SIZE 10 BY 1 TOOLTIP "Неотправленнная или неподтвержденая информация".
DEFINE VARIABLE oxml-log AS CHARACTER INITIAL ?
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 98 BY 6 TOOLTIP "Просмотр файла с сообщениями о работе OpenXML"
     FONT 4 NO-UNDO.
DEFINE QUERY br-esys FOR
      X_ext-system SCROLLING.
DEFINE QUERY pck-rcvd FOR
      X_esys-pck-rcvd SCROLLING.
DEFINE QUERY pck-sent FOR
      X_esys-pck-sent SCROLLING.
DEFINE BROWSE br-esys
  QUERY br-esys DISPLAY
      X_ext-system.esys-id column-label "ВС"
(X_ext-system.esys-type > integer('0':U)) column-label "Спец" format "+/"
(X_ext-system.esys-have-export and X_ext-system.esys-db-num-exp = v-db-num)  column-label "Экспорт!в тек.БД" format "+/"
(X_ext-system.esys-have-import and X_ext-system.esys-db-num-imp = v-db-num)  column-label "Импорт!в тек.БД" format "+/"
X_ext-system.esys-name
    WITH SEPARATORS SIZE 50 BY 14.52 FIT-LAST-COLUMN TOOLTIP "Рабочие ВС".
DEFINE BROWSE pck-rcvd
  QUERY pck-rcvd NO-LOCK DISPLAY
      X_esys-pck-rcvd.espr-pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_esys-pck-rcvd.espr-rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      v-imp-err COLUMN-LABEL "Ош." FORMAT "X(1)":U
      X_esys-pck-rcvd.espr-total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
  X_esys-pck-rcvd.custom-pack-name COLUMN-LABEL "Имя пакета в ВС" FORMAT "X(255)":U WIDTH 30
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 46.6 BY 6.52
         FONT 4
         TITLE "Полученные пакеты" FIT-LAST-COLUMN TOOLTIP "Полученные пакеты от данной ВС".
DEFINE BROWSE pck-sent
  QUERY pck-sent NO-LOCK DISPLAY
      X_esys-pck-sent.esps-pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_esys-pck-sent.esps-rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_esys-pck-sent.esps-total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
      X_esys-pck-sent.custom-pack-name COLUMN-LABEL "Имя пакета в ВС" FORMAT "X(255)":U WIDTH 30
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 46.6 BY 7
         FONT 4
         TITLE "Отправленные пакеты" FIT-LAST-COLUMN TOOLTIP "Отправленные пакеты в данную ВС".
DEFINE FRAME oxmlhand
     b-quit AT ROW 1 COL 1
     b-create AT ROW 1 COL 11
     b-packlist AT ROW 1 COL 77 WIDGET-ID 6
     b-help AT ROW 1 COL 95
     br-esys AT ROW 2 COL 1
     pck-sent AT ROW 2 COL 52
     b-send AT ROW 9 COL 52
     b-send-all AT ROW 9 COL 62
     b-conf-pck AT ROW 9 COL 72 WIDGET-ID 2
     b-info AT ROW 9 COL 86.8
     pck-rcvd AT ROW 10 COL 52 WIDGET-ID 100
     b-imp-err AT ROW 16.48 COL 87 WIDGET-ID 8
     b-get-pck AT ROW 16.52 COL 1
     b-send-new AT ROW 16.52 COL 21
     b-unsend AT ROW 16.52 COL 41
     b-get AT ROW 16.52 COL 52
     b-proc-pck AT ROW 16.52 COL 62
     b-other AT ROW 16.52 COL 72 WIDGET-ID 4
     oxml-log AT ROW 17.52 COL 1 NO-LABEL
     SPACE(0.29) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".
ASSIGN
       FRAME oxmlhand:SCROLLABLE       = FALSE.
ASSIGN
       b-other:POPUP-MENU IN FRAME oxmlhand       = MENU MENU-b-other:HANDLE.
ASSIGN
       oxml-log:READ-ONLY IN FRAME oxmlhand        = TRUE.
ASSIGN
       pck-rcvd:HIDDEN  IN FRAME oxmlhand                = TRUE.
ON WINDOW-CLOSE OF FRAME oxmlhand
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-conf-pck IN FRAME oxmlhand
DO:
    if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    if not available X_esys-pck-sent THEN do:
        message "Нет готовых пакетов." view-as alert-box .
        return no-apply.
    end.
   run bge/confepck.p (  INPUT parparentproc
                        ,INPUT p-log-handle
                        ,input log-file-name
                        ,INPUT NO
                        ,INPUT X_esys-pck-sent.esys-id
                        ,INPUT X_esys-pck-sent.db-num
                        ,INPUT X_esys-pck-sent.esps-cr-db-num
                        ,INPUT X_esys-pck-sent.esps-pack-num) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE
      ERROR-STATUS:get-message(1) SKIP
      RETURN-VALUE
      VIEW-AS ALERT-BOX.
   END.
   run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-create IN FRAME oxmlhand
DO:
  define variable v-message  as character no-undo .
  define variable v-err-code as integer   no-undo .
  run write-to-log ( substitute( "Подготовка новых пакетов." ) ).
  run bge/cnewxpck.p (
                     input substitute("&1,&2"
                                     ,X_ext-system.esys-id
                                     ,X_ext-system.db-num)
                   , output v-err-code
  ) no-error .
  if error-status:error
  then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов OpenXML &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,chr(10)
                                  ,return-value
                                )
                    ) .
  end.
  else do:
    assign
      v-message = return-value
    .
    if v-message <> "":U then do:
      run write-to-log ( substitute( "&1", v-message ) ).
    end.
    run write-to-log ( substitute( "Завершена подготовка новых пакетов." ) ).
  end.
  run refresh-brws in this-procedure  ( input yes ) .
END.
ON CHOOSE OF b-get IN FRAME oxmlhand
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmlinx.p ( input parparentproc
                       ,input this-procedure:handle
                       ,input p-log-handle
                       ,input substitute("take,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                      )
                  ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + chr(32)
                        + substitute( "ERROR!!! Ошибка при приеме пакета данных из ВС &1"
                        ,X_ext-system.esys-id ) + chr(10)
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-get-pck IN FRAME oxmlhand
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
 if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmlinx.p ( input parparentproc
                       ,input this-procedure:handle
                       ,input p-log-handle
                       ,input substitute("take+analys,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num)
                  ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + chr(32)
                        + substitute( "ERROR!!! Ошибка при приеме пакетов данных из ВС &1", X_ext-system.esys-id ) + chr(10)
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-imp-err IN FRAME oxmlhand
DO:
  run bge/pack-err.w ( input X_esys-pck-rcvd.esys-id
                      ,input X_esys-pck-rcvd.db-num
                      ,input X_esys-pck-rcvd.espr-cr-db-num
                      ,input X_esys-pck-rcvd.espr-pack-num
                ) no-error.
END.
ON CHOOSE OF b-info IN FRAME oxmlhand
DO:
  if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
  run bge/packxinf.w ( input X_esys-pck-sent.esys-id
                      ,input X_esys-pck-sent.db-num
                      ,input X_esys-pck-sent.esps-cr-db-num
                      ,input X_esys-pck-sent.esps-pack-num
                ) no-error.
END.
ON CHOOSE OF b-packlist IN FRAME oxmlhand
DO:
    if not available X_esys-pck-sent THEN do:
        message "Не выбран пакет для просмотра." view-as alert-box .
        return no-apply.
    end.
    run bge/viewpack.w ( X_ext-system.esys-id
                        ,X_ext-system.db-num
                        ,X_esys-pck-sent.esps-cr-db-num
                        ,X_esys-pck-sent.esps-pack-num
                        ) no-error.
    run refresh-brws
      ( input yes )
    .
END.
ON CHOOSE OF b-proc-pck IN FRAME oxmlhand
DO:
   if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
  if not available X_esys-pck-rcvd then do:
    message
    "Отстутствует пакет для разбора"
    view-as alert-box .
    undo, return no-apply.
  end.
  assign
  add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
  .
  run bge/oxmlinx.p ( input parparentproc
                      ,input this-procedure:handle
                      ,input p-log-handle
                      ,input substitute("analys,&1,&2,&3,&4,&5"
                                    ,v-db-num
                                    ,X_ext-system.esys-id
                                    ,X_ext-system.db-num
                                    ,X_esys-pck-rcvd.espr-cr-db-num
                                    ,X_esys-pck-rcvd.espr-pack-num
                                    )
                ) no-error.
  if error-status:error then do:
    run write-to-log( vss-workfile + chr(32)
                      + substitute( "ERROR!!! Ошибка при приеме пакета данных из ВС &1"
                      ,X_ext-system.esys-id ) + chr(10)
                      + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                      + substitute( "&1", return-value )
                    ) .
  end.
  assign
  add-log-file-name = ?
  .
  run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-send IN FRAME oxmlhand
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    if not available X_esys-pck-sent THEN do:
        message "Не выбран пакет для отправки." view-as alert-box .
        return no-apply.
    end.
    if X_esys-pck-sent.esps-rcvd = no
    or can-find(first ub.esys-route no-lock where
                     ub.esys-route.esys-id = X_esys-pck-sent.esys-id
                  and ub.esys-route.db-num = X_esys-pck-sent.db-num
                  and ub.esys-route.esr-cr-db-num = g#db-num
                  and ub.esys-route.esr-last-pack = X_esys-pck-sent.esps-pack-num
                  )
    then do:
      assign
      add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
      .
      run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-pack,&1,&2,&3,&4,&5"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                      ,X_esys-pck-sent.esps-cr-db-num
                                      ,X_esys-pck-sent.esps-pack-num)
                    ) no-error.
      if error-status:error then do:
        run write-to-log( vss-workfile + chr(32)
                          + substitute( "ERROR!!! Ошибка при отправке одного пакета данных в ВС &1", X_ext-system.esys-id ) + chr(10)
                          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                          + substitute( "&1", return-value )
                        ) .
      end.
      assign
      add-log-file-name = ?
      .
      run refresh-brws
        ( input yes )
      .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Отправить пакет &1 нельзя.", X_esys-pck-sent.esps-pack-num ) skip
        substitute( "Получено подтверждение о его приеме и данные уже удалены." )
        view-as alert-box information
      .
    end.
END.
ON CHOOSE OF b-send-all IN FRAME oxmlhand
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    if not available X_esys-pck-sent THEN do:
        message "Нет готовых пакетов." view-as alert-box .
        return no-apply.
    end.
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
     run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-esys-unconf,&1,&2,&3,-1,-1"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                        )
                    ) no-error.
      if error-status:error then do:
        run write-to-log( vss-workfile + chr(32)
                      + substitute( "ERROR!!! Ошибка при отправке всех неподтвержденных пакетов данных в ВС &1", X_ext-system.esys-id ) + chr(10)
                      + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                      + substitute( "&1", return-value )
                    ) .
      end.
   assign
   add-log-file-name = ?
   .
      run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-send-new IN FRAME oxmlhand
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-esys,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                        )
                    ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + chr(32)
                        + substitute( "ERROR!!! Ошибка при отправке Данных в ВС &1", X_ext-system.esys-id)  + chr(10)
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).
END.
ON CHOOSE OF b-unsend IN FRAME oxmlhand
DO:
  if not available X_ext-system then do:                 message                   "Не выбрана ВС."                   view-as alert-box information.                 return no-apply.               end.               find first buf_ext-system no-lock                 where buf_ext-system.esys-id = X_ext-system.esys-id                    and  buf_ext-system.db-num = X_ext-system.db-num                 no-error .               if not available buf_ext-system then do:                 message                   substitute( "ВС &1 удалена.", X_ext-system.esys-id )                   view-as alert-box information.                 run refresh-brws                   ( input yes ) .                 return no-apply.               end.
  run bge/vxroute.w ( input X_ext-system.esys-id, input X_ext-system.db-num ) .
END.
ON VALUE-CHANGED OF br-esys IN FRAME oxmlhand
DO:
  run refresh-brws in this-procedure  ( input no )  .
END.
ON CHOOSE OF MENU-ITEM m_send-ora-rcpt
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
MESSAGE
"ВЫ действительно хотите сформировать подтверждение для пакета ?" SKIP
"(Скорее всего оно уже было сформировано)" SKIP
VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
IF NOT glog THEN RETURN NO-APPLY.
  run bge/rorarcpt.p ( INPUT parparentproc
                      ,INPUT p-log-handle
                      ,input no
                      ,INPUT X_ext-system.esys-id
                      ,INPUT X_ext-system.db-num
                      ,INPUT X_esys-pck-rcvd.espr-pack-num) NO-ERROR.
if error-status:error then do:
  message error-status:get-message(1)
  return-value
  view-as alert-box error .
end.
END.
ON ROW-DISPLAY OF pck-rcvd IN FRAME oxmlhand
DO:
  define buffer esys-pck-rcvd-err for ub.esys-pck-rcvd-err.
  v-imp-err = if can-find(first esys-pck-rcvd-err where
                                esys-pck-rcvd-err.esys-id        = X_esys-pck-rcvd.esys-id
                            AND esys-pck-rcvd-err.db-num         = X_esys-pck-rcvd.db-num
                            AND esys-pck-rcvd-err.espr-cr-db-num = X_esys-pck-rcvd.espr-cr-db-num
                            AND esys-pck-rcvd-err.espr-pack-num  = X_esys-pck-rcvd.espr-pack-num)
              then "+" else "".
END.
ON VALUE-CHANGED OF pck-rcvd IN FRAME oxmlhand
DO:
  define buffer esys-pck-rcvd-err for ub.esys-pck-rcvd-err.
    ASSIGN
    MENU-ITEM m_send-ora-rcpt:SENSITIVE IN MENU MENU-b-other = NO.
  IF NOT AVAILABLE X_ext-system  THEN DO:
  END.
  ELSE DO:
     IF AVAILABLE X_esys-pck-rcvd THEN DO:
        CASE X_ext-system.delivery-method:
          WHEN INTEGER('3':U) THEN DO:
              ASSIGN
              MENU-ITEM m_send-ora-rcpt:SENSITIVE IN MENU MENU-b-other = YES.
          END.
          OTHERWISE DO:
          END.
        END CASE.
      END.
      ELSE DO:
      END.
      if can-find(first esys-pck-rcvd-err where
                        esys-pck-rcvd-err.esys-id        = X_esys-pck-rcvd.esys-id
                    AND esys-pck-rcvd-err.db-num         = X_esys-pck-rcvd.db-num
                    AND esys-pck-rcvd-err.espr-cr-db-num = X_esys-pck-rcvd.espr-cr-db-num
                    AND esys-pck-rcvd-err.espr-pack-num  = X_esys-pck-rcvd.espr-pack-num)
        then enable b-imp-err with frame oxmlhand.
        else disable b-imp-err with frame oxmlhand.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME oxmlhand:PARENT eq ?
THEN FRAME oxmlhand:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame oxmlhand anywhere
do:
   run refresh-brws in this-procedure  ( input yes).
    apply "VALUE-CHANGED" to br-esys.
end.
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  find first buf_sys-ctrl no-lock.
  run gbl/set-gbl.p
    (input false
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при инициализации переменных g#...&2&3"
                                  ,vss-workfile
                                  ,chr(10)
                                  ,error-status:get-message(error-status:num-messages)
                                )
                    ) .
    return error.
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame oxmlhand
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame oxmlhand
do:
  apply "help":u to frame oxmlhand .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame oxmlhand:width - 0.3
                fh            = frame oxmlhand:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame oxmlhand :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame oxmlhand :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame oxmlhand :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame oxmlhand :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame oxmlhand :height = v-frame-height
          .
          if frame oxmlhand :scrollable = true
          then do:
            assign
              frame oxmlhand :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame oxmlhand :scrollable = true
          then do:
            assign
              frame oxmlhand :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame oxmlhand :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame oxmlhand :height
      v-frame-virtual-height = frame oxmlhand :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame oxmlhand :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame oxmlhand
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame oxmlhand :scrollable = true
      then do:
        assign
          frame oxmlhand :virtual-height = frame oxmlhand :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame oxmlhand :height = frame oxmlhand :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame oxmlhand :height = frame oxmlhand :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame oxmlhand :scrollable = true
      then do:
        assign
          frame oxmlhand :virtual-height = frame oxmlhand :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame oxmlhand :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame oxmlhand :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame oxmlhand :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame oxmlhand :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame oxmlhand :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame oxmlhand :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame oxmlhand :width = v-frame-width
          .
          if frame oxmlhand :scrollable = true
          then do:
            assign
              frame oxmlhand :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame oxmlhand :scrollable = true
          then do:
            assign
              frame oxmlhand :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame oxmlhand :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame oxmlhand :width
      v-frame-virtual-width = frame oxmlhand :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame oxmlhand :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame oxmlhand
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame oxmlhand :scrollable = true
      then do:
        assign
          frame oxmlhand :virtual-width = frame oxmlhand :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame oxmlhand :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame oxmlhand :width = frame oxmlhand :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame oxmlhand :scrollable = true
      then do:
        assign
          frame oxmlhand :virtual-width = frame oxmlhand :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame oxmlhand :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame oxmlhand :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame oxmlhand
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame oxmlhand :height - v-diasize-resize-button :height
                  - 1
                  - (frame oxmlhand :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame oxmlhand :width - v-diasize-resize-button :width
                  - 1
                  - (frame oxmlhand :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame oxmlhand
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame oxmlhand :height
      v-col-delta = v-new-col - frame oxmlhand :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame oxmlhand :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame oxmlhand :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame oxmlhand :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame oxmlhand :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame oxmlhand :width
      v-diasize-current-frame-height = frame oxmlhand :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame oxmlhand
    :
      assign
        v-diasize-orig-frame-height = frame oxmlhand :height
        v-diasize-orig-frame-width  = frame oxmlhand :width
        v-diasize-browse-handle     = browse br-esys :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame oxmlhand :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
  assign
    hand-log-msg-h = oxml-log:handle
  g#esys = true
  .
  define variable mDBInfo as character no-undo.
  run adm/db-info.p ( output v-db-num, output mDBInfo ) no-error .
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2&3&4"
                                  ,vss-workfile
                                  ,mDBInfo
                                  ,chr(10)
                                  ,error-status:get-message(error-status:num-messages)
                                )
                    ) .
    return error.
  end.
  assign
   frame oxmlhand:title = substitute("OpenXML &1", mDBInfo)
   br-esys:num-locked-columns IN FRAME oxmlhand = 1
  .
  RUN Myenable in this-procedure.
  do
  on ERROR  undo, leave
  on ENDKEY undo, leave
  on STOP   undo, retry
  :
    wait-for go of frame oxmlhand.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME oxmlhand.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY oxml-log
      WITH FRAME oxmlhand.
  ENABLE b-quit b-create b-packlist b-help br-esys pck-sent b-send b-send-all
         b-conf-pck b-info pck-rcvd b-imp-err b-get-pck b-send-new b-unsend
         b-get b-proc-pck b-other oxml-log
      WITH FRAME oxmlhand.
  OPEN QUERY br-esys FOR EACH X_ext-system NO-LOCK by X_ext-system.esys-id    INDEXED-REPOSITION .    OPEN QUERY pck-sent FOR EACH X_esys-pck-sent.
END PROCEDURE.
PROCEDURE esys-key :
define input-output parameter p-key-passed-date as date no-undo .
define variable v-key-ok as logical no-undo .
define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-key-passed-date = ?
or p-key-passed-date < v-today then do:
  run bge/esys-key.p ( input g#db-num
                      ,input no
                      ,output v-key-ok
                      ,output v-mess) no-error.
  if error-status:error then do:
    message
    substitute( "&2&1Ошибка при выполнении проверки конф. параметров по типам ВС&1&3&1&4"
                                      , chr(10)
                                      , vss-workfile
                                      , return-value
                                      , error-status :get-message( error-status :num-messages )
                                                    )
    view-as alert-box error.
    return error.
  end.
  if not v-key-ok then do:
    message
    substitute( "При проверке конфигурационных параметров по типам ВС обнаружено несоответствие&1&2&1Продолжение работы невозможно&1"
                                      , chr(10)
                                      , v-mess       )
    view-as alert-box error .
    return error.
  end.
  assign
  p-key-passed-date = v-today.
end.
END PROCEDURE.
PROCEDURE MyEnable :
b-other:MENU-MOUSE IN FRAME oxmlhand = 1.
DISPLAY oxml-log
WITH FRAME oxmlhand.
ENABLE
b-quit b-create b-help
br-esys
pck-sent
b-send
b-packlist
b-send-all
b-conf-pck
b-info
pck-rcvd
b-get-pck
b-send-new
b-other
b-unsend
b-get
b-proc-pck
oxml-log
WITH FRAME oxmlhand.
run Openbr-esys in this-procedure .
apply "VALUE-CHANGED" to br-esys.
apply "VALUE-CHANGED" to pck-rcvd.
END PROCEDURE.
PROCEDURE Openbr-esys :
OPEN QUERY br-esys FOR EACH X_ext-system NO-LOCK where
(X_ext-system.esys-have-export and
    X_ext-system.esys-db-num-exp = buf_sys-ctrl.db-num)
    or
(X_ext-system.esys-have-import and
    X_ext-system.esys-db-num-imp = buf_sys-ctrl.db-num
    )
by X_ext-system.esys-id
    INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE Openbr-pck-rcvd :
OPEN QUERY pck-rcvd FOR EACH X_esys-pck-rcvd
      WHERE X_esys-pck-rcvd.esys-id = X_ext-system.esys-id
      and X_esys-pck-rcvd.db-num = X_ext-system.db-num
      and X_esys-pck-rcvd.espr-cr-db-num = buf_sys-ctrl.db-num
      NO-LOCK
    BY X_esys-pck-rcvd.esys-id DESCENDING
    BY X_esys-pck-rcvd.db-num DESCENDING
    BY X_esys-pck-rcvd.espr-cr-db-num DESCENDING
    BY X_esys-pck-rcvd.espr-pack-num DESCENDING INDEXED-REPOSITION.
 END PROCEDURE.
PROCEDURE Openbr-pck-sent :
OPEN QUERY pck-sent FOR EACH X_esys-pck-sent
      WHERE X_esys-pck-sent.esys-id = X_ext-system.esys-id
      and X_esys-pck-sent.db-num = X_ext-system.db-num
      and X_esys-pck-sent.esps-cr-db-num = buf_sys-ctrl.db-num
      NO-LOCK
    BY X_esys-pck-sent.esys-id DESCENDING
    BY X_esys-pck-sent.db-num DESCENDING
    BY X_esys-pck-sent.esps-cr-db-num DESCENDING
    BY X_esys-pck-sent.esps-pack-num DESCENDING INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE refresh-brws :
define input parameter p-with-esys as logical no-undo .
  define variable v-rowid as rowid no-undo .
  if p-with-esys = true then do:
    assign
      log-res = browse br-esys:set-repositioned-row( browse br-esys :focused-row, 'CONDITIONAL':u)
      v-rowid = rowid( X_ext-system )
    .
    run Openbr-esys in this-procedure.
    reposition br-esys to rowid v-rowid no-error .
  end.
  run Openbr-pck-rcvd in this-procedure.
  run Openbr-pck-sent in this-procedure.
 if available X_esys-pck-sent then do:
    assign
      log-res = pck-sent:select-row( 1 ) IN FRAME oxmlhand
    .
  end.
  if available X_esys-pck-rcvd then do:
    assign
      log-res = pck-rcvd:select-row( 1 ) IN FRAME oxmlhand
    .
  end.
END PROCEDURE.
