block-level on error undo, throw.
define input parameter p0-action     as character no-undo .
define input parameter p0-arch-type  as character no-undo .
define input parameter p0-file-name  as character no-undo .
define input parameter p0-source-dir as character no-undo .
define input parameter p0-target-dir as character no-undo .
define input parameter p0-temp-dir   as character no-undo .
def var vss-revision    as character no-undo init "$Revision: 0913db48c0a8, 1234, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Mon Feb 26 19:29:32 2018 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: s-g-pack.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/s-g-pack.p $":U .
def var vss-description as character no-undo init "отправка и прием пакета новостей (файла)".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define stream FLStream.
  define variable v-filename         as character no-undo .
  define variable v-fullfilename     as character no-undo .
  define variable v-filetype         as character no-undo .
  assign
    file-info:file-name = p0-temp-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U )
  then do:
    os-create-dir value( p0-temp-dir ).
    if os-error <> 0 then do:
      return error substitute( "&1. Каталог &2 отсутствует, а создать его не удалось.", vss-workfile, p0-temp-dir ).
    end.
  end.
  if p0-file-name <> ? then do:
    run file-s-g ( input p0-action
                  ,input p0-arch-type
                  ,input p0-file-name
                  ,input p0-source-dir
                  ,input p0-target-dir
                  ,input p0-temp-dir
                 ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  else do:
    input stream FLStream from os-dir ( p0-source-dir ) .
    repeat
    on error  undo, return error substitute( "&1 (repeat). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (repeat). stop", vss-workfile )
    :
      import stream FLStream v-filename v-fullfilename v-filetype.
      if v-filetype begins "F"
        and num-entries( v-filename, "." ) > 1
      then do:
        assign
          file-info:file-name = v-fullfilename
        .
        if lookup(entry( num-entries( v-filename, "." ), v-filename, "." ), "$$$") = 0
          and file-info:file-type MATCHES "*W*":U
          and file-info:file-type MATCHES "*R*":U
          and not ( file-info:file-type MATCHES "*H*":U )
        then do:
          run file-s-g ( input p0-action
                        ,input p0-arch-type
                        ,input v-filename
                        ,input p0-source-dir
                        ,input p0-target-dir
                        ,input p0-temp-dir
                      ) no-error.
          if error-status :error then do:
            return error return-value.
          end.
        end.
      end.
    END.
    input stream FLStream close.
  end.
  return .
end.
procedure file-s-g :
  define input parameter p-action     as character no-undo .
  define input parameter p-arch-type  as character no-undo .
  define input parameter p-file-name  as character no-undo .
  define input parameter p-source-dir as character no-undo .
  define input parameter p-target-dir as character no-undo .
  define input parameter p-temp-dir   as character no-undo .
  do
  on error  undo, return error substitute( "&1 (file-s-g). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (file-s-g). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (file-s-g). endkey", vss-workfile )
  :
    define variable v-arch-type        as character no-undo .
    define variable v-arh-name         as character no-undo .
    define variable v-file-source      as character no-undo .
    define variable v-file-source-arj  as character no-undo .
    define variable v-file-temp        as character no-undo .
    define variable v-file-target      as character no-undo .
    define variable v-file-hash        as character no-undo .
    define variable v-file-name-no-ext as character no-undo .
    define variable v-ext-name         as character no-undo .
    define variable v-err-mess         as character no-undo .
        if p-file-name BEGINS "RC_":U or p-file-name BEGINS "update_":U or p-file-name BEGINS "UFO-":U then do:
      assign
        p-arch-type = "":U
      .
    end.
    if r-index( p-file-name, '.':u) > 0 then do:
      assign
        v-file-name-no-ext = substring( p-file-name, 1, r-index( p-file-name, '.':u) - 1 )
        v-ext-name         = entry( num-entries( p-file-name, "." ), p-file-name, "." )
      .
    end.
    else do:
      assign
        v-file-name-no-ext = p-file-name
        v-ext-name         = "":U
      .
    end.
    assign
      v-file-source     = p-source-dir + chr(92) + p-file-name
      v-file-temp       = p-temp-dir   + chr(92) + p-file-name
      v-file-target     = p-target-dir + chr(92) + p-file-name
    .
    assign
      file-info:file-name = v-file-source
    .
    if file-info:file-type = ?
      or not ( file-info:file-type begins "F":U )
    then do:
      return error substitute( "&1. Исходный файл &2 не найден.", vss-workfile, v-file-source ).
    end.
    run gbl/md5.p(v-file-source, output v-file-hash).
    run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-file-source,  v-file-hash) ) .
    if p-action = "put":U then do:
      if p-arch-type <> "":U then do:
        case p-arch-type :
          when "7zip":U then do:
            assign
              v-arh-name = search( "exe/7z.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/7za.exe":U )
              .
            end.
          end.
          when "arj":U then do:
            assign
              v-arh-name = search( "exe/arj32.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/arj.exe":U )
              .
            end.
          end.
        end case.
        if v-arh-name = ? then do:
          return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
        end.
        run write-to-log( substitute( "Отправка файла &1 (&2)", v-file-source, v-arh-name ) ).
        assign
          v-file-source-arj = p-source-dir + chr(92) + v-file-name-no-ext
          v-file-temp       = p-temp-dir   + chr(92) + v-file-name-no-ext
          v-file-target     = p-target-dir + chr(92) + v-file-name-no-ext
        .
        case p-arch-type :
          when "7zip":U then do:
            assign
              v-file-source-arj = v-file-source-arj + ".zip":U
              v-file-temp       = v-file-temp       + ".zip":U
              v-file-target     = v-file-target     + ".zip":U
            .
            os-command silent
              value( substitute( "&1 a -tzip -y &2 &3":U, v-arh-name, v-file-source-arj, v-file-source ) )
            .
          end.
          when "arj":U then do:
            assign
              v-file-source-arj = v-file-source-arj + ".arj":U
              v-file-temp       = v-file-temp       + ".arj":U
              v-file-target     = v-file-target     + ".arj":U
            .
            os-command silent
              value( substitute( "&1 a -e -y &2 &3":U, v-arh-name, v-file-source-arj, v-file-source ) )
            .
          end.
        end case.
      end.
      else do:
        run write-to-log( substitute( "Отправка файла &1 (copy)", v-file-source ) ).
        assign
          v-file-source-arj = v-file-source
        .
      end.
      run del-file in this-procedure
        ( input v-file-temp
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      os-copy
        value( v-file-source-arj )
        value( v-file-temp )
        .
      if os-error <> 0 then do:
        run adm/os-err.p
          ( output v-err-mess
          ).
        return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, chr(10), v-err-mess ) .
      end.
      if p-arch-type <> "":U then do:
        run del-file in this-procedure
          ( input v-file-source-arj
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.
      run ren-file in this-procedure
        ( input v-file-temp
        , input v-file-target
        ) no-error .
      if error-status :error then do:
        assign
          v-err-mess = return-value
        .
        run del-file in this-procedure
          ( input v-file-temp
          ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = v-err-mess + chr(10) + return-value
          .
        end.
        return error v-err-mess .
      end.
    end.
    else do:
            if p-file-name BEGINS "RC_":U or p-file-name BEGINS "update_":U or p-file-name BEGINS "UFO-":U then do:
        run write-to-log( substitute( "Прием и обработка пакетов update", v-file-source ) ) .
        run adm/upd-rc.p
          ( input p-source-dir
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка приема и(или) обработки пакетов update!&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
        end.
      end.
      else do:
        if v-ext-name = "zip":U then do:
          assign
            v-arch-type = "7zip":U
            v-arh-name  = search( "exe/7z.exe":U )
          .
          if v-arh-name = ? then do:
            assign
              v-arh-name = search( "exe/7za.exe":U )
            .
          end.
        end.
        else do:
          if lookup( v-ext-name, "arj") <> 0 then do:
            assign
              v-arch-type = "arj":U
              v-arh-name  = search( "exe/arj32.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/arj.exe":U )
              .
            end.
          end.
          else do:
            assign
              v-arch-type = "":U
              v-arh-name  = "copy":U
            .
          end.
        end.
        if v-arch-type <> "":U
          and v-arh-name = ?
        then do:
          return error substitute( "&1. Программа архиватор не найдена для файла с расширением &2!", vss-workfile, v-ext-name ).
        end.
        run write-to-log( substitute( "Прием файла &1 (&2)", v-file-source, v-arh-name ) ) .
        run ren-file in this-procedure
          ( input v-file-source
          , input v-file-temp
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        run del-file in this-procedure
          ( input v-file-target
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        os-copy
          value( v-file-temp )
          value( v-file-target )
          .
        if os-error <> 0 then do:
          run adm/os-err.p
            ( output v-err-mess
            ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, chr(10), v-err-mess ).
        end.
        run del-file in this-procedure
          ( input v-file-temp
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        if v-arch-type <> "":U then do:
          case v-arch-type :
            when "7zip":U then do:
              os-command silent
                value( substitute( "&1 e -y &2 -o&3":U, v-arh-name, v-file-target, p-target-dir ) )
              .
            end.
            when "arj":U then do:
              os-command silent
                value( substitute( "&1 e -y &2 &3":U, v-arh-name, v-file-target, p-target-dir ) )
              .
            end.
          end case.
          run del-file in this-procedure
            ( input v-file-target
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure del-file :
  define input parameter p-del-file-name as character no-undo .
  do
  on error  undo, return error substitute( "&1 (del-file). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (del-file). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (del-file). endkey", vss-workfile )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    define variable v-str      as character no-undo .
    assign
      file-info:file-name = p-del-file-name
    .
    if file-info:file-type <> ? then do:
      if file-info:file-type begins "F":U then do:
        assign
          v-str = "файл"
        .
      end.
      else do:
        if file-info:file-type begins "D":U then do:
          assign
            v-str = "каталог"
          .
        end.
        else do:
          assign
            v-str = "не знаю что"
          .
        end.
      end.
      bl1:
      do v-ind = 1 to 60 :
        os-delete value( p-del-file-name ).
        assign
          v-err-code = os-error
          file-info:file-name = p-del-file-name
        .
        if v-err-code = 0
          or file-info:file-type = ?
        then do:
          leave bl1 .
        end.
        pause 1 no-message .
      end.
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно удалить &2 &3&4&5", vss-workfile, v-str, p-del-file-name, chr(10), v-err-mess ).
      end.
    end.
  end.
  return.
end procedure.
procedure ren-file :
  define input parameter p-file-source as character no-undo .
  define input parameter p-file-target as character no-undo .
  do
  on error  undo, return error substitute( "&1 (ren-file). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (ren-file). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-file). endkey", vss-workfile )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    run del-file ( input p-file-target ) no-error .
    if error-status :error then do:
      return error return-value .
    end.
    bl1:
    do v-ind = 1 to 60 :
      os-rename value( p-file-source ) value( p-file-target ).
      assign
        v-err-code = os-error
        file-info:file-name = p-file-source
      .
      if v-err-code = 0
        or file-info:file-type = ?
      then do:
        leave bl1 .
      end.
      pause 1 no-message .
    end.
    if v-err-code <> 0 then do:
      run adm/os-err.p ( output v-err-mess ).
      return error substitute( "&1. Невозможно переименовать файл &2 в &3&4&5", vss-workfile, p-file-source, p-file-target, chr(10), v-err-mess ).
    end.
  end.
end procedure.
