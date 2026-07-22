block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: libthpos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/libthpos.p $":U .
define variable vss-description as character no-undo init "Библиотека работы c POS IBS TH".
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
define new global shared variable g#libthpos as handle no-undo .
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
function check-by-mask returns logical (
  input p-mask  as character
  ,input p-str as character
   ,output p-descr as character
  ).
define variable ii as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask-char as character no-undo .
assign
v-max = length (p-mask).
_do:
do ii = 1 to v-max:
  assign
  v-mask-char = substring(p-mask, ii, 1).
  if v-mask-char = chr(63) then NEXT _do.
  if v-mask-char = "*":U then do:
    if ii < v-max then do:
      assign
      p-descr = substitute("неверная маска &1: звездочка может быть только последним символом маски").
      return no .
    end.
    return yes.
  end.
  else do:
    if v-mask-char <> substring(p-str, ii, 1) then do:
      assign
      p-descr = substitute("№ ДК &1 не соответствует МАСКЕ &2", p-str, p-mask).
      return no.
    end.
    next _do.
  end.
end.
if v-mask-char = chr(63) and v-max = length(p-str) then return yes.
end function.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function card-by-mask returns CHARACTER (
                                             input p-cli-mask  as character
                                            ,input p-cc-run as INTEGER
                                            ,input p-full-number as character
                                            ):
define variable ii as integer no-undo .
define variable v-cli-mask as character no-undo .
define variable v-full-number as character no-undo .
define variable v-short-number as character no-undo .
  if length(p-cli-mask) <> length(p-full-number) then return '':U.
  v-cli-mask = p-cli-mask.
  do ii = 1 to length(p-cli-mask):
    if substring(v-cli-mask, ii, 1) = 'D' then do:
      substring(v-cli-mask, ii, 1) = substring(p-full-number, ii, 1).
      assign
      v-short-number = v-short-number  + substring(p-full-number, ii, 1)
      v-full-number = v-full-number + substring(p-full-number, ii, 1)
      .
    end.
    else do:
       if substring(v-cli-mask, ii, 1) = 'C' then do:
         v-full-number = v-full-number + substring(p-full-number, ii, 1).
       end.
       else do:
         v-full-number = v-full-number + substring(p-cli-mask, ii, 1).
       end.
    end.
  END.
  if v-full-number <> p-full-number then return '':U.
  v-full-number = ''.
  if index(v-cli-mask, 'C') > 0 then do:
    if p-cc-run = 0 then return '':U.
    CASE p-cc-run:
      when integer('1':U) then do:
        run gbl/pluhnalg.p ( input v-cli-mask, output v-full-number) no-error .
      end.
      otherwise do:
        error-status:error = yes.
      end.
    end case.
    if error-status:error then do:
      return '':U.
    end.
    if v-full-number <> p-full-number then return '':U.
  end.
  return v-short-number.
end function.
define temp-table libthpos_cash-desk-attr like ub.cash-desk-attr.
temP-TABLE libthpos_cash-desk-attr:HANDLE:SCHEMA-MARSHAL = "NONE".
define dataset libthpos_params  for libthpos_cash-desk-attr.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION name-2cdf returns character
                   (  input p-name-2cd as character
                    , input p-mode as logical
                    , input p-cod-pcod as logical
                    , input p-b-code  as integer
                    , input p-gds-code as integer
                    , input p-artic   as character
                    , input p-engl-name  as character
                    , input p-in-code as character
                    , input p-part-code as character
                    , input p-obj-type as character
                    , input p-obj-code as integer
                    , input p-alpha1 as character
                    , output p-gtd as character
                    ) :
define variable v-name-2cd as character no-undo .
define variable v-dop-alt-name as character no-undo.
define variable v-type as character no-undo.
define buffer buf_parts for ub.parts.
define buffer buf_code for ub.code.
if not p-mode and p-name-2cd = "PLU":U then do:
  return "PLU кассы":U.
end.
if not p-mode then do:
  if p-name-2cd <> "GTD":U
  and  p-name-2cd <> "alpha1|gtd":U
  then do:
  assign
  p-name-2cd = p-name-2cd + "-":U + "GTD":U.
end.
end.
if p-part-code = "":U or p-cod-pcod = no then do:
  run gdsoattr-value in this-procedure (
    'dt-seasons':U,
    p-gds-code,
    p-obj-type,
    p-obj-code,
    output v-dop-alt-name,
    output v-type
  ) no-error.
  if v-dop-alt-name <> "" then do:
    find first buf_code where
               buf_code.parent = "DTSeasons"
           and buf_code.code   = v-dop-alt-name
         no-lock no-error.
    if available buf_code then
      assign
        p-engl-name = ""
        v-dop-alt-name =  buf_code.misc1
      .
  end.
  else do:
    run gdsoattr-value in this-procedure
                        ( input  'dop-alt-name-o':U
                         ,input  p-gds-code
                         ,input  p-obj-type
                         ,input  p-obj-code
                         ,output v-dop-alt-name
                         ,output v-type
                        ) no-error .
  end.
  CASE p-name-2cd:
    when "name" then do:
      if p-mode then return p-engl-name + v-dop-alt-name.
      return "Англ. название".
    end.
    when "code":U then do:
      if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
      return "Лок. код товара"  .
    end.
    when "GTD":U
    or
    when "name-GTD":U
    or
    when "code-GTD":U
    or
    when "alpha1|gtd":U
    or
    when "name-alpha1|gtd":U
    or
    when "code-alpha1|gtd":U
    then do:
      if p-mode then do:
        run gdcstcod_cst-code  in this-procedure (
                                                    input  p-obj-type
                                                    ,input  p-obj-code
                                                    ,input  p-gds-code
                                                    ,input  p-in-code
                                                    ,input  p-part-code
                                                    ,output p-gtd
                                                    ) no-error .
      end.
      if p-name-2cd = "name-gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "name-alpha1|gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "code-GTD":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-name-2cd = "code-alpha1|gtd":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-mode then do:
        if p-name-2cd = "GTD" then  return p-gtd.
        if p-name-2cd = "alpha1|gtd" then  return (p-alpha1 + "|" + p-gtd).
      end.
      if p-name-2cd = "GTD" then  return "Код ГТД".
      if p-name-2cd = "alpha1|gtd" then  return "Страна|Код ГТД".
    end.
  END CASE.
end.
else do:
  if p-name-2cd = "name-gtd":U
  or p-name-2cd = "code-GTD":U
  or p-name-2cd = "name-alpha1|GTD":U
  or p-name-2cd = "code-alpha1|GTD":U
  or p-name-2cd = "alpha1|GTD":U
  then do:
    if p-mode then do:
      run gdcstcod_cst-code  in this-procedure (
                                                   input  p-obj-type
                                                  ,input  p-obj-code
                                                  ,input  p-gds-code
                                                  ,input  p-in-code
                                                  ,input  p-part-code
                                                  ,output p-gtd
                                                  ) no-error .
    end.
    else do:
      if p-name-2cd = "gtd":U then
      p-gtd = "Код ГТД".
      if p-name-2cd = "alpha1|Gtd":U then
      p-gtd = "Страна|Код ГТД".
    end.
  end.
  if p-mode then  return p-part-code.
  return "Код партии".
end.
END FUNCTION.
function chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th returns character ( input p-pos-type as character
                                         ,input p-nam-2str as logical
                                         ,input p-nam-artc as logical
                                         ,input p-unit-cli-type as character
                                         ,input p-unit-base as character
                                         ,input p-unit-cli as character
                                         ,input p-cli-base-rate as decimal
                                         ,input p-artic as character
                                         ,input p-f-name as character
                                         ,input p-gds-name as character
                                         ,input p-gds-name1 as character
                                         ,output p-second-name as character):
define variable v-length as integer no-undo .
define variable nam-2str-shift as integer no-undo .
define variable chk_name as character no-undo .
assign
v-length = (if p-pos-type = 'IBM':U then 25 else 40 )
v-length = (if p-pos-type = 'MARIA':U then 24 else v-length)
v-length = (if p-pos-type = 'MARIA':U and lookup('топ':U, p-unit-cli-type) > 0
            then 5
            else v-length)
v-length = (if p-pos-type = 'IBM-XML':U then 128 else v-length )
nam-2str-shift = (if p-nam-2str then v-length else 0)
.
if p-nam-artc then do:
  assign
  chk_name = substitute("&1 &2", p-artic, p-f-name)
    .
end.
else  do:
  assign
  chk_name = replace(p-gds-name, chr(34), "":U) + p-f-name
  .
end.
if p-unit-base <> p-unit-cli then do:
  if length (chk_name) > 109 then chk_name = substring (chk_name,1,109) .
  assign
  chk_name = string(substr(chk_name
                            ,1
                            ,max(14, v-length + nam-2str-shift - 1 - length(trim(string(p-cli-base-rate), chr(32)))) +  nam-2str-shift ) +
                    "*":U +
                    trim(string(p-cli-base-rate), chr(32)), "x(":U + string(v-length + nam-2str-shift) + ")":U ).
end.
else do:
  chk_name = string(chk_name, "X(":U + string(v-length + nam-2str-shift) + ")":U).
end.
if p-nam-2str then do:
  assign
  p-second-name = chr(34) + trim(substr(chk_name, v-length)," ") + chr(34)
  chk_name = substr(chk_name, 1, v-length)
  .
end.
else do:
  assign
  p-second-name = replace(p-gds-name1, chr(39), "":U)
  p-second-name =   (chr(34) +
                    TRIM(string( replace(p-second-name, chr(34), "":U), "X(":U + string(v-length) + ")":U ))
                    + chr(34) )
  .
end.
return chk_name.
end function.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure printbuffer private:
define input parameter p-bh as handle no-undo .
define variable v-ii as integer no-undo .
if search("printbuffer.fld") <> ? then do:
  output to value( substitute("&1.txt", p-bh:name)) append.
  put unformatted today chr(32) string(time, "HH:MM:SS")
  this-procedure :name skip
  skip.
  do v-ii = 1 to p-bh:num-fields:
    if p-bh:buffer-field(v-ii):data-type = 'rowid':U then do:
      put unformatted fill( chr(32), 10) p-bh:buffer-field(v-ii):name string(p-bh:buffer-field(v-ii):buffer-value) at 35 skip.
    end.
    else do:
      put unformatted fill( chr(32), 10) p-bh:buffer-field(v-ii):name p-bh:buffer-field(v-ii):buffer-value at 35 skip.
    end.
  end.
end.
output close.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
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
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info22 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info22, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info22, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info22, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info22, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info22 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info22, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info22 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info22, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info22, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info22, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info22, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info22, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info22, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info22 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info22 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info22, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info22, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info22, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info22 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info22 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info22, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info22, v-inform, v-tbl-name ).
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure print-xml:
define input parameter p-dsh as handle no-undo .
define input parameter p-file-name-without-ext as character no-undo .
define variable glog as logical no-undo .
define variable v-rowid as rowid no-undo.
define variable v-rowid-list as character no-undo .
define variable v-rowid-list2 as character no-undo .
define variable v-ii as integer no-undo .
define variable v-th as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-dsh  as handle no-undo .
do
on error undo, return error
:
  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        v-rowid-list = v-rowid-list +
                        (if v-ii = 1 then '' else chr(44)) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
      v-dsh = p-dsh.
    end.
    when "temp-table" then do:
      if p-dsh:default-buffer-handle:available then do:
        v-rowid-list = string(p-dsh:default-buffer-handle:rowid).
      end.
      v-dsh = p-dsh.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        if p-dsh:available then do:
          create temp-table v-th  .
          v-th:create-like(p-dsh).
          v-th:temp-table-prepare(p-dsh:table).
          create buffer v-bh for table v-th.
          v-bh:buffer-create().
          v-bh:buffer-copy(p-dsh).
          v-bh:buffer-release().
          v-dsh = v-bh.
        end.
      end.
      else do:
        v-dsh = p-dsh.
      end.
    end.
  end case.
  glog = v-dsh:WRITE-XML("FILE"
                        , substitute("&1.xml", p-file-name-without-ext)
                        , yes
                        , "windows-1251"
                        , ''
                        , no
                        , no  ) no-error.
  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        if entry(v-ii,v-rowid-list) <> '' then do:
           glog = p-dsh:get-buffer-handle(v-ii):find-by-rowid(TO-ROWID(entry(v-ii,v-rowid-list)))  .
        end.
        v-rowid-list2 = v-rowid-list2 +
                        (if v-ii = 1 then '' else chr(44)) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
    end.
    when "temp-table" then do:
      if v-rowid-list <> '' then do:
        p-dsh:default-buffer-handle:find-by-rowid(to-rowid(v-rowid-list)).
      end.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        delete object v-bh.
        delete object v-th.
      end.
    end.
  end case.
end.
end procedure.
define new global shared variable g#lib-log as handle no-undo .
if valid-handle (g#libthpos)
and g#libthpos <> this-procedure :handle
and g#libthpos :get-signature('libthpos_clear-cda':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с POS IBS TH" skip
    g#libthpos skip
    g#libthpos :type skip
    g#libthpos :file-name skip
    valid-handle(g#libthpos) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libthpos = this-procedure :handle
  .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table libthpos_context  no-undo
field parparentproc       as widget-handle
field p-log-handle        as handle
field p-log-file-name     as character
field view-log            as logical
field ll                  as integer
field tt-wd-bh            as handle
field pos-type            as character
field cash-num            as integer
field obj-type            as character init 'маг':U
field obj-code            as integer
field db-num              as integer
field r-b                 as character
field host-code           as integer
field base-code           as integer
field cre-pay             as integer
field is-catering         as logical
field is-cdinv            as logical
field is-ptrl             as logical
field is-wth              as logical
field process-sale        as logical
field dc-mask             as logical
field card-by-mask        as logical
field sclspref            as character
field scpgpref            as character
field scpgpref-pre        as character
field doc-prt             as logical
field shift-on            as logical
field cas-shft            as logical
field t-shft              as integer
field v-shft              as integer
field ptrl-check          as logical
field annu-check          as logical
field z-check             as logical
field hnum                as logical
field is-100-discnt       as logical
field zero-cashier        as integer
field rnd-znak            as integer
field cas-curs            as logical
field nam-2str            as logical
field nam-artc            as logical
field cod-pcod            as logical
field name-2cd            as character
field how-temp-disc       as character
field nalc                as integer
field rmethod-type        as character
field rmethod-coeff       as decimal
field serial-code         as character
field salesman-mandatory  as integer
field sales-man           as integer
field salesman-psn-code   as integer
field pos-type-for-discnt as character
field manual-discnt       as integer
field is-grp-totals       as logical
field is-gds-totals       as logical
field cash-counter        as decimal
field pre-cash-counter    as decimal
field qnty-change         as logical
field log-level           as integer
field chk-discnt-table    as handle
help 'cntxt_chk-discnt-table':U
field chk-gds-table       as handle
help 'cntxt_chk-gds-table':U
field chk-pay-table       as handle
help  'cntxt_chk-pay-table':U
field z-number            as integer
field shift-num           as integer
field shift-date          as date
field shift-name          as character
field emulator-mode       as integer
field ibmgroup            as logical
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table libthpos_dis-card-mask no-undo
like ub.dis-card-mask
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table libthpos_tt-wd no-undo
field doc-code like ub.chk-doc.doc-code
field record-type like ub.chk-discnt.record-type
field line-type like ub.chk-discnt.line-type
field discnt-id like ub.chk-discnt.discnt-id
field line-num like ub.chk-gds.line-num
field wd-sum   like ub.chk-doc.netto
index pi is primary
line-num
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table libthpos_chk-context no-undo  before-table undo_libthpos_chk-context
field doc-code as character
field obj-code as integer
help 'doc_obj-code':U
field direction as integer
field rowid_ as rowid
field chk-type as integer
field prev-chk-type as integer
field lng as integer
field lnp as integer
field lnd as integer
field lnc as integer
field lnpp as integer
field chk-date as date
field chk-time as integer
field current-date as date
field current-time as integer
field bank-rate as decimal
field bank-scale as integer
field base-rate as decimal
help 'doc_base-rate':U
field cash-rate as decimal
field cash-scale as integer
field a-chk-date as date
field a-chk-time as integer
field a-bank-rate as decimal
field a-bank-scale as integer
field a-base-rate as decimal
field a-cash-rate as decimal
field a-cash-scale as integer
field src-cli-type as character
field src-cli-code as integer
field src-d-mask as character
field src-d-card as character
field d-card as character
field d-pcnt as decimal
help 'doc_dc-d-pcnt':U
field cash-d-pcnt as decimal
help 'doc_dc-cash-d-pcnt':U
field category as integer
help 'doc_dc-category':U
field sales-man as integer
field salesman-psn-code as integer
field step as integer
field src-qnty as decimal
field gds-netto as decimal
field sub-netto as decimal
field netto as decimal
field all-pay-rubl as decimal
field all-pay-base as decimal
field st-r-b as decimal
field st-rubl as decimal
field st-base as decimal
field st-for-discnt-r-b as decimal
help 'doc_st-for-discnt-r-b':U
field to-pay-r-b  as decimal
help 'doc_to-pay-r-b':U
field to-pay-rubl as decimal
field to-pay-base as decimal
field has-pay-r-b  as decimal
field has-pay-rubl as decimal
field has-pay-base as decimal
field doc-qnty as decimal
field src-tot-doc as decimal
field src-tot-rubl as decimal
field src-tot-base as decimal
field discnt-id as integer
field gds-r as decimal
field tot-r as decimal
field pay-r as decimal
field r-sums as decimal
field gds-discnt as decimal
field tot-discnt as decimal
field pay-discnt as decimal
field pay-discnt-rubl as decimal
field pay-discnt-base as decimal
field discnt as decimal
field sale-in-out as logical
field is-petrol-check as logical
field recalc-gline-num as integer
help 'doc_recalc-gline-num':U
field recalc-pline-num as integer
help 'doc_recalc-pline-num':U
field manual-tot-discnt as decimal
field manual-tot-dis-type as integer
field manual-discnt-id as integer
field manual-discnt-ln as integer
field manual-discnt-sum as decimal
field getcheck as integer
field with-atr1-sum as decimal
field change-sum as decimal
field is-undo as logical
field print-copy-num as integer
index pi is unique primary
doc-code
.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE libthpos_temp-cash-pay-list
FIELD cdpay-code AS INTEGER
FIELD curr-code AS INTEGER
FIELD frpay-code AS INTEGER
INDEX pi IS UNIQUE PRIMARY
cdpay-code curr-code
INDEX ifr frpay-code
    .
DEFINE TEMP-TABLE libthpos_temp-pay-names
FIELD frpay-code AS INTEGER
FIELD frpay-name AS CHARACTER
INDEX pi IS UNIQUE PRIMARY frpay-code.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure libthpos_get-cash-pay-list :
define input parameter p-cp-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-fr-code as integer no-undo .
define variable v-cp-list as character no-undo .
define buffer buf_temp-cash-pay-list for libthpos_temp-cash-pay-list.
do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-cp-list, chr(4)):
    v-dop1 = ENTRY(v-ii, p-cp-list, chr(4)).
    ASSIGN
    v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
    v-cp-list = ENTRY(2, v-dop1, "=")
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      DO v-jj = 1 TO num-entries(v-cp-list, ";"):
        FIND FIRST buf_temp-cash-pay-list WHERE
                  buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
            AND buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58))) NO-ERROR.
        IF NOT AVAILABLE buf_temp-cash-pay-list THEN DO:
          CREATE buf_temp-cash-pay-list.
          ASSIGN
          buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
          buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
          buf_temp-cash-pay-list.frpay-code = v-fr-code
          .
        END.
      end.
    end.
  end.
END.
end procedure.
procedure libthpos_get-pay-names :
define input parameter p-pay-names-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-fr-code as integer no-undo .
define variable v-name as character no-undo .
define buffer buf_temp-pay-names for libthpos_temp-pay-names.
do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-pay-names-list, chr(4)):
    ASSIGN
    v-fr-code = v-ii + 1
    v-name = ENTRY(v-ii, p-pay-names-list, chr(4))
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      FIND FIRST buf_temp-pay-names WHERE
                buf_temp-pay-names.frpay-code = v-fr-code NO-ERROR.
      IF NOT AVAILABLE buf_temp-pay-names THEN DO:
        CREATE buf_temp-pay-names.
        ASSIGN
        buf_temp-pay-names.frpay-code = v-fr-code
        buf_temp-pay-names.frpay-name = v-name
        .
      END.
    END.
  END.
end.
end procedure.
procedure libthpos_set-cash-pay-list :
define output parameter p-cash-pay-list as character no-undo .
define buffer buf_temp-cash-pay-list for libthpos_temp-cash-pay-list.
do
on error undo, return error
:
  FOR EACH buf_temp-cash-pay-list
  BREAK BY
  buf_temp-cash-pay-list.frpay-code:
    IF not(buf_temp-cash-pay-list.frpay-code  >= 2
         AND
         buf_temp-cash-pay-list.frpay-code  <= 4) THEN DO:
    undo, return error  substitute("Неверно заполнено соответствие для типа кассового платежа TH с кодом &1 и валютой &2"
               , buf_temp-cash-pay-list.cdpay-code
               , buf_temp-cash-pay-list.curr-code).
    END.
    IF FIRST-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = substitute("&1&2&3="
                                  ,p-cash-pay-list
                                  ,chr(4)
                                    ,buf_temp-cash-pay-list.frpay-code) .
    END.
    ASSIGN
    p-cash-pay-list = substitute("&1&2:&3;"
                                ,p-cash-pay-list
                                  ,buf_temp-cash-pay-list.cdpay-code
                                  ,buf_temp-cash-pay-list.curr-code
                                  ) .
    IF last-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = right-trim(p-cash-pay-list, ";").
    END.
  END.
  assign
  p-cash-pay-list = LEFT-TRIM(p-cash-pay-list, chr(4))
  p-cash-pay-list = right-TRIM(p-cash-pay-list, ";")
  .
end.
end procedure.
procedure libthpos_set-pay-names :
define output parameter p-pay-names as character no-undo .
define buffer buf_temp-pay-names for libthpos_temp-pay-names.
do
on error undo, return error
:
  FOR EACH buf_temp-pay-names
  BY buf_temp-pay-names.frpay-code
      :
    IF buf_temp-pay-names.frpay-code >= 2
    OR buf_temp-pay-names.frpay-code <= 2
    THEN
    ASSIGN
    p-pay-names = substitute("&1&2&3"
                                  ,p-pay-names
                                  ,chr(4)
                                  ,buf_temp-pay-names.frpay-name) .
  END.
  ASSIGN
  p-pay-names = left-trim(p-pay-names, chr(4))
  .
end.
end procedure.
define temp-table libthpos_cash-counter no-undo
field pay-code as integer
field curr-code as integer
field wth-code as integer
field par-code as integer
field par-val as integer
field tot-sum as decimal
field tot-rubl as decimal
field tot-base as decimal
field doc-qnty as decimal
field tot-lines as integer
field pre-tot-sum as decimal
field pre-tot-rubl as decimal
field pre-tot-base as decimal
field pre-doc-qnty as decimal
field pre-tot-lines as integer
field is-cash as logical
index pi is unique primary
pay-code curr-code wth-code par-code
.
define temp-table libthpos_rp-by-call no-undo
field profile_id as integer
field once-more as integer
field rph as handle
field call_id as character
index pi is unique primary
profile_id
once-more
.
define temp-table libthpos_flddf no-undo
field table-name_ as character
field name_ as character
field buffer_ as handle
field field-name_ as character
field fld-df as character
field buffer-field_ as handle
field table-no as integer
index pi is unique primary
fld-df
index itable table-name_
.
define temp-table libthpos_chk-doc no-undo like ub.chk-doc before-table undo_libthpos_chk-doc.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table libthpos_chk-gds no-undo like ub.chk-gds before-table undo_libthpos_chk-gds
field src-price-rubl as decimal
field src-discnt-rubl as decimal
field src-sum-rubl as decimal
field src-r-discnt-sum  as decimal
field src-discnt-sum    as decimal
field src-discnt-sum-rubl    as decimal
field r-sum  as decimal
field without-gds-discnt as integer
help 'gline_without-gds-discnt':U
field without-subtotal-discnt as integer
help 'gline_without-subtotal-discnt':U
field recalc-line-num as integer
help 'gline_recalc-line-num':U
field src-price-netto   as decimal
help 'gline_src-price-netto':U
field price-base-netto   as decimal
help 'gline_price-base-netto':U
field start-src-price   as decimal
help 'gline_start-src-price':U
field main-bar-code     like ub.bar-code.b-code
field gds-code          like ub.goods.gds-code
help 'gline_gds-code':U
field unit-base         like ub.goods.unit-base
field unit-base-type    like ub.units.type
field unit-cli          like ub.bar-code.unit-cli
field unit-cli-type     like ub.units.type
field min-rate          like ub.goods.min-rate
field max-rate          like ub.goods.max-rate
field in-code           like ub.bar-code.in-code
field part-code         like ub.bar-code.part-code
field cash-parts        like ub.gds-obj.cash-parts
field prt-root          like ub.goods.prt-root
field root-node-code    like ub.gds-prt.node-code
field empty-scale       as logical
field chk-name as character
field second-name as character
field is-weight-pbc as logical
field is-pgweight-pbc as logical
field will-price-base as decimal
help 'gline_price-base':U
field will-doc-qnty as decimal
help 'gline_doc-qnty':U
field cli-base-rate as decimal
help 'gline_cli-base-rate':U
field free-price as logical
field line-direction as integer
field node-code         like ub.bar-code.node-code
field sum-grp-code as integer
help 'gline_sum-grp-code':U
field manual-discnt-id as integer
field manual-discnt-sum as decimal
field is-undo as logical
index ln is unique primary
doc-code
line-num
index ib-code
b-code
index igds
gds-code
index igrp
sum-grp-code
index inode
node-code
.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table libthpos_chk-pay no-undo like ub.chk-pay  before-table undo_libthpos_chk-pay
field for-discnt-doc as decimal
field for-discnt-r-b as decimal
field for-discnt-rubl as decimal
field for-discnt-base as decimal
field brutto-doc as decimal
field brutto-rubl as decimal
field brutto-base as decimal
field brutto-r-b as decimal
field r-sum as decimal
field discnt-r-b as decimal
field discnt-sum as decimal
field discnt-rubl as decimal
field discnt-base as decimal
field b-exch-date as date
field b-exch-time as integer
field b-exch-rate as decimal
help 'pline_exch-rate':U
field b-exch-scale as integer
help 'pline_exch-scale':U
field b-calc-rate as decimal
field is-cash as logical
field has-overpay as integer
field atr1 as logical
field has-return as integer
field can-mix as integer
field frpay-code as integer
field inversed as logical
field is-credit-card as logical
field is-debet-card as logical
field atr128 as logical
field atr16 as logical
field atr32 as logical
field recalc-line-num as integer
field par-rate as decimal
field get-qnty-method as character
field byval as logical
help 'pline_recalc-line-num':U
index ln is unique primary
doc-code
line-num
index ipay
pay-code curr-code
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table libthpos_chk-discnt no-undo like ub.chk-discnt before-table undo_libthpos_chk-discnt
field delta-discnt  as decimal help 'dline_delta-discnt':U
field nonunique     as character help 'dline_nonunique':U
field discnt-role as character help 'dline_discnt-role':U
field charkey as character help 'dline_charkey':U
field intended as logical help 'dline_intended':U
field not-found as logical help 'dline_not-found':U
field src-price-netto as decimal
INDEX pi is unique primary
doc-code
record-type
line-num
discnt-id
object-line-num
index dcard
d-card
record-type
INDEX discnt-type
line-type
discnt-type
record-type
index icharkey_one
discnt-role
rule-num
charkey
.
define variable v-bh0 as handle no-undo extent 6 .
define variable v-bh as handle no-undo extent 6 .
define variable loc-print-copy-num as integer no-undo .
define variable loc-print-doc-code as character no-undo .
define dataset libthpos_receipt  for
libthpos_chk-context,
libthpos_chk-doc,
libthpos_chk-gds,
libthpos_chk-pay,
libthpos_chk-discnt
data-relation line-doc for libthpos_chk-doc, libthpos_chk-context relation-fields (doc-code, doc-code)
data-relation line-gds for libthpos_chk-doc, libthpos_chk-gds relation-fields (doc-code, doc-code) nested
data-relation line-pay for libthpos_chk-doc, libthpos_chk-pay relation-fields (doc-code, doc-code) nested
data-relation line-discnt for libthpos_chk-doc, libthpos_chk-discnt relation-fields (doc-code, doc-code) nested
.
define dataset libthpos_context  for
libthpos_context,
libthpos_cash-counter,
libthpos_dis-card-mask
.
define buffer locked_chk-doc for ub.chk-doc.
on delete of this-procedure do:
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                  , input no).
  for each libthpos_cash-desk-attr:
    delete libthpos_cash-desk-attr.
  end.
  for each libthpos_context:
    delete libthpos_context.
  end.
  for each libthpos_chk-context:
    delete libthpos_chk-context.
  end.
  for each libthpos_dis-card-mask:
    delete libthpos_dis-card-mask.
  end.
  dataset libthpos_params:empty-dataset().
  dataset libthpos_receipt:empty-dataset().
  for each buf_libthpos_rp-by-call:
    if  valid-handle(buf_libthpos_rp-by-call.rph) then do:
      delete procedure(buf_libthpos_rp-by-call.rph).
    end.
    delete buf_libthpos_rp-by-call.
  end.
  assign
    g#libthpos = ?
  .
end.
procedure libthpos_clear-cda:
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
  do
  on error undo, return error return-value
  :
    for each buf_libthpos_cash-desk-attr
    on error undo, return error :
      delete buf_libthpos_cash-desk-attr.
    end.
  end.
end procedure.
function libthpos_rmethod returns decimal ( input p-rmethod-type as character
                                            ,input p-rmethod-coeff as decimal
                                            ,input p-sum as decimal ):
define variable  mround-sum as decimal no-undo.
case p-rmethod-type:
  when "MROUND" then do:
    if p-rmethod-coeff > 0 then do:
      mround-sum = truncate(p-sum, integer(p-rmethod-coeff)).
    end.
    else do:
      mround-sum = truncate(p-sum / exp(10, abs(p-rmethod-coeff)), 0) * EXP(10, abs(p-rmethod-coeff)).
    end.
  end.
  when "NO-COINS" then do:
    mround-sum = truncate( p-sum / p-rmethod-coeff, 0) * p-rmethod-coeff.
  end.
end case.
return mround-sum.
end function.
procedure libthpos_clear-context:
define buffer buf_libthpos_context for libthpos_context.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_libthpos_flddf for libthpos_flddf.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
  do
  on error undo, return error return-value
  :
    for each buf_libthpos_flddf
    on error undo, return error :
      delete buf_libthpos_flddf.
    end.
    for each buf_libthpos_context
    on error undo, return error :
      delete buf_libthpos_context.
    end.
    for each buf_libthpos_dis-card-mask
    on error undo, return error :
      delete buf_libthpos_dis-card-mask.
    end.
    for each buf_libthpos_cash-counter:
      delete buf_libthpos_cash-counter.
    end.
    for each buf_libthpos_rp-by-call:
      if  valid-handle(buf_libthpos_rp-by-call.rph) then do:
        delete procedure(buf_libthpos_rp-by-call.rph).
      end.
      delete buf_libthpos_rp-by-call.
    end.
  end.
end procedure.
procedure libthpos_fill-cda:
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
do
on error undo, return error return-value
:
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
  do
  on error undo, return error return-value
  :
    run libthpos_clear-cda in this-procedure.
    for each buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.cash-num = p-cash-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      create buf_libthpos_cash-desk-attr.
      buffer-copy buf_cash-desk-attr to buf_libthpos_cash-desk-attr.
    end.
  end.
end.
end procedure.
procedure libthpos_get-cda :
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-code as character no-undo .
define output parameter p-attr-value-character as character no-undo .
define output parameter p-attr-value-date as date no-undo .
define output parameter p-attr-value-decimal as decimal no-undo .
define output parameter p-attr-value-integer as integer no-undo .
define output parameter p-attr-value-logical as logical no-undo .
define output parameter p-attr-value-type as character no-undo .
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not (libthpos_context.db-num = p-db-num
          or
          libthpos_context.obj-code = p-obj-code
          or
          libthpos_context.pos-type = p-pos-type
          or
          libthpos_context.cash-num = p-cash-num) then do:
    undo main-block, return error substitute("Неверный контекст").
  end.
  find first buf_libthpos_cash-desk-attr where
            buf_libthpos_cash-desk-attr.upper-attr-code = p-upper-attr-code
        and buf_libthpos_cash-desk-attr.attr-code = p-attr-code
        and buf_libthpos_cash-desk-attr.db-num = libthpos_context.db-num
        and buf_libthpos_cash-desk-attr.obj-code = libthpos_context.obj-code
        and buf_libthpos_cash-desk-attr.pos-type = libthpos_context.pos-type
        and buf_libthpos_cash-desk-attr.cash-num = libthpos_context.cash-num no-error .
  if not available buf_libthpos_cash-desk-attr then do:
    undo  main-block, return error substitute("Не найден параметр кассы &1 (секция &2)", p-attr-code, p-upper-attr-code).
  end.
  assign
  p-attr-value-character = buf_libthpos_cash-desk-attr.attr-value-character
  p-attr-value-date = buf_libthpos_cash-desk-attr.attr-value-date
  p-attr-value-decimal = buf_libthpos_cash-desk-attr.attr-value-decimal
  p-attr-value-integer = buf_libthpos_cash-desk-attr.attr-value-integer
  p-attr-value-logical = buf_libthpos_cash-desk-attr.attr-value-logical
  p-attr-value-type = buf_libthpos_cash-desk-attr.attr-value-type
  .
end.
end procedure.
procedure libthpos_get-all-cda :
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define output parameter dataset FOR libthpos_params .
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not (libthpos_context.db-num = p-db-num
          or
          libthpos_context.obj-code = p-obj-code
          or
          libthpos_context.pos-type = p-pos-type
          or
          libthpos_context.cash-num = p-cash-num) then do:
    undo main-block, return error substitute("Неверный контекст").
  end.
end.
end procedure.
procedure libthpos_create-context :
define input parameter p-parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define output parameter p-serial-code as character no-undo .
define output parameter p-r-b as character no-undo .
define output parameter p-base-code as integer no-undo .
define variable v-type as character no-undo .
define variable v-tth as handle no-undo .
define variable v-process-sale as logical no-undo .
define variable v-nam-artc as logical no-undo .
define variable v-cod-pcod as logical no-undo .
define variable v-nam-2str as logical no-undo .
define variable v-name-2cd as character no-undo .
define variable v-how-temp-disc as character no-undo .
define variable v-nalc as integer no-undo .
define variable v-rmethod-type as character no-undo .
define variable v-rmethod-coeff as decimal no-undo .
define variable v-cash-counter as decimal no-undo .
define variable v-manual-discnt as integer no-undo .
define variable v-salesman-mandatory as integer no-undo .
define variable v-log-level as integer   no-undo .
define variable v-qnty-change as logical   no-undo .
define variable v-pos-type-for-discnt as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-call-id as character no-undo .
define variable v-prop-code as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_libthpos_context for libthpos_context.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define buffer buf_cash-pay for ub.cash-pay.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if p-pos-type <> 'IBS-TH':U
  and p-pos-type <> 'IBS-TH-MOB':U
  then do:
    undo main-block, return error substitute("Неверный тип POS = &1", p-pos-type).
  end.
  find first buf_cash-desk no-lock where
          buf_cash-desk.db-num = p-db-num
      and buf_cash-desk.obj-code = p-obj-code
      and buf_cash-desk.pos-type = p-pos-type
      and buf_cash-desk.cash-num = p-cash-num no-error.
  if not available buf_cash-desk then do:
    undo main-block, return error substitute("Нет POS &1 №&2 на маг&3 БД &4"
                                  , p-pos-type
                                  , p-cash-num
                                  , p-obj-code
                                  , p-db-num
                                  ).
  end.
  if buf_cash-desk.cash-on = no then do:
    undo main-block, return error substitute("POS &1 №&2 на маг&3 БД &4 ВЫКЛЮЧЕН"
                                  , p-pos-type
                                  , p-cash-num
                                  , p-obj-code
                                  , p-db-num
                                  ).
  end.
  for each libthpos_chk-context:
    delete libthpos_chk-context.
  end.
  run libthpos_clear-context in this-procedure .
   run libthpos_create-flddf in this-procedure no-error .
   if error-status:error then do:
     undo, return error substitute("&1&2&3", error-status:get-message(1) , chr(10), return-value ).
   end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_create-context in g#libchkvl
  (input  'маг':U
  ,input  p-obj-code
  ,input  buffer buf_libthpos_context:handle
  ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_libthpos_context.
  for each buf_libthpos_dis-card-mask:
    delete buf_libthpos_dis-card-mask.
  end.
  _maska:
  for each buf_dis-card-mask no-lock where
      buf_Dis-card-mask.stts              = integer('0':U)
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> buf_libthpos_context.host-code then next _maska.
    if (buf_dis-card-mask.obj-type <> "":U
    AND buf_dis-card-mask.obj-type <> 'маг':U)
    or (buf_dis-card-mask.obj-code <> 0
    and buf_dis-card-mask.obj-code <> p-obj-code)
    then NEXT _maska.
    if buf_dis-card-mask.use-on = integer('2':U) then NEXT _Maska.
    create buf_libthpos_dis-card-mask.
    buffer-copy buf_dis-card-mask to
    buf_libthpos_dis-card-mask.
  end.
  run libthpos_fill-cda in this-procedure (
                                              input p-db-num
                                              ,input p-obj-code
                                              ,input p-pos-type
                                              ,input p-cash-num ) no-error.
  if error-status:error then do:
    undo main-block, return error substitute("Ошибка при поиске заполнении массива значений параметров кассы&1:&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  p-obj-code
      ,input  'cd-inf-send':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then return error .
  for each thbjattr_thbj-attr where
          thbjattr_thbj-attr.obj-type = 'маг':U
      and thbjattr_thbj-attr.obj-code = buf_libthpos_context.obj-code
      and thbjattr_thbj-attr.upper-prop-code = 'cd-inf-send':U
  on error undo, return error :
    case thbjattr_thbj-attr.prop-code:
      when 'nam-artc':U then do:
        v-nam-artc = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'cod-pcod':U then do:
        v-cod-pcod = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'nam-2str':U then do:
        v-nam-2str = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'name-2cd':U then do:
        v-name-2cd = thbjattr_thbj-attr.property-value-character.
      end.
      when 'how-temp-disc':U then do:
        v-how-temp-disc = thbjattr_thbj-attr.property-value-character.
      end.
    end case.
  end.
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  p-obj-code
      ,input  'cd-sending':U
      ,input  'process-sale':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-process-sale
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then return error .
  if p-pos-type = 'IBS-TH':U then do:
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_fisreg':U
          and buf_libthpos_cash-desk-attr.attr-code = 'cash-pay-list':U no-error.
      .
    run libthpos_get-cash-pay-list in this-procedure (
                                                      input  (if available buf_libthpos_cash-desk-attr
                                                      then buf_libthpos_cash-desk-attr.attr-value-character
                                                      else '') ) no-error .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_fisreg':U
          and buf_libthpos_cash-desk-attr.attr-code = 'pay-names':U no-error.
    run libthpos_get-pay-names in this-procedure ( input  (if available buf_libthpos_cash-desk-attr
                                                    then buf_libthpos_cash-desk-attr.attr-value-character
                                                    else '') ) no-error .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
          and buf_libthpos_cash-desk-attr.attr-code = 'nalc':U no-error.
      .
    assign
    v-nalc = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-integer
              else 0)
    .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
          and buf_libthpos_cash-desk-attr.attr-code = 'rmethod-type':U no-error.
      .
    assign
    v-rmethod-type = (if available buf_libthpos_cash-desk-attr
                      then buf_libthpos_cash-desk-attr.attr-value-character
                      else "MROUND")
    v-rmethod-coeff = (if not available buf_libthpos_cash-desk-attr
                      then 2.0
                      else v-rmethod-coeff)
    .
    if available buf_libthpos_cash-desk-attr then do:
      find first buf_libthpos_cash-desk-attr no-lock where
                buf_libthpos_cash-desk-attr.db-num = p-db-num
            and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
            and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
            and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
            and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
            and buf_libthpos_cash-desk-attr.attr-code = 'rmethod-coeff':U no-error.
      assign
      v-rmethod-coeff = (if available buf_libthpos_cash-desk-attr
                        then buf_libthpos_cash-desk-attr.attr-value-decimal
                        else (if v-rmethod-type = "MROUND"
                              then 2.0
                              else 0.0
                              )
                        )
      .
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    for each buf_inkas-pay-wth no-lock where
            buf_inkas-pay-wth.obj-code = p-obj-code
        and buf_inkas-pay-wth.obj-code = p-obj-code
        and buf_inkas-pay-wth.pay-desk = p-cash-num
        and buf_inkas-pay-wth.inkas-code = ''
        and buf_inkas-pay-wth.chk-type = 0
        and buf_inkas-pay-wth.cashier = 0
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_inkas-pay-wth.pay-code = 0
      and buf_inkas-pay-wth.curr-code = 0 then next.
      create buf_libthpos_cash-counter.
      buffer-copy buf_inkas-pay-wth to buf_libthpos_cash-counter
      .
      find first buf_cash-pay no-lock where
              buf_cash-pay.cdpay-code = buf_inkas-pay-wth.pay-code
          and buf_cash-pay.curr-code = buf_inkas-pay-wth.curr-code .
      if buf_cash-pay.is-cash then do:
        assign
        v-cash-counter = v-cash-counter + ( if buf_libthpos_context.r-b = 'rubl':U
                          then buf_inkas-pay-wth.tot-rubl
                          else buf_inkas-pay-wth.tot-base)
        buf_libthpos_cash-counter.is-cash = yes
        .
      end.
    end.
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
          and buf_libthpos_cash-desk-attr.attr-code = 'manual-discnt':U no-error.
      .
    assign
    v-manual-discnt = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-integer
              else 0)
    .
    v-pos-type-for-discnt = 'IBS-TH':U.
  end.
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = (if p-pos-type = 'IBS-TH':U
                                                           then 'IBS-TH_main':U
                                                           else 'IBS-TH-MOB_main':U)
        and buf_libthpos_cash-desk-attr.attr-code = (if p-pos-type = 'IBS-TH':U
                                                    then 'salesman-mandatory':U
                                                    else 'salesman-mandatory':U)  no-error.
     .
  assign
  v-salesman-mandatory = (if available buf_libthpos_cash-desk-attr
            then buf_libthpos_cash-desk-attr.attr-value-integer
            else 0)
  .
  if p-pos-type = 'IBS-TH-MOB':U then do:
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH-MOB_main':U
          and buf_libthpos_cash-desk-attr.attr-code = 'pos-type-for-discnt':U  no-error.
    assign
    v-pos-type-for-discnt = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-character
              else 'IBS-TH-MOB':U)
    .
  end.
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
        and buf_libthpos_cash-desk-attr.attr-code = 'log-level':U no-error.
   assign
   v-log-level = (if available buf_libthpos_cash-desk-attr
                 then buf_libthpos_cash-desk-attr.attr-value-integer
                 else 0).
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = 'IBS-TH_main':U
        and buf_libthpos_cash-desk-attr.attr-code = 'qnty-change':U no-error.
   assign
   v-qnty-change = (if available buf_libthpos_cash-desk-attr
                 then logical(buf_libthpos_cash-desk-attr.attr-value-integer)
                 else no).
  if p-pos-type = 'IBS-TH':U then do:
    assign
    v-prop-code = 'chk-doc_ibs-th':U
    .
  end.
  if p-pos-type = 'IBS-TH-MOB':U then do:
    assign
    v-prop-code = 'chk-doc_ibs-th-mob':U
    .
  end.
  find first buf_thbj-attr share-lock where
            buf_thbj-attr.obj-type = 'маг':U
        and buf_thbj-attr.obj-code = p-obj-code
        and buf_thbj-attr.upper-prop-code = 'rum_obj':U
        and buf_thbj-attr.prop-code = v-prop-code
        and buf_thbj-attr.property-value-logical = yes
        no-error.
  if not available buf_thbj-attr then do:
    find first buf_thbj-attr share-lock where
              buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.upper-prop-code = 'rum':U
          and buf_thbj-attr.prop-code = v-prop-code
          no-error.
  end.
  if available buf_thbj-attr then do:
    run gen-key-rec in this-procedure (
                                          input  'thbj-attr':U
                                         ,input (buffer buf_thbj-attr:handle)
                                         ,output v-call-id) .
    for each buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = v-call-id
    break
    by buf_rp-by-call.profile_id
    by buf_rp-by-call.once-more
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      create buf_libthpos_rp-by-call.
      assign
      buf_libthpos_rp-by-call.profile_id = buf_rp-by-call.profile_id
      buf_libthpos_rp-by-call.once-more = buf_rp-by-call.once-more
      buf_libthpos_rp-by-call.call_id = buf_rp-by-call.call_id
      v-bh[1] = (buffer buf_libthpos_context:handle)
      .
      run value( substitute("rul/rp-&1.p"
                            , buf_libthpos_rp-by-call.profile_id))
            persistent set buf_libthpos_rp-by-call.rph
                (
                  input p-parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle
                  ,input ?
                  ,input v-call-id
                  ,input buf_libthpos_rp-by-call.profile_id
                  ,input buf_libthpos_rp-by-call.once-more
                  ,input buf_libthpos_context.host-code
                  ,input buf_libthpos_context.obj-type
                  ,input buf_libthpos_context.obj-code
                  ,input p-pos-type
                  ,input v-pos-type-for-discnt
                  ,input buf_libthpos_context.p-log-file-name
                  ,input (buffer libthpos_flddf:handle)
                  ,input v-bh
                ) no-error
                .
      if error-status :error then do:
        run libthpos_clear-context in this-procedure no-error.
        undo main-block, return error substitute("Ошибка при загрузке процедуры расчета скидок/бонусов для профайла &1", buf_rp-by-call.profile_id).
      end.
    end.
  end.
  assign
  buf_libthpos_context.parparentproc = p-parparentproc
  buf_libthpos_context.p-log-handle = p-log-handle
  buf_libthpos_context.tt-wd-bh = (buffer libthpos_chk-discnt:handle)
  buf_libthpos_context.process-sale = v-process-sale
  buf_libthpos_context.pos-type = p-pos-type
  buf_libthpos_context.cash-num = p-cash-num
  buf_libthpos_context.nalc = v-nalc
  buf_libthpos_context.rmethod-type = v-rmethod-type
  buf_libthpos_context.rmethod-coeff = v-rmethod-coeff
  buf_libthpos_context.nam-artc   = v-nam-artc
  buf_libthpos_context.nam-2str   = v-nam-2str
  buf_libthpos_context.cod-pcod   = v-cod-pcod
  buf_libthpos_context.name-2cd   = v-name-2cd
  buf_libthpos_context.cash-counter = v-cash-counter
  buf_libthpos_context.salesman-mandatory = v-salesman-mandatory
  buf_libthpos_context.manual-discnt = v-manual-discnt
  buf_libthpos_context.log-level = v-log-level
  buf_libthpos_context.qnty-change = v-qnty-change
  buf_libthpos_context.pos-type-for-discnt = v-pos-type-for-discnt
  buf_libthpos_context.chk-discnt-table = (buffer libthpos_chk-discnt:handle:table-handle)
  buf_libthpos_context.chk-gds-table = (buffer libthpos_chk-gds:handle:table-handle)
  buf_libthpos_context.chk-pay-table = (buffer libthpos_chk-pay:handle:table-handle)
  p-r-b = buf_libthpos_context.r-b
  p-base-code = buf_libthpos_context.base-code
  buf_libthpos_context.serial-code = buf_cash-desk.serial-code
  p-serial-code = buf_cash-desk.serial-code
  .
end.
end procedure.
procedure libthpos_get-context-property :
define input parameter p-what-context as integer no-undo .
define input parameter p-property as character no-undo .
define output parameter p-character as character no-undo .
define output parameter p-date as date no-undo .
define output parameter p-decimal as decimal no-undo .
define output parameter p-integer as integer no-undo .
define output parameter p-logical as logical no-undo .
define output parameter p-handle as handle no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-setted as logical no-undo .
define variable v-fh as handle no-undo .
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if p-what-context = 2 then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      undo main-block, return error substitute("Не выставлен контекст чека").
    end.
  end.
  case p-what-context:
    when 1 then do:
      assign
      v-fh = buffer libthpos_context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста работы =&1", p-property).
      end.
    end.
    when 2 then do:
      assign
      v-fh = buffer libthpos_chk-context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста чека =&1", p-property).
      end.
    end.
  end case.
  assign
  p-data-type = v-fh:data-type.
  case p-data-type:
    when 'character':U then do:
      assign
      p-character = v-fh:buffer-value
      .
    end.
    when 'date':U then do:
      assign
      p-date = v-fh:buffer-value
      .
    end.
    when 'decimal':U then do:
      assign
      p-decimal = v-fh:buffer-value
      .
    end.
    when 'integer':U then do:
      assign
      p-integer = v-fh:buffer-value
      .
    end.
    when 'logical':U then do:
      assign
      p-logical = v-fh:buffer-value
      .
    end.
    when 'handle':U then do:
      assign
      p-handle = v-fh:buffer-value
      .
    end.
    otherwise do:
      undo main-block, return error substitute("Неверный или неизвестный тип данных для свойства &1 = &2"
                                               , v-fh:data-type
                                               , p-property).
    end.
  end case.
  p-setted = yes.
end.
end procedure.
procedure libthpos_set-context-property :
define input parameter p-what-context as integer no-undo .
define input parameter p-property as character no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date as date no-undo .
define input parameter p-decimal as decimal no-undo .
define input parameter p-integer as integer no-undo .
define input parameter p-logical as logical no-undo .
define input parameter p-handle as handle no-undo .
define output parameter p-setted as logical no-undo .
define variable v-fh as handle no-undo .
define variable v-data-type as character no-undo .
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if p-what-context = 2 then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      undo main-block, return error substitute("Не выставлен контекст чека").
    end.
  end.
  case p-what-context:
    when 1 then do:
      assign
      v-fh = buffer libthpos_context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста работы =&1", p-property).
      end.
      if lookup(p-property, "p-log-handle,p-log-file-name,z-number,emulator-mode") = 0 then do:
         undo main-block , return error substitute("Запрошенное свойство контекста работы =&1 является READ-ONLY", p-property).
      end.
    end.
    when 2 then do:
      assign
      v-fh = buffer libthpos_chk-context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста чека =&1", p-property).
      end.
      if lookup(p-property, "xxx") = 0 then do:
        undo main-block , return error substitute("Запрошенное свойство контекста чека =&1 является READ-ONLY", p-property).
      end.
    end.
  end case.
  assign
  v-data-type = v-fh:data-type.
  case v-data-type:
    when 'character':U then do:
      assign
      v-fh:buffer-value = p-character
      .
    end.
    when 'date':U then do:
      assign
      v-fh:buffer-value = p-date
      .
    end.
    when 'decimal':U then do:
      assign
      v-fh:buffer-value = p-decimal
      .
    end.
    when 'integer':U then do:
      assign
      v-fh:buffer-value = p-integer
      .
    end.
    when 'logical':U then do:
      assign
      v-fh:buffer-value =  p-logical
      .
    end.
    when 'handle':U then do:
      assign
      v-fh:buffer-value = p-handle
      .
    end.
    otherwise do:
      undo main-block, return error substitute("Неверный или неизвестный тип данных для свойства &1 = &2"
                                               , v-fh:data-type
                                               , p-property).
    end.
  end case.
  p-setted = yes.
end.
end procedure.
procedure libthpos_set-log :
define input parameter p-log-handle as handle no-undo .
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not valid-handle(p-log-handle) then do:
    undo main-block, return error substitute("Неверный указатель на процедуру логирования").
  end.
  for each buf_libthpos_rp-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run rp-chk-doc_set-log in buf_libthpos_rp-by-call.rph no-error.
  end.
  assign
  libthpos_context.p-log-handle = p-log-handle
  .
end.
end procedure.
procedure libthpos_create-chk-doc :
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-chk-type as integer no-undo .
define input parameter p-cashier  as integer no-undo .
define input parameter p-cashier-psn-code as integer no-undo .
define output parameter p-doc-code as character no-undo .
define output parameter p-bank-rate as decimal no-undo .
define output parameter p-bank-scale as decimal no-undo .
define output parameter p-cash-rate as decimal no-undo .
define output parameter p-cash-scale as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-sale-in-out as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if (lookup(string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U) = 0 and lookup(string(p-chk-type), '201,206,208,301,306':U) = 0)
    or lookup(string(p-chk-type), '14,15,16,17,36':U) > 0
    or lookup(string(p-chk-type), '101,106,108,169,196,114,115,116,136,117,111,112,113':U) > 0
    or lookup(string(p-chk-type), '8':U) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека = &1", p-chk-type).
      undo main-block, retry main-block .
    end.
    if lookup(string(p-chk-type), '201,206,208,301,306':U) = 0
    and p-pos-type = 'IBS-TH-MOB':U then do:
      v-err-mess = substitute("Неверный тип чека = &1 для кассы типа &2", p-chk-type, p-pos-type).
      undo main-block, retry main-block .
    end.
    if lookup(string(p-chk-type), '201,206,208,301,306':U) > 0
    and p-pos-type <> 'IBS-TH-MOB':U then do:
      v-err-mess = substitute("Неверный тип чека = &1 для кассы типа &2", p-chk-type, p-pos-type).
      undo main-block, retry main-block .
    end.
    find first libthpos_context no-error.
    if not available libthpos_context then do:
      v-err-mess = substitute("Не выставлен контекст работы").
      undo main-block, retry main-block .
    end.
    if libthpos_context.pos-type = 'IBS-TH':U
    and lookup(string(p-chk-type), '201,206,208,301,306':U) = 0
    and (libthpos_context.z-number <= 0
    or libthpos_context.z-number = ?)
    and libthpos_context.emulator-mode = 0
    then do:
      v-err-mess = substitute("Не выставлен № z-отчета").
      undo main-block, retry main-block .
    end.
    if not (libthpos_context.db-num = p-db-num
            and
            libthpos_context.obj-code = p-obj-code
            and
            libthpos_context.pos-type = p-pos-type
            and
            libthpos_context.cash-num = p-cash-num) then do:
      v-err-mess = substitute("Неверный контекст").
      undo main-block, retry main-block .
    end.
    if not is-cdinv and p-chk-type = integer('11':U) then do:
      v-err-mess = substitute("В данной конфигурации запрещено делать инвентаризацию на кассах").
      undo main-block, retry main-block .
    end.
    if not is-ptrl and lookup(string(p-chk-type), '14,15,16,17,36':U) > 0
    then do:
      v-err-mess = substitute("В данной конфигурации запрещено делать специфические чеки топлива").
      undo main-block, retry main-block .
    end .
    if buffer libthpos_chk-context:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    if buffer libthpos_chk-pay:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    if buffer libthpos_chk-gds:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    if buffer libthpos_chk-discnt:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    dataset libthpos_receipt:empty-dataset().
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input yes).
    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_staff no-lock where
              buf_staff.role = 'C':U
        and buf_staff.role-level = 'db':U
        and buf_staff.db-num = p-db-num
        and buf_staff.staff-code = p-cashier
        and buf_staff.date-start <= v-today
        and buf_staff.date-end >= v-today
        and buf_staff.psn-code = p-cashier-psn-code no-error.
    if not available buf_staff then do:
      v-err-mess =  substitute("На текущий момент нет кассира с кодом &1 БД &2 и кодом физ.лица &3"
                                  , p-cashier
                                  , p-db-num
                                  , p-cashier-psn-code
                                  ).
      undo main-block, retry main-block.
    end.
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    if libthpos_context.r-b = 'base':U
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = 'маг':U
                AND buf_curr-shop.obj-code = p-obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess =  substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
    end.
    if libthpos_context.r-b = 'rubl':U
    and libthpos_context.base-code <> 0 then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = 'маг':U
            AND buf_curr-shop.obj-code = p-obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess =  substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
    end.
    if lookup(string(p-chk-type), '6,96':U) > 0
    or  lookup(string(p-chk-type), '1,69,14,15,16,36':U) > 0 then do:
      assign
      v-sale-in-out = yes
      .
    end.
    create buf_chk-doc.
    create libthpos_chk-context.
    assign
    buf_chk-doc.obj-type = 'маг':U
    buf_chk-doc.obj-code = p-obj-code
    buf_chk-doc.office = ?
    buf_chk-doc.doc-code = (if p-db-num = 0
                            then string(next-value(s-chk, ub ))
                            else string( p-obj-code ) + chr(47) + string( next-value( s-chk, ub ) ))
    loc-print-doc-code = buf_chk-doc.doc-code
    buf_chk-doc.chk-id = buf_chk-doc.doc-code
    buf_chk-doc.chk-date = v-today
    buf_chk-doc.chk-time = v-time
    buf_chk-doc.pay-desk = p-cash-num
    buf_chk-doc.cashier  = p-cashier
    buf_chk-doc.cashier-psn-code  = p-cashier-psn-code
    buf_chk-doc.src-d-card =  ''
    buf_chk-doc.d-card =  ''
    buf_chk-doc.src-d-pcnt =  0
    buf_chk-doc.src-cli-type = ?
    buf_chk-doc.src-cli-code = 0
    buf_chk-doc.src-shift-date = v-today
    buf_chk-doc.src-shift-name = ''
    buf_chk-doc.shift-name = ''
    buf_chk-doc.shift-num = 0
    buf_chk-doc.cash-rate = v-cash-rate
    buf_chk-doc.cash-scale = v-cash-scale
    buf_chk-doc.base-rate = v-base-rate
    buf_chk-doc.z-number = libthpos_context.z-number
    buf_chk-doc.chk-type = p-chk-type
    buf_chk-doc.correct = yes
    buf_chk-doc.discnt = 0
    buf_chk-doc.sales-man = libthpos_context.sales-man
    buf_chk-doc.salesman-psn-code = libthpos_context.salesman-psn-code
    buf_chk-doc.src-tot-doc = 0
    buf_chk-doc.netto = 0
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.doc-qnty = 0
    libthpos_chk-context.doc-code = buf_chk-doc.doc-code
    libthpos_chk-context.obj-code = buf_chk-doc.obj-code
    libthpos_chk-context.chk-type = buf_chk-doc.chk-type
    libthpos_chk-context.lng = 0
    libthpos_chk-context.recalc-gline-num = libthpos_chk-context.lng + 1
    libthpos_chk-context.lnp = 0
    libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
    libthpos_chk-context.lnd = 0
    libthpos_chk-context.chk-date = v-today
    libthpos_chk-context.chk-time = v-time
    libthpos_chk-context.base-rate = v-base-rate
    libthpos_chk-context.cash-rate = v-cash-rate
    libthpos_chk-context.cash-scale = v-cash-scale
    libthpos_chk-context.bank-rate = v-bank-rate
    libthpos_chk-context.bank-scale = v-bank-scale
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    libthpos_chk-context.is-petrol-check = lookup(string(p-chk-type), '14,15,16,17,36':U) > 0
    libthpos_chk-context.rowid_ = rowid(buf_chk-doc)
    libthpos_chk-context.sale-in-out = v-sale-in-out
    p-doc-code = buf_chk-doc.doc-code
    p-bank-rate = v-bank-rate
    p-bank-scale = v-bank-scale
    p-cash-rate = v-cash-rate
    p-cash-scale = v-cash-scale
    .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
  libthpos_chk-context.direction = libchkvl_right-netto-sign (
                                  input  libthpos_chk-context.chk-type
                                  )
 .
    create libthpos_chk-doc.
    buffer-copy buf_Chk-doc to libthpos_chk-doc.
    find first locked_chk-doc share-lock where
              rowid(locked_chk-doc) = rowid(buf_chk-doc).
    libthpos_context.ll = libthpos_context.ll + 1.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_create-chk-title :
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-chk-type as integer no-undo .
define input parameter p-cashier  as integer no-undo .
define input parameter p-cashier-psn-code as integer no-undo .
define output parameter p-doc-code as character no-undo .
define output parameter p-bank-rate as decimal no-undo .
define output parameter p-bank-scale as decimal no-undo .
define output parameter p-cash-rate as decimal no-undo .
define output parameter p-cash-scale as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-sale-in-out as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if lookup(string(p-chk-type), '2,3,4,5,7':U) = 0
    then do:
      v-err-mess = substitute("Неверный тип чека МЦ = &1", p-chk-type).
      undo main-block, retry main-block.
    end.
    if p-pos-type = 'IBS-TH-MOB':U then do:
      v-err-mess = substitute("Неверный тип кассы = &2", p-pos-type).
      undo main-block, retry main-block.
    end.
    find first libthpos_context no-error.
    if not available libthpos_context then do:
      v-err-mess = substitute("Не выставлен контекст работы").
      undo main-block, retry main-block.
    end.
    if not (libthpos_context.db-num = p-db-num
            and
            libthpos_context.obj-code = p-obj-code
            and
            libthpos_context.pos-type = p-pos-type
            and
            libthpos_context.cash-num = p-cash-num) then do:
      v-err-mess = substitute("Неверный контекст").
      undo main-block, retry main-block.
    end.
    if buffer libthpos_chk-context:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    if buffer libthpos_chk-pay:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    if buffer libthpos_chk-gds:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    if buffer libthpos_chk-discnt:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    dataset libthpos_receipt:empty-dataset().
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    ,  input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input yes).
    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_staff no-lock where
              buf_staff.role = 'C':U
        and buf_staff.role-level = 'db':U
        and buf_staff.db-num = p-db-num
        and buf_staff.staff-code = p-cashier
        and buf_staff.date-start <= v-today
        and buf_staff.date-end >= v-today
        and buf_staff.psn-code = p-cashier-psn-code no-error.
    if not available buf_staff then do:
      v-err-mess = substitute("На текущий момент нет кассира с кодом &1 БД &2 и кодом физ.лица &3"
                                  , p-cashier
                                  , p-db-num
                                  , p-cashier-psn-code
                                  ).
      undo main-block, retry main-block.
    end.
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    if libthpos_context.r-b = 'base':U
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = 'маг':U
                AND buf_curr-shop.obj-code = p-obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
    end.
    if libthpos_context.r-b = 'rubl':U
    and libthpos_context.base-code <> 0 then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = 'маг':U
            AND buf_curr-shop.obj-code = p-obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
    end.
    create buf_chk-doc.
    create libthpos_chk-context.
    assign
    buf_chk-doc.obj-type = 'маг':U
    buf_chk-doc.obj-code = p-obj-code
    buf_chk-doc.office = ?
    buf_chk-doc.doc-code = (if p-db-num = 0
                            then string(next-value(s-chk, ub ))
                            else string( p-obj-code ) + chr(47) + string( next-value( s-chk, ub ) ))
    loc-print-doc-code = buf_chk-doc.doc-code
    buf_chk-doc.chk-date = v-today
    buf_chk-doc.chk-time = v-time
    buf_chk-doc.pay-desk = p-cash-num
    buf_chk-doc.cashier  = p-cashier
    buf_chk-doc.cashier-psn-code  = p-cashier-psn-code
    buf_chk-doc.d-card =  ''
    buf_chk-doc.src-shift-date = v-today
    buf_chk-doc.src-shift-name = ''
    buf_chk-doc.shift-name = ''
    buf_chk-doc.shift-num = 0
    buf_chk-doc.cash-rate = v-cash-rate
    buf_chk-doc.cash-scale = v-cash-scale
    buf_chk-doc.base-rate = v-base-rate
    buf_chk-doc.z-number = libthpos_context.z-number
    buf_chk-doc.chk-type = p-chk-type
    buf_chk-doc.correct = yes
    buf_chk-doc.discnt = 0
    buf_chk-doc.sales-man = libthpos_context.sales-man
    buf_chk-doc.salesman-psn-code = libthpos_context.salesman-psn-code
    libthpos_chk-context.doc-code = buf_chk-doc.doc-code
    libthpos_chk-context.obj-code = buf_chk-doc.obj-code
    libthpos_chk-context.chk-type = buf_chk-doc.chk-type
    libthpos_chk-context.lnp = 0
    libthpos_chk-context.chk-date = v-today
    libthpos_chk-context.chk-time = v-time
    libthpos_chk-context.base-rate = v-base-rate
    libthpos_chk-context.cash-rate = v-cash-rate
    libthpos_chk-context.cash-scale = v-cash-scale
    libthpos_chk-context.bank-rate = v-bank-rate
    libthpos_chk-context.bank-scale = v-bank-scale
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    libthpos_chk-context.rowid_ = rowid(buf_chk-doc)
    p-doc-code = buf_chk-doc.doc-code
    p-bank-rate = v-bank-rate
    p-bank-scale = v-bank-scale
    p-cash-rate = v-cash-rate
    p-cash-scale = v-cash-scale
    .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
  libthpos_chk-context.direction = libchkvl_right-netto-sign (
                                  input  libthpos_chk-context.chk-type
                                  )
 .
    create libthpos_chk-doc.
    buffer-copy buf_chk-doc to libthpos_chk-doc.
    find first locked_chk-doc share-lock where
              rowid(locked_chk-doc) = rowid(buf_chk-doc).
    libthpos_context.ll = libthpos_context.ll + 1.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_set-salesman :
define input parameter p-doc-code as character no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-sales-man as integer no-undo .
define input parameter p-salesman-psn-code as integer no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_Chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if p-doc-code <> "" then do:
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context no-error.
      end.
      if not available libthpos_chk-context then do:
        v-err-mess = substitute("Не выставлен контекст чека").
        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.doc-code <> p-doc-code then do:
        v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
        undo main-block, retry main-block.
      end.
      if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0
      or lookup(string(libthpos_chk-context.chk-type), '112':U) > 0
      or lookup(string(libthpos_chk-context.chk-type), '12':U) > 0
      or lookup(string(libthpos_chk-context.chk-type), '111':U) > 0
      or lookup(string(libthpos_chk-context.chk-type), '11':U) > 0
      then do:
        v-err-mess = substitute("В чеке &1 с типом &2 продавца быть не может", p-doc-code, libthpos_chk-context.chk-type).
        undo main-block, retry main-block.
      end.
    end.
    if p-line-num <> 0  then do:
      if p-doc-code = ""
      then do:
        v-err-mess = substitute("Задана строк чека (=&1) для установки продавца, но не задан номер чека", p-line-num).
        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.lng < p-line-num then do:
        v-err-mess = substitute("В чеке &1 на строки &2"
                                      , p-doc-code
                                      , p-line-num).
        undo main-block, retry main-block.
      end.
    end.
    if p-sales-man <> 0 then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      find first buf_staff no-lock where
                buf_staff.role = 'S':U
          and buf_staff.role-level = 'db':U
          and buf_staff.db-num = libthpos_context.db-num
          and buf_staff.staff-code = p-sales-man
          and buf_staff.date-start <= v-today
          and buf_staff.date-end >= v-today
          and buf_staff.psn-code = p-salesman-psn-code no-error.
      if not available buf_staff then do:
        v-err-mess = substitute("На текущий момент нет продавца с кодом &1 БД &2 и кодом физ.лица &3"
                                    , p-sales-man
                                    , libthpos_context.db-num
                                    , p-salesman-psn-code
                                    ).
        undo main-block, retry main-block.
      end.
    end.
    if p-doc-code = "" then do:
      assign
      libthpos_context.sales-man = p-sales-man
      libthpos_context.salesman-psn-code = (if p-sales-man = 0 then 0 else p-salesman-psn-code)
      .
    end.
    else do:
      assign
      libthpos_chk-context.sales-man = p-sales-man
      libthpos_chk-context.salesman-psn-code = (if p-sales-man = 0 then 0 else p-salesman-psn-code)
      .
      find first buf_chk-doc where
                buf_chk-doc.doc-code = p-doc-code.
      assign
      buf_chk-doc.sales-man = p-sales-man
      buf_chk-doc.salesman-psn-code = p-salesman-psn-code
      .
      if p-line-num > 0 then do:
        for first buf_chk-gds share-lock where
                buf_chk-gds.doc-code = p-doc-code
            and buf_chk-gds.line-num = p-line-num,
            first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = p-doc-code
              and buf_libthpos_chk-gds.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        :
          assign
          buf_chk-gds.sales-man = p-sales-man
          buf_chk-gds.salesman-psn-code = p-salesman-psn-code
          buf_libthpos_chk-gds.sales-man = p-sales-man
          buf_libthpos_chk-gds.salesman-psn-code = p-salesman-psn-code
          .
        end.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    p-setted = yes.
  end.
end.
end procedure.
procedure libthpos_set-card :
define input parameter p-doc-code as character no-undo .
define input parameter p-src-d-card as character no-undo .
define output parameter p-d-card as character no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer no-undo .
define output parameter p-obj-name as character no-undo .
define variable v-found as logical no-undo .
define variable v-descr as character no-undo .
define variable v-short-number as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-d-mask as character no-undo .
define variable v-d-card as character no-undo .
define variable v-th-mask as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0
    or lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 карты быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= 3 then do:
      v-err-mess = substitute("Уже есть строки оплаты, нельзя зарегистрировать ДК").
      undo main-block, retry main-block.
    end.
    find first buf_Dis-card no-lock where
              buf_Dis-card.d-card = p-src-d-card no-error.
    if not available buf_dis-card then do:
      if (libthpos_context.dc-mask or libthpos_context.card-by-mask) then do:
        _maska:
        for each buf_libthpos_dis-card-mask no-lock
        by buf_libthpos_dis-card-mask.rank
        on error undo main-block, retry main-block
        :
          assign
          v-found = yes
          v-descr = "":U
          v-short-number = '':U
          v-is-correct = no
          .
          if libthpos_context.card-by-mask then do:
            assign
            v-short-number = card-by-mask (buf_libthpos_dis-card-mask.cli-mask, buf_libthpos_dis-card-mask.cc-run, p-src-d-card)
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удается определить короткий номер ДК по маске (полный номер &1):&2&3"
                                            , p-src-d-card
                                            , chr(10)
                                            , return-value ).
              undo main-block, retry main-block.
            end.
            v-d-mask = buf_libthpos_dis-card-mask.cli-mask.
          end.
          if v-short-number = '':U then do:
            if libthpos_context.dc-mask then do:
              assign
              v-is-correct = check-by-mask (buf_libthpos_dis-card-mask.mask, p-src-d-card, output v-descr)
              no-error
              .
              if error-status:error then do:
                v-err-mess = substitute("Не удается сопоставить карту (полный номер &1) маске:&2&3"
                                              , p-src-d-card
                                              , chr(10)
                                              , return-value ).
                undo main-block, retry main-block.
              end.
              v-d-mask = buf_libthpos_dis-card-mask.mask.
            end.
          end.
          if v-is-correct or v-short-number <> '':U then do:
            find first buf_dis-card no-lock where
                      buf_dis-card.d-card = (if v-short-number <> '':U
                                            then v-short-number
                                            else buf_libthpos_dis-card-mask.mask) no-error .
            if available buf_dis-card
            and buf_dis-card.type = buf_libthpos_dis-card-mask.type
            and buf_dis-card.emitent-host-code = buf_libthpos_dis-card-mask.emitent-host-code
            then do:
              assign
              v-d-card = buf_Dis-card.d-card
              v-th-mask = yes
              .
              LEAVE _maska.
            end.
          end.
        end.
        if not available buf_dis-card then do:
          v-err-mess =  (if not v-found
                            then substitute("Для карты &1 не определено ни одной действующей маски", v-d-card)
                            else substitute("Карта &1 не соответствует ни одной действующей маске", v-d-card)
                          ) .
          undo main-block, retry main-block.
        end.
      end.
    end.
    if avail buf_dis-card
    then find first buf_dis-card-type No-LOCK WHERE
                    buf_dis-card-type.type = buf_dis-card.type AND
                    buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code AND
                    buf_dis-card-type.host-code = 0 AND
                    buf_dis-card-type.obj-type = "":U AND
                    buf_dis-card-type.obj-code = 0
                    NO-ERROR.
    else release buf_dis-card-type.
    IF NOT avail buf_dis-card
    or NOT avail buf_dis-card-type
    OR (buf_dis-card.emitent-host-code <> libthpos_context.host-code and buf_dis-card.emitent-host-code <> 0)
    or (lookup(string(libthpos_context.obj-code), buf_dis-card-type.DCBYSHOP) > 0
        and
        buf_dis-card.issue-code <> libthpos_context.obj-code)
    then do:
      v-err-mess = substitute("Нет сведений о карте клиента &1 или карта выдана другим магазином"
                              , p-src-d-card
                            ) .
      undo main-block, retry main-block.
    end.
    if avail buf_dis-card
    and buf_dis-card.emitent-host-code = 0
    and buf_dis-card.credit-card then do:
      v-err-mess = substitute(
                              "Глобальная карта &1 (&2) не может быть кредитной"
                              , p-src-d-card
                              , v-d-card
                            ) .
      undo main-block, retry main-block.
    end.
    if avail buf_dis-card
    and buf_dis-card.status_ = 'неисп':U then do:
      v-err-mess = substitute("Карта &2 имеет статус &3&1" +
                              "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА и подлежит ПОЛНОМУ И ОКОНЧАТЕЛЬНОМУ УДАЛЕНИЮ&1"
                              , chr(10)
                              , buf_dis-card.d-card
                              , buf_dis-card.status_
                            )                  .
      undo main-block, retry main-block.
    end.
    if available buf_Dis-card
    and buf_dis-card.status_ =  'удал':U then do:
      v-err-mess = substitute("Карта &2 имеет статус &3&1" +
                              "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                              , chr(10)
                              , buf_dis-card.d-card
                              , buf_dis-card.status_
                            )                  .
      undo main-block, retry main-block.
    end.
    if available buf_dis-card
    and buf_Dis-card.valid-from <> ? then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      if buf_dis-card.valid-from > v-today then do:
        v-err-mess = substitute("Дата начала действия карты &1 = &2&3" +
                                "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                                , buf_dis-card.d-card
                                , string(buf_dis-card.valid-from, "99/99/9999")
                                , chr(10)
                              )                  .
        undo main-block, retry main-block.
      end.
    end.
    if available buf_dis-card
    and buf_Dis-card.valid-date <> ? then do:
      if v-today = ? then do:
        run cur-time in this-procedure ( output v-today, output v-time).
      end.
      if buf_dis-card.valid-date < v-today then do:
        v-err-mess = substitute("Карта &1 просрочена (&2)&3" +
                                "и НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                                , buf_dis-card.d-card
                                , string(buf_dis-card.valid-from, "99/99/9999")
                                , chr(10)
                              )                  .
        undo main-block, retry main-block.
      end.
    end.
    find first buf_chk-doc share-lock where
              rowid(buf_chk-doc) = libthpos_chk-context.rowid_.
    assign
    p-d-card   = buf_Dis-card.d-card
    p-cli-type = buf_Dis-card.cli-type
    p-cli-code = buf_Dis-card.cli-code
    buf_chk-doc.src-d-card = p-src-d-card
    buf_chk-doc.src-d-mask = v-d-mask
    buf_chk-doc.src-cli-type = buf_dis-card.cli-type
    buf_chk-doc.src-cli-code = buf_dis-card.cli-code
    libthpos_chk-doc.src-d-card = p-src-d-card
    libthpos_chk-doc.src-d-mask = v-d-mask
    libthpos_chk-doc.src-cli-type = buf_dis-card.cli-type
    libthpos_chk-doc.src-cli-code = buf_dis-card.cli-code
    libthpos_chk-context.src-d-card = p-src-d-card
    libthpos_chk-context.src-d-mask = v-d-mask
    libthpos_chk-context.src-cli-type = buf_dis-card.cli-type
    libthpos_chk-context.src-cli-code = buf_dis-card.cli-code
     libthpos_chk-context.d-pcnt = (if buf_dis-card.d-pcnt-method = integer('1':U)
                                  or buf_dis-card.d-pcnt-method  = integer('3':U)
                                  then buf_dis-card.d-pcnt
                                  else 0)
    libthpos_chk-context.cash-d-pcnt = (if buf_dis-card.d-pcnt-method = integer('2':U)
                                        or buf_dis-card.d-pcnt-method  = integer('3':U)
                                        then  buf_dis-card.cash-d-pcnt
                                        else 0)
    libthpos_chk-context.category = buf_dis-card.category
    .
    if buf_dis-card-type.d-pcnt-byshop then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  libthpos_context.host-code
  ,input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  'def-pcnt':U
  ,output libthpos_chk-context.d-pcnt
  ) no-error .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  libthpos_context.host-code
  ,input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  'def-cash-pcnt':U
  ,output libthpos_chk-context.cash-d-pcnt
  ) no-error .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  libthpos_context.host-code
  ,input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  'def-categ':U
  ,output libthpos_chk-context.category
  ) no-error .
    end.
    if libthpos_chk-context.step > 0 then do:
      for each buf_chk-gds share-lock where
              buf_chk-gds.doc-code = p-doc-code,
        first libthpos_chk-gds where
            libthpos_chk-gds.doc-code = p-doc-code
          and libthpos_chk-gds.line-num = buf_chk-gds.line-num
      on error undo main-block, retry main-block:
        assign
        buf_chk-gds.src-d-card = p-src-d-card
        buf_chk-gds.src-d-mask = v-d-mask
        buf_chk-gds.src-cli-type = buf_dis-card.cli-type
        buf_chk-gds.src-cli-code = buf_dis-card.cli-code
        libthpos_chk-gds.src-d-card = p-src-d-card
        libthpos_chk-gds.src-d-mask = v-d-mask
        libthpos_chk-gds.src-cli-type = buf_dis-card.cli-type
        libthpos_chk-gds.src-cli-code = buf_dis-card.cli-code
        libthpos_chk-context.recalc-gline-num = 1
        .
      end.
      run libthpos_recalc-discnt in this-procedure no-error.
      if error-status:error then do:
        v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
        undo main-block, retry main-block.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_gds-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-line-direction as integer no-undo .
define input  parameter p-src-code as character no-undo .
define input-output  parameter p-src-qnty as decimal no-undo .
define input  parameter p-pump as integer no-undo .
define input  parameter p-nozzle-code as integer no-undo .
define input  parameter p-pl-code    as integer no-undo .
define input  parameter p-pass-gds   as integer no-undo .
define input  parameter p-write-off-code as integer no-undo .
define input  parameter p-depart-id  as integer no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define output parameter p-b-code as integer no-undo .
define output parameter p-gds-code as integer no-undo .
define output parameter p-chk-name as character no-undo .
define output parameter p-second-name as character no-undo .
define input-output parameter p-src-price as decimal no-undo .
define output parameter p-src-price-rubl as decimal no-undo .
define output parameter p-src-discnt-sum as decimal no-undo .
define output parameter p-src-discnt-sum-rubl as decimal no-undo .
define output parameter p-src-sum as decimal no-undo .
define output parameter p-src-sum-rubl as decimal no-undo .
define output parameter p-src-sum-netto as decimal no-undo .
define output parameter p-src-sum-netto-rubl as decimal no-undo .
define output parameter p-unit-base as character no-undo .
define variable v-doc-qnty as decimal no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-line-direction as integer no-undo .
define variable v-result   as character         no-undo.
define variable v-type-bc  as character         no-undo.
define variable v-weight   as decimal           no-undo.
define variable v-empty-scale as logical no-undo .
define variable v-gds-name as character no-undo .
define variable v-gds-name1 as character no-undo .
define variable v-second-name as character no-undo .
define variable v-f-name as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-main-bar-code as integer no-undo .
define variable v-is-weight-pbc as logical no-undo .
define variable v-is-pgweight-pbc as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-unit-base as character no-undo .
define variable v-unit-base-type as character no-undo .
define variable v-unit-cli as character no-undo .
define variable v-unit-cli-type as character no-undo .
define variable v-prt-root as integer no-undo .
define variable v-root-node-code as integer no-undo .
define variable v-min-rate as decimal no-undo .
define variable v-max-rate as decimal no-undo .
define variable v-node-code as integer no-undo .
define variable v-in-code as character no-undo .
define variable v-part-code as character no-undo .
define variable v-chk-name as character no-undo .
define variable v-cash-parts as logical no-undo .
define variable v-gtd as character no-undo .
define variable v-valid as logical no-undo .
define variable v-mess as character no-undo .
define variable v-chr-err as character no-undo .
define variable v-plt-id          as integer   no-undo .
define variable v-plt-db-num      as integer   no-undo .
define variable v-pdf-id          as integer   no-undo .
define variable v-pdf-db-num      as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-sale-price-r-b as decimal   no-undo .
define variable v-depart-type as character no-undo .
define variable v-depart-code as integer no-undo .
define variable v-is-null-price as logical no-undo .
define variable v-road-tax-base as decimal   no-undo .
define variable v-road-tax-rubl as decimal   no-undo .
define variable v-excise-base   as decimal   no-undo .
define variable v-excise-rubl   as decimal   no-undo .
define variable v-free-price as logical no-undo .
define variable v-sum-grp-code as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-no-add-price as logical no-undo .
define variable v-discnt as decimal no-undo .
define variable v-m-discnt as decimal no-undo .
define variable v-src-price as decimal no-undo .
define variable v-src-discnt as decimal no-undo .
define variable v-start-src-price as decimal no-undo .
define variable v-start-src-discnt as decimal no-undo .
define variable v-new-src-price as decimal no-undo .
define variable v-new-src-discnt as decimal no-undo .
define variable v-dopchr as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-recalc as logical no-undo .
define variable v-scpg-format as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-accept-changes as logical no-undo .
define variable v-in-ov as logical no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
define buffer buf_goods for ub.goods.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_units for ub.units.
define buffer root_gds-prt for ub.gds-prt.
define buffer term_gds-prt for ub.gds-prt.
define buffer cli_units for ub.units.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf2_libthpos_chk-gds for libthpos_chk-gds.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-line-num <= 0 then do:
      v-err-mess = substitute("Неверный номер товарной строки = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not (p-mode = 'ДОБАВЛЕНИЕ':U
            or
            p-mode = 'ИЗМЕНЕНИЕ':U
            or
            p-mode = 'удаление':U
            or
            p-mode = 'ИЗМЕНЕНИЕ':U  + chr(44) + "recalc"
            or
            p-mode = 'ИЗМЕНЕНИЕ':U  + chr(44) + "recalc" + chr(44) + "no-changes"
            or
            p-mode = 'ПРОСМОТР':U
            ) then do:
      v-err-mess = substitute("Неверное действие над товарной строкой чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    assign
    v-accept-changes = yes.
    if (p-mode = 'ИЗМЕНЕНИЕ':U  + chr(44) + "recalc" + chr(44) + "no-changes") then do:
      v-accept-changes = no.
    end.
    if (p-mode = 'ИЗМЕНЕНИЕ':U  + chr(44) + "recalc")
    or (p-mode = 'ИЗМЕНЕНИЕ':U  + chr(44) + "recalc" + chr(44) + "no-changes")
    then do:
      assign
      v-is-recalc = yes
      p-mode = 'ИЗМЕНЕНИЕ':U
      .
    end.
    if p-mode = 'ПРОСМОТР':U then do:
      find first buf_libthpos_chk-gds where
                buf_libthpos_chk-gds.doc-code = p-doc-code
           and  buf_libthpos_chk-gds.line-num = p-line-num no-error.
      if not available buf_libthpos_chk-gds then do:
        v-err-mess = substitute("Не найдена строка &1 в чеке &2", p-line-num, p-doc-code).
        undo main-block, retry main-block.
      end.
      assign
      p-b-code = buf_libthpos_chk-gds.b-code
      p-gds-code = buf_libthpos_chk-gds.gds-code
      p-second-name = buf_libthpos_chk-gds.second-name
      p-src-price = buf_libthpos_chk-gds.src-price
      p-src-price-rubl = buf_libthpos_chk-gds.src-price-rubl
      p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
      p-src-discnt-sum-rubl = buf_libthpos_chk-gds.src-discnt-sum-rubl
      p-src-sum = buf_libthpos_chk-gds.src-sum
      p-src-sum-rubl = buf_libthpos_chk-gds.src-sum-rubl
      p-src-sum-netto = p-src-sum - p-src-discnt-sum
      p-src-sum-netto-rubl = p-src-sum-rubl - p-src-discnt-sum-rubl
      p-unit-base = buf_libthpos_chk-gds.unit-base
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  1)
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > 1 or p-mode = 'удаление':U then 1 else 0)
                                  ,(if libthpos_chk-context.step > 2 or p-mode = 'удаление':U then 1 else 0)
                                )
                  else "")
      .
      return ''.
    end.
    if p-mode = 'удаление':U
    and p-src-qnty <> 0 then do:
      v-err-mess = substitute("Для удаления товарной строки чека количество должно = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    and p-src-qnty = 0
    or p-src-qnty = ?
    then do:
      v-err-mess = substitute("Для изменения товарной строки чека количество должно быть задано").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction > 0
    and p-line-direction > 0
    and p-src-qnty  < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction > 0
    and p-line-direction < 0
    and p-src-qnty  > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction < 0
    and p-line-direction < 0
    and p-src-qnty  < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction < 0
    and p-line-direction > 0
    and p-src-qnty  > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if p-line-direction < 0 then do:
      v-err-mess = substitute("Еще не реализован режим задания отрицательного количества (код &1)", p-src-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = 'ДОБАВЛЕНИЕ':U
    or p-mode = 'ИЗМЕНЕНИЕ':U)
    and p-line-num = 1
    and libthpos_chk-context.direction > 0
    and p-src-qnty < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = 'ДОБАВЛЕНИЕ':U
    or p-mode = 'ИЗМЕНЕНИЕ':U)
    and p-line-num = 1
    and libthpos_chk-context.direction < 0
    and p-src-qnty > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0
    or lookup(string(libthpos_chk-context.chk-type), '12,13,40,112,113':U) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 товарной строки быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if lookup(string(p-write-off-code), '?,0,1,-6,-9,2,-2,3,-3,-4,17':U) = 0 then do:
      v-err-mess = substitute("Неверный код списания = &1 для строки &2", p-write-off-code, p-line-num).
      undo main-block, retry main-block.
    end.
    case p-mode:
      when 'ДОБАВЛЕНИЕ':U then do:
        if libthpos_chk-context.lng + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № товарной строки чека = &1&2должен быть &3"
                                      , p-line-num
                                      , chr(10)
                                      , libthpos_chk-context.lng + 1).
          undo main-block, retry main-block.
        end.
        if p-src-code = ?
        or p-src-code = "" then do:
          v-err-mess = substitute("Не задан код товара для новой строки чека &1", P-LINE-NUM).
          undo main-block, retry main-block.
        end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  libthpos_context.parparentproc
,input  p-src-code
,input  p-src-price
,input  'маг':U
,input  libthpos_context.obj-code
,input   ( if g#auto then no else yes )
,input  no
,input  libthpos_context.sclspref
,input  libthpos_context.scpgpref
,output v-result
,output v-type-bc
,output v-weight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
        if not available buf_bar-code then do:
           v-err-mess = substitute("Не найден товар по коду &1", p-src-code).
          undo main-block, retry main-block.
        end.
        if available buf_prod-bc
        and buf_prod-bc.bc-on = no then do:
          v-err-mess = substitute("Товар по коду &1 найден, но данный ДопБК Выключен", p-src-code).
          undo main-block, retry main-block.
        end.
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if not available buf_goods then do:
          v-err-mess = substitute("Отсутствует в IBS TH товар с кодом &1, основным бар-кодом &2, найденный по коду &3"
                                                , buf_bar-code.gds-code
                                                , buf_bar-code.b-code
                                                , p-src-code).
          undo main-block, retry main-block.
        end.
        find first root_gds-prt where
                root_gds-prt.upper-code = buf_goods.prt-root NO-LOCK .
        assign
        v-unit-base = buf_goods.unit-base
        v-min-rate = buf_goods.min-rate
        v-max-rate = buf_goods.max-rate
        v-gds-code = buf_goods.gds-code
        v-b-code = buf_bar-code.b-code
        v-in-code = buf_bar-code.in-code
        v-part-code = buf_bar-code.part-code
        v-node-code = buf_bar-code.node-code
        v-unit-cli = buf_bar-code.unit-cli
        v-root-node-code = root_gds-prt.node-code
        v-prt-root = buf_goods.prt-root
        .
        if buf_bar-code.in-code = ""
        and buf_bar-code.part-code = ""
        and buf_bar-code.unit-cli = buf_goods.unit-base
        and buf_bar-code.node-code = root_gds-prt.node-code then do:
          v-main-bar-code = buf_bar-code.b-code.
        end.
        else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  v-root-node-code
  ,output v-main-bar-code
  )  .
        end.
        assign
        v-empty-scale = NOT (libthpos_context.doc-prt AND ( root_gds-prt.node-name <> '_Пустая шкала':U))
        .
        FIND FIRST buf_units WHERE
                  buf_units.unit-name = buf_goods.unit-base NO-LOCK .
        if buf_bar-code.unit-cli <> buf_goods.unit-base then do:
          find first cli_units no-lock where
                    cli_units.unit-name = buf_bar-code.unit-cli.
          assign
          v-unit-cli-type = cli_units.type
          v-unit-base-type = buf_units.type
          .
        end.
        else do:
          assign
          v-unit-cli-type = buf_units.type
          v-unit-base-type = buf_units.type
          .
        end.
        find first term_gds-prt no-lock where
                  term_gds-prt.node-code = buf_bar-code.node-code
              and term_gds-prt.prt-root = root_gds-prt.prt-root.
        if lookup('вес':U, v-unit-cli-type) > 0
        then do:
          if lookup(substring(p-src-code, 1, 2), libthpos_context.sclspref) > 0
          and length(p-src-code) = 13
          then do:
            assign
            v-dopchr = substring(p-src-code, 1, 12).
            run str/chk-sum.p ( input-output v-dopchr) no-error.
            if error-status:error then do:
              v-err-mess = substitute("Не удалось рассчитать КЦ в предположительно весовом коде &1: не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
                          undo main-block, retry main-block.
            end.
            if v-dopchr <> p-src-code then do:
              v-err-mess = substitute("Неверная КЦ &2 в предположительно весовом коде &1 (дожна быть &3): не удалось найти количество весового товара по коду &1"
                                                    , p-src-code
                                                    ,substring(p-src-code, 13, 1)
                                                    ,substring(v-dopchr, 13, 1)
                                                    ).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty  = decimal(substring(p-src-code, 8, 5)) / 1000
            v-is-weight-pbc = yes
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty = libthpos_chk-context.direction * p-src-qnty * p-line-direction
            .
          end.
        end.
        if lookup('шту':U, v-unit-base-type) > 0
        then do:
          if lookup(substring(p-src-code, 1, 2), libthpos_context.scpgpref-pre) > 0
          and length(p-src-code) = 13
          then do:
            assign
            v-scpg-format = entry(lookup(substr(p-src-code, 1, 2), libthpos_context.scpgpref-pre), libthpos_context.scpgpref)
            v-dopchr = substring(p-src-code, 1, 12).
            run str/chk-sum.p ( input-output v-dopchr) no-error.
            if error-status:error then do:
              v-err-mess = substitute("Не удалось рассчитать КЦ в предположительно штучном коде для весов &1: не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            if v-dopchr <> p-src-code then do:
              v-err-mess = substitute("Неверная КЦ &2 в предположительно штучном коде для весов &1 (дожна быть &3): не удалось найти количество весового товара по коду &1"
                                                    , p-src-code
                                                    ,substring(p-src-code, 13, 1)
                                                    ,substring(v-dopchr, 13, 1)
                                                    ).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty  = decimal(substring(p-src-code, 8, 5)) / exp(10, num-entries(substring(v-scpg-format, 8,5), "0") - 1)
            v-is-pgweight-pbc = yes
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty = libthpos_chk-context.direction * p-src-qnty * p-line-direction
            .
          end.
        end.
        assign
        v-cli-base-rate = buf_bar-code.cli-base-rate
        v-doc-qnty = p-src-qnty * v-cli-base-rate.
        assign
        v-gds-name  = IF libthpos_context.nam-2str
                      then buf_goods.gds-name
                      else (
                            IF libthpos_context.nam-artc
                            then buf_goods.artic
                            else (if buf_goods.chk-name <> ""
                                  then buf_goods.chk-name
                                  else buf_goods.gds-name)
                          )
      v-f-name = (if NOT v-empty-scale
                  then term_gds-prt.f-name
                  else "")
      v-gds-name1 =   name-2cdf(
                        input libthpos_context.name-2cd
                      , input yes
                      , input libthpos_context.cod-pcod
                      , input buf_bar-code.b-code
                      , input buf_goods.gds-code
                      , input buf_goods.artic
                      , input buf_goods.engl-name
                      , input buf_bar-code.in-code
                      , input buf_bar-code.part-code
                      , input libthpos_context.obj-type
                      , input libthpos_context.obj-code
                      , input buf_goods.alpha1
                      , output v-gtd
                      ).
        assign
        p-chk-name = chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th ( input libthpos_context.pos-type
                                          ,input libthpos_context.nam-2str
                                          ,input libthpos_context.nam-artc
                                          ,input v-unit-cli-type
                                          ,input buf_goods.unit-base
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.cli-base-rate
                                          ,input buf_goods.artic
                                          ,input v-f-name
                                          ,input v-gds-name
                                          ,input v-gds-name1
                                          ,output v-second-name ).
        if lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,36':U ) > 0
        and LOOKUP('топ':U, buf_units.type) = 0 then do:
          v-err-mess = substitute("Недопустима строка с обычным товаром в чеке типа &1", libthpos_chk-context.chk-typ).
          undo main-block, retry main-block.
        end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  'маг':U
  ,input  libthpos_context.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'cash-parts=request'
  ,output v-cash-parts
  )  .
        if lookup(string(libthpos_chk-context.chk-type), '6,96':U) = 0
        and p-src-price <> ?
        then do:
          run gdsoattr-value in this-procedure (
                                                  input   'free-price':U
                                                ,input   v-gds-code
                                                ,input   libthpos_context.obj-type
                                                ,input   libthpos_context.obj-code
                                                ,output  v-attr-value
                                                ,output  v-attr-type
                                                ) no-error.
          if not error-status:error
          and v-attr-value <> "" then do:
            v-free-price = logical(v-attr-value).
          end.
          if v-free-price = no
          then do:
            v-err-mess = substitute("Для товара с кодом &1 свободный ввод цены не разрешен", p-src-code).
            undo main-block, retry main-block.
          end.
        end.
        if libthpos_context.is-grp-totals =  yes then do:
          run gdsoattr-value in this-procedure (
                                                  input   'sum-grp':U
                                                  ,input   v-gds-code
                                                  ,input   libthpos_context.obj-type
                                                  ,input   libthpos_context.obj-code
                                                  ,output  v-attr-value
                                                  ,output  v-attr-type
                                                  ) no-error.
          if not error-status:error
          and v-attr-value <> "" then do:
            v-sum-grp-code = integer(v-attr-value).
          end.
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U
      or
      when 'удаление':U
      then do:
        for first buf_chk-gds share-lock where
                buf_chk-gds.doc-code = p-doc-code
            and buf_chk-gds.line-num = p-line-num,
            first buf_libthpos_chk-gds where
                buf_libthpos_chk-gds.doc-code = p-doc-code
            and buf_libthpos_chk-gds.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-gds then do:
          v-err-mess = substitute("Неверный № товарной строки чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-src-code <> buf_chk-gds.src-code
        then do:
          v-err-mess = substitute("Для уже имеющейся строки чека (&1) нельзя изменить код продажи - был &2"
                                      , p-line-num
                                      , buf_chk-gds.src-code
                                      ).
          undo main-block, retry main-block.
        end.
        if p-line-direction <> buf_libthpos_chk-gds.line-direction then do:
          v-err-mess = substitute("Для уже имеющейся строки чека (&1) нельзя изменить знак количества - был &2"
                                      , p-line-num
                                      , buf_libthpos_chk-gds.line-direction
                                      ).
          undo main-block, retry main-block.
        end.
        assign
        v-b-code = buf_libthpos_chk-gds.b-code
        v-main-bar-code = buf_libthpos_chk-gds.main-bar-code
        v-gds-code = buf_libthpos_chk-gds.gds-code
        v-unit-base-type = buf_libthpos_chk-gds.unit-base-type
        v-unit-base = buf_libthpos_chk-gds.unit-base
        v-unit-cli = buf_libthpos_chk-gds.unit-cli
        v-unit-cli-type = buf_libthpos_chk-gds.unit-cli-type
        v-min-rate = buf_libthpos_chk-gds.min-rate
        v-max-rate = buf_libthpos_chk-gds.max-rate
        v-in-code = buf_libthpos_chk-gds.in-code
        v-cash-parts = buf_libthpos_chk-gds.cash-parts
        v-node-code = buf_libthpos_chk-gds.node-code
        v-root-node-code = buf_libthpos_chk-gds.root-node-code
        v-prt-root  = buf_libthpos_chk-gds.prt-root
        v-empty-scale = buf_libthpos_chk-gds.empty-scale
        v-chk-name = buf_libthpos_chk-gds.chk-name
        v-second-name = buf_libthpos_chk-gds.second-name
        v-is-weight-pbc = buf_libthpos_chk-gds.is-weight-pbc
        v-is-pgweight-pbc = buf_libthpos_chk-gds.is-pgweight-pbc
        v-doc-qnty = buf_libthpos_CHK-GDS.will-doc-qnty
        v-cli-base-rate = buf_libthpos_chk-gds.cli-base-rate
        v-free-price = buf_libthpos_chk-gds.free-price
        v-sum-grp-code = buf_libthpos_chk-gds.sum-grp-code
        v-line-direction = buf_libthpos_chk-gds.line-direction
        .
        if v-is-weight-pbc
        and p-mode = 'ИЗМЕНЕНИЕ':U
        and p-src-qnty <> buf_chk-gds.src-qnty
        then do:
          v-err-mess = substitute("Нельзя поменять количество по коду &1, код = весовой, количество ЗАШИТО в коде").
          undo main-block, retry main-block.
        end.
        if v-is-pgweight-pbc
        and p-mode = 'ИЗМЕНЕНИЕ':U
        and p-src-qnty <> buf_chk-gds.src-qnty
        then do:
          v-err-mess = substitute("Нельзя поменять количество по коду &1, код = штучный для весов, количество ЗАШИТО в коде").
          undo main-block, retry main-block.
        end.
      end.
    end case.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_petrol-valid in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  libthpos_context.pos-type
  ,input  p-src-code
  ,input  v-gds-code
  ,input  v-unit-base-type
  ,input  p-pump
  ,input  p-nozzle-code
  ,output v-valid
  ,output v-mess
  ,output v-chr-err
  ) no-error .
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке топливного товара")
                                  else v-mess)
                              , chr(10)).
      undo main-block, retry main-block.
    end.
    if LOOKUP( 'сер':U, v-unit-base-type ) > 0
    OR lookup('2ед':U, v-unit-base-type) > 0
    OR lookup('доп':U, v-unit-base-type) > 0 then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_unit-type-qnty in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  v-unit-base-type
  ,input  v-unit-cli-type
  ,input  p-src-code
  ,input  v-in-code
  ,input  p-src-qnty
  ,input  v-min-rate
  ,input  v-max-rate
  ,output v-valid
  ,output v-mess
  ,output v-chr-err
  ) no-error .
      if error-status:error or
      not v-valid then do:
        v-err-mess = substitute("&1&2&3"
                                , (if error-status:error
                                    then substitute("Ошибка при проверке товара согласно типу ед.изм")
                                    else v-mess)
                                , chr(10)).
        undo main-block, retry main-block.
      end.
    end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_part-valid in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  v-unit-base-type
  ,input  v-unit-cli-type
  ,input  p-src-code
  ,input  v-in-code
  ,input  v-part-code
  ,input  v-cash-parts
  ,input  p-src-qnty
  ,output v-valid
  ,output v-mess
  ,output v-chr-err
  ) no-error .
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                                , (if error-status:error
                                    then substitute("Ошибка при проверке возможности продажи товара по партиям")
                                    else v-mess)
                                , chr(10)).
      undo main-block, retry main-block.
    end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_prt-valid in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  libthpos_context.doc-prt
  ,input  p-src-code
  ,input  v-empty-scale
  ,input  v-root-node-code
  ,input  v-node-code
  ,output v-valid
  ,output v-mess
  ,output v-chr-err
  ) no-error .
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                            , (if error-status:error
                                then substitute("Ошибка при проверке возможности продажи товара по признакам")
                                else v-mess)
                            , chr(10)).
      undo main-block, retry main-block.
    end.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_chk-gds-wro in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  p-src-qnty
  ,input  p-write-off-code
  ,output v-valid
  ,output v-mess
  ) no-error .
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке валидности кода списания строки &1", p-line-num)
                                  else v-mess)
                              , chr(10)).
      undo main-block, retry main-block.
    end.
    if p-mode <> 'удаление':U
    and not
      ((libthpos_chk-context.chk-type = integer('6':U)
    or libthpos_chk-context.chk-type = integer('96':U)
    or libthpos_chk-context.chk-type = integer('206':U)
      )
      and not (p-src-price = ? or p-src-price = 0)
      )
      then do:
    define variable v-doc-num as character no-undo .
    if libthpos_context.r-b = 'base':U then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  v-b-code
  ,input  v-main-bar-code
  ,input  0
  ,output v-doc-num
  ,output v-sale-price-base
  ,output v-road-tax-base
  ,output v-excise-base
  ) no-error .
    end.
    else do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  v-b-code
  ,input  v-main-bar-code
  ,input  0
  ,output v-doc-num
  ,output v-sale-price-rubl
  ,output v-road-tax-rubl
  ,output v-excise-rubl
  ) no-error .
    end.
      if error-status:error then do:
        v-err-mess = substitute("Не удалось получить цену для кода &1&2&3&2&4"
                                                , p-src-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
        undo main-block, retry main-block.
      end.
      if (v-sale-price-base = ?
      or v-sale-price-rubl = ?)
      then do:
        v-err-mess = substitute("Не определена цена для кода &1&2&3&2&4"
                                                , p-src-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
        undo main-block, retry main-block.
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U then
      do:
        if lookup(string(libthpos_chk-context.chk-type), '1,69,14,15,16,36':U) > 0
        or lookup(string(libthpos_chk-context.chk-type), '101':U + chr(44) +
                                    '169':U) > 0
        or lookup(string(libthpos_chk-context.chk-type), '201':U) > 0
        then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  'маг':U
  ,input  libthpos_context.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'in-ov=request'
  ,output v-in-ov
  ) no-error .
         if error-status:error then do:
          v-err-mess = substitute("Ошибка при определении свойства <Требует переоценки> для кода &1&2&3&2&4"
                                                  , p-src-code
                                                  , chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
          undo main-block, retry main-block.
         end.
         if v-in-ov then do:
          v-err-mess = substitute("Товар по коду &1 требует переоценки - продажа запрещена"
                                                  , p-src-code
                                                  ).
          undo main-block, retry main-block.
         end.
        end.
      end.
    end.
    else do:
      if p-mode = 'удаление':U then do:
        assign
        p-src-price = buf_libthpos_chk-gds.src-price
        p-src-price = buf_libthpos_chk-gds.src-price-rubl
        .
      end.
      else do:
        assign
        v-sale-price-r-b = p-src-price
        v-sale-price-rubl = (if libthpos_context.r-b = 'rubl':U
                            then p-src-price
                            else p-src-price * libthpos_chk-context.base-rate)
        v-sale-price-base = (if libthpos_context.r-b = 'base':U
                            then p-src-price
                            else p-src-price / libthpos_chk-context.base-rate)
        .
      end.
    end.
    assign
    v-sale-price-r-b = (if libthpos_context.r-b = 'rubl':U
                        then v-sale-price-rubl
                        else v-sale-price-base
                        )
    v-depart-type = 'маг':U
    v-depart-code = p-depart-id
    .
    if p-mode <> 'ДОБАВЛЕНИЕ':U
    and libthpos_chk-context.direction > 0
    then do:
      if p-mode = 'ИЗМЕНЕНИЕ':U
      and buf_libthpos_chk-gds.manual-discnt-sum >= buf_libthpos_chk-gds.src-price * p-src-qnty
      and buf_libthpos_chk-gds.manual-discnt-sum > 0
      then do:
        v-err-mess = substitute("Нельзя изменить строку &1 чека &2 - ручная скидка по строке (&3) превысит сумму строки (&4)"
                                              , p-line-num
                                              , p-doc-code
                                              , buf_libthpos_chk-gds.manual-discnt-sum
                                              , buf_libthpos_chk-gds.src-price * p-src-qnty
                                              ).
        undo main-block, retry main-block.
      end.
      if (libthpos_chk-context.manual-discnt-sum  - (if p-mode = 'удаление':U then buf_libthpos_chk-gds.manual-discnt-sum else 0)) > 0
      and (libthpos_chk-context.manual-discnt-sum - (if p-mode = 'удаление':U then buf_libthpos_chk-gds.manual-discnt-sum else 0))
       >= (libthpos_chk-context.src-tot-doc - buf_libthpos_chk-gds.src-sum +
          buf_libthpos_chk-gds.src-price * p-src-qnty) + (if p-mode = 'удаление':U then buf_libthpos_chk-gds.manual-discnt-sum else 0)
      then do:
        v-err-mess = substitute("Нельзя удалить/изменить строку &1 чека &2 - общая ручная скидка по чеку (&3) превысит сумму чека (&4)"
                                              ,p-line-num
                                              ,p-doc-code
                                              ,libthpos_chk-context.manual-discnt-sum
                                              ,libthpos_chk-context.src-tot-doc - buf_libthpos_chk-gds.src-sum + buf_libthpos_chk-gds.src-price * p-src-qnty
                                              ).
        undo main-block, retry main-block.
      end.
    end.
    if p-mode <> 'удаление':U then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_fbr-valid in g#libchkvl
  (input  libthpos_chk-context.chk-type
  ,input  p-line-num
  ,input  libthpos_context.obj-type
  ,input  libthpos_context.obj-code
  ,input  libthpos_context.is-catering
  ,input  libthpos_context.pos-type
  ,input  p-src-code
  ,input  v-gds-code
  ,input  v-sale-price-r-b
  ,input  v-src-discnt
  ,input  p-write-off-code
  ,input-output  v-depart-type
  ,input-output  v-depart-code
  ,output v-is-null-price
  ,output v-valid
  ,output v-mess
  ,output v-chr-err
  ) no-error .
      if error-status:error or
      not v-valid then do:
        v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке возможности продажи товара")
                                  else v-mess)
                              , chr(10)).
        undo main-block, retry main-block.
      end.
    end.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      _chk-discnt-gds:
      for each buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
          and buf_chk-discnt.line-num = p-line-num
          and buf_chk-discnt.record-type = 0
          and buf_chk-discnt.object-line-num = p-line-num
          and buf_chk-discnt.line-type = integer('1':U),
          first buf_libthpos_chk-discnt where
                buf_libthpos_chk-discnt.doc-code = p-doc-code
          and buf_libthpos_chk-discnt.line-num = p-line-num
          and buf_libthpos_chk-discnt.record-type = 0
          and buf_libthpos_chk-discnt.object-line-num = p-line-num
          and buf_libthpos_chk-discnt.discnt-id = buf_chk-discnt.discnt-id
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        if buf_libthpos_chk-discnt.discnt-type = integer('13':U) then next _chk-discnt-gds.
        delete buf_chk-discnt.
        delete buf_libthpos_chk-discnt.
      end.
      buf_libthpos_chk-gds.without-gds-discnt = 0.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create buf_chk-gds.
      create buf_libthpos_chk-gds.
      assign
      buf_chk-gds.doc-code = p-doc-code
      libthpos_chk-context.lng = libthpos_chk-context.lng + 1
      libthpos_chk-context.recalc-gline-num = libthpos_chk-context.lng + 1
      buf_chk-gds.line-num = libthpos_chk-context.lng
      buf_libthpos_chk-gds.recalc-line-num = buf_chk-gds.line-num
      buf_chk-gds.grp-code = 0
      buf_chk-gds.chk-date = libthpos_chk-doc.chk-date
      buf_chk-gds.b-code = v-b-code
      buf_chk-gds.src-code = p-src-code
      buf_chk-gds.sales-man  = libthpos_chk-context.sales-man
      buf_chk-gds.salesman-psn-code = libthpos_chk-context.salesman-psn-code
      buf_chk-gds.src-sum   = 0
      buf_libthpos_chk-gds.src-sum-rubl   = 0
      buf_chk-gds.src-qnty = 0
      buf_chk-gds.src-discnt = 0
      buf_chk-gds.src-price = 0
      buf_libthpos_chk-gds.src-price-rubl = 0
      buf_chk-gds.doc-qnty = 0
      buf_chk-gds.price-service = 0
      buf_chk-gds.pass-gds = 0
      buf_chk-gds.is-error = no
      buf_chk-gds.pump   = 0
      buf_chk-gds.nozzle = 0
      buf_chk-gds.loc1 = ''
      buf_chk-gds.src-pl-code = 0
      buf_chk-gds.line-type  = ''
      buf_chk-gds.src-d-card = libthpos_chk-context.src-d-card
      buf_chk-gds.src-d-mask = libthpos_chk-context.src-d-mask
      buf_chk-gds.src-cli-type = libthpos_chk-context.src-cli-type
      buf_chk-gds.src-cli-code = libthpos_chk-context.src-cli-code
      buf_chk-gds.depart-id = 0
      .
    end.
    assign
    libthpos_chk-context.src-qnty = libthpos_chk-context.src-qnty - buf_chk-gds.src-qnty
    libthpos_chk-context.src-tot-doc = libthpos_chk-context.src-tot-doc - buf_chk-gds.src-sum
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r - buf_libthpos_chk-gds.r-sum
    .
    assign
    buf_chk-gds.src-price = truncate(v-sale-price-r-b, 2)
    buf_libthpos_chk-gds.src-price-rubl = truncate(v-sale-price-rubl, 2)
    buf_chk-gds.src-qnty = p-src-qnty
    buf_chk-gds.pass-gds = p-pass-gds
    buf_chk-gds.pump = p-pump
    buf_chk-gds.nozzle-code = p-nozzle-code
    buf_chk-gds.src-pl-code = p-pl-code
    buf_chk-gds.write-off-code = p-write-off-code
    buf_chk-gds.depart-id = p-depart-id
    buf_chk-gds.doc-qnty = 0
    buf_chk-gds.price-service = 0
    buf_chk-gds.time-oper = v-time
    buf_chk-gds.road-tax = (if libthpos_context.r-b = 'rubl':U
                            then v-road-tax-rubl
                            else v-road-tax-base)
    buf_chk-gds.line-sign = (if libthpos_chk-context.chk-type = integer('1':U)
                              then (buf_chk-gds.src-qnty >= 0)
                              else (buf_chk-gds.src-qnty <= 0)
                        )
    buf_chk-gds.src-sum   = truncate(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2)
    buf_libthpos_chk-gds.src-sum-rubl = truncate(buf_libthpos_chk-gds.src-price-rubl * buf_chk-gds.src-qnty, 2)
    buf_chk-gds.src-discnt = 0
    buf_libthpos_chk-gds.src-discnt = 0
    buf_libthpos_chk-gds.src-discnt-rubl = 0
    buf_libthpos_chk-gds.src-discnt-sum = 0
    buf_libthpos_chk-gds.src-discnt-sum-rubl = 0
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
    buf_libthpos_chk-gds.will-doc-qnty = p-src-qnty * v-cli-base-rate
    .
    if libthpos_chk-context.chk-type = integer('17':U) then do:
      assign
      buf_chk-gds.write-off-code =  integer('17':U)
      .
    end.
    else  do:
      assign
      buf_chk-gds.write-off-code = (if v-no-add-price
                                    then (if lookup(string(libthpos_chk-context.chk-type), '1,69,14,15,16,36':U) > 0
                                        then integer('1':U)
                                        else integer('-6':U)
                                      )
                                      else 0
                                    )
      .
    end.
    buffer-copy buf_chk-gds to buf_libthpos_chk-gds.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      assign
      buf_libthpos_chk-gds.start-src-price = truncate(v-sale-price-r-b, 2)
      buf_libthpos_chk-gds.src-price-netto = buf_chk-gds.src-price
      buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
      buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * v-cli-base-rate
      buf_libthpos_chk-gds.main-bar-code = v-main-bar-code
      buf_libthpos_chk-gds.gds-code = v-gds-code
      buf_libthpos_Chk-gds.unit-base  = v-unit-base
      buf_libthpos_chk-gds.unit-cli   = v-unit-cli
      buf_libthpos_chk-gds.unit-base-type        = v-unit-base-type
      buf_libthpos_chk-gds.unit-cli-type    = v-unit-cli-type
      buf_libthpos_chk-gds.min-rate = v-min-rate
      buf_libthpos_chk-gds.max-rate = v-max-rate
      buf_libthpos_chk-gds.in-code  = v-in-code
      buf_libthpos_chk-gds.part-code  = v-part-code
      buf_libthpos_chk-gds.cash-parts  = v-cash-parts
      buf_libthpos_chk-gds.node-code = v-node-code
      buf_libthpos_chk-gds.root-node-code = root_gds-prt.node-code
      buf_libthpos_chk-gds.prt-root = buf_goods.prt-root
      buf_libthpos_chk-gds.empty-scale = v-empty-scale
      buf_libthpos_chk-gds.chk-name = v-chk-name
      buf_libthpos_chk-gds.second-name =   v-second-name
      buf_libthpos_chk-gds.is-weight-pbc = v-is-weight-pbc
      buf_libthpos_chk-gds.is-pgweight-pbc = v-is-pgweight-pbc
      buf_libthpos_chk-gds.will-doc-qnty = v-doc-qnty
      buf_libthpos_chk-gds.cli-base-rate = v-cli-base-rate
      buf_libthpos_chk-gds.sum-grp-code = v-sum-grp-code
      buf_libthpos_chk-gds.free-price = v-free-price
      buf_libthpos_chk-gds.line-direction = v-line-direction
      .
    end.
    assign
    libthpos_chk-context.src-qnty = libthpos_chk-context.src-qnty + buf_libthpos_chk-gds.src-qnty
    libthpos_chk-context.src-tot-doc = libthpos_chk-context.src-tot-doc + buf_chk-gds.src-sum
    libthpos_chk-context.src-tot-rubl =  (if libthpos_context.r-b = 'rubl':U
                                              or (libthpos_context.r-b = 'base':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.src-tot-doc
                                            else libthpos_chk-context.src-tot-doc * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
    libthpos_chk-context.src-tot-base =  (if libthpos_context.r-b = 'base':U
                                              or (libthpos_context.r-b = 'rubl':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.src-tot-doc
                                            else libthpos_chk-context.src-tot-doc / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
    .
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) = 0
    and libthpos_chk-context.direction > 0
    then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-start-src-price = v-sale-price-r-b
      v-src-price = v-sale-price-r-b
      v-start-src-discnt = 0
      v-src-discnt = 0
      .
      assign
      v-bh[1] = (buffer libthpos_context:handle)
      v-bh[4] = (buffer buf_libthpos_chk-gds:handle)
      v-bh[5] = (buffer libthpos_chk-pay:handle)
      v-bh[6] = (buffer libthpos_chk-discnt:handle)
      .
      for each buf_libthpos_rp-by-call
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        run rs_15_1 in buf_libthpos_rp-by-call.rph (
                  input '':U
                ,input p-line-num
                ,input v-b-code
                ,input v-gds-code
                ,input v-sum-grp-code
                ,input v-node-code
                ,input p-src-qnty
                ,input v-doc-qnty
                ,input v-start-src-price
                ,input v-src-price
                ,input v-start-src-discnt
                ,input v-src-discnt
                ,input v-unit-base
                ,input v-unit-base-type
                ,input v-unit-cli
                ,input v-unit-cli-type
                ,input v-bh
                ,output v-new-src-price
                ,output v-new-src-discnt
                    ) no-error.
        if not error-status :error then do:
          assign
          v-src-price = v-new-src-price
          v-src-discnt = v-new-src-discnt
          .
        end.
        else do:
          message
          error-status:get-message(1)
          return-value view-as alert-box .
        end.
      end.
      assign
      v-discnt = v-new-src-discnt
      .
    end.
    if buf_libthpos_chk-gds.manual-discnt-id > 0
    then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = p-line-num
        and  buf_libthpos_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = p-line-num
        and  buf_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id:
        leave.
      end.
      if p-mode = 'удаление':U then do:
        v-m-discnt = 0.
        libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum.
      end.
      else do:
        case buf_libthpos_chk-discnt.value-type:
          when integer('1':U) then do:
            assign
            buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price - v-discnt
            v-m-discnt = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-discnt.discnt-value-pcnt / 100
            buf_libthpos_chk-discnt.object-sum = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-qnty = buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.discnt-value-abs = buf_libthpos_chk-gds.src-qnty * v-m-discnt
            libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum
            buf_libthpos_chk-gds.manual-discnt-sum = buf_libthpos_chk-discnt.discnt-value-abs
            libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-gds.manual-discnt-sum
            .
          end.
          when integer('10':U) then do:
            assign
            buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price - v-discnt
            v-m-discnt = buf_libthpos_chk-discnt.discnt-value-abs / buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-sum = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-qnty = buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.discnt-value-pcnt = v-m-discnt / buf_libthpos_chk-discnt.src-price-netto * 100
            .
          end.
        end case.
        buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
      end.
      v-discnt = v-discnt + v-m-discnt.
      if p-mode = 'удаление':U then do:
        delete buf_libthpos_chk-discnt.
        delete buf_chk-discnt.
      end.
    end.
    assign
    buf_chk-gds.src-discnt = truncate(v-discnt, 2)
    buf_libthpos_chk-gds.src-discnt = truncate(v-discnt, 2)
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price - buf_libthpos_chk-gds.src-discnt
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
    buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * v-cli-base-rate
    buf_libthpos_chk-gds.src-discnt-rubl = (if libthpos_context.r-b = 'rubl':U
                                            then buf_libthpos_chk-gds.src-discnt
                                            else truncate(v-discnt * libthpos_chk-context.base-rate, 2 ))
    .
    assign
    buf_libthpos_chk-gds.src-discnt-sum = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt, 2)
    buf_libthpos_chk-gds.src-discnt-sum-rubl = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt-rubl, 2)
    buf_libthpos_chk-gds.r-sum = (buf_libthpos_chk-gds.src-qnty * (v-sale-price-r-b - v-discnt)) -
                                (buf_libthpos_chk-gds.src-sum -  buf_libthpos_chk-gds.src-discnt-sum)
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r + buf_libthpos_chk-gds.r-sum
    libthpos_chk-context.step =  if libthpos_chk-context.step = 0
                                then 1
                                else libthpos_chk-context.step
    .
    if buf_chk-gds.src-sum <= buf_libthpos_chk-gds.src-discnt-sum
    and libthpos_chk-context.direction > 0
    and buf_libthpos_chk-gds.src-discnt-sum > 0
    and p-mode <> 'удаление':U
    then do:
      v-err-mess = substitute("Нельзя удалить/изменить строку &1 чека &2 - общая скидка по строке (&3) превысит сумму строки брутто (&4)"
                                              ,p-line-num
                                              ,p-doc-code
                                              ,buf_libthpos_chk-gds.src-discnt-sum
                                              ,buf_chk-gds.src-sum
                                              ).
      undo main-block, retry main-block.
    end.
    if p-mode = 'удаление':U
    and buf_chk-gds.src-qnty = 0 then do:
      define variable v-recalc-line-num as integer no-undo .
      v-recalc-line-num = buf_libthpos_chk-gds.recalc-line-num.
      delete buf_chk-gds.
      delete buf_libthpos_chk-gds.
      find last buf2_libthpos_chk-gds where
              buf2_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code use-index ln no-error.
      assign
      libthpos_chk-context.lng = (if available buf2_libthpos_chk-gds
                                then buf2_libthpos_chk-gds.line-num
                                else 0)
      libthpos_chk-context.recalc-gline-num = (if v-recalc-line-num = p-line-num
                                                then libthpos_chk-context.lng + 1
                                                else v-recalc-line-num)
      .
      if libthpos_chk-context.lng = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = 1
                                    then 0
                                    else libthpos_chk-context.step.
      end.
      assign
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  1)
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > 1 or p-mode = 'удаление':U then 1 else 0)
                                  ,(if libthpos_chk-context.step > 2 or p-mode = 'удаление':U then 1 else 0)
                                )
                  else "")
      .
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    else do:
      assign
      p-b-code = v-b-code
      p-gds-code = v-gds-code
      p-second-name = v-second-name
      p-src-price = buf_chk-gds.src-price
      p-src-price-rubl = buf_libthpos_chk-gds.src-price-rubl
      p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
      p-src-discnt-sum-rubl = buf_libthpos_chk-gds.src-discnt-sum-rubl
      p-src-sum = buf_chk-gds.src-sum
      p-src-sum-rubl = buf_libthpos_chk-gds.src-sum-rubl
      p-src-sum-netto = p-src-sum - p-src-discnt-sum
      p-src-sum-netto-rubl = p-src-sum-rubl - p-src-discnt-sum-rubl
      p-unit-base = buf_libthpos_chk-gds.unit-base
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  1)
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > 1 or p-mode = 'удаление':U then 1 else 0)
                                  ,(if libthpos_chk-context.step > 2 or p-mode = 'удаление':U then 1 else 0)
                                )
                  else "")
      .
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
      run printbuffer in this-procedure ( input (buffer buf_chk-gds:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-gds:handle)).
    end.
    if v-accept-changes then do:
      dataset libthpos_receipt:accept-changes.
    end.
  end.
end.
end procedure.
procedure libthpos_sub-total :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-mode as character no-undo .
define output parameter p-setted as logical   no-undo .
define input-output parameter p-st-r-b as decimal no-undo .
define input-output parameter p-st-rubl as decimal no-undo .
define input-output parameter p-st-base as decimal no-undo .
define input-output parameter p-tot-doc as decimal no-undo .
define input-output parameter p-st-discnt as decimal no-undo .
define output parameter p-netto as decimal no-undo .
define output parameter p-netto-rubl as decimal no-undo .
define output parameter p-netto-base as decimal no-undo .
define output parameter p-all-discnt as decimal no-undo .
define output parameter p-all-discnt-rubl as decimal no-undo .
define output parameter p-all-discnt-base as decimal no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-tot-r-b as decimal no-undo .
define variable v-tot-discnt as decimal no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_chk-discnt for ub.chk-discnt.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not (p-mode = ''
            or
            p-mode = "no-changes") then do:
      v-err-mess = substitute("Неверное действие над подитогом чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    if libthpos_context.r-b = 'base':U
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = libthpos_context.obj-type
                AND buf_curr-shop.obj-code = libthpos_context.obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , libthpos_context.obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
      if v-today <> libthpos_chk-context.chk-date then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
      end.
      else do:
        assign
        v-bank-rate = libthpos_chk-context.bank-rate
        v-bank-scale = libthpos_chk-context.bank-scale
        .
      end.
    end.
    if libthpos_context.r-b = 'rubl':U
    and libthpos_context.base-code <> 0
    then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = libthpos_context.obj-type
            AND buf_curr-shop.obj-code = libthpos_context.obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , 'маг':U
                                      , libthpos_context.obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.chk-date <> v-today then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  libthpos_context.base-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  )  .
      end.
      else do:
        assign
        v-bank-rate = libthpos_chk-context.bank-rate
        v-bank-scale = libthpos_chk-context.bank-scale
        .
      end.
    end.
    assign
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    .
    assign
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + libthpos_chk-context.tot-discnt
    libthpos_chk-context.netto = libthpos_chk-context.netto + libthpos_chk-context.tot-discnt
    .
    define variable v-start-sum-brutto-r-b as decimal no-undo .
    define variable v-sum-brutto-r-b as decimal no-undo .
    define variable v-st-discnt-r-b as decimal no-undo .
    define variable v-st-r-b as decimal no-undo .
    define variable v-new-st-discnt-r-b as decimal no-undo .
    define variable v-sum-for-discnt-r-b as decimal no-undo .
    define variable v-new-sum-for-discnt-r-b as decimal no-undo .
    assign
    v-start-sum-brutto-r-b = libthpos_chk-context.sub-netto
    v-sum-brutto-r-b = libthpos_chk-context.sub-netto
    libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.sub-netto
    v-sum-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b
    v-st-discnt-r-b = 0.0
    v-new-st-discnt-r-b = 0.0
    v-new-sum-for-discnt-r-b = 0.0
    .
    assign
    v-bh[2] = buffer libthpos_chk-context:handle
    v-bh[4] = buffer libthpos_chk-gds:handle
    v-bh[1] = buffer libthpos_context:handle
    v-bh[5] = buffer libthpos_chk-pay:handle
    .
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) = 0
    and libthpos_chk-context.direction > 0
    then do:
      _chk-discnt:
      for each buf_libthpos_chk-discnt share-lock where
              buf_libthpos_chk-discnt.line-type = integer('2':U)
              or
              buf_libthpos_chk-discnt.line-type = integer('7':U)
              ,
          first buf_chk-discnt where
                buf_chk-discnt.doc-code = p-doc-code
          and buf_chk-discnt.line-num = buf_libthpos_chk-discnt.line-num
          and buf_chk-discnt.record-type = buf_libthpos_chk-discnt.record-type
          and buf_chk-discnt.discnt-id = buf_libthpos_chk-discnt.discnt-id
          and buf_chk-discnt.object-line-num = buf_libthpos_chk-discnt.object-line-num
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        if buf_libthpos_chk-discnt.discnt-type = integer('13':U) then do:
          next _chk-discnt.
        end.
        delete buf_chk-discnt.
        delete buf_libthpos_chk-discnt.
      end.
      run cur-time in this-procedure ( output libthpos_chk-context.current-date, output libthpos_chk-context.current-time).
      for each buf_libthpos_rp-by-call
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
      run rs_16_1 in buf_libthpos_rp-by-call.rph (
                  input '':U
                ,input libthpos_chk-context.lng
                ,input v-start-sum-brutto-r-b
                ,input v-sum-brutto-r-b
                ,input v-sum-for-discnt-r-b
                ,input v-st-discnt-r-b
                ,input v-bh
                ,output v-st-r-b
                ,output v-new-st-discnt-r-b
                ,output v-new-sum-for-discnt-r-b
                    ) no-error.
        if not error-status :error then do:
          assign
          v-sum-brutto-r-b = v-st-r-b
          v-st-discnt-r-b = v-new-st-discnt-r-b
          v-sum-for-discnt-r-b = v-new-sum-for-discnt-r-b
          .
        end.
      end.
      assign
      v-tot-discnt = v-new-st-discnt-r-b
      .
    end.
    if libthpos_chk-context.manual-discnt-id <> 0 then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id:
        assign
        libthpos_chk-context.manual-tot-discnt = libthpos_chk-context.manual-tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-discnt.discnt-value-abs
        .
        leave.
      end.
      case buf_libthpos_chk-discnt.value-type:
        when integer('1':U) then do:
          assign
          buf_libthpos_chk-discnt.discnt-value-abs = libthpos_chk-context.st-for-discnt-r-b *  buf_libthpos_chk-discnt.discnt-value-pcnt / 100
          buf_libthpos_chk-discnt.object-sum  = libthpos_chk-context.st-for-discnt-r-b
          buf_libthpos_chk-discnt.object-qnty = libthpos_chk-context.src-qnty
          .
        end.
        when integer('10':U) then do:
          assign
          buf_libthpos_chk-discnt.discnt-value-pcnt = buf_libthpos_chk-discnt.discnt-value-abs / libthpos_chk-context.st-for-discnt-r-b * 100
          buf_libthpos_chk-discnt.object-sum  = libthpos_chk-context.st-for-discnt-r-b
          buf_libthpos_chk-discnt.object-qnty = libthpos_chk-context.src-qnty
          .
        end.
      end case.
      buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
      assign
      libthpos_chk-context.manual-tot-discnt = libthpos_chk-context.manual-tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-discnt.discnt-value-abs
      .
    end.
    assign
    libthpos_chk-context.step =  if libthpos_chk-context.step = 1
                                then 2
                                else libthpos_chk-context.step
    libthpos_chk-context.tot-discnt = libthpos_chk-context.manual-tot-discnt + v-tot-discnt
    libthpos_chk-context.tot-r = v-tot-discnt - (libthpos_chk-context.tot-discnt - libthpos_chk-context.manual-tot-discnt )
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto - libthpos_chk-context.tot-discnt
    libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b - libthpos_chk-context.tot-discnt
    libthpos_chk-context.netto = libthpos_rmethod(libthpos_context.rmethod-type
                                                , libthpos_context.rmethod-coeff
                                                ,libthpos_chk-context.netto - libthpos_chk-context.tot-discnt)
    libthpos_chk-context.st-r-b = libthpos_rmethod(libthpos_context.rmethod-type
                                                    , libthpos_context.rmethod-coeff
                                                    , libthpos_chk-context.sub-netto)
    p-st-r-b = libthpos_chk-context.st-r-b
    libthpos_chk-context.st-rubl =  (if libthpos_context.r-b = 'rubl':U
                                    or (libthpos_context.r-b = 'base':U
                                        and
                                        libthpos_context.base-code = 0)
                                      then libthpos_chk-context.st-r-b
                                      else libthpos_chk-context.st-r-b * libthpos_chk-context.a-base-rate)
    p-st-rubl = libthpos_chk-context.st-rubl
    libthpos_chk-context.st-base = (if libthpos_context.r-b = 'base':U
                                    or (libthpos_context.r-b = 'rubl':U
                                        and
                                        libthpos_context.base-code = 0)
                                    then libthpos_chk-context.st-r-b
                                    else libthpos_chk-context.st-r-b / libthpos_chk-context.a-base-rate)
    libthpos_chk-context.to-pay-r-b   = libthpos_chk-context.st-r-b - libthpos_chk-context.has-pay-r-b - libthpos_chk-context.pay-discnt
    libthpos_chk-context.to-pay-rubl  = (if libthpos_context.r-b = 'rubl':U
                                            or (libthpos_context.r-b = 'base':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
                                            - libthpos_chk-context.has-pay-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.all-pay-rubl =  libthpos_chk-context.st-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.to-pay-base  = (if libthpos_context.r-b = 'base':U
                                            or (libthpos_context.r-b = 'rubl':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
                                        - libthpos_chk-context.has-pay-base - libthpos_chk-context.pay-discnt-base
    libthpos_chk-context.all-pay-base =  libthpos_chk-context.st-base - libthpos_chk-context.pay-discnt-base
    p-st-base = libthpos_chk-context.st-base
    p-tot-doc = libthpos_chk-context.src-tot-doc
    libthpos_chk-context.tot-r = libthpos_chk-context.sub-netto - libthpos_chk-context.st-r-b
    p-st-discnt  = libthpos_chk-context.gds-discnt + libthpos_chk-context.tot-discnt
    p-netto = libthpos_chk-context.netto
    p-netto-rubl = libthpos_chk-context.all-pay-rubl
    p-netto-base = libthpos_chk-context.all-pay-base
    p-all-discnt = libthpos_chk-context.src-tot-doc - libthpos_chk-context.netto
    p-all-discnt-rubl = libthpos_chk-context.src-tot-rubl - libthpos_chk-context.all-pay-rubl
    p-all-discnt-base = libthpos_chk-context.src-tot-base - libthpos_chk-context.all-pay-base
    p-setted = yes
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and libthpos_chk-context.direction > 0
    then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2) Возможно не стоит применять ручную скидку"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    if p-mode <> "no-changes" then do:
      dataset libthpos_receipt:accept-changes.
    end.
  end.
end.
end procedure.
procedure libthpos_pay-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-cdpay-code as integer no-undo .
define input-output parameter p-curr-code as integer   no-undo .
define input  parameter p-par-code as integer no-undo .
define input  parameter p-src-qnty as decimal no-undo .
define output parameter p-frpay-code as integer no-undo .
define input  parameter p-pass-pay   as integer no-undo .
define input  parameter p-pay-card as character no-undo .
define input-output parameter p-tot-sum as decimal no-undo .
define input-output parameter p-tot-rubl as decimal no-undo .
define input-output parameter p-tot-base as decimal no-undo .
define output parameter p-get-qnty-method as character no-undo .
define output parameter p-2-cdpay-code as integer no-undo .
define output parameter p-2-curr-code as integer   no-undo .
define output parameter p-2-frpay-code as integer no-undo .
define output parameter p-2-tot-sum as decimal no-undo .
define output parameter p-2-tot-rubl as decimal no-undo .
define output parameter p-2-tot-base as decimal no-undo .
define output parameter p-src-discnt-sum as decimal no-undo .
define output parameter p-src-discnt-rubl as decimal no-undo .
define output parameter p-for-discnt-doc as decimal no-undo .
define output parameter p-for-discnt-rubl as decimal no-undo .
define output parameter p-for-discnt-r-b as decimal no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-netto-sum as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-discnt as decimal no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-exch-abbr as character no-undo .
define variable v-exch-date as date no-undo .
define variable v-exch-time as integer no-undo .
define variable v-nalc-exch-rate as decimal no-undo .
define variable v-nalc-exch-scale as integer no-undo .
define variable v-nalc-exch-date as date no-undo .
define variable v-nalc-exch-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-calc-rate as integer no-undo .
define variable v-pay-discnt-sum as decimal no-undo .
define variable v-pay-discnt-rubl as decimal no-undo .
define variable v-pay-discnt-base as decimal no-undo .
define variable v-is-cash as logical no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-has-overpay as integer no-undo .
define variable v-atr1  as logical no-undo .
define variable v-has-return as integer no-undo .
define variable v-can-mix  as integer no-undo .
define variable v-is-credit-card as logical no-undo .
define variable v-is-debet-card  as logical no-undo .
define variable v-atr128 as logical no-undo .
define variable v-atr16 as logical no-undo .
define variable v-atr32 as logical no-undo .
define variable v-wth-code as integer   no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-src-val as integer   no-undo .
define variable v-par-rate as decimal no-undo .
define variable v-inversed as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_libthpos_temp-cash-pay-list for libthpos_temp-cash-pay-list.
define buffer buf2_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf2_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer undo_libthpos_chk-context for libthpos_chk-context.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step < 2 then do:
      v-err-mess = substitute("Не подведены итоги по чеку &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-line-num <= 0 then do:
      v-err-mess = substitute("Неверный номер строки оплат = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not (
            (
              (p-mode = 'ДОБАВЛЕНИЕ':U
              or
              p-mode = 'ИЗМЕНЕНИЕ':U
              or
              p-mode = 'удаление':U
              )
              and p-tot-sum <> ?
              )
            or
            (p-mode = 'check'
            and p-tot-sum = ?)
            ) then do:
      v-err-mess = substitute("Неверное действие над строкой оплат чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if p-mode = 'удаление':U
    and (p-tot-sum = ?
    or p-tot-sum <> 0 ) then do:
      v-err-mess = substitute("Для удаления строки оплат чека сумма должна = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    and (p-tot-sum = ?
    or p-tot-sum = 0) then do:
      v-err-mess = substitute("Для изменения строки оплат чека сумма не должна = 0 или ?").
      undo main-block, retry main-block.
    end.
    if p-tot-sum <> ? then do:
      v-inversed = yes.
    end.
    if p-tot-sum = ?
    and p-mode = "check"
    then do:
      p-mode = 'ДОБАВЛЕНИЕ':U.
    end.
    define variable v-na-vhode as decimal no-undo .
    v-na-vhode = p-tot-sum.
    if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0
    or lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,11,13,40,114,115,116,136,,117,111,113,201,206,208,301,306':U) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 строки оплат быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    case p-mode:
      when 'ДОБАВЛЕНИЕ':U then do:
        if libthpos_chk-context.lnp + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1&2должен быть &3"
                                      , p-line-num
                                      , chr(10)
                                      , libthpos_chk-context.lnp + 1).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code = ? then do:
          assign
          p-cdpay-code = 1
          p-curr-code = libthpos_context.nalc
          v-is-cash = yes
          v-has-overpay = 0
          v-atr1  = yes
          v-has-return = 1
          v-can-mix  = 1
          v-src-val = 0
          p-par-code = 0
          .
        end.
        else do:
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = p-cdpay-code
                and buf_cash-pay.curr-code = p-curr-code no-error.
          if not available buf_cash-pay then do:
            v-err-mess = substitute("Не найден тип кассового платежа с кодом &1 и валютой &2"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          if buf_cash-pay.wth-code > 0 then do:
            find first buf_wealth no-lock where
                      buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
            if not available buf_wealth then do:
              v-err-mess = substitute("Не найдена МЦ с кодом &1 для типа кассового платежа с кодом &2 и валютой &3"
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            v-get-qnty-method = buf_wealth.get-qnty-method.
                  end.
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = buf_cash-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
          assign
          v-has-overpay = buf_cash-pay.has-overpay
          v-atr1  = buf_cash-pay.atr1
          v-has-return = buf_cash-pay.has-return
          v-can-mix  = buf_cash-pay.can-mix
          v-is-credit-card = buf_cash-pay.is-credit-card
          v-is-debet-card  = buf_cash-pay.is-debet-card
          v-atr128 = buf_Cash-pay.atr128
          v-atr16 = buf_Cash-pay.atr16
          v-atr32 = buf_Cash-pay.atr32
          v-wth-code = buf_cash-pay.wth-code
          .
          if v-has-return = 0
          and lookup(string(libthpos_chk-context.chk-type), '6,96':U) > 0 then do:
            v-err-mess = substitute("Для типа касс платежа с кодом &1 и валютой &2 возврат ЗАПРЕЩЕН"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          if p-line-num > 1 then do:
            for each buf2_libthpos_chk-pay where
                    buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code,
                first buf2_cash-pay no-lock where
                    buf2_cash-pay.cdpay-code = buf2_libthpos_chk-pay.pay-code
              and  buf2_cash-pay.curr-code = buf2_libthpos_chk-pay.curr-code:
              if buf2_cash-pay.can-mix = 0
              and not (buf2_cash-pay.cdpay-code = buf_cash-pay.cdpay-code
                      and
                      buf2_cash-pay.curr-code = buf_cash-pay.curr-code)
              then do:
                v-err-mess = substitute("В чеке есть строка оплаты с № &1, для которой запрещена СМЕШАННАЯ ОПЛАТА"
                                                        , buf2_libthpos_chk-pay.line-num
                                                        ).
                undo main-block, retry main-block.
              end.
            end.
          end.
          assign
          v-is-cash = buf_cash-pay.is-cash
          .
          if p-pay-card <> "0"
          and p-pay-card <> ""
          and buf_cash-pay.is-cash then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 с признаком НАЛИЧНЫЕ не может быть № карты"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
        end.
        if p-cdpay-code = 1 then do:
          v-frpay-code = 1.
        end.
        else do:
          find first buf_libthpos_temp-cash-pay-list where
                  buf_libthpos_temp-cash-pay-list.cdpay-code = p-cdpay-code
              and  buf_libthpos_temp-cash-pay-list.curr-code = p-curr-code no-error .
          if not available  buf_libthpos_temp-cash-pay-list then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 не удалось найти соответствующий код оплаты на ФР"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          v-frpay-code = buf_libthpos_temp-cash-pay-list.frpay-code.
        end.
        if p-tot-sum = ? then do:
          assign
          v-tot-rubl = libthpos_chk-context.to-pay-rubl
          v-tot-base = libthpos_chk-context.to-pay-base
          .
          if p-curr-code = 0 then do:
            assign
            v-cash-rate = 1
            v-calc-rate = 1
            v-bank-rate = 1
            v-bank-scale = 1
            v-exch-rate = 1
            v-exch-scale = 1
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-sum = v-tot-rubl
            .
          end.
          else do:
            if p-curr-code = libthpos_context.base-code then do:
              assign
              v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              v-calc-rate = 1
              v-bank-rate = libthpos_chk-context.a-bank-rate
              v-bank-scale = libthpos_chk-context.a-bank-scale
              v-exch-rate = libthpos_chk-context.a-bank-rate
              v-exch-scale = libthpos_chk-context.a-bank-scale
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
              v-tot-sum = v-tot-base
              .
            end.
            else do:
              run cur-time in this-procedure ( output v-today, output v-time).
              find  LAST buf_curr-shop NO-LOCK WHERE
                            buf_curr-shop.obj-type = libthpos_context.obj-type
                        AND buf_curr-shop.obj-code = libthpos_context.obj-code
                        AND buf_curr-shop.curr-code = p-curr-code
                        AND ( ( buf_curr-shop.exch-date = v-today
                              AND
                              buf_curr-shop.exch-time <= v-time ) OR
                              buf_curr-shop.exch-date < v-today ) NO-ERROR .
              if available buf_curr-shop then do:
                assign
                v-exch-rate = buf_curr-shop.exch-rate
                v-exch-scale = buf_curr-shop.exch-scale
                v-exch-date  = buf_curr-shop.exch-date
                v-exch-time  = buf_curr-shop.exch-time
                .
              end.
              else do:
                v-err-mess =  substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , p-curr-code
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
                undo main-block, retry main-block.
              end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  ) no-error .
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при определении курса валюты с кодом &1 на &2", p-curr-code, string(v-today, "99/99/999")).
                undo main-block, retry main-block.
              end.
              assign
              v-tot-sum = (if libthpos_context.r-b = 'rubl':U
                          then p-tot-rubl / v-exch-rate * v-exch-scale
                          else p-tot-base * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale / v-exch-rate * v-exch-scale
                            )
              .
            end.
          end.
        end.
        else do:
          assign
          v-tot-sum = p-tot-sum
          .
          if p-curr-code = 0 then do:
            assign
              v-cash-rate = 1
              v-calc-rate = 1
              v-bank-rate = 1
              v-bank-scale = 1
              v-exch-rate = 1
              v-exch-scale = 1
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
            v-tot-rubl = p-tot-sum
            v-tot-base = (if libthpos_context.base-code = 0
                          then v-tot-rubl
                          else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
          end.
          else do:
            if p-curr-code = libthpos_context.base-code then do:
              assign
              v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              v-calc-rate = 1
              v-bank-rate = libthpos_chk-context.a-bank-rate
              v-bank-scale = libthpos_chk-context.a-bank-scale
              v-exch-rate = libthpos_chk-context.a-bank-rate
              v-exch-scale = libthpos_chk-context.a-bank-scale
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
              v-tot-base = p-tot-sum
              v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              .
            end.
            else do:
              run cur-time in this-procedure ( output v-today, output v-time).
              find  LAST buf_curr-shop NO-LOCK WHERE
                            buf_curr-shop.obj-type = libthpos_context.obj-type
                        AND buf_curr-shop.obj-code = libthpos_context.obj-code
                        AND buf_curr-shop.curr-code = p-curr-code
                        AND ( ( buf_curr-shop.exch-date = v-today
                              AND
                              buf_curr-shop.exch-time <= v-time ) OR
                              buf_curr-shop.exch-date < v-today ) NO-ERROR .
              if available buf_curr-shop then do:
                assign
                v-exch-rate = buf_curr-shop.exch-rate
                v-exch-scale = buf_curr-shop.exch-scale
                v-exch-date  = buf_curr-shop.exch-date
                v-exch-time  = buf_curr-shop.exch-time
                .
              end.
              else do:
                v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , p-curr-code
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
                undo main-block, retry main-block.
              end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  ) no-error .
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при получении курса валюты &1 на &2", p-curr-code, string(v-today, "99/99/9999")).
                undo main-block, retry main-block.
              end.
              assign
              v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
              .
            end.
          end.
          if v-atr1 = no
          and (v-has-overpay = 0
              or
              lookup(string(libthpos_chk-context.chk-type), '1,69,14,15,16,36':U) = 0
              )
          and (
                ( libthpos_context.r-b = 'rubl':U
                and
                abs(v-tot-rubl) > abs(libthpos_chk-context.to-pay-rubl))
                or
                ( libthpos_context.r-b = 'base':U
                and
                abs(v-tot-rubl) > abs(libthpos_chk-context.to-pay-base))
              ) then do:
            v-err-mess = substitute("Для типа касс. платежа с кодом &1 НЕ РАЗРЕШЕНА СДАЧА, а сумма >, чем сумма к оплате"
                                                      , p-cdpay-code
                                                      , p-curr-code).
            undo main-block, retry main-block.
          end.
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U
      or
      when 'удаление':U then do:
        for first buf_chk-pay share-lock where
                buf_chk-pay.doc-code = p-doc-code
            and buf_chk-pay.line-num = p-line-num,
            first buf_libthpos_chk-pay where
                buf_libthpos_chk-pay.doc-code = p-doc-code
            and buf_libthpos_chk-pay.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-pay then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code <> buf_chk-pay.pay-code
        then do:
          v-err-mess = substitute("Для уже имеющейся строки оплат чека (&1) нельзя изменить код типа касс. платеж и код валюты - были &2 &3"
                                      , p-line-num
                                      , buf_chk-pay.pay-code
                                      , buf_chk-pay.curr-code
                                      ).
          undo main-block, retry main-block.
        end.
        if p-pay-card = ""
        and (buf_libthpos_chk-pay.is-credit-card
              or
              buf_libthpos_chk-pay.is-debet-card
              or
              buf_libthpos_chk-pay.atr128
              or
              buf_libthpos_chk-pay.atr16
              or
              buf_libthpos_chk-pay.atr32
              )
        and p-mode <> 'удаление':U
        then do:
          v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 необходим № карты"
                                                  , p-cdpay-code
                                                  , p-curr-code).
          undo main-block, retry main-block.
        end.
        if p-mode = 'ИЗМЕНЕНИЕ':U then do:
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = libthpos_chk-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , libthpos_chk-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
        end.
        assign
        v-tot-sum  = p-tot-sum
        .
        if buf_libthpos_chk-pay.curr-code = 0 then do:
          assign
          v-tot-rubl = p-tot-sum
          v-tot-base = (if libthpos_context.base-code = 0
                        then v-tot-rubl
                        else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
        assign
        v-bank-rate = buf_libthpos_chk-pay.bank-rate
        v-bank-scale = buf_libthpos_chk-pay.bank-scale
        v-cash-rate = buf_libthpos_chk-pay.cash-rate
        v-exch-date = buf_libthpos_chk-pay.b-exch-date
        v-exch-time = buf_libthpos_chk-pay.b-exch-time
        v-exch-rate = buf_libthpos_chk-pay.b-exch-rate
        v-exch-scale =  buf_libthpos_chk-pay.b-exch-scale
        v-calc-rate = buf_libthpos_chk-pay.b-calc-rate
        v-is-cash = buf_libthpos_chk-pay.is-cash
        v-frpay-code = buf_libthpos_chk-pay.frpay-code
        v-pay-discnt-sum = buf_libthpos_chk-pay.discnt-sum
        v-pay-discnt-rubl = buf_libthpos_chk-pay.discnt-rubl
        v-pay-discnt-base = buf_libthpos_chk-pay.discnt-base
        v-has-overpay = buf_libthpos_chk-pay.has-overpay
        v-can-mix = buf_libthpos_chk-pay.can-mix
        v-has-return = buf_libthpos_chk-pay.has-return
        v-atr1 = buf_libthpos_chk-pay.atr1
        v-is-credit-card = buf_libthpos_chk-pay.is-credit-card
        v-is-debet-card  = buf_libthpos_chk-pay.is-debet-card
        v-atr128 = buf_libthpos_chk-pay.atr128
        v-atr16 = buf_libthpos_chk-pay.atr16
        v-atr32 = buf_libthpos_chk-pay.atr32
        v-wth-code = buf_libthpos_chk-pay.wth-code
        v-get-qnty-method = buf_libthpos_chk-pay.get-qnty-method
        .
        if v-get-qnty-method = '=val-qnty':U
        and p-mode = 'ИЗМЕНЕНИЕ':U then do:
          if not (p-par-code > 0
                and
                p-src-qnty <> 0) then do:
            v-err-mess = substitute("Для типа касс. платеж с кодом &1 и кодом валюты &2 необходимо указать номинал и количество знаков оплаты"
                                        , buf_chk-pay.pay-code
                                        , buf_chk-pay.curr-code
                                        ).
            undo main-block, retry main-block.
          end.
        end.
      end.
    end case.
    if libthpos_context.nalc <>  0
    and libthpos_context.nalc <> libthpos_context.base-code
    and libthpos_context.nalc <> p-curr-code then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = libthpos_context.obj-type
                AND buf_curr-shop.obj-code = libthpos_context.obj-code
                AND buf_curr-shop.curr-code = libthpos_context.nalc
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-nalc-exch-rate = buf_curr-shop.exch-rate
        v-nalc-exch-scale = buf_curr-shop.exch-scale
        v-nalc-exch-date  = buf_curr-shop.exch-date
        v-nalc-exch-time  = buf_curr-shop.exch-time
        .
      end.
      else do:
        v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , libthpos_context.nalc
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
        undo main-block, retry main-block.
      end.
    end.
    if (p-mode = 'ДОБАВЛЕНИЕ':U
    or p-mode = 'ИЗМЕНЕНИЕ':U)
    and p-line-num = 1
    and libthpos_chk-context.direction > 0
    and v-tot-sum < 0 then do:
      v-err-mess = substitute("Неверный знак суммы по типу кассового платежа с кодом &1", p-cdpay-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = 'ДОБАВЛЕНИЕ':U
    or p-mode = 'ИЗМЕНЕНИЕ':U)
    and libthpos_chk-context.direction < 0
    and v-tot-sum > 0 then do:
      v-err-mess = substitute("Неверный знак суммы строки оплаты &1 чека &2", p-cdpay-code, p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U
    then do:
      create buf_libthpos_chk-pay.
      if p-mode = 'ДОБАВЛЕНИЕ':U
      and v-inversed then do:
        create buf_chk-pay.
        assign
        buf_chk-pay.doc-code = p-doc-code
        libthpos_chk-context.lnp = libthpos_chk-context.lnp + 1
        libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
        buf_chk-pay.line-num = libthpos_chk-context.lnp
        buf_libthpos_chk-pay.recalc-line-num = buf_chk-pay.line-num
        buf_chk-pay.chk-date = libthpos_chk-doc.chk-date
        buf_chk-pay.time-oper = v-time
        buf_chk-pay.pay-code = p-cdpay-code
        buf_chk-pay.curr-code = p-curr-code
        buf_chk-pay.par-code = p-par-code
        buf_chk-pay.pass-pay = 0
        buf_chk-pay.line-type  = ''
        buf_chk-pay.pay-card = ""
        buf_Chk-pay.obj-type = libthpos_context.obj-type
        buf_chk-pay.obj-code = libthpos_context.obj-code
        buf_Chk-pay.bank-rate = 1
        buf_Chk-pay.bank-scale = 1
        buf_Chk-pay.cash-rate = 1
        buf_chk-pay.is-error = no
        buf_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
        buf_chk-pay.line-type = ""
        buf_chk-pay.out-code = ?
        buf_chk-pay.tot-base = 0
        buf_chk-pay.tot-rubl = 0
        buf_chk-pay.tot-sum = 0
        buf_chk-pay.par-code = p-par-code
        buf_chk-pay.src-val = v-src-val
        buf_chk-pay.pass-pay = p-pass-pay
        .
        buffer-copy buf_chk-pay to buf_libthpos_chk-pay.
      end.
      else do:
        assign
        buf_libthpos_chk-pay.doc-code = p-doc-code
        buf_libthpos_chk-pay.line-num = -1
        buf_libthpos_chk-pay.recalc-line-num = -1
        buf_libthpos_chk-pay.chk-date = libthpos_chk-doc.chk-date
        buf_libthpos_chk-pay.time-oper = v-time
        buf_libthpos_chk-pay.pay-code = p-cdpay-code
        buf_libthpos_chk-pay.curr-code = p-curr-code
        buf_libthpos_chk-pay.par-code = p-par-code
        buf_libthpos_chk-pay.pass-pay = 0
        buf_libthpos_chk-pay.line-type  = ''
        buf_libthpos_chk-pay.pay-card = ""
        buf_libthpos_chk-pay.obj-type = libthpos_context.obj-type
        buf_libthpos_chk-pay.obj-code = libthpos_context.obj-code
        buf_libthpos_chk-pay.bank-rate = 1
        buf_libthpos_chk-pay.bank-scale = 1
        buf_libthpos_chk-pay.cash-rate = 1
        buf_libthpos_chk-pay.is-error = no
        buf_libthpos_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
        buf_libthpos_chk-pay.line-type = ""
        buf_libthpos_chk-pay.out-code = ?
        buf_libthpos_chk-pay.tot-base = 0
        buf_libthpos_chk-pay.tot-rubl = 0
        buf_libthpos_chk-pay.tot-sum = 0
        buf_libthpos_chk-pay.par-code = p-par-code
        buf_libthpos_chk-pay.src-val = v-src-val
        buf_libthpos_chk-pay.pass-pay = p-pass-pay
        .
      end.
      assign
      buf_libthpos_chk-pay.has-overpay = v-has-overpay
      buf_libthpos_chk-pay.atr1  = v-atr1
      buf_libthpos_chk-pay.has-return = v-has-return
      buf_libthpos_chk-pay.can-mix  = v-can-mix
      buf_libthpos_chk-pay.is-credit-card = v-is-credit-card
      buf_libthpos_chk-pay.is-debet-card = v-is-debet-card
      buf_libthpos_chk-pay.atr128 = v-atr128
      buf_libthpos_chk-pay.atr16 = v-atr16
      buf_libthpos_chk-pay.atr32 =  v-atr32
      buf_libthpos_chk-pay.get-qnty-method = v-get-qnty-method
      buf_libthpos_chk-pay.wth-code = v-wth-code
      buf_libthpos_chk-pay.par-rate = v-par-rate
      .
    end.
    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = 'IBS-TH':U
    and v-inversed
    then do:
      find first buf_libthpos_cash-counter where
                buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
          and  buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
          and  buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
          and  buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
                no-error.
      if not available buf_libthpos_cash-counter then do:
        create buf_libthpos_cash-counter.
        assign
        buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
        buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
        buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
        buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
        buf_libthpos_cash-counter.par-val = buf_chk-pay.src-val
        .
      end.
    end.
    assign
    libthpos_chk-context.pay-discnt = libthpos_chk-context.pay-discnt - buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.pay-discnt-rubl = libthpos_chk-context.pay-discnt-rubl - buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.pay-discnt-base = libthpos_chk-context.pay-discnt-base - buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.to-pay-r-b = libthpos_chk-context.to-pay-r-b + buf_libthpos_chk-pay.brutto-r-b +
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-r-b else 0)
    libthpos_chk-context.with-atr1-sum = libthpos_chk-context.with-atr1-sum -
                                        (if buf_libthpos_chk-pay.atr1
                                        then (if libthpos_context.r-b = 'base':U
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.change-sum = libthpos_chk-context.change-sum -
                                        (if buf_libthpos_chk-pay.line-sign = no
                                        then (if libthpos_context.r-b = 'base':U
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.has-pay-r-b = libthpos_chk-context.has-pay-r-b - (if libthpos_context.r-b = 'base':U
                                                                            then buf_libthpos_chk-pay.tot-base
                                                                            else buf_libthpos_chk-pay.tot-rubl)
    libthpos_chk-context.to-pay-rubl = libthpos_chk-context.to-pay-rubl + buf_libthpos_chk-pay.brutto-rubl +
                                        (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0)
    libthpos_chk-context.has-pay-rubl = libthpos_chk-context.has-pay-rubl - buf_libthpos_chk-pay.tot-rubl
    libthpos_chk-context.all-pay-rubl = libthpos_chk-context.all-pay-rubl + buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.to-pay-base = libthpos_chk-context.to-pay-base + buf_libthpos_chk-pay.brutto-base +
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-base else 0)
    libthpos_chk-context.has-pay-base = libthpos_chk-context.has-pay-base - buf_libthpos_chk-pay.tot-base
    libthpos_chk-context.all-pay-base = libthpos_chk-context.all-pay-base + buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.pay-r = libthpos_chk-context.pay-r - buf_libthpos_chk-pay.r-sum
    .
    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = 'IBS-TH':U
    and v-inversed
    then do:
      assign
      buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum - buf_chk-pay.tot-sum
      buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base - buf_libthpos_chk-pay.tot-base
      buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl - buf_libthpos_chk-pay.tot-rubl
      buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines - 1
      buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty - buf_chk-pay.src-qnty
      libthpos_context.pre-cash-counter = (if buf_libthpos_cash-counter.is-cash = yes
                                          then (libthpos_context.pre-cash-counter -
                                                  (if libthpos_context.r-b = 'rubl':U
                                                  then buf_libthpos_chk-pay.tot-rubl
                                                  else buf_libthpos_chk-pay.tot-base)
                                                )
                                          else libthpos_context.pre-cash-counter)
      .
    end.
    assign
    buf_libthpos_chk-pay.inversed = (if p-mode <> 'удаление':U then v-inversed else buf_libthpos_chk-pay.inversed)
    buf_libthpos_chk-pay.is-cash = v-is-cash
    buf_libthpos_chk-pay.frpay-code = v-frpay-code
    buf_libthpos_chk-pay.has-overpay = v-has-overpay
    buf_libthpos_chk-pay.can-mix = v-can-mix
    buf_libthpos_chk-pay.has-return = v-has-return
    buf_libthpos_chk-pay.atr1 = v-atr1
    buf_libthpos_chk-pay.is-credit-card = v-is-credit-card
    buf_libthpos_chk-pay.is-debet-card = v-is-debet-card
    buf_libthpos_chk-pay.atr128 = v-atr128
    buf_libthpos_chk-pay.atr16 = v-atr16
    buf_libthpos_chk-pay.atr32 =  v-atr32
    buf_libthpos_chk-pay.get-qnty-method =  v-get-qnty-method
    buf_libthpos_chk-pay.par-rate =  v-par-rate
    buf_libthpos_chk-pay.wth-code =  v-wth-code
    buf_libthpos_chk-pay.src-val =  v-src-val
    buf_libthpos_chk-pay.tot-base = v-tot-base
    buf_libthpos_chk-pay.tot-rubl = v-tot-rubl
    buf_libthpos_chk-pay.tot-sum = v-tot-sum
    buf_libthpos_chk-pay.bank-rate = v-bank-rate
    buf_libthpos_chk-pay.bank-scale = v-bank-scale
    buf_libthpos_chk-pay.cash-rate = v-cash-rate
    buf_libthpos_chk-pay.b-exch-date = v-exch-date
    buf_libthpos_chk-pay.b-exch-time = v-exch-time
    buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
    buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
    buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
    buf_libthpos_chk-pay.brutto-doc = v-tot-sum
    buf_libthpos_chk-pay.brutto-rubl = v-tot-rubl
    buf_libthpos_chk-pay.brutto-base = v-tot-base
    buf_libthpos_chk-pay.brutto-r-b = (if libthpos_context.r-b = 'rubl':U
                                      then v-tot-rubl
                                      else v-tot-base)
    .
    if buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    then do:
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = (if libthpos_chk-context.to-pay-rubl * libthpos_chk-context.direction < (v-tot-sum /  buf_libthpos_chk-pay.b-exch-rate * buf_libthpos_chk-pay.b-exch-scale) * libthpos_chk-context.direction
                                            then libthpos_chk-context.to-pay-rubl
                                            else  v-tot-rubl)
      buf_libthpos_chk-pay.for-discnt-doc = (if buf_libthpos_chk-pay.curr-code = 0
                                            then buf_libthpos_chk-pay.for-discnt-rubl
                                            else  buf_libthpos_chk-pay.for-discnt-rubl / buf_libthpos_chk-pay.b-exch-rate * buf_libthpos_chk-pay.b-exch-scale )
      buf_libthpos_chk-pay.for-discnt-r-b = (if libthpos_context.r-b = 'rubl':U
                                              or libthpos_context.base-code = 0
                                              then buf_libthpos_chk-pay.for-discnt-rubl
                                              else buf_libthpos_chk-pay.for-discnt-rubl / libthpos_chk-context.base-rate )
      buf_libthpos_chk-pay.for-discnt-base = (if buf_libthpos_chk-pay.curr-code = libthpos_context.base-code
                                              then buf_libthpos_chk-pay.for-discnt-doc
                                              else (if buf_libthpos_chk-pay.curr-code = 0
                                                    then buf_libthpos_chk-pay.for-discnt-rubl
                                                    else buf_libthpos_chk-pay.for-discnt-rubl / libthpos_chk-context.base-rate )
                                              )
      .
    end.
    else do:
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = 0
      buf_libthpos_chk-pay.for-discnt-doc = 0
      buf_libthpos_chk-pay.for-discnt-r-b = 0
      buf_libthpos_chk-pay.for-discnt-base = 0
      .
    end.
    define variable v-start-curr-sum as decimal no-undo .
    define variable v-start-rubl-sum as decimal no-undo .
    define variable v-start-base-sum as decimal no-undo .
    define variable v-curr-sum as decimal no-undo .
    define variable v-rubl-sum as decimal no-undo .
    define variable v-base-sum as decimal no-undo .
    define variable v-discnt-curr as decimal no-undo .
    define variable v-discnt-rubl as decimal no-undo .
    define variable v-discnt-base as decimal no-undo .
    define variable v-new-curr-sum as decimal no-undo .
    define variable v-new-rubl-sum as decimal no-undo .
    define variable v-new-base-sum as decimal no-undo .
    define variable v-new-discnt-curr as decimal no-undo .
    define variable v-new-discnt-rubl as decimal no-undo .
    define variable v-new-discnt-base as decimal no-undo .
    assign
    v-start-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-start-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-start-base-sum = buf_libthpos_chk-pay.tot-base
    v-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-base-sum = buf_libthpos_chk-pay.tot-base
    v-new-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-new-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-new-base-sum = buf_libthpos_chk-pay.tot-base
    v-discnt-curr = 0
    v-discnt-rubl = 0
    v-discnt-base = 0
    v-new-discnt-curr = 0
    v-new-discnt-rubl = 0
    v-new-discnt-base = 0
    .
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) = 0
    and buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    and libthpos_chk-context.direction > 0
    then do:
      if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
        _chk-discnt-pay:
        for each buf_libthpos_chk-discnt share-lock where
                buf_libthpos_chk-discnt.line-type = integer('5':U)
          and buf_libthpos_chk-discnt.line-num = p-line-num
          and buf_libthpos_chk-discnt.record-type = 0
          and buf_libthpos_chk-discnt.object-line-num = p-line-num,
            first buf_chk-discnt where
                  buf_chk-discnt.doc-code = p-doc-code
            and buf_chk-discnt.line-num = buf_libthpos_chk-discnt.line-num
            and buf_chk-discnt.record-type = buf_libthpos_chk-discnt.record-type
            and buf_chk-discnt.discnt-id = buf_libthpos_chk-discnt.discnt-id
            and buf_chk-discnt.object-line-num = buf_libthpos_chk-discnt.object-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          delete buf_chk-discnt.
          delete buf_libthpos_chk-discnt.
        end.
        assign
        buf_libthpos_chk-pay.discnt-r-b = 0
        buf_libthpos_chk-pay.discnt-rubl = 0
        buf_libthpos_chk-pay.discnt-base = 0
        buf_libthpos_chk-pay.discnt-sum = 0
        .
      end.
      if p-mode <> 'удаление':U then do:
        run cur-time in this-procedure ( output libthpos_chk-context.current-date, output libthpos_chk-context.current-time).
        assign
        v-bh[1] = (buffer libthpos_context:handle)
        v-bh[4] = (buffer libthpos_chk-gds:handle)
        v-bh[5] = (buffer buf_libthpos_chk-pay:handle)
        v-bh[6] = (buffer libthpos_chk-discnt:handle)
        .
        for each buf_libthpos_rp-by-call
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
        run rs_17_1 in buf_libthpos_rp-by-call.rph (
                    input '':U
                  ,input p-line-num
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-pay-card
                  ,input buf_libthpos_chk-pay.inversed
                  ,input v-start-curr-sum
                  ,input v-curr-sum
                  ,input v-start-rubl-sum
                  ,input v-rubl-sum
                  ,input v-start-base-sum
                  ,input v-base-sum
                  ,input v-discnt-curr
                  ,input v-discnt-rubl
                  ,input v-discnt-base
                  ,input v-bh
                  ,output v-new-curr-sum
                  ,output v-new-rubl-sum
                  ,output v-new-base-sum
                  ,output v-new-discnt-curr
                  ,output v-new-discnt-rubl
                  ,output v-new-discnt-base
                      ) no-error.
          if not error-status :error then do:
            assign
            v-curr-sum = v-new-curr-sum
            v-rubl-sum = v-new-rubl-sum
            v-base-sum = v-new-base-sum
            v-discnt-curr = v-new-discnt-curr
            v-discnt-rubl = v-new-discnt-rubl
            v-discnt-base = v-new-discnt-base
            .
          end.
        end.
      end.
    end.
    assign
    v-pay-discnt-sum = v-new-discnt-curr
    v-pay-discnt-rubl = v-new-discnt-rubl
    v-pay-discnt-base = v-new-discnt-base
    .
    define variable v-netto-sum-wr as decimal no-undo .
    assign
    buf_libthpos_chk-pay.discnt-sum = round(v-pay-discnt-sum, 2)
    buf_libthpos_chk-pay.discnt-rubl = round(v-pay-discnt-rubl, 2)
    buf_libthpos_chk-pay.discnt-base = round(v-pay-discnt-base, 2)
    buf_libthpos_chk-pay.discnt-r-b = round((if libthpos_context.r-b = 'rubl':U
                                      then v-pay-discnt-rubl
                                      else v-pay-discnt-base), 2)
    buf_libthpos_chk-pay.brutto-doc = (if buf_libthpos_chk-pay.inversed then (v-tot-sum  ) else buf_libthpos_chk-pay.brutto-doc)
    buf_libthpos_chk-pay.brutto-rubl = (if buf_libthpos_chk-pay.inversed then (v-tot-rubl  ) else buf_libthpos_chk-pay.brutto-rubl)
    buf_libthpos_chk-pay.brutto-base = (if buf_libthpos_chk-pay.inversed then (v-tot-base  ) else buf_libthpos_chk-pay.brutto-base)
    buf_libthpos_chk-pay.brutto-r-b = (if libthpos_context.r-b = 'rubl':U
                                      then buf_libthpos_chk-pay.brutto-rubl
                                      else buf_libthpos_chk-pay.brutto-base)
    v-netto-sum-wr = (if libthpos_context.r-b = 'rubl':U
                      then v-rubl-sum
                      else v-base-sum)
    v-netto-sum  = round(v-netto-sum, 2)
    v-netto-sum  = round(v-curr-sum, 2)
    v-netto-rubl = round(v-rubl-sum, 2)
    v-netto-base = round(v-base-sum, 2)
    buf_libthpos_chk-pay.tot-sum = v-netto-sum
    buf_libthpos_chk-pay.tot-rubl = v-netto-rubl
    buf_libthpos_chk-pay.tot-base = v-netto-base
    buf_libthpos_chk-pay.r-sum = (v-netto-sum - v-netto-sum-wr) -
                                ((if libthpos_context.r-b = 'rubl':U
                                  then v-pay-discnt-rubl
                                  else v-pay-discnt-base) - buf_libthpos_chk-pay.discnt-r-b)
    buf_libthpos_chk-pay.pass-pay = p-pass-pay
    .
    if v-inversed then do:
      assign
      buf_chk-pay.tot-sum   = v-netto-sum
      buf_chk-pay.src-qnty = p-src-qnty
      buf_chk-pay.bank-rate = v-bank-rate
      buf_chk-pay.bank-scale = v-bank-scale
      buf_chk-pay.cash-rate = v-cash-rate
      buf_chk-pay.pass-pay = p-pass-pay
      buf_chk-pay.time-oper = v-time
      buf_chk-pay.line-sign = (if libthpos_chk-context.chk-type = integer('1':U)
                                then (buf_chk-pay.tot-sum >= 0)
                                else (buf_chk-pay.tot-sum <= 0)
                          )
      .
    end.
    if buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    then do:
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = buf_libthpos_chk-pay.for-discnt-rubl + buf_libthpos_chk-pay.discnt-rubl
      buf_libthpos_chk-pay.for-discnt-doc  = buf_libthpos_chk-pay.for-discnt-doc + buf_libthpos_chk-pay.discnt-sum
      buf_libthpos_chk-pay.for-discnt-base = buf_libthpos_chk-pay.for-discnt-base + buf_libthpos_chk-pay.discnt-base
      buf_libthpos_chk-pay.for-discnt-r-b  = buf_libthpos_chk-pay.for-discnt-r-b +  (if libthpos_context.r-b = 'rubl':U
                                                                                      then buf_libthpos_chk-pay.discnt-rubl
                                                                                      else buf_libthpos_chk-pay.discnt-base)
      .
    end.
    else do:
    end.
    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = 'IBS-TH':U
    and v-inversed
    then do:
      assign
      buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum + buf_chk-pay.tot-sum
      buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base + buf_libthpos_chk-pay.tot-base
      buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl + buf_libthpos_chk-pay.tot-rubl
      buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty + buf_chk-pay.src-qnty
      buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines + 1
      libthpos_context.pre-cash-counter = (if buf_libthpos_chk-pay.is-cash
                                          then  (libthpos_context.pre-cash-counter +
                                              (if libthpos_context.r-b = 'rubl':U
                                              then buf_libthpos_chk-pay.tot-rubl
                                              else buf_libthpos_chk-pay.tot-base)
                                              )
                                              else libthpos_context.pre-cash-counter)
      .
    end.
    assign
    libthpos_chk-context.pay-discnt = libthpos_chk-context.pay-discnt + buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.pay-discnt-rubl = libthpos_chk-context.pay-discnt-rubl + buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.pay-discnt-base = libthpos_chk-context.pay-discnt-base + buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.to-pay-r-b = libthpos_chk-context.to-pay-r-b -  buf_libthpos_chk-pay.brutto-r-b -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-r-b else 0)
    libthpos_chk-context.has-pay-r-b = libthpos_chk-context.has-pay-r-b + (if libthpos_context.r-b = 'base':U
                                                                            then v-netto-base
                                                                            else v-netto-rubl)
    libthpos_chk-context.change-sum = libthpos_chk-context.change-sum +
                                        (if buf_libthpos_chk-pay.line-sign = no
                                        then (if libthpos_context.r-b = 'base':U
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.with-atr1-sum = libthpos_chk-context.with-atr1-sum +
                                        (if buf_libthpos_chk-pay.atr1
                                        then (if libthpos_context.r-b = 'base':U
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.to-pay-rubl = libthpos_chk-context.to-pay-rubl - buf_libthpos_chk-pay.brutto-rubl -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0)
    libthpos_chk-context.has-pay-rubl = libthpos_chk-context.has-pay-rubl + v-netto-rubl
    libthpos_chk-context.all-pay-rubl = libthpos_chk-context.all-pay-rubl - buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.to-pay-base = libthpos_chk-context.to-pay-base - buf_libthpos_chk-pay.brutto-base -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-base else 0)
    libthpos_chk-context.has-pay-base = libthpos_chk-context.has-pay-base + v-netto-base
    libthpos_chk-context.all-pay-base = libthpos_chk-context.all-pay-base - buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.pay-r = libthpos_chk-context.pay-r + buf_libthpos_chk-pay.r-sum
    libthpos_chk-context.step =  if libthpos_chk-context.step = 2
                                then 3
                                else libthpos_chk-context.step
    .
    if p-mode = 'удаление':U
    and buf_chk-pay.tot-sum = 0 then do:
      delete buf_chk-pay.
      delete buf_libthpos_chk-pay.
      find last buf2_libthpos_chk-pay where
                buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code use-index ln no-error.
      assign
      libthpos_chk-context.lnp = (if available buf2_libthpos_chk-pay
                                  then buf2_libthpos_chk-pay.line-num
                                  else 0)
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      .
      if libthpos_chk-context.lnp = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = 3
                                    then 2
                                    else libthpos_chk-context.step.
      end.
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    if available buf_libthpos_chk-pay then do:
      assign
      buf_libthpos_chk-pay.b-exch-date = v-exch-date
      buf_libthpos_chk-pay.b-exch-time = v-exch-time
      buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
      buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
      buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
      .
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U
    and v-atr1 = yes then do:
      assign
      p-2-cdpay-code = p-cdpay-code
      p-2-curr-code = p-curr-code
      p-frpay-code = v-frpay-code
      .
    end.
    else do:
      assign
      p-2-cdpay-code = 1
      p-2-curr-code = libthpos_context.nalc
      p-2-frpay-code = 1
      .
    end.
    assign
    p-frpay-code = v-frpay-code
    p-tot-sum = v-netto-sum
    p-tot-rubl = v-netto-rubl
    p-tot-base = v-netto-base
    p-2-tot-sum  = (if p-2-curr-code = 0
                    then libthpos_chk-context.to-pay-rubl
                    else (if p-2-curr-code = libthpos_context.base-code
                          then libthpos_chk-context.to-pay-base
                          else (if libthpos_context.r-b = 'rubl':U
                                then  libthpos_chk-context.to-pay-rubl / v-nalc-exch-rate * v-nalc-exch-scale
                                else libthpos_chk-context.to-pay-base / libthpos_chk-context.a-cash-rate * libthpos_chk-context.a-cash-scale
                                * v-nalc-exch-rate / v-nalc-exch-scale
                                )
                          )
                    )
    p-2-tot-rubl = libthpos_chk-context.to-pay-rubl
    p-2-tot-base = libthpos_chk-context.to-pay-base
    p-2-tot-sum  =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-sum)
    p-2-tot-rubl =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-rubl)
    p-2-tot-base =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-base)
    p-get-qnty-method = v-get-qnty-method
    p-src-discnt-sum = (if p-mode = 'удаление':U then 0 else (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-sum else 0))
    p-src-discnt-rubl = (if p-mode = 'удаление':U then 0 else (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0))
    p-for-discnt-doc =  (if p-mode = 'удаление':U then 0 else buf_libthpos_chk-pay.for-discnt-doc)
    p-for-discnt-rubl = (if p-mode = 'удаление':U then 0 else buf_libthpos_chk-pay.for-discnt-rubl)
    p-for-discnt-r-b = (if p-mode = 'удаление':U then 0 else buf_libthpos_chk-pay.for-discnt-r-b)
    p-setted = yes
    .
    if available buf_libthpos_chk-pay then do:
      run printbuffer in this-procedure ( input (buffer buf_chk-pay:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-pay:handle)).
    end.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    if not v-inversed then do:
      dataset libthpos_receipt:reject-changes.
      undo main-block, return ''.
    end.
    else do:
      dataset libthpos_receipt:accept-changes.
    end.
    find first libthpos_chk-context.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
  end.
end.
end procedure.
procedure libthpos_inst-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-cdpay-code as integer no-undo .
define input-output parameter p-curr-code as integer   no-undo .
define input  parameter p-par-code as integer no-undo .
define input  parameter p-src-qnty as decimal no-undo .
define output parameter p-frpay-code as integer no-undo .
define input  parameter p-pass-pay   as integer no-undo .
define input  parameter p-pay-card as character no-undo .
define input-output parameter p-tot-sum as decimal no-undo .
define input-output parameter p-tot-rubl as decimal no-undo .
define input-output parameter p-tot-base as decimal no-undo .
define output parameter p-get-qnty-method as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-exch-abbr as character no-undo .
define variable v-exch-date as date no-undo .
define variable v-exch-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-calc-rate as integer no-undo .
define variable v-is-cash as logical no-undo .
define variable v-wth-code as integer   no-undo .
define variable v-src-val as integer   no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-par-rate as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-inversed as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf2_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_libthpos_temp-cash-pay-list for libthpos_temp-cash-pay-list.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if not (p-mode = 'ДОБАВЛЕНИЕ':U
            or
            p-mode = 'ИЗМЕНЕНИЕ':U
            or
            p-mode = 'удаление':U
            ) then do:
      v-err-mess = substitute("Неверное действие над строкой оплат чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if p-mode = 'удаление':U
    and (p-tot-sum = ?
    or p-tot-sum <> 0 ) then do:
      v-err-mess = substitute("Для удаления строки оплат чека сумма должна = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    and (p-tot-sum = ?
    or p-tot-sum = 0)
    and not libthpos_chk-context.chk-type = integer('7':U)
    then do:
      v-err-mess = substitute("Для изменения строки оплат чека сумма не должна = 0 или ?").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.chk-type = integer('7':U)
    and p-tot-sum <> 0
    then do:
      v-err-mess = substitute("Для строки оплат в чеке типа ДЕКЛАРАЦИЯ сумма должна = 0").
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) = 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 строки оплат быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if p-tot-sum = ?
    and not (libthpos_chk-context.chk-type = integer('2':U)
            or
            libthpos_chk-context.chk-type = integer('рас':U)
            or
            (libthpos_chk-context.chk-type = integer('4':U)  and p-line-num = 2)
            ) then do:
      v-err-mess = substitute("В чеке &1 с типом &2 должна быть задана сумма", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if p-line-num > 2
    and libthpos_chk-context.chk-type = integer('4':U) then do:
      v-err-mess = substitute("В чеке &1 с типом &2 может быть только 2 строки", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    case p-mode:
      when 'ДОБАВЛЕНИЕ':U then do:
        if libthpos_chk-context.lnp + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1&2должен быть &3"
                                      , p-line-num
                                      , chr(10)
                                      , libthpos_chk-context.lnp + 1).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code = ? then do:
          assign
          p-cdpay-code = 1
          p-curr-code = libthpos_context.nalc
          v-is-cash = yes
          .
        end.
        else do:
        end.
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = p-cdpay-code
                and buf_cash-pay.curr-code = p-curr-code no-error.
          if not available buf_cash-pay then do:
            v-err-mess = substitute("Не найден тип кассового платежа с кодом &1 и валютой &2"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-is-cash = buf_cash-pay.is-cash
          .
        if buf_cash-pay.wth-code > 0 then do:
          find first buf_wealth no-lock where
                    buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
          if not available buf_wealth then do:
            v-err-mess = substitute("Не найдена МЦ с кодом &1 для типа кассового платежа с кодом &2 и валютой &3"
                                                    , buf_cash-pay.wth-code
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-get-qnty-method = buf_wealth.get-qnty-method
          v-wth-code = buf_wealth.wth-code
          .
        end.
        if p-par-code <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.par-code = p-par-code
                and buf_wth-par.wth-code = buf_cash-pay.wth-code no-error.
          if not available buf_wth-par then do:
            v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                    , p-par-code
                                                    , buf_cash-pay.wth-code
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-src-val = buf_wth-par.par-val
          v-par-rate = buf_wth-par.par-rate
          .
        end.
        if p-cdpay-code = 1 then do:
          v-frpay-code = 1.
        end.
        else do:
          find first buf_libthpos_temp-cash-pay-list where
                  buf_libthpos_temp-cash-pay-list.cdpay-code = p-cdpay-code
              and  buf_libthpos_temp-cash-pay-list.curr-code = p-curr-code no-error .
          if not available  buf_libthpos_temp-cash-pay-list then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 не удалось найти соответствующий код оплаты на ФР"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          v-frpay-code = buf_libthpos_temp-cash-pay-list.frpay-code.
        end.
        assign
        v-tot-sum = p-tot-sum
        .
        if p-curr-code = 0 then do:
            assign
            v-cash-rate = 1
            v-calc-rate = 1
            v-bank-rate = 1
            v-bank-scale = 1
            v-exch-rate = 1
            v-exch-scale = 1
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-rubl = p-tot-sum
            v-tot-base = (if libthpos_context.base-code = 0
                          then v-tot-rubl
                          else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            v-calc-rate = 1
            v-bank-rate = libthpos_chk-context.a-bank-rate
            v-bank-scale = libthpos_chk-context.a-bank-scale
            v-exch-rate = libthpos_chk-context.a-bank-rate
            v-exch-scale = libthpos_chk-context.a-bank-scale
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            find  LAST buf_curr-shop NO-LOCK WHERE
                          buf_curr-shop.obj-type = libthpos_context.obj-type
                      AND buf_curr-shop.obj-code = libthpos_context.obj-code
                      AND buf_curr-shop.curr-code = p-curr-code
                      AND ( ( buf_curr-shop.exch-date = v-today
                            AND
                            buf_curr-shop.exch-time <= v-time ) OR
                            buf_curr-shop.exch-date < v-today ) NO-ERROR .
            if available buf_curr-shop then do:
              assign
              v-exch-rate = buf_curr-shop.exch-rate
              v-exch-scale = buf_curr-shop.exch-scale
              v-exch-date  = buf_curr-shop.exch-date
              v-exch-time  = buf_curr-shop.exch-time
              .
            end.
            else do:
              v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                        , p-curr-code
                        , libthpos_context.obj-type
                        , libthpos_context.obj-code
                        , string(v-today, "99/99/9999")
                        , string(v-time, "HH:MM:SS")
                      ).
              undo main-block, retry main-block.
            end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  v-today
  ,output v-bank-rate
  ,output v-bank-scale
  ,output v-bank-abbr
  ) no-error .
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при определении курса валюты с кодом &1 на &2", p-curr-code, string(v-today, "99/99/9999")).
              undo main-block, retry main-block.
            end.
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U
      or
      when 'удаление':U then do:
        for first buf_chk-pay share-lock where
                buf_chk-pay.doc-code = p-doc-code
            and buf_chk-pay.line-num = p-line-num,
            first buf_libthpos_chk-pay where
                buf_libthpos_chk-pay.doc-code = p-doc-code
            and buf_libthpos_chk-pay.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-pay then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code <> buf_chk-pay.pay-code
        or p-curr-code <> buf_chk-pay.curr-code
        then do:
          v-err-mess = substitute("Для уже имеющейся строки оплат чека (&1) нельзя изменить код типа касс. платеж и код валюты - были &2 &3"
                                      , p-line-num
                                      , buf_chk-pay.pay-code
                                      , buf_chk-pay.curr-code
                                      ).
                  undo main-block, retry main-block.
        end.
        if p-mode = 'ИЗМЕНЕНИЕ':U then do:
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = buf_libthpos_chk-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
        end.
        assign
        v-tot-sum  = p-tot-sum
        .
        if buf_libthpos_chk-pay.curr-code = 0 then do:
          assign
          v-tot-rubl = p-tot-sum
          v-tot-base = (if libthpos_context.base-code = 0
                        then v-tot-rubl
                        else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
        assign
        v-bank-rate = buf_libthpos_chk-pay.bank-rate
        v-bank-scale = buf_libthpos_chk-pay.bank-scale
        v-cash-rate = buf_libthpos_chk-pay.cash-rate
        v-exch-date = buf_libthpos_chk-pay.b-exch-date
        v-exch-time = buf_libthpos_chk-pay.b-exch-time
        v-exch-rate = buf_libthpos_chk-pay.b-exch-rate
        v-exch-scale =  buf_libthpos_chk-pay.b-exch-scale
        v-calc-rate = buf_libthpos_chk-pay.b-calc-rate
        v-is-cash = buf_libthpos_chk-pay.is-cash
        v-frpay-code = buf_libthpos_chk-pay.frpay-code
        v-get-qnty-method = buf_libthpos_chk-pay.get-qnty-method
        v-wth-code = buf_libthpos_chk-pay.wth-code
        v-src-val = buf_libthpos_chk-pay.src-val
        .
      end.
    end case.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create buf_chk-pay.
      create buf_libthpos_chk-pay.
      assign
      buf_chk-pay.doc-code = p-doc-code
      libthpos_chk-context.lnp = libthpos_chk-context.lnp + 1
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      buf_chk-pay.line-num = libthpos_chk-context.lnp
      buf_libthpos_chk-pay.recalc-line-num = buf_chk-pay.line-num
      buf_chk-pay.time-oper = v-time
      buf_chk-pay.pay-code = p-cdpay-code
      buf_chk-pay.curr-code = p-curr-code
      buf_chk-pay.pass-pay = 0
      buf_chk-pay.line-type  = ''
      buf_chk-pay.pay-card = ""
      buf_chk-pay.obj-type = libthpos_context.obj-type
      buf_chk-pay.obj-code = libthpos_context.obj-code
      buf_chk-pay.bank-rate = 1
      buf_chk-pay.bank-scale = 1
      buf_chk-pay.cash-rate = 1
      buf_chk-pay.is-error = no
      buf_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
      buf_chk-pay.line-type = ""
      buf_chk-pay.out-code = ?
      buf_chk-pay.tot-sum = 0
      buf_chk-pay.pass-pay = p-pass-pay
      buf_chk-pay.par-code = p-par-code
      buf_chk-pay.src-val = v-src-val
      buf_chk-pay.wth-code = v-wth-code
      buf_libthpos_chk-pay.par-rate = v-par-rate
      .
      buffer-copy buf_chk-pay to buf_libthpos_chk-pay.
    end.
    find first buf_libthpos_cash-counter where
              buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
          and buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
          and buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
          and buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
              no-error.
    if not available buf_libthpos_cash-counter then do:
      create buf_libthpos_cash-counter.
      assign
      buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
      buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
      buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
      buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
      .
    end.
    assign
    buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum - buf_chk-pay.tot-sum
    buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base - buf_libthpos_chk-pay.tot-base
    buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl - buf_libthpos_chk-pay.tot-rubl
    buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty - buf_chk-pay.src-qnty
    buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines - 1
    libthpos_context.pre-cash-counter = (if buf_libthpos_cash-counter.is-cash
                                        then (libthpos_context.pre-cash-counter -
                                                (if libthpos_context.r-b = 'rubl':U
                                                then buf_libthpos_chk-pay.tot-rubl
                                                else buf_libthpos_chk-pay.tot-base)
                                              )
                                              else libthpos_context.pre-cash-counter)
    .
    assign
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-pay.tot-sum * buf_libthpos_chk-pay.cash-rate
    .
    assign
    buf_libthpos_chk-pay.is-cash = v-is-cash
    buf_libthpos_chk-pay.get-qnty-method = v-get-qnty-method
    buf_libthpos_chk-pay.par-rate = v-par-rate
    buf_libthpos_chk-pay.wth-code = v-wth-code
    buf_libthpos_chk-pay.frpay-code = v-frpay-code
    buf_libthpos_chk-pay.tot-base = v-tot-base
    buf_libthpos_chk-pay.tot-rubl = v-tot-rubl
    buf_libthpos_chk-pay.tot-sum = v-tot-sum
    buf_libthpos_chk-pay.bank-rate = v-bank-rate
    buf_libthpos_chk-pay.bank-scale = v-bank-scale
    buf_libthpos_chk-pay.cash-rate = v-cash-rate
    buf_libthpos_chk-pay.b-exch-date = v-exch-date
    buf_libthpos_chk-pay.b-exch-time = v-exch-time
    buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
    buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
    buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
    buf_chk-pay.tot-sum = v-tot-sum
    buf_chk-pay.src-qnty = p-src-qnty
    buf_chk-pay.bank-rate = v-bank-rate
    buf_chk-pay.bank-scale = v-bank-scale
    buf_chk-pay.cash-rate = v-cash-rate
    buf_chk-pay.pass-pay = p-pass-pay
    buf_libthpos_chk-pay.pass-pay = p-pass-pay
    buf_chk-pay.time-oper = v-time
    buf_chk-pay.line-sign = (if libthpos_chk-context.chk-type = integer('1':U)
                              then (buf_chk-pay.tot-sum >= 0)
                              else (buf_chk-pay.tot-sum <= 0)
                        )
    .
    assign
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-pay.tot-sum * buf_libthpos_chk-pay.cash-rate
    .
    assign
    buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum + buf_chk-pay.tot-sum
    buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base + buf_libthpos_chk-pay.tot-base
    buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl + buf_libthpos_chk-pay.tot-rubl
    buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines + 1
    buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty + buf_chk-pay.src-qnty
    libthpos_context.pre-cash-counter = (if buf_libthpos_chk-pay.is-cash
                                        then  (libthpos_context.pre-cash-counter +
                                            (if libthpos_context.r-b = 'rubl':U
                                            then buf_libthpos_chk-pay.tot-rubl
                                            else buf_libthpos_chk-pay.tot-base)
                                            )
                                            else libthpos_context.pre-cash-counter)
    .
    assign
    libthpos_chk-context.step =  if libthpos_chk-context.step = 0
                                then 3
                                else libthpos_chk-context.step
    .
    if p-mode = 'удаление':U
    and buf_chk-pay.tot-sum = 0 then do:
      delete buf_chk-pay.
      delete buf_libthpos_chk-pay.
      find last buf2_libthpos_chk-pay where
              buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code use-index ln no-error.
      assign
      libthpos_chk-context.lnp = (if available buf_libthpos_chk-pay
                                  then buf_libthpos_chk-pay.line-num
                                  else 0)
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      .
      if libthpos_chk-context.lnp = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = 3
                                    then 0
                                    else libthpos_chk-context.step.
      end.
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    if available buf_libthpos_chk-pay then do:
      assign
      buf_libthpos_chk-pay.b-exch-date = v-exch-date
      buf_libthpos_chk-pay.b-exch-time = v-exch-time
      buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
      buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
      buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
      .
    end.
    assign
    p-frpay-code = v-frpay-code
    p-tot-sum = v-tot-sum
    p-tot-rubl = v-tot-rubl
    p-tot-base = v-tot-base
    p-get-qnty-method = v-get-qnty-method
    p-setted = yes
    .
    if available buf_libthpos_chk-pay then do:
      run printbuffer in this-procedure ( input (buffer buf_chk-pay:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-pay:handle)).
    end.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_getcheck :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-close-check as logical no-undo .
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define variable v-doc-code as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    session:set-wait-state("").
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.with-atr1-sum < libthpos_chk-context.change-sum
    and libthpos_chk-context.direction > 0
    and lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '8,108,208':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '201,206,208,301,306':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,36':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,36':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '12,13,40,112,113':U) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - Сумма сдачи (&2) в чеке превышает сумму платежей (&3), на которые сдача разрешена"
                                            , libthpos_chk-context.change-sum
                                            , libthpos_chk-context.with-atr1-sum
                                            , p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.manual-discnt-sum >= libthpos_chk-context.src-tot-doc
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - сумма всех ручных скидок &2 >= суммы брутто &3"
                                                , p-doc-code
                                                , libthpos_chk-context.manual-discnt-sum
                                                , libthpos_chk-context.src-tot-doc
                                                ).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - сумма скидок &2 >= суммы брутто &3"
                                                , p-doc-code
                                                , libthpos_chk-context.discnt
                                                , libthpos_chk-context.src-tot-doc
                                                ).
          undo main-block, retry main-block.
    end.
    if libthpos_context.salesman-mandatory > 0
    and lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '8,108,208':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '201,206,208,301,306':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,36':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '12,13,40,112,113':U) = 0
    then do:
      for each buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code:
        if buf_libthpos_chk-gds.salesman = 0
        or buf_libthpos_chk-gds.salesman = ? then do:
          v-err-mess = substitute("Нельзя закрыть чек &1 - в одной или нескольких строках чека НЕ УКАЗАН ПРОДАВЕЦ").
          undo main-block, retry main-block.
        end.
      end.
    end.
    if libthpos_chk-context.getcheck > 0 then do:
      run libthpos_prepare-getcheck in this-procedure ( input p-doc-code) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Ошибки при постобработке чека = &1&2&3&2&4"
                                                , p-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value
                                                ).
        undo main-block, retry main-block.
      end.
    end.
    libthpos_chk-context.getcheck = libthpos_chk-context.getcheck + 1.
    if libthpos_chk-context.step < 3
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,11,13,40,114,115,116,136,,117,111,113,201,206,208,301,306':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '8,108,208':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '201,206,208,301,306':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) = 0
    and lookup(string(libthpos_chk-context.chk-type), '14,15,16,17,36':U) = 0
    and libthpos_chk-context.chk-type  <> integer('12':U)
    and libthpos_chk-context.chk-type  <> integer('112':U)
    then do:
      v-err-mess = substitute("Чек &1 еще не закончен", p-doc-code).
      undo main-block, retry main-block.
    end.
    v-doc-code = libthpos_chk-context.doc-code.
    v-chk-type = libthpos_chk-context.chk-type.
    if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0 then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getwcheck in g#libchkvl
  (input  buffer libthpos_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  p-close-check
  ,input  yes
  ,input  libthpos_chk-context.netto
  ,input-output v-doc-code
    ) no-error .
    end.
    else do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer libthpos_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  p-close-check
  ,input  yes
  ,input  libthpos_chk-context.netto
  ,input  libthpos_chk-context.lng
  ,input  libthpos_chk-context.tot-discnt + libthpos_chk-context.pay-discnt
  ,input  libthpos_chk-context.discnt-id
  ,input-output v-doc-code
    ) no-error .
    end.
    if error-status:error then do:
      v-err-mess = substitute("Ошибка при валидации чека &1&2&3&2&4"
                                              , p-doc-code
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    if p-close-check then do:
      run libthpos_write-cash-counter in this-procedure no-error.
      if error-status:error then do:
        v-err-mess = substitute("&1&2&3", error-status:get-message(1), chr(10), return-value ).
        undo main-block, retry main-block.
      end.
      release locked_chk-doc no-error.
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context.
      end.
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context.
        if available libthpos_chk-context then do:
          run libthpos_print-dataset in this-procedure ( input no).
          delete libthpos_chk-context.
        end.
      end.
    end.
    else do:
    end.
    dataset libthpos_receipt:accept-changes.
    if p-close-check = yes then do:
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                      , input no).
    end.
    session:set-wait-state("").
  end.
end.
if p-close-check then do:
  run libthpos_process-sale in this-procedure ( input v-chk-type
                                              ,input v-doc-code) no-error.
end.
end procedure.
procedure libthpos_close-check :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-chk-num as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc share-lock where
            buf_chk-doc.doc-code = p-doc-code.
    assign
    buf_chk-doc.office = trim(replace(replace(buf_chk-doc.office, 'готов':U, ''), chr(44) + chr(44), chr(44)), chr(44))
    buf_chk-doc.chk-num  = p-chk-num
    v-chk-type = buf_chk-doc.chk-type
    v-doc-code = buf_chk-doc.doc-code
    .
    run libthpos_write-cash-counter in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3", error-status:get-message(1), chr(10), return-value ).
      undo main-block, retry main-block.
    end.
    release buf_chk-doc no-error.
    release locked_chk-doc no-error.
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context.
      if available libthpos_chk-context then do:
        run libthpos_print-dataset in this-procedure ( input no).
        delete libthpos_chk-context.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.
end procedure.
procedure libthpos_annulate :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-chk-num as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    assign
    v-chk-type = (if lookup(string(libthpos_chk-context.chk-type), '201,206,208,301,306':U) > 0
                  then integer('208':U)
                  else integer('8':U)
                  )
    libthpos_chk-context.prev-chk-type = libthpos_chk-context.chk-type
    locked_chk-doc.prev-chk-type = locked_chk-doc.chk-type
    libthpos_chk-context.chk-type = v-chk-type
    locked_chk-doc.chk-type = v-chk-type
    locked_chk-doc.chk-num  = p-chk-num
    v-doc-code = locked_chk-doc.doc-code
    .
    run libthpos_getcheck in this-procedure ( input p-doc-code
                                              , input yes
                                              ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3"
                                              , error-status:get-message(1)
                                              , chr(10)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.
end procedure.
procedure libthpos_delete-chk-doc :
define input  parameter p-doc-code as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '2,3,4,5,7':U) > 0 then do:
      v-err-mess = substitute("Нельзя удалить чек МЦ").
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '201,206,208,301,306':U) > 0 then do:
      v-err-mess = substitute("Нельзя удалить чек с типом &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc where
              buf_chk-doc.doc-code = p-doc-code.
    delete buf_chk-doc no-error.
    if error-status:error then do:
      release buf_chk-doc.
    end.
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context.
      if available libthpos_chk-context then do:
        run libthpos_print-dataset in this-procedure ( input no).
        delete libthpos_chk-context.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
end procedure.
procedure libthpos_postpone :
define input  parameter p-doc-code as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-err-mess as character no-undo .
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if not (libthpos_chk-context.chk-type = integer('1':U)
            or
            libthpos_chk-context.chk-type = integer('6':U)) then do:
      v-err-mess = substitute("Нельзя отложить чеки с типом &1", libthpos_chk-context.chk-type ).
      undo main-block, retry main-block.
    end.
    assign
    v-chk-type = (if libthpos_chk-context.chk-type = integer('1':U)
                  then integer('201':U)
                  else integer('206':U)
                  )
    libthpos_chk-context.chk-type = v-chk-type
    locked_chk-doc.chk-type = v-chk-type
    .
    if not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code)
    then do:
      v-err-mess = substitute("Нельзя отложить чек &1 - в чеке нет ни одной строки"
                             , p-doc-code).
      undo main-block, retry main-block.
    end.
    run libthpos_getcheck in this-procedure ( input p-doc-code
                                            , input yes
                                            ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3"
                                              , error-status:get-message(1)
                                              , chr(10)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
end procedure.
procedure libthpos_close-postpone :
define input parameter p-doc-code as character no-undo .
define input parameter p-postpone-doc-code as character no-undo .
define input parameter p-close-mode as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer bufp_chk-doc for ub.chk-doc.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    find first bufp_chk-doc exclusive-lock where
            bufp_chk-doc.doc-code = p-postpone-doc-code no-error no-wait.
    if not available bufp_chk-doc
    and not locked(bufp_chk-doc)
    then do:
      v-err-mess = substitute("Не найден чек &1", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if locked(bufp_chk-doc) then do:
      v-err-mess = substitute("Занят чек &1", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(bufp_chk-doc.chk-type), '201,206,208,301,306':U) = 0 then do:
      v-err-mess = substitute("Чек &1 не является отложенным чеком, операция неприменима", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if bufp_chk-doc.chk-type = integer('208':U) then do:
      v-err-mess = substitute("Чек &1 аннулирован, операция неприменима", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    v-chk-type = bufp_chk-doc.chk-type.
    v-doc-code = bufp_chk-doc.doc-code.
    case p-close-mode:
      when 1 then do:
        assign
        bufp_chk-doc.chk-type = bufp_chk-doc.chk-type + 100
        bufp_chk-doc.tot-doc = 0
        bufp_chk-doc.netto = 0
        bufp_chk-doc.discnt = 0
        bufp_chk-doc.sub-discnt = 0
        bufp_chk-doc.doc-qnty = 0
        bufp_chk-doc.ps = substitute(">>&1", p-doc-code)
        .
      end.
      when 0 then do:
        assign
        bufp_chk-doc.chk-type = integer('208':U)
        bufp_chk-doc.tot-doc = 0
        bufp_chk-doc.netto = 0
        bufp_chk-doc.discnt = 0
        bufp_chk-doc.sub-discnt = 0
        bufp_chk-doc.doc-qnty = 0
        .
      end.
    end case.
    dataset libthpos_receipt:accept-changes.
    run libthpos_print-dataset in this-procedure ( input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.
end procedure.
procedure libthpos_annu-lost-check :
define input parameter p-doc-code as character no-undo .
define variable v-lng as integer no-undo .
define variable v-discnt-id as integer no-undo .
define variable v-doc-code as character no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context
    and libthpos_chk-context.doc-code = p-doc-code
    then do:
      v-err-mess = substitute("В данный момент Вы работаете с чеком &1, операция аннуляции сбойного чека неприменима").
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = p-doc-code no-error no-wait.
    if not available buf_chk-doc
    and not locked(buf_chk-doc)
    then do:
      v-err-mess = substitute("Не найден чек &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if locked(buf_chk-doc) then do:
      v-err-mess = substitute("Занят чек &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if buf_chk-doc.chk-type = integer('208':U)
    or buf_chk-doc.chk-type = integer('8':U)
    then do:
      v-err-mess = substitute("Чек &1 уже аннулирован, операция неприменима", p-doc-code).
      undo main-block, retry main-block.
    end.
    if trim(replace(replace(buf_chk-doc.office, 'у':U, ''), 'т':U, ''), chr(44)) = ''
    and buf_chk-doc.correct = yes then do:
      v-err-mess = substitute("Чек &1 уже прошел валидацию, операция неприменима", p-doc-code).
      undo main-block, retry main-block.
    end.
    find last buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code no-error.
    find last buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
        and buf_chk-discnt.record-type = 0  no-error.
    assign
    v-lng = (if available buf_chk-gds
            then buf_chk-gds.line-num
            else 0)
    v-discnt-id = (if available buf_chk-discnt
                  then buf_chk-discnt.discnt-id
                  else 0)
    .
    if lookup(string(buf_chk-doc.chk-type), '201,206,208,301,306':U) > 0 then do:
      assign
      buf_chk-doc.chk-type = integer('208':U)
      .
    end.
    else do:
      assign
      buf_chk-doc.chk-type = integer('8':U)
      .
    end.
    v-doc-code = buf_chk-doc.doc-code.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer libthpos_context:handle
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  yes
  ,input  yes
  ,input  0
  ,input  v-lng
  ,input  0
  ,input  v-discnt-id
  ,input-output v-doc-code
    ) no-error .
    if error-status:error then do:
      v-err-mess = substitute("Ошибка при валидации чека &1&2&3&2&4"
                                              , p-doc-code
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_print-dataset in this-procedure ( input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end.
end.
end procedure.
procedure libthpos_write-cash-counter private:
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define variable v-err-mess as character no-undo .
define variable v-all-counter-base as decimal no-undo .
define variable v-all-counter-rubl as decimal no-undo .
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    for each buf_libthpos_cash-counter
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if lookup(string(libthpos_chk-context.chk-type), '8,108,208':U) > 0 then do:
        assign
        buf_libthpos_cash-counter.pre-tot-sum = 0
        buf_libthpos_cash-counter.pre-tot-rubl = 0
        buf_libthpos_cash-counter.pre-tot-base = 0
        buf_libthpos_cash-counter.pre-tot-lines = 0
        buf_libthpos_cash-counter.pre-doc-qnty = 0
        .
      end.
      else do:
        assign
        buf_libthpos_cash-counter.tot-sum = buf_libthpos_cash-counter.tot-sum + buf_libthpos_cash-counter.pre-tot-sum
        buf_libthpos_cash-counter.pre-tot-sum = 0
        buf_libthpos_cash-counter.tot-rubl = buf_libthpos_cash-counter.tot-rubl + buf_libthpos_cash-counter.pre-tot-rubl
        buf_libthpos_cash-counter.pre-tot-rubl = 0
        buf_libthpos_cash-counter.tot-base = buf_libthpos_cash-counter.tot-base + buf_libthpos_cash-counter.pre-tot-base
        buf_libthpos_cash-counter.pre-tot-base = 0
        buf_libthpos_cash-counter.tot-lines = buf_libthpos_cash-counter.tot-lines + buf_libthpos_cash-counter.pre-tot-lines
        buf_libthpos_cash-counter.pre-tot-lines = 0
        buf_libthpos_cash-counter.doc-qnty = buf_libthpos_cash-counter.doc-qnty + buf_libthpos_cash-counter.pre-doc-qnty
        buf_libthpos_cash-counter.pre-doc-qnty = 0
        .
      end.
      find first buf_inkas-pay-wth where
                buf_inkas-pay-wth.inkas-code = ''
            and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
            and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
            and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
            and buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
            and buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
            and buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
            and buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
            and buf_inkas-pay-wth.cashier = 0
            and buf_inkas-pay-wth.chk-type = 0
            no-error.
      if not available buf_inkas-pay-wth then do:
        create buf_inkas-pay-wth.
        assign
        buf_inkas-pay-wth.inkas-code = ''
        buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
        buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
        buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
        buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
        buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
        buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
        buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
        buf_inkas-pay-wth.par-val = buf_libthpos_cash-counter.par-val
        buf_inkas-pay-wth.cashier = 0
        buf_inkas-pay-wth.chk-type = 0
        buf_inkas-pay-wth.doc-qnty = 0
        .
      end.
      assign
      buf_inkas-pay-wth.tot-sum = buf_libthpos_cash-counter.tot-sum
      buf_inkas-pay-wth.tot-base = buf_libthpos_cash-counter.tot-base
      buf_inkas-pay-wth.tot-rubl = buf_libthpos_cash-counter.tot-rubl
      buf_inkas-pay-wth.tot-lines = buf_libthpos_cash-counter.tot-lines
      buf_inkas-pay-wth.doc-qnty = buf_libthpos_cash-counter.doc-qnty
      v-all-counter-base = v-all-counter-base + buf_inkas-pay-wth.tot-base
      v-all-counter-rubl = v-all-counter-rubl + buf_inkas-pay-wth.tot-rubl
      .
    end .
    assign
    libthpos_context.cash-counter = libthpos_context.cash-counter + libthpos_context.pre-cash-counter
    libthpos_context.pre-cash-counter = 0
    .
    find first buf_inkas-pay-wth where
              buf_inkas-pay-wth.inkas-code = ''
          and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
          and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
          and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
          and buf_inkas-pay-wth.pay-code = 0
          and buf_inkas-pay-wth.curr-code = 0
          and buf_inkas-pay-wth.wth-code = 0
          and buf_inkas-pay-wth.par-code = 0
          and buf_inkas-pay-wth.cashier = 0
          and buf_inkas-pay-wth.chk-type = 0
          no-error.
    if not available buf_inkas-pay-wth then do:
      create buf_inkas-pay-wth.
      assign
      buf_inkas-pay-wth.inkas-code = ''
      buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
      buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
      buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
      buf_inkas-pay-wth.pay-code = 0
      buf_inkas-pay-wth.curr-code = 0
      buf_inkas-pay-wth.wth-code = 0
      buf_inkas-pay-wth.par-code = 0
      buf_inkas-pay-wth.par-val = 0
      buf_inkas-pay-wth.cashier = 0
      buf_inkas-pay-wth.chk-type = 0
      .
    end.
    assign
    buf_inkas-pay-wth.tot-rubl = v-all-counter-rubl
    buf_inkas-pay-wth.tot-base = v-all-counter-base
    .
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_clear-cash-counter:
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define variable v-all-counter-base as decimal no-undo .
define variable v-all-counter-rubl as decimal no-undo .
define variable v-err-mess as character no-undo .
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context then do:
      v-err-mess = substitute("Выставлен контекст чека - операция обнуления невозможна").
      undo main-block, retry main-block.
    end.
    for each buf_libthpos_cash-counter
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if buf_libthpos_cash-counter.is-cash then
      assign
      buf_libthpos_cash-counter.tot-sum = 0
      buf_libthpos_cash-counter.pre-tot-sum = 0
      buf_libthpos_cash-counter.tot-rubl = 0
      buf_libthpos_cash-counter.pre-tot-rubl = 0
      buf_libthpos_cash-counter.tot-base = 0
      buf_libthpos_cash-counter.pre-tot-base = 0
      buf_libthpos_cash-counter.tot-lines = 0
      buf_libthpos_cash-counter.pre-tot-lines = 0
      buf_libthpos_cash-counter.doc-qnty = 0
      buf_libthpos_cash-counter.pre-doc-qnty = 0
      .
      find first buf_inkas-pay-wth where
                buf_inkas-pay-wth.inkas-code = ''
            and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
            and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
            and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
            and buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
            and buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
            and buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
            and buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
            and buf_inkas-pay-wth.cashier = 0
            and buf_inkas-pay-wth.chk-type = 0
            no-error.
      if not available buf_inkas-pay-wth then do:
        create buf_inkas-pay-wth.
        assign
        buf_inkas-pay-wth.inkas-code = ''
        buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
        buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
        buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
        buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
        buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
        buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
        buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
        buf_inkas-pay-wth.par-val = buf_libthpos_cash-counter.par-val
        buf_inkas-pay-wth.cashier = 0
        buf_inkas-pay-wth.chk-type = 0
        buf_inkas-pay-wth.doc-qnty = 0
        .
      end.
      assign
      buf_inkas-pay-wth.tot-sum = buf_libthpos_cash-counter.tot-sum
      buf_inkas-pay-wth.tot-base = buf_libthpos_cash-counter.tot-base
      buf_inkas-pay-wth.tot-rubl = buf_libthpos_cash-counter.tot-rubl
      buf_inkas-pay-wth.tot-lines = buf_libthpos_cash-counter.tot-lines
      buf_inkas-pay-wth.doc-qnty = buf_libthpos_cash-counter.doc-qnty
      v-all-counter-base = v-all-counter-base + buf_inkas-pay-wth.tot-base
      v-all-counter-rubl = v-all-counter-rubl + buf_inkas-pay-wth.tot-rubl
      .
    end .
    assign
    libthpos_context.cash-counter = 0
    libthpos_context.pre-cash-counter = 0
    .
    find first buf_inkas-pay-wth where
              buf_inkas-pay-wth.inkas-code = ''
          and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
          and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
          and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
          and buf_inkas-pay-wth.pay-code = 0
          and buf_inkas-pay-wth.curr-code = 0
          and buf_inkas-pay-wth.wth-code = 0
          and buf_inkas-pay-wth.par-code = 0
          and buf_inkas-pay-wth.cashier = 0
          and buf_inkas-pay-wth.chk-type = 0
          no-error.
    if not available buf_inkas-pay-wth then do:
      create buf_inkas-pay-wth.
      assign
      buf_inkas-pay-wth.inkas-code = ''
      buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
      buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
      buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
      buf_inkas-pay-wth.pay-code = 0
      buf_inkas-pay-wth.curr-code = 0
      buf_inkas-pay-wth.wth-code = 0
      buf_inkas-pay-wth.par-code = 0
      buf_inkas-pay-wth.par-val = 0
      buf_inkas-pay-wth.cashier = 0
      buf_inkas-pay-wth.chk-type = 0
      .
    end.
    assign
    buf_inkas-pay-wth.tot-rubl = v-all-counter-rubl
    buf_inkas-pay-wth.tot-base = v-all-counter-base
    .
  end.
end.
end procedure.
procedure libthpos_create-flddf :
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define buffer buf_libthpos_flddf for  libthpos_flddf .
define variable v-err-mess as character no-undo .
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    assign
    v-bh0[1] = (buffer libthpos_context:handle)
    v-bh[1] = v-bh0[1]
    v-bh0[2] = (buffer libthpos_chk-context:handle)
    v-bh[2] = v-bh0[2]
    v-bh0[3] = (buffer libthpos_chk-doc:handle)
    v-bh[3] = v-bh0[3]
    v-bh0[4] = (buffer libthpos_chk-gds:handle)
    v-bh[4] = v-bh0[4]
    v-bh0[5] = (buffer libthpos_chk-pay:handle)
    v-bh[5] = v-bh0[5]
    v-bh0[6] = (buffer libthpos_chk-discnt:handle)
    v-bh[6] = v-bh0[6]
    .
    assign
    buffer libthpos_chk-context:handle:buffer-field("chk-date"):help = 'doc_chk-date':U
    buffer libthpos_chk-context:handle:buffer-field("chk-time"):help = 'doc_chk-time':U
    buffer libthpos_chk-gds:handle:buffer-field("line-num"):help = 'gline_line-num':U
    buffer libthpos_chk-pay:handle:buffer-field("line-num"):help = 'pline_line-num':U
    buffer libthpos_chk-pay:handle:buffer-field("tot-sum"):help = 'pline_tot-sum':U
    buffer libthpos_chk-gds:handle:buffer-field("src-qnty"):help = 'gline_src-qnty':U
    buffer libthpos_chk-gds:handle:buffer-field("src-price"):help = 'gline_src-price':U
    buffer libthpos_chk-gds:handle:buffer-field("src-code"):help = 'gline_src-code':U
    buffer libthpos_chk-gds:handle:buffer-field("b-code"):help = 'gline_b-code':U
    buffer libthpos_chk-gds:handle:buffer-field("src-sum"):help = 'gline_src-base':U
    buffer libthpos_chk-gds:handle:buffer-field("src-discnt"):help = 'gline_src-discnt':U
    buffer libthpos_chk-discnt:handle:buffer-field("discnt-value-pcnt"):help = 'dline_discnt-value-pcnt':U
    buffer libthpos_chk-discnt:handle:buffer-field("discnt-value-abs"):help = 'dline_discnt-value-abs':U
    buffer libthpos_chk-discnt:handle:buffer-field("value-type"):help = 'dline_value-type':U
    buffer libthpos_chk-discnt:handle:buffer-field("templ-rl-root"):help = 'dline_templ-rl-root':U
    buffer libthpos_chk-discnt:handle:buffer-field("object-sum"):help = 'dline_object-sum':U
    buffer libthpos_chk-discnt:handle:buffer-field("rule-num"):help = 'dline_rule-num':U
    .
    do v-ii = 1 to 6:
      do v-jj = 1 to v-bh[v-ii]:num-fields:
        v-bh[v-ii]:buffer-field(v-jj):private-data  = v-bh[v-ii]:buffer-field(v-jj):help.
        if v-bh[v-ii]:buffer-field(v-jj):private-data <> ?
        and v-bh[v-ii]:buffer-field(v-jj):private-data <> '' then do:
          find first buf_libthpos_flddf where
                    buf_libthpos_flddf.fld-df = v-bh[v-ii]:buffer-field(v-jj):private-data no-error.
          if not available buf_libthpos_flddf then do:
            create buf_libthpos_flddf.
            assign
            buf_libthpos_flddf.fld-df = v-bh[v-ii]:buffer-field(v-jj):private-data
            buf_libthpos_flddf.table-name_ = v-bh[v-ii]:table
            buf_libthpos_flddf.name_ = v-bh[v-ii]:name
            buf_libthpos_flddf.buffer_ = v-bh[v-ii]
            buf_libthpos_flddf.field-name_ = v-bh[v-ii]:buffer-field(v-jj):name
            buf_libthpos_flddf.buffer-field_ = v-bh[v-ii]:buffer-field(v-jj)
            buf_libthpos_flddf.table-no = v-ii
            .
          end.
          else do:
            message
            substitute("Неверно настроены регистры значений для расчета скидок и бонусов&1"  +
                        "регистр &2 для расчета скидок определен дважды&1" +
                        "обратитесь к администратору"
                        , chr(10)
                        , v-bh[v-ii]:buffer-field(v-jj):private-data
                      )
            view-as alert-box error.
            return error.
          end.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure libthpos_set-gds-manual-discnt :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-value-type as integer no-undo .
define input  parameter p-discnt-value as decimal no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define input-output parameter p-src-discnt-sum as decimal no-undo .
define input-output parameter p-src-sum as decimal no-undo .
define input-output parameter p-src-sum-netto as decimal no-undo .
define variable v-discnt as decimal no-undo .
define variable v-pcnt as decimal no-undo .
define variable v-discnt-sum as decimal no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    find first buf_libthpos_chk-gds where buf_libthpos_chk-gds.line-num = p-line-num.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) > 0
    or lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека для задания скидки = &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.lng < p-line-num
    or not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = p-doc-code
                      and libthpos_chk-gds.line-num = p-line-num) then do:
      v-err-mess = substitute("Неверный номер товарной строки для начисления скидки = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not ( p-value-type = integer('1':U)
            or
            p-value-type = integer('10':U)) then do:
      v-err-mess = substitute("Неверный тип значения скидки = &1", p-value-type).
      undo main-block, retry main-block.
    end.
    if libthpos_context.manual-discnt = 0 then do:
      v-err-mess = substitute("Запрещены ручные скидки на данной кассе/магазине").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= 3 then do:
      v-err-mess = substitute("Уже есть строки оплаты").
      undo main-block, retry main-block.
    end.
    for first buf_chk-gds share-lock where
            buf_chk-gds.doc-code = p-doc-code
        and buf_chk-gds.line-num = p-line-num,
        first buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = p-doc-code
        and  buf_libthpos_chk-gds.line-num = p-line-num :
      leave.
    end.
    if buf_libthpos_chk-gds.without-gds-discnt > 0 then do:
      v-err-mess = substitute("На товаре стоит флаг запрета товарных скидок").
      undo main-block, retry main-block.
    end.
    case p-value-type:
      when integer('1':U) then do:
        if p-discnt-value > 100 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1 (>= 100%)"
                                                  , p-discnt-value
                                                  ).
          undo main-block, retry main-block.
        end.
        assign
        v-discnt = buf_libthpos_chk-gds.src-price-netto *  p-discnt-value / 100
        v-pcnt = p-discnt-value
        v-discnt-sum = v-discnt *  buf_libthpos_chk-gds.src-qnty
        .
      end.
      when integer('10':U) then do:
        if buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto - p-discnt-value  <= 0 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1&2Сумма по строке без этой скидки =&3"
                                                    , p-discnt-value
                                                    , chr(10)
                                                    ,(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto)
                                                    ).
          undo main-block, retry main-block.
        end.
        assign
        v-discnt = p-discnt-value / buf_libthpos_chk-gds.src-qnty
        v-pcnt = p-discnt-value / buf_libthpos_chk-gds.src-price-netto * 100  / buf_libthpos_chk-gds.src-qnty
        v-discnt-sum = p-discnt-value
        .
      end.
    end case.
    if buf_libthpos_chk-gds.manual-discnt-id = 0 then do:
      create buf_libthpos_chk-discnt.
      assign
      buf_libthpos_chk-discnt.doc-code = p-doc-code
      buf_libthpos_chk-discnt.record-type = 0
      buf_libthpos_chk-discnt.line-type = integer('1':U)
      buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.discnt-id + 1
      libthpos_chk-context.discnt-id = libthpos_chk-context.discnt-id + 1
      buf_libthpos_chk-discnt.line-num = p-line-num
      libthpos_chk-context.lnd = libthpos_chk-context.lnd + 1
      buf_libthpos_chk-discnt.pay-desk = libthpos_context.cash-num
      buf_libthpos_chk-discnt.obj-type = libthpos_context.obj-type
      buf_libthpos_chk-discnt.obj-code = libthpos_context.obj-code
      buf_libthpos_chk-discnt.chk-date = libthpos_chk-context.chk-date
      buf_libthpos_chk-discnt.chk-time = libthpos_chk-context.chk-time
      buf_libthpos_chk-discnt.time-oper = buf_libthpos_chk-gds.time-oper
      buf_libthpos_chk-discnt.src-d-card = buf_libthpos_chk-gds.src-d-card
      buf_libthpos_chk-discnt.kateg = libthpos_chk-context.category
      buf_libthpos_chk-discnt.rank = 999999999
      buf_libthpos_chk-discnt.pass-discnt = integer('1':U)
      buf_libthpos_chk-discnt.rule-num = 0
      buf_libthpos_chk-discnt.templ-rl-root = 0
      buf_libthpos_chk-discnt.discnt-type = integer('13':U)
      buf_libthpos_chk-discnt.discnt-role = ''
      buf_libthpos_chk-discnt.object-line-num =  p-line-num
      buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price-netto
      buf_libthpos_chk-gds.manual-discnt-id = buf_libthpos_chk-discnt.discnt-id
      .
    end.
    else do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = p-line-num
        and  buf_libthpos_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = p-line-num
        and  buf_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id:
        leave.
      end.
    end.
    assign
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r - buf_libthpos_chk-gds.r-sum
    buf_chk-gds.src-discnt = buf_chk-gds.src-discnt - buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-gds.src-discnt = buf_libthpos_chk-gds.src-discnt - buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price-netto + buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-discnt.object-qnty =  buf_libthpos_chk-gds.src-qnty
    buf_libthpos_chk-discnt.object-sum =  buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto
    buf_libthpos_chk-discnt.discnt-value-abs =  v-discnt-sum
    buf_libthpos_chk-discnt.discnt-value-pcnt =  v-pcnt
    buf_libthpos_chk-discnt.delta-discnt  =  v-discnt
    buf_libthpos_chk-discnt.value-type = p-value-type
    .
    buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
    assign
    buf_chk-gds.src-discnt = buf_chk-gds.src-discnt + v-discnt
    buf_libthpos_chk-gds.src-discnt = buf_libthpos_chk-gds.src-discnt + v-discnt
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price-netto - v-discnt
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * buf_libthpos_chk-gds.cli-base-rate
    buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * buf_libthpos_chk-gds.cli-base-rate
    .
    assign
    buf_libthpos_chk-gds.src-discnt-sum = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt, 2)
    buf_libthpos_chk-gds.r-sum = (buf_libthpos_chk-gds.src-qnty * (buf_libthpos_chk-gds.start-src-price - v-discnt)) -
                                (buf_libthpos_chk-gds.src-sum -  buf_libthpos_chk-gds.src-discnt-sum)
    buf_libthpos_chk-gds.manual-discnt-sum = buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-gds.manual-discnt-sum
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r + buf_libthpos_chk-gds.r-sum
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and libthpos_chk-context.direction > 0
    then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2) Возможно не стоит применять ручную скидку"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.
    if (buf_libthpos_chk-discnt.discnt-value-abs = 0.0 and buf_libthpos_chk-discnt.value-type = integer('10':U))
    or (buf_libthpos_chk-discnt.discnt-value-pcnt = 0.0 and buf_libthpos_chk-discnt.value-type = integer('1':U))
    then do:
      delete buf_libthpos_chk-discnt.
      delete buf_chk-discnt.
      buf_libthpos_chk-gds.manual-discnt-id = 0.
    end.
    assign
    libthpos_chk-context.recalc-gline-num = (if p-line-num <= libthpos_chk-context.lng
                                              then buf_libthpos_chk-gds.recalc-line-num
                                              else libthpos_chk-context.recalc-gline-num)
    p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
    p-src-sum = buf_chk-gds.src-sum
    p-src-sum-netto = p-src-sum - p-src-discnt-sum
    p-setted = yes
    p-next = ''
    .
    run libthpos_recalc-discnt in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_set-subtotal-manual-discnt :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-value-type as integer no-undo .
define input  parameter p-discnt-value as decimal no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define input-output parameter p-st-r-b as decimal no-undo .
define input-output parameter p-st-rubl as decimal no-undo .
define input-output parameter p-st-base as decimal no-undo .
define input-output parameter p-tot-doc as decimal no-undo .
define input-output parameter p-discnt as decimal no-undo .
define variable v-discnt as decimal no-undo .
define variable v-pcnt as decimal no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) > 0
    or lookup(string(libthpos_chk-context.chk-type), '6,69,96,106,169,196,206':U) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека для задания скидки = &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.lng = 0
    or not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = p-doc-code
                      ) then do:
      v-err-mess = substitute("Нет строк в чеке").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step < 2 then do:
      v-err-mess = substitute("Не был подведен итог в чеке").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= 3 then do:
      v-err-mess = substitute("Уже есть строки оплаты").
      undo main-block, retry main-block.
    end.
    if not ( p-value-type = integer('1':U)
            or
            p-value-type = integer('10':U)) then do:
      v-err-mess = substitute("Неверный тип значения скидки = &1", p-value-type).
      undo main-block, retry main-block.
    end.
    if libthpos_context.manual-discnt = 0 then do:
      v-err-mess = substitute("Запрещены ручные скидки на данной кассе/магазине").
      undo main-block, retry main-block.
    end.
    case p-value-type:
      when integer('1':U) then do:
        if  p-discnt-value >= 100 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1 (>= 100%)"
                                                    , p-discnt-value
                                                    ).
          undo main-block, retry main-block.
        end.
      end.
      when integer('10':U) then do:
        if libthpos_chk-context.st-for-discnt-r-b - p-discnt-value  <= 0 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1&2Сумма по чеку без этой скидки =&3"
                                                    , p-discnt-value
                                                    , chr(10)
                                                    ,libthpos_chk-context.st-for-discnt-r-b
                                                    ).
          undo main-block, retry main-block.
        end.
      end.
    end.
    if libthpos_chk-context.manual-discnt-id <> 0 then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id:
        assign
        libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b + buf_libthpos_chk-discnt.discnt-value-abs
        .
        leave.
      end.
    end.
    case p-value-type:
      when integer('1':U) then do:
        assign
        v-discnt = libthpos_chk-context.st-for-discnt-r-b *  p-discnt-value / 100
        v-pcnt = p-discnt-value
        .
      end.
      when integer('10':U) then do:
        assign
        v-discnt = p-discnt-value
        v-pcnt = p-discnt-value / libthpos_chk-context.st-for-discnt-r-b * 100
        .
      end.
    end case.
    if libthpos_chk-context.manual-discnt-id = 0 then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      create buf_libthpos_chk-discnt.
      assign
      buf_libthpos_chk-discnt.doc-code = p-doc-code
      buf_libthpos_chk-discnt.record-type = 0
      buf_libthpos_chk-discnt.line-type = integer('4':U)
      buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.discnt-id + 1
      libthpos_chk-context.discnt-id = libthpos_chk-context.discnt-id + 1
      buf_libthpos_chk-discnt.line-num = libthpos_chk-context.lng
      libthpos_chk-context.lnd = libthpos_chk-context.lnd + 1
      buf_libthpos_chk-discnt.pay-desk = libthpos_context.cash-num
      buf_libthpos_chk-discnt.obj-type = libthpos_context.obj-type
      buf_libthpos_chk-discnt.obj-code = libthpos_context.obj-code
      buf_libthpos_chk-discnt.chk-date = libthpos_chk-context.chk-date
      buf_libthpos_chk-discnt.chk-time = libthpos_chk-context.chk-time
      buf_libthpos_chk-discnt.time-oper = v-time
      buf_libthpos_chk-discnt.src-d-card = libthpos_chk-context.src-d-card
      buf_libthpos_chk-discnt.kateg = libthpos_chk-context.category
      buf_libthpos_chk-discnt.rank = 999999999
      buf_libthpos_chk-discnt.pass-discnt = integer('1':U)
      buf_libthpos_chk-discnt.rule-num = 0
      buf_libthpos_chk-discnt.templ-rl-root = 0
      buf_libthpos_chk-discnt.discnt-type = integer('13':U)
      buf_libthpos_chk-discnt.discnt-role = ''
      buf_libthpos_chk-discnt.object-line-num =  libthpos_chk-context.lnd
      libthpos_chk-context.manual-discnt-id = buf_libthpos_chk-discnt.discnt-id
      libthpos_chk-context.manual-discnt-ln = libthpos_chk-context.lng
      .
    end.
    else do:
      assign
      buf_libthpos_chk-discnt.line-num = libthpos_chk-context.lng
      buf_chk-discnt.line-num = libthpos_chk-context.lng
      libthpos_chk-context.manual-discnt-ln = libthpos_chk-context.lng
      .
    end.
    assign
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto +  buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-discnt.discnt-value-abs
    buf_libthpos_chk-discnt.discnt-value-abs = truncate(v-discnt, 2)
    buf_libthpos_chk-discnt.discnt-value-pcnt = v-pcnt
    buf_libthpos_chk-discnt.delta-discnt  =  v-discnt
    buf_libthpos_chk-discnt.object-qnty =  libthpos_chk-context.src-qnty
    buf_libthpos_chk-discnt.object-sum =  libthpos_chk-context.st-for-discnt-r-b
    buf_libthpos_chk-discnt.value-type = p-value-type
    .
    buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
    assign
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto  - buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-tot-discnt = buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-tot-dis-type = buf_libthpos_chk-discnt.value-type
    libthpos_chk-context.st-r-b = libthpos_rmethod(libthpos_context.rmethod-type
                                                    , libthpos_context.rmethod-coeff
                                                    , libthpos_chk-context.sub-netto)
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2)"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.
    if (buf_libthpos_chk-discnt.discnt-value-abs = 0.0 and buf_libthpos_chk-discnt.value-type = integer('10':U))
    or (buf_libthpos_chk-discnt.discnt-value-pcnt = 0.0 and buf_libthpos_chk-discnt.value-type = integer('1':U))
    then do:
      delete buf_libthpos_chk-discnt.
      delete buf_chk-discnt.
      libthpos_chk-context.manual-discnt-id = 0.
    end.
    assign
    p-st-r-b = libthpos_chk-context.st-r-b
    libthpos_chk-context.st-rubl =  (if libthpos_context.r-b = 'rubl':U
                                    or (libthpos_context.r-b = 'base':U
                                        and
                                        libthpos_context.base-code = 0)
                                      then libthpos_chk-context.st-r-b
                                      else libthpos_chk-context.st-r-b * libthpos_chk-context.a-base-rate)
    p-st-rubl = libthpos_chk-context.st-rubl
    libthpos_chk-context.st-base = (if libthpos_context.r-b = 'base':U
                                    or (libthpos_context.r-b = 'rubl':U
                                        and
                                        libthpos_context.base-code = 0)
                                    then libthpos_chk-context.st-r-b
                                    else libthpos_chk-context.st-r-b / libthpos_chk-context.a-base-rate)
    p-st-base = libthpos_chk-context.st-base
    p-tot-doc = libthpos_chk-context.src-tot-doc
    libthpos_chk-context.tot-r = libthpos_chk-context.sub-netto - libthpos_chk-context.st-r-b
    p-discnt  = libthpos_chk-context.gds-discnt + libthpos_chk-context.tot-discnt
    libthpos_chk-context.to-pay-r-b   = libthpos_chk-context.st-r-b - libthpos_chk-context.has-pay-r-b
    libthpos_chk-context.to-pay-rubl  = (if libthpos_context.r-b = 'rubl':U
                                            or (libthpos_context.r-b = 'base':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
                                        - libthpos_chk-context.has-pay-rubl
    libthpos_chk-context.all-pay-rubl =  libthpos_chk-context.st-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.to-pay-base  = (if libthpos_context.r-b = 'base':U
                                            or (libthpos_context.r-b = 'rubl':U
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
                                            - libthpos_chk-context.has-pay-base
    libthpos_chk-context.all-pay-base =  libthpos_chk-context.st-base - libthpos_chk-context.pay-discnt-base
    p-setted = yes
    p-next =
              ''
    .
    run libthpos_recalc-discnt in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_cfr :
define input  parameter p-doc-code as character no-undo .
define input parameter p-trans-type as integer no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-deckey_one as decimal no-undo .
define input parameter p-key#_one as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_cd-trans for ub.cd-trans.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
      if not available libthpos_chk-context then do:
        v-err-mess = substitute("Не выставлен контекст чека").
        undo main-block, retry main-block.
      end.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.chk-type <> integer('12':U)  then do:
      v-err-mess = substitute("Запись фискальных регистров возможна только внутри чека z-отчета").
      undo main-block, retry main-block.
    end.
    find first buf_cd-trans share-lock where
          buf_cd-trans.trans-type = p-trans-type
        and buf_cd-trans.obj-type = libthpos_context.obj-type
        and buf_cd-trans.obj-code = libthpos_context.obj-code
        and buf_cd-trans.pay-desk = libthpos_context.cash-num
        and buf_cd-trans.chk-id = libthpos_chk-context.doc-code
        and buf_cd-trans.charkey_one = p-charkey_one
    no-error.
    if not available buf_cd-trans then do:
      create buf_cd-trans.
      assign
      buf_cd-trans.db-num   = g#db-num
      buf_cd-trans.trans-id = next-value(s-cd-trans, ub)
      buf_cd-trans.trans-type = p-trans-type
      buf_cd-trans.obj-type = libthpos_context.obj-type
      buf_cd-trans.obj-code = libthpos_context.obj-code
      buf_cd-trans.chk-date = libthpos_chk-context.chk-date
      buf_cd-trans.chk-time = libthpos_chk-context.chk-time
      buf_cd-trans.chk-id = libthpos_chk-context.doc-code
      buf_cd-trans.z-number = libthpos_context.z-number
      buf_cd-trans.doc-code = libthpos_chk-context.doc-code
      buf_cd-trans.src-shift-date = libthpos_context.shift-date
      buf_cd-trans.src-shift-name = libthpos_context.shift-name
      buf_cd-trans.shift-name = libthpos_context.shift-name
      buf_cd-trans.shift-date = libthpos_context.shift-date
      buf_cd-trans.shift-num = libthpos_context.shift-num
      buf_cd-trans.pay-desk = libthpos_context.cash-num
      buf_cd-trans.charkey_one = p-charkey_one
      buf_cd-trans.deckey_one = p-deckey_one
      buf_cd-trans.key#_one = p-key#_one
      .
    end.
  end.
end.
end procedure.
procedure libthpos_recalc-discnt private:
define variable v-setted as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-chk-name as character no-undo .
define variable v-second-name as character no-undo .
define variable v-src-price as decimal no-undo .
define variable v-src-discnt-sum as decimal no-undo .
define variable v-src-sum as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-next as character no-undo .
define variable  v-src-price-rubl as decimal no-undo .
define variable  v-src-discnt-sum-rubl as decimal no-undo .
define variable  v-src-sum-rubl as decimal no-undo .
define variable  v-src-sum-netto-rubl as decimal no-undo .
define variable v-err-mess as character no-undo .
define variable v-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-st-rb as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-st-discnt as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .
define variable v-unit-base as character no-undo .
define variable v-step as integer no-undo .
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf2_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    v-step = libthpos_chk-context.step.
    if v-step >= 1 then do:
      for each buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code
          and buf_libthpos_chk-gds.line-num >= libthpos_chk-context.recalc-gline-num
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        v-ii = v-ii + 1.
        assign
        v-setted = no.
        if (libthpos_chk-context.chk-type = integer('6':U)
        or libthpos_chk-context.chk-type = integer('96':U)
        or libthpos_chk-context.chk-type = integer('206':U)
          ) then do:
          v-src-price = buf_libthpos_chk-gds.src-price.
        end.
        else v-src-price = ?.
        assign
        v-mode = 'ИЗМЕНЕНИЕ':U + chr(44) + "recalc" + chr(44) + "no-changes".
        run libthpos_gds-line  in this-procedure (
                                                    input libthpos_chk-context.doc-code
                                                  ,input buf_libthpos_chk-gds.line-num
                                                  ,input v-mode
                                                  ,input buf_libthpos_chk-gds.line-direction
                                                  ,input buf_libthpos_chk-gds.src-code
                                                  ,input-output buf_libthpos_chk-gds.src-qnty
                                                  ,input buf_libthpos_chk-gds.pump
                                                  ,input buf_libthpos_chk-gds.nozzle-code
                                                  ,input buf_libthpos_chk-gds.pl-code
                                                  ,input buf_libthpos_chk-gds.pass-gds
                                                  ,input buf_libthpos_chk-gds.write-off-code
                                                  ,input buf_libthpos_chk-gds.depart-id
                                                  ,output v-setted
                                                  ,output v-next
                                                  ,output v-b-code
                                                  ,output v-gds-code
                                                  ,output v-chk-name
                                                  ,output v-second-name
                                                  ,input-output v-src-price
                                                  ,output v-src-price-rubl
                                                  ,output v-src-discnt-sum
                                                  ,output v-src-discnt-sum-rubl
                                                  ,output v-src-sum
                                                  ,output v-src-sum-rubl
                                                  ,output v-src-sum-netto
                                                  ,output v-src-sum-netto-rubl
                                                  ,output v-unit-base
                                                  ) no-error.
        if not error-status:error
        and v-setted
        then do:
          assign
          libthpos_chk-context.recalc-gline-num  = min(libthpos_chk-context.recalc-gline-num  + 1, libthpos_chk-context.lng)
          .
        end.
        else do:
          v-err-mess = substitute("Строка &1: &2 &3"
                                  , buf_libthpos_chk-gds.line-num
                                  , return-value
                                  , error-status:get-message(1)
                                  ).
          undo main-block, retry main-block.
        end.
        find first buf2_libthpos_chk-gds no-lock where
                  buf2_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code
              and buf2_libthpos_chk-gds.line-num > buf_libthpos_chk-gds.line-num no-error.
        if available buf2_libthpos_chk-gds then do:
          v-mode = "no-changes".
        end.
        else do:
          v-mode = ''.
        end.
        run libthpos_sub-total  in this-procedure (
                                                    input libthpos_chk-context.doc-code
                                                    ,input v-mode
                                                    ,output v-setted
                                                    ,input-output v-st-rb
                                                    ,input-output v-st-rubl
                                                    ,input-output v-st-base
                                                    ,input-output v-tot-doc
                                                    ,input-output v-st-discnt
                                                    ,output v-netto
                                                    ,output v-netto-rubl
                                                    ,output v-netto-base
                                                    ,output v-all-discnt
                                                    ,output v-all-discnt-rubl
                                                    ,output v-all-discnt-base
                                                    ) no-error.
        if error-status:error
        or not v-setted
        then do:
          v-err-mess = substitute("Ошибка в Подитоге после строки &1: &2 &3"
                                  , buf_libthpos_chk-gds.line-num
                                  , return-value
                                  , error-status:get-message(1)
                                  ).
          undo main-block, retry main-block.
        end.
      end.
    end.
    if v-step >= 3 then do:
    end.
    dataset libthpos_receipt:accept-changes.
  end.
end.
end procedure.
procedure libthpos_prepare-getcheck private:
define input parameter p-doc-code as character no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    find first buf_chk-doc exclusive-lock where buf_chk-doc.doc-code = p-doc-code.
    assign
    buf_chk-doc.netto = 0
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.correct = yes
    buf_chk-doc.doc-qnty = 0
    buf_chk-doc.office = ''
    .
    for each buf_chk-discnt where
              buf_chk-discnt.doc-code = p-doc-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if buf_chk-discnt.record-type = 0 then NEXT.
      if buf_chk-discnt.record-type = 4  then NEXT.
      delete buf_chk-discnt.
    end.
    for each buf_chk-gds-pay where buf_chk-gds-pay.doc-code = p-doc-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      delete buf_chk-gds-pay.
    end.
  end.
end.
end procedure.
procedure libthpos_tracking-changes private :
define input  parameter p-tbl-handle as handle no-undo .
define input  parameter p-on-off as logical   no-undo .
p-tbl-handle:tracking-changes = p-on-off.
end procedure.
procedure libthpos_undo :
define buffer buf_libthpos_chk-doc for libthpos_chk-doc.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
do
on error undo, return error return-value
:
  for each undo_libthpos_chk-doc:
    case buffer undo_libthpos_chk-doc:handle:row-state:
      when row-deleted then do:
      end.
      when row-modified then do:
        buffer-copy undo_libthpos_chk-doc to libthpos_chk-context.
      end.
      when row-created then do:
      end.
    end.
  end.
  for each undo_libthpos_chk-context:
    case buffer undo_libthpos_chk-context:handle:row-state:
      when row-deleted then do:
      end.
      when row-modified then do:
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
      end.
    end.
  end.
  for each undo_libthpos_chk-gds:
    case buffer undo_libthpos_chk-gds:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-gds.
         buffer-copy undo_libthpos_chk-gds to buf_libthpos_chk-gds.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = undo_libthpos_chk-gds.doc-code
              and buf_libthpos_chk-gds.line-num = undo_libthpos_chk-gds.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = undo_libthpos_chk-gds.doc-code
              and buf_libthpos_chk-gds.line-num = undo_libthpos_chk-gds.line-num.
         delete buf_libthpos_chk-gds.
      end.
    end.
  end.
  for each undo_libthpos_chk-pay:
    case buffer undo_libthpos_chk-pay:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-pay.
         buffer-copy undo_libthpos_chk-pay to buf_libthpos_chk-pay.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-pay where
                  buf_libthpos_chk-pay.doc-code = undo_libthpos_chk-pay.doc-code
              and buf_libthpos_chk-pay.line-num = undo_libthpos_chk-pay.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-pay where
                  buf_libthpos_chk-pay.doc-code = undo_libthpos_chk-pay.doc-code
              and buf_libthpos_chk-pay.line-num = undo_libthpos_chk-pay.line-num.
         delete buf_libthpos_chk-pay.
      end.
    end.
  end.
  for each undo_libthpos_chk-discnt:
    case buffer undo_libthpos_chk-discnt:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-discnt.
         buffer-copy undo_libthpos_chk-discnt to buf_libthpos_chk-discnt.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-discnt where
                  buf_libthpos_chk-discnt.doc-code = undo_libthpos_chk-discnt.doc-code
              and buf_libthpos_chk-discnt.line-num = undo_libthpos_chk-discnt.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-discnt where
                  buf_libthpos_chk-discnt.doc-code = undo_libthpos_chk-discnt.doc-code
              and buf_libthpos_chk-discnt.line-num = undo_libthpos_chk-discnt.line-num.
         delete buf_libthpos_chk-discnt.
      end.
    end.
  end.
end.
end procedure.
procedure libthpos_print-dataset :
define input parameter p-forced as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
do
on error undo, return error
:
  if search("print-xml.xml") <> ?
  or p-forced
  then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context then do:
      libthpos_chk-context.print-copy-num = libthpos_chk-context.print-copy-num + 1.
      run print-xml in this-procedure ( input (dataset libthpos_receipt:handle)
                                          ,input substitute("&1_&2"
                                                            ,libthpos_chk-context.doc-code
                                                            ,libthpos_chk-context.print-copy-num)).
     find first libthpos_chk-context.
    end.
    else do:
      loc-print-copy-num = loc-print-copy-num + 1.
      run print-xml in this-procedure ( input (dataset libthpos_receipt:handle)
                                          ,input substitute("&1_&2"
                                                            ,loc-print-doc-code
                                                            ,loc-print-copy-num)).
    end.
    find first libthpos_chk-doc no-error.
    run cur-time in this-procedure ( output v-today, output v-time).
     run print-xml in this-procedure ( input (dataset libthpos_context:handle)
                                        ,input substitute("thpos_context_&1-&2-&3_&4"
                                                          , string(year(v-today), "9999")
                                                          , string(month(v-today), "99")
                                                          , string(day(v-today), "99")
                                                          , replace(string(v-time, "HH:MM:SS"), ":", "-")
                                                           )
                                        ).
     run print-xml in this-procedure ( input (dataset libthpos_params:handle)
                                        ,input substitute("thpos_params_&1-&2-&3_&4"
                                                          , string(year(v-today), "9999")
                                                          , string(month(v-today), "99")
                                                          , string(day(v-today), "99")
                                                          , replace(string(v-time, "HH:MM:SS"), ":", "-")
                                                           )
                                        ).
  end.
end.
end procedure.
procedure libthpos_process-sale :
define input parameter p-chk-type as integer no-undo .
define input parameter p-doc-code as character no-undo .
define variable v-log-handle as handle no-undo .
if  libthpos_context.process-sale
and lookup(string(p-chk-type), '11,111,201,206':U) = 0
and lookup(string(p-chk-type), '2,3,4,5,7':U) = 0
then do:
  if not valid-handle(libthpos_context.p-log-handle) then do:
if (valid-handle(g#lib-log) <> true) then do:   run gbl/lib-log.p persistent no-error .   if error-status :error or (valid-handle(g#lib-log) <> true) then do:     message       "Error starting gbl/lib-log.p" skip       g#lib-log skip       g#lib-log :type skip       g#lib-log :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-log_get-log-handle in g#lib-log
  (output  v-log-handle
  ) no-error .
  end.
  else do:
    v-log-handle = libthpos_context.p-log-handle.
  end.
  run str/afgetchk.p (
                       input libthpos_context.parparentproc
                      ,input this-procedure:handle
                      ,input v-log-handle
                      ,input (libthpos_context.obj-type + chr(4)  +
                             string(libthpos_context.obj-code) + chr(4) +
                             p-doc-code )
                      ) no-error.
end.
end procedure.
