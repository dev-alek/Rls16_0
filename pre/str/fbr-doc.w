define input  parameter parparentproc             as handle    no-undo .
define input  parameter p-fbrhist-handle          as handle    no-undo .
define input  parameter p-doc-mode                as character no-undo .
define input  parameter p-fbr-doc-recid           as recid     no-undo .
define output parameter p-new-fbr-doc-recid       as recid     no-undo .
define input-output parameter p-fbr-doc-next-prev as logical   no-undo .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ производства.".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    if search('fbr.log') = ?
    then do:
        assign
            log-file-name = ""
        .
    end.
    else do:
        assign
            log-file-name = 'fbr.log'
        .
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrcode-doc-code no-undo
    field rec-type      as character
    field doc-code      as character
    field obj-type      as character
    field obj-code      as integer
    field cli-type      as character
    field cli-code      as integer
    field ext-doc-type  as character
    field doc-type      as character
    field order         as integer
    index pi is primary unique rec-type doc-code
    index od order
.
procedure fbrcode-gen-recipe-code :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-recipe-code       as character    no-undo.
    assign
        p-recipe-code   = string( next-value( s-recipe, ub ) )
                            + "-"
                            + trim( string( p-obj-code, ">>>>9" ) )
                            + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    .
end.
end procedure.
procedure fbrcode-is-from-object :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-is-from-object    as logical      no-undo.
    if num-entries( p-doc-code, "-" ) < 2
    or entry( 2, p-doc-code, "-" ) <> trim (string (p-obj-code, ">>>>9"))
                                    + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    then do:
        assign
            p-is-from-object = no
        .
    end.
    else do:
        assign
            p-is-from-object = yes
        .
    end.
end.
end procedure.
procedure fbrcode-trn-doc :
do
on error undo, return error
:
    define input parameter p-out-doc-type       as character    no-undo.
    define input parameter p-out-code           as character    no-undo.
    define input parameter p-trn-doc-out-type   as character    no-undo.
    define output parameter p-trn-doc-doc-code  as character   no-undo.
    case p-out-doc-type:
        when 'производство':U
        then do:
            case p-trn-doc-out-type :
                when 'рас':U
                then do:
                    assign
                        p-trn-doc-doc-code = p-out-code
                    .
                end.
                when 'при':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "=" )
                    .
                end.
                when 'спи':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "*" )
                    .
                end.
                otherwise do:
                    assign
                        p-trn-doc-doc-code = ""
                    .
                    undo, return error "Не может быть обработан тип складского документа '"
                                        + p-trn-doc-out-type + "' во входных параметрах".
                end.
            end case.
        end.
        otherwise do:
            assign
                p-trn-doc-doc-code = ""
            .
            undo, return error "Не может быть обработан тип внешнего документа '"
                                + p-out-doc-type + "' во входных параметрах".
        end.
    end case.
end.
end procedure.
procedure fbrcode-fill-fbr-by-sale-or-pln :
define input parameter p-main-doc-code      as character        no-undo.
    define variable v-order    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_fbr-doc
  , buf_trn-doc
  , buf_temp_fbrcode-doc-code
on error undo, return error
:
    for each buf_temp_fbrcode-doc-code
    on error undo, return error
    :
        delete buf_temp_fbrcode-doc-code.
    end.
    assign
        v-order = 0
    .
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-main-doc-code
    on error undo, return error
    :
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.rec-type      = 'производство':U
            buf_temp_fbrcode-doc-code.doc-code      = buf_fbr-doc.doc-code
            buf_temp_fbrcode-doc-code.ext-doc-type  = "":U
            buf_temp_fbrcode-doc-code.obj-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_fbr-doc.doc-type
        .
        for each buf_trn-doc no-lock
           where buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error
        :
            if buf_trn-doc.ext-doc-type = 'em':U
            or buf_trn-doc.ext-doc-type = 'im':U
            or buf_trn-doc.ext-doc-type = 'wm':U
            or buf_trn-doc.ext-doc-type = 'ev':U
            then do:
                assign
                    v-order = v-order + 1
                .
                create buf_temp_fbrcode-doc-code.
                assign
                    buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
                    buf_temp_fbrcode-doc-code.rec-type      = 'скл':U
                    buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
                    buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
                    buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
                    buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
                    buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
                    buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
                    buf_temp_fbrcode-doc-code.order         = v-order
                .
            end.
        end.
        assign
            v-order  = v-order + 1
        .
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.rec-type = 'производство':U
               and buf_temp_fbrcode-doc-code.doc-code = buf_fbr-doc.doc-code
        .
        assign
            buf_temp_fbrcode-doc-code.order = v-order
        .
    end.
    for each buf_trn-doc no-lock
       where buf_trn-doc.out-code = p-main-doc-code
    by buf_trn-doc.fact-order
    on error undo, return error
    :
        assign
            v-order = v-order + 1
        .
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
            buf_temp_fbrcode-doc-code.rec-type      = 'маг':U
            buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
            buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
            buf_temp_fbrcode-doc-code.order         = v-order
        .
    end.
end.
end procedure.
procedure fbrcode-get-final-doc :
define input parameter p-main-doc-code      as character        no-undo.
define output parameter p-income-doc-code   as character        no-undo.
    define variable v-main-obj-type    as character    no-undo.
    define variable v-main-obj-code    as integer      no-undo.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-main-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-main-doc-code
    .
    assign
        v-main-obj-type = buf_trn-doc.obj-type
        v-main-obj-code = buf_trn-doc.obj-code
    .
    find first buf_temp_fbrcode-doc-code
         where buf_temp_fbrcode-doc-code.ext-doc-type = 'ev':U
           and buf_temp_fbrcode-doc-code.cli-type     = v-main-obj-type
           and buf_temp_fbrcode-doc-code.cli-code     = v-main-obj-code
    no-error.
    if available buf_temp_fbrcode-doc-code
    then do:
        find first buf_trn-doc no-lock
             where buf_trn-doc.out-code     = buf_temp_fbrcode-doc-code.doc-code
               and buf_trn-doc.ext-doc-type = 'iv':U
        .
        assign
            p-income-doc-code = buf_trn-doc.doc-code
        .
    end.
    else do:
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.ext-doc-type = 'im':U
               and buf_temp_fbrcode-doc-code.obj-type     = v-main-obj-type
               and buf_temp_fbrcode-doc-code.obj-code     = v-main-obj-code
        no-error.
        if available buf_temp_fbrcode-doc-code
        then do:
            assign
                p-income-doc-code = buf_temp_fbrcode-doc-code.doc-code
            .
        end.
        else do:
            assign
                p-income-doc-code = "":U
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrlib_recipe no-undo
    field recipe-code                   as character
    field fbr-doc-code                  as character
    field income-goods-doc-code         as character
    field count-income                  as integer
    field qnty-income                   as decimal
    field sum-income-sale               as decimal
    field sum-income-cost-base          as decimal
    field sum-income-cost-rubl          as decimal
    field sum-income-vat-cost-base      as decimal
    field sum-income-vat-cost-rubl      as decimal
    field write-off-goods-doc-code      as character
    field write-off-office-doc-code     as character
    field count-write-off               as integer
    field qnty-write-off                as decimal
    field sum-write-off-sale            as decimal
    field sum-write-off-cost-base       as decimal
    field sum-write-off-cost-rubl       as decimal
    field sum-write-off-vat-cost-base   as decimal
    field sum-write-off-vat-cost-rubl   as decimal
index pi is primary unique recipe-code
index income income-goods-doc-code
index wogds write-off-goods-doc-code
index wooff write-off-office-doc-code
.
define temp-table temp_dressing-ingr no-undo
    field recipe-code   as character
    field gds-code      as integer
    field line-qnty     as decimal
    field used-qnty     as decimal
    field recipe-qnty   as decimal
    index pi is primary unique recipe-code gds-code
.
define temp-table temp_recipe-order no-undo
    field recipe-code   as character
    field order         as integer
    index pi is primary unique order
.
define temp-table temp_recipe-childs-qnty no-undo
    field recipe-code   as character
    field childs-qnty   as integer
    field order         as integer
    index pi is primary unique recipe-code
.
define temp-table temp_recipe-childs no-undo
    field recipe-code       as character
    field child-code        as integer
    field child-recipe-code as character
    index pi is primary unique recipe-code child-code
.
define variable v-fbrlib-recipe-order               as integer  no-undo.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fbrlib_create-fbr-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-userid as character no-undo .
define output parameter p-fbr-doc-code as character no-undo .
define output parameter p-recid as recid no-undo .
define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-db-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-code as character no-undo .
define variable fi-pay-code as integer no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_curr-accnt for ub.curr-accnt.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-obj-db-num <> v-db-num then do:
  return error substitute("Запрещено создание документа производства в чужой БД:&1БД &2&3 - &4&1текущая БД - &5"
                          , chr(10)
                          , p-obj-type
                          , p-obj-code
                          , v-obj-db-num
                          , v-db-num).
end.
run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
find last buf_curr-accnt no-lock
    where buf_curr-accnt.curr-code = v-base-code
      and buf_curr-accnt.exch-date <= v-today use-index pi
no-error.
if not available buf_curr-accnt
then do:
  undo, return error substitute("На дату &1 неизвестен курс базовой валюты с кодом &2"
                                  , string(v-today, "99/99/9999")
                                  , v-base-code).
end.
run doc-code in this-procedure (
      input  "main"
    , input  p-obj-type
    , input  p-obj-code
    , input  ?
    , output v-doc-code
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при генерации номера документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
run trg/chkdocnm.p (
      input v-doc-code
    , input 'fbr-doc':U
    , input ?
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при проверке номера для нового документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
create buf_fbr-doc.
assign
buf_fbr-doc.doc-code  = v-doc-code
buf_fbr-doc.creid     = p-userid
buf_fbr-doc.doc-date  = v-today
buf_fbr-doc.doc-type  = 'производство':U
buf_fbr-doc.host-code = v-host-code
buf_fbr-doc.obj-code  = p-obj-code
buf_fbr-doc.obj-type  = p-obj-type
buf_fbr-doc.PS        = "@"
buf_fbr-doc.status_   = 'новый':U
buf_fbr-doc.user-db-num = v-obj-db-num
buf_fbr-doc.user-name   = p-userid
.
run fbrlib_get-default-pay-code in this-procedure (
      input buf_fbr-doc.obj-type
    , input buf_fbr-doc.obj-code
    , output fi-pay-code
).
buf_fbr-doc.pay-code = fi-pay-code.
p-recid = recid(buf_fbr-doc).
p-fbr-doc-code = buf_fbr-doc.doc-code.
end.
end procedure.
procedure fbrlib_get-default-pay-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-pay-code  as integer          no-undo.
define variable v-host-code as integer no-undo .
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.
define buffer buf_sysconf       for ub.sysconf.
do
for buf_shop
  , buf_store
  , buf_sysconf
on error undo, return error
:
  case p-obj-type  :
    when 'маг':U then do:
        find first buf_shop no-lock
              where buf_shop.obj-code = p-obj-code
        no-error.
        if available buf_shop
        then do:
            assign
                p-pay-code = buf_shop.fbr-pay
            .
        end.
    end.
    when 'скл':U then do:
        find first buf_store no-lock
              where buf_store.obj-code = p-obj-code
        no-error.
        if available buf_store
        then do:
            assign
                p-pay-code = buf_store.fbr-pay
            .
        end.
    end.
  end case.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
      no-error.
      if available buf_sysconf
      then do:
          assign
              p-pay-code = buf_sysconf.fbr-pay
          .
      end.
  end.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-pay-code
  )  .
  end.
end.
end procedure.
procedure fbrlib-fill-and-check-temp_fbrlib_recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-code as character    no-undo.
    define variable vss-description as character    no-undo init "fbrlib-fill-and-check-temp_fbrlib_recipe: ".
    define variable v-gds-name      as character    no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    define buffer buf_out_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    for each buf_temp_fbrlib_recipe
    :
        delete buf_temp_fbrlib_recipe.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-code
    :
        find first buf_temp_fbrlib_recipe
             where buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available buf_temp_fbrlib_recipe
        then do:
            create buf_temp_fbrlib_recipe.
            assign
                buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
                buf_temp_fbrlib_recipe.fbr-doc-code = buf_fbr-line.doc-code
            .
        end.
    end.
    for each buf_temp_fbrlib_recipe
    :
        assign
            buf_temp_fbrlib_recipe.count-income                = 0
            buf_temp_fbrlib_recipe.qnty-income                 = 0
            buf_temp_fbrlib_recipe.sum-income-sale             = 0
            buf_temp_fbrlib_recipe.sum-income-cost-base        = 0
            buf_temp_fbrlib_recipe.sum-income-cost-rubl        = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-base    = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl    = 0
            buf_temp_fbrlib_recipe.count-write-off             = 0
            buf_temp_fbrlib_recipe.qnty-write-off              = 0
            buf_temp_fbrlib_recipe.sum-write-off-sale          = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-base     = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'при':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-income             = buf_temp_fbrlib_recipe.count-income + 1
                buf_temp_fbrlib_recipe.qnty-income              = buf_temp_fbrlib_recipe.qnty-income
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-income-sale          = buf_temp_fbrlib_recipe.sum-income-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-income-cost-base     = buf_temp_fbrlib_recipe.sum-income-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-income-cost-rubl     = buf_temp_fbrlib_recipe.sum-income-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-base = buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'спи':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            and buf_fbr-doc.status_    = 'разрешен':U
            then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-write-off             = buf_temp_fbrlib_recipe.count-write-off + 1
                buf_temp_fbrlib_recipe.qnty-write-off              = buf_temp_fbrlib_recipe.qnty-write-off
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-write-off-sale          = buf_temp_fbrlib_recipe.sum-write-off-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-write-off-cost-base     = buf_temp_fbrlib_recipe.sum-write-off-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        if buf_fbr-doc.status_    = 'разрешен':U
        and ( abs( buf_temp_fbrlib_recipe.sum-write-off-cost-base     - buf_temp_fbrlib_recipe.sum-income-cost-base     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     - buf_temp_fbrlib_recipe.sum-income-cost-rubl     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base - buf_temp_fbrlib_recipe.sum-income-vat-cost-base ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl - buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl ) > 0.01
            )
        then do:
         undo, return error
            substitute("В документе пр-ва &1 Не совпадают суммы учетных цен для списанного и оприходованного по рецепту товара.&2" +
                        "Рецепт: &3&2&4&4по списанному товару&4по оприходованному товару&2"  +
                        "Сумма в баз.вал.&4&5&4&4&6&2" +
                        "Сумма в &9.&4&7&4&4&8&2"
                       , buf_fbr-doc.doc-code
                       , chr(10)
                       , buf_temp_fbrlib_recipe.recipe-code
                       , chr(9)
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-base
                       , buf_temp_fbrlib_recipe.sum-income-cost-base
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                       , buf_temp_fbrlib_recipe.sum-income-cost-rubl
                       , "руб"
                       )
           +
           substitute("НДС в баз.вал.&1&2&1&1&3&4" +
                      "НДС в &7.&1&5&1&1&6&4"
                     ,  chr(9)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                     ,chr(10)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                     ,"руб"
                     )       .
        end.
    end.
end.
end procedure.
procedure fbrlib-fill-sum-fbr-doc :
do
on error undo, return error
:
define input parameter p-fbr-doc-recid  as recid        no-undo.
define input parameter p-mode           as character    no-undo.
    define variable vss-description as character init "fbrlib-fill-sum-fbr-doc: "  no-undo.
    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe   for temp_fbrlib_recipe.
    define variable v-in-count          as integer       no-undo.
    define variable v-out-count         as integer       no-undo.
    find first buf_fbr-doc exclusive-lock
         where recid ( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_temp_fbrlib_recipe no-error.
    if not available buf_temp_fbrlib_recipe
    then do:
        run fbrlib-fill-and-check-temp_fbrlib_recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("&1 Ошибка расчета сумм при заполнении шапки документа производства.&2&3&2&4"
                                           , vss-description
                                           , chr(10)
                                           , error-status:get-message(1)
                                           , return-value ).
        end.
    end.
    assign
        v-in-count                  = 0
        buf_fbr-doc.in-qnty         = 0
        buf_fbr-doc.in-sale         = 0
        buf_fbr-doc.in-base         = 0
        buf_fbr-doc.in-rubl         = 0
        buf_fbr-doc.in-vat-base     = 0
        buf_fbr-doc.in-vat-rubl     = 0
        v-out-count                 = 0
        buf_fbr-doc.out-qnty        = 0
        buf_fbr-doc.out-sale        = 0
        buf_fbr-doc.out-base        = 0
        buf_fbr-doc.out-rubl        = 0
        buf_fbr-doc.out-vat-base    = 0
        buf_fbr-doc.out-vat-rubl    = 0
    .
    for each buf_temp_fbrlib_recipe
    :
        assign
            v-in-count                  = v-in-count                + buf_temp_fbrlib_recipe.count-income
            buf_fbr-doc.in-qnty         = buf_fbr-doc.in-qnty       + buf_temp_fbrlib_recipe.qnty-income
            buf_fbr-doc.in-sale         = buf_fbr-doc.in-sale       + buf_temp_fbrlib_recipe.sum-income-sale
            buf_fbr-doc.in-base         = buf_fbr-doc.in-base       + buf_temp_fbrlib_recipe.sum-income-cost-base
            buf_fbr-doc.in-rubl         = buf_fbr-doc.in-rubl       + buf_temp_fbrlib_recipe.sum-income-cost-rubl
            buf_fbr-doc.in-vat-base     = buf_fbr-doc.in-vat-base   + buf_temp_fbrlib_recipe.sum-income-vat-cost-base
            buf_fbr-doc.in-vat-rubl     = buf_fbr-doc.in-vat-rubl   + buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
            v-out-count                 = v-out-count               + buf_temp_fbrlib_recipe.count-write-off
            buf_fbr-doc.out-qnty        = buf_fbr-doc.out-qnty      + buf_temp_fbrlib_recipe.qnty-write-off
            buf_fbr-doc.out-sale        = buf_fbr-doc.out-sale      + buf_temp_fbrlib_recipe.sum-write-off-sale
            buf_fbr-doc.out-base        = buf_fbr-doc.out-base      + buf_temp_fbrlib_recipe.sum-write-off-cost-base
            buf_fbr-doc.out-rubl        = buf_fbr-doc.out-rubl      + buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
            buf_fbr-doc.out-vat-base    = buf_fbr-doc.out-vat-base  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
            buf_fbr-doc.out-vat-rubl    = buf_fbr-doc.out-vat-rubl  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
        .
    end.
    if ( abs (buf_fbr-doc.in-rubl - buf_fbr-doc.out-rubl) <= 0.01
    and   abs (buf_fbr-doc.in-base - buf_fbr-doc.out-base) <= 0.01 )
    or p-mode <> 'факт':U
    then do:
        if substring( buf_fbr-doc.PS, 1, 1 ) = "@"
        then do:
            assign
                buf_fbr-doc.PS = "@ Строк полученных товаров : "
                                + string( v-out-count, ">>>,>>9" )
                                + chr(10) + "Строк исходных товаров : "
                                + string( v-in-count, ">>>,>>9" )
            .
        end.
    end.
    else do:
      undo, return error substitute("В док-те пр-ва &1 не совпадают суммы списанных и оприходованных товаров.&2" +
                                    "Сумма списанных товаров в &3 - &4&2" +
                                    "Сумма оприходованных товаров в &3 - &5&2" +
                                    "Сумма оприходованных товаров в &3 - &6&2" +
                                    "Сумма списанных товаров в баз.вал. - &7&2" +
                                    "Сумма оприходованных товаров в баз.вал. - &8&2"
                                    , buf_fbr-doc.doc-code
                                    , chr(10)
                                    , "рублях"
                                    , round( buf_fbr-doc.out-rubl, 2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.out-base, 2 )
                                    , round( buf_fbr-doc.in-base,  2 )).
    end.
end.
end procedure.
procedure fbrlib-calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-line-recid as recid        no-undo.
define input parameter p-price-obj-type as character    no-undo.
define input parameter p-price-obj-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.
    define variable v-void          as decimal       no-undo.
    define variable v-void-char     as character     no-undo.
    define variable v-gds-code      as integer       no-undo.
    define variable v-b-code        as integer       no-undo.
    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_gds-prt   for ub.gds-prt.
    define buffer buf_bar-code  for ub.bar-code.
    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения кода товара (артикул &7).&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , buf_fbr-line.artic
                                      ).
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения основного бар-кода товара (код товара) &7.&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , v-gds-code
                                      ).
    end.
    if buf_fbr-line.is-calc = no
    then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-price-obj-type
  ,input  p-price-obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-void-char
  ,output p-current-price
  ,output v-void
  ,output v-void
  ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("&1 &2 &3&4Ошибка определения продажной цены основного бар-кода товара (код товара) &7.&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          , v-gds-code
                                          ).
        end.
    end.
    else do:
        assign
            p-current-price = buf_fbr-line.price-sale
        .
    end.
end.
end procedure.
procedure fbrlib-put-in-order-recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
    define variable v-recipe-counter    as integer          no-undo.
    define variable v-recipe-amount     as integer init 0   no-undo.
    define variable v-child-counter     as integer          no-undo.
    define variable v-is-call-cycle     as logical          no-undo.
    define variable v-str as character     no-undo.
    define buffer buf_in_fbr-line       for ub.fbr-line.
    define buffer buf_dress_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    for each temp_recipe-childs-qnty
    :
        delete temp_recipe-childs-qnty.
    end.
    for each temp_recipe-childs
    :
        delete temp_recipe-childs.
    end.
    for each temp_recipe-order
    :
        delete temp_recipe-order.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first temp_recipe-childs-qnty
             where temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available temp_recipe-childs-qnty
        then do:
            create temp_recipe-childs-qnty.
            assign
                v-recipe-amount                     = v-recipe-amount + 1
                temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
                temp_recipe-childs-qnty.order       = v-recipe-amount
                temp_recipe-childs-qnty.childs-qnty = 0
                v-child-counter                     = 0
            .
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'спи':U
    on error undo, return error
    :
        for each buf_dress_fbr-line no-lock
           where buf_dress_fbr-line.doc-code    = p-fbr-doc-doc-code
             and buf_dress_fbr-line.trn-type    = 'при':U
             and buf_dress_fbr-line.artic       = buf_in_fbr-line.artic
             and buf_dress_fbr-line.prod-type   = buf_in_fbr-line.prod-type
             and buf_dress_fbr-line.prod-code   = buf_in_fbr-line.prod-code
        on error undo, return error
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_dress_fbr-line.recipe-code
            .
            if buf_in_fbr-line.is-comp = yes
            then do:
                find last temp_recipe-childs-qnty
                    where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                .
                assign
                    temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                .
                create temp_recipe-childs.
                assign
                    temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                    temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                    temp_recipe-childs.child-recipe-code    = buf_dress_fbr-line.recipe-code
                .
            end.
            else do:
            end.
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'при':U
    on error undo, return error
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_in_fbr-line.recipe-code
        no-error.
        if buf_in_fbr-line.is-comp = no
        then do:
        end.
        else do:
            for each buf_recipe-gds no-lock
            where buf_recipe-gds.recipe-code = buf_in_fbr-line.recipe-code
            :
                for each buf_fbr-line no-lock
                where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                    and buf_fbr-line.trn-type    = 'при':U
                    and buf_fbr-line.artic       = buf_recipe-gds.artic
                    and buf_fbr-line.prod-type   = buf_recipe-gds.prod-type
                    and buf_fbr-line.prod-code   = buf_recipe-gds.prod-code
                on error undo, return error
                :
                    find first buf_recipe no-lock
                         where buf_recipe.recipe-code = buf_fbr-line.recipe-code
                    .
                    if buf_recipe.recipe-type = 'разделка':U
                    then do:
                    end.
                    else do:
                        find last temp_recipe-childs-qnty
                            where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                        .
                        assign
                            temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                        .
                        create temp_recipe-childs.
                        assign
                            temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                            temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                            temp_recipe-childs.child-recipe-code    = buf_fbr-line.recipe-code
                        .
                    end.
                end.
            end.
        end.
    end.
    for each temp_recipe-order
    on error undo, return error
    :
        delete temp_recipe-order.
    end.
    assign
        v-fbrlib-recipe-order = 0
    .
    do v-recipe-counter = 1 to v-recipe-amount
    on error undo, return error
    :
        run fbrlib-add-recipe-in-tmp-order in this-procedure (
              input v-recipe-counter
            , input 0
            , output v-is-call-cycle
        ).
        if v-is-call-cycle = yes
        then do:
            message
                    "Достигнут максимальный уровень вложенности рецептов."
                skip(1)
                skip "Невозможно упорядочить рецепты."
                skip(1)
                skip "Необходимо изменить структуру рецептов,"
                skip "используемых при формировании"
                skip "данного документа производства."
            view-as alert-box error
            title "Невозможно рассчитать документ производства".
            for each temp_recipe-childs-qnty
            :
                delete temp_recipe-childs-qnty.
            end.
            for each temp_recipe-childs
            :
                delete temp_recipe-childs.
            end.
            for each temp_recipe-order
            :
                delete temp_recipe-order.
            end.
            for each temp_recipe-order
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            for each temp_fbrlib_recipe
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            undo, return error.
        end.
    end.
end.
end procedure.
procedure fbrlib-add-recipe-in-tmp-order :
do
on error undo, return error
:
define input parameter p-order              as integer      no-undo.
define input parameter p-call-counter       as integer      no-undo.
define output parameter p-is-call-cycle     as logical      no-undo.
    define variable v-nodes-counter     as integer       no-undo.
    define buffer buf_c_temp_recipe-childs-qnty for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs-qnty   for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs        for temp_recipe-childs     .
    define buffer buf_temp_recipe-order         for temp_recipe-order.
    assign
        p-call-counter = p-call-counter + 1
    .
    if p-call-counter > 50
    then do:
        assign
            p-is-call-cycle = yes
        .
    end.
    else do:
        find first buf_temp_recipe-childs-qnty
             where buf_temp_recipe-childs-qnty.order = p-order
        .
        find first buf_temp_recipe-order
             where buf_temp_recipe-order.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
        no-error.
        if not available buf_temp_recipe-order
        then do:
            do v-nodes-counter = 1 to buf_temp_recipe-childs-qnty.childs-qnty
            :
                find first buf_temp_recipe-childs
                     where buf_temp_recipe-childs.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
                       and buf_temp_recipe-childs.child-code  = v-nodes-counter
                .
                find first buf_c_temp_recipe-childs-qnty
                     where buf_c_temp_recipe-childs-qnty.recipe-code = buf_temp_recipe-childs.child-recipe-code
                .
                run fbrlib-add-recipe-in-tmp-order in this-procedure (
                      input buf_c_temp_recipe-childs-qnty.order
                    , input p-call-counter
                    , output p-is-call-cycle
                ).
                if p-is-call-cycle = yes
                then do:
                    return.
                end.
            end.
            assign
                v-fbrlib-recipe-order = v-fbrlib-recipe-order + 1
            .
            create buf_temp_recipe-order.
            assign
                buf_temp_recipe-order.recipe-code   = buf_temp_recipe-childs-qnty.recipe-code
                buf_temp_recipe-order.order         = v-fbrlib-recipe-order
            .
        end.
    end.
end.
end procedure.
procedure fbrlib-get-trn-type :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-goods-recid    as recid        no-undo.
define input parameter p-is-integration as logical      no-undo.
define output parameter p-is-comp       as logical      no-undo.
define output parameter p-trn-type      as character    no-undo.
define buffer buf_recipe    for ub.recipe.
define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if not available buf_recipe
    then do:
        assign
            p-is-comp = no
            p-trn-type = "":U
        .
        undo, return.
    end.
    if  buf_recipe.artic        = buf_goods.artic
    and buf_recipe.prod-type    = buf_goods.prod-type
    and buf_recipe.prod-code    = buf_goods.prod-code
    then do:
        assign
            p-is-comp = yes
        .
    end.
    else do:
        assign
            p-is-comp = no
        .
    end.
    case buf_recipe.recipe-type
    :
        when 'производство':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'альтернатива':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'разделка':U
        then do:
            if p-is-comp = no
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'комплектация':U
        then do:
            if p-is-integration = ?
            then do:
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update p-is-integration.
            end.
            if p-is-integration = yes
            then do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            else do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
            end.
        end.
    end case.
end.
end procedure.
procedure fbrlib-get-mark :
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-mark          as logical    no-undo.
define buffer buf_goods-attr     for ub.goods-attr.
define buffer buf_recipe-gds for ub.recipe-gds .
    for each buf_recipe-gds no-lock where buf_recipe-gds.recipe-code = p-recipe-code,
         first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_recipe-gds.gds-code and
                                            buf_goods-attr.attr-code = 'mark-type':U:
         if buf_goods-attr.attr-value <> "" and buf_goods-attr.attr-value <> "not-type" then do:
            p-mark = true .
            return .
         end.
    end.
end procedure.
procedure fbrlib-check-temp-tables :
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.
    define variable v-str               as character        no-undo.
    assign
        v-str = v-str + chr(10) + "temp_recipe-childs-qnty:" + chr(10)
    .
    for each temp_recipe-childs-qnty
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs-qnty.recipe-code )
                    + "   " + string( temp_recipe-childs-qnty.childs-qnty )
                    + "   " + string( temp_recipe-childs-qnty.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + "temp_recipe-childs:" + chr(10)
    .
    for each temp_recipe-childs
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs.recipe-code )
                    + "   " + string( temp_recipe-childs.child-code )
                    + "   " + string( temp_recipe-childs.child-recipe-code )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_recipe-order:" + chr(10)
    .
    for each temp_recipe-order
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-order.recipe-code )
                    + "   " + string( temp_recipe-order.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_fbrlib_recipe:" + chr(10)
    .
    run writelog in this-procedure ( input "fbr.log", input 0, input p-title ).
    run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    for each temp_fbrlib_recipe
    on error undo, return error
    :
        assign
            v-str   = "recipe-code: "                   + string( temp_fbrlib_recipe.recipe-code                 )
                    + "   " + "count-income: "                  + string( temp_fbrlib_recipe.count-income                )
                    + "   " + "qnty-income: "                   + string( temp_fbrlib_recipe.qnty-income                 )
                    + "   " + "sum-income-sale: "               + string( temp_fbrlib_recipe.sum-income-sale             )
                    + "   " + "sum-income-cost-base: "          + string( temp_fbrlib_recipe.sum-income-cost-base        )
                    + "   " + "sum-income-cost-rubl: "          + string( temp_fbrlib_recipe.sum-income-cost-rubl        )
                    + "   " + "sum-income-vat-cost-base: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-base    )
                    + "   " + "sum-income-vat-cost-rubl: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-rubl    )
                    + "   " + "count-write-off: "               + string( temp_fbrlib_recipe.count-write-off             )
                    + "   " + "qnty-write-off: "                + string( temp_fbrlib_recipe.qnty-write-off              )
                    + "   " + "sum-write-off-sale: "            + string( temp_fbrlib_recipe.sum-write-off-sale          )
                    + "   " + "sum-write-off-cost-base: "       + string( temp_fbrlib_recipe.sum-write-off-cost-base     )
                    + "   " + "sum-write-off-cost-rubl: "       + string( temp_fbrlib_recipe.sum-write-off-cost-rubl     )
                    + "   " + "sum-write-off-vat-cost-base: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-base )
                    + "   " + "sum-write-off-vat-cost-rubl: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-rubl )
                    + chr(10)
        .
        run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    end.
end.
end procedure.
procedure fbrlib-s-coeff-value :
define input  parameter p-gds-code    as integer        no-undo.
define input  parameter p-date        as date           no-undo.
define input  parameter p-obj-type    as character      no-undo.
define input  parameter p-obj-code    as integer        no-undo.
define output parameter p-coeff-value as decimal        no-undo.
define variable vss-description as character init "fbrlib-s-coeff-value-01: определяет значение сезонного коэффициента" no-undo.
    define variable v-date          as date         no-undo.
    define variable v-host-code     as integer      no-undo.
    define buffer buf_goods       for ub.goods.
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
    define buffer buf_clients     for ub.clients.
    define buffer buf_s-coeff     for ub.s-coeff.
do
for buf_goods
  , buf_fbr-gds-obj
  , buf_clients
  , buf_s-coeff
on error undo, return error return-value
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    no-error .
    if not available buf_goods
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден товар с кодом &1", p-gds-code).
    end.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден объект &1&2", p-obj-type, p-obj-code).
    end.
    assign
        v-date = date(month(p-date), day(p-date), Year(01/01/1996))
    .
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.gds-code = p-gds-code
           and buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
    no-error.
    if not available buf_fbr-gds-obj
    or buf_fbr-gds-obj.is-season = no
    then do:
        assign
            p-coeff-value = 0
        .
        return.
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = p-obj-type
          and buf_s-coeff.obj-code = p-obj-code
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = 0
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
    end.
    else do:
        assign
            p-coeff-value = 0
        .
    end.
end.
end procedure.
procedure fbrlib_create-fbr-recipe-gds :
define input parameter p-doc-code         as character      no-undo.
define input parameter p-recipe-code      as character      no-undo.
define input parameter p-prod-type        as character      no-undo.
define input parameter p-prod-code        as integer        no-undo.
define input parameter p-artic            as character      no-undo.
define input parameter p-gds-code         as integer        no-undo.
define input parameter p-is-waste         as logical        no-undo.
define input parameter p-proc-number      as integer        no-undo.
define input parameter p-obj-date         as date           no-undo.
define input parameter p-obj-type         as character      no-undo.
define input parameter p-obj-code         as integer        no-undo.
define input parameter p-calc-method      as decimal        no-undo.
define input parameter p-coeff-waste      as decimal        no-undo.
define input parameter p-orig-qnty        as decimal        no-undo.
define input parameter p-orig-brutto-qnty as decimal        no-undo.
    define variable v-coeff-season  as decimal      no-undo.
    define variable v-void-decimal  as decimal      no-undo.
    define variable v-void-integer  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe            for ub.recipe.
do
for buf_fbr-recipe-gds
  , buf_recipe
  , buf_goods
on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    find first buf_fbr-recipe-gds exclusive-lock
         where buf_fbr-recipe-gds.doc-code    = p-doc-code
           and buf_fbr-recipe-gds.recipe-code = p-recipe-code
           and buf_fbr-recipe-gds.prod-type   = p-prod-type
           and buf_fbr-recipe-gds.prod-code   = p-prod-code
           and buf_fbr-recipe-gds.artic       = p-artic
    no-error.
    if not available buf_fbr-recipe-gds
    then do:
        create buf_fbr-recipe-gds.
        assign
            buf_fbr-recipe-gds.doc-code           = p-doc-code
            buf_fbr-recipe-gds.recipe-code        = p-recipe-code
            buf_fbr-recipe-gds.prod-type          = p-prod-type
            buf_fbr-recipe-gds.prod-code          = p-prod-code
            buf_fbr-recipe-gds.artic              = p-artic
            buf_fbr-recipe-gds.gds-code           = p-gds-code
            buf_fbr-recipe-gds.is-waste           = p-is-waste
            buf_fbr-recipe-gds.proc-number        = p-proc-number
            buf_fbr-recipe-gds.recipe-qnty        = p-orig-qnty
            buf_fbr-recipe-gds.recipe-brutto-qnty = p-orig-brutto-qnty
        .
        find first buf_goods no-lock
             where buf_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_goods.prod-code = buf_fbr-recipe-gds.prod-code
               and buf_goods.artic     = buf_fbr-recipe-gds.artic
        .
        run fbrlib-s-coeff-value in this-procedure (
              input buf_goods.gds-code
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , output v-coeff-season
        ) no-error.
        if error-status:error
        then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
        assign
            buf_fbr-recipe-gds.qnty         = p-orig-qnty
            buf_fbr-recipe-gds.coeff-value  = v-coeff-season
            buf_fbr-recipe-gds.coeff-waste  = p-coeff-waste
        .
        run fbrlib-get-recipe-type in this-procedure (
              input buf_fbr-recipe-gds.doc-code
            , input buf_fbr-recipe-gds.recipe-code
            , output v-recipe-type
        ).
        if v-recipe-type <> 'производство':U
        then do:
            assign
                buf_fbr-recipe-gds.coeff-value  = 0
                buf_fbr-recipe-gds.coeff-waste  = 0
                buf_fbr-recipe-gds.calc-method  = 1
                buf_fbr-recipe-gds.brutto-qnty  = buf_fbr-recipe-gds.qnty
            .
        end.
        else do:
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input 0
                , input 3
                , output v-void-decimal
                , output v-void-decimal
                , output buf_fbr-recipe-gds.brutto-qnty
                , output v-void-integer
            ).
            assign
                buf_fbr-recipe-gds.calc-method  = p-calc-method
            .
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input buf_fbr-recipe-gds.brutto-qnty
                , input buf_fbr-recipe-gds.calc-method
                , output buf_fbr-recipe-gds.qnty
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-integer
            ).
        end.
    end.
end.
end procedure.
procedure fbrlib-set-default-recipe :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.
    define variable v-artic             as character    no-undo.
    define variable v-prod-type         as character    no-undo.
    define variable v-prod-code         as character    no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-recipe-found      as logical      no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_other_recipe  for ub.recipe.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_recipe
  , buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-recipe-code
    ).
    if v-recipe-code <> ""
    then do:
        find first buf_recipe no-lock
            where buf_recipe.recipe-code = v-recipe-code
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-code = ""
            .
        end.
    end.
    if v-recipe-code = ""
    then do:
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-obj-type
               and buf_fbr-gds-obj.obj-code = p-obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            run ref/fgdsobj1.p (
                  input-output v-fbr-gds-obj-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input p-gds-code
                , input p-obj-type
                , input p-obj-code
                , input 0
                , input ""
                , input 0
                , input no
                , input no
                , input no
                , input no
                , input no
                , input no
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_fbr-gds-obj exclusive-lock
                 where recid( buf_fbr-gds-obj ) = v-fbr-gds-obj-recid
            .
        end.
        assign
            v-recipe-found = no
        .
        for first buf_recipe no-lock
            where buf_recipe.obj-type    = p-obj-type
              and buf_recipe.obj-code    = p-obj-code
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
              or (
                  buf_recipe.obj-type    = ""
              and buf_recipe.obj-code    = 0
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
                  )
        :
            assign
                v-recipe-found = yes
                buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
            .
        end.
        if v-recipe-found = no
        then do:
            for first buf_recipe no-lock
                where buf_recipe.obj-type    = p-obj-type
                  and buf_recipe.obj-code    = p-obj-code
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                  or (
                      buf_recipe.obj-type    = ""
                  and buf_recipe.obj-code    = 0
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                      )
            :
                assign
                    v-recipe-found = yes
                    buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                .
            end.
            if v-recipe-found = no
            then do:
                for first buf_recipe no-lock
                    where buf_recipe.obj-type    = p-obj-type
                      and buf_recipe.obj-code    = p-obj-code
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                      or (
                          buf_recipe.obj-type    = ""
                      and buf_recipe.obj-code    = 0
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                          )
                :
                    assign
                        v-recipe-found = yes
                        buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                    .
                end.
                if v-recipe-found = no
                then do:
                    assign
                        buf_fbr-gds-obj.default-recipe-code = ""
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-obj-recipe :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-recipe-code   as character    no-undo.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_fbr-gds-obj
on error undo, return error
:
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    no-error.
    if available buf_fbr-gds-obj
    then do:
        assign
            p-recipe-code = buf_fbr-gds-obj.default-recipe-code
        .
    end.
    else do:
        assign
            p-recipe-code = ""
        .
    end.
end.
end procedure.
procedure fbrlib-create-or-update-recipe-gds :
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-is-waste       as logical          no-undo.
define input parameter p-qnty           as decimal          no-undo.
define input parameter p-proc-number    as integer          no-undo.
define input parameter p-nws-self       as logical          no-undo.
    define variable v-max-proc-num  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_proc_recipe-gds   for ub.recipe-gds.
do
for buf_goods
  , buf_recipe-gds
  , buf_recipe
  , buf_proc_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_recipe-gds
         where buf_recipe-gds.recipe-code = p-recipe-code
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
           and buf_recipe-gds.artic       = buf_goods.artic
    no-error.
    if not available buf_recipe-gds
    then do:
        create buf_recipe-gds.
        assign
            buf_recipe-gds.recipe-code = p-recipe-code
            buf_recipe-gds.gds-code    = p-gds-code
            buf_recipe-gds.prod-type   = buf_goods.prod-type
            buf_recipe-gds.prod-code   = buf_goods.prod-code
            buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
            buf_recipe-gds.is-waste    = no
            buf_recipe-gds.qnty        = 0
            buf_recipe-gds.coeff-waste = 0
            buf_recipe-gds.brutto-qnty = 0
            buf_recipe-gds.proc-number = 0
            buf_recipe-gds.nws-self    = no
        .
    end.
    assign
        buf_recipe-gds.is-waste    = p-is-waste
    .
    run fbrlib-get-recipe-type in this-procedure (
          input "":U
        , input buf_recipe-gds.recipe-code
        , output v-recipe-type
    ).
    if v-recipe-type <> 'производство':U
    then do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.qnty        = p-qnty
            buf_recipe-gds.brutto-qnty = p-qnty
            buf_recipe-gds.coeff-waste = 0
        .
    end.
    else do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.brutto-qnty = p-qnty
        .
        run fbrlib-calc-brutto in this-procedure (
              input v-recipe-type
            , input 0
            , input 0
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.brutto-qnty
            , input 1
            , output buf_recipe-gds.qnty
            , output buf_recipe-gds.coeff-waste
            , output buf_recipe-gds.brutto-qnty
            , output buf_recipe-gds.calc-method
        ).
    end.
    assign
        buf_recipe-gds.nws-self    = p-nws-self
    .
    if buf_recipe.recipe-type = 'альтернатива':U
    and buf_recipe-gds.proc-number <> 0
    then do:
    end.
    else do:
        if p-proc-number <> 0
        then do:
            assign
                buf_recipe-gds.proc-number = p-proc-number
            .
        end.
        else do:
            assign
                v-max-proc-num = 0
            .
            for each buf_proc_recipe-gds no-lock
               where buf_proc_recipe-gds.recipe-code = p-recipe-code
            :
                if recid( buf_proc_recipe-gds ) <> recid( buf_recipe-gds )
                then do:
                    assign
                        v-max-proc-num = ( if v-max-proc-num < buf_proc_recipe-gds.proc-number then buf_proc_recipe-gds.proc-number else v-max-proc-num )
                    .
                end.
            end.
            assign
                buf_recipe-gds.proc-number = v-max-proc-num + 1
            .
        end.
    end.
end.
end procedure.
PROCEDURE fbrlib-create-or-update-recipe :
define input parameter p-mode               as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-design             as character    no-undo.
define input parameter p-order              as integer      no-undo.
define input parameter p-quality            as character    no-undo.
define input parameter p-ref-num            as character    no-undo.
define input parameter p-technique          as character    no-undo.
define input parameter p-template           as character    no-undo.
define input parameter p-qnty               as decimal      no-undo.
define input parameter p-portion-qnty       as integer      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define output parameter p-new-recipe-code   as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define buffer buf_recipe    for ub.recipe.
    define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    if p-mode <> 'ДОБАВЛЕНИЕ':U
    and p-mode <> 'ИЗМЕНЕНИЕ':U
    then do:
        message
            skip "Ошибка задания типа операции для создания или измения рецепта."
            skip (1)
            skip "Задан тип операции:" p-mode
        view-as alert-box error.
        undo, return error .
    end.
    if p-recipe-code = ""
    then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
        create buf_recipe .
        run fbrcode-gen-recipe-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output buf_recipe.recipe-code
        ).
        assign
            buf_recipe.artic               = buf_goods.artic
            buf_recipe.prod-type           = buf_goods.prod-type
            buf_recipe.prod-code           = buf_goods.prod-code
            buf_recipe.recipe-type         = p-recipe-type
            buf_recipe.recipe-name         = ( if p-name = "" then buf_goods.gds-name else p-name )
            buf_recipe.gds-code            = p-gds-code
            buf_recipe.host-code           = v-host-code
            buf_recipe.obj-type            = p-obj-type
            buf_recipe.obj-code            = p-obj-code
            buf_recipe.recipe-design       = ""
            buf_recipe.recipe-order        = 0
            buf_recipe.recipe-quality      = ""
            buf_recipe.recipe-ref-num      = ""
            buf_recipe.recipe-technique    = ""
            buf_recipe.recipe-template     = ""
            buf_recipe.qnty                = 1.0
            buf_recipe.portion-qnty        = 1
            buf_recipe.portion-weight      = 0
        .
    end.
    if p-name <> ""
    then do:
        assign
            buf_recipe.recipe-name = p-name
        .
    end.
    assign
        buf_recipe.recipe-design       = p-design
        buf_recipe.recipe-order        = p-order
        buf_recipe.recipe-quality      = p-quality
        buf_recipe.recipe-ref-num      = p-ref-num
        buf_recipe.recipe-technique    = p-technique
        buf_recipe.recipe-template     = p-template
        buf_recipe.qnty                = p-qnty
        buf_recipe.portion-qnty        = p-portion-qnty
        buf_recipe.portion-weight      = p-portion-weight
    .
    assign
        p-new-recipe-code = buf_recipe.recipe-code
    .
    run fbrlib-set-default-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.gds-code
    ).
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-fbr-doc :
define input parameter parparentproc-handle as widget-handle no-undo .
define input parameter p-doc-code   as character no-undo.
define input parameter p-chip-num   like ub.c-trn-doc.chip-num no-undo .
    define variable v-shift-on      as logical      no-undo.
    define variable v-shift-date    as date         no-undo.
    define variable v-shift-num     as integer      no-undo.
    define variable v-shift-name    as character    no-undo.
    define variable v-obj-date      as date         no-undo.
    define variable v-chip-num      as integer      no-undo.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_c-fbr-doc     for ub.c-fbr-doc.
    define buffer buf_fbr-recipe     for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_c-fbr-doc
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_marking
  , buf_marking-lines
on error undo, return error
:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    if search ("delfbr.err") <> ?
    then do:
        os-delete "delfbr.err".
    end.
  _del-block:
    do transaction
  on error undo _del-block, return error return-value
  on endkey undo _del-block , return error return-value
  on stop undo _del-block , return error return-value
    :
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = p-doc-code
        no-error.
        if not available buf_fbr-doc
        then do:
      undo _del-block, return error substitute("&1 &2 &3&4Не найден документ производства &5 для удаления."
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        , p-doc-code).
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'при':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        assign
        p-chip-num = (if p-chip-num = ?
                      then v-chip-num
                      else p-chip-num).
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'рас':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'спи':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        create buf_c-fbr-doc.
        buffer-copy buf_fbr-doc to buf_c-fbr-doc.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-obj-date
  ) no-error .
        if error-status :error
        or v-obj-date = ?
        then do:
      undo _del-block, return error "Нет текущей даты на объекте документа.".
        end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  )  .
        if v-shift-on
        then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
            if error-status :error
            then do:
        undo _del-block, return error "Ошибка при поиске текущей смены на объекте".
            end.
        end.
        else do:
            assign
                v-shift-date = ?
                v-shift-num  = ?
                v-shift-name = ?
            .
        end.
        define variable v-today       as date         no-undo.
        define variable v-time        as integer      no-undo.
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        assign
            buf_c-fbr-doc.chip-num         = (if p-chip-num <> ? then p-chip-num else next-value( s-corr-chip, ub  ))
            buf_c-fbr-doc.corr-user-name   = v-cntxt-userid
            buf_c-fbr-doc.corr-user-db-num = v-cntxt-db-num
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-shift-date  = v-shift-date
            buf_c-fbr-doc.corr-shift-num   = v-shift-num
            buf_c-fbr-doc.corr-shift-name  = v-shift-name
            buf_c-fbr-doc.is-del           = yes
        .
        assign
            buf_fbr-doc.is-del = yes
        .
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            for first buf_goods no-lock where buf_goods.artic      = buf_fbr-line.artic
                                          and buf_goods.prod-type  = buf_fbr-line.prod-type
                                          and buf_goods.prod-code  = buf_fbr-line.prod-code,
            each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                    and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                                    and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                                    and buf_marking-lines.in-code  = "manufacturing"
                                                    and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                                    and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                                    and buf_marking-lines.prt-code = 0
            :
              for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                assign
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_fbr-line.is-comp
                .
              end .
              delete buf_marking-lines.
            end .
            delete buf_fbr-line.
        end.
        for each buf_fbr-recipe exclusive-lock
           where buf_fbr-recipe.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe.
        end.
        for each buf_fbr-recipe-gds exclusive-lock
           where buf_fbr-recipe-gds.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe-gds.
        end.
        delete buf_fbr-doc.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-del-trn-doc :
do
on error undo, return error
:
define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-trn-doc-type       as character    no-undo.
define input parameter p-phchip-num         like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num           like ub.c-trn-doc.chip-num no-undo .
    define variable v-trn-doc-doc-code  as character     no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-doc-code
        , input p-trn-doc-type
        , output v-trn-doc-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-trn-doc-doc-code
    no-error.
    if available buf_trn-doc
    then do:
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "del-doc.err"
            , input ?
            , input p-fbr-doc-doc-code
            , input v-cntxt-userid
            , input 0
            , input p-phchip-num
            , output p-chip-num
        ) no-error.
        if error-status :error
        then do:
          undo, return error substitute("Не удалось удалить складской документ &1, созданный по документу производства &2.&3&4&3&5"
                                        ,v-trn-doc-doc-code
                                        ,p-fbr-doc-doc-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-trn-doc :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-doc-type       as character    no-undo.
define input parameter p-ph-chip-num       like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num      like ub.c-trn-doc.chip-num no-undo .
    define variable v-doc-code          as character        no-undo.
    define variable v-ext-doc-type      as character        no-undo.
    define variable v-trn-doc-recid     as recid            no-undo.
    define variable varchip-code        as integer          no-undo.
    define variable varchip-code2       as integer          no-undo.
    define variable v-chip-counter      as integer          no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_pri_trn-doc   for ub.trn-doc.
    define buffer buf_cons_trn-doc  for ub.trn-doc.
do
for buf_trn-doc
  , buf_pri_trn-doc
  , buf_cons_trn-doc
on error undo, return error
:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-code
        , input p-doc-type
        , output v-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        if p-doc-type <> 'спи':U
        then do:
            message
                "Не найден документ '" p-doc-type "'"
                "по документу производства " p-fbr-doc-code
            view-as alert-box.
            undo, return error.
        end.
        else do:
        end.
    end.
    else do:
        assign
            v-trn-doc-recid = recid( buf_trn-doc )
            v-ext-doc-type  = buf_trn-doc.ext-doc-type
        .
        if v-ext-doc-type = 'ev':U
        then do:
            find first buf_pri_trn-doc no-lock
                 where buf_pri_trn-doc.out-code     = v-doc-code
                   and buf_pri_trn-doc.ext-doc-type = 'iv':U
            no-error.
            if available buf_pri_trn-doc
            then do:
                run str/del-doc.p (
                      input parparentproc
                    , input buf_pri_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                                ,buf_pri_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        define buffer buf_out_trn-doc       for ub.trn-doc.
        if p-doc-type = 'при':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_out_trn-doc exclusive-lock
               where buf_out_trn-doc.out-code = buf_trn-doc.doc-code
            on error undo, return error
            :
                assign
                    v-chip-counter = v-chip-counter + 1
                .
                if v-chip-counter > 1
                then do:
                    assign
                        varchip-code = varchip-code2
                    .
                end.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_out_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, связанного со складским документов прихода &2, созданный по документу производства &3.&4&5&4&6"
                                                ,buf_out_trn-doc.doc-code
                                                ,buf_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "delfbr.err"
            , input ?
            , input p-fbr-doc-code
            , input v-cntxt-userid
            , input 0
            , input (if p-ph-chip-num <> ?
                     then p-ph-chip-num
                     else (if varchip-code <> 0
                           then varchip-code
                           else ?)
                     )
            , output varchip-code2
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                          ,buf_trn-doc.doc-code
                                          ,p-fbr-doc-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value ).
        end.
        if p-doc-type = 'рас':U
        or p-doc-type = 'спи':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_cons_trn-doc no-lock
               where buf_cons_trn-doc.out-code      = v-doc-code
                 and buf_cons_trn-doc.ext-doc-type  = 'pc':U
            :
                assign
                    v-trn-doc-recid = recid( buf_cons_trn-doc )
                    v-chip-counter = v-chip-counter + 1
                .
                assign
                varchip-code = if v-chip-counter = 2
                               then varchip-code2
                               else varchip-code.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_cons_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input ?
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                             then p-ph-chip-num
                             else ( if v-chip-counter = 1
                                    then ?
                                    else varchip-code )
                             )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute("Ошибка при удалении складского документа смены типа приобретения &1, созданный по документу производства &2.&3&4&3&5"
                                                  ,buf_cons_trn-doc.doc-code
                                                  ,p-fbr-doc-code
                                                  , chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
                end.
                assign
                    p-chip-num = varchip-code2
                .
            end.
        end.
        assign
            p-chip-num = varchip-code2
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-print-del-error-message :
do
on error undo, return error
:
    define variable v-user-action   as character    no-undo.
    define variable v-printed       as logical      no-undo.
    message
        vss-workfile vss-revision vss-description
        skip "Ошибка при удалении документа."
        skip return-value
        skip trim(error-status :get-message(1))
        skip trim(error-status :get-message(2))
        skip trim(error-status :get-message(3))
    view-as alert-box error.
    if search ("delfbr.err") <> ?
    then do:
      run gbl/prnfilen.w
        (input  "Ошибки при удалении документа производства"
        ,input  0
        ,input  "delfbr.err"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.
END PROCEDURE.
procedure fbrlib-calc-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-new-netto         as decimal          no-undo.
define output parameter p-new-coeff-waste   as decimal          no-undo.
define output parameter p-new-brutto        as decimal          no-undo.
define output parameter p-new-calc-method   as integer          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        assign
            p-new-coeff-waste = 0
            p-new-calc-method = 1
            p-new-netto       = ( if p-calc-method = 1 then p-brutto else p-netto )
            p-new-brutto      = ( if p-calc-method = 1 then p-brutto else p-netto )
        .
    end.
    else do:
        assign
            p-new-calc-method = p-calc-method
        .
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                assign
                    p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = p-brutto
                .
            end.
            when 2
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = 100 - p-coeff-value - ( 100 * p-netto / p-brutto )
                    p-new-brutto        = p-brutto
                .
            end.
            when 3
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste )
                .
            end.
            otherwise do:
                define variable v-yesno    as logical      no-undo.
                assign
                    v-yesno = yes
                .
                message
                    "Неверный метод для расчета брутто, нетто и процента потерь."
                    skip "Значение метода должно быть 1, 2 или 3."
                    skip(1)
                    skip "Заданное значение:" p-calc-method
                    skip(1)
                    skip "Установить значение метода расчета 1"
                    skip "(расчет нетто по брутто и проценту потерь)?"
                view-as alert-box warning
                buttons yes-no
                title "Неверное значение метода пересчета в строках документа-производства"
                update v-yesno
                .
                if v-yesno = yes
                then do:
                    assign
                        p-new-calc-method   = 1
                        p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                        p-new-coeff-waste   = p-coeff-waste
                        p-new-brutto        = p-brutto
                    .
                end.
                else do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка расчета брутто, нетто и процента потерь."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error
                    title "Неверное значение метода расчета"
                    .
                    undo, return error .
                end.
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-error-message     as character        no-undo.
define output parameter p-not-good          as logical          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        if p-netto <> p-brutto
        or p-coeff-waste <> 0
        then do:
            assign
                p-not-good      = yes
                p-error-message = substitute( "Во всех рецептах кроме рецепта производства должно выполняться:&1брутто = нетто и процент потерь = 0.&1&1Тип рецепта: &2&1Брутто: &3&1Нетто: &4&1Процент потерь: &5"
                                        , chr(10), p-recipe-type, p-brutto, p-netto, p-coeff-waste )
            .
        end.
    end.
    else do:
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                if round( p-netto, 9 ) <> round( p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100, 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета нетто ( &2 ) &1 по брутто ( &3 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            when 2
            then do:
                if round( p-coeff-waste, 9 ) <> round( 100 - p-coeff-value - ( 100 * p-netto / p-brutto ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message =  substitute( "Ошибка расчета процента потерь ( &2 ) &1 по нетто ( &3 ) &1 брутто ( &4 ) &1 и cезонному проценту ( &5 )."
                                                , chr(10), p-coeff-waste, p-netto, p-brutto, p-coeff-value )
                    .
                end.
            end.
            when 3
            then do:
                if round( p-brutto, 9 ) <> round( 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета брутто ( &3 ) &1 по нетто ( &2 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            otherwise do:
                assign
                    p-not-good      = yes
                    p-error-message = substitute( "Ошибка ввода метода расчета ( &1 ).", p-calc-method )
                .
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-fbr-recipe :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-is-correct    as logical          no-undo.
    define variable v-comp-factor    as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
on error undo, return error
:
    assign
        p-is-correct = yes
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code no-error
    .
    if not available buf_fbr-recipe then do:
      undo, return error substitute("Не найден рецепт (fbr-recipe) с кодом &1 для  документа пр-ва &2", p-recipe-code, p-doc-code).
    end.
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = buf_fbr-recipe.doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
               and buf_fbr-line.artic       = buf_fbr-recipe.artic
               and buf_fbr-line.prod-type   = buf_fbr-recipe.prod-type
               and buf_fbr-line.prod-code   = buf_fbr-recipe.prod-code
        .
        assign
            v-comp-factor = buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty
        .
        recipe-line-cycle:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if absolute( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty - v-comp-factor ) > 0.000000001
            then do:
                assign
                    p-is-correct = no
                .
                leave recipe-line-cycle.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-recipe-type :
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-recipe-type   as character        no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-recipe    for ub.fbr-recipe.
do
for buf_recipe
  , buf_fbr-recipe
on error undo, return error
:
    if p-fbr-doc-code = ""
    then do:
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-recipe-code
        no-error.
        if available buf_recipe
        then do:
            assign
                p-recipe-type = buf_recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
    else do:
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code      = p-fbr-doc-code
               and buf_fbr-recipe.recipe-code   = p-recipe-code
        no-error.
        if available buf_fbr-recipe
        then do:
            assign
                p-recipe-type = buf_fbr-recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
end.
end procedure.
PROCEDURE calc-comp-from-ingr :
define input parameter p-fbr-v-fbr-doc-line-recid           as recid        no-undo.
define input parameter p-fact-qnty                          as decimal      no-undo.
define output parameter p-comp-fbr-v-fbr-doc-line-recid     as recid        no-undo.
define output parameter p-comp-qnty                         as decimal      no-undo.
    define variable v-ingr-qnty     as decimal       no-undo.
    define buffer buf_i_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_recipe        for ub.fbr-recipe.
    define buffer buf_recipe-gds    for ub.fbr-recipe-gds.
do
for buf_i_fbr-line
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_i_fbr-line no-lock
         where recid( buf_i_fbr-line ) = p-fbr-v-fbr-doc-line-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code      = buf_i_fbr-line.doc-code
           and buf_recipe.recipe-code   = buf_i_fbr-line.recipe-code
    no-error.
    if not available buf_recipe
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "В строке производства не указан рецепт."
            skip "Невозможно рассчитать количество составного товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if buf_recipe.recipe-type = 'альтернатива':U
    then do:
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
             and buf_fbr-line.trn-type    = buf_i_fbr-line.trn-type
             and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
        on error undo, return error
        :
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
                   and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
                   and buf_recipe-gds.artic       = buf_fbr-line.artic
                   and buf_recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_recipe-gds.prod-code   = buf_fbr-line.prod-code
            .
            assign
                p-comp-qnty         = p-comp-qnty       + ( buf_fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty )
            .
        end.
        assign
            p-comp-qnty         = p-comp-qnty       / buf_recipe.qnty
        .
    end.
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
        .
        assign
            p-comp-qnty = p-fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
        .
    end.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
    .
    assign
        p-comp-fbr-v-fbr-doc-line-recid = recid( buf_fbr-line )
    .
end.
END PROCEDURE.
PROCEDURE get-temp_dressing-ingr-used-qnty :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-line-qnty     as decimal      no-undo.
define output parameter p-used-qnty     as decimal      no-undo.
define output parameter p-recipe-qnty   as decimal      no-undo.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
for buf_temp_dressing-ingr
on error undo, return error
:
    find first buf_temp_dressing-ingr no-lock
         where buf_temp_dressing-ingr.recipe-code = p-recipe-code
           and buf_temp_dressing-ingr.gds-code    = p-gds-code
    no-error.
    if available buf_temp_dressing-ingr
    then do:
        assign
            p-line-qnty     = buf_temp_dressing-ingr.line-qnty
            p-used-qnty     = buf_temp_dressing-ingr.used-qnty
            p-recipe-qnty   = buf_temp_dressing-ingr.recipe-qnty
        .
    end.
    else do:
        assign
            p-line-qnty     = 0
            p-used-qnty     = 0
            p-recipe-qnty   = 0
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-recipe :
do
on error undo, return error
:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
    define variable v-recipe-qnty       as decimal      no-undo.
    define variable v-comp-qnty         as decimal      no-undo.
    define variable v-recipe-gds-qnty   as decimal      no-undo.
    define variable v-ingr-qnty         as decimal      no-undo.
    define variable v-qnty              as decimal      no-undo.
    define variable v-coeff-waste       as decimal      no-undo.
    define variable v-brutto-qnty       as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_el_fbr-recipe-gds for ub.fbr-recipe-gds.
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code      = p-doc-code
           and buf_fbr-recipe.recipe-code   = p-recipe-code
    .
    assign
        v-recipe-qnty = buf_fbr-recipe.qnty
    .
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
    .
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = p-doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = p-recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if buf_fbr-line.fact-qnty / v-comp-qnty <> buf_fbr-recipe-gds.brutto-qnty / v-recipe-qnty
            then do:
                do transaction
                on error undo, return error
                :
                    find first buf_el_fbr-recipe-gds exclusive-lock
                         where recid( buf_el_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    assign
                        buf_el_fbr-recipe-gds.calc-method   = 1
                        buf_el_fbr-recipe-gds.brutto-qnty   = buf_fbr-line.fact-qnty * v-recipe-qnty / v-comp-qnty
                    .
                    run fbrlib-calc-brutto in this-procedure (
                          input buf_fbr-recipe.recipe-type
                        , input 0
                        , input buf_el_fbr-recipe-gds.coeff-value
                        , input buf_el_fbr-recipe-gds.coeff-waste
                        , input buf_el_fbr-recipe-gds.brutto-qnty
                        , input 1
                        , output buf_el_fbr-recipe-gds.qnty
                        , output buf_el_fbr-recipe-gds.coeff-waste
                        , output buf_el_fbr-recipe-gds.brutto-qnty
                        , output buf_el_fbr-recipe-gds.calc-method
                    ).
                end.
            end.
        end.
        run fbrlib_adjust-doc-lines in this-procedure (
              input parparentproc
            , input p-fbrhist-handle
            , input p-doc-code
            , input p-recipe-code
            , input p-price-sale-obj-type
            , input p-price-sale-obj-code
        ).
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-doc-lines :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
define variable v-comp-qnty         as decimal      no-undo.
define variable v-trn-type          as character    no-undo.
define variable v-ingr-qnty         as decimal      no-undo.
define variable v-recipe-qnty       as decimal      no-undo.
define variable v-fbr-v-fbr-doc-line-recid    as recid        no-undo.
define buffer buf_fbr-recipe        for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
define buffer buf_fbr-line          for ub.fbr-line.
define buffer buf_coeff_fbr-line    for ub.fbr-line.
define buffer buf_goods             for ub.goods.
define buffer buf_fbr-doc           for ub.fbr-doc.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
  , buf_coeff_fbr-line
  , buf_goods
  , buf_fbr-doc
on error undo, return error
:
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = p-doc-code
           and buf_fbr-line.is-comp       = yes
           and buf_fbr-line.recipe-code   = p-recipe-code
    .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code      = p-doc-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
        v-trn-type  = buf_fbr-line.trn-type
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
    v-recipe-qnty = buf_fbr-recipe.qnty
    .
    do transaction
    on error undo, return error
    :
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code      = p-doc-code
             and buf_fbr-recipe-gds.recipe-code   = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
            no-error.
            if not available buf_fbr-line
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_fbr-recipe-gds.artic
                       and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                       and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
                .
                run str/fbr-crln.p (
                      input parparentproc
                    , input recid( buf_fbr-doc )
                    , input recid( buf_goods )
                    , input buf_fbr-recipe-gds.recipe-code
                    , input v-trn-type
                    , input no
                    , input no
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-fbr-v-fbr-doc-line-recid
                ).
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                       and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                       and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                no-error.
                if not available buf_fbr-line
                then do:
                    undo, return error substitute("Не удалось создать строку документа производства &1 &2&3&4"
                                                   , p-doc-code
                                                   , buf_fbr-recipe-gds.artic
                                                   , buf_fbr-recipe-gds.prod-type
                                                   , buf_fbr-recipe-gds.prod-code).
                end.
            end.
            find first buf_coeff_fbr-line exclusive-lock
                 where recid( buf_coeff_fbr-line ) = recid( buf_fbr-line )
            .
            if buf_coeff_fbr-line.calc-method <> buf_fbr-recipe-gds.calc-method
            or buf_coeff_fbr-line.coeff-value <> buf_fbr-recipe-gds.coeff-value
            or buf_coeff_fbr-line.coeff-waste <> buf_fbr-recipe-gds.coeff-waste
            then do:
                assign
                    buf_coeff_fbr-line.calc-method = buf_fbr-recipe-gds.calc-method
                    buf_coeff_fbr-line.coeff-value = buf_fbr-recipe-gds.coeff-value
                    buf_coeff_fbr-line.coeff-waste = buf_fbr-recipe-gds.coeff-waste
                .
            end.
        end.
    end.
    define variable v-need-goods    as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    run str/fbr-qnty.p (
          input parparentproc
        , input p-fbrhist-handle
        , input recid( buf_fbr-doc )
        , input recid( buf_fbr-line )
        , input no
        , input "ingr"
        , input no
        , input p-price-sale-obj-type
        , input p-price-sale-obj-code
        , input no
        , input no
        , input no
        , output v-need-goods
        , output v-need-goods-list
        , output v-need-goods-qnty-list
    ).
end.
END PROCEDURE.
procedure fbrlib_check-before-close :
define input parameter p-doc-code as character no-undo .
define variable same-sale as decimal no-undo .
define variable is-waste as logical no-undo .
define variable fix-price as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_goods for ub.goods.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
do
on error undo, return error
:
  for each buf_fbr-line no-lock
      where buf_fbr-line.doc-code = p-doc-code
    , each buf_goods no-lock
      where buf_goods.artic     = buf_fbr-line.artic
        and buf_goods.prod-type = buf_fbr-line.prod-type
        and buf_goods.prod-code = buf_fbr-line.prod-code
  break by buf_fbr-line.prod-type
        by buf_fbr-line.prod-code
        by buf_fbr-line.artic
  :
    if first-of (buf_fbr-line.artic)
    then do:
      assign
      same-sale = buf_fbr-line.price-sale
      is-waste = (buf_fbr-line.rsrv-qnty = ?)
      fix-price = buf_fbr-line.is-calc
      .
    end.
    if same-sale <> buf_fbr-line.price-sale
    then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром должна быть указана одна и та же цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if fix-price <> buf_fbr-line.is-calc then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром цена должна быть фиксирована или нет."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if is-waste <> (buf_fbr-line.rsrv-qnty = ?)
    then do:
      undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа этот товар должен быть отходом либо не отходом."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if buf_fbr-line.rsrv-qnty <> ?
    and buf_goods.gds-type <> 'у':U
    and ( buf_fbr-line.price-sale <= 0 or buf_fbr-line.price-sale = ?  )
    and buf_fbr-line.fact-qnty <> 0
    then do:
      if buf_fbr-line.trn-type     = 'при':U  then for first buf_fbr-doc where buf_fbr-doc.doc-code =  p-doc-code no-lock:
        if  can-find(first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.gds-code = buf_goods.gds-code
            AND buf_fbr-gds-obj.obj-type = buf_fbr-doc.obj-type
            AND buf_fbr-gds-obj.obj-code = buf_fbr-doc.obj-code
            and buf_fbr-gds-obj.is-null-price  )  then .
                  else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
      end.
      else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
    end.
  end.
end.
end procedure.
procedure fbrrest-get-free-qnty :
do
on error undo, return error
:
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-gds-code       as integer              no-undo.
define input parameter p-autofbr        as logical              no-undo.
define output parameter p-avail-qnty    as decimal              no-undo.
    define variable v-req-qnty  like ub.fbr-line.fact-qnty no-undo.
    define variable v-free-qnty as decimal       no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_temp-parts    for temp-parts.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-avail-qnty = 0
    .
    run partslib-init-temp-parts in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.artic
        , input buf_goods.prod-type
        , input buf_goods.prod-code
    ).
    assign
        v-free-qnty = 0
    .
    for each buf_temp-parts
    on error undo, return error
    :
        if buf_temp-parts.qnty > 0
        then do:
            assign
                v-free-qnty = v-free-qnty + buf_temp-parts.free-qnty
            .
        end.
    end.
    assign
        p-avail-qnty = ( if v-free-qnty > 0 then v-free-qnty else 0 )
    .
end.
end procedure.
procedure fbrrest-get-catering-object :
do
on error undo, return error
:
define input parameter p-obj-code            as integer      no-undo.
define output parameter p-catering-obj-type  as character    no-undo.
define output parameter p-catering-obj-code  as integer      no-undo.
    define buffer buf_shop              for ub.shop.
    find first buf_shop no-lock
         where buf_shop.obj-code = p-obj-code
    .
    assign
        p-catering-obj-type = buf_shop.kitchen-store-type
        p-catering-obj-code = buf_shop.kitchen-store-code
    .
end.
end procedure.
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
    if v-value = "" or logical(v-value) = false then return false .
end.
FUNCTION check-ban-sales-via-cd-grp return logical ( input p-grp-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
    v-upper-code = p-grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
end.
define temp-table temp_goods-qnty no-undo
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field recipe-type   as character
    field recipe-code   as character
    field trn-type      as character
    field need-qnty     as decimal
    field calculated    as logical
    index pi is primary unique gds-code recipe-code
    index cl calculated
.
PROCEDURE create-initial-temp-goods :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-artic              as character    no-undo.
define input parameter p-prod-type          as character    no-undo.
define input parameter p-prod-code          as integer      no-undo.
define input parameter p-trn-type           as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-need-qnty          as decimal      no-undo.
define output parameter p-same-good             as logical      no-undo.
define output parameter p-same-good-old-qnty    as decimal      no-undo.
    define variable v-gds-code    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_obj_recipe            for ub.recipe.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    run clear-temp-tables in this-procedure.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
    create buf_temp_goods-qnty.
    assign
        buf_temp_goods-qnty.gds-code    = v-gds-code
        buf_temp_goods-qnty.artic       = p-artic
        buf_temp_goods-qnty.prod-type   = p-prod-type
        buf_temp_goods-qnty.prod-code   = p-prod-code
        buf_temp_goods-qnty.trn-type    = p-trn-type
        buf_temp_goods-qnty.recipe-type = p-recipe-type
        buf_temp_goods-qnty.recipe-code = p-recipe-code
        buf_temp_goods-qnty.need-qnty   = p-need-qnty
        buf_temp_goods-qnty.calculated  = no
    .
    assign
        p-same-good                 = no
        p-same-good-old-qnty        = 0
    .
    find first buf_fbr-doc where buf_fbr-doc.doc-code = p-fbr-doc-doc-code exclusive-lock.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_fbr-line.is-comp  = yes
    on error undo, return error
    :
        find first buf_temp_goods-qnty
             where buf_temp_goods-qnty.artic        = buf_fbr-line.artic
               and buf_temp_goods-qnty.prod-type    = buf_fbr-line.prod-type
               and buf_temp_goods-qnty.prod-code    = buf_fbr-line.prod-code
        no-error.
        if available buf_temp_goods-qnty
        then do:
            assign
                p-same-good                 = yes
                p-same-good-old-qnty        = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.calculated  = no
            .
        end.
        else do:
            define variable v-recipe-type   as character     no-undo.
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_fbr-line.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_recipe no-lock
                 where buf_recipe.doc-code      = p-fbr-doc-doc-code
                   and buf_recipe.recipe-code   = buf_fbr-line.recipe-code
            no-error.
            if available buf_recipe
            then do:
                assign
                    v-recipe-type = buf_recipe.recipe-type
                .
                if v-recipe-type = 'разделка':U
                or ( v-recipe-type = 'комплектация':U
                    and buf_fbr-line.trn-type = 'спи':U )
                then do:
                    run fill-temp-dressing-ingr in this-procedure (
                          input buf_fbr-line.doc-code
                        , input buf_recipe.recipe-code
                    ).
                end.
            end.
            else do:
                assign
                    v-recipe-type = ?
                .
            end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  )  .
            create buf_temp_goods-qnty.
            assign
                buf_temp_goods-qnty.gds-code    = v-gds-code
                buf_temp_goods-qnty.artic       = buf_fbr-line.artic
                buf_temp_goods-qnty.prod-type   = buf_fbr-line.prod-type
                buf_temp_goods-qnty.prod-code   = buf_fbr-line.prod-code
                buf_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
                buf_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.recipe-type = v-recipe-type
                buf_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_temp_goods-qnty.calculated  = yes
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE calc-not-calculated-goods :
do
on error undo, return error
:
define input parameter p-mainmenu-handle        as handle           no-undo.
define input parameter p-fbrhist-handle         as widget-handle    no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-same-good              as logical          no-undo.
define input parameter p-same-good-old-qnty     as decimal          no-undo.
define input parameter p-always-select-recipe   as logical          no-undo.
define input parameter p-add-childs             as logical          no-undo.
define input parameter p-price-sale-obj-type    as character        no-undo.
define input parameter p-price-sale-obj-code    as integer          no-undo.
define input parameter p-autofbr                as logical          no-undo.
define input parameter p-have-store             as logical          no-undo.
    define variable v-counter               as integer       no-undo.
    define variable v-recipe-type           as character     no-undo.
    define variable v-recipe-code           as character     no-undo.
    define variable v-recipe-found          as logical       no-undo.
    define variable v-gds-code              as integer       no-undo.
    define variable v-yesno                 as logical       no-undo.
    define variable v-fbr-line-recid        as recid         no-undo.
    define variable v-recipe-recid-list     as character     no-undo.
    define variable v-need-goods            as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    define variable v-have-rights           as logical       no-undo.
    define variable v-trn-type              as character     no-undo.
    define variable v-is-comp               as logical       no-undo.
    define variable v-host-code             as integer       no-undo.
    define variable v-is-manual-input       as logical       no-undo.
    define variable v-add-good              as logical       no-undo.
    define variable v-cancel                as logical       no-undo.
    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .
    define variable v-mark-qnty      as decimal no-undo init ? .
    define buffer buf_obj_recipe            for recipe.
    define buffer buf_obj_recipe-gds        for recipe-gds.
    define buffer buf_fbr-recipe            for fbr-recipe.
    define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
    define buffer buf_goods                 for goods.
    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_fbr-line              for fbr-line.
    define buffer buf_comp_fbr-line         for fbr-line.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_start_temp_goods-qnty for temp_goods-qnty.
    define buffer buf_del_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_marking-lines         for ub.marking-lines .
    define buffer buf_marking               for ub.marking .
   define variable v-ban-recipes as logical no-undo .
   define variable v-ban-altr    as logical no-undo .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    run test-temp-tables in this-procedure ( "Заполнена временная таблица по товарам документа." ).
    find first buf_start_temp_goods-qnty
         where buf_start_temp_goods-qnty.calculated = no
    no-error.
    calc-not-calculated-goods:
    do while available buf_start_temp_goods-qnty
    :
        run writelog in this-procedure ( log-file-name, 2, substitute( "Расчет товара с артикулом &1", buf_start_temp_goods-qnty.artic ) ).
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_start_temp_goods-qnty.gds-code
        .
        if buf_start_temp_goods-qnty.recipe-code = ?
        then do:
            assign
                v-is-manual-input = yes
            .
        end.
        else do:
            assign
                v-is-manual-input = no
            .
        end.
        if buf_start_temp_goods-qnty.recipe-code = ?
        or p-always-select-recipe = yes
        then do:
            assign
                v-yesno     = ?
                v-add-good  = no
            .
            do while v-yesno = ?
            and v-add-good = no
            :
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-add,b-sel"
                    , input 'все':U
                    , input recid( buf_goods )
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-recipe-recid-list
                ) no-error.
                if error-status :error
                or v-recipe-recid-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление всех товаров списка"
                        skip "Cancel - вернуться к выбору рецепта"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
      if v-ban-altr or v-ban-recipes then
      do:
         for each buf_obj_recipe no-lock where recid (buf_obj_recipe) = integer(v-recipe-recid-list):
            if buf_obj_recipe.recipe-type = 'производство':U and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  'mark-type':U
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     message "Рецепт производства " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " содержит маркированный товар."
                        view-as alert-box.
                     return .
                  end.
               end.
            end.
            if buf_obj_recipe.recipe-type = 'альтернатива':U and v-ban-altr then
            do:
               if not check-ban-sales-via-cd(buf_goods.gds-code) then
               do:
                  message "Рецепт альтернатива " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + chr(10) + "входит в группу, у которой не установлен атрибут: " + chr(10) + "Запрет передачи на кассу."
                     view-as alert-box.
                  return .
               end.
            end.
            if buf_obj_recipe.recipe-type = 'комплектация':U and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  'mark-type':U
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     run gds-attr-value in this-procedure  ( input  buf_obj_recipe.gds-code
                        , input  'mark-type':U
                        , output v-attr-value-rec
                        , output v-attr-type
                        ) no-error .
                     if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                     do:
                        message "Рецепт комплектации " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " должен быть маркированным"
                           view-as alert-box.
                        return .
                     end.
                     else leave.
                  end.
               end.
            end.
         end.
      end.
                    assign
                        v-add-good = yes
                    .
                end.
            end.
            if v-add-good = no
            then do:
                if v-yesno = yes
                then do:
                    for each tt-marking-lines where tt-marking-lines.gds-code = buf_start_temp_goods-qnty.gds-code
                    :
                      for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                        assign
                          buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                        .
                      end .
                      delete tt-marking-lines .
                    end .
                    delete buf_start_temp_goods-qnty.
                    find first buf_start_temp_goods-qnty
                            where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.
                else do:
                    undo, return error .
                end.
            end.
            find first buf_obj_recipe no-lock
                 where recid( buf_obj_recipe ) = integer( v-recipe-recid-list )
            no-error.
            if not available buf_obj_recipe
            then do:
                if p-always-select-recipe = yes
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = yes
                    .
                    find first buf_start_temp_goods-qnty
                         where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.
                else do:
                    message
                        "Неверно выбран рецепт для товара."
                    view-as alert-box information.
                    undo, return error .
                end.
            end.
            else do:
                run copy-recipe-in-doc in this-procedure (
                      input buf_fbr-doc.doc-code
                    , input buf_obj_recipe.recipe-code
                    , input buf_fbr-doc.doc-date
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                ).
                find first buf_fbr-recipe no-lock
                     where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                       and buf_fbr-recipe.recipe-code = buf_obj_recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.recipe-code = buf_fbr-recipe.recipe-code
                    buf_start_temp_goods-qnty.recipe-type = buf_fbr-recipe.recipe-type
                .
            end.
            run writelog in this-procedure ( log-file-name, 3, substitute( "В диалоге выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.
        else do:
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_start_temp_goods-qnty.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_fbr-recipe no-lock
                 where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                   and buf_fbr-recipe.recipe-code = buf_start_temp_goods-qnty.recipe-code
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.
        case buf_fbr-recipe.recipe-type
        :
          when 'производство':U
          then do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_manufacturing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'комплектация':U
          then do:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_gathering':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'разделка':U
          then do:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_dressing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'альтернатива':U
          then do:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_alternative':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'топливо':U
          then do:
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_petrolium-manufacturing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип рецепта производства" skip
              "Тип рецепта" buf_fbr-recipe.recipe-type skip
              "Документ производства" buf_fbr-recipe.doc-code skip
              "Код рецепта" buf_fbr-recipe.recipe-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if v-have-rights = no
        then do:
            message
                "Недостаточно прав для производства."
                skip(1) "Обратитесь к администратору."
                skip(1) return-value
            view-as alert-box information.
            run clear-temp-tables in this-procedure .
            undo, return error.
        end.
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
        no-error.
        if available buf_fbr-line
        then do:
            define buffer buf_change_fbr-line      for ub.fbr-line.
            run writelog in this-procedure ( log-file-name, 3, "В документе уже есть выбранный рецепт." ).
            if buf_start_temp_goods-qnty.need-qnty = ?
            and v-is-manual-input = yes
            then do:
                define variable v-old-fact-qnty  as decimal       no-undo.
                define variable v-old-price-sale as decimal       no-undo.
                assign
                    v-old-fact-qnty  = buf_fbr-line.fact-qnty
                    v-old-price-sale = buf_fbr-line.price-sale
                .
                run str/fbr-line.w (
                      input p-fbrhist-handle
                    , input buf_fbr-doc.status_
                    , input p-fbr-doc-doc-code
                    , input recid( buf_fbr-line )
                    , input ?
                    , output v-cancel
                ).
                if error-status :error
                or v-cancel = yes
                then do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    message
                             vss-workfile vss-revision vss-description
                        skip "Ошибка изменения строки."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                        skip buf_change_fbr-line.fact-qnty
                    view-as alert-box error.
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    run clear-temp-tables in this-procedure.
                    return.
                end.
                if buf_fbr-line.fact-qnty <= v-old-fact-qnty
                then do:
                    define variable v-gds-name    as character    no-undo.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  )  .
                    message
                             "Для производства товаров документа необходимо"
                        skip "большее количество товара, чем было добавлено."
                        skip "Количество товара в документе будет восстановлено."
                        skip(1)
                        skip "Товар: " buf_fbr-line.artic v-gds-name
                        skip "Количество в строке документа производства:" v-old-fact-qnty
                        skip "Новое количество:" buf_fbr-line.fact-qnty
                    view-as alert-box information
                    title "Изменение строки документа производства".
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    delete buf_start_temp_goods-qnty.
                end.
                else do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_start_temp_goods-qnty.need-qnty  = buf_fbr-line.fact-qnty
                        buf_start_temp_goods-qnty.calculated = no
                        buf_change_fbr-line.fact-qnty     = 0
                    .
                end.
                run test-temp-tables in this-procedure ( "Товар добавлять не надо - параметр fbr-frcp=yes, но введенное в диалоге количество меньше необходимого." ).
                find first buf_start_temp_goods-qnty
                     where buf_start_temp_goods-qnty.calculated = no
                no-error.
                next calc-not-calculated-goods.
            end.
            else do:
                find first buf_change_fbr-line exclusive-lock
                     where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                       and buf_change_fbr-line.is-comp     = yes
                       and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.need-qnty  = buf_start_temp_goods-qnty.need-qnty + buf_fbr-line.fact-qnty
                    buf_change_fbr-line.fact-qnty        = buf_start_temp_goods-qnty.need-qnty
                .
                if buf_start_temp_goods-qnty.recipe-code <> "":U
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = no
                    .
                end.
            end.
            run writelog in this-procedure ( log-file-name, 3, substitute( "Изменена рассчитанная строка документа. Новое количество &1", buf_fbr-line.fact-qnty ) ).
        end.
        run fbrlib-get-trn-type in this-procedure (
              input buf_fbr-recipe.recipe-code
            , input recid( buf_goods )
            , input ( if buf_start_temp_goods-qnty.trn-type = ?
                      then ?
                      else ( if buf_start_temp_goods-qnty.trn-type = 'при':U
                             then yes
                             else no ) )
            , output v-is-comp
            , output v-trn-type
        ).
        assign
            buf_start_temp_goods-qnty.trn-type = v-trn-type
        .
        run str/fbr-crln.p (
              input p-mainmenu-handle
            , input recid( buf_fbr-doc )
            , input recid( buf_goods )
            , input buf_fbr-recipe.recipe-code
            , input v-trn-type
            , input v-is-comp
            , input yes
            , input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , output v-fbr-line-recid
        ).
        if buf_start_temp_goods-qnty.need-qnty = ?
        then do:
            find first tt-marking-lines no-error .
            if available tt-marking-lines
            then do :
              assign v-mark-qnty = 0 .
              for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
              first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                        and buf_goods.prod-type = buf_fbr-line.prod-type
                                        and buf_goods.prod-code = buf_fbr-line.prod-code,
              each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
              :
                assign v-mark-qnty = v-mark-qnty + tt-marking-lines.box-qnty .
              end .
            end .
            run str/fbr-line.w (
                  input p-fbrhist-handle
                , input buf_fbr-doc.status_
                , input p-fbr-doc-doc-code
                , input v-fbr-line-recid
                , input v-mark-qnty
                , output v-cancel
            ) no-error.
            if error-status :error
            or v-cancel = yes
            then do:
                find first buf_fbr-line exclusive-lock
                     where recid( buf_fbr-line ) = v-fbr-line-recid
                .
                for first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                          and buf_goods.prod-type = buf_fbr-line.prod-type
                                          and buf_goods.prod-code = buf_fbr-line.prod-code,
                each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
                :
                  for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                    assign
                      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                    .
                  end .
                end .
                delete buf_fbr-line.
                run clear-temp-tables in this-procedure.
                return.
            end.
            for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
            first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                      and buf_goods.prod-type = buf_fbr-line.prod-type
                                      and buf_goods.prod-code = buf_fbr-line.prod-code,
            each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
            :
              create buf_marking-lines .
              assign
                buf_marking-lines.mark      = tt-marking-lines.mark
                buf_marking-lines.obj-type  = buf_fbr-doc.obj-type
                buf_marking-lines.obj-code  = buf_fbr-doc.obj-code
                buf_marking-lines.gds-code  = buf_goods.gds-code
                buf_marking-lines.in-code   = "manufacturing"
                buf_marking-lines.out-code  = buf_fbr-line.doc-code
                buf_marking-lines.part-code = buf_fbr-line.recipe-code
                buf_marking-lines.prt-code  = 0
                buf_marking-lines.doc-level = 1
              .
            end .
            find first buf_fbr-line exclusive-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            if p-same-good = yes
            then do:
                if p-autofbr = yes
                then do:
                    assign
                        v-yesno = yes
                    .
                end.
                else do:
                    message
                             "Товар уже есть в документе."
                        skip "Вы можете добавить введенное количество в строку документа,"
                        skip "изменить количество в документе на введенное"
                        skip "или отменить добавление товара, оставив рецепт без изменений"
                        skip(1)
                        skip "Артикул товара:        " buf_start_temp_goods-qnty.artic
                        skip "Количество в документе:" p-same-good-old-qnty
                        skip(1)
                        skip "Добавить в строку?"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Добавление товара"
                    update v-yesno.
                    if v-yesno = ?
                    then do:
                        assign
                            buf_start_temp_goods-qnty.need-qnty   = p-same-good-old-qnty
                            buf_start_temp_goods-qnty.calculated  = yes
                        .
                        run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Расчитанная строка документа оставлена без изменений. Количество &1", buf_start_temp_goods-qnty.need-qnty ) ).
                        run test-temp-tables in this-procedure ( "Добавили товар." ).
                        find first buf_start_temp_goods-qnty
                             where buf_start_temp_goods-qnty.calculated = no
                        no-error.
                        next calc-not-calculated-goods.
                    end.
                end.
                assign
                    buf_start_temp_goods-qnty.calculated  = no
                .
                if v-yesno = yes
                then do:
                    assign
                        buf_fbr-line.fact-qnty = buf_fbr-line.fact-qnty + p-same-good-old-qnty
                    .
                end.
                run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Количество в рассчитанной строке документа изменено на &1", buf_fbr-line.fact-qnty ) ).
            end.
            assign
                buf_start_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_start_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_start_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
            .
        end.
        run writelog in this-procedure ( log-file-name, 2, "Идем по ингредиентам товара." ).
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = buf_fbr-recipe.doc-code
             and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_fbr-recipe-gds.artic
                   and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                   and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
            .
            assign
                v-is-comp = no
                v-trn-type = ( if buf_start_temp_goods-qnty.trn-type = 'при':U then 'спи':U else 'при':U )
            .
            run str/fbr-crln.p (
                  input p-mainmenu-handle
                , input recid( buf_fbr-doc )
                , input recid( buf_goods )
                , input buf_fbr-recipe.recipe-code
                , input v-trn-type
                , input v-is-comp
                , input yes
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , output v-fbr-line-recid
            ).
            find first buf_fbr-line no-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Создана строка ингредиента с артикулом '&1'", buf_fbr-line.artic ) ).
        end.
        run writelog in this-procedure ( log-file-name, 2, substitute( "Упорядочивание рецептов. Идем по рецептам с последнего." ) ).
        run fbrlib-put-in-order-recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            for each buf_del_temp_goods-qnty
            :
                delete buf_del_temp_goods-qnty.
            end.
            undo, return error.
        end.
        find last temp_recipe-order.
        calc-all-recipes:
        do while available temp_recipe-order
        :
            run writelog in this-procedure ( log-file-name, 3, substitute( "Обработка рецепта номер: &1", temp_recipe-order.recipe-code ) ).
            find first buf_comp_fbr-line exclusive-lock
                 where buf_comp_fbr-line.doc-code    = p-fbr-doc-doc-code
                   and buf_comp_fbr-line.is-comp     = yes
                   and buf_comp_fbr-line.recipe-code = temp_recipe-order.recipe-code
            .
            find first buf_temp_goods-qnty
                 where buf_temp_goods-qnty.artic        = buf_comp_fbr-line.artic
                   and buf_temp_goods-qnty.prod-type    = buf_comp_fbr-line.prod-type
                   and buf_temp_goods-qnty.prod-code    = buf_comp_fbr-line.prod-code
                   and buf_temp_goods-qnty.recipe-code  = buf_comp_fbr-line.recipe-code
            no-error.
            if not available buf_temp_goods-qnty
            or buf_temp_goods-qnty.calculated = no
            then do:
                run writelog in this-procedure ( log-file-name, 4, "Товар рецепта не рассчитан. Рассчитываем." ).
                if available buf_temp_goods-qnty
                and buf_temp_goods-qnty.need-qnty <> buf_comp_fbr-line.fact-qnty
                then do:
                    assign
                        buf_comp_fbr-line.fact-qnty = buf_temp_goods-qnty.need-qnty
                    .
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Прописываем количество в строку составного товара: &1", buf_comp_fbr-line.fact-qnty  ) ).
                end.
                run str/fbr-qnty.p (
                      input p-mainmenu-handle
                    , input p-fbrhist-handle
                    , input recid( buf_fbr-doc )
                    , input recid( buf_comp_fbr-line )
                    , input no
                    , input "ingr"
                    , input no
                    , input p-price-sale-obj-type
                    , input p-price-sale-obj-code
                    , input yes
                    , input p-autofbr
                    , input p-have-store
                    , output v-need-goods
                    , output v-need-goods-list
                    , output v-need-goods-qnty-list
                ).
                if p-add-childs  = yes
                and v-need-goods = yes
                then do:
                    do v-counter = 1 to num-entries( v-need-goods-list ) / 2
                    :
                        run add-new-recipe in this-procedure (
                              input p-mainmenu-handle
                            , input buf_fbr-doc.doc-code
                            , input entry( 2 * v-counter, v-need-goods-list )
                            , input integer( entry( 2 * v-counter - 1 , v-need-goods-list ) )
                            , input decimal( entry( v-counter, v-need-goods-qnty-list ) )
                            , input p-autofbr
                            , input p-have-store
                        ).
                    end.
                    leave calc-all-recipes.
                end.
            end.
            find prev temp_recipe-order no-error.
        end.
        assign
            buf_start_temp_goods-qnty.calculated = yes
        .
        if buf_start_temp_goods-qnty.recipe-type = 'разделка':U
        or ( buf_start_temp_goods-qnty.recipe-type = 'комплектация':U
             and buf_start_temp_goods-qnty.trn-type = 'спи':U )
        then do:
            run fill-temp-dressing-ingr in this-procedure (
                  input buf_fbr-doc.doc-code
                , input buf_start_temp_goods-qnty.recipe-code
            ).
        end.
        run test-temp-tables in this-procedure ( "Добавили товар." ).
        find first buf_start_temp_goods-qnty
             where buf_start_temp_goods-qnty.calculated = no
        no-error.
    end.
end.
END PROCEDURE.
PROCEDURE clear-temp-tables :
do
on error undo, return error
:
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
    for each buf_temp_goods-qnty
    on error undo, return error
    :
        delete buf_temp_goods-qnty.
    end.
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        delete buf_temp_dressing-ingr.
    end.
end.
END PROCEDURE.
PROCEDURE copy-recipe-in-doc :
define input parameter p-doc-code       as character             no-undo.
define input parameter p-recipe-code    as character             no-undo.
define input parameter p-obj-date       as date                  no-undo.
define input parameter p-obj-type       like ub.clients.obj-type no-undo.
define input parameter p-obj-code       like ub.clients.obj-code no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_recipe
  , buf_recipe-gds
on error undo, return error return-value
:
find first buf_recipe no-lock
     where buf_recipe.recipe-code = p-recipe-code
.
find first buf_fbr-recipe exclusive-lock
     where buf_fbr-recipe.doc-code      = p-doc-code
       and buf_fbr-recipe.recipe-code   = p-recipe-code
no-error.
if not available buf_fbr-recipe
then do:
  create buf_fbr-recipe.
  assign
    buf_fbr-recipe.doc-code     = p-doc-code
    buf_fbr-recipe.recipe-code  = p-recipe-code
    buf_fbr-recipe.recipe-type  = buf_recipe.recipe-type
  .
  for each buf_recipe-gds exclusive-lock
     where buf_recipe-gds.recipe-code = p-recipe-code
  on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
        run fbrlib_create-fbr-recipe-gds in this-procedure (
              input p-doc-code
            , input buf_recipe-gds.recipe-code
            , input buf_recipe-gds.prod-type
            , input buf_recipe-gds.prod-code
            , input buf_recipe-gds.artic
            , input buf_recipe-gds.gds-code
            , input buf_recipe-gds.is-waste
            , input buf_recipe-gds.proc-number
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , input buf_recipe-gds.calc-method
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.qnty
            , input buf_recipe-gds.brutto-qnty
      ) no-error.
      if error-status:error
      then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
      end.
  end.
  buffer-copy buf_recipe to buf_fbr-recipe.
end.
end.
END PROCEDURE.
PROCEDURE fill-temp-dressing-ingr :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
    define variable v-free-qnty     as decimal       no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_c_fbr-line            for ub.fbr-line.
    define buffer buf_i_fbr-line            for ub.fbr-line.
    define buffer buf_i_other_fbr-line      for ub.fbr-line.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_recipe-gds            for ub.fbr-recipe-gds.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code    = p-doc-code
           and buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_c_fbr-line no-lock
         where buf_c_fbr-line.doc-code    = p-doc-code
           and buf_c_fbr-line.is-comp     = yes
           and buf_c_fbr-line.recipe-code = p-recipe-code
    .
    if buf_recipe.recipe-type <> 'разделка':U
    and ( buf_recipe.recipe-type <> 'комплектация':U
         or buf_c_fbr-line.trn-type <> 'спи':U )
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Процедура fill-temp-dressing-ingr применима только к рецептам разделки и разукомплектации."
            skip return-value
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_dressing-ingr
    :
        delete buf_temp_dressing-ingr.
    end.
    for each buf_i_fbr-line no-lock
       where buf_i_fbr-line.doc-code    = p-doc-code
         and buf_i_fbr-line.is-comp     = no
         and buf_i_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_i_fbr-line.artic
               and buf_goods.prod-type  = buf_i_fbr-line.prod-type
               and buf_goods.prod-code  = buf_i_fbr-line.prod-code
        .
        find first buf_temp_dressing-ingr
             where buf_temp_dressing-ingr.recipe-code = p-recipe-code
               and buf_temp_dressing-ingr.gds-code    = buf_goods.gds-code
        no-error.
        if not available buf_temp_dressing-ingr
        then do:
            create buf_temp_dressing-ingr.
            assign
                buf_temp_dressing-ingr.recipe-code  = p-recipe-code
                buf_temp_dressing-ingr.gds-code     = buf_goods.gds-code
                buf_temp_dressing-ingr.used-qnty    = 0
                buf_temp_dressing-ingr.line-qnty    = 0
                buf_temp_dressing-ingr.recipe-qnty  = 0
            .
        end.
        run fbrrest-get-free-qnty in this-procedure (
              input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , input buf_goods.gds-code
            , input no
            , output v-free-qnty
        ).
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = p-recipe-code
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code <> p-recipe-code
             and buf_i_other_fbr-line.artic       = buf_i_fbr-line.artic
             and buf_i_other_fbr-line.prod-type   = buf_i_fbr-line.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_i_fbr-line.prod-code
        :
            assign
                buf_temp_dressing-ingr.line-qnty    = buf_temp_dressing-ingr.line-qnty
                                                        + buf_i_other_fbr-line.fact-qnty
            .
        end.
        if available buf_temp_dressing-ingr
        then do:
            assign
                buf_temp_dressing-ingr.used-qnty = buf_temp_dressing-ingr.line-qnty - v-free-qnty
            .
        end.
    end.
    for each buf_temp_dressing-ingr
       where buf_temp_dressing-ingr.recipe-code = p-recipe-code
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_dressing-ingr.gds-code
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code = buf_temp_dressing-ingr.recipe-code
             and buf_i_other_fbr-line.artic       = buf_goods.artic
             and buf_i_other_fbr-line.prod-type   = buf_goods.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_goods.prod-code
        on error undo, return error
        :
            assign
                buf_temp_dressing-ingr.recipe-qnty = buf_temp_dressing-ingr.recipe-qnty
                                                    + buf_i_other_fbr-line.fact-qnty
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE test-temp-tables :
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.
define variable v-str               as character        no-undo.
    assign
        v-str = p-title + " temp_goods-qnty:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_goods-qnty
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_goods-qnty.gds-code )
                    + "   " + ( if buf_temp_goods-qnty.recipe-type = ? then "?" else string( buf_temp_goods-qnty.recipe-type ) )
                    + "   " + ( if buf_temp_goods-qnty.recipe-code = ? then "?" else string( buf_temp_goods-qnty.recipe-code ) )
                    + "   " + ( if buf_temp_goods-qnty.trn-type = ?    then "?" else string( buf_temp_goods-qnty.trn-type ) )
                    + "   " + ( if buf_temp_goods-qnty.need-qnty = ?   then "?" else string( buf_temp_goods-qnty.need-qnty ) )
                    + "   " + string( buf_temp_goods-qnty.calculated )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.
    assign
        v-str = "        temp_dressing-ingr:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_dressing-ingr.recipe-code  )
                    + "   " + string( buf_temp_dressing-ingr.gds-code )
                    + "   " + ( if buf_temp_dressing-ingr.line-qnty = ?   then "?" else string( buf_temp_dressing-ingr.line-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.used-qnty = ?   then "?" else string( buf_temp_dressing-ingr.used-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.recipe-qnty = ? then "?" else string( buf_temp_dressing-ingr.recipe-qnty ) )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.
end.
END PROCEDURE.
PROCEDURE add-new-recipe :
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-need-qnty          as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.
define input parameter p-have-store         as logical          no-undo.
    define variable v-comp-gds-code         as integer          no-undo.
    define variable v-comp-trn-type         as character        no-undo.
    define variable v-comp-need-qnty        as decimal          no-undo.
    define variable v-comp-recipe-type      as character        no-undo.
    define variable v-comp-recipe-code      as character        no-undo.
    define variable v-comp-recipe-found     as logical          no-undo.
    define variable v-ext-comp-recipe-type  as character        no-undo.
    define variable v-no-add-good           as logical          no-undo.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .
    define variable v-ban-recipes as logical no-undo .
    define variable v-ban-altr    as logical no-undo .
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true .
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    run extend-noweight-gds-qnty in this-procedure (
          input p-gds-code
        , input p-need-qnty
        , output p-need-qnty
    ).
    run select-recipe in this-procedure (
          input p-mainmenu-handle
        , input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
        , input p-gds-code
        , input p-trn-type
        , input p-need-qnty
        , input p-autofbr
        , input p-have-store
        , output v-comp-gds-code
        , output v-comp-trn-type
        , output v-comp-need-qnty
        , output v-comp-recipe-type
        , output v-comp-recipe-code
        , output v-comp-recipe-found
        , output v-no-add-good
    ) no-error.
    if not error-status :error
    and v-comp-recipe-found = yes
    and v-no-add-good       = no
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        assign
            v-ext-comp-recipe-type = v-comp-recipe-type
        .
        if v-comp-recipe-type = 'комплектация':U
        and v-comp-trn-type   = 'спи':U
        then do:
            assign
                v-ext-comp-recipe-type = 'разделка':U
            .
        end.
        case v-ext-comp-recipe-type
        :
            when 'разделка':U
            then do:
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                       and buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                no-error.
                if not available buf_temp_goods-qnty
                then do:
                    create buf_temp_goods-qnty.
                    assign
                        buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                        buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                        buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                        buf_temp_goods-qnty.artic       = buf_goods.artic
                        buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                        buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                        buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                        buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.
                else do:
                    find first buf_goods no-lock
                         where buf_goods.gds-code = p-gds-code
                    .
                    find first buf_fbr-line no-lock
                         where buf_fbr-line.doc-code    = p-doc-code
                           and buf_fbr-line.trn-type    = p-trn-type
                           and buf_fbr-line.recipe-code = v-comp-recipe-code
                           and buf_fbr-line.artic       = buf_goods.artic
                           and buf_fbr-line.prod-type   = buf_goods.prod-type
                           and buf_fbr-line.prod-code   = buf_goods.prod-code
                    no-error.
                    if available buf_fbr-line
                    then do:
                        define variable v-line-qnty             as decimal   no-undo.
                        define variable v-used-qnty             as decimal   no-undo.
                        define variable v-free-qnty             as decimal   no-undo.
                        define variable v-recipe-qnty           as decimal   no-undo.
                        define variable v-comp-fbr-line-recid   as recid     no-undo.
                        run get-temp_dressing-ingr-used-qnty in this-procedure (
                              input v-comp-recipe-code
                            , input p-gds-code
                            , output v-line-qnty
                            , output v-used-qnty
                            , output v-recipe-qnty
                        ).
                        run fbrrest-get-free-qnty in this-procedure (
                              input buf_fbr-doc.obj-type
                            , input buf_fbr-doc.obj-code
                            , input p-gds-code
                            , input p-autofbr
                            , output v-free-qnty
                        ).
                        assign
                            p-need-qnty = p-need-qnty + v-recipe-qnty
                        .
                        run calc-comp-from-ingr in this-procedure (
                              input recid( buf_fbr-line )
                            , input p-need-qnty
                            , output v-comp-fbr-line-recid
                            , output v-comp-need-qnty
                        ) .
                    end.
                    assign
                        buf_temp_goods-qnty.need-qnty   = maximum( buf_temp_goods-qnty.need-qnty, v-comp-need-qnty )
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.
            end.
            otherwise do:
      if v-ban-altr or v-ban-recipes then
      do:
          if v-ext-comp-recipe-type = 'производство':U and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  'mark-type':U
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   message "Рецепт производства " + v-comp-recipe-code + " содержит маркированный товар."
                      view-as alert-box.
                   return .
                end.
             end.
          end.
          if v-ext-comp-recipe-type = 'альтернатива':U and v-ban-altr then
          do:
             if not check-ban-sales-via-cd(buf_goods.gds-code) then
             do:
               message "Рецепт альтернатива " + v-comp-recipe-code + " входит в группу, у которой не установлен атрибут: " + chr(10) + "Запрет передачи на кассу."
                 view-as alert-box.
               return .
             end.
          end.
          if v-ext-comp-recipe-type = 'комплектация':U and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  'mark-type':U
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   run gds-attr-value in this-procedure  ( input  p-gds-code
                      , input  'mark-type':U
                      , output v-attr-value-rec
                      , output v-attr-type
                      ) no-error .
                   if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                   do:
                      message "Рецепт комплектации " + v-comp-recipe-code + " должен быть маркированным"
                         view-as alert-box.
                      return .
                   end.
                   else leave.
                end.
             end.
          end.
      end.
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code = p-gds-code
                       and buf_temp_goods-qnty.trn-type = p-trn-type
                no-error.
                if available buf_temp_goods-qnty
                then do:
                    assign
                        buf_temp_goods-qnty.need-qnty  = buf_temp_goods-qnty.need-qnty + p-need-qnty
                    .
                    if buf_temp_goods-qnty.recipe-code <> ""
                    then do:
                        assign
                            buf_temp_goods-qnty.calculated = no
                        .
                    end.
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Раскрутка ингредиетнов: добавляем товар '&1' к уже рассчитанному: &2", buf_temp_goods-qnty.artic, buf_temp_goods-qnty.need-qnty  ) ).
                end.
                else do:
                    find first buf_temp_goods-qnty
                         where buf_temp_goods-qnty.gds-code = v-comp-gds-code
                           and buf_temp_goods-qnty.trn-type = v-comp-trn-type
                    no-error.
                    if not available buf_temp_goods-qnty
                    then do:
                        create buf_temp_goods-qnty.
                        find first buf_goods no-lock
                             where buf_goods.gds-code = v-comp-gds-code
                        .
                        assign
                            buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                            buf_temp_goods-qnty.artic       = buf_goods.artic
                            buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                            buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                            buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                            buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                            buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                            buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                            buf_temp_goods-qnty.calculated  = no
                        .
                        run writelog in this-procedure ( log-file-name, 5, "Раскрутка ингредиентов: добавляем товар как не рассчитанный." ).
                    end.
                end.
            end.
        end case.
        if available buf_temp_goods-qnty
        then do:
            run extend-noweight-gds-qnty in this-procedure (
                  input buf_temp_goods-qnty.gds-code
                , input buf_temp_goods-qnty.need-qnty
                , output buf_temp_goods-qnty.need-qnty
            ).
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        if v-ext-comp-recipe-type = 'разделка':U
        then do:
            find first buf_fbr-line exclusive-lock
                where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.trn-type    = v-comp-trn-type
                and buf_fbr-line.recipe-code = v-comp-recipe-code
                and buf_fbr-line.artic       = buf_goods.artic
                and buf_fbr-line.prod-type   = buf_goods.prod-type
                and buf_fbr-line.prod-code   = buf_goods.prod-code
            no-error.
            if available buf_fbr-line
            then do:
                assign
                    buf_fbr-line.fact-qnty = 0
                .
            end.
        end.
        else do:
            for each buf_fbr-line exclusive-lock
            where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.recipe-code = v-comp-recipe-code
            on error undo, return error
            :
                delete buf_fbr-line.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE extend-noweight-gds-qnty :
do
on error undo, return error
:
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-in-qnty    as decimal      no-undo.
define output parameter p-out-qnty  as decimal      no-undo.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_units                 for ub.units.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    assign
        p-out-qnty = p-in-qnty
    .
    if not ( lookup( 'вес':U, buf_units.type ) > 0
             or lookup ('дро':U, buf_units.type) > 0 )
    then do:
        if p-out-qnty <> truncate( p-out-qnty, 0 )
        then do:
            assign
                p-out-qnty = truncate( p-out-qnty, 0 ) + 1
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE select-recipe :
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-qnty           as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.
define input parameter p-have-store         as logical          no-undo.
define output parameter p-out-gds-code      as integer          no-undo.
define output parameter p-out-trn-type      as character        no-undo.
define output parameter p-out-gds-qnty      as decimal          no-undo.
define output parameter p-out-recipe-type   as character        no-undo.
define output parameter p-out-recipe-code   as character        no-undo.
define output parameter p-recipe-found      as logical          no-undo.
define output parameter p-no-need-good      as logical          no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .
define variable v-type                  as character    no-undo.
define variable v-recipe-type           as character    no-undo.
define variable v-recipe-list           as character    no-undo.
define variable v-is-comp               as logical      no-undo.
define variable v-is-integration        as logical      no-undo.
define variable v-cancel                as logical      no-undo.
define variable v-yesno                 as logical      no-undo.
define variable v-default-recipe-code   as character    no-undo.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_goods             for ub.goods.
    define buffer buf_selected_recipe   for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_ingr_goods        for ub.goods.
    run writelog in this-procedure (
        input log-file-name
        , input 0
        , input "******** select-recipe ***************************************"
    ).
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-trn-type = ?
    then do:
        run writelog in this-procedure ( log-file-name, 0, "Не определен тип строки. Добавление невозможно" ).
        undo, return error.
    end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'fbrattr':U
                      , input  'fbr-frcp':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error then do:
       assign
          v-value-logical = FALSE
       .
    end.
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "fbr-frcp = '&1'", v-value-logical )
    ).
    assign
        p-out-recipe-type = ?
        p-out-recipe-code = ?
        v-recipe-type = ?
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-default-recipe-code
    ).
    comp-recipe:
    for each buf_recipe no-lock
       where ( buf_recipe.obj-type = p-obj-type
           and buf_recipe.obj-code = p-obj-code
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
           and buf_recipe.stts      <> 2
          )
          or ( buf_recipe.obj-type = ""
           and buf_recipe.obj-code = 0
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
           and buf_recipe.stts      <> 2
          )
    :
        if  ( p-autofbr = yes or v-value-logical = yes ) and buf_recipe.recipe-code <> v-default-recipe-code
        then do:
            undo comp-recipe, next comp-recipe.
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
        ).
        if p-autofbr = yes
        and buf_recipe.recipe-type <> 'производство':U
        and buf_recipe.recipe-type <> 'альтернатива':U
        and buf_recipe.recipe-type <> 'комплектация':U
        and buf_recipe.recipe-type <> 'комплектация':U
        then do:
            next comp-recipe.
        end.
        if p-trn-type = 'при':U
        and buf_recipe.recipe-type = 'разделка':U
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Разделка для составного не может дать прихода. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if p-trn-type = 'спи':U
        and buf_recipe.recipe-type <> 'разделка':U
        and buf_recipe.recipe-type <> 'комплектация':U
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Только разделка или разукомплектация для составного может дать списание. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if v-recipe-type = ?
        then do:
            assign
                p-out-recipe-type = buf_recipe.recipe-type
                p-out-recipe-code = buf_recipe.recipe-code
                v-recipe-type = "recipe"
                v-is-integration = yes
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден первый подходящий рецепт для составного"
            ).
            if v-value-logical
            then do:
                run writelog in this-procedure (
                    input log-file-name
                    , input 4
                    , input "Включен параметр fbr-frcp. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
            if p-autofbr = yes
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 4
                    , input "Раскрутка для ресторана. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
        end.
        else do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден еще один подходящий рецепт"
            ).
            assign
                v-yesno = ?
                p-no-need-good = yes
            .
            do while v-yesno = ?
            and p-no-need-good = yes
            :
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-sel"
                    , input 'все':U
                    , input recid( buf_goods )
                    , input p-obj-type
                    , input p-obj-code
                    , output v-recipe-list
                ) no-error.
                if error-status :error
                or v-recipe-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление товаров"
                        skip "Cancel - вернуться к выбору рецептов"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
                    assign
                        p-no-need-good = no
                    .
                end.
            end.
            if p-no-need-good = yes
            then do:
                if v-yesno = no
                then do:
                    undo, return error .
                end.
                else do:
                    return.
                end.
            end.
            find first buf_selected_recipe no-lock
                 where recid( buf_selected_recipe ) = integer( entry( 1, v-recipe-list ) )
            no-error.
            if not available buf_selected_recipe
            then do:
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = ?
                    v-is-integration  = ?
                .
            end.
            else do:
                assign
                    p-out-recipe-type   = buf_selected_recipe.recipe-type
                    p-out-recipe-code   = buf_selected_recipe.recipe-code
                    v-recipe-type       = "recipe"
                    v-is-integration    = yes
                .
                leave comp-recipe.
            end.
        end.
    end.
    if v-recipe-type = ?
    and p-autofbr = no
    then do:
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input "Поиск товара среди ингредиентов рецептов."
        ).
        search-recipe-gds:
        for each buf_recipe-gds
           where buf_recipe-gds.artic       = buf_goods.artic
             and buf_recipe-gds.prod-type   = buf_goods.prod-type
             and buf_recipe-gds.prod-code   = buf_goods.prod-code
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
                   and buf_recipe.obj-type    = p-obj-type
                   and buf_recipe.obj-code    = p-obj-code
                 no-error
            .
            if not available buf_recipe then next search-recipe-gds.
            find buf_ingr_goods no-lock
                where buf_ingr_goods.gds-code = buf_recipe.gds-code
            .
            if buf_ingr_goods.stts <> 0 then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input subst("Рецепт &1 на товар &2 не подходит т.к. товар удален", buf_recipe.recipe-code, buf_ingr_goods.gds-code)
                ).
                next search-recipe-gds.
            end.
            run writelog in this-procedure (
                  input log-file-name
                , input 3
                , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
            ).
            if p-trn-type = 'при':U
            and buf_recipe.recipe-type <> 'разделка':U
            and buf_recipe.recipe-type <> 'комплектация':U
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Только разделка или разукомплектация для ингредиента может дать приход"
                ).
                next search-recipe-gds.
            end.
            if p-trn-type = 'спи':U
            and buf_recipe.recipe-type = 'разделка':U
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Разделка для ингредиента не может дать списания"
                ).
                next search-recipe-gds.
            end.
            if v-recipe-type = ?
            then do:
                assign
                    p-out-recipe-type   = buf_recipe.recipe-type
                    p-out-recipe-code   = buf_recipe.recipe-code
                    v-recipe-type       = "recipe-gds"
                    v-is-integration    = no
                .
                if v-value-logical
                then do:
                    leave search-recipe-gds.
                end.
            end.
            else do:
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = p-out-recipe-code + chr(44) + buf_recipe.recipe-code
                    v-is-integration  = ?
                .
            end.
        end.
    end.
    if p-out-recipe-type = ?
    and p-out-recipe-code = ?
    then do:
        assign
            p-recipe-found = no
        .
    end.
    else do:
        if p-out-recipe-type = ?
        then do:
            define variable v-recipe-recid-list as character     no-undo.
            run str/rcp-sel.w (
                  input p-mainmenu-handle
                , input buf_goods.gds-code
                , input 'при':U
                , output p-out-recipe-code
                , output v-is-integration
                , output v-cancel
            ) .
            if v-cancel = yes
            then do:
                assign
                    p-recipe-found = no
                    p-no-need-good = yes
                .
                return.
            end.
        end.
        assign
            p-recipe-found = yes
        .
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-out-recipe-code
        .
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe.artic
               and buf_goods.prod-type  = buf_recipe.prod-type
               and buf_goods.prod-code  = buf_recipe.prod-code
        .
        assign
            p-out-recipe-type   = buf_recipe.recipe-type
            p-out-gds-code      = buf_goods.gds-code
        .
        run fbrlib-get-trn-type in this-procedure (
              input buf_recipe.recipe-code
            , input recid( buf_goods )
            , input v-is-integration
            , output v-is-comp
            , output p-out-trn-type
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 1
            , input substitute( "Найден рецепт '&1' с is-comp = &2, товаром '&3 &4', типом &5"
                                , p-out-recipe-code
                                , v-is-comp
                                , buf_goods.artic
                                , buf_goods.gds-name
                                , p-out-trn-type )
        ).
        if p-out-gds-code <> p-gds-code
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input "Необходимый товар является ингредиентом"
            ).
            find first buf_goods no-lock
                 where buf_goods.gds-code = p-gds-code
            .
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
                   and buf_recipe-gds.artic       = buf_goods.artic
                   and buf_recipe-gds.prod-type   = buf_goods.prod-type
                   and buf_recipe-gds.prod-code   = buf_goods.prod-code
            .
            if buf_recipe-gds.brutto-qnty = ?
            or buf_recipe-gds.brutto-qnty = 0
            then do:
                message
                    "При раскрутке рецепта обнаружен ингредиент с количеством " buf_recipe-gds.brutto-qnty
                    skip "Продолжение расчета документа невозможно."
                    skip(1) "Код рецепта:      " buf_recipe.recipe-code
                    skip    "Товар ингредиента:" buf_recipe-gds.artic buf_goods.gds-name
                view-as alert-box error.
                undo, return error .
            end.
            assign
                p-out-gds-qnty = p-gds-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
                p-out-trn-type = ( if p-trn-type = 'спи':U then 'при':U else 'спи':U )
            .
            run writelog in this-procedure (
                input log-file-name
                , input 1
                , input substitute( "Количество товара: &1. Для его производства необходимо: &2 по рецепту: &3. Тип строки составного: &4."
                                    , p-gds-qnty
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.
        else do:
            assign
                p-out-gds-qnty = p-gds-qnty
                p-out-trn-type = p-trn-type
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input substitute( "Для производства товара необходимо: &1 по рецепту: &2. Тип строки: &3."
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.
    end.
end.
END PROCEDURE.
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
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
def var vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info56 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info60 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info60, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info60, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info60, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info60, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info60 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info60, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info60 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info60, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info60, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info60, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info60, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info60, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info60, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info60 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info60 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info60, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info60, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info60, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info60 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info60 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info60, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info60, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
define shared variable br-handle as handle no-undo.
define shared buffer f-doc for ub.fbr-doc.
define shared query br-docs     for f-doc scrolling.
define new shared buffer buf_comp_fbr-line for ub.fbr-line.
define new shared buffer buf_ingr_fbr-line for ub.fbr-line.
define variable ref-list                   as character no-undo.
define variable v-fbr-doc-fbroperator-code as integer   no-undo.
define variable v-price-sale-obj-type      as character no-undo.
define variable v-price-sale-obj-code      as integer   no-undo.
define variable v-artic                    as character initial " " no-undo.
define variable current-browse             as handle    no-undo.
define variable comp-OK                    as logical   no-undo.
define variable comp-prod                  as logical   no-undo.
define variable comp-name                  as character no-undo.
define variable comp-unit                  as character no-undo.
define variable ingr-OK                    as logical   no-undo.
define variable ingr-prod                  as logical   no-undo.
define variable ingr-name                  as character no-undo.
define variable ingr-unit                  as character no-undo.
define variable ingr-netto                 as decimal   no-undo.
define variable comp-sort-column-name      as character no-undo .
define variable ingr-sort-column-name      as character no-undo .
define variable v-close-enabled            as logical   init no no-undo.
define variable v-need-refresh             as logical   init no no-undo.
define variable v-fbr-doc-line-rec         as recid     no-undo.
define variable v-fbr-doc-g-log            as logical   no-undo.
define variable v-fbr-doc-rep-rec          as recid     no-undo.
define variable gds-rec                    as recid     no-undo.
define variable v-ban-recipes   as logical      no-undo .
define variable v-ban-altr      as logical      no-undo .
define variable v-base                     as logical   init no no-undo.
define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable bcol_comp as handle extent no-undo.
define variable hBrowse_comp as handle no-undo.
define variable ii as integer no-undo.
define new shared buffer flt-gds      for ub.goods.
define            buffer buf_parts    for ub.parts.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-back-date       as logical   no-undo .
define variable v-back-date-type  as character no-undo .
define variable is-shift-on       as logical   no-undo.
define variable v-mark-weight as decimal no-undo .
define variable v-isweighed as logical no-undo .
FUNCTION get-goods-name RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID )  FORWARD.
FUNCTION get-line-OK RETURNS logical
   ( p-fbr-line-recid AS RECID )  FORWARD.
FUNCTION get-netto-qnty RETURNS DECIMAL
   ( p-fbr-line-recid AS RECID )  FORWARD.
FUNCTION get-prod-ref RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID  )  FORWARD.
FUNCTION get-unit-base RETURNS CHARACTER
   (  p-fbr-line-recid AS RECID  )  FORWARD.
FUNCTION need-marks RETURNS logical
   (  buffer local-fbr-line for ub.fbr-line )  FORWARD.
DEFINE MENU m-add
   MENU-ITEM m-rcp-add      LABEL "Товар с &рецептом"
   MENU-ITEM m-all-add      LABEL "Товары по в&сем связанным рецептам"
   MENU-ITEM m-comp-add     LABEL "Товар без рецепта в &верхний список"
   MENU-ITEM m-ingr-add     LABEL "Товар без рецепта в &нижний список".
DEFINE MENU m-del
   MENU-ITEM m-rcp-del      LABEL "Товар с &рецептом"
   MENU-ITEM m-all-del      LABEL "Товары по в&сем связанным рецептам"
   MENU-ITEM m-all-doc-del  LABEL "Вс&е товары документа"
   MENU-ITEM m-comp-del     LABEL "Товар без рецепта в &верхнем списке"
   MENU-ITEM m-ingr-del     LABEL "Товар без рецепта в &нижнем списке".
DEFINE MENU m-outs
   MENU-ITEM m-sale         LABEL "&Продажа"
   MENU-ITEM m-doc          LABEL "&Накладная"
   MENU-ITEM m-ord          LABEL "&Заказ"        .
DEFINE MENU POPUP-MENU-b-rsrv
   MENU-ITEM m-doc-rsrv     LABEL "По всему &документу"
   MENU-ITEM m-rcp-rsrv     LABEL "По текущему &рецепту".
DEFINE BUTTON b-add
   LABEL "&Добавить"
   SIZE 10 BY 1 TOOLTIP "Добавление строк по рецепту (или без него)".
DEFINE BUTTON b-add-marks
   LABEL "Доб. &марки"
   SIZE 12 BY 1 TOOLTIP "Добавление марок по текущей строке".
DEFINE BUTTON b-calc-comp
   LABEL "С&ост"
   SIZE 6 BY 1 TOOLTIP "Расчет полученного товара от строк ингредиентов по рецепту".
DEFINE BUTTON b-calc-ingr
   LABEL "Ин&гр"
   SIZE 6 BY 1 TOOLTIP "Расчет строк ингредиентов от полученного товара по рецепту".
DEFINE BUTTON b-chg
   LABEL "&Изменить"
   SIZE 10 BY 1 TOOLTIP "Изменение строки составного товара".
DEFINE BUTTON b-del
   LABEL "&Удалить"
   SIZE 10 BY 1 TOOLTIP "Удаление строк по рецепту (или без него)".
DEFINE BUTTON b-exit
   LABEL "&Выход "
   SIZE 10 BY 1 TOOLTIP "Выход из документа с сохранением состояния"
   BGCOLOR 8 .
DEFINE BUTTON b-gds
   LABEL "Товар&ы"
   SIZE 10 BY 1 TOOLTIP "Просмотр документа производства по товарам"
   BGCOLOR 8 .
DEFINE BUTTON b-help
   LABEL "Помо&щь"
   SIZE 10 BY 1 TOOLTIP "Помощь"
   BGCOLOR 8 .
DEFINE BUTTON b-lkp
   LABEL "&Просмотр"
   SIZE 10 BY 1 TOOLTIP "Просмотр строки составного товара".
DEFINE BUTTON b-next AUTO-GO
   LABEL "&>>"
   SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующего документа списка".
DEFINE BUTTON b-parts
   LABEL "&Партии"
   SIZE 10 BY 1 TOOLTIP "Просмотр или редактирование партий товара"
   BGCOLOR 8 .
DEFINE BUTTON b-prev AUTO-GO
   LABEL "&<<"
   SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего документа списка".
DEFINE BUTTON b-recipe
   LABEL "&Рецепт"
   SIZE 10 BY 1 TOOLTIP "Просмотр или исправление рецепта для текущей строки".
DEFINE BUTTON b-rsrv
   LABEL "Ре&зерв"
   SIZE 10 BY 1 TOOLTIP "Резервирование списываемого товара"
   BGCOLOR 8 .
DEFINE BUTTON r-fbroperator
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-price"
   SIZE 3 BY .88 TOOLTIP "Выбор ответственного за операции производства".
DEFINE BUTTON r-outs
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-outs"
   SIZE 3 BY .88 TOOLTIP "Список накладных по объекту".
DEFINE BUTTON r-pay
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-pay"
   SIZE 3 BY .88 TOOLTIP "Выбор объекта, с которого берутся цены продажи".
DEFINE BUTTON r-price
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-price"
   SIZE 3 BY .88 TOOLTIP "Выбор объекта, с которого берутся цены продажи".
DEFINE BUTTON shift-sel
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL ""
   SIZE 3 BY .88.
DEFINE VARIABLE effect           AS DECIMAL   FORMAT "->>,>>9.99%":U INITIAL 0
   LABEL "Эфф"
   VIEW-AS FILL-IN
   SIZE 8.25 BY 1 TOOLTIP "Эффективность: увеличение суммы продажных цен в процентах"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE fact-date        AS DATE      FORMAT "99/99/99":U
   LABEL "Факт"
   VIEW-AS FILL-IN
   SIZE 9.75 BY 1 TOOLTIP "Факт дата закрытия"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE fi-pay-code      AS INTEGER   FORMAT "99999":U INITIAL 0
   LABEL "&Опл"
   VIEW-AS FILL-IN
   SIZE 6.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-pay-type-name AS CHARACTER FORMAT "X(40)":U
   VIEW-AS FILL-IN
   SIZE 12.5 BY 1
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE ingr-goods-type  AS CHARACTER FORMAT "X(1)":U
   VIEW-AS FILL-IN
   SIZE 2.38 BY 1 TOOLTIP "Буква У появляется, если это услуга"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE ingr-long        AS CHARACTER FORMAT "X(256)":U
   LABEL "Товар"
   VIEW-AS FILL-IN
   SIZE 66 BY 1 TOOLTIP "Полное название товара из нижнего списка"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE obj-fbroperator  AS CHARACTER FORMAT "X(256)":U
   LABEL "Ответственный"
   VIEW-AS FILL-IN
   SIZE 13 BY 1 TOOLTIP "Ответственный за операции производства"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE obj-price        AS CHARACTER FORMAT "X(256)":U
   LABEL "Цены"
   VIEW-AS FILL-IN
   SIZE 12.38 BY 1 TOOLTIP "Объект, с которого берутся цены продажи"
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE out-code         AS CHARACTER FORMAT "X(16)":U
   LABEL "Ис&т"
   VIEW-AS FILL-IN
   SIZE 16.13 BY 1 TOOLTIP "Номер накладной для добавления строк из нее" NO-UNDO.
DEFINE VARIABLE shift            AS CHARACTER FORMAT "X(256)":U
   LABEL "Смена"
   VIEW-AS FILL-IN
   SIZE 11 BY 1
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE tot-qnty         AS DECIMAL   FORMAT "->,>>>,>>9.99":U INITIAL 0
   LABEL "Сумма по фракциям"
   VIEW-AS FILL-IN
   SIZE 13.5 BY 1.08 NO-UNDO.
DEFINE VARIABLE rs-one-all       AS CHARACTER
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS
   "В&се", "all",
   "Ре&цепт", "recipe",
   "&Тип", "type",
   "Тов&ар", "goods"
   SIZE 28.63 BY .88 TOOLTIP "Строки по всем или для текущего рецепта, по типам, по товару" NO-UNDO.
DEFINE QUERY br-comp FOR
   buf_comp_fbr-line SCROLLING.
DEFINE QUERY br-ingr FOR
   buf_ingr_fbr-line SCROLLING.
DEFINE BROWSE br-comp
   QUERY br-comp NO-LOCK DISPLAY
   buf_comp_fbr-line.artic                                   format "x(16)"              column-label "Артикул"
   get-goods-name(recid(buf_comp_fbr-line)) @ comp-name      format "x(25)"              column-label "Название"
   buf_comp_fbr-line.trn-type                                format "x(3)"               column-label "Тип"
   get-line-OK(recid(buf_comp_fbr-line)) @ comp-OK           format "+/-"                column-label "OK"
   buf_comp_fbr-line.fact-qnty                               format ">>>>>9.999"         column-label "Количество"
   get-unit-base(recid(buf_comp_fbr-line)) @ comp-unit       format "x(3)"               column-label "Изм"
   buf_comp_fbr-line.is-calc                                 format "*/-"                column-label "Ф"
   buf_comp_fbr-line.price-sale                              format ">>>,>>9.<<"         column-label "Цена продажи"
   buf_comp_fbr-line.fix-cost                                format "*/-"                column-label "Ф"
   buf_comp_fbr-line.price-base                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(б.в)"
   buf_comp_fbr-line.price-sum-base                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (б.в)"
   buf_comp_fbr-line.price-sum-vat-base                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (б.в)"
   buf_comp_fbr-line.price-rubl                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(руб)"
   buf_comp_fbr-line.price-sum-rubl                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (руб)"
   buf_comp_fbr-line.price-sum-vat-rubl                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (руб)"
   buf_comp_fbr-line.rsrv-qnty                               format ">>,>>>,>>9.<<<" column-label "Допустимо"
   get-prod-ref(recid(buf_comp_fbr-line)) @ comp-prod        format "x(14)"          column-label "Производитель"
ENABLE
      buf_comp_fbr-line.is-calc
      buf_comp_fbr-line.fix-cost
      buf_comp_fbr-line.price-rubl
      buf_comp_fbr-line.price-sum-vat-rubl
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 7.13.
DEFINE BROWSE br-ingr
   QUERY br-ingr DISPLAY
   buf_ingr_fbr-line.artic                                   format "X(16)"              column-label "Артикул"
   buf_ingr_fbr-line.recipe-code                             format "X(10)"              column-label "    Рецепт"
   get-goods-name(recid(buf_ingr_fbr-line)) @ ingr-name      format "X(24)"              column-label "Название"
   buf_ingr_fbr-line.trn-type                                format "X(3)"               column-label "Тип"
   get-line-OK(recid(buf_comp_fbr-line)) @ ingr-OK           format "+/-"                column-label "OK"
   buf_ingr_fbr-line.fact-qnty                               format ">>>>>9.999"         column-label "Брутто"
   get-unit-base(recid(buf_ingr_fbr-line)) @ ingr-unit       format "X(3)"               column-label "Изм"
   buf_ingr_fbr-line.is-calc                                 format "*/-"                column-label "Ф"
   buf_ingr_fbr-line.price-sale                              format ">>,>>>,>>9.<<"      column-label "Цена продажи"
   buf_ingr_fbr-line.fix-cost                                format "*/-"                column-label "Ф"
   buf_ingr_fbr-line.coeff-waste                             format "->,>>9.<<<"         column-label "%потерь"
   buf_ingr_fbr-line.coeff-value                             format "->,>>9.<<<"         column-label "%сезонн"
   get-netto-qnty(recid(buf_ingr_fbr-line)) @ ingr-netto     format ">>>>>9.999"         column-label "Нетто"
   buf_ingr_fbr-line.price-base                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(б.в)"
   buf_ingr_fbr-line.price-sum-base                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (б.в)"
   buf_ingr_fbr-line.price-sum-vat-base                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (б.в)"
   buf_ingr_fbr-line.price-rubl                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(руб)"
   buf_ingr_fbr-line.price-sum-rubl                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (руб)"
   buf_ingr_fbr-line.price-sum-vat-rubl                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (руб)"
   buf_ingr_fbr-line.rsrv-qnty                               format ">>,>>>,>>9.<<<"     column-label "Допустимо"
   get-prod-ref(recid(buf_comp_fbr-line)) @ ingr-prod        format "X(14)"              column-label "Производитель"
ENABLE
      buf_ingr_fbr-line.is-calc
      buf_ingr_fbr-line.fix-cost
      buf_ingr_fbr-line.fact-qnty
      buf_ingr_fbr-line.price-sale
      buf_ingr_fbr-line.price-base
      buf_ingr_fbr-line.price-rubl
      buf_ingr_fbr-line.price-sum-vat-base
      buf_ingr_fbr-line.price-sum-vat-rubl
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 8.63.
DEFINE FRAME D-FBR-DOC
   br-comp AT ROW 5.25 COL 2
   br-ingr AT ROW 15.13 COL 2
   fi-pay-code AT ROW 2.5 COL 76.5 COLON-ALIGNED
   fi-pay-type-name AT ROW 2.5 COL 83.5 COLON-ALIGNED NO-LABEL
   b-exit AT ROW 1.21 COL 2
   b-prev AT ROW 1.21 COL 12
   b-next AT ROW 1.21 COL 15
   b-rsrv AT ROW 1.21 COL 18
   b-gds AT ROW 1.21 COL 28
   b-parts AT ROW 1.21 COL 38
   out-code AT ROW 1.21 COL 43.25 COLON-ALIGNED
   r-outs AT ROW 1.21 COL 61.88
   obj-price AT ROW 1.21 COL 70 COLON-ALIGNED
   r-price AT ROW 1.21 COL 84.38
   b-help AT ROW 1.21 COL 88.25
   b-recipe AT ROW 3.83 COL 2
   b-lkp AT ROW 12.71 COL 2
   b-add AT ROW 12.71 COL 12
   b-chg AT ROW 12.71 COL 22
   b-del AT ROW 12.71 COL 32
   b-calc-ingr AT ROW 12.71 COL 42
   b-calc-comp AT ROW 12.71 COL 48
   b-add-marks AT ROW 12.71 COL 54
   rs-one-all AT ROW 12.71 COL 67.75 NO-LABEL
   fbr-recipe.recipe-code AT ROW 3.75 COL 13.38 COLON-ALIGNED NO-LABEL
   VIEW-AS FILL-IN
   SIZE 12.63 BY 1.08 TOOLTIP "Номер рецепта текущей строки"
   FGCOLOR 4
   fbr-recipe.recipe-type AT ROW 3.75 COL 10.63 COLON-ALIGNED NO-LABEL FORMAT "X(1)"
   VIEW-AS FILL-IN
   SIZE 2.5 BY 1.08 TOOLTIP "Тип рецепта: к - комплектация, а - альтернатива, п - производство, р - разделка"
   FGCOLOR 4
   fbr-recipe-gds.qnty AT ROW 13.96 COL 87.63 COLON-ALIGNED
   LABEL "Коэф"
   VIEW-AS FILL-IN
   SIZE 6.5 BY 1 TOOLTIP "Количество текущего ингредиента по рецепту"
   FGCOLOR 4
   fbr-recipe-gds.is-waste AT ROW 13.96 COL 78.75 COLON-ALIGNED NO-LABEL FORMAT "*/."
   VIEW-AS FILL-IN
   SIZE 2.5 BY 1 TOOLTIP "Звездочка зажигается, если это ОТХОДЫ"
   FGCOLOR 4
   fbr-recipe.recipe-name AT ROW 3.75 COL 24.5 COLON-ALIGNED NO-LABEL
   VIEW-AS FILL-IN
   SIZE 43.75 BY 1.08 TOOLTIP "Название рецепта текущей строки"
   FGCOLOR 4
   ingr-goods-type AT ROW 13.96 COL 76.5 COLON-ALIGNED NO-LABEL
   fbr-recipe.qnty AT ROW 3.79 COL 88.25 COLON-ALIGNED
   LABEL "Коэф"
   VIEW-AS FILL-IN
   SIZE 6.5 BY 1 TOOLTIP "Количество составного товара по рецепту"
   FGCOLOR 4
   effect AT ROW 3.79 COL 73.63 COLON-ALIGNED
   tot-qnty AT ROW 20.25 COL 37.5 COLON-ALIGNED
   ingr-long AT ROW 13.96 COL 10.5 COLON-ALIGNED
   obj-fbroperator AT ROW 2.5 COL 15 COLON-ALIGNED
   r-fbroperator AT ROW 2.5 COL 30.5
   r-pay AT ROW 2.5 COL 98
   fact-date AT ROW 2.5 COL 38 COLON-ALIGNED WIDGET-ID 2
   shift AT ROW 2.5 COL 55.5 COLON-ALIGNED WIDGET-ID 4
   shift-sel AT ROW 2.5 COL 69 WIDGET-ID 6
   SPACE(29.37) SKIP(20.36)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
   TITLE "".
ASSIGN
   FRAME D-FBR-DOC:SCROLLABLE = FALSE
   FRAME D-FBR-DOC:HIDDEN     = TRUE.
ASSIGN
   b-add:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-add:HANDLE.
ASSIGN
   b-del:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-del:HANDLE.
ASSIGN
   b-rsrv:POPUP-MENU IN FRAME D-FBR-DOC = MENU POPUP-MENU-b-rsrv:HANDLE.
ASSIGN
   effect:HIDDEN IN FRAME D-FBR-DOC = TRUE.
ASSIGN
   r-outs:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-outs:HANDLE.
ASSIGN
   shift:READ-ONLY IN FRAME D-FBR-DOC = TRUE.
ASSIGN
   tot-qnty:HIDDEN IN FRAME D-FBR-DOC = TRUE.
ON END-ERROR OF FRAME D-FBR-DOC
   OR ENDKEY OF FRAME D-FBR-DOC ANYWHERE
   DO:
      APPLY "CHOOSE":U TO b-exit.
   END.
ON GO OF FRAME D-FBR-DOC
   DO:
      define variable v-today as date    no-undo.
      define variable v-time  as integer no-undo.
      find first ub.fbr-line no-lock
         where ub.fbr-line.doc-code = f-doc.doc-code
         no-error.
      if not available ub.fbr-line
         and p-doc-mode <> 'ПРОСМОТР':U
         then
      do:
         message
            "В документе нет ни одной строки. Документ удаляется."
            view-as alert-box information.
         delete f-doc.
         assign
            p-fbr-doc-recid     = ?
            p-new-fbr-doc-recid = ?
            .
      end.
      else
      do:
         if p-doc-mode <> 'ПРОСМОТР':U
            then
         do:
            run cur-time in this-procedure (
               output v-today
               , output v-time
               ).
            assign
               f-doc.sys-date     = v-today
               f-doc.sys-time     = string( v-time, "HH:MM:SS":U )
               f-doc.sys-time-int = v-time
               .
         end.
      end.
   END.
ON WINDOW-CLOSE OF FRAME D-FBR-DOC
   DO:
      if v-close-enabled = no
         then
      do:
         undo, return no-apply.
      end.
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF b-calc-comp IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define variable v-comp-fbr-v-fbr-doc-line-recid as recid   no-undo.
      define variable v-comp-qnty                     as decimal no-undo.
      define variable v-comp-price-sale               as decimal no-undo.
      if not available buf_ingr_fbr-line
         then
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      run calc-comp-from-ingr in this-procedure (
         input recid( buf_ingr_fbr-line )
         , input buf_ingr_fbr-line.fact-qnty
         , output v-comp-fbr-v-fbr-doc-line-recid
         , output v-comp-qnty
         ).
      run set-comp-qnty in this-procedure (
         input v-comp-fbr-v-fbr-doc-line-recid
         , input v-comp-qnty
         ).
      run UI-on ("line").
   END.
ON CHOOSE OF b-calc-ingr IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define variable v-need-goods           as logical   no-undo.
      define variable v-need-goods-list      as character no-undo.
      define variable v-need-goods-qnty-list as character no-undo.
      if not available buf_comp_fbr-line
         then
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      run str/fbr-qnty.p (
         input parparentproc
         , input p-fbrhist-handle
         , input recid( f-doc )
         , input recid( buf_comp_fbr-line )
         , input yes
         , input "ingr"
         , input no
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input no
         , input no
         , input no
         , output v-need-goods
         , output v-need-goods-list
         , output v-need-goods-qnty-list
         ) no-error.
      if error-status:error then
      do:
         message
            substitute("Ошибка при расчете ингридиентов&1&2&1&3"
            , chr(10)
            , error-status:get-message(1)
            , return-value )
            view-as alert-box error .
      end.
      run UI-on in this-procedure ( input "line" ).
   END.
ON CHOOSE OF b-chg IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define variable v-cancel   as logical no-undo.
      define variable v-old-qnty as decimal no-undo.
      define variable v-mark-qnty as decimal no-undo init ? .
      define variable v-attr-value as character no-undo .
      define variable v-attr-type as character no-undo .
      define buffer buf_goods for ub.goods .
      define buffer buf_fbr-recipe for ub.fbr-recipe.
      define buffer buf_fbr-line   for ub.fbr-line.
      define buffer buf_marking-lines for ub.marking-lines .
      define buffer buf_marking for ub.marking .
      if not available buf_comp_fbr-line then
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      do
         on stop undo, return no-apply
         on error undo, return no-apply
         :
         assign
           v-old-qnty = buf_comp_fbr-line.fact-qnty
         .
         for first buf_goods no-lock where buf_goods.artic     = buf_comp_fbr-line.artic
                                       and buf_goods.prod-type = buf_comp_fbr-line.prod-type
                                       and buf_goods.prod-code = buf_comp_fbr-line.prod-code
         :
           v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, buf_goods.gds-code) .
           for each buf_marking-lines where buf_marking-lines.gds-code = buf_goods.gds-code
                                    and buf_marking-lines.obj-type = f-doc.obj-type
                                    and buf_marking-lines.obj-code = f-doc.obj-code
                                    and buf_marking-lines.in-code  = "manufacturing"
                                    and buf_marking-lines.out-code = buf_comp_fbr-line.doc-code
                                    and buf_marking-lines.part-code = buf_comp_fbr-line.recipe-code
                                    and buf_marking-lines.prt-code = 0
           :
             if v-mark-qnty = ? then assign v-mark-qnty = 0 .
             if v-isweighed
             then do :
               for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
                 v-mark-weight = MarkWeight(buf_marking.mark) .
                 assign v-mark-qnty = v-mark-qnty + v-mark-weight .
               end .
             end .
             else do :
               assign v-mark-qnty = v-mark-qnty + 1 .
             end .
           end .
         end .
         run str/fbr-line.w (
            input p-fbrhist-handle
            , input 'ИЗМЕНЕНИЕ':U
            , input buf_comp_fbr-line.doc-code
            , input recid (buf_comp_fbr-line)
            , input v-mark-qnty
            , output v-cancel
            ) no-error.
         if error-status :error
            then
         do:
            message
               vss-workfile vss-revision vss-description
               skip
               "Ошибка изменения количества составного товара."
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box error.
            undo, return no-apply .
         end.
         if buf_comp_fbr-line.recipe-code <> ""
            then
         do:
            define variable v-need-goods           as logical   no-undo.
            define variable v-need-goods-list      as character no-undo.
            define variable v-need-goods-qnty-list as character no-undo.
            if v-old-qnty > buf_comp_fbr-line.fact-qnty
               then
            do:
               find first buf_fbr-recipe no-lock
                  where buf_fbr-recipe.doc-code    = buf_comp_fbr-line.doc-code
                  and buf_fbr-recipe.recipe-code = buf_comp_fbr-line.recipe-code
                  .
               if buf_fbr-recipe.recipe-type = 'альтернатива':U
                  then
               do:
                  do transaction
                     :
                     for each buf_fbr-line exclusive-lock
                        where buf_fbr-line.doc-code    = buf_comp_fbr-line.doc-code
                        and buf_fbr-line.is-comp     = no
                        and buf_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code
                        :
                        delete buf_fbr-line.
                     end.
                  end.
               end.
            end.
            run str/fbr-qnty.p (
               input parparentproc
               , input p-fbrhist-handle
               , input recid( f-doc )
               , input recid( buf_comp_fbr-line )
               , no
               , "ingr"
               , no
               , v-price-sale-obj-type
               , v-price-sale-obj-code
               , input no
               , input no
               , input no
               , output v-need-goods
               , output v-need-goods-list
               , output v-need-goods-qnty-list
               ) no-error.
            if error-status :error
               then
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip
                  "Ошибка расчета количества ингредиентов"
                  skip
                  "при изменении количества составного товара"
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return no-apply .
            end.
         end.
      end.
      run UI-on ("line").
   END.
ON CHOOSE OF b-exit IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define variable v-can-continue as logical no-undo.
      define buffer buf_fbr-line for ub.fbr-line.
      if f-doc.is-free = no
         and p-doc-mode <> 'ПРОСМОТР':U
         then
      do:
         for each buf_fbr-line no-lock
            where buf_fbr-line.doc-code = f-doc.doc-code
            and buf_fbr-line.is-comp  = yes
            :
            run check-and-correct-fbr-recipe in this-procedure (
               input f-doc.doc-code
               , input buf_fbr-line.recipe-code
               , output v-can-continue
               ) no-error.
            if error-status :error
               then
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip
                  "Ошибка проверки соответствия"
                  skip
                  "строк рецепта документа и строк документа."
                  skip(1)
                  skip
                  "Рецепт:" buf_fbr-line.recipe-code
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return no-apply.
            end.
            if v-can-continue = no
               then
            do:
               undo, return no-apply.
            end.
         end.
         assign
            fi-pay-code
            .
         assign
            f-doc.pay-code = fi-pay-code
            .
      end.
      assign
         p-fbr-doc-next-prev = ?
         v-close-enabled     = yes
         .
      apply "GO" to frame D-FBR-DOC.
   END.
ON CHOOSE OF b-gds IN FRAME D-FBR-DOC
   DO:
      run assign-current-goods .
      run str/fbr-igds.w (
         input parparentproc
         , input recid( f-doc )
         , input-output gds-rec
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Ошибка просмотра документа производства по товарам."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box error.
         undo, return no-apply.
      end.
      if gds-rec <> ? then
      do:
         rs-one-all = "goods".
         run UI-on ("enable").
      end.
   END.
ON CHOOSE OF b-lkp IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define variable v-cancel as logical no-undo.
      if not available buf_comp_fbr-line then
      do:
         message "Неправильно выбрана строка.".
         undo, return no-apply.
      end.
      run str/fbr-line.w (
         input p-fbrhist-handle
         , input 'ПРОСМОТР':U
         , input buf_comp_fbr-line.doc-code
         , input recid (buf_comp_fbr-line)
         , input ?
         , output v-cancel
         ).
      return no-apply.
   END.
ON CHOOSE OF b-next IN FRAME D-FBR-DOC
   DO:
      assign
         v-close-enabled = yes
         v-need-refresh  = yes
         .
   END.
ON CHOOSE OF b-parts IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      case current-browse
         :
         when br-comp :handle
         then
            do:
               if buf_comp_fbr-line.trn-type = 'спи':U
                  then
               do:
                  run process-parts in this-procedure (
                     input buf_comp_fbr-line.doc-code
                     , input buf_comp_fbr-line.trn-type
                     , input buf_comp_fbr-line.recipe-code
                     , input buf_comp_fbr-line.artic
                     , input buf_comp_fbr-line.prod-type
                     , input buf_comp_fbr-line.prod-code
                     ) no-error.
                  if error-status :error
                     then
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip
                        "Ошибка обработки партий."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return no-apply .
                  end.
                  apply "entry" to br-comp in frame D-FBR-DOC .
               end.
               else
               do:
                  message
                     "Выберите строку списания."
                     view-as alert-box information.
               end.
            end.
         when br-ingr :handle
         then
            do:
               if buf_ingr_fbr-line.trn-type = 'спи':U
                  then
               do:
                  run process-parts in this-procedure (
                     input buf_ingr_fbr-line.doc-code
                     , input buf_ingr_fbr-line.trn-type
                     , input buf_ingr_fbr-line.recipe-code
                     , input buf_ingr_fbr-line.artic
                     , input buf_ingr_fbr-line.prod-type
                     , input buf_ingr_fbr-line.prod-code
                     ) no-error.
                  if error-status :error
                     then
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip
                        "Ошибка обработки партий."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return no-apply .
                  end.
                  apply "entry" to br-ingr in frame D-FBR-DOC .
               end.
               else
               do:
                  message
                     "Выберите строку списания."
                     view-as alert-box information.
               end.
            end.
      end case.
      run UI-on in this-procedure ( input "line" ).
   END.
ON CHOOSE OF b-prev IN FRAME D-FBR-DOC
   DO:
      assign
         v-close-enabled = yes
         v-need-refresh  = yes
         .
   END.
ON CHOOSE OF b-recipe IN FRAME D-FBR-DOC
   DO:
      define variable ri             as recid   no-undo.
      define variable v-cancel       as logical no-undo.
      define variable v-can-continue as logical no-undo.
      define variable v-goods-recid  as recid   no-undo.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      define buffer buf_recipe for ub.fbr-recipe.
      define buffer buf_goods  for ub.goods.
      if not available buf_comp_fbr-line
         then
      do:
         message
            "Неправильно выбрана строка."
            view-as alert-box error.
         undo, return no-apply.
      end.
      if buf_comp_fbr-line.recipe-code = ""
         then
      do:
         message
            "Данная строка не имеет рецепта."
            view-as alert-box error.
         undo, return no-apply.
      end.
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  f-doc.host-code
    ,input  f-doc.obj-type
    ,input  f-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-fbr-doc-g-log
    )  .
end.
      if not v-fbr-doc-g-log
         then
      do:
         undo, return no-apply .
      end.
      find first buf_recipe no-lock
         where buf_recipe.doc-code      = f-doc.doc-code
         and buf_recipe.recipe-code   = buf_comp_fbr-line.recipe-code
         .
      find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
         and buf_goods.prod-type  = buf_recipe.prod-type
         and buf_goods.prod-code  = buf_recipe.prod-code
         no-error.
      if not available buf_goods
         then
      do:
         message
            skip
            "Не найден товар рецепта."
            view-as alert-box error.
         undo, return no-apply .
      end.
      assign
         ri = recid( buf_recipe )
         .
      if p-doc-mode <> 'ПРОСМОТР':U
         then
      do:
         run check-and-correct-fbr-recipe in this-procedure (
            input f-doc.doc-code
            , input buf_comp_fbr-line.recipe-code
            , output v-can-continue
            ).
         if v-can-continue = no
            then
         do:
            undo, return no-apply.
         end.
      end.
      run ref/recips.w (
         input parparentproc
         , input ( if f-doc.status_ = 'новый':U then p-doc-mode else 'ПРОСМОТР':U )
         , input buf_comp_fbr-line.doc-code
         , input recid( buf_goods )
         , input buf_recipe.recipe-type
         , input buf_recipe.recipe-code
         , output v-cancel
         ).
      if v-cancel = no
         and p-doc-mode <> 'ПРОСМОТР':U
         then
      do:
         run fbrlib_adjust-doc-lines in this-procedure (
            input parparentproc
            , input p-fbrhist-handle
            , input buf_comp_fbr-line.doc-code
            , input buf_recipe.recipe-code
            , input v-price-sale-obj-type
            , input v-price-sale-obj-code
            ).
      end.
      apply "value-changed" to br-comp in frame D-FBR-DOC.
      apply "value-changed" to br-ingr in frame D-FBR-DOC.
   END.
ON ENTRY OF br-comp IN FRAME D-FBR-DOC
   DO:
      current-browse = br-comp:handle.
      if available buf_comp_fbr-line
         then
      do:
         run fill-recipe-fields in this-procedure (
            input buf_comp_fbr-line.recipe-code
            ).
      end.
   END.
ON MOUSE-SELECT-DBLCLICK OF br-comp IN FRAME D-FBR-DOC
   DO:
      if p-doc-mode = 'ПРОСМОТР':U or f-doc.status_ <> 'новый':U then
         apply "choose" to b-lkp.
      else
         apply "choose" to b-chg.
   END.
ON RETURN OF br-comp IN FRAME D-FBR-DOC
   DO:
      if p-doc-mode = 'ПРОСМОТР':U then
         apply "choose" to b-lkp.
      else
         apply "choose" to b-chg.
   END.
ON ROW-DISPLAY OF br-comp IN FRAME D-FBR-DOC
   DO:
      define buffer local_ingr_fbr-line for ub.fbr-line .
      if buf_comp_fbr-line.is-waste = yes
         then
      do:
         assign
            buf_comp_fbr-line.artic                 :bgcolor in browse br-comp = gray_color
            comp-name                               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.trn-type              :bgcolor in browse br-comp = gray_color
            comp-OK                                 :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.fact-qnty             :bgcolor in browse br-comp = gray_color
            comp-unit                               :bgcolor in browse br-comp = gray_color
            comp-prod                               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.is-calc               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sale            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.fix-cost              :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-rubl            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-base            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-rubl        :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-base        :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-vat-rubl    :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-vat-base    :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.rsrv-qnty             :bgcolor in browse br-comp = gray_color
            .
      end.
      for first local_ingr_fbr-line no-lock where local_ingr_fbr-line.doc-code = f-doc.doc-code
                                              and local_ingr_fbr-line.is-comp = no
                                              and local_ingr_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code
      :
        if need-marks(buffer local_ingr_fbr-line)
        then do ii = 1 to extent (bcol_comp):
          if valid-handle (bcol_comp[ii])
          then do:
            assign
              bcol_comp[ii]:bgcolor = RED_COLOR.
          end.
        end.
      end .
   END.
ON ROW-LEAVE OF br-comp IN FRAME D-FBR-DOC
   DO:
      if not available buf_comp_fbr-line
         then
      do:
         return .
      end.
      if not browse br-comp:current-row-modified
         then
      do:
         return .
      end.
      run change-current-comp-line in this-procedure (
         input recid( buf_comp_fbr-line )
         , input f-doc.status_
         , input f-doc.host-code
         ) no-error.
      display
         buf_comp_fbr-line.price-sale
         buf_comp_fbr-line.is-calc
         buf_comp_fbr-line.fix-cost
         buf_comp_fbr-line.price-base
         buf_comp_fbr-line.price-rubl
         buf_comp_fbr-line.price-sum-base
         buf_comp_fbr-line.price-sum-rubl
         buf_comp_fbr-line.price-sum-vat-base
         buf_comp_fbr-line.price-sum-vat-rubl
         with browse br-comp.
      if error-status :error
         then
      do:
         undo, return no-apply.
      end.
   END.
ON VALUE-CHANGED OF br-comp IN FRAME D-FBR-DOC
   DO:
      display
         ? @ ub.fbr-recipe.recipe-code
         ? @ ub.fbr-recipe.recipe-type
         ? @ ub.fbr-recipe.recipe-name
         ? @ ub.fbr-recipe.qnty
         ? @ effect
         with frame D-FBR-DOC.
      if available buf_comp_fbr-line
         then
      do:
         assign
            v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
            .
         run fill-recipe-fields in this-procedure (
            input buf_comp_fbr-line.recipe-code
            ) .
         run get-effect in this-procedure (
            input buf_comp_fbr-line.recipe-code
            , input f-doc.doc-code
            , output effect
            ).
         display
            effect
            with frame D-FBR-DOC.
      end.
      if lookup (rs-one-all, "all,type,goods") > 0
         then
      do:
      end.
      else
      do:
         run open-ingr in this-procedure (
            input ( if available buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ? )
            ) .
      end.
   END.
ON ENTRY OF br-ingr IN FRAME D-FBR-DOC
   DO:
      current-browse = br-ingr:handle.
   END.
ON ROW-DISPLAY OF br-ingr IN FRAME D-FBR-DOC
   DO:
      if buf_ingr_fbr-line.is-waste = yes
         then
      do:
         assign
            buf_ingr_fbr-line.artic                 :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.recipe-code           :bgcolor in browse br-ingr = gray_color
            ingr-name                               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.trn-type              :bgcolor in browse br-ingr = gray_color
            ingr-OK                                 :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.fact-qnty             :bgcolor in browse br-ingr = gray_color
            ingr-unit                               :bgcolor in browse br-ingr = gray_color
            ingr-prod                               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.is-calc               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sale            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.fix-cost              :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.coeff-waste           :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.coeff-value           :bgcolor in browse br-ingr = gray_color
            ingr-netto                              :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-rubl            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-base            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-rubl        :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-base        :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-vat-rubl    :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-vat-base    :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.rsrv-qnty             :bgcolor in browse br-ingr = gray_color
            .
      end.
   END.
ON ROW-LEAVE OF br-ingr IN FRAME D-FBR-DOC
   DO:
      if available buf_ingr_fbr-line
         and browse br-ingr:current-row-modified
         then
      do:
         run assign-ingr-line in this-procedure (
            rowid( buf_ingr_fbr-line )
            , input browse br-ingr buf_ingr_fbr-line.fact-qnty
            , input browse br-ingr buf_ingr_fbr-line.is-calc
            , input browse br-ingr buf_ingr_fbr-line.price-sale
            , input browse br-ingr buf_ingr_fbr-line.fix-cost
            , input browse br-ingr buf_ingr_fbr-line.price-rubl
            , input browse br-ingr buf_ingr_fbr-line.price-base
            , input browse br-ingr buf_ingr_fbr-line.price-sum-vat-rubl
            , input browse br-ingr buf_ingr_fbr-line.price-sum-vat-base
            ) no-error.
         if error-status :error
            then
         do:
            message
               vss-workfile vss-revision vss-description
               skip(1)
               skip
               "Ошибка записи строки ингредиента"
               skip
               "документа производства"
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box error.
            undo, return no-apply .
         end.
         display
            buf_ingr_fbr-line.is-calc
            buf_ingr_fbr-line.price-sale
            buf_ingr_fbr-line.price-base
            buf_ingr_fbr-line.price-rubl
            buf_ingr_fbr-line.price-sum-base
            buf_ingr_fbr-line.price-sum-rubl
            buf_ingr_fbr-line.price-sum-vat-base
            buf_ingr_fbr-line.price-sum-vat-rubl
            buf_ingr_fbr-line.fix-cost
            with browse br-ingr.
         browse br-ingr :refresh().
      end.
   END.
ON VALUE-CHANGED OF br-ingr IN FRAME D-FBR-DOC
   DO:
      define variable v-gds-name           as character no-undo.
      define variable v-gds-type           as character no-undo.
      define variable v-recipe-type        as character no-undo.
      define variable v-recipe-qnty        as decimal   no-undo.
      define variable v-recipe-brutto-qnty as decimal   no-undo.
      define variable v-recipe-coeff-value as decimal   no-undo.
      define variable v-recipe-coeff-waste as decimal   no-undo.
      define variable v-recipe-waste       as logical   no-undo.
      display
         ?   @ ingr-long
         ?   @ ub.fbr-recipe-gds.qnty
         no  @ ub.fbr-recipe-gds.is-waste
         ""  @ ingr-goods-type
         with frame D-FBR-DOC.
      if available buf_ingr_fbr-line
         then
      do:
         run get-ingr-line-parameters in this-procedure (
            input buf_ingr_fbr-line.recipe-code
            , input buf_ingr_fbr-line.artic
            , input buf_ingr_fbr-line.prod-type
            , input buf_ingr_fbr-line.prod-code
            , output v-gds-name
            , output v-gds-type
            , output v-recipe-type
            , output v-recipe-qnty
            , output v-recipe-brutto-qnty
            , output v-recipe-coeff-value
            , output v-recipe-coeff-waste
            , output v-recipe-waste
            ) .
         if v-recipe-type = 'разделка':U
            and v-recipe-waste = no
            then
         do:
            if v-base = yes
               then
            do:
               assign
                  buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = no
                  .
            end.
            else
            do:
               assign
                  buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = no
                  .
            end.
         end.
         else
         do:
            assign
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = yes
               .
         end.
         if not( v-cntxt-db-num-obj = v-cntxt-db-num )
            and ( v-cntxt-db-num-obj <> 0 )
            then
         do:
            assign
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               .
         end.
         run fill-recipe-fields in this-procedure (
            input buf_ingr_fbr-line.recipe-code
            ).
         display
            v-gds-name              @ ingr-long
            v-gds-type              @ ingr-goods-type
            v-recipe-brutto-qnty    @ fbr-recipe-gds.qnty
            v-recipe-waste          @ fbr-recipe-gds.is-waste
            with frame D-FBR-DOC.
      end.
   END.
ON LEAVE OF fi-pay-code IN FRAME D-FBR-DOC
   DO:
      define buffer buf_pay-type for ub.pay-type.
      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = integer( fi-pay-code :screen-value )
         no-error.
      if not available buf_pay-type
         then
      do:
         message
            "Введите код оплаты, определённый в справочнике"
            skip
            "кодов оплат."
            view-as alert-box.
         undo, return no-apply.
      end.
      else
      do:
         assign
            fi-pay-code
            .
         run get-pay-type-name in this-procedure (
            input fi-pay-code
            , output fi-pay-type-name
            ).
         display
            fi-pay-type-name
            with frame D-FBR-DOC.
      end.
   END.
ON CHOOSE OF b-add-marks in frame D-FBR-DOC
do :
  if available buf_ingr_fbr-line
  then do :
    run str/fbr-doc-ingr-marks-add.w (input parparentproc,
                                 input recid(buf_ingr_fbr-line)) .
    br-ingr:refresh () .
  end .
end .
ON CHOOSE OF MENU-ITEM m-all-add
   DO:
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-fbr-doc .
  if focus :handle <> b-add :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run add-proc in this-procedure (
         input "rcp-all"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка добавления товаров по всем связанным рецептам."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
   END.
ON CHOOSE OF MENU-ITEM m-all-del
   DO:
      define variable v-deleted as logical no-undo.
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-fbr-doc .
  if focus :handle <> b-del :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run del-proc in this-procedure ( input "all", output v-deleted ).
      if v-deleted = yes
         then
      do:
         run UI-on ("line").
      end.
   END.
ON CHOOSE OF MENU-ITEM m-all-doc-del
   DO:
      define variable v-deleted as logical no-undo.
define variable vss-include-info71 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-fbr-doc .
  if focus :handle <> b-del :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run del-proc in this-procedure ( input "all-doc", output v-deleted ).
      if v-deleted = yes
         then
      do:
         run UI-on ("line").
      end.
   END.
ON CHOOSE OF MENU-ITEM m-comp-add
   DO:
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-fbr-doc .
  if focus :handle <> b-add :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_free':U
    ,input  'object':U
    ,input  f-doc.host-code
    ,input  f-doc.obj-type
    ,input  f-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-fbr-doc-g-log
    )  .
end.
      if v-fbr-doc-g-log <> yes
         then
      do:
         undo, return no-apply.
      end.
      run add-proc in this-procedure (
         input "up"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка добавления товара без рецепта в верхний список."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = yes
         .
      run hide-not-avail-menu-items in this-procedure ( input yes ).
   END.
ON CHOOSE OF MENU-ITEM m-comp-del
   DO:
      define variable v-deleted as logical no-undo.
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-fbr-doc .
  if focus :handle <> b-del :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run del-proc in this-procedure ( input "up", output v-deleted ).
      if v-deleted = yes
         then
      do:
         run UI-on ("line").
      end.
   END.
ON CHOOSE OF MENU-ITEM m-doc
   DO:
      define variable loc-ref-list as character no-undo.
      define variable i            as integer   no-undo .
      run str/all-docs.w (
         input parparentproc,
         input v-cntxt-host-code-obj ,
         input v-cntxt-obj-type ,
         input v-cntxt-obj-code ,
         input 'выбор':U,
         input ?,
         input ?,
         input ?,
         input ?,
         input "b-sel,b-mark":U,
         input ?,
         input ?,
         input ?,
         output loc-ref-list ) NO-ERROR.
      if loc-ref-list = ""  then
      do:
         message
            "Ничего не отметили в списке заказов !"
            view-as alert-box information .
         display
            ? @ out-code
            with frame D-FBR-DOC.
         apply "entry" to b-add in frame D-FBR-DOC.
         return no-apply.
      end.
      if num-entries( loc-ref-list ) = 0
         or loc-ref-list = ""
         or error-status:error
         then
      do:
         display
            ? @ out-code
            with frame D-FBR-DOC.
         apply "entry" to b-add in frame D-FBR-DOC.
         return no-apply.
      end.
      else
      do:
if session :set-wait-state( "compiler" ) then.
         repeat i = 1 to  num-entries( loc-ref-list ) :
            find first ub.trn-doc no-lock
               where recid( ub.trn-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
            display
               ub.trn-doc.doc-code @ out-code
               with frame D-FBR-DOC.
            run str/fbr-copy.p (
               input parparentproc
               , input f-doc.doc-code
               , input trn-doc.doc-code
               , input f-doc.obj-type
               , input f-doc.obj-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , input p-fbrhist-handle
               ) no-error.
            if error-status :error
               then
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip(1)
                  skip
                  "Ошибка копирования накладной в документ производства."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
               undo, return no-apply.
            end.
         end.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
      run UI-on in this-procedure ( input "line" ).
if session :set-wait-state( "" ) then.
      return no-apply.
   END.
ON CHOOSE OF MENU-ITEM m-doc-rsrv
   DO:
      define variable v-reserved as logical no-undo.
define variable vss-include-info75 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rsrv :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rsrv in frame d-fbr-doc .
  if focus :handle <> b-rsrv :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run str/fbr-rsrv.p (
         input parparentproc
         , input ?
         , input recid( f-doc )
         , input no
         , input no
         , input no
         , input no
         , output v-reserved
         ) no-error.
      if error-status:error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка резервирования товара по всему документу."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply.
      end.
      if v-reserved = yes
         then
      do:
         assign
            f-doc.status_ = 'разрешен':U
            .
      end.
      run UI-on in this-procedure ( input "line" ).
if session :set-wait-state( "" ) then.
   END.
ON CHOOSE OF MENU-ITEM m-ingr-add
   DO:
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-fbr-doc .
  if focus :handle <> b-add :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
define variable vss-include-info77 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_free':U
    ,input  'object':U
    ,input  f-doc.host-code
    ,input  f-doc.obj-type
    ,input  f-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-fbr-doc-g-log
    )  .
end.
      if v-fbr-doc-g-log <> yes
         then
      do:
         undo, return no-apply.
      end.
      run add-proc in this-procedure (
         input "down"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка добавления товара без рецепта в нижний список."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = yes
         .
      run hide-not-avail-menu-items in this-procedure ( input yes ).
   END.
ON CHOOSE OF MENU-ITEM m-ingr-del
   DO:
      define variable v-deleted as logical no-undo.
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-fbr-doc .
  if focus :handle <> b-del :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run del-proc in this-procedure ( input "down", output v-deleted ).
      if v-deleted = yes
         then
      do:
         run UI-on ("line").
      end.
   END.
ON CHOOSE OF MENU-ITEM m-ord
   DO:
      define variable i            as integer   no-undo .
      define variable loc-ref-list as character no-undo.
      run ref/all-zakz.w
         ( input   parParentProc
         ,input   ?
         ,input   ?
         ,input   "firmord"
         ,input   ""
         ,input   "b-sel,b-mark"
         ,input   ""
         ,output  loc-ref-list ) no-error .
      if loc-ref-list = ""  then
      do:
         message "Ни чего не отметили в списке заказов !"
            view-as alert-box information .
         display
            ? @ out-code
            with frame D-FBR-DOC.
         apply "entry" to b-add in frame D-FBR-DOC.
         return no-apply.
      end.
      if num-entries( loc-ref-list ) = 0
         or loc-ref-list                = ""
         or error-status :error
         then
      do:
         display
            ? @ out-code
            with frame D-FBR-DOC.
         apply "entry" to b-add in frame D-FBR-DOC.
         return no-apply.
      end.
      else
      do:
if session :set-wait-state( "compiler" ) then.
         repeat i = 1 to  num-entries( loc-ref-list ) :
            find first ub.ord-doc no-lock
               where recid( ub.ord-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
            display
               ub.ord-doc.doc-code @ out-code
               with frame D-FBR-DOC.
            run cus/ord-copy.p (
               input parparentproc
               , input f-doc.doc-code
               , input ub.ord-doc.doc-code
               , input f-doc.obj-type
               , input f-doc.obj-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , input p-fbrhist-handle
               ) no-error.
            if error-status :error
               then
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip(1)
                  skip
                  "Ошибка копирования заказа в документ производства."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
               undo, return no-apply.
            end.
         end.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
      run UI-on in this-procedure ( input "line" ).
if session :set-wait-state( "" ) then.
      return no-apply.
   END.
ON CHOOSE OF MENU-ITEM m-rcp-add
   DO:
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-fbr-doc .
  if focus :handle <> b-add :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run add-proc in this-procedure (
         input "rcp"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка добавления товара с рецептом."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      do transaction
         on error undo, return no-apply
         :
         assign
            f-doc.is-free = no
            .
      end.
      run hide-not-avail-menu-items in this-procedure (
         input no
         ).
   END.
ON CHOOSE OF MENU-ITEM m-rcp-del
   DO:
      define variable v-deleted as logical no-undo.
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-fbr-doc .
  if focus :handle <> b-del :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      run del-proc in this-procedure ( input "rcp", output v-deleted ).
      if v-deleted = yes
         then
      do:
         run UI-on ("line").
      end.
   END.
ON CHOOSE OF MENU-ITEM m-rcp-rsrv
   DO:
define variable vss-include-info81 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rsrv :type in frame d-fbr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-fbr-doc skip
    "Тип" self :type in frame d-fbr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rsrv in frame d-fbr-doc .
  if focus :handle <> b-rsrv :handle in frame d-fbr-doc then do:
    return no-apply .
  end.
end.
      if not available buf_comp_fbr-line
         then
      do:
         message
            "Неправильно выбрана строка составного товара."
            view-as alert-box error.
         return no-apply.
      end.
      run str/fbr-rcp.p (
         input parparentproc
         , input p-fbrhist-handle
         , input p-fbr-doc-recid
         , input no
         , input buf_comp_fbr-line.recipe-code
         , input no
         , input no
         ) no-error.
      if error-status:error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка расчета рецепта. "
            skip
            "Рецепт: " buf_comp_fbr-line.recipe-code
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         return no-apply.
      end.
      run fbrlib-fill-sum-fbr-doc in this-procedure (
         input p-fbr-doc-recid
         , input 'reserv':U
         ) no-error.
      if error-status:error then
      do:
         message
            substitute("Ошибка при расчете шапки документа пр-ва&1&2&1&3"
            , chr(10)
            , error-status:get-message(1)
            , return-value )
            view-as alert-box error .
      end.
      run UI-on in this-procedure ( input "line" ).
if session :set-wait-state( "" ) then.
   END.
ON CHOOSE OF MENU-ITEM m-sale
   DO:
      define variable v-user-select as logical   no-undo .
      define variable v-obj-type    as character no-undo .
      define variable v-obj-code    as integer   no-undo .
      define variable v-rid-list    as character no-undo .
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(r-outs :type in frame D-FBR-DOC
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame D-FBR-DOC skip
    "Тип" self :type in frame D-FBR-DOC skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to r-outs in frame D-FBR-DOC .
  if focus :handle <> r-outs :handle in frame D-FBR-DOC then do:
    return no-apply .
  end.
end.
      assign
         v-fbr-doc-g-log = yes
         .
      message
         "Выберите объект для поиска незакрытой продажи" skip
         view-as alert-box question
         buttons OK-Cancel
         update v-fbr-doc-g-log.
      if not v-fbr-doc-g-log
         then
      do:
         return no-apply.
      end.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
      if v-user-select <> true
         then
      do:
         return no-apply .
      end.
      run str/salelist.w
         (input  parparentproc
         ,input  "b-sel"
         ,input  'новый':U
         ,input  0
         ,input  v-obj-type
         ,input  v-obj-code
         ,input-output v-rid-list
         ).
      if v-rid-list = ""
         then
      do:
         return no-apply.
      end.
      find first ub.inkas no-lock
         where recid(ub.inkas) = integer(v-rid-list)
         no-error.
      if not available ub.inkas
         then
      do:
         message
            "На выбранном объекте не найдена незакрытая продажа."
            view-as alert-box error.
         return no-apply.
      end.
      display ub.inkas.inkas-code @ out-code with frame D-FBR-DOC.
      apply "entry" to out-code in frame D-FBR-DOC.
      apply 'Return':U to out-code in frame D-FBR-DOC.
   END.
ON RETURN OF out-code IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info84 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      find first ub.trn-doc no-lock
         where ub.trn-doc.doc-code = input frame D-FBR-DOC out-code
         no-error.
      if not available ub.trn-doc
         then
      do:
         apply "choose" to r-outs in frame D-FBR-DOC.
         return no-apply.
      end.
      run str/fbr-copy.p (
         input parparentproc
         , input f-doc.doc-code
         , input ub.trn-doc.doc-code
         , input f-doc.obj-type
         , input f-doc.obj-code
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input p-fbrhist-handle
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Ошибка копирования накладной в документ производства."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box error.
         undo, return no-apply.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure (
         input no
         ).
      run UI-on in this-procedure ( input "line" ).
      return no-apply.
   END.
ON CHOOSE OF r-fbroperator IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info85 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      run select-fbroperator in this-procedure (
         output obj-fbroperator
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Ошибка выбора оператора документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply .
      end.
      display
         obj-fbroperator
         with frame D-FBR-DOC.
   END.
ON CHOOSE OF r-pay IN FRAME D-FBR-DOC
   DO:
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
      run select-fbrpaycode in this-procedure (
         input fi-pay-code
         , output fi-pay-code
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Ошибка выбора кода оплаты документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply .
      end.
      run get-pay-name in this-procedure (
         input fi-pay-code
         , output fi-pay-type-name
         ).
      display
         fi-pay-code
         fi-pay-type-name
         with frame D-FBR-DOC.
   END.
ON row-display OF br-ingr IN FRAME D-FBR-DOC
DO:
  run rowdisp .
END.
ON CHOOSE OF r-price IN FRAME D-FBR-DOC
   DO:
      define variable v-user-select as logical   no-undo .
      define variable v-obj-type    as character no-undo .
      define variable v-obj-code    as integer   no-undo .
define variable vss-include-info87 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
      if v-user-select <> true
         then
      do:
         return no-apply .
      end.
      assign
         v-price-sale-obj-type = v-obj-type
         v-price-sale-obj-code = v-obj-code
         .
      run UI-on in this-procedure ( input "line" ).
      return no-apply.
   END.
ON VALUE-CHANGED OF rs-one-all IN FRAME D-FBR-DOC
   DO:
      assign
         rs-one-all
         .
      run assign-current-goods.
      run UI-on ("enable").
   END.
ON CHOOSE OF shift-sel IN FRAME D-FBR-DOC
   DO:
      run proc-sht.
   END.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame D-FBR-DOC anywhere do:
  run get-goods-recid.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-comp in frame D-FBR-DOC.
  return no-apply.
end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
   if objSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
ON CHOOSE OF b-next IN FRAME D-FBR-DOC
   DO:
      if valid-handle (br-handle) then
      do:
         v-fbr-doc-g-log = br-handle:select-next-row().
         if not v-fbr-doc-g-log then message "Это последний документ списка.".
      end.
      assign
         p-fbr-doc-recid     = recid( f-doc )
         p-new-fbr-doc-recid = p-fbr-doc-recid
         p-fbr-doc-next-prev = yes
         .
   END.
ON CHOOSE OF b-prev IN FRAME D-FBR-DOC
   DO:
      if valid-handle (br-handle) then
      do:
         v-fbr-doc-g-log = br-handle:select-prev-row().
         if not v-fbr-doc-g-log then message "Это первый документ списка.".
      end.
      assign
         p-fbr-doc-recid     = recid( f-doc )
         p-new-fbr-doc-recid = p-fbr-doc-recid
         p-fbr-doc-next-prev = yes
         .
   END.
on return, mouse-select-dblclick of buf_comp_fbr-line.is-calc in browse br-comp
   do:
      buf_comp_fbr-line.is-calc:screen-value in browse br-comp =
         string ((buf_comp_fbr-line.is-calc:screen-value in browse br-comp = "-"), buf_comp_fbr-line.is-calc:format in browse br-comp).
      return no-apply.
   end.
on return, mouse-select-dblclick of buf_ingr_fbr-line.is-calc in browse br-ingr
   do:
      buf_ingr_fbr-line.is-calc:screen-value in browse br-ingr =
         string ((buf_ingr_fbr-line.is-calc:screen-value in browse br-ingr = "-"), buf_ingr_fbr-line.is-calc:format in browse br-ingr).
      return no-apply.
   end.
on return, mouse-select-dblclick of buf_comp_fbr-line.fix-cost in browse br-comp
   do:
      buf_comp_fbr-line.fix-cost:screen-value in browse br-comp =
         string ((buf_comp_fbr-line.fix-cost:screen-value in browse br-comp = "-"), buf_comp_fbr-line.fix-cost:format in browse br-comp).
      return no-apply.
   end.
on return, mouse-select-dblclick of buf_ingr_fbr-line.fix-cost in browse br-ingr
   do:
      buf_ingr_fbr-line.fix-cost:screen-value in browse br-ingr =
         string ((buf_ingr_fbr-line.fix-cost:screen-value in browse br-ingr = "-"), buf_ingr_fbr-line.fix-cost:format in browse br-ingr).
      return no-apply.
   end.
on value-changed of fact-date in frame D-FBR-DOC
   do:
      assign frame D-FBR-DOC fact-date no-error.
      f-doc.fact-date = fact-date.
   end.
PROCEDURE proc-sht :
   define buffer bf_shift-obj for ub.shift-obj.
   define variable varrid-list as character no-undo.
   define variable varrecid    as recid     no-undo.
   assign
      varrid-list = "".
   run str/sht-all.w (parparentproc, f-doc.obj-type, f-doc.obj-code, 'b-sel', 'obj',f-doc.obj-type, f-doc.obj-code, '':u, input-output varrid-list) no-error.
   if error-status:error or varrid-list = "":u then
   do:
      return.
   end.
   else
   do:
      assign
         varrecid = integer (entry(1, varrid-list)).
      find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
      if available bf_shift-obj then
      do:
         assign
            f-doc.shift-date = bf_shift-obj.shift-date
            f-doc.shift-num  = bf_shift-obj.shift-num
            f-doc.shift-name = bf_shift-obj.shift-name.
         shift = subst("&1 &2 &3", f-doc.shift-date, f-doc.shift-num, f-doc.shift-name ).
         display shift f-doc.shift-date f-doc.shift-num f-doc.shift-name with frame D-FBR-DOC.
         assign
            f-doc.fact-date = f-doc.shift-date
            fact-date       = f-doc.shift-date.
         display fact-date with frame D-FBR-DOC.
      end.
   end.
END PROCEDURE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME D-FBR-DOC:PARENT eq ?
   THEN FRAME D-FBR-DOC:PARENT = ACTIVE-WINDOW.
assign
   p-new-fbr-doc-recid = p-fbr-doc-recid
   .
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame D-FBR-DOC
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
on choose of b-help in frame D-FBR-DOC
do:
  apply "help":u to frame D-FBR-DOC .
end.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame D-FBR-DOC:width - 0.3
                fh            = frame D-FBR-DOC:first-child
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
def var sort-labelbr-comp   as character no-undo .
def var sort-clmnbr-comp    as handle    no-undo .
def var cur-clmnbr-comp     as handle    no-undo .
def var cur-clmn-locbr-comp as integer   no-undo .
def var re-querybr-comp     as logical   initial no no-undo .
on start-search, ctrl-o of br-comp in frame D-FBR-DOC do:
   run sort-brbr-comp
     (input (if available buf_comp_fbr-line
             then recid(buf_comp_fbr-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-comp :
  define input parameter p-recid as recid no-undo .
  if re-querybr-comp = no then do:
    assign
       cur-clmnbr-comp = br-comp:current-column in frame D-FBR-DOC
    .
    if sort-clmnbr-comp <> ? then sort-clmnbr-comp:column-fgcolor = 0.
    if cur-clmnbr-comp = sort-clmnbr-comp then do:
      assign
         sort-labelbr-comp = ""
         sort-clmnbr-comp = ?
      .
     end.
     else do:
       assign
         sort-labelbr-comp = cur-clmnbr-comp:label
         sort-clmnbr-comp  = cur-clmnbr-comp
         sort-clmnbr-comp:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-comp = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-comp:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-comp then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-comp = cur-clmn-locbr-comp + 1
    .
  end.
  case sort-labelbr-comp:
        when comp-name:label in browse br-comp then DO:   assign       comp-sort-column-name = substitute('dynamic-function(&1get-goods-name&1,recid(buf_comp_fbr-line))',chr(34))     .     run open-comp.   . END.
        when buf_comp_fbr-line.trn-type:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.trn-type"     .     run open-comp.   . END.
        when comp-OK:label in browse br-comp then DO:   assign       comp-sort-column-name = substitute('dynamic-function(&1get-line-OK&1,recid(buf_comp_fbr-line))',chr(34))     .     run open-comp.   . END.
        when buf_comp_fbr-line.fact-qnty:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.fact-qnty"     .     run open-comp.   . END.
        when comp-unit:label in browse br-comp then DO:   assign       comp-sort-column-name = substitute('dynamic-function(&1get-unit-base&1,recid(buf_comp_fbr-line))',chr(34))     .     run open-comp.   . END.
        when buf_comp_fbr-line.is-calc:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.is-calc"     .     run open-comp.   . END.
        when buf_comp_fbr-line.price-sale:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.price-sale"     .     run open-comp.   . END.
        when buf_comp_fbr-line.fix-cost:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.fix-cost"     .     run open-comp.   . END.
        when buf_comp_fbr-line.price-base:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.price-base"     .     run open-comp.   . END.
        when buf_comp_fbr-line.price-rubl:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.price-rubl"     .     run open-comp.   . END.
        when buf_comp_fbr-line.rsrv-qnty:label in browse br-comp then DO:    assign       comp-sort-column-name = "buf_comp_fbr-line.rsrv-qnty"     .     run open-comp.   . END.
        when comp-prod:label in browse br-comp then DO:   assign       comp-sort-column-name = substitute('dynamic-function(&1get-prod-ref&1,recid(buf_comp_fbr-line))',chr(34))     .     run open-comp.   . END.
    otherwise do:
      assign
        comp-sort-column-name = ""
      .
      run open-comp.
      if sort-labelbr-comp <> "" then do:
        assign
          cur-clmnbr-comp:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-comp = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-comp to recid p-recid no-error.
    apply "value-changed" to br-comp in frame D-FBR-DOC.
  end.
  apply "entry" to br-comp in frame D-FBR-DOC.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-comp:
if cur-clmnbr-comp = ? then do:
   run open-comp.
end.
else do:
   assign re-querybr-comp = yes.
   run sort-brbr-comp
     (input (if available buf_comp_fbr-line
             then recid(buf_comp_fbr-line)
             else ?
            )
     ).
   assign re-querybr-comp = no.
end.
end.
def var sort-labelbr-ingr   as character no-undo .
def var sort-clmnbr-ingr    as handle    no-undo .
def var cur-clmnbr-ingr     as handle    no-undo .
def var cur-clmn-locbr-ingr as integer   no-undo .
def var re-querybr-ingr     as logical   initial no no-undo .
on start-search, ctrl-o of br-ingr in frame D-FBR-DOC do:
   run sort-brbr-ingr
     (input (if available buf_ingr_fbr-line
             then recid(buf_ingr_fbr-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-ingr :
  define input parameter p-recid as recid no-undo .
  if re-querybr-ingr = no then do:
    assign
       cur-clmnbr-ingr = br-ingr:current-column in frame D-FBR-DOC
    .
    if sort-clmnbr-ingr <> ? then sort-clmnbr-ingr:column-fgcolor = 0.
    if cur-clmnbr-ingr = sort-clmnbr-ingr then do:
      assign
         sort-labelbr-ingr = ""
         sort-clmnbr-ingr = ?
      .
     end.
     else do:
       assign
         sort-labelbr-ingr = cur-clmnbr-ingr:label
         sort-clmnbr-ingr  = cur-clmnbr-ingr
         sort-clmnbr-ingr:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-ingr = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-ingr:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-ingr then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-ingr = cur-clmn-locbr-ingr + 1
    .
  end.
  case sort-labelbr-ingr:
        when ingr-name:label in browse br-ingr then DO:   assign       ingr-sort-column-name = substitute('dynamic-function(&1get-goods-name&1,recid(buf_ingr_fbr-line))',chr(34))     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.trn-type:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.trn-type"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when ingr-OK:label in browse br-ingr then DO:   assign       ingr-sort-column-name = substitute('dynamic-function(&1get-line-OK&1,recid(buf_ingr_fbr-line))',chr(34))     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.fact-qnty:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.fact-qnty"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when ingr-unit:label in browse br-ingr then DO:   assign       ingr-sort-column-name = substitute('dynamic-function(&1get-unit-base&1,recid(buf_ingr_fbr-line))',chr(34))     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.is-calc:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.is-calc"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.price-sale:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.price-sale"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.fix-cost:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.fix-cost"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.price-base:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.price-base"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.price-rubl:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.price-rubl"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when buf_ingr_fbr-line.rsrv-qnty:label in browse br-ingr then DO:    assign       ingr-sort-column-name = "buf_ingr_fbr-line.rsrv-qnty"     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
        when ingr-prod:label in browse br-ingr then DO:   assign       ingr-sort-column-name = substitute('dynamic-function(&1get-prod-ref&1,recid(buf_ingr_fbr-line))',chr(34))     .     run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).   . END.
    otherwise do:
      assign
        ingr-sort-column-name = ""
      .
      run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).
      if sort-labelbr-ingr <> "" then do:
        assign
          cur-clmnbr-ingr:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-ingr = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-ingr to recid p-recid no-error.
    apply "value-changed" to br-ingr in frame D-FBR-DOC.
  end.
  apply "entry" to br-ingr in frame D-FBR-DOC.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-ingr:
if cur-clmnbr-ingr = ? then do:
   run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?).
end.
else do:
   assign re-querybr-ingr = yes.
   run sort-brbr-ingr
     (input (if available buf_ingr_fbr-line
             then recid(buf_ingr_fbr-line)
             else ?
            )
     ).
   assign re-querybr-ingr = no.
end.
end.
delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input 'nakl_par':U
   ,input  "back-date"
   ,output v-value-character
   ,output v-value-date
   ,output v-value-decimal
   ,output v-value-integer
   ,output v-back-date
   ,output v-back-date-type
   ,INPUT-OUTPUT table-handle v-tth
   ) no-error .
if error-status :error  then v-back-date = false .
delete object v-tth no-error.
if error-status:error then v-back-date = false.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request'
  ,output is-shift-on
  ) no-error .
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of fact-date in frame D-FBR-DOC
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of fact-date in frame D-FBR-DOC
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of fact-date in frame D-FBR-DOC
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of fact-date in frame D-FBR-DOC
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of fact-date in frame D-FBR-DOC
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of fact-date in frame D-FBR-DOC
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date97
    MENU-ITEM m-ed-date97-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date97-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date97-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date97-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fact-date :POPUP-MENU in frame D-FBR-DOC = ?
  then do:
    ASSIGN
      fact-date :POPUP-MENU in frame D-FBR-DOC = MENU m-ed-date97 :HANDLE
      fact-date :MENU-MOUSE in frame D-FBR-DOC = 3
    .
  end.
  define variable v-label-handle97 as handle no-undo .
  assign
    v-label-handle97 = fact-date :side-label-handle in frame D-FBR-DOC
  .
  if valid-handle (v-label-handle97)
  then do:
    if v-label-handle97 :tooltip = ""
    or v-label-handle97 :tooltip = ?
    then do:
      assign
        v-label-handle97 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date97-1 in menu m-ed-date97 DO:
    apply "ctrl-b":U to fact-date in frame D-FBR-DOC .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date97-2 in menu m-ed-date97 DO:
    apply "ctrl-d":U to fact-date in frame D-FBR-DOC .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date97-3 in menu m-ed-date97 DO:
    apply "ctrl-e":U to fact-date in frame D-FBR-DOC .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date97-4 in menu m-ed-date97 DO:
    apply "ctrl-f":U to fact-date in frame D-FBR-DOC .
  END.
hbrowse = browse br-ingr:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).
  bcol[ii] = hbrowse:get-browse-column (ii).
end.
hbrowse_comp = browse br-comp:handle.
extent (bcol_comp) = hbrowse_comp:num-columns.
bcol_comp[1] = hbrowse_comp:first-column.
do ii = 1 to extent (bcol_comp).
  bcol_comp[ii] = hbrowse_comp:get-browse-column (ii).
end.
assign
   p-fbr-doc-next-prev = yes
   .
n-p:
do while p-fbr-doc-next-prev
   :
   MAIN-BLOCK:
   DO
      ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      :
      run writelog in this-procedure (log-file-name, 0, "&DLine").
      run writelog in this-procedure (log-file-name, 1, "Запуск блока Производства").
      if p-doc-mode <> 'ДОБАВЛЕНИЕ':U
         then
      do:
         define variable v-fbroperator-string as character no-undo.
         define variable v-fbrpaycode-string  as character no-undo.
         run str/fbrattrv.p (
            input f-doc.doc-code
            , input 'fbroperator':U
            , output v-fbroperator-string
            ) no-error.
         if error-status :error
            then
         do:
            message
               vss-workfile vss-revision vss-description
               skip(1)
               skip
               "Ошибка определения оператора производства."
               skip(1)
               skip
               "Выберите ответственного за операции производства."
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box warning.
            assign
               v-fbr-doc-fbroperator-code = 0
               .
         end.
         assign
            v-fbr-doc-fbroperator-code = integer( v-fbroperator-string )
            no-error.
         if error-status :error
            then
         do:
            assign
               v-fbr-doc-fbroperator-code = 0
               .
         end.
         else
         do:
            define buffer buf_clients for ub.clients.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'чел':U
               and buf_clients.obj-code = v-fbr-doc-fbroperator-code
               no-error.
            if not available buf_clients
               then
            do:
               assign
                  v-fbr-doc-fbroperator-code = 0
                  .
            end.
         end.
         if f-doc.pay-code = ?
            or f-doc.pay-code = 0
            then
         do:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  f-doc.obj-type
  ,input  f-doc.obj-code
  ,output fi-pay-code
  )  .
         end.
         else
         do:
            assign
               fi-pay-code = f-doc.pay-code
               .
         end.
      end.
      run mode-on no-error.
      if error-status:error
         then
      do:
         undo, return error.
      end.
      if p-doc-mode = 'ИЗМЕНЕНИЕ':U
         then
      do:
         run hide-not-avail-menu-items in this-procedure (
            input f-doc.is-free
            ).
      end.
      if p-doc-mode = 'ДОБАВЛЕНИЕ':U
         then
      do:
         assign
            p-doc-mode = 'ИЗМЕНЕНИЕ':U
            .
      end.
      assign
         rs-one-all            = "recipe":U
         v-fbr-doc-rep-rec     = ?
         v-price-sale-obj-type = v-cntxt-obj-type
         v-price-sale-obj-code = v-cntxt-obj-code
         .
      display f-doc.fact-date @ fact-date with frame D-FBR-DOC.
      shift = subst("&1 &2 &3", f-doc.shift-date, f-doc.shift-num, f-doc.shift-name).
      if f-doc.shift-date <> ? then
         display shift with frame D-FBR-DOC.
      run get-pay-type-name in this-procedure (
         input fi-pay-code
         , output fi-pay-type-name
         ).
      run UI-on in this-procedure (
         input "enable":U
         ).
      if v-fbr-doc-line-rec <> ?
         and p-doc-mode = 'ПРОСМОТР':U
         then
      do:
         reposition br-comp to recid v-fbr-doc-line-rec no-error.
      end.
      WAIT-FOR GO OF FRAME D-FBR-DOC focus br-comp.
   END.
end.
RUN disable_UI.
PROCEDURE add-free-fbr-line :
   do
      on error undo, return error
      :
      define input parameter p-browse         as character                no-undo.
      define input parameter p-price-obj-type like ub.clients.obj-type       no-undo.
      define input parameter p-price-obj-code like ub.clients.obj-code       no-undo.
      define variable vss-description            as character no-undo init "Добавление строк без рецепта.".
      define variable v-trn-type                 as character no-undo.
      define variable v-fbr-v-fbr-doc-line-recid as recid     no-undo.
      define variable v-cancel                   as logical   no-undo.
      define buffer buf_goods    for ub.goods.
      define buffer buf_gds-prt  for ub.gds-prt.
      define buffer buf_fbr-line for ub.fbr-line.
      if p-browse = "up"
         then
      do:
         assign
            v-trn-type = 'при':U
            .
      end.
      else
      do:
         assign
            v-trn-type = 'спи':U
            .
      end.
      find first buf_goods no-lock
         where recid( buf_goods ) = gds-rec
         .
      find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
         .
      if buf_goods.gds-type = 'у':U
         and v-trn-type = 'при':U
         then
      do:
         message
            "Невозможно добавить услугу в приход."
            skip(1) "Услуга:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      end.
      if buf_goods.stts <> 0
         then
      do:
         message
            "Невозможно добавить в документ удаленный товар."
            skip(1) "Товар:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      END.
      find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = f-doc.doc-code
         and buf_fbr-line.trn-type    <> v-trn-type
         and buf_fbr-line.recipe-code = ""
         and buf_fbr-line.artic       = buf_goods.artic
         and buf_fbr-line.prod-type   = buf_goods.prod-type
         and buf_fbr-line.prod-code   = buf_goods.prod-code
         no-error.
      if available buf_fbr-line
         then
      do:
         assign
            v-fbr-doc-g-log = no
            .
         message
            "Выбранный для добавления товар уже есть в этом документе."
            skip
            "Ингредиенты не могут совпадать с получаемыми товарами !"
            skip(1) "Товар:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      end.
      run str/fbr-crln.p (
         input parparentproc
         , input p-fbr-doc-recid
         , input gds-rec
         , input ""
         , input v-trn-type
         , input ( p-browse = "up" )
         , input no
         , input p-price-obj-type
         , input p-price-obj-code
         , output v-fbr-v-fbr-doc-line-recid
         ).
      if p-browse = "up"
         then
      do:
         find first buf_fbr-line no-lock
            where recid (buf_fbr-line) = v-fbr-v-fbr-doc-line-recid
            .
         assign
            v-fbr-doc-line-rec = recid( buf_fbr-line )
            .
         run str/fbr-line.w (
            input p-fbrhist-handle
            , input 'ИЗМЕНЕНИЕ':U
            , input buf_fbr-line.doc-code
            , input v-fbr-doc-line-rec
            , input ?
            , output v-cancel
            ).
      end.
      else
      do:
         do transaction
            on error undo, return error
            :
            find first buf_fbr-line exclusive-lock
               where recid (buf_fbr-line) = v-fbr-v-fbr-doc-line-recid
               .
            assign
               v-fbr-doc-rep-rec      = recid( buf_fbr-line )
               buf_fbr-line.fact-qnty = 0
               .
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE add-proc :
   do transaction
      on error undo, return error
      :
      define input parameter p-mode                   as character    no-undo.
      define input parameter p-price-sale-obj-type    as character    no-undo.
      define input parameter p-price-sale-obj-code    as integer      no-undo.
      define variable v-goods-recid-list as character no-undo.
      define variable vss-description    as character no-undo init "add-proc: ".
      define variable v-value            as character no-undo .
      define variable v-type             as character no-undo .
      define variable v-attr-value as character no-undo .
      define variable v-attr-value-rec as character no-undo .
      define variable v-attr-type as character no-undo .
      define buffer buf_goods    for ub.goods.
      define buffer buf_fbr-line for ub.fbr-line.
      run str/chs-gds.w (
         input parparentproc
         , input f-doc.obj-type
         , input f-doc.obj-code
         , input '':U
         , input '':U
         , input "Строка документа № " + f-doc.doc-code
         , input 'объект':U
         , input ?
         , input ?
         , input ?
         , input ?
         , input-output v-artic
         , output v-goods-recid-list
         ) .
      if v-goods-recid-list <> ''
         then
      do:
         define variable v-line-counter as integer no-undo.
         assign
            v-fbr-doc-line-rec = ?
            v-line-counter     = 1
            .
         do while v-line-counter <= num-entries ( v-goods-recid-list )
            :
            assign
               gds-rec        = integer( entry ( v-line-counter, v-goods-recid-list ) )
               v-line-counter = v-line-counter + 1
               .
            find first buf_goods no-lock
               where recid( buf_goods ) = gds-rec
               .
            case p-mode
               :
               when "rcp"
               then
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 по рецепту.", buf_goods.artic ) ).
                     RUN gds-attr-value (
                          INPUT buf_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-attr-value,
                          OUTPUT v-attr-type
                          ).
                     v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, buf_goods.gds-code) .
                     if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-attr-value)
                     or v-isweighed
                     then do :
                       empty temp-table tt-marking-lines .
                       run str/fbr-doc-dish-marks-add.w (input parparentproc,
                                                         input gds-rec,
                                                         output table tt-marking-lines) .
                     end .
                     run add-recipe in this-procedure (
                        input f-doc.doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input no
                        ) no-error.
                     if error-status :error
                     then do:
                       undo, return error.
                     end.
                  end.
               when "rcp-all"
               then
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 по рецепту. Раскрутка.", buf_goods.artic ) ).
                     run add-recipe in this-procedure (
                        input f-doc.doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input yes
                        ) .
                  end.
               when "up"
               then
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 без рецепта в верхний список.", buf_goods.artic ) ).
                     run add-free-fbr-line in this-procedure (
                        input p-mode
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        ) .
                  end.
               when "down"
               then
                  do:
                     if v-ban-recipes then
                     do:
                        run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
                           , input  'mark-type':U
                           , output v-attr-value
                           , output v-attr-type
                           ) no-error .
                        if v-attr-value <> "" and v-attr-value <> "not-type" then
                        do:
                           message "Добавление маркированного товара в ингридиенты, запрещено"
                              view-as alert-box.
                           return .
                        end.
                     end.
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 без рецепта в нижний список.", buf_goods.artic ) ).
                     run add-free-fbr-line in this-procedure (
                        input p-mode
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        ) .
                     if rs-one-all = "recipe"
                        then
                     do:
                        find first buf_comp_fbr-line no-lock
                           where buf_comp_fbr-line.is-comp = yes
                           and buf_comp_fbr-line.doc-code = f-doc.doc-code
                           and buf_comp_fbr-line.recipe-code = ""
                           no-error.
                        if available buf_comp_fbr-line
                           then
                        do:
                           assign
                              v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        else
                        do:
                           assign
                              v-fbr-doc-line-rec = ?
                              .
                        end.
                     end.
                  end.
            end.
         end.
         run UI-on ("line").
      end.
   end.
END PROCEDURE.
PROCEDURE add-recipe :
   do
      on error undo, return error
      :
      define input parameter p-fbr-doc-doc-code   as character    no-undo.
      define input parameter p-artic              as character    no-undo.
      define input parameter p-prod-type          as character    no-undo.
      define input parameter p-prod-code          as integer      no-undo.
      define input parameter p-add-childs         as logical      no-undo.
      define variable v-same-good          as logical no-undo.
      define variable v-same-good-old-qnty as decimal no-undo.
      run create-initial-temp-goods in this-procedure (
         input p-fbr-doc-doc-code
         , input p-artic
         , input p-prod-type
         , input p-prod-code
         , input  ?
         , input ?
         , input ?
         , input ?
         , output v-same-good
         , output v-same-good-old-qnty
         ).
      run calc-not-calculated-goods in this-procedure (
         input parparentproc
         , input p-fbrhist-handle
         , input p-fbr-doc-doc-code
         , input v-same-good
         , input v-same-good-old-qnty
         , input no
         , input p-add-childs
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input no
         , input no
         ) no-error.
      if error-status :error
      then do:
        undo, return error.
      end.
      run writelog in this-procedure ( log-file-name, 2, "Добавление товаров завершено." ).
   end.
END PROCEDURE.
PROCEDURE adjust-changed-ingr-line :
   define input parameter p-doc-code               as character        no-undo.
   define input parameter p-recipe-code            as character        no-undo.
   define input parameter p-artic                  as character        no-undo.
   define input parameter p-prod-type              as character        no-undo.
   define input parameter p-prod-code              as integer          no-undo.
   define input parameter p-old-fact-qnty          as decimal          no-undo.
   define input parameter p-old-price-sale         as decimal          no-undo.
   define input parameter p-old-cost-base          as decimal          no-undo.
   define input parameter p-old-cost-rubl          as decimal          no-undo.
   define input parameter p-old-cost-sum-vat-base  as decimal          no-undo.
   define input parameter p-old-cost-sum-vat-rubl  as decimal          no-undo.
   define input parameter p-old-vat-coeff          as decimal          no-undo.
   define variable v-price-sale as decimal no-undo.
   define variable v-base-rate  as decimal no-undo.
   define variable v-base-scale as decimal no-undo.
   define variable v-today      as date    no-undo.
   define variable v-time       as integer no-undo.
   define buffer buf_fbr-line       for ub.fbr-line.
   define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_fbr-line
      with frame D-FBR-DOC
      on error undo, return error
      :
      find first buf_fbr-line exclusive-lock
         where buf_fbr-line.doc-code    = p-doc-code
         and buf_fbr-line.is-comp     = no
         and buf_fbr-line.recipe-code = p-recipe-code
         and buf_fbr-line.artic       = p-artic
         and buf_fbr-line.prod-type   = p-prod-type
         and buf_fbr-line.prod-code   = p-prod-code
         .
      if p-old-fact-qnty <> buf_fbr-line.fact-qnty
         then
      do:
         assign
            buf_fbr-line.calc-method = 1
            .
         display
            get-netto-qnty(recid(buf_fbr-line)) @ ingr-netto
            with browse br-ingr .
      end.
      case f-doc.status_
         :
         when 'новый':U
         then
            do:
               if buf_fbr-line.price-sale <> p-old-price-sale
                  then
               do:
                  assign
                     buf_fbr-line.is-calc = yes
                     .
               end.
               run fbrlib-calc-prices in this-procedure (
                  input recid( buf_fbr-line )
                  , input v-price-sale-obj-type
                  , input v-price-sale-obj-code
                  , output v-price-sale
                  ) no-error.
               if error-status:error then
               do:
                  message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
                     , chr(10)
                     , error-status:get-message(1)
                     , return-value )
                     view-as alert-box error .
                  undo, return error .
               end.
               assign
                  buf_fbr-line.price-sale = v-price-sale
                  .
               if v-price-sale-obj-type <> v-cntxt-obj-type
                  or v-price-sale-obj-code <> v-cntxt-obj-code
                  then
               do:
                  assign
                     buf_fbr-line.is-calc = yes
                     .
               end.
            end.
         when 'разрешен':U
         then
            do:
               find first ub.fbr-recipe no-lock
                  where ub.fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                  no-error.
               if buf_fbr-line.trn-type = 'спи':U
                  or buf_fbr-line.is-comp
                  or buf_fbr-line.rsrv-qnty = ?
                  then
               do:
                  assign
                     buf_fbr-line.fix-cost = no
                     .
               end.
               else
               do:
                  if ( v-base = yes and ( buf_fbr-line.price-base <> p-old-cost-base or buf_fbr-line.price-sum-vat-base <> p-old-cost-sum-vat-base ) )
                     or ( v-base = no  and ( buf_fbr-line.price-rubl <> p-old-cost-rubl or buf_fbr-line.price-sum-vat-rubl <> p-old-cost-sum-vat-rubl ) )
                     then
                  do:
                     assign
                        buf_fbr-line.fix-cost       = yes
                        buf_fbr-line.price-sum-rubl = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-base = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                        .
                     if ( v-base = yes and buf_fbr-line.price-base <> p-old-cost-base )
                        or ( v-base = no  and buf_fbr-line.price-rubl <> p-old-cost-rubl )
                        then
                     do:
                        assign
                           buf_fbr-line.price-sum-vat-rubl = p-old-vat-coeff * buf_fbr-line.price-sum-rubl
                           buf_fbr-line.price-sum-vat-base = p-old-vat-coeff * buf_fbr-line.price-sum-base
                           .
                     end.
                  end.
                  run cur-time in this-procedure ( output v-today
                     , output v-time
                     ).
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  f-doc.host-code
  ,input  v-today
  ,output v-base-rate
  ,output v-base-scale
  ) no-error .
                  if error-status :error
                     then
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip
                        "Ошибка вычисления курса базовой валюты."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return error .
                  end.
                  if v-base = yes
                     then
                  do:
                     assign
                        buf_fbr-line.price-rubl         = buf_fbr-line.price-base
                                                                * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                / ( if v-base-scale = 0 then 1 else v-base-scale )
                        buf_fbr-line.price-sum-rubl     = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-vat-base
                                                                * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  else
                  do:
                     assign
                        buf_fbr-line.price-base         = buf_fbr-line.price-rubl
                                                                / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                * ( if v-base-scale = 0 then 1 else v-base-scale )
                        buf_fbr-line.price-sum-base     = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-vat-rubl
                                                                / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-base <> p-old-cost-base
                     or buf_fbr-line.price-rubl <> p-old-cost-rubl
                     then
                  do:
                     run str/fbrclcin.p (
                        input buf_fbr-line.doc-code
                        , input buf_fbr-line.recipe-code
                        , input v-base
                        , input v-base-rate
                        , input v-base-scale
                        ).
                  end.
               end.
            end.
      end case.
   end.
END PROCEDURE.
PROCEDURE assign-current-goods :
   do
      on error undo, return error
      :
      define buffer buf_goods for ub.goods.
      if current-browse = br-ingr :handle in frame D-FBR-DOC
         or not available( buf_comp_fbr-line )
         then
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_ingr_fbr-line.artic
            and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
            and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
            no-error.
      end.
      else
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_comp_fbr-line.artic
            and buf_goods.prod-type = buf_comp_fbr-line.prod-type
            and buf_goods.prod-code = buf_comp_fbr-line.prod-code
            no-error.
      end.
      if available buf_goods
         then
      do:
         assign
            gds-rec = recid( buf_goods )
            .
      end.
   end.
END PROCEDURE.
PROCEDURE assign-ingr-line :
   define input parameter p-ingr-fbr-line-rowid    as rowid            no-undo.
   define input parameter p-fact-qnty              as decimal          no-undo.
   define input parameter p-is-calc                as logical          no-undo.
   define input parameter p-price-sale             as decimal          no-undo.
   define input parameter p-fix-cost               as logical          no-undo.
   define input parameter p-price-rubl             as decimal          no-undo.
   define input parameter p-price-base             as decimal          no-undo.
   define input parameter p-price-sum-vat-rubl     as decimal          no-undo.
   define input parameter p-price-sum-vat-base     as decimal          no-undo.
   define variable old-fact-qnty         as decimal no-undo .
   define variable old-price-sale        like ub.fbr-line.price-sale no-undo .
   define variable old-cost-base         like ub.fbr-line.price-base no-undo .
   define variable old-cost-rubl         like ub.fbr-line.price-rubl no-undo .
   define variable old-cost-sum-vat-base like ub.fbr-line.price-base no-undo .
   define variable old-cost-sum-vat-rubl like ub.fbr-line.price-rubl no-undo .
   define variable old-vat-coeff         as decimal no-undo.
   define buffer buf_loc_ingr_fbr-line for ub.fbr-line.
   do
      for buf_loc_ingr_fbr-line
      on error undo, return error
      :
      find first buf_loc_ingr_fbr-line exclusive-lock
         where rowid( buf_loc_ingr_fbr-line ) = p-ingr-fbr-line-rowid
         .
      assign
         old-fact-qnty         = buf_loc_ingr_fbr-line.fact-qnty
         old-price-sale        = buf_loc_ingr_fbr-line.price-sale
         old-cost-rubl         = buf_loc_ingr_fbr-line.price-rubl
         old-cost-base         = buf_loc_ingr_fbr-line.price-base
         old-cost-sum-vat-rubl = buf_loc_ingr_fbr-line.price-sum-vat-rubl
         old-cost-sum-vat-base = buf_loc_ingr_fbr-line.price-sum-vat-base
         .
      if v-base = yes
         then
      do:
         assign
            old-vat-coeff = ( if old-cost-base = 0
                                or old-cost-base = ?
                                then 0
                                else old-cost-sum-vat-base / ( old-cost-base * buf_loc_ingr_fbr-line.fact-qnty ) )
            .
      end.
      else
      do:
         assign
            old-vat-coeff = ( if old-cost-rubl = 0
                                or old-cost-rubl = ?
                                then 0
                                else old-cost-sum-vat-rubl / ( old-cost-rubl * buf_loc_ingr_fbr-line.fact-qnty ) )
            .
      end.
      assign
         buf_loc_ingr_fbr-line.fact-qnty          = p-fact-qnty
         buf_loc_ingr_fbr-line.is-calc            = p-is-calc
         buf_loc_ingr_fbr-line.price-sale         = p-price-sale
         buf_loc_ingr_fbr-line.fix-cost           = p-fix-cost
         buf_loc_ingr_fbr-line.price-rubl         = p-price-rubl
         buf_loc_ingr_fbr-line.price-base         = p-price-base
         buf_loc_ingr_fbr-line.price-sum-vat-rubl = p-price-sum-vat-rubl
         buf_loc_ingr_fbr-line.price-sum-vat-base = p-price-sum-vat-base
         .
      run adjust-changed-ingr-line in this-procedure (
         input buf_loc_ingr_fbr-line.doc-code
         , input buf_loc_ingr_fbr-line.recipe-code
         , input buf_loc_ingr_fbr-line.artic
         , input buf_loc_ingr_fbr-line.prod-type
         , input buf_loc_ingr_fbr-line.prod-code
         , input old-fact-qnty
         , input old-price-sale
         , input old-cost-base
         , input old-cost-rubl
         , input old-cost-sum-vat-base
         , input old-cost-sum-vat-rubl
         , input old-vat-coeff
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Ошибка пересчета измененной строки"
            skip
            "документа производства"
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return error .
      end.
   end.
END PROCEDURE.
PROCEDURE assign-obj-fbroperator :
   define buffer buf_clients for ub.clients.
   do
      for buf_clients
      on error undo, return error
      :
      if v-fbr-doc-fbroperator-code = 0
         then
      do:
         assign
            obj-fbroperator = "":U
            .
      end.
      else
      do:
         find first buf_clients no-lock
            where buf_clients.obj-type = 'чел':U
            and buf_clients.obj-code = v-fbr-doc-fbroperator-code
            no-error.
         if available buf_clients
            then
         do:
            assign
               obj-fbroperator = buf_clients.obj-name
               .
         end.
         else
         do:
            assign
               obj-fbroperator = "":U
               .
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE change-current-comp-line :
   do
      on error undo, return error
      :
      define input parameter p-comp-fbr-v-fbr-doc-line-recid    as recid        no-undo.
      define input parameter p-fbr-doc-status         as character    no-undo.
      define input parameter p-host-code              as integer      no-undo.
      define variable old-cost-base         like ub.fbr-line.price-base no-undo .
      define variable old-cost-rubl         like ub.fbr-line.price-rubl no-undo .
      define variable old-cost-sum-vat-base like ub.fbr-line.price-sum-vat-base no-undo .
      define variable old-cost-sum-vat-rubl like ub.fbr-line.price-sum-vat-rubl no-undo .
      define variable v-price-sale          as decimal no-undo.
      define variable v-today               as date    no-undo.
      define variable v-time                as integer no-undo.
      define variable v-base-rate           as decimal no-undo.
      define variable v-base-scale          as decimal no-undo.
      define buffer buf_fbr-doc  for ub.fbr-doc.
      define buffer buf_fbr-line for ub.fbr-line.
      define buffer buf_recipe   for ub.fbr-recipe.
      find first buf_fbr-line exclusive-lock
         where recid( buf_fbr-line ) = p-comp-fbr-v-fbr-doc-line-recid
         .
      if p-fbr-doc-status = 'новый':U
         then
      do:
         assign
            browse br-comp
            buf_comp_fbr-line.is-calc
            .
         run fbrlib-calc-prices in this-procedure (
            input p-comp-fbr-v-fbr-doc-line-recid
            , input v-price-sale-obj-type
            , input v-price-sale-obj-code
            , output v-price-sale
            ) no-error.
         if error-status:error then
         do:
            message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
               view-as alert-box error .
            undo, return error .
         end.
         if v-price-sale <> ?
            then
         do:
            assign
               buf_fbr-line.price-sale = v-price-sale
               .
            if v-price-sale-obj-type <> v-cntxt-obj-type
               or v-price-sale-obj-code <> v-cntxt-obj-code
               then
            do:
               assign
                  buf_fbr-line.is-calc = yes
                  .
            end.
         end.
      end.
      if p-fbr-doc-status = 'разрешен':U
         then
      do:
         find first buf_recipe no-lock
            where buf_recipe.doc-code      = f-doc.doc-code
            and buf_recipe.recipe-code   = buf_fbr-line.recipe-code
            no-error.
         if buf_fbr-line.trn-type = 'спи':U
            or available buf_recipe
            or buf_fbr-line.rsrv-qnty = ?
            then
         do:
            assign
               buf_fbr-line.fix-cost = no
               .
         end.
         else
         do:
            assign
               old-cost-base         = buf_fbr-line.price-base
               old-cost-rubl         = buf_fbr-line.price-rubl
               old-cost-sum-vat-base = buf_fbr-line.price-sum-vat-base
               old-cost-sum-vat-rubl = buf_fbr-line.price-sum-vat-rubl
               browse br-comp
               buf_comp_fbr-line.fix-cost
               buf_comp_fbr-line.price-rubl
               buf_comp_fbr-line.price-base
               buf_comp_fbr-line.price-sum-vat-rubl
               buf_comp_fbr-line.price-sum-vat-base
               .
            if ( v-base = yes
               and ( buf_fbr-line.price-base <> old-cost-base
               or buf_fbr-line.price-sum-vat-base <> old-cost-sum-vat-base ) )
               or ( v-base = no
               and ( buf_fbr-line.price-rubl <> old-cost-rubl
               or buf_fbr-line.price-sum-vat-rubl <> old-cost-sum-vat-rubl ) )
               then
            do:
               assign
                  buf_fbr-line.fix-cost = yes
                  .
               run cur-time in this-procedure ( output v-today
                  , output v-time
                  ).
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  p-host-code
  ,input  v-today
  ,output v-base-rate
  ,output v-base-scale
  ) no-error .
               if error-status :error
                  then
               do:
                  message
                     vss-workfile vss-revision vss-description
                     skip
                     "Ошибка вычисления курса базовой валюты."
                     skip return-value
                     skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                     view-as alert-box error.
                  undo, return no-apply .
               end.
               if v-base = yes
                  then
               do:
                  if buf_fbr-line.price-sum-vat-base <> old-cost-sum-vat-base
                     then
                  do:
                     assign
                        buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-vat-base
                                                            * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-base <> old-cost-base
                     then
                  do:
                     assign
                        buf_fbr-line.price-rubl = buf_fbr-line.price-base
                                                            * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
               end.
               else
               do:
                  if buf_fbr-line.price-sum-vat-rubl <> old-cost-sum-vat-rubl
                     then
                  do:
                     assign
                        buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-vat-rubl
                                                            / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-rubl <> old-cost-rubl
                     then
                  do:
                     assign
                        buf_fbr-line.price-base = buf_fbr-line.price-rubl
                                                            / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
               end.
               assign
                  buf_fbr-line.price-sum-rubl = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                  buf_fbr-line.price-sum-base = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                  buf_fbr-line.rsrv-qnty      = buf_fbr-line.fact-qnty
                  .
            end.
            if buf_comp_fbr-line.price-sum-vat-rubl >= buf_comp_fbr-line.price-sum-rubl
               or buf_comp_fbr-line.price-sum-vat-base >= buf_comp_fbr-line.price-sum-base
               then
            do:
               assign
                  buf_comp_fbr-line.price-sum-vat-rubl = old-cost-sum-vat-rubl
                  buf_comp_fbr-line.price-sum-vat-base = old-cost-sum-vat-base
                  buf_comp_fbr-line.price-sum-rubl     = old-cost-rubl
                  buf_comp_fbr-line.price-sum-base     = old-cost-base
                  .
               message
                  skip
                  "Сумма НДС учетных цен не может быть"
                  skip
                  "больше или равна сумме учетных цен"
                  skip(1)
                  skip
                  "Введите верные данные."
                  view-as alert-box error.
               undo, return error .
            end.
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE check-and-correct-fbr-recipe :
   define input parameter p-fbr-doc-code       as character        no-undo.
   define input parameter p-fbr-recipe-code    as character        no-undo.
   define output parameter p-can-continue      as logical          no-undo.
   define variable v-is-correct as logical no-undo.
   define variable v-yesno      as logical no-undo.
   do
      on error undo, return error
      :
      assign
         p-can-continue = yes
         .
      run fbrlib-check-fbr-recipe in this-procedure (
         input p-fbr-doc-code
         , input p-fbr-recipe-code
         , output v-is-correct
         ).
      if v-is-correct = no
         then
      do:
         assign
            v-yesno = no
            .
         message
            "Рецепт документа не соответствует строкам документа."
            skip(1)
            "Номер рецепта:" p-fbr-recipe-code
            skip(1)
            skip
            "Вы можете:"
            skip
            "    Изменить рецепт документа в соответствии"
            skip
            "        с введенными значениями количеств ингредиентов."
            skip
            "    или вернуться к редактированию документа,"
            skip
            "        чтобы привести строки в соответствие рецепту"
            skip
            "        кнопками Составной и Ингредиенты"
            skip(1)
            skip
            "Изменить рецепт документа?"
            view-as alert-box question
            buttons ok-cancel
            title "Изменение рецепта документа"
            update v-yesno.
         if v-yesno = yes
            then
         do:
            run fbrlib_adjust-recipe in this-procedure (
               input parparentproc
               , input p-fbrhist-handle
               , input p-fbr-doc-code
               , input p-fbr-recipe-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               ).
         end.
         else
         do:
            assign
               p-can-continue = no
               .
            undo, return.
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE del-proc :
   do
      on error undo, return error
      :
      define input parameter p-mode as character no-undo.
      define output parameter p-deleted as logical      no-undo.
      define variable v-rcp-list as character no-undo.
      define variable v-count    as integer   no-undo.
      define buffer buf_fbr-line           for ub.fbr-line.
      define buffer buf_del_fbr-line       for ub.fbr-line.
      define buffer buf_del_fbr-recipe     for ub.fbr-recipe.
      define buffer buf_del_fbr-recipe-gds for ub.fbr-recipe-gds.
      define buffer buf_goods              for ub.goods .
      define buffer buf_marking            for ub.marking .
      define buffer buf_marking-lines      for ub.marking-lines .
      assign
         p-deleted = no
         .
      case p-mode:
         when "down"
         then
            do:
               if not available buf_ingr_fbr-line
                  then
               do:
                  message "Неправильно выбрана строка нижнего списка.".
               end.
               else
               do:
                  if buf_ingr_fbr-line.recipe-code <> ""
                     then
                  do:
                     message "Строка нижнего списка может быть удалена только по рецепту.".
                  end.
                  else
                  do:
                     assign
                        v-fbr-doc-g-log = no
                        .
                     message
                        "Удалить строку нижнего списка?"
                        view-as alert-box question
                        buttons yes-no
                        title "Удаление строки"
                        update v-fbr-doc-g-log.
                     if v-fbr-doc-g-log = yes
                        then
                     do:
                        assign
                           v-fbr-doc-line-rec = recid( buf_ingr_fbr-line )
                           .
                        get next br-ingr.
                        if available buf_ingr_fbr-line
                           then
                        do:
                           assign
                              v-fbr-doc-rep-rec = recid( buf_ingr_fbr-line )
                              .
                        end.
                        else
                        do:
                           reposition br-ingr to recid v-fbr-doc-line-rec no-error.
                           get prev br-ingr.
                           assign
                              v-fbr-doc-rep-rec = recid( buf_ingr_fbr-line )
                              .
                        end.
                        del-ingr:
                        do transaction
                           on stop  undo del-ingr, return no-apply
                           on error undo del-ingr, return no-apply
                           :
                           find first buf_ingr_fbr-line exclusive-lock
                              where recid( buf_ingr_fbr-line ) = v-fbr-doc-line-rec
                              .
                           for first buf_goods no-lock where buf_goods.artic      = buf_ingr_fbr-line.artic
                                                         and buf_goods.prod-type  = buf_ingr_fbr-line.prod-type
                                                         and buf_goods.prod-code  = buf_ingr_fbr-line.prod-code,
                           each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                   and buf_marking-lines.obj-type = f-doc.obj-type
                                                                   and buf_marking-lines.obj-code = f-doc.obj-code
                                                                   and buf_marking-lines.in-code  = "manufacturing"
                                                                   and buf_marking-lines.out-code = buf_ingr_fbr-line.doc-code
                                                                   and buf_marking-lines.part-code = buf_ingr_fbr-line.recipe-code
                                                                   and buf_marking-lines.prt-code = 0
                           :
                             for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                             end .
                             delete buf_marking-lines.
                           end .
                           delete buf_ingr_fbr-line.
                        end.
                        assign
                           v-fbr-doc-line-rec = recid( buf_comp_fbr-line )
                           p-deleted          = yes
                           .
                     end.
                  end.
               end.
            end.
         when "up"
         then
            do:
               if not available buf_comp_fbr-line
                  then
               do:
                  message
                     "Неправильно выбрана строка верхнего списка."
                     view-as alert-box.
               end.
               else
               do:
                  if buf_comp_fbr-line.recipe-code <> ""
                     then
                  do:
                     message
                        "Строка верхнего списка может быть удалена только по рецепту."
                        view-as alert-box information
                        title "Удаление строки".
                  end.
                  else
                  do:
                     assign
                        v-fbr-doc-g-log = no
                        .
                     message
                        "Удалить строку верхнего списка?"
                        view-as alert-box question
                        buttons yes-no
                        title "Удаление строки"
                        update v-fbr-doc-g-log.
                     if v-fbr-doc-g-log = yes
                        then
                     do:
                        assign
                           v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                           .
                        get next br-comp.
                        if available buf_comp_fbr-line
                           then
                        do:
                           assign
                              v-fbr-doc-rep-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        else
                        do:
                           reposition br-comp to recid v-fbr-doc-line-rec no-error.
                           get prev br-comp.
                           assign
                              v-fbr-doc-rep-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        del-comp:
                        do transaction
                           on stop undo del-comp, return no-apply
                           on error undo del-comp, return no-apply
                           :
                           find first buf_comp_fbr-line exclusive-lock
                              where recid (buf_comp_fbr-line) = v-fbr-doc-line-rec
                              .
                           for first buf_goods no-lock where buf_goods.artic      = buf_comp_fbr-line.artic
                                                         and buf_goods.prod-type  = buf_comp_fbr-line.prod-type
                                                         and buf_goods.prod-code  = buf_comp_fbr-line.prod-code,
                           each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                   and buf_marking-lines.obj-type = f-doc.obj-type
                                                                   and buf_marking-lines.obj-code = f-doc.obj-code
                                                                   and buf_marking-lines.in-code  = "manufacturing"
                                                                   and buf_marking-lines.out-code = buf_comp_fbr-line.doc-code
                                                                   and buf_marking-lines.part-code = buf_comp_fbr-line.recipe-code
                                                                   and buf_marking-lines.prt-code = 0
                           :
                             for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB .
                             end .
                             delete buf_marking-lines.
                           end .
                           delete buf_comp_fbr-line.
                        end.
                        assign
                           v-fbr-doc-line-rec = v-fbr-doc-rep-rec
                           p-deleted          = yes
                           .
                     end.
                  end.
               end.
            end.
         when "all-doc"
         then
            do:
               assign
                  v-fbr-doc-g-log = no
                  .
               message
                  "Удалить все строки документа?"
                  view-as alert-box question
                  buttons yes-no
                  update v-fbr-doc-g-log.
               if v-fbr-doc-g-log = yes
                  then
               do:
                  for each buf_fbr-line no-lock
                     where buf_fbr-line.doc-code      = f-doc.doc-code
                     on error undo, return error
                     :
                     do transaction
                        on error undo, return error
                        :
                        if buf_fbr-line.is-comp = yes
                           then
                        do:
                           find first buf_del_fbr-recipe exclusive-lock
                              where buf_del_fbr-recipe.doc-code    = f-doc.doc-code
                              and buf_del_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                              no-error.
                           if available buf_del_fbr-recipe
                              then
                           do:
                              delete buf_del_fbr-recipe.
                           end.
                        end.
                        else
                        do:
                           find first buf_del_fbr-recipe-gds exclusive-lock
                              where buf_del_fbr-recipe-gds.doc-code    = f-doc.doc-code
                              and buf_del_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                              and buf_del_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                              and buf_del_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                              and buf_del_fbr-recipe-gds.artic       = buf_fbr-line.artic
                              no-error.
                           if available buf_del_fbr-recipe-gds
                              then
                           do:
                              delete buf_del_fbr-recipe-gds.
                           end.
                        end.
                        find first buf_del_fbr-line exclusive-lock
                           where recid( buf_del_fbr-line ) = recid( buf_fbr-line )
                           .
                        for first buf_goods no-lock where buf_goods.artic      = buf_del_fbr-line.artic
                                                      and buf_goods.prod-type  = buf_del_fbr-line.prod-type
                                                      and buf_goods.prod-code  = buf_del_fbr-line.prod-code,
                        each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                and buf_marking-lines.obj-type = f-doc.obj-type
                                                                and buf_marking-lines.obj-code = f-doc.obj-code
                                                                and buf_marking-lines.in-code  = "manufacturing"
                                                                and buf_marking-lines.out-code = buf_del_fbr-line.doc-code
                                                                and buf_marking-lines.part-code = buf_del_fbr-line.recipe-code
                                                                and buf_marking-lines.prt-code = 0
                        :
                          for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                             assign
                               buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when not buf_del_fbr-line.is-comp
                               buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_del_fbr-line.is-comp
                             .
                          end .
                          delete buf_marking-lines.
                        end .
                        delete buf_del_fbr-line.
                     end.
                  end.
                  assign
                     p-deleted = yes
                     .
               end.
            end.
         when "rcp"
         or
         when "all"
         then
            do:
               if not available buf_comp_fbr-line
                  then
               do:
                  message "Неправильно выбрана строка документа (из верхнего списка).".
               end.
               else
               do:
                  assign
                     v-fbr-doc-g-log = no
                     .
                  if p-mode = "rcp"
                     then
                  do:
                     message
                        "Удалить все строки документа, соответствующие текущему рецепту?"
                        view-as alert-box question
                        buttons yes-no
                        update v-fbr-doc-g-log.
                  end.
                  else
                  do:
                     message
                        "Удалить строки документа, соответствующие текущему рецепту, а также рецептам для ингредиентов?"
                        view-as alert-box question
                        buttons yes-no
                        update v-fbr-doc-g-log.
                  end.
                  if v-fbr-doc-g-log = yes
                     then
                  do:
                     assign
                        v-rcp-list         = buf_comp_fbr-line.recipe-code
                        v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                        v-fbr-doc-rep-rec  = ?
                        .
                     get next br-comp .
                     if available buf_comp_fbr-line then
                     do :
                        v-fbr-doc-line-rec = recid (buf_comp_fbr-line) .
                        get prev br-comp .
                     end.
                     if p-mode = "all"
                        then
                     do:
                        run fill-del-list in this-procedure (
                           input buf_comp_fbr-line.recipe-code
                           , output v-rcp-list
                           ).
                     end.
                     do v-count = 1 to num-entries( v-rcp-list )
                        :
                        for each buf_fbr-line no-lock
                           where buf_fbr-line.doc-code      = f-doc.doc-code
                           and buf_fbr-line.recipe-code   = entry( v-count, v-rcp-list )
                           on error undo, return error
                           :
                           do transaction
                              on error undo, return error
                              :
                              if buf_fbr-line.is-comp = yes
                                 then
                              do:
                                 find first buf_del_fbr-recipe exclusive-lock
                                    where buf_del_fbr-recipe.doc-code    = f-doc.doc-code
                                    and buf_del_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                                    no-error.
                                 if available buf_del_fbr-recipe
                                    then
                                 do:
                                    delete buf_del_fbr-recipe.
                                 end.
                              end.
                              else
                              do:
                                 find first buf_del_fbr-recipe-gds exclusive-lock
                                    where buf_del_fbr-recipe-gds.doc-code    = f-doc.doc-code
                                    and buf_del_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                                    and buf_del_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                                    and buf_del_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                                    and buf_del_fbr-recipe-gds.artic       = buf_fbr-line.artic
                                    no-error.
                                 if available buf_del_fbr-recipe-gds
                                    then
                                 do:
                                    delete buf_del_fbr-recipe-gds.
                                 end.
                              end.
                              find first buf_del_fbr-line exclusive-lock
                                 where recid( buf_del_fbr-line ) = recid( buf_fbr-line )
                                 .
                              for first buf_goods no-lock where buf_goods.artic      = buf_del_fbr-line.artic
                                                            and buf_goods.prod-type  = buf_del_fbr-line.prod-type
                                                            and buf_goods.prod-code  = buf_del_fbr-line.prod-code,
                              each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                      and buf_marking-lines.obj-type = f-doc.obj-type
                                                                      and buf_marking-lines.obj-code = f-doc.obj-code
                                                                      and buf_marking-lines.in-code  = "manufacturing"
                                                                      and buf_marking-lines.out-code = buf_del_fbr-line.doc-code
                                                                      and buf_marking-lines.part-code = buf_del_fbr-line.recipe-code
                                                                      and buf_marking-lines.prt-code = 0
                              :
                                for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                   assign
                                     buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when not buf_del_fbr-line.is-comp
                                     buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_del_fbr-line.is-comp
                                   .
                                end .
                                delete buf_marking-lines.
                              end .
                              delete buf_del_fbr-line.
                           end.
                        end.
                     end.
                     assign
                        p-deleted = yes
                        .
                  end.
               end.
            end.
      end case.
   end.
END PROCEDURE.
PROCEDURE disable_UI :
   HIDE FRAME D-FBR-DOC.
END PROCEDURE.
PROCEDURE fill-del-list :
   define input parameter r-code       like ub.fbr-recipe.recipe-code no-undo.
   define output parameter p-rcp-list  as character    no-undo.
   define buffer buf_ingr_fbr-line for ub.fbr-line.
   define buffer buf_comp_fbr-line for ub.fbr-line.
   assign
      p-rcp-list = string( r-code )
      .
   for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code
      and buf_ingr_fbr-line.is-comp = no
      and buf_ingr_fbr-line.recipe-code = r-code
      :
      for each buf_comp_fbr-line no-lock
         where buf_comp_fbr-line.doc-code = buf_ingr_fbr-line.doc-code
         and buf_comp_fbr-line.is-comp = yes
         and buf_comp_fbr-line.artic = buf_ingr_fbr-line.artic
         and buf_comp_fbr-line.prod-type = buf_ingr_fbr-line.prod-type
         and buf_comp_fbr-line.prod-code = buf_ingr_fbr-line.prod-code
         :
         assign
            p-rcp-list = p-rcp-list + "," + buf_comp_fbr-line.recipe-code
            .
      end.
   end.
END PROCEDURE.
PROCEDURE fill-recipe-fields :
   do
      on error undo, return error
      :
      define input parameter p-recipe-code as character    no-undo.
      define buffer buf_recipe for ub.fbr-recipe.
      find first buf_recipe no-lock
         where buf_recipe.doc-code = f-doc.doc-code
         and buf_recipe.recipe-code = p-recipe-code
         no-error.
      if available buf_recipe
         then
      do:
         display
            buf_recipe.recipe-code  @ ub.fbr-recipe.recipe-code
            buf_recipe.recipe-name  @ ub.fbr-recipe.recipe-name
            buf_recipe.recipe-type  @ ub.fbr-recipe.recipe-type
            buf_recipe.qnty         @ ub.fbr-recipe.qnty
            with frame D-FBR-DOC.
      end.
      else
      do:
         display
            "" @ ub.fbr-recipe.recipe-code
            "" @ ub.fbr-recipe.recipe-name
            "" @ ub.fbr-recipe.recipe-type
            "" @ ub.fbr-recipe.qnty
            with frame D-FBR-DOC.
      end.
   end.
END PROCEDURE.
PROCEDURE get-current-goods-recid :
   define output parameter p-gds-rec as recid            no-undo.
   do
      on error undo, return error
      :
      define buffer buf_goods for ub.goods.
      if current-browse = br-ingr :handle in frame D-FBR-DOC
         or not available( buf_comp_fbr-line )
         then
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_ingr_fbr-line.artic
            and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
            and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
            no-error.
      end.
      else
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_comp_fbr-line.artic
            and buf_goods.prod-type = buf_comp_fbr-line.prod-type
            and buf_goods.prod-code = buf_comp_fbr-line.prod-code
            no-error.
      end.
      if available buf_goods
         then
      do:
         assign
            p-gds-rec = recid( buf_goods )
            .
      end.
      else
      do:
         assign
            p-gds-rec = ?
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-effect :
   do
      on error undo, return error
      :
      define input parameter p-recipe-code    as character    no-undo.
      define input parameter p-doc-code       as character    no-undo.
      define output parameter p-effect        as decimal      no-undo.
      define variable v-sum-cost-rubl as decimal no-undo.
      define variable v-sum-cost-base as decimal no-undo.
      define variable v-sum-sale      as decimal no-undo.
      define buffer buf_fbr-line for ub.fbr-line.
      assign
         v-sum-cost-rubl = 0
         v-sum-cost-base = 0
         v-sum-sale      = 0
         .
      for each buf_fbr-line no-lock
         where buf_fbr-line.recipe-code   = p-recipe-code
         and buf_fbr-line.doc-code      = p-doc-code
         and buf_fbr-line.rsrv-qnty     <> ?
         :
         if buf_fbr-line.trn-type = 'спи':U
            then
         do:
            assign
               v-sum-cost-rubl = v-sum-cost-rubl + buf_fbr-line.price-sum-rubl + buf_fbr-line.price-sum-vat-rubl
               v-sum-cost-base = v-sum-cost-base + buf_fbr-line.price-sum-base + buf_fbr-line.price-sum-vat-base
               .
         end.
         else
         do:
            assign
               v-sum-sale = v-sum-sale      + ( buf_fbr-line.fact-qnty * buf_fbr-line.price-sale )
               .
         end.
      end.
      if v-base = yes
         then
      do:
         assign
            p-effect = ( v-sum-sale - v-sum-cost-base ) / v-sum-cost-base * 100.
         .
      end.
      else
      do:
         assign
            p-effect = ( v-sum-sale - v-sum-cost-rubl ) / v-sum-cost-rubl * 100.
         .
      end.
   end.
END PROCEDURE.
PROCEDURE get-goods-name-proc :
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-gds-name          as character        no-undo.
   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output p-gds-name
  ) no-error .
         if error-status :error
            then
         do:
            assign
               p-gds-name = "":U
               .
         end.
      end.
      else
      do:
         assign
            p-gds-name = "":U
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-goods-recid :
   define buffer buf_goods for ub.goods.
   do
      for buf_goods
      with frame D-FBR-DOC
      on error undo, return error
      :
      case current-browse
         :
         when br-comp :handle
         then
            do:
               if available buf_comp_fbr-line
                  then
               do:
                  find first buf_goods no-lock
                     where buf_goods.artic     = buf_comp_fbr-line.artic
                     and buf_goods.prod-type = buf_comp_fbr-line.prod-type
                     and buf_goods.prod-code = buf_comp_fbr-line.prod-code
                     no-error.
                  if available buf_goods
                     then
                  do:
                     assign
                        gds-rec = recid( buf_goods )
                        .
                  end.
               end.
            end.
         when br-ingr :handle
         then
            do:
               if available buf_ingr_fbr-line
                  then
               do:
                  find first buf_goods no-lock
                     where buf_goods.artic     = buf_ingr_fbr-line.artic
                     and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
                     and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
                     no-error.
                  if available buf_goods
                     then
                  do:
                     assign
                        gds-rec = recid( buf_goods )
                        .
                  end.
               end.
            end.
      end case.
   end.
END PROCEDURE.
PROCEDURE get-ingr-line-parameters :
   define input parameter p-recipe-code            as character        no-undo.
   define input parameter p-artic                  as character        no-undo.
   define input parameter p-prod-type              as character        no-undo.
   define input parameter p-prod-code              as integer          no-undo.
   define output parameter p-gds-name              as character        no-undo.
   define output parameter p-gds-type              as character        no-undo.
   define output parameter p-recipe-type           as character        no-undo.
   define output parameter p-recipe-qnty           as decimal          no-undo.
   define output parameter p-recipe-brutto-qnty    as decimal          no-undo.
   define output parameter p-recipe-coeff-value    as decimal          no-undo.
   define output parameter p-recipe-coeff-waste    as decimal          no-undo.
   define output parameter p-recipe-waste          as logical          no-undo.
   define buffer buf_goods      for ub.goods.
   define buffer buf_recipe     for ub.recipe.
   define buffer buf_recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_goods
      , buf_recipe
      , buf_recipe-gds
      on error undo, return error
      :
      find first buf_goods no-lock
         where buf_goods.artic      = p-artic
         and buf_goods.prod-type  = p-prod-type
         and buf_goods.prod-code  = p-prod-code
         no-error.
      assign
         p-gds-name = ( if available buf_goods then buf_goods.gds-name else "":U )
         p-gds-type = ( if available buf_goods
                     then ( if buf_goods.gds-type = 'т':U then "" else 'у':U )
                     else "":U
                     )
         .
      find first buf_recipe-gds no-lock
         where buf_recipe-gds.doc-code     = f-doc.doc-code
         and buf_recipe-gds.recipe-code  = p-recipe-code
         and buf_recipe-gds.artic        = p-artic
         and buf_recipe-gds.prod-type    = p-prod-type
         and buf_recipe-gds.prod-code    = p-prod-code
         no-error.
      if available buf_recipe-gds
         then
      do:
         assign
            p-recipe-qnty        = buf_recipe-gds.qnty
            p-recipe-brutto-qnty = buf_recipe-gds.brutto-qnty
            p-recipe-coeff-value = buf_recipe-gds.coeff-value
            p-recipe-coeff-waste = buf_recipe-gds.coeff-waste
            p-recipe-waste       = buf_recipe-gds.is-waste
            .
      end.
      else
      do:
         assign
            p-recipe-qnty        = ?
            p-recipe-brutto-qnty = ?
            p-recipe-coeff-value = ?
            p-recipe-coeff-waste = ?
            p-recipe-waste       = no
            .
      end.
      find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
         no-error.
      if available buf_recipe
         then
      do:
         assign
            p-recipe-type = buf_recipe.recipe-type
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-line-OK-proc :
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-line-ok           as logical          no-undo.
   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
         assign
            p-line-ok = ( buf_fbr-line.fact-qnty = buf_fbr-line.rsrv-qnty
                       or buf_fbr-line.rsrv-qnty = ? )
            .
      end.
      else
      do:
         assign
            p-line-ok = no
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-netto-qnty-proc :
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-netto-qnty        as decimal          no-undo.
   define variable v-void-decimal as decimal   no-undo.
   define variable v-void-integer as integer   no-undo.
   define variable v-recipe-type  as character no-undo.
   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
         run fbrlib-get-recipe-type in this-procedure (
            input buf_fbr-line.doc-code
            , input buf_fbr-line.recipe-code
            , output v-recipe-type
            ).
         run fbrlib-calc-brutto in this-procedure (
            input v-recipe-type
            , input 0
            , input buf_fbr-line.coeff-value
            , input buf_fbr-line.coeff-waste
            , input buf_fbr-line.fact-qnty
            , input 1
            , output p-netto-qnty
            , output v-void-decimal
            , output v-void-decimal
            , output v-void-integer
            ) NO-ERROR.
         if error-status :error
            then
         do:
            assign
               p-netto-qnty = 0.0
               .
         end.
      end.
      else
      do:
         assign
            p-netto-qnty = 0.0
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-pay-name :
   define input parameter p-pay-code   as integer          no-undo.
   define output parameter p-pay-name  as character        no-undo.
   define buffer buf_pay-type for ub.pay-type.
   do
      for buf_pay-type
      on error undo, return error
      :
      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-pay-code
         no-error.
      if available buf_pay-type
         then
      do:
         assign
            p-pay-name = buf_pay-type.obj-name
            .
      end.
      else
      do:
         assign
            p-pay-name = "":U
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-pay-type-name :
   define input parameter p-pay-code       as integer          no-undo.
   define output parameter p-pay-type-name as character        no-undo.
   define buffer buf_pay-type for ub.pay-type.
   do
      on error undo, return error
      :
      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-pay-code
         no-error.
      if available buf_pay-type
         then
      do:
         assign
            p-pay-type-name = buf_pay-type.obj-name
            .
      end.
      else
      do:
         assign
            p-pay-type-name = "":U
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-prod-ref-proc :
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-prod-string       as character        no-undo.
   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
         assign
            p-prod-string = buf_fbr-line.prod-type + " " + string ( buf_fbr-line.prod-code )
            .
         if error-status :error
            then
         do:
            assign
               p-prod-string = "":U
               .
         end.
      end.
      else
      do:
         assign
            p-prod-string = "":U
            .
      end.
   end.
END PROCEDURE.
PROCEDURE get-unit-base-proc :
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-unit-base         as character        no-undo.
   define variable v-gds-code as integer no-undo.
   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  ) no-error .
         if error-status :error
            then
         do:
            assign
               p-unit-base = "":U
               .
         end.
         else
         do:
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output p-unit-base
  ) no-error .
            if error-status :error
               then
            do:
               assign
                  p-unit-base = "":U
                  .
            end.
         end.
      end.
      else
      do:
         assign
            p-unit-base = "":U
            .
      end.
   end.
END PROCEDURE.
PROCEDURE hide-not-avail-menu-items :
   do
      on error undo, return error
      :
      define input parameter p-fbr-doc-is-free as logical      no-undo.
      case p-fbr-doc-is-free
         :
         when yes
         then
            do:
               assign
                  menu-item m-rcp-add :sensitive in menu m-add = no
                  menu-item m-all-add :sensitive in menu m-add = no
                  menu-item m-rcp-del :sensitive in menu m-del = no
                  menu-item m-all-del :sensitive in menu m-del = no
                  .
            end.
         when no
         then
            do:
               assign
                  menu-item m-comp-add :sensitive in menu m-add = no
                  menu-item m-ingr-add :sensitive in menu m-add = no
                  menu-item m-comp-del :sensitive in menu m-del = no
                  menu-item m-ingr-del :sensitive in menu m-del = no
                  .
            end.
      end case.
   end.
END PROCEDURE.
PROCEDURE mode-on :
   do
      on error undo, return error
      :
      case p-doc-mode :
         when 'ДОБАВЛЕНИЕ':U then
            do:
               define variable v-doc-code as character no-undo.
               run fbrlib_create-fbr-doc ( input v-cntxt-obj-type
                  , input  v-cntxt-obj-code
                  ,input v-cntxt-userid
                  , output v-doc-code
                  ,output p-fbr-doc-recid) no-error.
               if error-status:error then
               do:
                  undo, return error substitute("Ошибка при создании нового документа производства:&1&2&1&3"
                     , chr(10)
                     , error-status:get-message(1)
                     , return-value ).
               end.
               assign
                  p-new-fbr-doc-recid = p-fbr-doc-recid
                  .
               find first f-doc exclusive-lock where
                  recid(f-doc) = p-fbr-doc-recid no-error.
               fi-pay-code = f-doc.pay-code.
            end.
         when 'ИЗМЕНЕНИЕ':U then
            do:
               find first f-doc
                  where recid (f-doc) = p-fbr-doc-recid
                  no-error.
               if available f-doc
                  then
               do:
                  find first f-doc exclusive-lock
                     where recid (f-doc) = p-fbr-doc-recid no-error
                     .
               end.
            end.
      end case.
      if not available f-doc
         then
      do:
         message
            "Неправильно выбран документ."
            view-as alert-box error.
         undo, return error.
      end.
   end.
END PROCEDURE.
PROCEDURE open-comp :
   define variable comp-sort-column-phrase as character no-undo .
   define variable filter-point            as character no-undo init "buf_comp_fbr-line" .
   case comp-sort-column-name :
      when ""
      then
         do:
            assign
               comp-sort-column-phrase = ""
               .
         end.
      when "comp-unit"
      then
         do:
            assign
               comp-sort-column-phrase = "by (recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-name"
      then
         do:
            assign
               comp-sort-column-phrase = "by get-goods-name(recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-OK"
      then
         do:
            assign
               comp-sort-column-phrase = "by get-line-OK(recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-prod"
      then
         do:
            assign
               comp-sort-column-phrase = "by get-prod-ref(recid(buf_comp_fbr-line))"
               .
         end.
      otherwise
      do:
         assign
            comp-sort-column-phrase = "by " + comp-sort-column-name
            .
      end.
   end case.
   case rs-one-all :
      when "type"
      then
         do:
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-105  as logical   no-undo .
define variable  l-filter-open-105    as logical   .
define variable  flt-rec-105       as recid     no-undo .
define variable  filter-name-105      as character no-undo .
define variable  where-phrase-105     as character no-undo .
define variable  sort-phrase-105      as character no-undo .
define variable  where-phrase-rus-105 as character no-undo .
define variable  sort-phrase-rus-105  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-105
  ,output filter-name-105
  ,output where-phrase-105
  ,output sort-phrase-105
  ,output where-phrase-rus-105
  ,output sort-phrase-rus-105
  ).
  assign
    l-filter-open-105 = false
  .
  if flt-rec-105 <> ?
    or comp-sort-column-phrase > ""
  then do:
    define variable  parameter-2-105 as character no-undo .
    define variable  parameter-3-105 as character no-undo .
    define variable  parameter-4-105 as character no-undo .
    define variable  parameter-5-105 as character no-undo .
    define variable  parameter-6-105 as character no-undo .
    define variable  parameter-7-105 as character no-undo .
      assign
      parameter-3-105 =
                              "for each buf_comp_fbr-line"
      parameter-4-105 =
        (
          if ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.trn-type = 'при':U " + " " + where-phrase-105) <> ""
          then  substitute('buf_comp_fbr-line.doc-code = &1&2&1 and buf_comp_fbr-line.trn-type = &1&3&1', chr(34), f-doc.doc-code, 'при':U )  + " " + where-phrase-105
          else "true"
        )
      parameter-5-105 = (" " + "" + " " + "")
      parameter-6-105 = if sort-phrase-105 = ''
                           then
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + sort-phrase-105
        )
      parameter-7-105 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-105 =
          ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.trn-type = 'при':U " + " " + where-phrase-105 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-comp:handle
                          ,input parameter-3-105
                          ,input parameter-4-105
                          ,input parameter-5-105
                          ,input parameter-6-105
                          ,input parameter-7-105
                          )
      .
      assign
        l-filter-open-105 = true
      .
    end.
    if l-filter-open-105 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-105 = false then do:
    open query br-comp for each buf_comp_fbr-line no-lock
      where buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.trn-type = 'при':U
      indexed-reposition
  .
  end.
         end.
      when "goods" then
         do:
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-107  as logical   no-undo .
define variable  l-filter-open-107    as logical   .
define variable  flt-rec-107       as recid     no-undo .
define variable  filter-name-107      as character no-undo .
define variable  where-phrase-107     as character no-undo .
define variable  sort-phrase-107      as character no-undo .
define variable  where-phrase-rus-107 as character no-undo .
define variable  sort-phrase-rus-107  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-107
  ,output filter-name-107
  ,output where-phrase-107
  ,output sort-phrase-107
  ,output where-phrase-rus-107
  ,output sort-phrase-rus-107
  ).
  assign
    l-filter-open-107 = false
  .
  if flt-rec-107 <> ?
    or comp-sort-column-phrase > ""
  then do:
    define variable  parameter-2-107 as character no-undo .
    define variable  parameter-3-107 as character no-undo .
    define variable  parameter-4-107 as character no-undo .
    define variable  parameter-5-107 as character no-undo .
    define variable  parameter-6-107 as character no-undo .
    define variable  parameter-7-107 as character no-undo .
      assign
      parameter-3-107 =
                              "for each buf_comp_fbr-line"
      parameter-4-107 =
        (
          if ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes and                             buf_comp_fbr-line.artic = flt-gds.artic and                             buf_comp_fbr-line.prod-type = flt-gds.prod-type and                             buf_comp_fbr-line.prod-code = flt-gds.prod-code " + " " + where-phrase-107) <> ""
          then  substitute('buf_comp_fbr-line.doc-code = &1&2&1 and                             buf_comp_fbr-line.is-comp = yes and                             buf_comp_fbr-line.artic = &1&3&1 and                             buf_comp_fbr-line.prod-type = &1&4&1 and                             buf_comp_fbr-line.prod-code = &5'                             , chr(34), f-doc.doc-code, flt-gds.artic, flt-gds.prod-type, flt-gds.prod-code) + " " + where-phrase-107
          else "true"
        )
      parameter-5-107 = (" " + "" + " " + "")
      parameter-6-107 = if sort-phrase-107 = ''
                           then
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + sort-phrase-107
        )
      parameter-7-107 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-107 =
          ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes and                             buf_comp_fbr-line.artic = flt-gds.artic and                             buf_comp_fbr-line.prod-type = flt-gds.prod-type and                             buf_comp_fbr-line.prod-code = flt-gds.prod-code " + " " + where-phrase-107 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-comp:handle
                          ,input parameter-3-107
                          ,input parameter-4-107
                          ,input parameter-5-107
                          ,input parameter-6-107
                          ,input parameter-7-107
                          )
      .
      assign
        l-filter-open-107 = true
      .
    end.
    if l-filter-open-107 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-107 = false then do:
    open query br-comp for each buf_comp_fbr-line no-lock
      where buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes and                             buf_comp_fbr-line.artic = flt-gds.artic and                             buf_comp_fbr-line.prod-type = flt-gds.prod-type and                             buf_comp_fbr-line.prod-code = flt-gds.prod-code
      indexed-reposition
  .
  end.
         end.
      otherwise
      do:
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-109  as logical   no-undo .
define variable  l-filter-open-109    as logical   .
define variable  flt-rec-109       as recid     no-undo .
define variable  filter-name-109      as character no-undo .
define variable  where-phrase-109     as character no-undo .
define variable  sort-phrase-109      as character no-undo .
define variable  where-phrase-rus-109 as character no-undo .
define variable  sort-phrase-rus-109  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-109
  ,output filter-name-109
  ,output where-phrase-109
  ,output sort-phrase-109
  ,output where-phrase-rus-109
  ,output sort-phrase-rus-109
  ).
  assign
    l-filter-open-109 = false
  .
  if flt-rec-109 <> ?
    or comp-sort-column-phrase > ""
  then do:
    define variable  parameter-2-109 as character no-undo .
    define variable  parameter-3-109 as character no-undo .
    define variable  parameter-4-109 as character no-undo .
    define variable  parameter-5-109 as character no-undo .
    define variable  parameter-6-109 as character no-undo .
    define variable  parameter-7-109 as character no-undo .
      assign
      parameter-3-109 =
                              "for each buf_comp_fbr-line"
      parameter-4-109 =
        (
          if ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes " + " " + where-phrase-109) <> ""
          then  substitute('buf_comp_fbr-line.doc-code = &1&2&1 and                             buf_comp_fbr-line.is-comp = yes', chr(34), f-doc.doc-code ) + " " + where-phrase-109
          else "true"
        )
      parameter-5-109 = (" " + "" + " " + "")
      parameter-6-109 = if sort-phrase-109 = ''
                           then
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + comp-sort-column-phrase +
        " " + sort-phrase-109
        )
      parameter-7-109 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-109 =
          ("buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes " + " " + where-phrase-109 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-comp:handle
                          ,input parameter-3-109
                          ,input parameter-4-109
                          ,input parameter-5-109
                          ,input parameter-6-109
                          ,input parameter-7-109
                          )
      .
      assign
        l-filter-open-109 = true
      .
    end.
    if l-filter-open-109 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-109 = false then do:
    open query br-comp for each buf_comp_fbr-line no-lock
      where buf_comp_fbr-line.doc-code = f-doc.doc-code and                             buf_comp_fbr-line.is-comp = yes
      indexed-reposition
  .
  end.
      end.
   end case.
END PROCEDURE.
PROCEDURE open-ingr :
   define input parameter cur-recipe-code  as character no-undo.
   define variable ingr-sort-column-phrase as character no-undo .
   define variable filter-point            as character no-undo init "buf_ingr_fbr-line" .
   case ingr-sort-column-name :
      when ""
      then
         do:
            assign
               ingr-sort-column-phrase = ""
               .
         end.
      when "ingr-unit"
      then
         do:
            assign
               ingr-sort-column-phrase = "by (recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-name"
      then
         do:
            assign
               ingr-sort-column-phrase = "by get-goods-name(recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-OK"
      then
         do:
            assign
               ingr-sort-column-phrase = "by get-line-OK(recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-prod"
      then
         do:
            assign
               ingr-sort-column-phrase = "by get-prod-ref(recid(buf_ingr_fbr-line))"
               .
         end.
      otherwise
      do:
         assign
            ingr-sort-column-phrase = "by " + ingr-sort-column-name
            .
      end.
   end case.
   case rs-one-all :
      when "type"
      then
         do:
            open query br-ingr for each buf_ingr_fbr-line no-lock
               where buf_ingr_fbr-line.trn-type = 'спи':U
               and buf_ingr_fbr-line.doc-code = f-doc.doc-code
               .
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-111  as logical   no-undo .
define variable  l-filter-open-111    as logical   .
define variable  flt-rec-111       as recid     no-undo .
define variable  filter-name-111      as character no-undo .
define variable  where-phrase-111     as character no-undo .
define variable  sort-phrase-111      as character no-undo .
define variable  where-phrase-rus-111 as character no-undo .
define variable  sort-phrase-rus-111  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-111
  ,output filter-name-111
  ,output where-phrase-111
  ,output sort-phrase-111
  ,output where-phrase-rus-111
  ,output sort-phrase-rus-111
  ).
  assign
    l-filter-open-111 = false
  .
  if flt-rec-111 <> ?
    or ingr-sort-column-phrase > ""
  then do:
    define variable  parameter-2-111 as character no-undo .
    define variable  parameter-3-111 as character no-undo .
    define variable  parameter-4-111 as character no-undo .
    define variable  parameter-5-111 as character no-undo .
    define variable  parameter-6-111 as character no-undo .
    define variable  parameter-7-111 as character no-undo .
      assign
      parameter-3-111 =
                              "for each buf_ingr_fbr-line no-lock"
      parameter-4-111 =
        (
          if ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.trn-type = 'спи':U " + " " + where-phrase-111) <> ""
          then  substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and                             buf_ingr_fbr-line.trn-type = &1&3&1', chr(34), f-doc.doc-code, 'спи':U ) + " " + where-phrase-111
          else "true"
        )
      parameter-5-111 = (" " + "" + " " + "")
      parameter-6-111 = if sort-phrase-111 = ''
                           then
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + sort-phrase-111
        )
      parameter-7-111 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-111 =
          ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.trn-type = 'спи':U " + " " + where-phrase-111 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ingr:handle
                          ,input parameter-3-111
                          ,input parameter-4-111
                          ,input parameter-5-111
                          ,input parameter-6-111
                          ,input parameter-7-111
                          )
      .
      assign
        l-filter-open-111 = true
      .
    end.
    if l-filter-open-111 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-111 = false then do:
    open query br-ingr for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.trn-type = 'спи':U
      indexed-reposition
  .
  end.
         end.
      when "goods"
      then
         do:
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-113  as logical   no-undo .
define variable  l-filter-open-113    as logical   .
define variable  flt-rec-113       as recid     no-undo .
define variable  filter-name-113      as character no-undo .
define variable  where-phrase-113     as character no-undo .
define variable  sort-phrase-113      as character no-undo .
define variable  where-phrase-rus-113 as character no-undo .
define variable  sort-phrase-rus-113  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-113
  ,output filter-name-113
  ,output where-phrase-113
  ,output sort-phrase-113
  ,output where-phrase-rus-113
  ,output sort-phrase-rus-113
  ).
  assign
    l-filter-open-113 = false
  .
  if flt-rec-113 <> ?
    or ingr-sort-column-phrase > ""
  then do:
    define variable  parameter-2-113 as character no-undo .
    define variable  parameter-3-113 as character no-undo .
    define variable  parameter-4-113 as character no-undo .
    define variable  parameter-5-113 as character no-undo .
    define variable  parameter-6-113 as character no-undo .
    define variable  parameter-7-113 as character no-undo .
      assign
      parameter-3-113 =
                              "for each buf_ingr_fbr-line no-lock"
      parameter-4-113 =
        (
          if ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no and                             buf_ingr_fbr-line.artic = flt-gds.artic and                             buf_ingr_fbr-line.prod-type = flt-gds.prod-type and                             buf_ingr_fbr-line.prod-code = flt-gds.prod-code" + " " + where-phrase-113) <> ""
          then  substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and                             buf_ingr_fbr-line.is-comp = no and                             buf_ingr_fbr-line.artic = &1&3&1 and                             buf_ingr_fbr-line.prod-type = &1&4&1 and                             buf_ingr_fbr-line.prod-code = &5'                            , chr(34), f-doc.doc-code, flt-gds.artic, flt-gds.prod-type, flt-gds.prod-code ) + " " + where-phrase-113
          else "true"
        )
      parameter-5-113 = (" " + "" + " " + "")
      parameter-6-113 = if sort-phrase-113 = ''
                           then
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + sort-phrase-113
        )
      parameter-7-113 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-113 =
          ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no and                             buf_ingr_fbr-line.artic = flt-gds.artic and                             buf_ingr_fbr-line.prod-type = flt-gds.prod-type and                             buf_ingr_fbr-line.prod-code = flt-gds.prod-code" + " " + where-phrase-113 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ingr:handle
                          ,input parameter-3-113
                          ,input parameter-4-113
                          ,input parameter-5-113
                          ,input parameter-6-113
                          ,input parameter-7-113
                          )
      .
      assign
        l-filter-open-113 = true
      .
    end.
    if l-filter-open-113 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-113 = false then do:
    open query br-ingr for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no and                             buf_ingr_fbr-line.artic = flt-gds.artic and                             buf_ingr_fbr-line.prod-type = flt-gds.prod-type and                             buf_ingr_fbr-line.prod-code = flt-gds.prod-code
      indexed-reposition
  .
  end.
         end.
      when "recipe"
      then
         do:
            if can-find (first ub.fbr-line where ub.fbr-line.is-comp = yes
               and ub.fbr-line.doc-code = f-doc.doc-code no-lock)
               then
            do:
               if available buf_comp_fbr-line
                  then
               do:
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-115  as logical   no-undo .
define variable  l-filter-open-115    as logical   .
define variable  flt-rec-115       as recid     no-undo .
define variable  filter-name-115      as character no-undo .
define variable  where-phrase-115     as character no-undo .
define variable  sort-phrase-115      as character no-undo .
define variable  where-phrase-rus-115 as character no-undo .
define variable  sort-phrase-rus-115  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-115
  ,output filter-name-115
  ,output where-phrase-115
  ,output sort-phrase-115
  ,output where-phrase-rus-115
  ,output sort-phrase-rus-115
  ).
  assign
    l-filter-open-115 = false
  .
  if flt-rec-115 <> ?
    or ingr-sort-column-phrase > ""
  then do:
    define variable  parameter-2-115 as character no-undo .
    define variable  parameter-3-115 as character no-undo .
    define variable  parameter-4-115 as character no-undo .
    define variable  parameter-5-115 as character no-undo .
    define variable  parameter-6-115 as character no-undo .
    define variable  parameter-7-115 as character no-undo .
      assign
      parameter-3-115 =
                              "for each buf_ingr_fbr-line no-lock"
      parameter-4-115 =
        (
          if ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                                     buf_ingr_fbr-line.is-comp = no and                                     buf_ingr_fbr-line.recipe-code = cur-recipe-code " + " " + where-phrase-115) <> ""
          then  substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and                                     buf_ingr_fbr-line.is-comp = no and                                     buf_ingr_fbr-line.recipe-code = &1&3&1'                                    , chr(34), f-doc.doc-code, cur-recipe-code ) + " " + where-phrase-115
          else "true"
        )
      parameter-5-115 = (" " + "" + " " + "")
      parameter-6-115 = if sort-phrase-115 = ''
                           then
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + sort-phrase-115
        )
      parameter-7-115 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-115 =
          ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                                     buf_ingr_fbr-line.is-comp = no and                                     buf_ingr_fbr-line.recipe-code = cur-recipe-code " + " " + where-phrase-115 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ingr:handle
                          ,input parameter-3-115
                          ,input parameter-4-115
                          ,input parameter-5-115
                          ,input parameter-6-115
                          ,input parameter-7-115
                          )
      .
      assign
        l-filter-open-115 = true
      .
    end.
    if l-filter-open-115 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-115 = false then do:
    open query br-ingr for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code and                                     buf_ingr_fbr-line.is-comp = no and                                     buf_ingr_fbr-line.recipe-code = cur-recipe-code
      indexed-reposition
  .
  end.
               end.
               else
               do:
                  message
                     "Недоступна запись составного товара."
                     view-as alert-box error.
               end.
            end.
            else
            do:
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-117  as logical   no-undo .
define variable  l-filter-open-117    as logical   .
define variable  flt-rec-117       as recid     no-undo .
define variable  filter-name-117      as character no-undo .
define variable  where-phrase-117     as character no-undo .
define variable  sort-phrase-117      as character no-undo .
define variable  where-phrase-rus-117 as character no-undo .
define variable  sort-phrase-rus-117  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-117
  ,output filter-name-117
  ,output where-phrase-117
  ,output sort-phrase-117
  ,output where-phrase-rus-117
  ,output sort-phrase-rus-117
  ).
  assign
    l-filter-open-117 = false
  .
  if flt-rec-117 <> ?
    or ingr-sort-column-phrase > ""
  then do:
    define variable  parameter-2-117 as character no-undo .
    define variable  parameter-3-117 as character no-undo .
    define variable  parameter-4-117 as character no-undo .
    define variable  parameter-5-117 as character no-undo .
    define variable  parameter-6-117 as character no-undo .
    define variable  parameter-7-117 as character no-undo .
      assign
      parameter-3-117 =
                              "for each buf_ingr_fbr-line no-lock"
      parameter-4-117 =
        (
          if ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                         buf_ingr_fbr-line.is-comp = no and                         buf_ingr_fbr-line.recipe-code = '' " + " " + where-phrase-117) <> ""
          then  substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and                         buf_ingr_fbr-line.is-comp = no and                         buf_ingr_fbr-line.recipe-code = &1&3&1'                        , chr(34), f-doc.doc-code, '':U) + " " + where-phrase-117
          else "true"
        )
      parameter-5-117 = (" " + "" + " " + "")
      parameter-6-117 = if sort-phrase-117 = ''
                           then
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + sort-phrase-117
        )
      parameter-7-117 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-117 =
          ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                         buf_ingr_fbr-line.is-comp = no and                         buf_ingr_fbr-line.recipe-code = '' " + " " + where-phrase-117 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ingr:handle
                          ,input parameter-3-117
                          ,input parameter-4-117
                          ,input parameter-5-117
                          ,input parameter-6-117
                          ,input parameter-7-117
                          )
      .
      assign
        l-filter-open-117 = true
      .
    end.
    if l-filter-open-117 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-117 = false then do:
    open query br-ingr for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code and                         buf_ingr_fbr-line.is-comp = no and                         buf_ingr_fbr-line.recipe-code = ''
      indexed-reposition
  .
  end.
            end.
         end.
      when "all"
      then
         do:
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-119  as logical   no-undo .
define variable  l-filter-open-119    as logical   .
define variable  flt-rec-119       as recid     no-undo .
define variable  filter-name-119      as character no-undo .
define variable  where-phrase-119     as character no-undo .
define variable  sort-phrase-119      as character no-undo .
define variable  where-phrase-rus-119 as character no-undo .
define variable  sort-phrase-rus-119  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-119
  ,output filter-name-119
  ,output where-phrase-119
  ,output sort-phrase-119
  ,output where-phrase-rus-119
  ,output sort-phrase-rus-119
  ).
  assign
    l-filter-open-119 = false
  .
  if flt-rec-119 <> ?
    or ingr-sort-column-phrase > ""
  then do:
    define variable  parameter-2-119 as character no-undo .
    define variable  parameter-3-119 as character no-undo .
    define variable  parameter-4-119 as character no-undo .
    define variable  parameter-5-119 as character no-undo .
    define variable  parameter-6-119 as character no-undo .
    define variable  parameter-7-119 as character no-undo .
      assign
      parameter-3-119 =
                              "for each buf_ingr_fbr-line no-lock"
      parameter-4-119 =
        (
          if ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no " + " " + where-phrase-119) <> ""
          then  substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and                             buf_ingr_fbr-line.is-comp = no'                             , chr(34), f-doc.doc-code ) + " " + where-phrase-119
          else "true"
        )
      parameter-5-119 = (" " + "" + " " + "")
      parameter-6-119 = if sort-phrase-119 = ''
                           then
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + ingr-sort-column-phrase +
        " " + sort-phrase-119
        )
      parameter-7-119 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-119 =
          ("buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no " + " " + where-phrase-119 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ingr:handle
                          ,input parameter-3-119
                          ,input parameter-4-119
                          ,input parameter-5-119
                          ,input parameter-6-119
                          ,input parameter-7-119
                          )
      .
      assign
        l-filter-open-119 = true
      .
    end.
    if l-filter-open-119 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
    end.
  end.
  if l-filter-open-119 = false then do:
    open query br-ingr for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code and                             buf_ingr_fbr-line.is-comp = no
      indexed-reposition
  .
  end.
         end.
      otherwise
      do:
         message
            "Неизвестный режим:" rs-one-all
            view-as alert-box error.
      end.
   end case.
   apply "value-changed" to br-ingr in frame D-FBR-DOC.
END PROCEDURE.
PROCEDURE process-parts :
   do
      on error undo, return error
      :
      define input parameter p-doc-code       as character    no-undo.
      define input parameter p-trn-type       as character    no-undo.
      define input parameter p-recipe-code    as character    no-undo.
      define input parameter p-artic          as character    no-undo.
      define input parameter p-prod-type      as character    no-undo.
      define input parameter p-prod-code      as integer      no-undo.
      define variable v-gds-code    as integer   no-undo .
      define variable v-parts-recid as recid     no-undo.
      define variable v-status      as character no-undo.
      define variable v-doc-qnty    as decimal   no-undo.
      define variable v-void        as decimal   no-undo.
      define variable v-sum-base    as decimal   no-undo.
      define variable v-sum-rubl    as decimal   no-undo.
      define variable v-vat-base    as decimal   no-undo.
      define variable v-vat-rubl    as decimal   no-undo.
      define buffer buf_doc-line for ub.doc-line.
      define buffer buf_trn-doc  for ub.trn-doc.
      define buffer buf_fbr-line for ub.fbr-line.
      define buffer buf_fbr-doc  for ub.fbr-doc.
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
      do transaction
         on error undo, return error
         :
         find first buf_fbr-doc no-lock
            where buf_fbr-doc.doc-code = p-doc-code
            .
         find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = p-doc-code
            .
         find first buf_doc-line exclusive-lock
            where buf_doc-line.doc-code    = buf_trn-doc.doc-code
            and buf_doc-line.artic       = p-artic
            and buf_doc-line.prod-type   = p-prod-type
            and buf_doc-line.prod-code   = p-prod-code
            no-error.
         if not available buf_doc-line
            then
         do:
            message
               "При списании товара по выбранной строке документа производства"
               skip
               "не была создана соответствующая строка в складском документе списания."
               skip(1)
               skip
               "Просмотр партий невозможен."
               view-as alert-box warning.
            undo, return error.
         end.
         assign
            v-doc-qnty          = buf_doc-line.doc-qnty
            v-status            = buf_trn-doc.status_
            buf_trn-doc.status_ = 'накл':U
            .
         run str/parts-l.w (
            input parparentproc
            , input f-doc.obj-type
            , input f-doc.obj-code
            , input v-gds-code
            , input p-doc-code
            , input ( if p-doc-mode = 'ПРОСМОТР':U
            then 'ПРОСМОТР':U
            else 'ИЗМЕНЕНИЕ':U
            )
            , input 'документ':U
            , input 'текущий':U
            , input 'документ':U
            , output v-parts-recid
            ) no-error.
         if error-status :error
            then
         do:
            if error-status :get-message(1) <> ""
               then
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip
                  "Ошибка при вызове интерфейса работы с партиями товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return error .
            end.
         end.
if session :set-wait-state( "compiler" ) then.
         find current buf_doc-line exclusive-lock.
         if buf_doc-line.doc-qnty <> v-doc-qnty
            then
         do:
            message
               "При изменении количества по партиям списанного товара"
               skip
               "было изменено общее количество товара в документе."
               skip(1)
               skip
               "Произвести такое изменение количеств по партиям невозможно."
               skip
               "Операция будет отменена."
               view-as alert-box error.
            undo, return error.
         end.
         assign
            buf_trn-doc.status_ = v-status
            .
         run str/fbrclcln.p (
            input buf_doc-line.doc-code
            , input p-doc-code
            , input p-trn-type
            , input p-recipe-code
            , input p-artic
            , input p-prod-type
            , input p-prod-code
            , input buf_fbr-doc.is-free
            ) no-error .
         if error-status:error then
         do:
            undo, return error substitute("Ошибка при расчете строки (&5 &6&7) для документа производства &1&2&3&2&4"
               , buf_doc-line.doc-code
               , chr(10)
               , error-status:get-message(1)
               , return-value
               , p-artic
               , p-prod-type
               , p-prod-code
               ).
         end.
      end.
      apply "entry" to br-ingr in frame D-FBR-DOC.
if session :set-wait-state( "" ) then.
   end.
END PROCEDURE.
PROCEDURE select-fbroperator :
   define output parameter p-obj-fbroperator   as character        no-undo.
   define variable v-fbroperator       as integer no-undo.
   define variable v-clients-recid-int as integer no-undo.
   define variable v-clients-recid     as recid   no-undo.
   define buffer buf_clients for ub.clients.
   do
      for buf_clients
      on error undo, return error
      :
      if v-fbr-doc-fbroperator-code <> 0
         then
      do:
         find first buf_clients no-lock
            where buf_clients.obj-type = 'чел':U
            and buf_clients.obj-code = v-fbr-doc-fbroperator-code
            no-error.
         if available buf_clients
            then
         do:
            assign
               v-clients-recid = recid( buf_clients )
               .
         end.
      end.
      run ref/cli-all.w (
         input parparentproc
         , input "b-sel":U
         , input 'чел':U
         , input 'все':U
         , input 'текущие':U
         , input v-clients-recid
         , input ",,,,,,NO,,":U
         , input "":U
         , output ref-list
         ).
      assign
         v-clients-recid-int = integer( ref-list )
    no-error.
      if error-status :error
         then
      do:
         assign
            v-fbr-doc-fbroperator-code = 0
            p-obj-fbroperator          = "":U
            .
      end.
      else
      do:
         find first buf_clients no-lock
            where recid( buf_clients ) = v-clients-recid-int
            no-error.
         if not available buf_clients
            then
         do:
            assign
               v-fbr-doc-fbroperator-code = 0
               p-obj-fbroperator          = "":U
               .
         end.
         else
         do:
            assign
               v-fbr-doc-fbroperator-code = buf_clients.obj-code
               p-obj-fbroperator          = buf_clients.obj-name
               .
         end.
      end.
      run str/fbrattrw.p (
         input f-doc.doc-code
         , input 'fbroperator':U
         , input string( v-fbr-doc-fbroperator-code )
         ) no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Не удалось записать оператора производства."
            skip(1)
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
      end.
   end.
END PROCEDURE.
FUNCTION need-marks RETURNS logical
(buffer local-fbr-line for ub.fbr-line ):
  define buffer bf_gds for ub.goods.
  define buffer buf_marking-lines      for ub.marking-lines .
  define buffer buf_marking      for ub.marking .
  define variable varvalue as character no-undo .
  define variable vartype as character no-undo .
  define variable v-marks-qnty as decimal no-undo init 0.0 .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as decimal no-undo .
  find first bf_gds where bf_gds.artic      = local-fbr-line.artic
                      and bf_gds.prod-type  = local-fbr-line.prod-type
                      and bf_gds.prod-code  = local-fbr-line.prod-code
                      .
  v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, bf_gds.gds-code) .
  RUN gds-attr-value (
      INPUT bf_gds.gds-code,
      INPUT 'mark-type':U,
      OUTPUT varvalue,
      OUTPUT vartype
      ).
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(varvalue)
  or v-isweighed
  then do :
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = bf_gds.gds-code
                                         and buf_marking-lines.obj-type = f-doc.obj-type
                                         and buf_marking-lines.obj-code = f-doc.obj-code
                                         and buf_marking-lines.in-code  = "manufacturing"
                                         and buf_marking-lines.out-code = local-fbr-line.doc-code
                                         and buf_marking-lines.part-code = local-fbr-line.recipe-code
                                         and buf_marking-lines.prt-code = 0
    :
      if v-isweighed
      then do :
        for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
          v-mark-weight = MarkWeight(buf_marking.mark) .
          assign v-marks-qnty = v-marks-qnty + v-mark-weight .
        end .
      end .
      else do :
        v-GTIN = getGtinByDM(buf_marking-lines.mark) .
        v-GTIN-qnty = getQntyCodeByGtin(v-GTIN) .
        if v-GTIN-qnty = 1
        then do :
          v-marks-qnty = v-marks-qnty + v-GTIN-qnty .
        end .
      end .
    end .
    if v-marks-qnty <> local-fbr-line.fact-qnty
    then return yes .
    else return no .
  end .
  else return no .
end function.
procedure rowdisp :
  if need-marks(buffer buf_ingr_fbr-line)
  then do ii = 1 to extent (bcol):
    if valid-handle (bcol[ii])
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
end procedure.
PROCEDURE select-fbrpaycode :
   define input parameter p-fbrpaycode         as integer          no-undo.
   define output parameter p-new-fbrpaycode    as integer          no-undo.
   define variable v-pay-type-recid as character no-undo .
   define buffer buf_pay-type for ub.pay-type.
   do
      for buf_pay-type
      on error undo, return error
      :
      run ref/paytype.w (
         input parparentproc
         , "b-sel":U
         , output v-pay-type-recid
         ).
      if v-pay-type-recid = ""
         then
      do:
         assign
            p-new-fbrpaycode = p-fbrpaycode
            .
      end.
      else
      do:
         find first buf_pay-type no-lock
            where recid( buf_pay-type ) = integer(v-pay-type-recid)
            .
         assign
            p-new-fbrpaycode = buf_pay-type.obj-code
            .
      end.
   end.
END PROCEDURE.
PROCEDURE set-comp-qnty :
   do
      on error undo, return error
      :
      define input parameter p-comp-v-fbr-doc-line-recid    as recid        no-undo.
      define input parameter p-comp-qnty          as decimal      no-undo.
      define variable v-doc-code    as character no-undo.
      define variable v-recipe-code as character no-undo.
      define variable v-is-fixed    as logical   init no no-undo.
      define buffer buf_fbr-doc         for ub.fbr-doc.
      define buffer buf_fbr-line        for ub.fbr-line.
      define buffer buf_recipe_fbr-line for ub.fbr-line.
      find first buf_recipe_fbr-line exclusive-lock
         where recid( buf_recipe_fbr-line ) = p-comp-v-fbr-doc-line-recid
         .
      assign
         buf_recipe_fbr-line.fact-qnty = p-comp-qnty
         v-doc-code                    = buf_recipe_fbr-line.doc-code
         v-recipe-code                 = buf_recipe_fbr-line.recipe-code
         .
      find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = v-doc-code
         .
      if buf_fbr-doc.obj-type <> v-price-sale-obj-type
         or buf_fbr-doc.obj-code <> v-price-sale-obj-code
         then
      do:
         assign
            v-is-fixed = yes
            .
      end.
      for each buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = v-doc-code
         and buf_fbr-line.recipe-code   = v-recipe-code
         on error undo, return error
         :
         find first buf_recipe_fbr-line exclusive-lock
            where recid( buf_recipe_fbr-line ) = recid( buf_fbr-line )
            .
         if buf_recipe_fbr-line.is-calc = no
            then
         do:
            run fbrlib-calc-prices in this-procedure (
               input recid( buf_recipe_fbr-line )
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , output buf_recipe_fbr-line.price-sale
               ) no-error.
            if error-status:error then
            do:
               message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
                  , chr(10)
                  , error-status:get-message(1)
                  , return-value )
                  view-as alert-box error .
               undo, return error .
            end.
            assign
               buf_recipe_fbr-line.is-calc = v-is-fixed
               .
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE show-line-and-recipe :
   define input parameter p-comp-v-fbr-doc-line-recid    as recid            no-undo.
   define variable v-out-string as character no-undo.
   define buffer buf_fbr-line       for ub.fbr-line.
   define buffer buf_i_fbr-line     for ub.fbr-line.
   define buffer buf_fbr-recipe     for ub.fbr-recipe.
   define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_fbr-line
      , buf_i_fbr-line
      , buf_fbr-recipe
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-comp-v-fbr-doc-line-recid
         no-error.
      if available buf_fbr-line
         then
      do:
         find first buf_fbr-recipe no-lock
            where buf_fbr-recipe.doc-code    = buf_fbr-line.doc-code
            and buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
            .
         assign
            v-out-string = substitute(  "Составной товар: &2&1    &4  &5 &6 &7"
                                        , chr(10)
                                        , buf_fbr-line.artic
                                        , buf_fbr-line.fact-qnty
                                        , buf_fbr-line.price-sum-rubl
                                        , buf_fbr-line.price-sum-base
                                        , buf_fbr-line.price-sum-vat-rubl
                                        , buf_fbr-line.price-sum-vat-base
                                     )
            v-out-string = v-out-string
                            + substitute(  "&1Рецепт: &2&1    &3 &4&1&1Ингредиенты:"
                                        , chr(10)
                                        , buf_fbr-recipe.recipe-code
                                        , buf_fbr-recipe.qnty
                                        , buf_fbr-recipe.recipe-qnty
                                     )
            .
         for each buf_i_fbr-line no-lock
            where buf_i_fbr-line.doc-code    = buf_fbr-line.doc-code
            and buf_i_fbr-line.is-comp     = no
            and buf_i_fbr-line.recipe-code = buf_fbr-line.recipe-code
            on error undo, return error
            :
            assign
               v-out-string = v-out-string
                                + substitute(  "&1&2:  &3 &4 &5 &6 &7 &8 &9"
                                            , chr(10)
                                            , buf_i_fbr-line.artic
                                            , buf_i_fbr-line.fact-qnty
                                            , buf_i_fbr-line.coeff-value
                                            , buf_i_fbr-line.coeff-waste
                                            , buf_i_fbr-line.price-sum-rubl
                                            , buf_i_fbr-line.price-sum-base
                                            , buf_i_fbr-line.price-sum-vat-rubl
                                            , buf_i_fbr-line.price-sum-vat-base
                                        )
               .
            find first buf_fbr-recipe-gds no-lock
               where buf_fbr-recipe-gds.doc-code      = buf_i_fbr-line.doc-code
               and buf_fbr-recipe-gds.recipe-code   = buf_i_fbr-line.recipe-code
               and buf_fbr-recipe-gds.prod-type     = buf_i_fbr-line.prod-type
               and buf_fbr-recipe-gds.prod-code     = buf_i_fbr-line.prod-code
               and buf_fbr-recipe-gds.artic         = buf_i_fbr-line.artic
               .
            assign
               v-out-string = v-out-string
                                + substitute(  "&1 &2 &3 &4 &5 &6 &7 &8"
                                            , chr(10)
                                            , buf_fbr-recipe-gds.qnty
                                            , buf_fbr-recipe-gds.calc-method
                                            , buf_fbr-recipe-gds.coeff-value
                                            , buf_fbr-recipe-gds.coeff-waste
                                            , buf_fbr-recipe-gds.brutto-qnty
                                            , buf_fbr-recipe-gds.recipe-qnty
                                            , buf_fbr-recipe-gds.recipe-brutto-qnty
                                          )
               .
         end.
      end.
      message
         v-out-string
         view-as alert-box information
         title "Строки документа производства."
         .
   end.
END PROCEDURE.
PROCEDURE UI-on :
   def input param fnc as character no-undo.
   define variable v-have-rights as logical no-undo.
   do
      on error undo, return error
      :
      run assign-obj-fbroperator in this-procedure no-error.
      if error-status :error
         then
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip
            "Невозможно отобразить имя оператора производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
      end.
      display
         obj-fbroperator
         with frame D-FBR-DOC.
      find first flt-gds no-lock
         where recid (flt-gds) = gds-rec
         no-error.
      if fnc = "enable"
         then
      do:
         VIEW FRAME D-FBR-DOC.
         enable
            b-exit
            b-lkp
            b-help
            b-recipe
            b-gds
            br-comp
            br-ingr
            rs-one-all
            with frame D-FBR-DOC.
         assign
            b-add:MENU-MOUSE          = 1
            b-del:MENU-MOUSE          = 1
            b-rsrv:MENU-MOUSE         = 1
            r-outs:MENU-MOUSE         = 1
            frame D-FBR-DOC:title = substitute( "&1 &2 : &3   № &4  - &5"
                                            , f-doc.obj-type
                                            , string (f-doc.obj-code, ">>>>9")
                                            , f-doc.status_
                                            , f-doc.doc-code
                                            , p-doc-mode
                                        )
            .
         case rs-one-all :
            when "goods"
            then
               do:
                  if available flt-gds
                     then
                  do:
                  end.
                  else
                  do:
                     message
                        "Нет текущего товара для фильтрации ни в верхнем, ни в нижнем списке."
                        view-as alert-box.
                     assign
                        rs-one-all = "all"
                        .
                     run UI-on ("enable").
                  end.
               end.
         end case.
         assign
            v-have-rights = yes
            .
         if f-doc.is-free = yes
            then
         do:
define variable vss-include-info121 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_free-update':U
    ,input  'object':U
    ,input  f-doc.host-code
    ,input  f-doc.obj-type
    ,input  f-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
         end.
         if f-doc.is-free = no
            or f-doc.status_ = 'факт':U
            or v-have-rights = no
            or p-doc-mode      = 'ПРОСМОТР':U
            then
         do:
            assign
               buf_comp_fbr-line.price-rubl :read-only         in browse br-comp = yes
               buf_comp_fbr-line.price-sum-vat-rubl :read-only in browse br-comp = yes
               .
         end.
         case p-doc-mode :
            when 'ПРОСМОТР':U
            then
               do:
                  enable
                     b-prev
                     b-next
                     with frame D-FBR-DOC.
               end.
            when 'ИЗМЕНЕНИЕ':U
            then
               do:
                  if f-doc.status_ = 'новый':U
                     then
                  do:
                     enable
                        b-add
                        b-chg
                        b-del
                        out-code
                        r-outs
                        b-calc-comp
                        b-calc-ingr
                        r-price
                        r-fbroperator
                        fi-pay-code
                        r-pay
                        b-add-marks
                        with frame D-FBR-DOC.
                     hide
                        b-parts
                        in frame D-FBR-DOC.
                  end.
                  if f-doc.status_ = 'разрешен':U
                     then
                  do:
                     enable
                        b-rsrv
                        b-parts
                        with frame D-FBR-DOC.
                  end.
                  if f-doc.status_ <> 'факт':U AND v-back-date then
                  do:
                     enable
                        fact-date
                        shift-sel
                        when is-shift-on
                        with frame D-FBR-DOC.
                  end.
               end.
         end case.
         if rs-one-all = "type"
            then
         do:
            disable
               b-add
               b-chg
               b-del
               out-code
               r-outs
               b-calc-comp
               b-calc-ingr
               b-rsrv
               r-fbroperator
               fi-pay-code
               fi-pay-type-name
               r-pay
               with frame D-FBR-DOC.
            assign
               buf_ingr_fbr-line.fact-qnty:read-only           in browse br-ingr = yes
               buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-base:read-only  in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-rubl:read-only  in browse br-ingr = yes
               buf_ingr_fbr-line.price-sale:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.is-calc:read-only             in browse br-ingr = yes
               buf_ingr_fbr-line.fix-cost:read-only            in browse br-ingr = yes
               buf_comp_fbr-line.is-calc:read-only             in browse br-comp = yes
               buf_comp_fbr-line.fix-cost:read-only            in browse br-comp = yes
               .
         end.
         else
         do:
            assign
               buf_ingr_fbr-line.fact-qnty:read-only in browse br-ingr          = (p-doc-mode = 'ПРОСМОТР':U or f-doc.status_ <> 'новый':U)
               buf_ingr_fbr-line.price-base:read-only in browse br-ingr         = yes
               buf_ingr_fbr-line.price-rubl:read-only in browse br-ingr         = yes
               buf_ingr_fbr-line.price-sum-vat-base:read-only in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-rubl:read-only in browse br-ingr = yes
               buf_ingr_fbr-line.fix-cost:read-only in browse br-ingr           = (p-doc-mode = 'ПРОСМОТР':U or f-doc.status_ <> 'разрешен':U)
               buf_ingr_fbr-line.price-sale:read-only in browse br-ingr         = (p-doc-mode = 'ПРОСМОТР':U or f-doc.status_ <> 'новый':U)
               buf_ingr_fbr-line.is-calc:read-only in browse br-ingr            = buf_ingr_fbr-line.price-sale:read-only in browse br-ingr
               buf_comp_fbr-line.is-calc:read-only in browse br-comp            = buf_ingr_fbr-line.price-sale:read-only in browse br-ingr
               buf_comp_fbr-line.fix-cost:read-only in browse br-comp           = buf_ingr_fbr-line.fix-cost:read-only in browse br-ingr
               .
         end.
         if rs-one-all = "goods"
            then
         do:
            disable
               b-add
               b-del
               with frame D-FBR-DOC.
         end.
define variable vss-include-info122 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_price-sale-ingr':U
    ,input  'object':U
    ,input  f-doc.host-code
    ,input  f-doc.obj-type
    ,input  f-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
         if v-have-rights = no
            then
         do:
            assign
               buf_ingr_fbr-line.price-sale :read-only         in browse br-ingr = yes
               .
         end.
      end.
      if f-doc.status_ = 'разрешен':U
         then
      do:
         enable
            b-parts
            with frame D-FBR-DOC.
      end.
      display
         rs-one-all
         fi-pay-code
         fi-pay-type-name
         with frame D-FBR-DOC.
      if r-outs:sensitive
         then
      do:
         display
            "" @ out-code
            with frame D-FBR-DOC.
      end.
      else
      do:
         hide
            out-code
            r-outs
            in frame D-FBR-DOC.
      end.
      if r-price:sensitive
         then
      do:
         display
            v-price-sale-obj-type + " " + string( v-price-sale-obj-code ) @ obj-price
            with frame D-FBR-DOC.
      end.
      else
      do:
         hide
            obj-price
            r-price
            in frame D-FBR-DOC.
      end.
      run open-comp in this-procedure.
      run open-ingr in this-procedure ( input ( if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ? ) ).
      if v-fbr-doc-line-rec = ?
         then
      do:
         if v-fbr-doc-rep-rec <> ?
            and rs-one-all <> "all"
            then
         do:
            assign
               rs-one-all = "all"
               .
            run UI-on ("enable").
         end.
      end.
      else
      do:
         reposition br-comp to recid (v-fbr-doc-line-rec) no-error.
      end.
      apply "value-changed" to br-comp in frame D-FBR-DOC.
      apply "value-changed" to br-ingr in frame D-FBR-DOC.
      apply "entry" to br-comp in frame D-FBR-DOC.
      if available buf_comp_fbr-line then
      do:
         current-browse = br-comp :handle.
      end.
      else
      do:
         apply "entry" to br-ingr.
         if available buf_ingr_fbr-line then
         do:
            current-browse = br-ingr :handle.
         end.
      end.
      if v-fbr-doc-rep-rec <> ?
         then
      do:
         reposition br-ingr to recid( v-fbr-doc-rep-rec ) no-error.
      end.
   end.
END PROCEDURE.
FUNCTION get-goods-name RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID ) :
   define variable v-gds-name as character no-undo.
   RUN get-goods-name-proc in this-procedure (
      input p-fbr-line-recid
      , output v-gds-name
      ).
   return ( v-gds-name ).
END FUNCTION.
FUNCTION get-line-OK RETURNS logical
   ( p-fbr-line-recid AS RECID ) :
   define variable v-line-ok as logical no-undo.
   run get-line-OK-proc in this-procedure (
      input p-fbr-line-recid
      , output v-line-ok
      ).
   return v-line-ok.
END FUNCTION.
FUNCTION get-netto-qnty RETURNS DECIMAL
   ( p-fbr-line-recid AS RECID ) :
   define variable v-netto-qnty as decimal no-undo.
   run get-netto-qnty-proc in this-procedure (
      input p-fbr-line-recid
      , output v-netto-qnty
      ).
   return v-netto-qnty.
END FUNCTION.
FUNCTION get-prod-ref RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID  ) :
   define variable v-prog-string as character no-undo.
   run get-prod-ref-proc in this-procedure (
      input p-fbr-line-recid
      , output v-prog-string
      ).
   return v-prog-string.
END FUNCTION.
FUNCTION get-unit-base RETURNS CHARACTER
   (  p-fbr-line-recid AS RECID  ) :
   define variable v-unit-base as character no-undo.
   run get-unit-base-proc in this-procedure (
      input p-fbr-line-recid
      , output v-unit-base
      ).
   return v-unit-base.
END FUNCTION.
