DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE BUFFER locked_payment FOR ub.payment.
DEFINE TEMP-TABLE tt-payment NO-UNDO LIKE ub.payment.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char  no-undo.
define input-output param  p-rid   as   recid           no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
DEFINE INPUT PARAMETER psource-type like ub.payment.source-type no-undo.
DEFINE INPUT PARAMETER psource-ref  like ub.payment.source-ref no-undo.
define input parameter p-d-card as character no-undo .
DEFINE INPUT PARAMETER ptot-cli like ub.payment.tot-cli no-undo.
DEFINE INPUT PARAMETER pexch-code like ub.payment.exch-code no-undo.
DEFINE INPUT PARAMETER pbase-rate like ub.payment.base-rate no-undo.
DEFINE INPUT PARAMETER pbase-scale like ub.payment.base-scale no-undo.
DEFINE INPUT PARAMETER pexch-rate like ub.payment.exch-rate no-undo.
DEFINE INPUT PARAMETER pexch-scale like ub.payment.exch-scale no-undo.
DEFINE INPUT PARAMETER pexch-date like ub.payment.exch-date no-undo.
DEFINE INPUT PARAMETER ppay-code like ub.payment.pay-code no-undo.
DEFINE INPUT PARAMETER pdate-pay like ub.payment.fact-date no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Обещанный платеж" .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-labels no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
procedure tempchgs-create-lable-record :
define input parameter p-t_name as character no-undo .
define input parameter p-f_name as character no-undo .
define input parameter p-l_name as character no-undo .
define input parameter p-f_update as logical no-undo .
define input parameter p-f_parent as character no-undo .
define input parameter p-f_visible as logical no-undo .
define buffer buf_temp-labels for temp-labels.
  do
  on error undo, return error
  :
     find first buf_temp-labels where
              buf_temp-labels.t_name = p-t_name
          and buf_temp-labels.f_name = p-f_name no-error.
     if not available buf_temp-labels then do:
      create buf_temp-labels.
      assign
      buf_temp-labels.t_name = p-t_name
      buf_temp-labels.f_name = p-f_name
      buf_temp-labels.l_name = p-l_name
      .
     end.
     assign
     buf_temp-labels.f_can_update = p-f_update
     buf_temp-labels.f_parent = p-f_parent
     buf_temp-labels.f_visible = p-f_visible
     buf_temp-labels.f_root = (if p-f_parent = '':U then p-f_name else p-f_parent)
     buf_temp-labels.num_ = 0
     .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcont_v-num_ as integer no-undo .
define  temp-table temp-tables no-undo
field tbl-name as character
field new-tbl-handle as handle
field new-table-handle as handle
index pi is unique primary
tbl-name.
define  temp-table temp-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
procedure tempcont_create-changes :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-tbl-handle as handle    no-undo.
define input  parameter p-ttbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .
define variable v-chg-fields as character no-undo .
define variable v-ii as integer no-undo .
define variable fh-main as handle no-undo .
define variable fh-temp as handle no-undo .
define variable fh as handle no-undo .
define variable th as handle no-undo .
define variable v-main-value as character no-undo .
define variable v-temp-value as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ind as integer no-undo .
define variable v-keys as character no-undo .
if p-tbl-handle:available then do:
  if p-tbl-handle:buffer-compare( p-ttbl-handle) = yes then return.
end.
do v-ii = 1 to min(p-tbl-handle:num-fields, p-ttbl-handle:num-fields):
  assign
  fh-main      = p-tbl-handle:buffer-field( v-ii )
  fh-temp      = p-ttbl-handle:buffer-field( v-ii )
  .
  if fh-main:name = fh-temp:name
  and fh-main:data-type = fh-temp:data-type then do:
    if fh-main:buffer-value ne fh-temp:buffer-value then do:
      if p-action = integer('1':U) then do:
        assign
        fh = fh-temp
        th = p-ttbl-handle
        v-main-value = fh-main:initial
        v-keys  = p-ttbl-handle:keys
        .
      end.
      else do:
        assign
        fh = fh-main
        th = p-tbl-handle
        v-main-value = fh-main:string-value
        v-keys  = p-tbl-handle:keys
        .
      end.
      assign
      v-temp-value = fh-temp:string-value
     .
     if v-uniq-key-rec = '':U then do:
        v-uniq-key-rec = p-tbl-name.
        do v-ind = 1 to num-entries(v-keys)
        on error undo, return error
        :
          assign
          fh = th:buffer-field(entry(v-ind, v-keys))
          v-uniq-key-rec = v-uniq-key-rec + chr(3) + substitute("&1", fh:buffer-value())
          .
        end.
      end.
      create temp-changes.
      assign
      temp-changes.t_name = p-tbl-name
      temp-changes.f_name = fh-main:name
      temp-changes.l_name = '':U
      temp-changes.v_old  = v-main-value
      temp-changes.v_new  = v-temp-value
      temp-changes.action = p-action
      temp-changes.uniq-key-rec = v-uniq-key-rec
      temp-changes.num_   = tempcont_v-num_ + 1
      tempcont_v-num_     = tempcont_v-num_ + 1
      .
    end.
  end.
end.
end procedure.
procedure tempcont_create-record :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-new-tbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .
do
on error  undo, return error substitute( "&1 (tempcont_create-record). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1 (tempcont_create-record). stop", vss-include-info4 )
on endkey undo, return error substitute( "&1 (tempcont_create-record). endkey", vss-include-info4 )
:
  define variable tt-name          as character no-undo .
  define variable tth              as handle    no-undo .
  define variable bh_tt            as handle    no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define variable v-inform         as character no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-idx-field-qnty as integer   no-undo .
  define variable v-where          as character no-undo .
  define variable v-word-link      as character no-undo .
  define variable v-field-name     as character no-undo .
  define variable fh_tbl-name      as handle    no-undo .
  define variable fh_tt            as handle    no-undo .
  define variable v-field-val      as character no-undo .
  define variable compare-log      as logical no-undo .
  define buffer buf_temp-tables  for temp-tables.
  if not p-new-tbl-handle:available then do:
    return error substitute( "&1. Переданный буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
  end.
  assign
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
  .
  find first buf_temp-tables where
            buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    create temp-table tth.
    assign
      tt-name = "wt-" + p-tbl-name
      tth:undo = no
    .
    v-ok = yes.
    assign
      v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (1)", vss-include-info4, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (2)", vss-include-info4, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    buf_temp-tables.new-table-handle = tth
    .
    assign
    bh_tt = buf_temp-tables.new-tbl-handle
    .
  end.
  else do:
    if p-new-tbl-handle:table-handle = buf_temp-tables.new-tbl-handle:table-handle then do:
      assign
      bh_tt = p-new-tbl-handle
      .
    end.
    else do:
      assign
      bh_tt = buf_temp-tables.new-tbl-handle
      .
    end.
  end.
  assign
  v-inform = bh_tt:index-information(1)
  v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = bh_tt:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1 (tempcont_create-record). Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1 (tempcont_create-record). Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
  end.
  assign
    v-where     = "where":U
    v-word-link = "":U
  .
  block_where:
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh_tbl-name  = bh_tt:buffer-field( v-field-name )
      fh_tt        = p-new-tbl-handle:buffer-field( v-field-name )
      v-field-val  = fh_tt:buffer-value
      v-where      = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, fh_tbl-name:table, v-field-name )
    .
    if fh_tbl-name:data-type ="character":U then do:
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
      v-where = substitute( "&1 &2", v-where, v-field-val )
    .
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  bh_tt:find-first( v-where, exclusive-lock ) no-error .
  if not bh_tt:available then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании буфера временной таблицы.", vss-include-info4, p-tbl-name ).
    end.
    assign
      compare-log = false
    .
  end.
  else do:
    assign
      compare-log = bh_tt:buffer-compare( p-new-tbl-handle )
    .
  end.
  if compare-log = false then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-copy( p-new-tbl-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). BUFFER-COPY не прошел для таблицы &2", vss-include-info4, p-tbl-name ).
    end.
  end.
  assign
    v-ok = false
  .
  assign
    v-ok = bh_tt:buffer-release() no-error
  .
  if v-ok <> true then do:
    return error substitute( "&1 (tempcont_create-record). buffer-release не прошел для таблицы &2", vss-include-info4, p-tbl-name ).
  end.
  assign
    v-ok = false
  .
  assign
    fh_tbl-name  = ?
    fh_tt        = ?
    bh_tt        = ?
  .
end.
end procedure.
procedure tempcont_get-buffer-handle :
define input parameter p-tbl-name as character no-undo .
define output parameter p-new-tbl-handle as handle no-undo .
do
on error undo, return error
:
  define variable tth              as handle    no-undo .
  define variable tt-name          as character no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define buffer buf_temp-tables  for temp-tables.
  find first buf_temp-tables where
           buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    create temp-table tth.
    assign
    tt-name = "wt-" + p-tbl-name
    tth:undo = no
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    v-ok = yes.
    assign
    v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (1)", vss-include-info4, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (2)", vss-include-info4, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.new-table-handle = tth
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    .
  end.
  p-new-tbl-handle = buf_temp-tables.new-tbl-handle.
end.
end procedure.
procedure tempcont_clear :
define buffer buf_temp-tables for temp-tables.
do
on error undo, return error return-value
:
  for each buf_temp-tables:
    if valid-handle(buf_temp-tables.new-table-handle) then do:
      buf_temp-tables.new-tbl-handle:empty-temp-table().
    end.
    delete object buf_temp-tables.new-table-handle.
  end.
end.
end procedure.
DEFINE VARIABLE for-pay-name like ub.pay-type.obj-name no-undo.
DEFINE BUFFER payer for ub.clients.
DEFINE BUFFER buf_Dis-card for ub.dis-card.
DEFINE BUFFER buf_ord-doc for ub.ord-doc.
DEFINE BUFFER buf_pay-type for ub.pay-type.
DEFINE BUFFER buf_curr-chk FOR ub.currency.
DEFINE BUTTON B-exch-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-pay-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-payer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE exch-code-name AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 7.6 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE pay-type-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE payer-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.payment,
      ub.clients,
      ub.currency,
      tt-payment SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 95
     tt-payment.fact-date AT ROW 3.13 COL 83.4 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     tt-payment.cli-type AT ROW 3.2 COL 11.8 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-payment.cli-code AT ROW 3.2 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-payment.due-date AT ROW 4.43 COL 83.8 COLON-ALIGNED
          LABEL "Ожид."
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     tt-payment.payer-type AT ROW 4.53 COL 11.8 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-payment.payer-code AT ROW 4.53 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
     B-payer AT ROW 4.53 COL 33.9
     tt-payment.status_ AT ROW 5.67 COL 80 COLON-ALIGNED
          LABEL "Статус"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.pay-code AT ROW 5.8 COL 11.8 COLON-ALIGNED
          LABEL "Код оплаты"
          VIEW-AS FILL-IN
          SIZE 7.5 BY 1
     B-pay-code AT ROW 5.8 COL 22.5
     tt-payment.creid AT ROW 6.93 COL 80 COLON-ALIGNED
          LABEL "Создал"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.source-type AT ROW 7.13 COL 13 COLON-ALIGNED
          LABEL "К документу"
          VIEW-AS FILL-IN
          SIZE 13.3 BY 1
     tt-payment.source-ref AT ROW 7.17 COL 33.3 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 18.4 BY 1
     tt-payment.closid AT ROW 8.2 COL 80 COLON-ALIGNED
          LABEL "Закрыл"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.tot-cli AT ROW 9.63 COL 14 COLON-ALIGNED
          LABEL "Сумма платежа"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     tt-payment.exch-code AT ROW 9.63 COL 41.6 COLON-ALIGNED
          LABEL "Вал."
          VIEW-AS FILL-IN
          SIZE 4.5 BY .97
     B-exch-code AT ROW 9.63 COL 49
     tt-payment.exch-rate AT ROW 9.63 COL 64.4 COLON-ALIGNED
          LABEL "Курс"
          VIEW-AS FILL-IN
          SIZE 11 BY 1.17
          FGCOLOR 4
     tt-payment.exch-scale AT ROW 9.63 COL 76.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.9 BY 1
     tt-payment.exch-date AT ROW 9.63 COL 82.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13.3 BY 1.17
     tt-payment.tot-base AT ROW 10.8 COL 14 COLON-ALIGNED
          LABEL "Сумма (б.в.)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-payment.base-rate AT ROW 10.8 COL 64.4 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 11.1 BY 1
          FGCOLOR 4
     tt-payment.base-scale AT ROW 10.8 COL 76.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.9 BY 1
     tt-payment.tot-rubl AT ROW 12.03 COL 14 COLON-ALIGNED
          LABEL "Сумма (rub)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-payment.PS AT ROW 14 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     buf_clients.obj-name AT ROW 3.2 COL 34 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 43 BY 1
          FGCOLOR 4
     payer-name AT ROW 4.53 COL 35.1 COLON-ALIGNED NO-LABEL
     pay-type-name AT ROW 5.8 COL 27 NO-LABEL
     exch-code-name AT ROW 9.63 COL 50.4 COLON-ALIGNED NO-LABEL
     SPACE(39.00) SKIP(6.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Платеж"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exch-code IN FRAME Dialog-Frame
DO:
  RUN local-curr-chk in this-procedure ("exch-code", "button").
  apply "entry" to tt-payment.exch-code in FRAME Dialog-Frame.
  run calc-sums in this-procedure ( input "exch-code") no-error.
  return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
IF p-mode = 'ПРОСМОТР':U THEN DO:
  UNDO, RETURN NO-APPLY.
END.
RUN proc-save IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-pay-code IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as character no-undo .
    run ref/paytype.w ( input parparentproc
                       ,input "b-sel"
                       ,output  v-ref-rec ).
    find FIRST buf_pay-type where
               recid(buf_pay-type) = integer(v-ref-rec) no-lock no-error.
   if not available buf_pay-type then return no-apply.
   DISPLAY
   buf_pay-type.obj-code @ tt-payment.pay-code
   buf_pay-type.obj-name @ pay-type-name
   WITH FRAME Dialog-Frame.
   RETURN NO-APPLY.
END.
ON CHOOSE OF B-payer IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE ref-list as char no-undo.
define variable v-ref-rec as recid no-undo .
run ref/cli-all.w ( input parparentproc
               ,input "b-sel"
               ,input 'все':U
               ,input ?
               ,input ?
               ,input ?
               ,input ?
               ,input ?
               ,output ref-list) NO-ERROR .
if ref-list <> "" then do:
  v-ref-rec = integer (ref-list).
  find payer where recid ( payer ) = v-ref-rec no-lock.
  display
  payer.obj-code @ tt-payment.payer-code
  payer.obj-type @ tt-payment.payer-type
  payer.obj-name @ payer-name
  with frame Dialog-Frame.
END.
RUN check-payer in this-procedure No-error.
IF error-status:error then do:
    return no-apply.
end.
END.
ON LEAVE OF tt-payment.base-rate IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" TO tt-payment.base-rate.
END.
ON RETURN OF tt-payment.base-rate IN FRAME Dialog-Frame
DO:
  run calc-sums in this-procedure ( input "base-rate") no-error.
END.
ON LEAVE OF tt-payment.base-scale IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" TO tt-payment.base-scale.
END.
ON RETURN OF tt-payment.base-scale IN FRAME Dialog-Frame
DO:
  run calc-sums in this-procedure ( input "base-rate") no-error.
END.
ON LEAVE OF tt-payment.exch-code IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-payment.exch-code <> tt-payment.exch-code then do:
    run local-curr-chk in this-procedure ("exch-code", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-payment.exch-code IN FRAME Dialog-Frame
OR RETURN OF tt-payment.exch-code IN FRAME Dialog-Frame DO:
  run local-curr-chk in this-procedure ("exch-code", "ret-mouse").
  apply "entry" to tt-payment.exch-code in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-payment.exch-date IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" TO tt-payment.exch-date.
END.
ON RETURN OF tt-payment.exch-date IN FRAME Dialog-Frame
DO:
END.
ON LEAVE OF tt-payment.exch-rate IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" to tt-payment.exch-rate.
END.
ON RETURN OF tt-payment.exch-rate IN FRAME Dialog-Frame
DO:
  run calc-sums in this-procedure ( input "exch-code") no-error.
END.
ON LEAVE OF tt-payment.exch-scale IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" to tt-payment.exch-scale.
END.
ON RETURN OF tt-payment.exch-scale IN FRAME Dialog-Frame
DO:
  run calc-sums in this-procedure ( input "exch-code") no-error.
END.
ON LEAVE OF tt-payment.pay-code IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" to tt-payment.pay-code.
END.
ON RETURN OF tt-payment.pay-code IN FRAME Dialog-Frame
DO:
run check-pay-code in this-procedure no-error.
if error-status:error then return no-apply.
display
buf_pay-type.obj-name @ pay-type-name
with frame Dialog-Frame.
END.
ON LEAVE OF tt-payment.payer-code IN FRAME Dialog-Frame
DO:
   FIND FIRST payer No-LOCK WHERE
              payer.obj-type = input frame Dialog-Frame tt-payment.payer-type
          AND payer.obj-code = input frame Dialog-Frame tt-payment.payer-code no-error.
   if available payer then
   DISPLAY
   payer.obj-name @ payer-name
   with frame Dialog-Frame.
   run check-payer in this-procedure no-error.
   if error-status:error then return no-apply.
END.
ON RETURN OF tt-payment.payer-code IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ref-list as char no-undo.
    define variable v-ref-rec as recid no-undo .
    FIND FIRST payer NO-LOCK WHERE
               payer.obj-type = input frame Dialog-Frame tt-payment.payer-type
           AND payer.obj-code = input frame Dialog-Frame tt-payment.payer-code no-error.
    if available payer then do:
        DISPLAY
        payer.obj-name @ payer-name
        with frame Dialog-Frame.
        return no-apply.
    end.
    else do:
        run ref/cli-all.w ( input parparentproc
                        ,input "b-add,b-sel":U
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,output ref-list) .
        if ref-list = "" then do:
            apply "entry" to tt-payment.payer-code in frame Dialog-Frame.
            return no-apply.
        end.
        v-ref-rec = integer (ref-list).
        FIND FIRST payer NO-LOCK WHERE
                   recid (payer) = v-ref-rec .
        DISPLAY
        payer.obj-type @ tt-payment.payer-type
        payer.obj-code @ tt-payment.payer-code
        payer.obj-name @ payer-name
        with frame Dialog-Frame.
        return no-apply.
    end.
END.
ON LEAVE OF tt-payment.tot-cli IN FRAME Dialog-Frame
DO:
  APPLY "RETURN" to tt-payment.tot-cli.
END.
ON RETURN OF tt-payment.tot-cli IN FRAME Dialog-Frame
DO:
  run calc-sums in this-procedure ( input "tot-cli").
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if lookup(p-mode
            ,( 'ДОБАВЛЕНИЕ':U + chr(4) +
              'ИЗМЕНЕНИЕ':U + chr(4) + 'ПРОСМОТР':U
              )
            , chr(4) ) = 0 then do:
    message
    substitute("Неверное значение параметра вызова p-mode=&1", p-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if lookup ( psource-type, 'заказ':U + chr(4) + 'payment':U, chr(4)) = 0
  and p-mode <> 'ПРОСМОТР':U
  then do:
    message
    substitute("Неверное значение параметра вызова psource-type=&1", psource-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if psource-type = 'payment':U
  and p-d-card = '':U then do:
    message
    substitute("Неверное значение параметра вызова p-d-card=&1", p-d-card)
    view-as alert-box error .
    undo main-block, return error .
  end.
  RUN fill-table IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    UNDO main-block, RETURN ERROR.
  END.
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-sums :
DEFIN INPUT PARAMETER changed as char no-undo.
CASE changed:
    WHEN "exch-code" then do:
        tt-payment.tot-cli = tt-payment.tot-rubl * (input frame Dialog-Frame tt-payment.exch-rate) /
                                     (input frame Dialog-Frame tt-payment.exch-scale).
    END.
    WHEN "tot-cli" then do:
        assign
        tt-payment.tot-cli = input frame Dialog-Frame tt-payment.tot-cli
        tt-payment.tot-rubl = tt-payment.tot-cli / ( input frame Dialog-Frame tt-payment.exch-rate /
                                       input frame Dialog-Frame tt-payment.exch-scale
                                     )
        tt-payment.tot-base = tt-payment.tot-rubl / ( input frame Dialog-Frame tt-payment.base-rate /
                                       input frame Dialog-Frame tt-payment.base-scale
                                     )
        .
    END.
    WHEN "base-rate" then do:
        assign
        tt-payment.tot-base = tt-payment.tot-rubl / ( input frame Dialog-Frame tt-payment.base-rate /
                                       input frame Dialog-Frame tt-payment.base-scale
                                     )
        .
    END.
END CASE.
DISPLAY
tt-payment.tot-cli
tt-payment.tot-base
tt-payment.tot-rubl
with frame Dialog-Frame
.
END PROCEDURE.
PROCEDURE check-pay-code :
find FIRST buf_pay-type where
           buf_pay-type.obj-code = input frame Dialog-Frame tt-payment.pay-code no-lock no-error.
if not available buf_pay-type then do:
  message "Нет вида оплаты с таким кодом.".
  apply "entry" TO tt-payment.pay-code in frame Dialog-Frame.
  return error.
end.
END PROCEDURE.
PROCEDURE check-payer :
if input frame Dialog-Frame tt-payment.payer-type = ? or
   input frame Dialog-Frame tt-payment.payer-type = "" then do:
   if can-find (ub.clients where
                ub.clients.obj-code = input frame Dialog-Frame tt-payment.payer-code AND
                ub.clients.obj-type = 'орг':U no-lock) then
    display
    'орг':U @ tt-payment.cli-type
    with frame Dialog-Frame.
    else
    display
    'чел':U @ tt-payment.cli-type with frame Dialog-Frame.
end.
find first payer where
          payer.obj-code = input frame Dialog-Frame tt-payment.payer-code
     AND payer.obj-type = input frame Dialog-Frame tt-payment.payer-type no-error.
if not available payer then do:
  if input frame Dialog-Frame tt-payment.payer-code <> ? and
     input frame Dialog-Frame tt-payment.payer-type <> ? then
    message "Неправильный код или тип плательщика.".
  apply "entry" to tt-payment.payer-code in frame Dialog-Frame.
  return error.
end.
display
payer.obj-type @ tt-payment.payer-type
with frame Dialog-Frame.
if payer.obj-type = 'орг':U
and payer.obj-code = p-curr-host-code then do:
  release payer no-error.
  message "Запрещенный код и тип плательщика.".
  apply "entry" to tt-payment.payer-code in frame Dialog-Frame.
  return error.
end.
if payer.obj-type = 'маг':U
or payer.obj-type = 'скл':U then do:
    release payer no-error.
    message "Выберите организацию или человека."
    view-as alert-box.
    apply "entry" to tt-payment.payer-type in frame Dialog-Frame.
    return error.
end.
display
payer.obj-name @ payer-name
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY payer-name pay-type-name exch-code-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_clients THEN
    DISPLAY buf_clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-payment THEN
    DISPLAY tt-payment.fact-date tt-payment.cli-type tt-payment.cli-code
          tt-payment.due-date tt-payment.payer-type tt-payment.payer-code
          tt-payment.status_ tt-payment.pay-code tt-payment.creid
          tt-payment.source-type tt-payment.source-ref tt-payment.closid
          tt-payment.tot-cli tt-payment.exch-code tt-payment.exch-rate
          tt-payment.exch-scale tt-payment.exch-date tt-payment.tot-base
          tt-payment.base-rate tt-payment.base-scale tt-payment.tot-rubl
          tt-payment.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-payment.fact-date tt-payment.due-date
         tt-payment.payer-type tt-payment.payer-code B-payer tt-payment.status_
         tt-payment.pay-code B-pay-code tt-payment.tot-cli tt-payment.exch-code
         B-exch-code tt-payment.exch-rate tt-payment.exch-scale
         tt-payment.exch-date tt-payment.base-rate tt-payment.base-scale
         tt-payment.PS payer-name pay-type-name exch-code-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-table :
DEFINE VARIABLE for-tot-cli as decimal No-UNDO.
DEFINE VARIABLE for-tot-base as decimal No-UNDO.
DEFINE VARIABLE for-date-pay as date no-undo.
DEFINE VARIABLE for-fact-date as date no-undo.
DEFINE VARIABLE for-status_ like ub.payment.status_ no-undo.
DEFINE VARIABLE max-for-tot-base as decimal No-UNDO.
DEFINE VARIABLE for-tot-rubl as decimal No-UNDO.
DEFINE VARIABLE v-base-rate as decimal no-undo.
DEFINE VARIABLE v-base-scale as decimal no-undo.
DEFINE VARIABLE v-exch-rate as decimal no-undo.
DEFINE VARIABLE v-exch-scale as decimal no-undo.
DEFINE VARIABLE v-exch-date as date no-undo.
DEFINE VARIABLE for-exch-code like ub.currency.curr-code no-undo.
DEFINE VARIABLE for-pay-code like ub.pay-type.obj-code no-undo.
DEFINE VARIABLE for-sign as decimal no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-curr-abbr as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
FIND FIRST buf_clients NO-LOCK WHERE
           buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code  No-ERROR.
IF NOT avail buf_clients then do:
    message
    substitute("Не найден контрагент &1&2 для ввода платежа"
              , p-cli-type
              , p-cli-code)
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
END.
IF buf_clients.obj-type = 'скл':U OR
   buf_clients.obj-type = 'маг':U then do:
    message
    substitute("Неверный тип контрагента &1 для ввода платежа"
                , buf_clients.obj-type )
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
end.
IF buf_clients.obj-code = p-curr-host-code and
   buf_clients.obj-type = 'орг':U then do:
    message
    substitute("Неверный контрагент &1 для ввода платежа"
              , buf_clients.obj-type )
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-curr-host-code
  ,output v-base-code
  )  .
run cur-time in this-procedure ( output v-today, output v-time).
for-date-pay = v-today.
FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = v-BASE-CODE No-ERROR.
IF NOT AVAIL buf_currency then do:
    message
    substitute("Не найдена валюта с кодом &1 для платежа &2"
                ,v-BASE-CODE
                ,locked_payment.pmnt-code)
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
END.
CASE p-mode:
WHEN 'ДОБАВЛЕНИЕ':U then do:
  FIND FIRST payer No-LOCK WHERE
            payer.obj-type = p-cli-type
        and payer.obj-code = p-cli-code No-ERROR.
  CASE psource-type:
    WHEN 'заказ':U then do:
      FIND FIRST buf_ord-doc No-LOCK WHERE
                  buf_ord-doc.doc-code = psource-ref NO-ERROR.
      if not avail buf_ord-doc then do:
        message
        substitute("Не найден заказ с N &1 для платежа"
                    , psource-ref )
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
      end.
      if buf_ord-doc.cli-type <> buf_clients.obj-type OR
      buf_ord-doc.cli-code <> buf_clients.obj-code then do:
        message
        substitute("Неверно выбран документ для платежа:&1" +
                    "Плательщик платежа =&2&3, клиент для заказа = &4&5"
                    ,buf_clients.obj-type
                    ,buf_clients.obj-code
                    ,buf_ord-doc.cli-type
                    ,buf_ord-doc.cli-code
                    )
        view-as alert-box ERROR.
      END.
      if buf_ord-doc.host-code <> p-curr-host-code then do:
          message
          "Выбран заказ чужой фирмы "
          view-as alert-box ERROR.
          return error.
      end.
      if buf_ord-doc.sum-cli = ?
      or buf_ord-doc.sum-cli = 0 then do:
          message "Нельзя создать платеж" skip
                  "сумма по заказу неопределена"
          view-as alert-box.
          return error.
      end.
      if NOT (buf_ord-doc.status_ = 'факт':U
              and buf_ord-doc.flag_ = yes) then do:
          message
          substitute("Нельзя создать платеж&1" +
                      "для заказа в статусе &2"
                      , chr(10)
                      ,(buf_ord-doc.status_ + string(buf_ord-doc.flag_, "+/-"))
                      )
          view-as alert-box.
          return error.
      end.
      ASSIGN
      for-sign = (if (buf_ord-doc.doc-type = 'ПО':U)
                  then -1
                  else 1)
      for-tot-cli = for-sign * (buf_Ord-doc.sum-cli + buf_Ord-doc.sum-ship +  buf_ord-doc.Sum-service)
      for-exch-code = buf_ord-doc.exch-code
      v-base-rate = buf_ord-doc.base-rate
      v-base-scale = buf_ord-doc.base-scale
      v-exch-rate = buf_ord-doc.exch-rate
      v-exch-scale = buf_ord-doc.exch-scale
      v-exch-date = buf_ord-doc.exch-date
      for-pay-code = (if buf_ord-doc.pay-code <> ?
                      then buf_ord-doc.pay-code
                      else ?)
      for-date-pay = (if buf_ord-doc.date-pay <> ?
                      then buf_ord-doc.date-pay
                      else for-date-pay)
      for-status_ = 'ожид':U
      for-fact-date = ?
      .
    END.
    when 'payment':U then do:
      FIND FIRST buf_sysconf NO-LOCK WHERE
                buf_sysconf.host-code = p-curr-host-code .
      FIND FIRST buf_pay-type NO-LOCK WHERE
                buf_pay-type.obj-code = buf_sysconf.ret-credit-pay NO-ERROR.
      IF NOT AVAILABLE buf_pay-type THEN DO:
        MESSAGE
        substitute("Неверно определен код оплаты для возврата кредита для фирмы &1"
                   , p-curr-host-code)
        VIEW-AS ALERT-BOX ERROR.
        p-rid = ?.
        UNDO, RETURN ERROR.
      END.
      for-pay-code = buf_pay-type.obj-code.
      FIND FIRST buf_dis-card No-LOCK WHERE
                  buf_dis-card.d-card = p-d-card NO-ERROR.
      if not avail buf_dis-card then do:
          message
          substitute("Не найдена дисконтная карта с номером &1"
                      ,p-d-card)
          view-as alert-box ERROR.
          p-rid = ?.
          return error.
      end.
      if buf_dis-card.cli-type <> buf_clients.obj-type OR
          buf_dis-card.cli-code <> buf_clients.obj-code then do:
          message
          "Неверно выбрана карта для платежа "
          view-as alert-box ERROR.
      END.
      if buf_dis-card.emitent-host-code <> p-curr-host-code
      AND buf_dis-card.emitent-host-code <> 0 then do:
          message
          "Выбрана карта чужой фирмы "
          view-as alert-box ERROR.
          return error.
      end.
      if buf_dis-card.status_ = 'блок':U
      OR buf_dis-card.status_ = 'удал':U then do:
          message
          substitute("Нельзя создать платеж&1" +
                      "для карты в статусе &2"
                      ,chr(10)
                      ,buf_dis-card.status_)
          view-as alert-box.
          return error.
      end.
      run cur-time in this-procedure( output v-today, output v-time).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  v-today
  ,output v-base-rate
  ,output v-base-scale
  ,output v-curr-abbr
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
      if v-curr-r-b = 'rubl':U then do:
        assign
        for-exch-code = 0
        v-exch-rate = 1
        v-exch-scale = 1
        .
      end.
      else do:
        assign
        for-exch-code = v-base-code
        v-exch-rate   = v-base-rate
        v-exch-scale = v-base-scale
        .
      end.
      assign
      v-exch-date = v-today
      for-date-pay = v-today
      FOR-fact-date = v-today
      for-tot-cli = 0
      for-status_ = 'факт':U
      .
    end.
  END CASE.
  assign
  for-tot-rubl = for-tot-cli / ( v-exch-rate / v-exch-scale)
  for-tot-base = for-tot-rubl / (v-base-rate / v-base-scale)
  .
  if for-pay-code <> ? then do:
      FIND FIRST buf_pay-type where
                  buf_pay-type.obj-code = for-pay-code No-ERROR.
      IF NOT avail buf_pay-type then do:
          message
          substitute("Не найден вид оплаты с кодом &1"
                      ,for-pay-code)
          view-as alert-box ERROR.
          p-rid = ?.
          return error.
      END.
      for-pay-name = buf_pay-type.obj-name.
  end.
  CREATE tt-payment.
  ASSIGN
  tt-payment.host-code = p-curr-host-code
  tt-payment.payer-type = payer.obj-type
  tt-payment.payer-code = payer.obj-code
  tt-payment.cli-type = buf_clients.obj-type
  tt-payment.cli-code = buf_clients.obj-code
  tt-payment.pay-code = for-pay-code
  tt-payment.tot-cli  = for-tot-cli
  tt-payment.exch-code = for-exch-code
  tt-payment.base-rate = v-base-rate
  tt-payment.base-scale = v-base-scale
  tt-payment.exch-rate = v-exch-rate
  tt-payment.exch-scale = v-exch-scale
  tt-payment.exch-date = v-exch-date
  tt-payment.due-date = for-date-pay
  tt-payment.STATUS_ = for-status_
  tt-payment.fact-date = for-fact-date
  tt-payment.source-ref = psource-ref
  tt-payment.source-type = (if psource-type = 'payment':U
                            then '':U
                            else psource-type)
  tt-payment.creid = v-cntxt-userid
  tt-payment.closid = (if psource-type = 'payment':U
                       then v-cntxt-userid
                       else '':U)
  .
END.
otherwise  do:
    FIND FIRST locked_payment where
               recid(locked_payment) = p-rid No-ERROR.
    IF NOT avail locked_payment then do:
        message "Не найден платеж"
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    end.
    if locked_payment.status_ =  'факт':U then do:
        message
        substitute("Нельзя редактировать платеж в статусе &1"
                   ,LOCKED_payment.status_)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    IF locked_payment.host-code <> p-curr-host-code then do:
      message "Выбран платеж другой фирмы"
      view-as alert-box ERROR.
      p-rid = ?.
      return error.
    end.
    FIND FIRST payer No-LOCK WHERE
               payer.obj-type = locked_payment.payer-type AND
               payer.obj-code = locked_payment.payer-code No-ERROR.
    IF NOT AVAIL PAYER then do:
        message
        substitute("Не найден плательщик &1&2 для платежа &3"
                   ,LOCKED_payment.payer-type
                   ,locked_payment.payer-code
                   ,locked_payment.pmnt-code )
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    FIND FIRST buf_currency NO-LOCK WHERE
               buf_currency.curr-code = locked_payment.exch-code No-ERROR.
    IF NOT AVAIL buf_currency then do:
        message
        substitute("Не найдена валюта с кодом &1 для платежа &2"
                  ,locked_payment.exch-code
                ,locked_payment.pmnt-code)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    FIND FIRST buf_pay-type No-LOCK WHERE
               buf_pay-type.obj-code = locked_payment.pay-code No-ERROR.
    if not avail buf_pay-type then do:
        message
        substitute("Не найден вид оплаты с кодом &1 для платежа &2"
                   ,locked_payment.pay-code
                   ,locked_payment.pmnt-code)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    end.
    CREATE tt-payment.
    BUFFER-COPY LOCKED_payment TO tt-payment
    .
    CASE psource-type:
      when 'заказ':U then do:
        FIND FIRST buf_ord-doc No-LOCK WHERE
                    buf_ord-doc.doc-code = psource-ref NO-ERROR.
        if not avail buf_ord-doc then do:
            message
            substitute("Не найден заказ с N &1 для платежа"
                       ,psource-ref )
            view-as alert-box ERROR.
            p-rid = ?.
            return error.
        end.
        frame Dialog-Frame:title = substitute("&1 N &1 к заказу &3"
                                               ,frame Dialog-Frame:title
                                               ,locked_payment.pmnt-code
                                               ,buf_ord-doc.doc-code).
      END.
    END CASE.
END.
END CASE.
END PROCEDURE.
PROCEDURE local-curr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "exch-code" and p-action = "ret-mouse" then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec12   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
                 no-lock no-error.
  if not available buf_curr-chk  then do:
    if input frame Dialog-Frame tt-payment.exch-code <> ""
       and input frame Dialog-Frame tt-payment.exch-code <> ? then
      message "Из справочника валют Вы должны выбрать валюту.".
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output v-ref-rec12) no-error .
    find buf_curr-chk where recid (buf_curr-chk) = v-ref-rec12  no-lock no-error.
    if not available buf_curr-chk then
      find first buf_curr-chk where
          buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
      no-lock no-error.
  end.
  if available buf_curr-chk then do:
    display buf_curr-chk.curr-code @ tt-payment.exch-code
            buf_curr-chk.curr-abbr @ exch-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-payment.exch-code.
  end.
  else display ? @ tt-payment.exch-code
               ? @ exch-code-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "exch-code" and p-action = "button" then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec14   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
                  no-lock no-error.
  assign v-ref-rec14 = ( if available buf_curr-chk then recid( buf_curr-chk ) else ? ).
  release buf_curr-chk.
  if not available buf_curr-chk  then do:
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output v-ref-rec14) no-error .
    find buf_curr-chk where recid (buf_curr-chk) = v-ref-rec14  no-lock no-error.
    if not available buf_curr-chk then
      find first buf_curr-chk where
          buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
      no-lock no-error.
  end.
  if available buf_curr-chk then do:
    display buf_curr-chk.curr-code @ tt-payment.exch-code
            buf_curr-chk.curr-abbr @ exch-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-payment.exch-code.
  end.
  else display ? @ tt-payment.exch-code
               ? @ exch-code-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "exch-code" and p-action = "leave" then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec16   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
                 no-lock no-error.
if available buf_curr-chk then do:
    display
    buf_curr-chk.curr-code @ tt-payment.exch-code
    buf_curr-chk.curr-abbr @ exch-code-name with frame Dialog-Frame.
        assign frame Dialog-Frame tt-payment.exch-code.
end.
else display ? @ tt-payment.exch-code ? @ exch-code-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE Myenable :
assign
tt-payment.tot-rubl :label in frame Dialog-Frame = "Сумма (руб)"
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec18   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
                 no-lock no-error.
if not available buf_curr-chk then do:
  display tt-payment.exch-code with frame Dialog-Frame.
  find buf_curr-chk no-lock where buf_curr-chk.curr-code = input frame Dialog-Frame tt-payment.exch-code
                          no-error.
end.
if available buf_curr-chk then do:
    display
    buf_curr-chk.curr-code @ tt-payment.exch-code
    buf_curr-chk.curr-abbr @ exch-code-name with frame Dialog-Frame.
end.
else display ? @ tt-payment.exch-code ? @ exch-code-name with frame Dialog-Frame.
CASE psource-type:
  WHEN 'заказ':U THEN DO:
    assign
    frame Dialog-Frame:title = substitute("&1  к заказу &2"
                                                ,frame Dialog-Frame:title
                                                ,buf_ord-doc.doc-code).
  END.
  WHEN 'payment':U THEN DO:
      ASSIGN
      frame Dialog-Frame:title = substitute("&1 к карте &2"
                                        ,frame Dialog-Frame:title
                                        ,buf_dis-card.d-card).
  END.
END CASE.
DISPLAY
tt-payment.cli-type
tt-payment.cli-code
buf_clients.obj-name
tt-payment.payer-type
tt-payment.payer-code
payer.obj-name @ payer-name
tt-payment.pay-code
for-pay-name @ pay-type-name
tt-payment.fact-date
tt-payment.due-date
tt-payment.status_
tt-payment.exch-code
tt-payment.exch-date
tt-payment.base-rate
tt-payment.base-scale
tt-payment.exch-rate
tt-payment.exch-scale
tt-payment.source-type
tt-payment.tot-cli
tt-payment.tot-base
tt-payment.tot-rubl
tt-payment.creid
tt-payment.closid
tt-payment.PS
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-payment.payer-type when p-mode <> 'ПРОСМОТР':U
tt-payment.payer-code when p-mode <> 'ПРОСМОТР':U
B-payer when p-mode <> 'ПРОСМОТР':U
tt-payment.pay-code when p-mode <> 'ПРОСМОТР':U
B-pay-code when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.due-date when p-mode <> 'ПРОСМОТР':U AND tt-payment.status_ = 'ожид':U
tt-payment.tot-cli when p-mode <> 'ПРОСМОТР':U
tt-payment.exch-rate when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.exch-date when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.exch-code when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
B-exch-code when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.exch-scale when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.base-rate when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.base-scale when p-mode <> 'ПРОСМОТР':U AND NOT psource-type = 'payment':U
tt-payment.PS when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
CASE psource-type:
  when 'заказ':U then do:
    DISABLE
    tt-payment.exch-code
    tt-payment.base-rate
    tt-payment.base-scale
    tt-payment.exch-rate
    tt-payment.exch-code
    tt-payment.pay-code
    tt-payment.exch-date
    WITH FRAME Dialog-Frame.
  end.
END.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
define buffer buf_payment for ub.payment.
ASSIGN
FRAME Dialog-Frame
tt-payment.due-date
tt-payment.payer-type = payer.obj-type
tt-payment.payer-code = payer.obj-code
tt-payment.tot-cli
tt-payment.PS
tt-payment.exch-date
tt-payment.exch-code
tt-payment.exch-rate
tt-payment.exch-scale
tt-payment.base-rate
tt-payment.base-scale
tt-payment.tot-base
tt-payment.tot-rubl
tt-payment.source-type
tt-payment.source-ref
tt-payment.d-card = p-d-card
tt-payment.fact-date = tt-payment.fact-date
tt-payment.creid = v-cntxt-userid
tt-payment.closid = (if tt-payment.status_ = 'факт':U
                 then v-cntxt-userid
                 else "")
tt-payment.pay-code
v-rid = (if p-mode = 'ИЗМЕНЕНИЕ':U then p-rid else ?)
.
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run ref/payment1.p (
                    input p-mode
                   ,input  no
                   ,input-output tt-payment.pmnt-code
                   ,input tt-payment.cli-type
                   ,input tt-payment.cli-code
                   ,input tt-payment.payer-type
                   ,input tt-payment.payer-code
                   ,input tt-payment.host-code
                   ,input tt-payment.tot-cli
                   ,input tt-payment.tot-base
                   ,input tt-payment.tot-rubl
                   ,input tt-payment.exch-date
                   ,input tt-payment.exch-code
                   ,input tt-payment.exch-rate
                   ,input tt-payment.exch-scale
                   ,input tt-payment.base-rate
                   ,input tt-payment.base-scale
                   ,input tt-payment.due-date
                   ,input tt-payment.fact-date
                   ,input tt-payment.source-type
                   ,input tt-payment.source-ref
                   ,input tt-payment.d-card
                   ,input tt-payment.pay-code
                   ,input tt-payment.status_
                   ,input tt-payment.PS
                   ,INPUT tt-payment.creid
                   ,INPUT tt-payment.closid
                   ) no-error .
  if error-status:error then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
    message error-status:get-message(1) skip
    return-value view-as alert-box .
    undo main-block, return error.
  end.
  find first buf_payment no-lock where
            buf_payment.pmnt-code = tt-payment.pmnt-code no-error.
  if not available buf_payment then do:
    message
    "Не удается найти созданный платеж"
    view-as alert-box error .
    undo, return error.
  end.
  if (psource-type = 'payment':U
     or
     psource-type = 'платеж':U )
  and p-d-card <> '':U then do:
    run str/saledc.p
      (
      input parparentproc
      ,input this-procedure :handle
      ,input ?
      ,input 'payment-on-card':U
      ,input ?
      ,input ""
      ,input 0
      ,input 0
      ,input 0
      ,input v-cntxt-db-num
      ,input buf_payment.pmnt-code
      ,input buf_payment.exch-date
      ,input buf_payment.fact-date
      ,input 0
      ,input 1
      ,input ?
      ,input yes
      ) no-error .
    if error-status:error then do:
      message error-status:get-message(1) skip
      return-value view-as alert-box .
      undo main-block, return error return-value .
    end.
  end.
  p-rid = recid(buf_payment).
end.
END PROCEDURE.
