block-level on error undo, throw.
define input parameter p-silent                       as logical no-undo .
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter pardoc-date like ub.wth-doc.doc-date no-undo .
define input parameter parfact-date like ub.wth-doc.fact-date no-undo .
define input parameter parshift-date like ub.wth-doc.shift-date no-undo .
define input parameter parshift-num like ub.wth-doc.shift-num no-undo .
define input parameter parshift-name like ub.wth-doc.shift-name no-undo .
define input parameter par-operator like ub.wth-doc.operator no-undo .
define input parameter par-deliver like ub.wth-doc.deliver no-undo .
define input parameter par-receiver like ub.wth-doc.receiver no-undo .
define input parameter par-inv-prs4 like ub.wth-doc.inv-prs4 no-undo .
define input parameter par-inv-prs5 like ub.wth-doc.inv-prs5 no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter parbef-sum like ub.wth-doc.doc-sum no-undo .
define input parameter paraft-sum like ub.wth-doc.fact-sum no-undo .
define input parameter par-PS like ub.wth-doc.PS no-undo .
define input parameter par-status_ like ub.wth-doc.status_ no-undo .
define input parameter parlines-exist as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-inv1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-inv1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в документе МЦ инвентаризации".
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
define temp-table tt-wth-doc no-undo like ub.wth-doc.
procedure wth-doch_write-wth-doc-history :
define parameter buffer buf_wth-doc for tt-wth-doc.
define input parameter p-doc-code  like ub.wth-doc.doc-code no-undo .
define input parameter p-host-code like ub.wth-doc.host-code no-undo .
define input parameter p-obj-type  like ub.wth-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.wth-doc.obj-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable varobj-date as date no-undo .
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable varshift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable v-create-hist as logical no-undo .
define variable v-result as character no-undo .
define buffer buf_c-wth-doc for ub.c-wth-doc.
define buffer buf_c-wth-line for ub.c-wth-line.
define buffer buf_c-wth-dtl for ub.c-wth-dtl.
define buffer prev_c-wth-line for ub.c-wth-line.
define buffer prev_c-wth-dtl for ub.c-wth-dtl.
do
on error undo, return error return-value
:
  run cur-time in this-procedure(output v-date, output v-time).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output varobj-date
  ) no-error .
  if error-status :error
  or varobj-date = ?
  then do:
   v-message = substitute("Нет текущей даты на объекте документа МЦ &1 &2&3&4&5 &6"
                , buf_wth-doc.doc-code
                , p-obj-type
                , p-obj-code
                , chr(10)
                , error-status:get-message(1)
                , return-value
                ).
    undo, return error v-message.
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
      varshift-name = ?
    .
  end.
  create buf_c-wth-doc.
  buffer-copy buf_wth-doc to buf_c-wth-doc
  assign
  buf_c-wth-doc.doc-code           = p-doc-code
  buf_c-wth-doc.obj-type           = p-obj-type
  buf_c-wth-doc.obj-code           = p-obj-code
  buf_c-wth-doc.host-code          = p-host-code
  buf_c-wth-doc.chip-num           = next-value (s-corr-chip, ub)
  buf_c-wth-doc.corr-time          = v-time
  buf_c-wth-doc.corr-user-db-num   = g#db-num
  buf_c-wth-doc.corr-user-name     = g#userid
  buf_c-wth-doc.corr-date          = varobj-date
  buf_c-wth-doc.corr-inkas-code    = "":U
  buf_c-wth-doc.corr-shift-date    = varshift-date
  buf_c-wth-doc.corr-shift-num     = varshift-num
  buf_c-wth-doc.corr-shift-name    = varshift-name
  buf_c-wth-doc.real-corr-date     = v-date
  .
  for each ub.wth-line where
          ub.wth-line.doc-code = buf_wth-doc.doc-code:
    create buf_c-wth-line.
    buffer-copy ub.wth-line to buf_c-wth-line
    assign
    buf_c-wth-line.chip-num           = buf_c-wth-doc.chip-num
    buf_c-wth-line.corr-user-db-num   = buf_c-wth-doc.corr-user-db-num
    .
  end.
  for each ub.wth-dtl where
          ub.wth-dtl.doc-code = buf_wth-doc.doc-code:
    create buf_c-wth-dtl.
    buffer-copy ub.wth-dtl to buf_c-wth-dtl
    assign
    buf_c-wth-dtl.chip-num           = buf_c-wth-doc.chip-num
    buf_c-wth-dtl.corr-user-db-num   = buf_c-wth-doc.corr-user-db-num
    .
  end.
    release buf_c-wth-doc.
end.
end procedure.
DEFINE VARIABLE loc#log as logical no-undo .
define variable v-mes     as character no-undo .
define variable v-file    as logical no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE parcli-type like ub.wth-doc.cli-type no-undo .
DEFINE VARIABLE parcli-code like ub.wth-doc.cli-code no-undo .
DEFINE VARIABLE l-shift-on as logical no-undo .
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE varcli-name like ub.clients.obj-name no-undo .
define buffer buf_c-wth-doc for ub.c-wth-doc.
DEF TEMP-TABLE t_t-plc NO-UNDO
  FIELD w-p-code LIKE ub.wth-place.w-p-code
  FIELD w-p-name LIKE ub.wth-place.w-p-name
  INDEX t_t-pi   IS   PRIMARY UNIQUE w-p-code
.
_main:
do
on error undo, return error
:
  assign
  parcli-type = 'орг':U
  parcli-code = parhost-code
  .
  if NOT (par-mode = 'ДОБАВЛЕНИЕ':U OR par-mode = 'ИЗМЕНЕНИЕ':U) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
    return error '':U.
  end.
  if par-status_ = 'факт':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-status_" par-status_
    view-as alert-box ERROR.
    return error '':U.
  end.
  if can-find(FIRST ub.wth-doc where
                    ub.wth-doc.doc-code = pardoc-code and
                  recid(wth-doc) <> par-rid) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-rid" par-rid skip
    " и/или pardoc-code " pardoc-code
    view-as alert-box ERROR.
    return error '':U.
  end.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    run gbl/factdate.p (
                      INPUT        parobj-type,
                      INPUT        parobj-code,
                      INPUT-OUTPUT f-date,
                      INPUT-OUTPUT f-time,
                      INPUT-OUTPUT s-date,
                      INPUT-OUTPUT s-num,
                      INPUT-OUTPUT s-name,
                      INPUT        (not p-silent)
                        ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        undo _main, return error return-value .
      END.
  end.
  run trg/wth-inv2.p (
                  input yes,
                  input pardoc-code,
                  input parhost-code,
                  input parobj-type,
                  input parobj-code,
                  input par-operator,
                  input par-deliver,
                  input par-receiver,
                  input par-inv-prs4,
                  input par-inv-prs5,
                  input parauto-fill,
                  input parlines-exist,
                  input no,
                  output varcli-name) no-error.
  if error-status:error then do:
    undo _main, return error return-value.
  end.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable l-in-ov5 as logical no-undo .
define variable v-date5 as date no-undo .
define variable v-time5 as integer no-undo .
run cur-time in this-procedure(output v-date5, output v-time5).
CREATE ub.wth-doc.
ASSIGN
  ub.wth-doc.host-code = parhost-code
  ub.wth-doc.doc-code  = TRIM( STRING( NEXT-VALUE( s-wth-doc, ub), ">>>>>>>>>9":U ) ) + "-" + TRIM( STRING( parobj-code, ">>>>>>>>9":U ) ) +                   SUBSTR( parobj-type, ( IF g#language = "RUS" THEN 1 ELSE 2 ), 1 )
   ub.wth-doc.doc-type  = 'инв':U
  ub.wth-doc.ext-doc-type  = 'iy':U
  ub.wth-doc.inter_    = if  lookup(ub.wth-doc.ext-doc-type,'ij,pj,fj,jj,oj,ej':U) > 0 then yes else no
  ub.wth-doc.exter_    = if  lookup(ub.wth-doc.ext-doc-type,'ie,ee,we,pc,ps,iy,pz,df,dp,dc,xc':U) > 0 then yes else no
  ub.wth-doc.status_   = 'накл':U
  ub.wth-doc.obj-type  = parobj-type
  ub.wth-doc.obj-code  = parobj-code
  ub.wth-doc.creid     = g#userid
  ub.wth-doc.credate   = v-date5
.
if ub.wth-doc.doc-type = 'инв':U or lookup(ub.wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
   or ub.wth-doc.doc-type = 'декл':U then do:
  assign
    ub.wth-doc.cli-type  = 'орг':U
    ub.wth-doc.cli-code  = parhost-code
    .
end.
else if ub.wth-doc.ext-doc-type = 'ps':U then do:
  assign
  ub.wth-doc.cli-type  = parobj-type
  ub.wth-doc.cli-code  = parobj-code
  .
end.
else if ub.wth-doc.inter_  = yes
then do:
  assign
  ub.wth-doc.cli-type  = parobj-type
  ub.wth-doc.cli-code  = parobj-code
  .
end.
else if ub.wth-doc.exter_  = yes
then do:
  assign
  ub.wth-doc.cli-type  =  (if parcli-type <> "" then parcli-type else 'орг':U)
  ub.wth-doc.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    ub.wth-doc.cli-type  = parobj-type
    ub.wth-doc.cli-code  = 0
.
    assign
    par-rid = recid(ub.wth-doc)
    .
  end.
  else do:
    FIND FIRST ub.wth-doc EXCLUSIVE-LOCK WHERE
              recid(ub.wth-doc) = par-rid NO-WAIT NO-ERROR.
    if locked ub.wth-doc then do:
      v-mes = substitute( "Документ занят"
                          ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    end.
    if not avail ub.wth-doc then do:
      v-mes = substitute( "Не найден документ МЦ"
                          ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    end.
    if ub.wth-doc.status_ <> par-status_ then do:
      v-mes = substitute( "Неверный вызов - с изменением статуса документа МЦ с &1 на &2"
                          ,ub.wth-doc.status_
                          , par-status_
                          ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    end.
    if ub.wth-doc.auto-fill <> parauto-fill then do:
      v-mes = substitute( "Неверный вызов - с изменением типа заполнения документа МЦ"
                          ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    end.
    if ub.wth-doc.status_ <> 'накл':U then dO:
      if ub.wth-doc.doc-code <> pardoc-code OR
        ub.wth-doc.host-code <> parhost-code OR
        ub.wth-doc.obj-type <> parobj-type OR
        ub.wth-doc.obj-code <> parobj-code OR
        ub.wth-doc.doc-date <> pardoc-date OR
        ub.wth-doc.shift-date <> parshift-date OR
        ub.wth-doc.shift-num <> parshift-num OR
        ub.wth-doc.shift-name <> parshift-name OR
        ub.wth-doc.bef-sum <> parbef-sum
        then do:
        v-mes = substitute( "Документ МЦ имеет статус &1 возможно изменить только сумму факт, примечание&2" +
                            "и состав инвентаризационной комиссии"
                          , ub.wth-doc.status_
                            ).
        run err-mess(input-output v-mes).
        var-entry = "":U.
        undo _main, return error (if p-silent then v-mes else var-entry).
      end.
    end.
    create tt-wth-doc.
    buffer-copy ub.wth-doc to tt-wth-doc.
  end.
  assign
  ub.wth-doc.cli-name = varcli-name
  ub.wth-doc.doc-code = (if par-mode = 'ДОБАВЛЕНИЕ':U then ub.wth-doc.doc-code else pardoc-code)
  ub.wth-doc.host-code = parhost-code
  ub.wth-doc.obj-type = parobj-type
  ub.wth-doc.obj-code = parobj-code
  ub.wth-doc.cli-type = 'орг':U
  ub.wth-doc.cli-code = parcli-code
  ub.wth-doc.doc-date = pardoc-date
  ub.wth-doc.fact-date = parfact-date
  ub.wth-doc.shift-date = parshift-date
  ub.wth-doc.shift-num = parshift-num
  ub.wth-doc.shift-name = parshift-name
  ub.wth-doc.operator = par-operator
  ub.wth-doc.deliver = par-deliver
  ub.wth-doc.receiver = par-receiver
  ub.wth-doc.inv-prs4 = par-inv-prs4
  ub.wth-doc.inv-prs5 = par-inv-prs5
  ub.wth-doc.doc-type = 'инв':U
  ub.wth-doc.auto-fill = parauto-fill
  ub.wth-doc.exter_ = yes
  ub.wth-doc.inter_ = no
  ub.wth-doc.PS = par-PS
  ub.wth-doc.status_ = par-status_
  ub.wth-doc.ext-doc-type = 'iy':U
  .
  release ub.wth-doc no-error.
  if error-status:error then do:
      v-mes = substitute("Ошибка при сохранении документа&1&2 &3", chr(10), error-status:get-message(1), return-value ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  find last buf_c-wth-doc no-lock where
            buf_c-wth-doc.doc-code = pardoc-code
        AND  buf_c-wth-doc.corr-user-db-num = g#db-num no-error.
  if (not par-mode = 'ДОБАВЛЕНИЕ':U and tt-wth-doc.creid <> g#userid
  and not available buf_c-wth-doc)
  or (available buf_c-wth-doc
  and buf_c-wth-doc.corr-user-name <> g#userid)
  then do:
    run wth-doch_write-wth-doc-history in this-procedure (
                                                            buffer tt-wth-doc
                                                            ,input pardoc-code
                                                            ,input parhost-code
                                                            ,input parobj-type
                                                            ,input parobj-code) no-error .
    if error-status:error then do:
      v-mes = error-status:get-message(1) .
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
  end.
  return '':U.
end.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("Документ МЦ №&1: &2&3&4&5", pardoc-code, parobj-type, parobj-code, chr(10), p-mes).
  if not p-silent then
  message
  p-mes
  view-as alert-box error .
END PROCEDURE.
