DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_pck-rcvd FOR ub.pck-rcvd.
DEFINE BUFFER X_pck-sent FOR ub.pck-sent.
define input  parameter parparentproc   as widget-handle no-undo .
define input  parameter p-user-login    as character     no-undo .
define input  parameter p-user-password as character     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы СПН".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  shared variable nws-exch-dir as character no-undo .
define  shared variable nws-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field db-num-dst      as integer
  field db-num-src      as integer
  field pack-num        as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field dst_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable log-res as logical no-undo .
define buffer buf_db for ub.db .
define variable v-rid-list     as   character    no-undo .
define variable v-rid-list-new as   character    no-undo .
define variable v-ind          as   integer      no-undo .
define variable v-num-entries  as   integer      no-undo .
define variable v-db-list      as   character    no-undo .
define variable v-db-num       like ub.db.db-num no-undo .
define variable v-one-db       as   logical      no-undo .
define variable v-cur-db-num as integer no-undo .
define variable v-have-rights    as logical        no-undo.
FUNCTION get-turn-on RETURNS LOGICAL
  ( INPUT v-db-key AS CHARACTER )  FORWARD.
DEFINE BUTTON b-create DEFAULT
     LABEL "Под&готовить новые"
     SIZE 20 BY 1 TOOLTIP "Подготовка новых пакетов для всех БД"
     BGCOLOR 8 .
DEFINE BUTTON b-sync DEFAULT
     LABEL "&Синхронизация"
     SIZE 20 BY 1 TOOLTIP "Синхронизация УБД, восстановленной из бэкапа, с ТБД"
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из новостей"
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
DEFINE BUTTON b-info-all DEFAULT
     LABEL "Информ. о пакетах"
     SIZE 20 BY 1 TOOLTIP "Детальная информация о пакетах по БД"
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-proc-pck DEFAULT
     LABEL "&Разобрать"
     SIZE 10 BY 1 TOOLTIP "Только разобрать пакет, не принимая новых".
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
     LABEL "&Без подтвержд."
     SIZE 20 BY 1 TOOLTIP "Неотправленнная или неподтвержденая информация".
DEFINE BUTTON bt-not-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE VARIABLE news-log AS CHARACTER INITIAL ?
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 97 BY 6.5 TOOLTIP "Просмотр файла с сообщениями о работе новостей" NO-UNDO.
DEFINE VARIABLE f-not-rcvd AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "без подтверждения"
      VIEW-AS TEXT
     SIZE 7 BY .67 TOOLTIP "кол-во пакетов без подтверждения" NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 7  NO-UNDO.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 13.5.
DEFINE QUERY br-db FOR
      X_db SCROLLING.
DEFINE QUERY br-pck-rcvd FOR
      X_pck-rcvd SCROLLING.
DEFINE QUERY br-pck-sent FOR
      X_pck-sent SCROLLING.
DEFINE BROWSE br-db
  QUERY br-db DISPLAY
      mark-string( input recid(X_db), input v-rid-list) column-label "*" format "X(1)":U
      get-turn-on(X_db.db-key) FORMAT "+/-":U COLUMN-LABEL "A":U
      X_db.db-num FORMAT ">>>>9":U
      X_db.db-name
    WITH SEPARATORS SIZE 61.5 BY 13
         TITLE "Список БД" FIT-LAST-COLUMN TOOLTIP "Рабочие БД".
DEFINE BROWSE br-pck-rcvd
  QUERY br-pck-rcvd NO-LOCK DISPLAY
      X_pck-rcvd.pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_pck-rcvd.rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_pck-rcvd.total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
            WIDTH 16.25
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 33 BY 6
         TITLE "Полученные пакеты" FIT-LAST-COLUMN TOOLTIP "Полученные пакеты от данной БД".
DEFINE BROWSE br-pck-sent
  QUERY br-pck-sent NO-LOCK DISPLAY
      X_pck-sent.pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_pck-sent.rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_pck-sent.total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
            WIDTH 16.25
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 33 BY 6
         TITLE "Отправленные пакеты" FIT-LAST-COLUMN TOOLTIP "Отправленные пакеты в данную БД".
DEFINE FRAME nws-hand
     b-exit AT ROW 1 COL 2
     b-get-pck AT ROW 1 COL 15
     b-create AT ROW 1 COL 35
     b-send-new AT ROW 1 COL 55
     b-info-all AT ROW 1 COL 75 WIDGET-ID 2
     b-help AT ROW 1 COL 95.5
     bt-not-sel-all AT ROW 2 COL 6 WIDGET-ID 10 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2 COL 9 WIDGET-ID 12 NO-TAB-STOP
     b-mark AT ROW 2 COL 12 WIDGET-ID 4
     b-get AT ROW 2 COL 15
     b-proc-pck AT ROW 2 COL 25
     b-sync at row 2 col 35
     b-send AT ROW 2 COL 55
     b-send-all AT ROW 2 COL 65
     b-unsend AT ROW 2 COL 75
     br-db AT ROW 3.5 COL 2.5
     br-pck-sent AT ROW 3.5 COL 65
     br-pck-rcvd AT ROW 10.5 COL 65
     news-log AT ROW 17 COL 2 NO-LABEL
     mark-num AT ROW 2 COL 2 NO-LABEL WIDGET-ID 8
     f-not-rcvd AT ROW 9.5 COL 86.5 COLON-ALIGNED
     RECT-3 AT ROW 3.25 COL 2
     SPACE(0.87) SKIP(7.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".
ASSIGN
       FRAME nws-hand:SCROLLABLE       = FALSE.
ASSIGN
       f-not-rcvd:READ-ONLY IN FRAME nws-hand        = TRUE.
ASSIGN
       news-log:READ-ONLY IN FRAME nws-hand        = TRUE.
ON WINDOW-CLOSE OF FRAME nws-hand
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-create IN FRAME nws-hand
DO:
  define variable v-message  as character no-undo .
  define variable v-err-code as integer   no-undo .
  assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  run write-to-log in this-procedure
    ( substitute( "Подготовка новых пакетов." )
    ).
  run nws/cnew-pck.p
    ( input v-db-list
    , output v-err-code
    ) no-error .
  if error-status:error then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов новостей &2&3&4"
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
      run write-to-log in this-procedure
        ( substitute( "&1", v-message )
        ).
    end.
    run write-to-log in this-procedure
      ( substitute( "Завершена подготовка новых пакетов." )
      ).
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-sync IN FRAME nws-hand
DO:
  define variable v-user-id as character no-undo .
  define variable vOk as logical no-undo .
  v-user-id = g#auto-user-id + chr(4) + 'yes' .
  if not available X_db then return no-apply .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  v-user-id
    ,input  0
    ,input  'actn_news-sync':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output v-have-rights
    )  .
end.
  if not v-have-rights
  then do :
    if v-cur-db-num = 0
    then do :
      message "Недостаточно прав для выполнения Cинхронизации БД " string(x_db.db-num) " с ТБД" view-as alert-box error.
    end .
    else do :
      message "Недостаточно прав для отправки запроса на Синхронизацию УБД с ТБД" view-as alert-box error.
    end .
    return no-apply .
  end.
  if v-cur-db-num = 0
  then do :
    run nws/sync.w (input parparentproc,
                    input X_db.db-num)
                    no-error .
    if error-status:error
    then do :
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при синхронизации пакетов с БД &5&3&2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,chr(10)
                                    ,return-value
                                    ,string(X_db.db-num)
                                  )
                      ) .
    end.
  end .
  else do :
    message "Вы уверены что хотите отправить запрос в ТБД на Синхронизацию обмена СПН? Каталоги новостей будут очищены!" view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
    run nws/send-sync-request.p (input parparentproc,
                                 input X_db.db-num)
                                 no-error .
    if error-status:error
    then do :
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при отправке запроса на Синхронизацию обмена СПН &3&2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,chr(10)
                                    ,return-value
                                  )
                      ) .
    end.
  end .
  OPEN QUERY br-pck-rcvd FOR EACH X_pck-rcvd       WHERE X_pck-rcvd.db-num = X_db.db-num  NO-LOCK     BY X_pck-rcvd.db-num DESCENDING        BY X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION.
  OPEN QUERY br-pck-sent FOR EACH X_pck-sent       WHERE X_pck-sent.db-num = X_db.db-num NO-LOCK     BY X_pck-sent.db-num DESCENDING        BY X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION.
END.
ON CHOOSE OF b-get IN FRAME nws-hand
DO:
    assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/rcvd-nws.p
      ( input parparentproc
      , input "take":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + chr(32)
          + substitute( "ERROR!!! Ошибка при приеме пакетов новостей из БД &1", v-db-num ) + chr(10)
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-get-pck IN FRAME nws-hand
DO:
    assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/rcvd-nws.p
     ( input parparentproc
     , input "take+analys":U
     , input v-db-num
     , input ?
     ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + chr(32)
          + substitute( "ERROR!!! Ошибка при приеме и(или) разборе пакетов новостей из БД &1", v-db-num ) + chr(10)
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-info-all IN FRAME nws-hand
DO:
  if not available X_db then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   find first buf_db no-lock     where buf_db.db-num = X_db.db-num     no-error .   if not available buf_db then do:     message       substitute( "БД &1 удалена.", X_db.db-num )       view-as alert-box information.     run refresh-brws in this-procedure       ( input yes ) .     return no-apply .   end.
  run nws/packsinf.w
    ( input X_db.db-num
    ).
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-mark IN FRAME nws-hand
DO:
  define variable loc#log as logical no-undo .
  if available X_db then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid7 as character no-undo .
define variable v-num-entry7 as integer   no-undo .
assign
  v-str-recid7 = trim( string( recid( X_db ) , "->>>>>>>>>>>9":U ) )
  v-num-entry7 = lookup( v-str-recid7 , v-rid-list )
.
if v-num-entry7 > 0 then do:
  assign
    entry( v-num-entry7, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid7
  .
end.
    loc#log = br-db:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-db:select-next-row ().
        apply "VALUE-CHANGED" to br-db in frame nws-hand.
    end.
    if num-entries( v-rid-list ) = 0 then do:
      hide mark-num in frame nws-hand.
    end.
    else do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame nws-hand.
    end.
  end.
  apply "entry" to br-db in frame nws-hand.
END.
ON CHOOSE OF b-proc-pck IN FRAME nws-hand
DO:
  assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/rcvd-nws.p
      ( input parparentproc
      , input "analys":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + chr(32)
          + substitute( "ERROR!!! Ошибка при разборе пакетов новостей из БД &1", v-db-num ) + chr(10)
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
          + substitute( "&1", return-value )
        ) .
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-send IN FRAME nws-hand
DO:
    if not available X_db then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   find first buf_db no-lock     where buf_db.db-num = X_db.db-num     no-error .   if not available buf_db then do:     message       substitute( "БД &1 удалена.", X_db.db-num )       view-as alert-box information.     run refresh-brws in this-procedure       ( input yes ) .     return no-apply .   end.
    if not available X_pck-sent THEN do:
        message "Не выбран пакет для отправки." view-as alert-box .
        return no-apply.
    end.
    if X_pck-sent.rcvd = no then do:
      if g#db-num = 0 then do:
        assign
          add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_db.db-num )
        .
      end.
      run nws/send-nws.p
        ( input parparentproc
        , input "one-pack":U
        , input X_db.db-num
        , input X_pck-sent.pack-num
        ) no-error.
      if error-status:error then do:
        run write-to-log in this-procedure
          ( vss-workfile + chr(32)
            + substitute( "ERROR!!! Ошибка при отправке одного пакета новостей в БД &1", X_db.db-num ) + chr(10)
            + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
            + substitute( "&1", return-value )
          ) .
      end.
      assign
        add-log-file-name = ?
      .
      run refresh-brws in this-procedure
        ( input yes
        ).
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Отправить пакет &1 нельзя.", X_pck-sent.pack-num ) skip
        substitute( "Получено подтверждение о его приеме." )
        view-as alert-box information
      .
    end.
END.
ON CHOOSE OF b-send-all IN FRAME nws-hand
DO:
  assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/send-nws.p
      ( input parparentproc
      , input "all-unconf":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + chr(32)
          + substitute( "ERROR!!! Ошибка при отправке всех неподтвержденных пакетов новостей в БД &1", v-db-num ) + chr(10)
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-send-new IN FRAME nws-hand
DO:
  assign     v-one-db = false   .   if trim( v-rid-list ) = "":U     and available X_db   then do:     assign       v-rid-list = string( recid ( X_db ) )       v-one-db   = true     .    end.   if trim( v-rid-list ) = "":U then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   assign     v-num-entries = num-entries( v-rid-list)     v-rid-list-new = "":U     v-db-list = "":U   .   do v-ind = 1 to v-num-entries   :     find first buf_db no-lock       where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) )       no-error .     if not available buf_db then do:       message         substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) )         view-as alert-box information.     end.     else do:       if v-one-db <> true then do:         assign           v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else chr(44)) + entry( v-ind, v-rid-list )         .       end.       assign         v-db-list = v-db-list + (if v-db-list = "":U then "":U else chr(44)) + string( buf_db.db-num )       .     end.   end.   assign     v-rid-list = v-rid-list-new   .   run refresh-brws in this-procedure     ( input yes ) .
  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/send-nws.p
      ( input parparentproc
      , input "all":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + chr(32)
                        + substitute( "ERROR!!! Ошибка при отправке новостей в БД &1", v-db-num )  + chr(10)
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                        + substitute( "&1", return-value )
                      ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.
ON CHOOSE OF b-unsend IN FRAME nws-hand
DO:
  if not available X_db then do:     message       "Не выбрана БД."       view-as alert-box information.     return no-apply.   end.   find first buf_db no-lock     where buf_db.db-num = X_db.db-num     no-error .   if not available buf_db then do:     message       substitute( "БД &1 удалена.", X_db.db-num )       view-as alert-box information.     run refresh-brws in this-procedure       ( input yes ) .     return no-apply .   end.
  run nws/v-route.w
    ( input parparentproc
    , input X_db.db-num
    ).
END.
ON VALUE-CHANGED OF br-db IN FRAME nws-hand
DO:
  run refresh-brws in this-procedure
    ( input no
    ).
END.
ON CHOOSE OF bt-not-sel-all IN FRAME nws-hand
DO:
  define variable loc#log as logical no-undo .
  if available X_db then do:
    v-rid-list = "" .
    for each X_db where X_db.db-num <> 0 :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid9 as character no-undo .
define variable v-num-entry9 as integer   no-undo .
assign
  v-str-recid9 = trim( string( recid( X_db ) , "->>>>>>>>>>>9":U ) )
  v-num-entry9 = lookup( v-str-recid9 , v-rid-list )
.
if v-num-entry9 > 0 then do:
  assign
    entry( v-num-entry9, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid9
  .
end.
      loc#log = br-db:refresh() .
    end.
  end.
  if num-entries( v-rid-list ) <> 0 then do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame nws-hand.
  end.
END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME nws-hand
DO:
  define variable loc#log as logical no-undo .
  v-rid-list = "" .
  loc#log = br-db:refresh() .
  hide mark-num in frame nws-hand.
END.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame nws-hand anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame nws-hand. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME nws-hand:PARENT eq ?
THEN FRAME nws-hand:PARENT = ACTIVE-WINDOW.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame nws-hand
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
on choose of b-help in frame nws-hand
do:
  apply "help":u to frame nws-hand .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame nws-hand:width - 0.3
                fh            = frame nws-hand:first-child
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
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  run gbl/set-gbl.p
    ( input false
     ,input p-user-login
     ,input p-user-password
    ) no-error.
  if error-status:error then do:
    return error substitute( "&1. Ошибка при инициализации переменных g#...&2&3"
                             ,vss-workfile
                             ,chr(10)
                             ,error-status:get-message(error-status:num-messages)
                           ).
  end.
  assign
    hand-log-msg-h = news-log:handle
    g#news = true
  .
  define variable mDBInfo as character no-undo.
  run adm/db-info.p
    ( output v-cur-db-num
    , output mDBInfo
    ) no-error .
  if error-status:error then do:
    return error substitute( "&1. &2&3&4"
                             ,vss-workfile
                             ,mDBInfo
                             ,chr(10)
                             ,error-status:get-message(error-status:num-messages)
                            ).
  end.
  assign
    frame nws-hand:title = "СПН" + chr(32) + mDBInfo
    browse br-db :num-locked-columns = 1
  .
  RUN enable_UI.
  run refresh-brws in this-procedure
    ( input no
    ).
  do
  on ERROR  undo, leave
  on ENDKEY undo, leave
  on STOP   undo, retry
  :
    wait-for go of frame nws-hand.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME nws-hand.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY news-log mark-num f-not-rcvd
      WITH FRAME nws-hand.
  ENABLE RECT-3 b-exit b-get-pck b-create b-sync b-send-new b-info-all b-help b-mark
         b-get b-proc-pck b-send b-send-all b-unsend br-db br-pck-sent
         br-pck-rcvd news-log mark-num bt-not-sel-all bt-not-sel-desel-all
      WITH FRAME nws-hand.
  if v-cur-db-num <> 0 then do :
    disable bt-not-sel-all bt-not-sel-desel-all
      WITH FRAME nws-hand.
  end.
  if g#db-num = 0 then     OPEN QUERY br-db FOR EACH X_db where X_db.db-num > 0 NO-LOCK INDEXED-REPOSITION. else     OPEN QUERY br-db FOR EACH X_db where X_db.db-num = 0 NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE refresh-brws :
  define input parameter p-with-db as logical no-undo .
  define variable v-rowid as rowid no-undo .
  define buffer buf_pck-sent for ub.pck-sent .
  assign
    v-rowid = ?
  .
  if p-with-db = true then do:
    if available X_db then do:
      assign
        v-rowid = rowid( X_db )
        log-res = browse br-db :set-repositioned-row( browse br-db :focused-row, 'CONDITIONAL':u)
      .
    end.
    if g#db-num = 0 then     OPEN QUERY br-db FOR EACH X_db where X_db.db-num > 0 NO-LOCK INDEXED-REPOSITION. else     OPEN QUERY br-db FOR EACH X_db where X_db.db-num = 0 NO-LOCK INDEXED-REPOSITION.
    reposition br-db to rowid v-rowid no-error .
  end.
  OPEN QUERY br-pck-rcvd FOR EACH X_pck-rcvd       WHERE X_pck-rcvd.db-num = X_db.db-num  NO-LOCK     BY X_pck-rcvd.db-num DESCENDING        BY X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION.
  OPEN QUERY br-pck-sent FOR EACH X_pck-sent       WHERE X_pck-sent.db-num = X_db.db-num NO-LOCK     BY X_pck-sent.db-num DESCENDING        BY X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION.
  if available X_pck-sent then do:
    assign
      log-res = browse br-pck-sent :select-row( 1 )
    .
  end.
  if available X_pck-rcvd then do:
    assign
      log-res = browse br-pck-rcvd :select-row( 1 )
    .
  end.
  assign
    f-not-rcvd = 0
  .
  for each buf_pck-sent no-lock
    where buf_pck-sent.db-num = X_db.db-num
      and buf_pck-sent.rcvd   = false
  on error undo, return error
  :
    assign
      f-not-rcvd = f-not-rcvd + 1
      f-not-rcvd :screen-value in frame nws-hand = string( f-not-rcvd, f-not-rcvd :format in frame nws-hand)
    .
  end.
  if f-not-rcvd > 10 then do:
    assign
      f-not-rcvd:fgcolor = RED_COLOR
    .
  end.
  else do:
    assign
      f-not-rcvd:fgcolor = ?
    .
  end.
  display f-not-rcvd with frame nws-hand.
  if num-entries( v-rid-list ) = 0 then do:
    hide mark-num in frame nws-hand.
  end.
  else do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame nws-hand.
  end.
END PROCEDURE.
FUNCTION get-turn-on RETURNS LOGICAL
  ( INPUT v-db-key AS CHARACTER ) :
  RETURN (v-db-key <> "":U AND v-db-key <> ? ).
END FUNCTION.
