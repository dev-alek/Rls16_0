using ibs.th.skt.Adapters.LogWrite.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
using ibs.th.skt.ControlledClients.*.
define input parameter p-param as character no-undo.
define input parameter p-hide as logical no-undo.
define input parameter p-user-login    as character no-undo .
define input parameter p-user-password as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "4GL socket server (HTTPD)".
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable mLableText as character no-undo.
define variable mStartTime as datetime-tz no-undo init ?.
procedure addtask:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   if mStartTime ne ?
   then
      mAsyncHelper:AddTask (ITask,iProc,iParam,mStartTime).
   else
      mAsyncHelper:AddTask (ITask,iProc,iParam).
   unsubscribe "PutFileLogAsunc".
end.
procedure addTaskTime:
   define input  parameter ITask      as character no-undo.
   define input  parameter iProc      as character no-undo.
   define input  parameter iParam     as character no-undo.
   define input  parameter iStartTime as datetime-tz no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   mAsyncHelper:AddTask (ITask,iProc,iParam,iStartTime).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitproc:
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,?,1,itext + " " + mLableText).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitProcLable:
   define input  parameter itext  as character no-undo.
   mLableText = itext.
end.
procedure waitProcShed:
   define input  parameter iSched as character no-undo.
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,iSched,1,itext).
   unsubscribe "PutFileLogAsunc".
end.
procedure WriteLogAsync:
   define input  parameter iFile as character no-undo.
   define variable vText as character no-undo.
   define variable vFile as longchar  no-undo.
   define variable vfileName as character no-undo.
   define variable vi as int64 no-undo.
   define variable vStr  as character no-undo.
   vfileName = mAsyncHelper:objExists(iFile,"f").
   if vfileName ne ?
   then do:
      copy-lob from file vfileName to vFile no-error.
      if error-status:error
      then do:
         run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).
      end.
      else do:
          vFile = replace (vFile,chr(13) + chr(10),chr(10)).
          do vi = 1 to num-entries(vFile,chr(10)) - 1:
            run write-to-log-notime (entry(vi, vFile,chr(10))).
         end.
      end.
   end.
   else do:
       assign
           vtext = substitute ("Процедура обработки данных не завершена. &1",ifile).
       run write-to-log (vtext).
   end.
end.
define new shared variable g#LogStr       as character no-undo .
define shared     variable g#auto-user-id as character no-undo .
define shared     variable g#auto-user-login as character no-undo .
define shared     variable g#auto-user-password as character no-undo .
define variable mWork         as logical no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile: defc-gds.i $ $Revision: 47e5c2a27e63, 2885, rls $".
DEFINE  TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD producer-int      as integer
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
FIELD bc-on              like ub.prod-bc.bc-on
FIELD gds-name          like ub.goods.gds-name
FIELD gds-namelong      like ub.goods.gds-name
FIELD gds-name1         like ub.goods.gds-name
FIELD f-name            like ub.gds-prt.f-name
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate
FIELD std-discnt-rule   as integer
FIELD temp-discnt-rule  as integer
FIELD temp-discnt-method as character
FIELD VAT-pc            like ub.doc-line.VAT-pc
FIELD vat-code          like ub.tax-rate-gds.rate-code
FIELD SLT-pc            like ub.doc-line.SLT-pc
FIELD grp-code          like ub.goods.grp-code
FIELD gds-stat          as integer FORMAT "999"
FIELD wd-rule          as integer
FIELD wgd-rule         as integer
FIELD fp               as logical
FIELD zp               as integer
FIELD pp               as integer
FIELD need-auth        as integer
FIELD is-menu          as integer
FIELD is-semi-finished as integer
FIELD is-modificator   as integer
FIELD DepartId         as integer
FIELD fbr-grp-code-0   as integer
FIELD fbr-grp-code     as integer
FIELD office           as integer
field office-type      as character
FIELD CalculationMethod      as integer
FIELD CalculationMethodRestr as integer
FIELD price-sale       like ub.price-list.price-sale
FIELD unit-type        like ub.units.type
FIELD unit-cli-type    like ub.units.type
FIELD tax-string       as char FORMAT "X(255)"
FIELD qnty-discnt-rule as integer
FIELD kat-discnt-rule  as integer
FIELD kat-discnt-method as character
FIELD date-discnt-rule as integer
FIELD abs-discnt-rule  as integer
FIELD tot-discnt-rule  as integer
FIELD fact-qnty        like ub.gds-obj.fact-qnty
FIELD free-qnty        like ub.gds-obj.free-qnty
FIELD producer         as character format "X(40)"
FIELD ingredient       as character format "X(40)"
FIELD GTD              as character format "X(31)"
FIELD alpha1           like ub.goods.alpha
FIELD node-code        like ub.bar-code.node-code
FIELD okei             like ub.units.okei
FIELD kkt              as integer
FIELD is-gas           as logical
FIELD ptrl-as-good     as logical
FIELD taracode         as character
FIELD crf              as integer
FIELD new-good         as logical
FIELD rc               as recid
FIELD obj-type         as character
FIELD obj-code         as integer
field is-main-code     as logical
field bc-on-type       as character
field main-prt-b-code  as integer
field ean-lz as character
field ean-rz as character
field code-short as  character
index pi is unique primary crf
index bc b-code
index pbc b-str
index igds gds-code
index mbc obj-type obj-code main-prt-b-code
.
define temp-table temp-dis-gds-rule no-undo
like ub.dis-gds-rule.
define temp-table cash-gds-discnt
FIELD crf              as integer
FIELD b-code            like ub.bar-code.b-code
field discnt-value as decimal
FIELD rule-num     as integer
field obj-type     as character
field obj-code     as integer
index pi is unique primary crf
index bc
b-code
obj-type
obj-code
rule-num
.
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
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
CREATE WIDGET-POOL.
define variable hServerSocket    as handle       no-undo.
define variable v-connect-param  as CHAR         no-undo.
define variable v-srv-connected  as LOG          no-undo.
define variable us-tmo           as INTEGER   INIT 60 no-undo.
if num-entries (p-param, ";") = 2
then do:
  v-connect-param = entry (1, p-param, ";").
  us-tmo = integer (entry (2, p-param, ";")) no-error.
  if us-tmo = ?
  then us-tmo = 60.
end.
else do:
  v-connect-param = p-param.
end.
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON Btn-st
     LABEL "Старт"
     SIZE 10 BY 1.
DEFINE BUTTON Btn-log
     LABEL "Вкл. расширеный лог."
     SIZE 22 BY 1.
DEFINE VARIABLE auto-log AS longchar
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 96 BY 20 NO-UNDO.
DEFINE VARIABLE mPort AS integer FORMAT ">>>>9"
     LABEL "Порт"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE FRAME DEFAULT-FRAME
     b-help AT ROW 1.17 COL 89 WIDGET-ID 4
     b-exit AT ROW 1.25 COL 2.5 WIDGET-ID 2
     Btn-st AT ROW 1.25 COL 12.5 WIDGET-ID 6
     Btn-log AT ROW 1.25 COL 37
     mPort AT ROW 1.25 COL 24
     auto-log AT ROW 3 COL 2.5 NO-LABEL WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99 BY 22.58 WIDGET-ID 100.
IF SESSION:DISPLAY-TYPE = "GUI":U  and not session:batch-mode THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Сокет-сервер"
         HEIGHT             = 22.58
         WIDTH              = 99
         MAX-HEIGHT         = 30.04
         MAX-WIDTH          = 128
         VIRTUAL-HEIGHT     = 30.04
         VIRTUAL-WIDTH      = 128
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE C-Win = CURRENT-WINDOW.
ASSIGN
       auto-log:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = yes.
if valid-handle(C-Win) then
do:
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  mWork = no.
  RETURN NO-APPLY.
END.
end.
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME
DO:
RUN proc-stop-srv.
PAUSE 2.
APPLY 'close':U TO THIS-PROCEDURE.
mWork = no.
END.
ON CHOOSE OF Btn-st IN FRAME DEFAULT-FRAME
DO:
assign mPort.
IF v-srv-connected = NO THEN
  RUN proc-start-srv IN THIS-PROCEDURE NO-ERROR.
ELSE  RUN proc-stop-srv IN THIS-PROCEDURE NO-ERROR.
END.
ON CHOOSE OF Btn-log IN FRAME DEFAULT-FRAME
DO:
   ibs.th.skt.Adapters.LogWrite:isDebugMod = not ibs.th.skt.Adapters.LogWrite:isDebugMod.
   if ibs.th.skt.Adapters.logWrite:isDebugMod
   then
      btn-log:LABEL IN FRAME DEFAULT-FRAME = "Выкл. расширеный лог.".
   else
      btn-log:LABEL IN FRAME DEFAULT-FRAME = "Вкл. расширеный лог.".
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DEFAULT-FRAME
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
on choose of b-help in frame DEFAULT-FRAME
do:
  apply "help":u to frame DEFAULT-FRAME .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DEFAULT-FRAME:width - 0.3
                fh            = frame DEFAULT-FRAME:first-child
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
if valid-handle(C-Win) then
do:
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
end.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
IF v-connect-param > ''
then do:
   if (trim(v-connect-param)begins "-S")
   then do:
      mPort = int(substring (trim(v-connect-param), 3)).
   end.
end.
if mPort eq 0
then do:
  RUN write-to-log-event('Не указаны параметры подключения!').
  RUN write-to-log-event('Параметры задаются -param "Sock:-S <Port>" или -param "M:<h+>Sock:<Port>" ').
  mPort = 8080.
  RUN write-to-log-event('Задаем порт по умочанию 8080').
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if not p-hide then do:
      if valid-handle(C-Win) then
        C-Win:HIDDEN = no.
      RUN enable_UI.
  end.
  define variable sktserv  as class SktServer no-undo.
  define variable logWrite as class LogWrite  no-undo.
  if ibs.th.skt.Adapters.logWrite:isDebugMod
   then
      btn-log:LABEL IN FRAME DEFAULT-FRAME = "Выкл. расширеный лог.".
   else
      btn-log:LABEL IN FRAME DEFAULT-FRAME = "Вкл. расширеный лог.".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output g#db-num
  )  .
  g#language = 'RUS'.
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  run gbl/get-gbl.p no-error.
  if error-status:error
  then do:
    message "Ошибка получения глобальный переменных." view-as alert-box.
    return error.
  end.
  logWrite = new LogWrite().
  sktserv  = new SktServer(this-procedure,us-tmo).
  apply 'choose':U to Btn-st.
  mWork = yes.
  subscribe "write-to-log" anywhere run-procedure "write-to-log-event".
  subscribe "write-to-log-codepage" anywhere run-procedure "write-to-log-event-codepage".
  subscribe "runCDn" anywhere.
  subscribe "runLmStatus" anywhere.
  define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.
  CheckUpd = new ibs.th.adm.upd.CheckUpd ().
  mAsyncHelper = new ibs.th.file.AsyncHelperth().
  mAsyncHelper:mProcPublish = this-procedure.
  mAsyncHelper:setCurrentUserPasswd().
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:WritelogInter = 5.
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:maxproc    = 1.
  run runCDN (1).
  run runLmStatus.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
  do while mWork:
     if valid-object(sktserv)
     then
        if sktserv:checkEnd()
           or mAsyncHelper:isWorkShed()
        then do:
           wait-for close of this-procedure pause 0.001.
           mAsyncHelper:WaitForOne(?).
        end.
        else do:
           if  CheckUpd:isStopWork or CheckUpd:isNeedUpd
           then do:
              RUN proc-stop-srv.
              mWork = no.
           end.
           else do:
                if valid-handle(C-Win) then
                  wait-for connect of hServerSocket or choose of Btn-st or close of this-procedure pause 60.
                else
                  wait-for connect of hServerSocket or close of this-procedure pause 60.
           end.
        end.
     else
       wait-for choose of Btn-st or close of this-procedure.
  end.
  delete object mAsyncHelper no-error.
  unsubscribe "write-to-log".
  unsubscribe "write-to-log-codePage".
  unsubscribe "runCDN".
  unsubscribe "runLmStatus".
END.
delete object logWrite.
PROCEDURE connproc :
  define input parameter hSocket as handle no-undo.
  sktserv:connproc(hSocket).
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY auto-log mport
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-help b-exit Btn-st Btn-log auto-log mport
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  VIEW C-Win.
END PROCEDURE.
PROCEDURE proc-start-srv :
DEF VAR vl-cnt AS LOG NO-UNDO.
CREATE SERVER-SOCKET hServerSocket.
hServerSocket:SET-CONNECT-PROCEDURE ("connProc":U).
vl-cnt = hServerSocket:ENABLE-CONNECTIONS("-S " + string(mPort)) NO-ERROR.
if vl-cnt = NO THEN do:
  RUN write-to-log-event(substitute('Ошибка запуска сервера &1!',error-status:get-message(1) )).
  return.
end.
v-srv-connected = YES.
RUN write-to-log-event(substitute('Запущен сокет-сервер с параметрами: -S &1 ', mPort)).
RUN write-to-log-event(substitute ("http://localhost:&1/help - описание запросов",mPort)).
mport:sensitive  in FRAME DEFAULT-FRAME = false.
btn-st:LABEL IN FRAME DEFAULT-FRAME = 'Стоп'.
sktserv  = new SktServer(this-procedure, us-tmo).
END PROCEDURE.
PROCEDURE proc-stop-srv :
DEF VAR vl-dis AS LOG NO-UNDO.
mport:sensitive  in FRAME DEFAULT-FRAME = true.
vl-dis = hServerSocket:disable-CONNECTIONS() NO-ERROR.
IF NOT vl-dis THEN DO:
  RUN write-to-log-event(substitute('Ошибка остановки сервера &1!',error-status:get-message(1) )).
  return.
END.
DELETE OBJECT sktserv no-error.
DELETE OBJECT hServerSocket no-error.
IF NOT valid-handle(hServerSocket) THEN
RUN write-to-log-event(substitute('Остановлен сокет-сервер (&1)',v-connect-param)).
ELSE RETURN.
v-srv-connected = NO.
btn-st:LABEL IN FRAME DEFAULT-FRAME = 'Старт'.
END PROCEDURE.
PROCEDURE write-to-log-event :
   DEFINE INPUT PARAMETER itext       AS character NO-UNDO.
   run write-to-log-event-codepage(itext, ?).
end.
PROCEDURE write-to-log-event-codepage :
DEFINE INPUT PARAMETER itext       AS character NO-UNDO.
define input parameter iSourcePage as character no-undo.
define variable str as char no-undo.
auto-log:move-to-eof( ) IN FRAME DEFAULT-FRAME NO-ERROR.
if objExists(itext,"F") eq ?
then do:
   str = cur-time-string-msec() + chr(9) + itext + chr(10).
   auto-log:insert-string( str ) NO-ERROR.
   RUN write-to-log-file(str).
end.
else do:
   def var varfile-str as longchar no-undo.
   if  itext ne "filewrireLog.txt"
   then do:
      str = cur-time-string-sec() + chr(9) + "Файл: " +  itext + chr(10).
      auto-log:insert-string(str) NO-ERROR.
      auto-log:insert-file(search(itext)) no-error.
   end.
   else do:
      str = cur-time-string-sec() + chr(10).
      auto-log:insert-string(str) NO-ERROR.
      auto-log:insert-file(search(itext)) no-error.
   end.
   if    iSourcePage eq ""
      or iSourcePage eq ?
   then
      copy-lob
         file itext
         to object varfile-str
      no-error.
   else
      copy-lob
         file itext
         to object varfile-str convert source codepage iSourcePage
      no-error.
   RUN write-to-log-file(varfile-str + chr(10)).
end.
END PROCEDURE.
PROCEDURE write-to-log-file :
DEFINE INPUT PARAMETER str-long AS longchar NO-UNDO.
define variable vFileName as character no-undo.
str-long = cur-time-string-msec() + chr(9) + str-long + chr(10) .
vFileName = "sktsrv-" + replace(string(today),"/","-") + ".log".
copy-lob
from object str-long
to file vFileName append
no-error
.
END PROCEDURE.
procedure runCdn:
   define input param iTypeUpd as integer no-undo.
   run utl/runproc-cdn.p ("CDN",this-procedure,iTypeUpd).
end procedure.
procedure runLMStatus:
   run utl/runproc-lmsts.p ("LM-STATUS",this-procedure).
end procedure.
