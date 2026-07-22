using ibs.th.str.*.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по приемке топлива".
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
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure godendo-date-to-offset :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-date   as date      no-undo .
  define output parameter p-offset as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-date  = ?
    or p-today = ?
    then do:
      assign
        p-offset = ?
      .
    end.
    else do:
      assign
        p-offset = p-date - p-today + 1
      .
    end.
  end.
end procedure.
procedure godendo-offset-to-date :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-offset as integer   no-undo .
  define output parameter p-date   as date      no-undo .
  do
  on error undo, return error return-value
  :
    if p-today  = ?
    or p-offset = ?
    then do:
      assign
        p-date = ?
      .
    end.
    else do:
      assign
        p-date = p-offset + p-today - 1
      .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define input        parameter parparentproc       as   handle                no-undo .
define input        parameter p-mode              as   character             no-undo .
define input        parameter p-doc-code          like ub.trn-doc.doc-code   no-undo .
define input        parameter p-gds-code          like ub.goods.gds-code     no-undo .
define input-output parameter infoSectionTotal as class InfoSectionsTotal    no-undo .
define       output parameter p-was-setting       as   logical               no-undo initial no .
define variable v-section-names as character no-undo.
define variable v-page-current as integer no-undo.
define variable ii as integer no-undo.
define variable rdcvalue      as char initial ? no-undo.
define variable rdctype       as char initial ? no-undo.
define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable v-fuel-type as character no-undo.
define variable v-gds-attr-value as character no-undo .
define variable v-gds-attr-type  as character no-undo .
define variable v-sr-type as integer no-undo.
define variable rdc-dnstvalue as character no-undo.
define variable rdc-dnsttype  as character no-undo.
define variable temp-for-pomi           as integer no-undo.
define buffer buf_clob-bind for ub.clob-bind.
define variable v-page as integer no-undo.
define variable iTemp as integer no-undo.
define variable maxSec as integer no-undo init 6.
define stream outstream.
  DEFINE VARIABLE up-image             AS HANDLE NO-UNDO.
  DEFINE VARIABLE tab-type             AS INT NO-UNDO.
  DEFINE VARIABLE char-hdl             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE page-label           AS HANDLE EXTENT 20 NO-UNDO.
  DEFINE VARIABLE image-hdl            AS HANDLE EXTENT 20 NO-UNDO.
  DEFINE VARIABLE page-enabled         AS LOGICAL EXTENT 20 NO-UNDO.
  DEFINE VARIABLE pos-x             AS integer NO-UNDO init 5.
  DEFINE VARIABLE pos-y             AS integer NO-UNDO init 30.
  DEF VAR width-tab-values    AS INT INIT [110,72] EXTENT 2 NO-UNDO.
  DEFINE VARIABLE        number-of-pages    AS INTEGER   NO-UNDO.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define buffer buf_goods for ub.goods .
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_doc-pl for ub.doc-pl.
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-choose-date-pov-plotn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date-pov-plotn"
     SIZE 3 BY 1.
DEFINE BUTTON b-copy-iz
     LABEL "Копировать"
     SIZE 10.75 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-copy-pass
     LABEL "Копировать в секции"
     SIZE 20 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-del-sec
     LABEL "Удалить секцию"
     SIZE 15 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-list-tank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-list-tank"
     SIZE 3 BY 1.
DEFINE BUTTON r-sr-izm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm"
     SIZE 3 BY 1.
DEFINE VARIABLE f-a-b-tarir AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Уровень цистерны относительно тарировочной планки"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-acc-ship AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Погр.изм.пост."
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-acc-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ?
     LABEL "Погр. изм. массы"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем по паспорту в литрах"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-vol-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем по паспорту в литрах"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-certif-fuel AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 92.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-qnty AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "   Масса по док."
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U
     LABEL " Дата конца слива"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-pov-plotn AS DATE FORMAT "99/99/99":U
     LABEL "Дата поверки"
     VIEW-AS FILL-IN
     SIZE 10.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-prob AS DATE FORMAT "99/99/99":U
     LABEL "Дата отбора пробы"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала слива"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-dens-temp AS DECIMAL FORMAT "->9":U INITIAL ?
     LABEL "Температура замера плотности"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-dens AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0
     LABEL "Плотность по док."
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-qnty AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "  Кол-во по док."
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-qnty-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Количество по документу"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-EU-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "          Масса ЕУ"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL ?
     LABEL " Время конца слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-prob AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время отбора пробы"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время начала слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-kol-prob AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Кол-во пробы (л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-list-tank AS CHARACTER FORMAT "X(256)":U
     LABEL "Резервуары"
     VIEW-AS FILL-IN
     SIZE 42.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-loss-norm AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Тех. потери по нормам, кг"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-prob AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-mouth AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "   Объем горловины"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-norm-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "из паспорта качества"
     VIEW-AS FILL-IN
     SIZE 70.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-passport AS CHARACTER FORMAT "X(256)":U
     LABEL "Паспорт качества №"
     VIEW-AS FILL-IN
     SIZE 72.5 BY .88 NO-UNDO.
DEFINE VARIABLE f-num-plotn AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 85.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-print-prob AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер печати (пробы)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-passport-plotn AS CHARACTER FORMAT "X(256)":U
     LABEL "Паспорт плотномера №"
     VIEW-AS FILL-IN
     SIZE 20.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-place-si AS INTEGER FORMAT ">>>,>>9":U INITIAL 0
     LABEL "Средство измерения"
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-place-si-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-sec-num AS CHARACTER FORMAT "x(256)":U
     LABEL "Номер секции"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-size AS CHARACTER FORMAT "x(8)" INITIAL "0"
     LABEL "Размер горловины"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Длина/Ширина" NO-UNDO.
DEFINE VARIABLE f-tank-density AS DECIMAL FORMAT ">>9.9999":U INITIAL ?
     LABEL " Плотность топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-density-pomi AS DECIMAL FORMAT ">>9.9999":U INITIAL ?
     LABEL "    Плотность приведенная"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-temp AS DECIMAL FORMAT "->9":U INITIAL ?
     LABEL "Температура замера объема"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "     Объем топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-vol-pomi AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ?
     LABEL "Объем топлива приведенный"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-vol-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-water AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Объем воды"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ?
     LABEL "   Масса топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-tank-weight-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Вес топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tests AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер пробы"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-text1 AS CHARACTER FORMAT "X(256)":U INITIAL "Нормативный документ завода-изготовителя (ГОСТ, ТУ на марку моторного топлива)"
     VIEW-AS FILL-IN
     SIZE 92.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-text2 AS CHARACTER FORMAT "X(256)":U INITIAL "Сертификат соответствия завода-изготовителя (на марку моторного топлива) № :"
     VIEW-AS FILL-IN
     SIZE 92.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-text3 AS CHARACTER FORMAT "X(256)":U INITIAL "Срок действия сертификата соответствия завода-изготовителя (на марку моторного"
     VIEW-AS FILL-IN
     SIZE 92.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-ttn-temp AS DECIMAL FORMAT "->9":U INITIAL ?
     LABEL "Температура по ТТН"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-validity-certif AS CHARACTER FORMAT "X(256)":U
     LABEL "топлива) из паспорта качества"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 3.75
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 3.58
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 6.83
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 2.5
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 7.42
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 3.5
     BGCOLOR 17 .
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 94 BY 2.58
     BGCOLOR 17 .
DEFINE RECTANGLE Rect-Bottom
     EDGE-PIXELS 0
     SIZE 33.63 BY .17
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Left
     EDGE-PIXELS 0
     SIZE .63 BY 4.25
     BGCOLOR 15 .
DEFINE RECTANGLE Rect-Main
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 33.75 BY 4.33
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE Rect-Right
     EDGE-PIXELS 0
     SIZE .63 BY 4.33
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Top
     EDGE-PIXELS 0
     SIZE 33.63 BY .17
     BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-del-sec AT ROW 1 COL 21.88 WIDGET-ID 88
     b-help AT ROW 1 COL 87.38
     f-sec-num AT ROW 3.75 COL 16.25 COLON-ALIGNED WIDGET-ID 84
     f-car-vol-total AT ROW 3.75 COL 31.13 COLON-ALIGNED WIDGET-ID 90
     f-ttn-temp AT ROW 3.79 COL 53.5 COLON-ALIGNED WIDGET-ID 132
     f-doc-qnty AT ROW 3.79 COL 80.5 COLON-ALIGNED WIDGET-ID 86
     f-doc-dens AT ROW 4.96 COL 21.25 COLON-ALIGNED WIDGET-ID 106
     f-tank-weight-total AT ROW 4.96 COL 31.13 COLON-ALIGNED WIDGET-ID 92
     f-acc-ship AT ROW 4.96 COL 53.5 COLON-ALIGNED WIDGET-ID 140
     f-cli-qnty AT ROW 4.96 COL 80.5 COLON-ALIGNED WIDGET-ID 108
     f-size AT ROW 6.13 COL 80.5 COLON-ALIGNED WIDGET-ID 20
     f-car-vol AT ROW 6.17 COL 30.25 COLON-ALIGNED
     f-tank-vol-total AT ROW 6.17 COL 31.13 COLON-ALIGNED WIDGET-ID 94
     f-doc-qnty-total AT ROW 7.29 COL 31.13 COLON-ALIGNED WIDGET-ID 98
     f-num-passport AT ROW 7.38 COL 22 COLON-ALIGNED WIDGET-ID 36
     f-text1 AT ROW 8.29 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 100 DISABLE-AUTO-ZAP
     f-norm-doc AT ROW 9.33 COL 4 WIDGET-ID 38
     f-text2 AT ROW 10.38 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 102 DISABLE-AUTO-ZAP
     f-certif-fuel AT ROW 11.46 COL 3.88 NO-LABEL WIDGET-ID 44
     f-text3 AT ROW 12.42 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 104 DISABLE-AUTO-ZAP
     f-validity-certif AT ROW 13.5 COL 4 WIDGET-ID 50
     b-copy-pass AT ROW 13.5 COL 76.75 WIDGET-ID 130
     f-a-b-tarir AT ROW 14.83 COL 80 COLON-ALIGNED WIDGET-ID 2
     f-mouth AT ROW 15.92 COL 22 COLON-ALIGNED
     f-tank-water AT ROW 15.92 COL 80 COLON-ALIGNED
     f-tank-vol AT ROW 17 COL 22 COLON-ALIGNED
     f-tank-temp AT ROW 17 COL 80 COLON-ALIGNED
     f-tank-density AT ROW 18.08 COL 22 COLON-ALIGNED
     f-dens-temp AT ROW 18.08 COL 80 COLON-ALIGNED WIDGET-ID 26
     f-EU-weight AT ROW 19.17 COL 22 COLON-ALIGNED WIDGET-ID 136
     f-list-tank AT ROW 19.21 COL 48.5 COLON-ALIGNED WIDGET-ID 124
     r-list-tank AT ROW 19.21 COL 93.25 WIDGET-ID 126
     f-loss-norm AT ROW 20.25 COL 29 COLON-ALIGNED WIDGET-ID 138
     f-place-si AT ROW 21.92 COL 22 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 21.92 COL 28.5 WIDGET-ID 18
     f-num-plotn AT ROW 23.04 COL 9 COLON-ALIGNED WIDGET-ID 76
     f-date-pov-plotn AT ROW 24.13 COL 16.13 COLON-ALIGNED WIDGET-ID 64
     b-copy-iz AT ROW 24.13 COL 86 WIDGET-ID 22
     b-choose-date-pov-plotn AT ROW 24.17 COL 29.13 WIDGET-ID 72
     f-passport-plotn AT ROW 24.17 COL 52.63 COLON-ALIGNED WIDGET-ID 68
     f-tank-weight AT ROW 25.5 COL 63.25 COLON-ALIGNED
     f-tank-density-pomi AT ROW 25.54 COL 29 COLON-ALIGNED WIDGET-ID 24
     b-calc AT ROW 26.17 COL 81.63 WIDGET-ID 80
     f-acc-weight AT ROW 26.71 COL 63.25 COLON-ALIGNED WIDGET-ID 134
     f-tank-vol-pomi AT ROW 26.75 COL 30 COLON-ALIGNED WIDGET-ID 28
     f-date-start AT ROW 28.21 COL 21 COLON-ALIGNED
     f-hour-start AT ROW 28.21 COL 88 COLON-ALIGNED
     f-min-start AT ROW 28.21 COL 91.63 COLON-ALIGNED NO-LABEL
     f-date-end AT ROW 29.29 COL 21 COLON-ALIGNED
     f-hour-end AT ROW 29.29 COL 88 COLON-ALIGNED
     f-min-end AT ROW 29.29 COL 91.63 COLON-ALIGNED NO-LABEL
     f-tests AT ROW 30.83 COL 20.88 COLON-ALIGNED WIDGET-ID 118
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     f-num-print-prob AT ROW 30.83 COL 80.5 COLON-ALIGNED WIDGET-ID 120
     f-kol-prob AT ROW 31.83 COL 20.88 COLON-ALIGNED WIDGET-ID 122
     f-hour-prob AT ROW 31.96 COL 87.75 COLON-ALIGNED WIDGET-ID 114
     f-min-prob AT ROW 31.96 COL 91.38 COLON-ALIGNED NO-LABEL WIDGET-ID 116
     f-date-prob AT ROW 32.83 COL 20.88 COLON-ALIGNED WIDGET-ID 112
     f-place-si-name AT ROW 21.92 COL 30.13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     Rect-Main AT ROW 8.17 COL 5.75
     Rect-Bottom AT ROW 8.08 COL 3.5
     Rect-Left AT ROW 1.75 COL 1.25
     Rect-Right AT ROW 1.88 COL 34.25
     Rect-Top AT ROW 1.71 COL 1.25
     RECT-3 AT ROW 21.75 COL 3.5
     RECT-1 AT ROW 3.54 COL 3.5
     RECT-4 AT ROW 14.67 COL 3.5 WIDGET-ID 30
     RECT-5 AT ROW 28 COL 3.5 WIDGET-ID 32
     RECT-6 AT ROW 7.25 COL 3.5 WIDGET-ID 34
     RECT-8 AT ROW 25.38 COL 3.5 WIDGET-ID 82
     RECT-7 AT ROW 30.58 COL 3.5 WIDGET-ID 110
     SPACE(1.87) SKIP(0.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация по приемке топлива"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-choose-date-pov-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-date-pov-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-passport-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-text1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-text2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-text3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON go OF FRAME Dialog-Frame
do:
  assign frame Dialog-Frame
    f-sec-num f-tests f-doc-qnty f-doc-dens f-cli-qnty f-car-vol f-size
    f-num-passport f-norm-doc f-text2 f-certif-fuel f-validity-certif
    f-a-b-tarir f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp
    f-num-plotn f-date-pov-plotn f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-doc-qnty f-doc-dens f-cli-qnty
    f-num-print-prob f-kol-prob f-date-prob f-hour-prob f-min-prob f-list-tank f-ttn-temp f-acc-ship f-EU-weight
  .
  if v-page-current <= infoSectionTotal:SectionNum
  then do:
    run check-page no-error.
    if error-status:error then do:
      return no-apply.
    end.
    run save-page.
  end.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then infoSectionTotal:SaveDB().
  assign
    p-was-setting = yes
  .
end.
ON window-close OF FRAME Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
ON choose OF b-calc IN FRAME Dialog-Frame
do:
  define variable ToolType                as integer no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable NeckType                as integer no-undo.
  define variable Dgor                    as decimal no-undo.
  define variable NeckWidth               as decimal no-undo.
  define variable NeckHeight              as decimal no-undo.
  define variable error-string            as character no-undo.
  define variable v-mm as com-handle.
  define variable v-proc as character no-undo.
  define buffer buf_sr-izmerenia    for ub.sr-izmerenia .
  run save-page.
  assign
  f-car-vol
  f-tank-vol
  f-a-b-tarir
  f-size
  f-tank-temp
  f-tank-density
  f-dens-temp
  f-place-si
  .
  case rdc-dnstvalue:
    when "pomi-rn" then do:
      _trpomi :
        do on error undo, return no-apply :
        find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = f-place-si no-error.
        if not available buf_sr-izmerenia then do :
          message
            substitute( 'Не найдено средство измерения с кодом &1', f-place-si ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply  .
        end.
        else do :
          assign
            ToolType               = buf_sr-izmerenia.sr-type-id
            DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
            DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
            .
        end.
        v-proc = "Rosneft.MethodOfMetering31" .
        release object v-mm no-error.
        v-mm = ?.
        create value("Rosneft.MethodOfMetering31") v-mm no-error.
        if error-status:error
        or not VALID-HANDLE(v-mm)
        then do:
          release object v-mm no-error.
          v-mm = ?.
          message
            substitute( 'Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ ' ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply .
        end.
        else do :
          if f-car-vol = ? or f-car-vol = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Объем по паспорту в литрах"  skip
            view-as alert-box error.
            apply "entry" to f-car-vol in frame Dialog-Frame .
            undo _trpomi, return no-apply  .
          end.
          if f-a-b-tarir = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Уровень цистерны относительно тарировочной планки"  skip
            view-as alert-box error.
            apply "entry" to f-a-b-tarir in frame Dialog-Frame .
            undo _trpomi, return no-apply  .
          end.
            assign
            f-size              = string (decimal (f-size))
            f-size:screen-value = string (decimal (f-size))
            no-error.
          if error-status:error then
          do:
            assign
              NeckType = 1
              NeckWidth = decimal (entry (1,f-size, "/"))
              NeckHeight = decimal (entry (2,f-size, "/"))
              Dgor = 0
              no-error.
          end.
          else do:
          assign
            NeckType = 0
            Dgor = decimal (f-size).
          end.
          if f-size = ? or f-size = "0" then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Внутренний диаметр горловины"  skip
            view-as alert-box error.
            apply "entry" to f-size in frame Dialog-Frame .
            undo _trpomi, return no-apply  .
          end.
          if f-tank-temp = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Температуру"  skip
            view-as alert-box error.
            apply "entry" to f-tank-temp in frame Dialog-Frame .
            undo _trpomi, return no-apply  .
          end.
          if f-tank-density = ? or f-tank-density = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Плотность топлива для ПО МИ"  skip
            view-as alert-box error.
            apply "entry" to f-tank-density in frame Dialog-Frame .
            undo _trpomi, return no-apply  .
          end.
          assign
            v-mm:V_real                 = f-car-vol
            v-mm:DeltaH                 = f-a-b-tarir
            v-mm:Dgor                   = Dgor
            v-mm:NeckType               = NeckType
            v-mm:NeckWidth              = NeckWidth
            v-mm:NeckHeight             = NeckHeight
            v-mm:Tv                     = f-tank-temp
            v-mm:Tr                     = f-dens-temp
            v-mm:R                      = ( f-tank-density * 1000 )
            v-mm:Tcy                    = temp-for-pomi
            v-mm:ToolType               = ToolType
            v-mm:A_Reservoir            = 0.0000125
            v-mm:DeltaOtn_V             = 0.4
            v-mm:DeltaAbs_R             = DeltaAbs_R
            v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
            v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
          .
          v-mm:Exec() .
          output stream outstream to value ("pomi.log") append.
          put stream outstream
            chr(10)
            "-----------------------------------------------"
            chr(10)
                                       now                     skip
            'Номер документа:'         p-doc-code              skip
            'Секция:'                  v-section-names         skip
            'Процедура'                v-proc                  skip
            'V_real                 =' f-car-vol               skip
            'DeltaH                 =' f-a-b-tarir             skip
            'Dgor                   =' Dgor                    skip
            'NeckType               =' NeckType                skip
            'NeckWidth              =' NeckWidth               skip
            'NeckHeight             =' NeckHeight              skip
            'Tv                     =' f-tank-temp             skip
            'Tr                     =' f-dens-temp             skip
            'R                      =' ( f-tank-density * 1000 ) skip
            'Tcy                    =' temp-for-pomi           skip
            'ToolType               =' ToolType                skip
            'A_Reservoir            =' string (0.0000125)      skip
            'DeltaOtn_V             =' 0.4                     skip
            'DeltaAbs_R             =' DeltaAbs_R              skip
            'DeltaAbs_Tv            =' DeltaAbs_Tv             skip
            'DeltaAbs_Tr            =' DeltaAbs_Tr             skip
            'Vcy                    =' v-mm:Vcy               skip
            'Rcy                    =' v-mm:Rcy               skip
            'V                      =' v-mm:V                 skip
            'CTL_base_alt           =' v-mm:CTL_base_alt      skip
            'CPL_base_alt           =' v-mm:CPL_base_alt      skip
            'CTPL_base_alt          =' v-mm:CTPL_base_alt     skip
            'Fp_base_alt            =' v-mm:Fp_base_alt       skip
            'CTL_obs_base           =' v-mm:CTL_obs_base      skip
            'CPL_obs_base           =' v-mm:CPL_obs_base      skip
            'CTPL_obs_base          =' v-mm:CTPL_obs_base     skip
            'Fp_obs_base            =' v-mm:Fp_obs_base       skip
            'Rv                     =' v-mm:Rv                skip
            'DeltaOtn_Vcy           =' v-mm:DeltaOtn_Vcy      skip
            'M                      =' v-mm:M                 skip
            'Mcy                    =' v-mm:Mcy               skip
            'DeltaOtn_M             =' v-mm:DeltaOtn_M        skip
          .
          output stream outstream close.
          if v-mm:Result <> 0 then do :
            error-string = v-mm:ResultDetail .
            output stream outstream to value ("pomi.log") append.
              put stream outstream error-string format "x(1024)" skip.
            output stream outstream close.
            release object v-mm no-error.
            v-mm = ?.
            message
              substitute('Ошибка работы библиотеки ПО МИ &1',error-string) skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          else do :
            assign
              f-tank-density-pomi    = decimal(v-mm:Rcy) / 1000
              f-tank-vol-pomi        = v-mm:Vcy
              f-tank-weight     = v-mm:Mcy
              f-acc-weight = round (v-mm:DeltaOtn_M, 3)
            .
            display
              f-tank-density-pomi
              f-tank-vol-pomi
              f-tank-weight
              f-acc-weight
            with frame Dialog-Frame.
            output stream outstream to value ("pomi.log") append.
              put stream outstream
              "v-mm:Rcy" f-tank-density-pomi      skip
              "v-mm:Vcy" f-tank-vol-pomi          skip
              "v-mm:Mcy" f-tank-weight            skip
              "v-mm:v-mm:DeltaOtn_M" f-acc-weight skip .
            output stream outstream close.
            release object v-mm no-error.
            v-mm = ?.
          end.
        end.
      end.
    end.
    when "th" then do:
      run gds-attr-value in this-procedure
        (  input p-gds-code
        ,  input 'fuel-type':U
        , output v-gds-attr-value
        , output v-gds-attr-type
        ) no-error .
      if not error-status:error and lookup (v-gds-attr-value, "petrol,diesel-sum,diesel-wint") > 0 then do:
        assign
          v-fuel-type = v-gds-attr-value.
        run str/rdcdnst.p (input f-tank-density * 1000
                      ,input f-dens-temp
                      ,input f-tank-vol
                      ,input f-tank-temp
                      ,input v-fuel-type
                      ,output f-tank-density-pomi
                      ,output f-tank-vol-pomi)
        no-error.
        if not error-status:error then do:
          assign
            f-tank-weight     = f-tank-density-pomi * f-tank-vol-pomi
          .
          display
            f-tank-vol-pomi
            f-tank-density-pomi
            f-tank-weight
          with frame Dialog-Frame.
        end.
        else do:
          message
            substitute('Ошибка при рассчете приведенных значений плотности и объема: &1', return-value)
          view-as alert-box error.
          undo, return no-apply  .
        end.
      end.
      else do:
        message
          substitute('Ошибка определения типа топлива &1 или не верный тип товлива &2', return-value, v-gds-attr-value)
        view-as alert-box error.
        undo, return no-apply  .
      end.
    end.
  end case.
  if rdc-dnstvalue = "pomi-rn" then do :
  end.
  if infoSectionTotal:IsRNAlgo
  then do:
    infoSectionTotal:InfoSectionCurr:TankWeight = f-tank-weight.
    def var v-m as decimal no-undo.
    infoSectionTotal:RNAlgo(v-page-current, output v-m, yes).
    f-EU-weight:screen-value = string (infoSectionTotal:InfoSectionCurr:NaturalLoss).
    f-loss-norm:screen-value = string (infoSectionTotal:InfoSectionCurr:TPNorm).
  end.
  enable
  f-tank-density
  with frame Dialog-Frame.
end.
ON choose OF b-choose-date-pov-plotn IN FRAME Dialog-Frame
do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run sel-date in this-procedure
    ( input f-date-pov-plotn :handle
    , input "Дата поверки плотномера"
    ) .
end.
ON choose OF b-copy-iz IN FRAME Dialog-Frame
do:
    define variable v-place-si as integer no-undo.
    define variable v-num-plotn as character no-undo.
    define variable v-date-pov-plotn as date no-undo.
    define variable v-passport-plotn as character no-undo.
    define buffer buf_sr-izmerenia for ub.sr-izmerenia .
    run str/in-copy-iz.w
      ( input        parParentProc
       ,input        p-mode
       ,input        p-gds-code
       ,output       v-place-si
       ,output       v-num-plotn
       ,output       v-passport-plotn
       ,output       v-date-pov-plotn
      ) no-error.
  infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = v-num-plotn.
  infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi = v-place-si.
  infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = v-date-pov-plotn.
  infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = v-passport-plotn.
  f-place-si:screen-value = string(infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi).
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = integer (f-place-si:screen-value) no-error.
    if available buf_sr-izmerenia then do:
      assign
        f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
        v-sr-type = buf_sr-izmerenia.sr-type-id.
    end.
    else
      assign
        f-place-si-name:screen-value = ""
        v-sr-type = 0.
  apply "leave" to f-place-si.
  f-num-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn).
  f-passport-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn).
  f-date-pov-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn).
end.
ON choose OF b-copy-pass IN FRAME Dialog-Frame
do:
  do ii = 1 to infoSectionTotal:SectionNum:
    if ii = v-page-current
      then next.
    infoSectionTotal:GetInfoSectionProp(ii):NumPassport = f-num-passport:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):NormDoc = f-norm-doc:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):CertifFuel = f-certif-fuel:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):ValidityCertif = f-validity-certif:screen-value.
  end.
end.
ON choose OF b-del-sec IN FRAME Dialog-Frame
do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if infoSectionTotal:SectionNum = 1
  then do:
    message "Нельзя удалять одну единственную секцию." view-as alert-box.
    return.
  end.
  infoSectionTotal:DeleteSection(v-page-current).
  v-page-current = if v-page-current = 1 then 1 else v-page-current - 1.
  v-section-names = "".
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end.
  v-section-names = trim (v-section-names, "|") + "|         +" + if infoSectionTotal:FlagTrn then "|Сумма" else "".
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
  run initialize-section.
end.
ON choose OF b-save IN FRAME Dialog-Frame
do:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run check-data no-error.
  if error-status:error
    then return no-apply .
  apply "LEAVE":U to f-car-vol      in frame Dialog-Frame .
  apply "LEAVE":U to f-tank-density in frame Dialog-Frame .
end.
ON leave OF f-a-b-tarir IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-acc-weight IN FRAME Dialog-Frame
do:
      apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-car-vol IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-car-vol IN FRAME Dialog-Frame
do:
  apply "entry" to f-tests in frame Dialog-Frame.
  return no-apply.
end.
ON value-changed OF f-car-vol IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  f-tank-vol-pomi:screen-value in frame Dialog-Frame = ?.
end.
ON leave OF f-car-vol-total IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-car-vol-total IN FRAME Dialog-Frame
do:
  apply "entry" to f-tests in frame Dialog-Frame.
  return no-apply.
end.
ON value-changed OF f-car-vol-total IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame Dialog-Frame
  .
end.
ON return OF f-certif-fuel IN FRAME Dialog-Frame
do:
return no-apply.
end.
ON leave OF f-cli-qnty IN FRAME Dialog-Frame
do:
    run calc-doc in this-procedure.
end.
ON return OF f-date-end IN FRAME Dialog-Frame
do:
    apply "entry" to f-hour-end in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-date-prob IN FRAME Dialog-Frame
do:
  apply "entry" to f-hour-prob in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-date-start IN FRAME Dialog-Frame
do:
  apply "entry" to f-hour-start in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-dens-temp IN FRAME Dialog-Frame
do:
  return no-apply.
end.
ON value-changed OF f-dens-temp IN FRAME Dialog-Frame
do:
  assign
    f-tank-density-pomi = ?
  .
  display
    f-tank-density-pomi with frame Dialog-Frame
  .
end.
ON leave OF f-doc-dens IN FRAME Dialog-Frame
do:
    run calc-doc in this-procedure.
end.
ON leave OF f-doc-qnty IN FRAME Dialog-Frame
do:
    run calc-doc in this-procedure.
end.
ON leave OF f-hour-end IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-hour-end IN FRAME Dialog-Frame
do:
    apply "entry" to f-min-end in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-hour-prob IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-hour-prob > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-prob in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-hour-prob IN FRAME Dialog-Frame
do:
apply "entry" to f-min-prob in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-hour-start IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-hour-start IN FRAME Dialog-Frame
do:
apply "entry" to f-min-start in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-kol-prob IN FRAME Dialog-Frame
do:
      apply "entry" to f-date-prob in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-list-tank IN FRAME Dialog-Frame
do:
      apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-min-end IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-min-end IN FRAME Dialog-Frame
do:
    apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-min-prob IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-min-prob > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-prob in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-min-prob IN FRAME Dialog-Frame
do:
  apply "entry" to f-date-end in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-min-start IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame Dialog-Frame .
     return no-apply .
  end.
end.
ON return OF f-min-start IN FRAME Dialog-Frame
do:
  apply "entry" to f-date-end in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-mouth IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-mouth IN FRAME Dialog-Frame
do:
apply "entry" to f-tank-density in frame Dialog-Frame.
return no-apply.
end.
ON value-changed OF f-mouth IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame Dialog-Frame
  .
end.
ON return OF f-norm-doc IN FRAME Dialog-Frame
do:
return no-apply.
end.
ON return OF f-num-passport IN FRAME Dialog-Frame
do:
return no-apply.
end.
ON return OF f-num-plotn IN FRAME Dialog-Frame
do:
return no-apply.
end.
ON return OF f-num-print-prob IN FRAME Dialog-Frame
do:
      apply "entry" to f-kol-prob in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-place-si IN FRAME Dialog-Frame
do:
define variable v-node-code as integer no-undo.
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  assign f-place-si.
  if f-place-si <> 0 and v-node-code <> ? then do :
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = f-place-si no-error.
    if not available (buf_sr-izmerenia) then do:
      message "Не найдено средство измерения с кодом " f-place-si view-as alert-box.
      f-place-si = 0.
      f-place-si:screen-value = "0".
      f-place-si-name:screen-value = "".
      assign
        f-num-plotn:screen-value = ""
        f-date-pov-plotn:screen-value = ""
        f-passport-plotn:screen-value = "".
      assign
        f-num-plotn
        f-date-pov-plotn
        f-passport-plotn
      .
      hide
        f-num-plotn
        f-date-pov-plotn
        f-passport-plotn
        b-choose-date-pov-plotn
        in frame Dialog-Frame.
      return.
    end.
    v-node-code = f-place-si.
    f-place-si-name:screen-value = buf_sr-izmerenia.sr-model.
    v-sr-type = buf_sr-izmerenia.sr-type-id.
  end.
  if v-sr-type = 2 or v-sr-type = 1 then do:
      enable f-num-plotn
             f-date-pov-plotn
             b-choose-date-pov-plotn
      with frame Dialog-Frame.
      hide f-passport-plotn
           in frame Dialog-Frame.
      f-passport-plotn:screen-value = "".
      assign f-passport-plotn.
  end.
  if v-sr-type = 3 or v-sr-type = 4 then do:
      enable f-num-plotn
             f-date-pov-plotn
             f-passport-plotn
             b-choose-date-pov-plotn
      with frame Dialog-Frame.
  end.
end.
ON return OF f-place-si IN FRAME Dialog-Frame
do:
  return no-apply.
end.
ON leave OF f-sec-num IN FRAME Dialog-Frame
do:
  if f-sec-num:screen-value = f-sec-num then return.
  find first ub.auto-tank where ub.auto-tank.auto-num = infoSectionTotal:CarNum + "#" + f-sec-num:screen-value no-error.
  if available (ub.auto-tank) and (f-size = "0" or f-size = ? or f-size = "" or not infoSectionTotal:FlagTrn )
  then do:
    assign
      f-size:screen-value = entry(3, auto-tank.name, chr(4))
      f-car-vol:screen-value = string (ub.auto-tank.brutto-qnty)
      f-doc-qnty:screen-value = string (ub.auto-tank.brutto-qnty)
      f-size = if entry (3, auto-tank.name, chr(4)) = "" or entry (3, auto-tank.name, chr(4)) = ? then "0" else entry (3, auto-tank.name, chr(4))
      f-doc-qnty = ub.auto-tank.brutto-qnty
      f-car-vol = ub.auto-tank.brutto-qnty.
  end.
  run save-page.
  v-section-names = "".
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + "Секция - " + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end.
  v-section-names = trim (v-section-names, "|") + (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + if infoSectionTotal:FlagTrn then "|Сумма" else "".
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
end.
ON leave OF f-size IN FRAME Dialog-Frame
do:
    decimal (f-size:screen-value) no-error.
    run calc-weight-vol in this-procedure.
end.
ON leave OF f-tank-density IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-tank-density IN FRAME Dialog-Frame
do:
      apply "entry" to f-tank-temp in frame Dialog-Frame.
return no-apply.
end.
ON value-changed OF f-tank-density IN FRAME Dialog-Frame
do:
  assign
    f-tank-density-pomi = ?
  .
  display
    f-tank-density-pomi with frame Dialog-Frame
  .
  run calc-weight-vol in this-procedure.
end.
ON leave OF f-tank-density-pomi IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-tank-temp IN FRAME Dialog-Frame
do:
  return no-apply.
end.
ON value-changed OF f-tank-temp IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame Dialog-Frame
  .
end.
ON return OF f-tank-vol IN FRAME Dialog-Frame
do:
      apply "entry" to f-tank-water in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-tank-vol-pomi IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-tank-vol-pomi IN FRAME Dialog-Frame
do:
      apply "entry" to f-tank-water in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-tank-vol-total IN FRAME Dialog-Frame
do:
      apply "entry" to f-tank-water in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-tank-water IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame Dialog-Frame
  .
  run calc-weight-vol in this-procedure.
end.
ON return OF f-tank-water IN FRAME Dialog-Frame
do:
      apply "entry" to f-tank-density in frame Dialog-Frame.
return no-apply.
end.
ON return OF f-tank-weight IN FRAME Dialog-Frame
do:
      apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
end.
ON leave OF f-tank-weight-total IN FRAME Dialog-Frame
do:
    run calc-weight-vol in this-procedure.
end.
ON return OF f-tank-weight-total IN FRAME Dialog-Frame
do:
  apply "entry" to f-tests in frame Dialog-Frame.
  return no-apply.
end.
ON value-changed OF f-tank-weight-total IN FRAME Dialog-Frame
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame Dialog-Frame
  .
end.
ON return OF f-tests IN FRAME Dialog-Frame
do:
  return no-apply.
end.
ON return OF f-ttn-temp IN FRAME Dialog-Frame
do:
  return no-apply.
end.
ON return OF f-validity-certif IN FRAME Dialog-Frame
do:
return no-apply.
end.
ON CHOOSE OF r-list-tank IN FRAME Dialog-Frame
DO:
  assign f-list-tank.
  run str/place-list.w
  ( input p-doc-code,
    input p-gds-code,
    input-output f-list-tank
  ).
  f-list-tank:screen-value = f-list-tank.
END.
ON choose OF r-sr-izm IN FRAME Dialog-Frame
do:
  define variable v-node-code as integer no-undo.
  define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input ""            ,
                    input 'ПРОСМОТР':U     ,
                    input ""            ,
                    input ""            ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    f-place-si = v-node-code.
    f-place-si:screen-value = string(v-node-code).
  find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = v-node-code no-error.
  if not available buf_sr-izmerenia then do:
    message "Введено неизвестное стредство измерения" view-as alert-box.
    return no-apply.
  end.
  f-place-si-name:screen-value = buf_sr-izmerenia.sr-model.
  end.
  apply "leave" to f-place-si.
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
  run gds-attr-value in this-procedure
    (  input p-gds-code
    ,  input 'fuel-type':U
    , output v-gds-attr-value
    , output v-gds-attr-type
    ) no-error .
  if error-status:error or lookup (v-gds-attr-value, "metan,propan") > 0 then
  do:
    rdc-dnstvalue = "not".
  end.
  infoSectionTotal:RdcDnstvalue = rdc-dnstvalue.
  v-page-current = 1.
  v-section-names = "".
  if infoSectionTotal:SectionNum = 1 then do:
    infoSectionTotal:GetInfoSectionProp(1):DocQnty = infoSectionTotal:DocQntyLine.
    infoSectionTotal:GetInfoSectionProp(1):DocDensity = infoSectionTotal:DocDensLine.
    infoSectionTotal:GetInfoSectionProp(1):CliQnty = infoSectionTotal:DocCliLine.
  end.
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end.
  if infoSectionTotal:FlagTrn
    then v-section-names = trim (v-section-names, "|") + (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + "|Сумма".
    else v-section-names = trim (v-section-names, "|") + (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then "|         +" else "").
  run set-size(input frame Dialog-Frame:height-pixels - 73, input frame Dialog-Frame:width-pixels - 20).
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  run enable_UI.
  run initialize-section.
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input trn-doc.obj-type
  , input trn-doc.obj-code
  ) .
  if not error-status :error then do:
    if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                  else temp-for-pomi = 20 .
  end.
  assign
    infoSectionTotal:IsRNAlgo = if ptrlprop-algoincome = 2 then true else false
  .
  if not infoSectionTotal:IsRnAlgo
    then
      hide
        f-acc-weight
      in frame Dialog-Frame .
  wait-for go of frame Dialog-Frame focus f-sec-num.
end.
run disable_UI.
PROCEDURE calc-doc :
run save-page.
  case false:
    when infoSectionTotal:DocQntyInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty / infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity no-error.
    end.
    when infoSectionTotal:DensityInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty / infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty no-error.
    end.
    when infoSectionTotal:CliQntyInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty = infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty * infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity no-error.
    end.
  end.
  do with frame Dialog-Frame:
  assign
    f-doc-qnty:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty)
    f-doc-dens:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity)
    f-cli-qnty:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty).
  end.
  assign frame Dialog-Frame
    f-doc-qnty
    f-doc-dens
    f-cli-qnty
  .
end procedure.
PROCEDURE calc-weight-vol :
define variable v-area as decimal no-undo.
  if v-page-current > infoSectionTotal:SectionNum or not infoSectionTotal:FlagTrn
    then return.
  assign frame Dialog-Frame
    f-mouth
    f-a-b-tarir
    f-size
    f-tank-density
    f-tank-weight
    f-tank-vol
    f-tank-vol-pomi
    f-tank-density-pomi
    f-car-vol
    f-tank-water
    .
  assign
    f-size              = string (decimal (f-size))
    f-size:screen-value = string (decimal (f-size))
    no-error.
  if error-status:error then
  do:
    assign
      v-area = decimal (entry (1,f-size, "/")) * decimal (entry (2,f-size, "/")) * 0.000001
      no-error.
    if error-status:error then
    do:
      message "Неверно указан размер горловины (либо значение диаметра, либо значение сторон для прямоугольной горловины в виде a/b). Берется по умолчанию 0" view-as alert-box.
      f-size:screen-value in frame Dialog-Frame = "0".
      v-area = 0.
    end.
  end.
  else
  do:
    v-area = 3.14159 * decimal (f-size) * decimal (f-size) * 0.000001 / 4 no-error.
  end.
  f-mouth = round (f-a-b-tarir * v-area, 2) .
  if f-mouth <> decimal (f-mouth:screen-value) then
    apply "value-changed" to f-mouth in frame Dialog-Frame.
  f-tank-vol = f-car-vol + f-mouth - f-tank-water.
  if rdc-dnstvalue = "not" then
  do:
    display input frame Dialog-Frame f-tank-vol *
      input frame Dialog-Frame f-tank-density @ f-tank-weight with frame Dialog-Frame.
  end.
  else
  do:
    if rdc-dnstvalue = "pomi-rn" or rdc-dnstvalue = "th" then do :
      display input frame Dialog-Frame f-tank-weight /
        input frame Dialog-Frame f-tank-vol-pomi @ f-tank-density-pomi with frame Dialog-Frame.
      assign
        f-tank-density-pomi = f-tank-weight / f-tank-vol-pomi.
    end.
    else do:
    display input frame Dialog-Frame f-tank-vol-pomi *
      input frame Dialog-Frame f-tank-density-pomi @ f-tank-weight with frame Dialog-Frame.
    end.
  end.
  assign
    f-tank-weight.
  do with frame Dialog-Frame:
    assign
      f-mouth:screen-value in frame Dialog-Frame = string (f-mouth)
      f-tank-vol:screen-value                     = string (f-tank-vol).
    .
  end.
end procedure.
PROCEDURE check-data :
define variable ii as integer no-undo.
  define variable v-list-tank as character no-undo.
  if p-mode = 'ПРОСМОТР':U or not infoSectionTotal:FlagTrn
      then return.
  infoSectionTotal:CalculateTotal().
  case false:
  when 0.01 > abs (infoSectionTotal:DocQntyTotal - infoSectionTotal:DocQntyLine) then
  do:
    message substitute ("Количество по документу - &1 не совпадает с суммой количества по документу - &2 по секциям", infoSectionTotal:DocQntyLine, infoSectionTotal:DocQntyTotal) view-as alert-box error.
    return error.
  end.
  when 0.01 > abs (infoSectionTotal:DocDensityAvg - infoSectionTotal:DocDensLine) then
  do:
    message substitute ("Плотность по документу - &1 не совпадает со средней плотностью по документу - &2 по секциям", infoSectionTotal:DocDensLine, infoSectionTotal:DocDensityAvg) view-as alert-box error.
    return error.
  end.
  when 0.01 > abs (infoSectionTotal:DocDensityAvg * infoSectionTotal:DocQntyTotal - infoSectionTotal:DocCliLine) then
  do:
    message substitute ("Масса по документу - &1 не совпадает с суммой масс по документу - &2 по секциям", infoSectionTotal:DocCliLine, infoSectionTotal:DocDensityAvg * infoSectionTotal:DocQntyTotal) view-as alert-box error.
    return error.
  end.
  end case.
  assign
    f-list-tank = f-list-tank:screen-value in frame Dialog-Frame.
  for each buf_doc-pl where buf_doc-pl.out-code = p-doc-code and buf_doc-pl.gds-code = p-gds-code:
    find first ub.place no-lock where ub.place.pl-code = buf_doc-pl.pl-code no-error.
    v-list-tank = v-list-tank + "," + ub.place.loc1.
  end.
  v-list-tank = left-trim (v-list-tank, ",").
  do ii = 1 to num-entries (f-list-tank):
    if lookup (entry (ii, f-list-tank), v-list-tank) = 0
    then do:
      message substitute ("Неверно указаны резервуары") view-as alert-box error.
      return error.
    end.
  end.
end procedure.
PROCEDURE check-page :
define variable v-list-tank as character no-undo.
  if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U then return.
  integer (replace (f-sec-num, ".", "-")) no-error.
  if error-status:error or f-sec-num matches "*,*"
    then
  do:
    message "Номер секции должен иметь числовое значение" view-as alert-box .
    apply "entry" to f-sec-num in frame Dialog-Frame .
    return error .
  end.
  do ii = 1 to infoSectionTotal:SectionNum:
    if ii <> v-page-current and input frame Dialog-Frame f-sec-num = infoSectionTotal:GetInfoSectionProp(ii):SectionName and infoSectionTotal:SectionNum >= v-page-current
    then do:
      message "Такой номер секции уже был" view-as alert-box .
      apply "entry" to f-sec-num in frame Dialog-Frame .
      return error .
    end.
  end.
  if not infoSectionTotal:FlagTrn then return.
  define variable stfactplvalue as character no-undo initial ? .
  define variable stfactpltype  as character no-undo initial ? .
  define variable v-update      as logical   no-undo initial true .
  define variable v-revision    as logical   no-undo initial false .
  define variable v-percrev     as decimal   no-undo initial ? .
  define variable v-auto-tank   as logical   no-undo initial false .
  define variable v-percauto    as decimal   no-undo initial ? .
  define variable v-inv         as logical   no-undo initial false .
  define variable v-percinv     as decimal   no-undo initial ? .
  define variable v-inv-set     as logical   no-undo initial false .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
  if error-status :error then do:
  end.
  if stfactplvalue <> "":U then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output v-update
  , output v-revision
  , output v-percrev
  , output v-auto-tank
  , output v-percauto
  , output v-inv
  , output v-percinv
  , output v-inv-set
  )  .
  end.
  if v-auto-tank = true
    or v-inv = true
  then do:
    if input frame Dialog-Frame f-car-vol <= 0 or
       input frame Dialog-Frame f-car-vol = ?
    then do:
      message "Объем по паспорту в литрах должен быть больше 0." view-as alert-box .
      apply "entry" to f-car-vol in frame Dialog-Frame .
      return error .
    end.
    if rdc-dnstvalue = "pomi-rn"  then do:
        if f-place-si:screen-value <> "" and input frame Dialog-Frame f-place-si <> 0 then do:
           if v-sr-type = 1 or v-sr-type = 2 then do:
           end.
        end.
        if f-place-si:screen-value <> "" then do:
           if v-sr-type = 3 or v-sr-type = 4 then do:
          end.
        end.
    end.
    if rdc-dnstvalue = "pomi-rn" then do:
        if input frame Dialog-Frame f-tank-vol <= 0 or
           input frame Dialog-Frame f-tank-vol  = ?
        then do:
          message "Объем топлива должен быть больше 0." view-as alert-box .
          apply "entry" to f-tank-vol in frame Dialog-Frame .
          return error .
        end.
        if input frame Dialog-Frame f-tank-weight <= 0 or
           input frame Dialog-Frame f-tank-weight  = ?
        then do:
          message "Вес топлива должен быть больше 0." view-as alert-box .
          apply "entry" to f-tank-weight in frame Dialog-Frame .
          return error .
        end.
        if input frame Dialog-Frame f-tank-density = ?
          or Valid-Density( input frame Dialog-Frame f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
        then do:
          message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
          apply "entry" to f-tank-density in frame Dialog-Frame .
          return error .
        end.
        if input frame Dialog-Frame f-place-si = 0
        then do:
          message "Введите средство измерения." view-as alert-box .
          apply "entry" to f-place-si in frame Dialog-Frame .
          return error .
        end.
        end.
  end.
  if input frame Dialog-Frame f-hour-start <> ?
    and input frame Dialog-Frame f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return error .
  end.
  if input frame Dialog-Frame f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame Dialog-Frame .
     return error .
  end.
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame Dialog-Frame .
     return error .
  end.
  if input frame Dialog-Frame f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame Dialog-Frame .
     return error .
  end.
  if input frame Dialog-Frame f-sec-num = ""
  then do:
     message "Не указан номер секции" view-as alert-box .
     apply "entry" to f-sec-num in frame Dialog-Frame .
     return error .
  end.
if input frame Dialog-Frame f-hour-prob > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame Dialog-Frame .
     return error .
  end.
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame Dialog-Frame .
     return error .
  end.
  assign
    f-list-tank = f-list-tank:screen-value in frame Dialog-Frame.
  for each buf_doc-pl where buf_doc-pl.out-code = p-doc-code and buf_doc-pl.gds-code = p-gds-code:
    find first ub.place no-lock where ub.place.pl-code = buf_doc-pl.pl-code no-error.
    v-list-tank = v-list-tank + "," + ub.place.loc1.
  end.
  v-list-tank = left-trim (v-list-tank, ",").
  do ii = 1 to num-entries (f-list-tank):
    if lookup (entry (ii, f-list-tank), v-list-tank) = 0
    then do:
      message substitute ("Неверно указаны резервуары") view-as alert-box.
      apply "entry" to f-list-tank in frame Dialog-Frame .
      return error.
    end.
  end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-acc-ship f-cli-qnty
          f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2
          f-certif-fuel f-text3 f-validity-certif f-a-b-tarir f-mouth
          f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp
          f-EU-weight f-list-tank f-loss-norm f-place-si f-num-plotn
          f-date-pov-plotn f-tank-weight f-tank-density-pomi f-acc-weight
          f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end
          f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob
          f-min-prob f-date-prob f-place-si-name
      WITH FRAME Dialog-Frame.
  ENABLE Rect-Main Rect-Bottom Rect-Left Rect-Right Rect-Top RECT-3 RECT-1
         RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 b-save b-quit b-del-sec b-help
         f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol
         f-num-passport f-norm-doc f-certif-fuel f-validity-certif f-a-b-tarir
         f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp
         f-list-tank r-list-tank f-acc-ship f-num-plotn
         f-date-pov-plotn f-date-start f-hour-start f-min-start f-date-end
         f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob
         f-min-prob f-date-prob
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE hide-disp-page :
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  if not infoSectionTotal:FlagTrn and (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) then do:
    enable RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm with frame Dialog-Frame.
    hide RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm in frame Dialog-Frame.
    display f-doc-qnty f-acc-ship f-doc-dens f-cli-qnty f-sec-num f-ttn-temp with frame Dialog-Frame.
    enable f-doc-qnty f-acc-ship f-doc-dens f-cli-qnty f-sec-num f-ttn-temp with frame Dialog-Frame.
    if infoSectionTotal:CliQntyInput and (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U)
      then enable f-cli-qnty with frame Dialog-Frame.
    else disable f-cli-qnty with frame Dialog-Frame.
    if infoSectionTotal:DocQntyInput and (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U)
      then enable f-doc-qnty with frame Dialog-Frame.
    else disable f-doc-qnty with frame Dialog-Frame.
    if infoSectionTotal:DensityInput and (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U)
      then enable f-doc-dens with frame Dialog-Frame.
    else disable f-doc-dens with frame Dialog-Frame.
    return.
  end.
  display RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm with frame Dialog-Frame.
  define variable IsKPPageCurrent as logical no-undo.
  IsKPPageCurrent = infoSectionTotal:GetInfoSectionProp(v-page-current):IsKP.
  iTemp = infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi.
  find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = iTemp no-error.
  if available buf_sr-izmerenia then do:
    assign
      f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
      v-sr-type = buf_sr-izmerenia.sr-type-id.
  end.
  else
    assign
      f-place-si-name:screen-value = ""
      v-sr-type = 0.
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  if v-sr-type = 0 then
  do:
    hide
      f-num-plotn
      f-date-pov-plotn
      b-choose-date-pov-plotn
      f-passport-plotn
      in frame Dialog-Frame.
  end.
  else
  do:
    if v-sr-type = 1 or v-sr-type = 2 then
    do:
      enable
        f-num-plotn
        f-date-pov-plotn
        b-choose-date-pov-plotn
        with frame Dialog-Frame.
      hide
        f-passport-plotn
        in frame Dialog-Frame.
    end.
    if v-sr-type = 3 or v-sr-type = 4 then
    do:
      enable
        f-num-plotn
        f-date-pov-plotn
        b-choose-date-pov-plotn
        f-passport-plotn
        with frame Dialog-Frame.
    end.
  end.
  display
    f-car-vol f-tests f-sec-num f-doc-qnty
    f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-tank-vol f-tank-temp f-tank-water f-tank-density
    f-tank-weight
    f-mouth
    f-a-b-tarir
    f-tank-vol-pomi f-dens-temp
    f-certif-fuel f-norm-doc
    f-num-passport f-validity-certif f-list-tank r-list-tank
    f-kol-prob f-num-print-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-size f-acc-ship f-EU-weight f-loss-norm
    with frame Dialog-Frame.
  if rdc-dnstvalue <> "not" and p-mode <> 'ПРОСМОТР':U  then
  do :
    disable
      f-mouth
      f-tank-density-pomi
      with frame Dialog-Frame.
    display
      f-size
      f-place-si
      r-sr-izm
      f-tank-density-pomi
      b-calc
      b-copy-iz
      b-copy-pass
      with frame Dialog-Frame.
    enable
      f-size
      f-place-si
      r-sr-izm
      b-calc
      b-copy-iz
      b-copy-pass
      with frame Dialog-Frame.
  end.
  if rdc-dnstvalue = "manual"
    then
  do:
    disable
      b-calc
      with frame Dialog-Frame.
    enable
      f-tank-vol-pomi
      f-tank-density-pomi
      with frame Dialog-Frame.
  end.
  if rdc-dnstvalue = "" or rdc-dnstvalue = ? or rdc-dnstvalue = "not" then
  do:
    rdc-dnstvalue = "not".
    disable
      f-tank-vol
      f-tank-temp
      f-tank-water
      f-tank-weight
      with frame Dialog-Frame.
    enable
      f-mouth
      f-a-b-tarir
      f-dens-temp
      f-tank-density
      f-car-vol f-tests f-sec-num f-doc-qnty
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      f-kol-prob f-num-print-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-acc-ship
      with frame Dialog-Frame.
    hide
      f-tank-vol-pomi
      f-tank-density-pomi
      in frame Dialog-Frame.
  end.
  if rdc-dnstvalue <> "pomi-rn" then do:
      HIDE
        f-tests f-num-print-prob f-kol-prob f-hour-prob
        f-min-prob f-date-prob f-acc-weight
      in frame Dialog-Frame .
  end.
  if infoSectionTotal:CliQntyInput and p-mode = 'ИЗМЕНЕНИЕ':U
    then
      assign
        f-cli-qnty:sensitive = true
        f-cli-qnty:fgcolor = 12
      .
  else disable f-cli-qnty with frame Dialog-Frame.
  if infoSectionTotal:DocQntyInput and p-mode = 'ИЗМЕНЕНИЕ':U
    then
      assign
        f-doc-qnty:sensitive = true
        f-doc-qnty:fgcolor = 12.
  else disable f-doc-qnty with frame Dialog-Frame.
  if infoSectionTotal:DensityInput and p-mode = 'ИЗМЕНЕНИЕ':U
    then
      assign
        f-doc-dens:sensitive = true
        f-doc-dens:fgcolor = 12.
  else disable f-doc-dens with frame Dialog-Frame.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then
  do:
    disable
      f-car-vol f-tests f-sec-num f-doc-qnty
      f-tank-vol f-tank-temp f-tank-water f-tank-density
      f-tank-weight
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      f-tank-vol-pomi f-dens-temp
      f-tank-density-pomi
      f-size
      f-place-si
      r-sr-izm
      b-calc
      b-copy-iz
      b-copy-pass
      b-save
      b-del-sec
      f-mouth
      f-a-b-tarir
      f-certif-fuel f-norm-doc f-num-passport f-validity-certif f-list-tank r-list-tank
      f-date-pov-plotn b-choose-date-pov-plotn f-passport-plotn f-num-plotn
      f-cli-qnty
      f-doc-qnty
      f-doc-dens
      f-kol-prob
      f-num-print-prob
      f-date-prob
      f-hour-prob
      f-min-prob
      f-ttn-temp
      f-acc-ship
      f-EU-weight
      f-loss-norm
      with frame Dialog-Frame.
  end.
  assign
    f-size:fgcolor = 12 when f-size:sensitive
    f-doc-dens:fgcolor = 12 when f-doc-dens:sensitive
    f-tank-vol:fgcolor = 12 when f-tank-vol:sensitive
    f-car-vol:fgcolor = 12 when f-car-vol:sensitive
    f-tank-density:fgcolor = 12 when f-tank-density:sensitive
    f-tank-weight:fgcolor = 12 when f-tank-weight:sensitive
    f-sec-num:fgcolor = 12 when f-sec-num:sensitive
    f-place-si:fgcolor = 12 when f-place-si:sensitive and rdc-dnstvalue = "pomi-rn"
    f-tank-temp:fgcolor = 12 when f-tank-temp:sensitive and rdc-dnstvalue = "pomi-rn"
    f-dens-temp:fgcolor = 12 when f-dens-temp:sensitive and rdc-dnstvalue = "pomi-rn"
    f-tank-density-pomi:fgcolor = 12 when f-tank-density-pomi:sensitive
    f-tank-vol-pomi:fgcolor = 12 when f-tank-vol-pomi:sensitive
  .
  assign
    f-size:screen-value = "0" when f-size:screen-value = "".
end procedure.
PROCEDURE initialize-section :
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
display RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm with frame Dialog-Frame.
  hide f-car-vol-total f-tank-weight-total f-tank-vol-total f-doc-qnty-total in frame Dialog-Frame.
  if v-page-current  = infoSectionTotal:SectionNum + 1 and (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then do:
    v-section-names = "".
    infoSectionTotal:NewSection().
    do ii = 1 to infoSectionTotal:SectionNum:
      v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
    end.
    if infoSectionTotal:FlagTrn
      then v-section-names = trim (v-section-names, "|") + (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + "|Сумма".
      else v-section-names = trim (v-section-names, "|") + (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then "|         +" else "").
    run initialize-folder (v-section-names).
    run show-current-page(input infoSectionTotal:SectionNum).
    run hide-disp-page.
  end.
  if v-page-current  = (infoSectionTotal:SectionNum + 2 - (if (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and infoSectionTotal:SectionNum < maxSec then 0 else 1)) then do:
    hide RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm in frame Dialog-Frame.
    infoSectionTotal:CalculateTotal().
    run check-data no-error.
    assign
      f-car-vol-total = infoSectionTotal:CarVolTotal
      f-tank-vol-total = infoSectionTotal:TankVolTotal
      f-tank-weight-total = infoSectionTotal:TankWeightTotal
      f-doc-qnty-total = infoSectionTotal:DocQntyTotal.
    display f-car-vol-total f-tank-weight-total f-tank-vol-total f-doc-qnty-total with frame Dialog-Frame.
  end.
  else do:
    assign
      f-tests = infoSectionTotal:GetInfoSectionProp(v-page-current):Tests
      f-sec-num = infoSectionTotal:GetInfoSectionProp(v-page-current):SectionName
      f-ttn-temp = infoSectionTotal:GetInfoSectionProp(v-page-current):TTNTemp
      f-num-print-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPrintProb
      f-kol-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):KolProb
      f-date-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):DateProb
      f-hour-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):HourProb
      f-min-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):MinProb
      f-EU-weight = infoSectionTotal:GetInfoSectionProp(v-page-current):NaturalLoss
    .
    assign
      f-car-vol = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol) no-error
    .
    f-car-vol:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol) no-error.
    assign
      f-certif-fuel = infoSectionTotal:GetInfoSectionProp(v-page-current):CertifFuel
      f-norm-doc = infoSectionTotal:GetInfoSectionProp(v-page-current):NormDoc
      f-num-passport = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPassport
      f-validity-certif = infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif
      f-list-tank = infoSectionTotal:GetInfoSectionProp(v-page-current):ListTank
      f-num-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn
      f-date-pov-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn
      f-passport-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn
      f-validity-certif = infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif
      f-acc-ship = infoSectionTotal:GetInfoSectionProp(v-page-current):AccShip
      f-loss-norm = infoSectionTotal:GetInfoSectionProp(v-page-current):TPNorm
    .
    if error-status:error then
      message "Неверно задан объем автоцистерны по паспорту " infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol " ."
      view-as alert-box error.
    assign
    f-tank-vol  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol) no-error.
    if error-status:error then
      message "Неверно определен объем в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol " . "
      view-as alert-box.
    assign
    f-tank-temp  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp) no-error.
    if error-status:error then
      message "Неверно определена температура в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp " . "
      view-as alert-box.
    assign
    f-tank-water  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater) no-error.
    if error-status:error then
      message "Неверно определен объем воды в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater " . "
      view-as alert-box.
    assign
    f-tank-density  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity) no-error.
    if error-status:error then
      message "Неверно определена плотность в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity " . "
      view-as alert-box.
    assign
    f-tank-weight  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight) no-error.
    if error-status:error then
      message "Неверно определен вес в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight " . "
      view-as alert-box.
    if rdc-dnstvalue = "pomi-rn"
    then do:
      f-acc-weight  = round (decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi), 3) no-error.
      if error-status:error then
        message "Неверно определена погрешнность измерения массы в библиотекие для работы с ПО МИ " infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi " . "
        view-as alert-box.
    end.
    if infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart = ? then f-date-start = infoSectionTotal:GetInfoSectionProp(1):DateStart .
    else f-date-start = infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart .
    if infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd = ? then f-date-end = infoSectionTotal:GetInfoSectionProp(1):DateEnd .
    else f-date-end = infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd .
    if infoSectionTotal:GetInfoSectionProp(v-page-current):TimeStart = 0 then
    do:
        f-hour-start = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeStart / 3600 , 0 ) ).
        f-min-start  = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeStart - f-hour-start * 3600 ) / 60 ).
    end.
    else
    do:
        f-hour-start = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeStart / 3600 , 0 ) ).
        f-min-start  = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeStart - f-hour-start * 3600 ) / 60 ).
    end.
    if infoSectionTotal:GetInfoSectionProp(v-page-current):TimeEnd = 0 then
    do:
        f-hour-end   = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeEnd / 3600 , 0 ) ).
        f-min-end    = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeEnd - f-hour-end * 3600 ) / 60).
    end.
    else
    do:
        f-hour-end   = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeEnd / 3600 , 0 ) ).
        f-min-end    = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeEnd - f-hour-end * 3600 ) / 60).
    end.
    assign
      f-mouth = decimal (infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth) no-error.
    if error-status:error then
      message "Неверно определен объем топлива в горловине " infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth " . "
      view-as alert-box.
    assign
    f-a-b-tarir  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir) no-error.
    if error-status:error then
      message "Неверно определен уровень цистерны относительно тарировочной планки " infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir " . "
      view-as alert-box.
    assign
    f-size = infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter no-error.
    if error-status:error then
      message "Неверно определен внутренний диаметр горловины" infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter " . "
      view-as alert-box.
    f-size:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter) no-error.
    assign
    f-place-si = integer(infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi) no-error.
    if error-status:error then
      message "Неверно определено средство измерения" infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi " . "
      view-as alert-box.
    f-tank-density-pomi = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi) no-error.
    if error-status:error then
      message "Неверно определена приведенная плотность" infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi " . "
      view-as alert-box.
    assign
    f-tank-vol-pomi  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi) no-error.
    if error-status:error then
      message "Неверно определен объем в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi " . "
      view-as alert-box.
    assign
    f-dens-temp  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):DensTemp) no-error.
    if error-status:error then
      message "Неверно определена температура в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp " . "
      view-as alert-box.
    assign
      f-doc-qnty = infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty
      f-doc-dens = infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity
      f-cli-qnty = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty
    no-error.
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = f-place-si no-error.
    if available buf_sr-izmerenia then do:
      assign
        f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
        v-sr-type = buf_sr-izmerenia.sr-type-id.
    end.
    else
      assign
        f-place-si-name:screen-value = ""
        v-sr-type = 0.
    run hide-disp-page.
  end.
end.
PROCEDURE initialize-folder :
  define input parameter folder-labels as character no-undo.
  define variable i             as integer   no-undo.
  define variable temp-hdl      as handle    no-undo.
  define variable del-hdl       as handle    no-undo.
  define variable rebuild       as logical   no-undo init no.
  define variable sts           as logical   no-undo.
  assign
    tab-type = 1 .
  assign
    number-of-pages = num-entries(folder-labels,'|':U).
  if valid-handle(up-image) then
  do:
    temp-hdl = frame Dialog-Frame:HANDLE.
    temp-hdl = temp-hdl:first-child.
    temp-hdl = temp-hdl:first-child.
    do while valid-handle(temp-hdl):
      del-hdl = temp-hdl.
      temp-hdl = temp-hdl:next-sibling.
      if del-hdl:private-data = "Tab-Folder":U then delete widget del-hdl.
    end.
  end.
  create image up-image
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = 0 + pos-x
    y                 = 0 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25 + 4
    private-data      = "Tab-Folder":U
    hidden            = no.
  assign
    sts = up-image:load-image("adeicon/ts-up":U +
         STRING(width-tab-values[tab-type])).
  do i = 1 to number-of-pages:
    if entry(i,folder-labels,'|':U) ne "":U then
      run create-folder-label (i, entry(i, folder-labels,'|':U)).
  end.
  view frame Dialog-Frame.
  run change-folder-page.
  return.
end procedure.
PROCEDURE change-folder-page :
  define variable sts   as logical no-undo.
  define variable page# as integer no-undo.
  if page# > 0 and page# <= 20 and
    VALID-HANDLE (page-label[page#]) then
  do:
    assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  end.
  return.
end procedure.
PROCEDURE create-folder-label :
  define input parameter p-page#        as integer   no-undo.
  define input parameter p-page-label   as character no-undo.
  define variable sts as log no-undo.
  create image image-hdl[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = (p-page# - 1) * width-tab-values[tab-type] + pos-x
    y                 = 2 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25
    private-data      = "Tab-Folder":U
    sensitive         = yes
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  create text page-label[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    y                 = image-hdl[p-page#]:y + 2
    x                 = image-hdl[p-page#]:x + 9
    width-pixel       = image-hdl[p-page#]:WIDTH-PIXEL - 18
    height-pixel      = image-hdl[p-page#]:HEIGHT-PIXEL - 4
    format            = "X(13)":U
    sensitive         = yes
    font              = if tab-type = 1 then ? else 4
    bgcolor           = 8
    screen-value      = p-page-label
    private-data      = "Tab-Folder":U
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  assign
    sts = image-hdl[p-page#]:load-image("adeicon/ts-dn":U +
                STRING(width-tab-values[tab-type])).
  sts = image-hdl[p-page#]:move-to-top().
  sts = page-label[p-page#]:move-to-top().
  assign
    page-enabled[p-page#]      = yes
    image-hdl[p-page#]:hidden  = no
    page-label[p-page#]:hidden = no.
  return.
end procedure.
PROCEDURE create-folder-page :
  define input parameter p-page#      as integer   no-undo.
  define input parameter p-new-label  as character no-undo.
  define variable i          as integer   no-undo.
  define variable num-labels as integer   no-undo.
  define variable labels     as character no-undo.
  define variable new-labels as character no-undo init "".
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if labels = ? then labels = "".
  num-labels = num-entries(labels,'|':U).
  if p-page# <= num-labels then
  do i = 1 to num-labels:
    new-labels = new-labels +
      if i = p-page# then p-new-label
      else entry(i, labels, '|':U).
    if i < num-labels then new-labels = new-labels + '|':U.
  end.
  else
  do:
    new-labels = labels.
    do i = 1 to p-page# - num-labels - if num-labels = 0 then 1 else 0:
      new-labels = new-labels + '|':U.
    end.
    new-labels = new-labels + p-new-label.
  end.
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + new-labels).
  run initialize-folder.
  return.
end procedure.
PROCEDURE delete-folder-page :
  define input parameter p-page#  as integer no-undo.
  define variable i      as integer   no-undo.
  define variable pos1   as integer   no-undo init 0.
  define variable pos2   as integer   no-undo.
  define variable labels as character no-undo.
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if valid-handle (page-label[p-page#]) then
    delete widget page-label[p-page#].
  if valid-handle (image-hdl[p-page#]) then
    delete widget image-hdl[p-page#].
  do i = 1 to p-page# - 1:
    pos1 = index(labels,'|':U, pos1 + 1).
  end.
  pos2 = index(labels,'|':U, pos1 + 1).
  labels = if pos2 ne 0 then SUBSTR(labels, 1, pos1, "CHARACTER":U) +
    SUBSTR(labels, pos2, -1, "CHARACTER":U)
    else SUBSTR(labels, 1, pos1 - 1, "CHARACTER":U).
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + labels).
  return.
end procedure.
PROCEDURE disable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = no
    page-label[p-page#]:fgcolor = 7.
  return.
end procedure.
PROCEDURE enable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = yes
    page-label[p-page#]:fgcolor = ?.
  return.
end procedure.
PROCEDURE label-trigger :
  define input parameter p-page# as integer no-undo.
  v-page = p-page#.
  run trg-folder in this-procedure no-error.
  if error-status:error
    then return.
  run show-current-page(input p-page#).
  return.
end procedure.
PROCEDURE local-initialize :
  run initialize-folder.
  run dispatch in THIS-PROCEDURE ('initialize':U).
  return.
end procedure.
PROCEDURE set-size :
  define input parameter p-height as decimal no-undo.
  define input parameter p-width  as decimal no-undo.
  define variable sts as logical.
  if p-height < 1.35 then p-height = 1.35.
  do with frame Dialog-Frame:
    assign
      Rect-Main:X               = 0 + pos-x
      Rect-Main:Y               = 25 + pos-y
      Rect-Main:WIDTH-PIXELS    = p-width
      Rect-Main:HEIGHT-PIXELS   = p-height
                                     - 25
      Rect-Top:X                = 1 + pos-x
      Rect-Top:Y                = 25 + 1 + pos-y
      Rect-Top:WIDTH-PIXELS     = p-width
                                     - 3
      Rect-Top:HEIGHT-PIXELS    = 3
      Rect-Bottom:X             = 1 + pos-x
      Rect-Bottom:Y             = p-height - 4 + pos-y
      Rect-Bottom:HEIGHT-PIXELS = 3
      Rect-Bottom:WIDTH-PIXELS  = p-width
                                     - 2
      Rect-Left:X               = 1 + pos-x
      Rect-Left:Y               = 25 + 1 + pos-y
      Rect-Left:WIDTH-PIXELS    = 3
      Rect-Left:HEIGHT-PIXELS   = p-height
                                     - 25 - 2
      Rect-Right:X              = p-width + pos-x
                                     - 4
      Rect-Right:Y              = 25 + 4 + pos-y
      Rect-Right:WIDTH-PIXELS   = 3
      Rect-Right:HEIGHT-PIXELS  = p-height
                                     - 25 - 5
      Rect-Main:HIDDEN          = no
      Rect-Top:HIDDEN           = no
      Rect-Bottom:HIDDEN        = no
      Rect-Left:HIDDEN          = no
      Rect-Right:HIDDEN         = no.
  end.
  return.
end procedure.
PROCEDURE show-current-page :
  define input parameter page# as integer no-undo.
  define variable sts as logical no-undo.
  if page# > 0 and page# <= 20 and
    VALID-HANDLE (page-label[page#])
    then assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  else if number-of-pages > 0 then
      assign up-image:hidden = yes.
end procedure.
PROCEDURE state-changed :
  define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.
PROCEDURE trg-folder :
apply "leave" to f-sec-num in frame Dialog-Frame.
  if v-page-current <= infoSectionTotal:SectionNum
  then do:
    run check-page no-error.
    if error-status:error then do:
      return error.
    end.
    run save-page.
    apply "LEAVE":U to f-car-vol      in frame Dialog-Frame .
    apply "LEAVE":U to f-tank-density in frame Dialog-Frame .
    run calc-doc.
  end.
  v-page-current = v-page.
  run initialize-section.
end.
procedure save-page:
  if v-page-current > infoSectionTotal:SectionNum then return.
  assign frame Dialog-Frame
    f-sec-num f-tests f-doc-qnty f-doc-dens f-cli-qnty f-car-vol f-size
    f-num-passport f-norm-doc f-certif-fuel f-validity-certif f-list-tank
    f-a-b-tarir f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp
    f-num-plotn f-date-pov-plotn f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-doc-qnty f-doc-dens f-cli-qnty
    f-passport-plotn f-num-plotn f-place-si
    f-num-print-prob f-kol-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-acc-ship f-EU-weight f-loss-norm
  .
  assign
    infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol = f-car-vol
    infoSectionTotal:GetInfoSectionProp(v-page-current):Tests  = f-tests
    infoSectionTotal:GetInfoSectionProp(v-page-current):SectionName  = f-sec-num
    infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty  = f-doc-qnty
    infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty  = f-cli-qnty
    infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity  = f-doc-dens
    infoSectionTotal:GetInfoSectionProp(v-page-current):TimeStart = f-hour-start * 3600 + f-min-start * 60
    infoSectionTotal:GetInfoSectionProp(v-page-current):TimeEnd = f-hour-end   * 3600 + f-min-end   * 60
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart = f-date-start
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd = f-date-end
    infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth =  f-mouth
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol = f-tank-vol
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp = f-tank-temp
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi = f-tank-vol-pomi
    infoSectionTotal:GetInfoSectionProp(v-page-current):DensTemp =  f-dens-temp
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater = f-tank-water
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity = f-tank-density
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight =  f-tank-weight
    infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi =  f-acc-weight when rdc-dnstvalue = "pomi-rn"
    infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir = f-a-b-tarir
    infoSectionTotal:GetInfoSectionProp(v-page-current):AccShip = f-acc-ship
    infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter =  f-size
    infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi = f-place-si
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi = f-tank-density-pomi
    infoSectionTotal:GetInfoSectionProp(v-page-current):CertifFuel = string (f-certif-fuel)
    infoSectionTotal:GetInfoSectionProp(v-page-current):NormDoc = string (f-norm-doc)
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPassport = string (f-num-passport)
    infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif = string (f-validity-certif)
    infoSectionTotal:GetInfoSectionProp(v-page-current):ListTank = string (f-list-tank)
    infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = f-passport-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPrintProb = f-num-print-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):KolProb = f-kol-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateProb = f-date-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):HourProb = f-hour-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):MinProb = f-min-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):TTNTemp  = f-ttn-temp
  no-error.
  if infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi <> 0 then do:
    if v-sr-type = 1 or v-sr-type = 2 then do:
      assign
      infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = ""
      infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn.
    end.
    if v-sr-type = 3 or v-sr-type = 4 then do:
      assign
      infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = f-passport-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn.
    end.
  end.
end procedure.
