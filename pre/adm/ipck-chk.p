block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ipck-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/ipck-chk.p $":U .
define variable vss-description as character no-undo init "Проверка готовности пакета обновления к инсталляции".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-ext-file no-undo like ub.ext-file.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ipck-mf-process-manifest-file :
define input parameter p-manifest-file  as character no-undo .
define input parameter p-action as character no-undo .
  do
  on error undo, return error
  :
  end.
end procedure.
procedure ipck-mf-check-ipck :
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-manifest-file as character no-undo .
define variable v-md5-signature as character no-undo .
define variable v-path as character no-undo .
define variable v-full-path as character no-undo .
define buffer buf_Ext-file for ub.ext-file.
  do
  on error undo, return error return-value
  :
  for each buf_ext-file no-lock where
         buf_Ext-file.db-num = p-db-num
     and buf_Ext-file.from-db-num = p-from-db-num
     and  buf_Ext-file.file-type = p-manifest-file
  on error undo, return error
  :
    file-info:file-name = v-path + chr(47) + buf_ext-file.file-name.
    if FILE-INFO:FULL-PATHNAME = ? then do:
      return error substitute("Отсутствует файл &1", buf_ext-file.file-name).
    end.
        run gbl/md5.p (
       input  v-full-path
      ,output v-md5-signature
      ) .
    if
    not
    (
    buf_ext-file.create-sys-date      = file-info:FILE-CREATE-DATE
    AND
    buf_ext-file.create-sys-time      = STRING(file-info:FILE-create-TIME, "HH:MM:SS")
    AND
    buf_ext-file.create-sys-time-INT  = file-info:FILE-create-TIME
    AND
    buf_ext-file.update-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.update-sys-time      = STRING(file-info:FILE-MOD-TIME, "HH:MM:SS")
    AND
    buf_ext-file.update-sys-time-INT  = file-info:FILE-MOD-TIME
    AND
    buf_ext-file.file-size            = FILE-INFO:FILE-SIZE
    AND
    buf_ext-file.crc-field            = v-md5-signature
    )
    then do:
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_ext-file.file-name).
    end.
    if
    not
    (
    buf_ext-file.create-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
    AND
    buf_ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
    AND
    buf_ext-file.update-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.file-size            = FILE-INFO:FILE-SIZE
    AND
    buf_ext-file.crc-field            = v-md5-signature
    and
    buF_ext-file.file-name = buf_ext-file.file-type
    ) then do:
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_ext-file.file-name).
    end.
  end.
  end.
end procedure.
define variable p-db-num as integer no-undo .
define variable p-from-db-num as integer no-undo .
define variable p-file-name  as character no-undo .
define variable p-action as character no-undo .
define variable p-lock-par as character no-undo .
define variable v-lock-par as character no-undo .
define buffer buf_ext-file for ub.ext-file.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
assign
p-db-num = integer(entry(1, p-parameter, chr(4) ))
p-from-db-num = integer(entry(2, p-parameter, chr(4) ))
p-file-name = entry(3, p-parameter, chr(4) )
p-action = entry(4, chr(4))
no-error .
if error-status:error then do:
  return error substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         ).
end.
assign
p-lock-par = (if num-entries(p-action) > 1
              then entry(2, p-action)
              else '':U)
p-action = entry(1, p-action)
.
CASE p-action:
  when 'query':U then do:
    find first buf_ext-file exclusive-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-type = p-file-name
        and buf_Ext-file.file-name = p-file-name no-error.
    if not available buf_ext-file then do:
      if p-db-num = g#db-num and g#db-num = 0
      then do:
      end.
      else do:
        run nws/cr-route.p (
                    input 'send-cmd':U
                    ,input ("command"
                            + chr(1) + "run-file"
                            + chr(1) + "ipck-chk.p"
                            + chr(1) + (string(buf_Ext-file.db-num)
                            + chr(4) +  string(buf_Ext-file.from-db-num)
                            + chr(4) +  buf_ext-file.FILE-NAME
                            + chr(4) + 'reply':U + chr(44) + "not-found"))
                    ,input ?
                    ,input string(0)
                    ) no-error .
      end.
    end.
    run ipck-mf-check-ipck in this-procedure ( input p-db-num, input p-from-db-num, input p-file-name) no-error.
    if error-status:error then do:
      v-lock-par = 'error':U.
    end.
    else do:
      v-lock-par = 'готов':U.
    end.
    if g#db-num = 0 and p-db-num = g#db-num then do:
      run adm/ipck-chk.p ( INPUT parparentproc
                            ,INPUT p-parent-handle
                            ,INPUT p-log-handle
                            ,INPUT (string(buf_ext-file.db-num)
                                      + chr(4) + string(buf_ext-file.from-db-num)
                                      + chr(4) + buf_ext-file.FILE-NAME
                                      + chr(4) + 'reply':U + chr(44) + v-lock-par)).
    end.
    else do:
      run nws/cr-route.p (
                    input 'send-cmd':U
                    ,input ("command"
                            + chr(1) + "run-file"
                            + chr(1) + "ipck-chk.p"
                            + chr(1) + (string(buf_Ext-file.db-num)
                            + chr(4) +  string(buf_ext-file.from-db-num)
                            + chr(4) +  buf_ext-file.FILE-NAME
                            + chr(4) + 'reply':U + chr(44) + v-lock-par))
                  ,input ?
                  ,input string(0)
                  ) no-error .
    end.
  end.
  when 'reply':U then do:
    find first buf_ext-file no-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-type = p-file-name
        and buf_Ext-file.file-name = p-file-name no-error.
    if available buf_Ext-file then do:
      find first buf_ext-file exclusive-lock where
              buf_Ext-file.db-num = p-db-num
          and buf_Ext-file.from-db-num = p-from-db-num
          and buf_Ext-file.file-type = p-file-name
          and buf_Ext-file.file-name = p-file-name .
      ASSIGN
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, 'готов':U, "":U)
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, chr(63), "":U)
      buf_Ext-file.STATUS_ = trim(buf_Ext-file.STATUS_, chr(44))
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, chr(44) + chr(44), chr(44))
      buf_Ext-file.STATUS_ = buf_Ext-file.STATUS_ + chr(44) + p-lock-par
      buf_Ext-file.STATUS_ = trim(buf_Ext-file.STATUS_, chr(44))
      .
    end.
  end.
END CASE.
end.
