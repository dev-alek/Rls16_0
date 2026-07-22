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
define input        parameter parparentproc       as   handle                no-undo .
define input        parameter p-mode              as   character             no-undo .
define input        parameter p-doc-code          like ub.trn-doc.doc-code   no-undo .
define input        parameter p-gds-code          like ub.goods.gds-code     no-undo .
define input-output parameter p-car-num           as   character             no-undo .
define input-output parameter p-car-vol           as   character             no-undo .
define input-output parameter p-tests             as   character             no-undo .
define input-output parameter p-autoent-obj-type  as   character             no-undo .
define input-output parameter p-autoent-obj-code  as   character             no-undo .
define input-output parameter p-item-pour         as   character             no-undo .
define input-output parameter p-time-pour         as   character             no-undo .
define input-output parameter p-tank-vol          as   character             no-undo .
define input-output parameter p-tank-temp         as   character             no-undo .
define input-output parameter p-tank-water        as   character             no-undo .
define input-output parameter p-tank-density      as   character             no-undo .
define input-output parameter p-tank-weight       as   character             no-undo .
define input-output parameter p-time-income       as   character             no-undo .
define input-output parameter p-date-start        like ub.rvs-line.real-date no-undo .
define input-output parameter p-time-start        like ub.rvs-line.real-time no-undo .
define input-output parameter p-date-end          like ub.rvs-line.real-date no-undo .
define input-output parameter p-time-end          like ub.rvs-line.real-time no-undo .
define input-output parameter p-mouth             as   character             no-undo .
define input-output parameter p-fio               as   character             no-undo .
define input-output parameter p-ptbotype          as   character             no-undo .
define input-output parameter p-ptbocode          as   character             no-undo .
define input-output parameter p-a-b-tarir         as   character             no-undo .
define input-output parameter p-diameter          as   character             no-undo .
define input-output parameter p-place-si          as   character             no-undo .
define input-output parameter p-tank-density-pomi as   character             no-undo .
define input-output parameter p-certif-fuel       as   character             no-undo .
define input-output parameter p-norm-doc          as   character             no-undo .
define input-output parameter p-num-passport      as   character             no-undo .
define input-output parameter p-validity-certif   as   character             no-undo .
define input-output parameter p-passport-plotn    as   character             no-undo .
define input-output parameter p-num-plotn         as   character             no-undo .
define input-output parameter p-date-pov-plotn    like ub.rvs-line.real-date no-undo .
define       output parameter p-was-setting       as   logical               no-undo initial no .
define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable pomi-licvalue as character no-undo.
define variable pomi-lictype  as character no-undo.
define stream outstream.
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
DEFINE BUTTON b-auto-tank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-clients"
     SIZE 3 BY .88.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-ptb
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-ptb"
     SIZE 3 BY .88.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-sr-izm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm"
     SIZE 3 BY .88.
DEFINE VARIABLE f-a-b-tarir AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Уровень цистерны относительно тарировочной планки"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Автопредприятие"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.88 BY 1.04 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Гос. N автоцистерны"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем по паспорту в литрах"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U
     LABEL "Дата конца слива"
     VIEW-AS FILL-IN
     SIZE 10 BY .88 NO-UNDO.
DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала слива"
     VIEW-AS FILL-IN
     SIZE 10 BY .88 NO-UNDO.
DEFINE VARIABLE f-diameter AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Внутренний диаметр горловины"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-fio AS CHARACTER FORMAT "X(256)":U
     LABEL "Ф.И.О. водителя-экспедитора"
     VIEW-AS FILL-IN
     SIZE 49.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время конца слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-income AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время прибытия на АЗС"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-pour AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время налива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время начала слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-item-pour AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-income AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-pour AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-mouth AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Горловина"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptbocode AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Нефтебаза"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptboname AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptbotype AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-density AS DECIMAL FORMAT "9.9999999999":U INITIAL ?
     LABEL "Плотность топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-density-pomi AS DECIMAL FORMAT "9.9999999999":U INITIAL ?
     LABEL "Плотность топлива для ПО МИ"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-temp AS DECIMAL FORMAT "->9.999":U INITIAL ?
     LABEL "Температура"
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-water AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем воды"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tank-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Вес топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-tests AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер пробы"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-place-si AS INTEGER FORMAT ">>>,>>9":U INITIAL 0
     LABEL "Средство измерения"
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 80.25 BY 8.25.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 80.13 BY 4.21.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 71
     f-autoent-obj-code AT ROW 2.46 COL 16 COLON-ALIGNED
     f-autoent-obj-type AT ROW 2.46 COL 27.75 COLON-ALIGNED NO-LABEL
     f-autoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.5
     f-car-num AT ROW 3.75 COL 20 COLON-ALIGNED
     f-car-vol AT ROW 3.75 COL 65.75 COLON-ALIGNED
     b-auto-tank AT ROW 3.79 COL 36.38
     f-tests AT ROW 4.92 COL 20.13 COLON-ALIGNED
     f-fio AT ROW 6.04 COL 30 COLON-ALIGNED
     f-ptbocode AT ROW 7.25 COL 16 COLON-ALIGNED
     f-ptbotype AT ROW 7.25 COL 27.75 COLON-ALIGNED NO-LABEL
     f-ptboname AT ROW 7.25 COL 36 COLON-ALIGNED NO-LABEL
     b-ptb AT ROW 7.38 COL 34.5
     f-hour-pour AT ROW 8.25 COL 73 COLON-ALIGNED
     f-min-pour AT ROW 8.25 COL 76.5 COLON-ALIGNED NO-LABEL
     f-item-pour AT ROW 9.5 COL 1.5 NO-LABEL
     f-tank-water AT ROW 11.71 COL 64.75 COLON-ALIGNED
     f-mouth AT ROW 11.79 COL 20.75 COLON-ALIGNED
     f-tank-vol AT ROW 12.96 COL 20.63 COLON-ALIGNED
     f-tank-temp AT ROW 12.96 COL 64.75 COLON-ALIGNED
     f-tank-density AT ROW 14.13 COL 20.5 COLON-ALIGNED
     b-calc AT ROW 14.13 COL 37.5 WIDGET-ID 22
     f-tank-weight AT ROW 14.13 COL 64.75 COLON-ALIGNED
     f-a-b-tarir AT ROW 15.13 COL 64.75 COLON-ALIGNED WIDGET-ID 2
     f-place-si AT ROW 16.25 COL 20.5 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 16.25 COL 28.5 WIDGET-ID 18
     f-diameter AT ROW 16.25 COL 64.75 COLON-ALIGNED WIDGET-ID 20
     f-tank-density-pomi AT ROW 17.5 COL 29.5 COLON-ALIGNED WIDGET-ID 24
     f-hour-income AT ROW 19.54 COL 71.75 COLON-ALIGNED
     f-min-income AT ROW 19.54 COL 75.38 COLON-ALIGNED NO-LABEL
     f-date-start AT ROW 21.25 COL 19.75 COLON-ALIGNED
     f-hour-start AT ROW 21.25 COL 71.75 COLON-ALIGNED
     f-min-start AT ROW 21.25 COL 75.38 COLON-ALIGNED NO-LABEL
     f-date-end AT ROW 22.33 COL 19.75 COLON-ALIGNED
     f-hour-end AT ROW 22.33 COL 71.75 COLON-ALIGNED
     f-min-end AT ROW 22.33 COL 75.38 COLON-ALIGNED NO-LABEL
     "Характеристики цистерны" VIEW-AS TEXT
          SIZE 23.63 BY .75 AT ROW 10.75 COL 26.25
     "Примечание к нефтебазе" VIEW-AS TEXT
          SIZE 25.5 BY 1 AT ROW 8.5 COL 1.5
     RECT-3 AT ROW 19.25 COL 1.5
     RECT-1 AT ROW 10.71 COL 1.5
     SPACE(0.12) SKIP(4.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация по приемке топлива"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
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
      return no-apply .
    end.
    if input frame Dialog-Frame f-tank-vol <= 0 or
       input frame Dialog-Frame f-tank-vol  = ?
    then do:
      message "Объем топлива должен быть больше 0." view-as alert-box .
      apply "entry" to f-tank-vol in frame Dialog-Frame .
      return no-apply .
    end.
    if input frame Dialog-Frame f-tank-weight <= 0 or
       input frame Dialog-Frame f-tank-weight  = ?
    then do:
      message "Вес топлива должен быть больше 0." view-as alert-box .
      apply "entry" to f-tank-weight in frame Dialog-Frame .
      return no-apply .
    end.
    if input frame Dialog-Frame f-tank-density = ?
      or Valid-Density( input frame Dialog-Frame f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
    then do:
      message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
      apply "entry" to f-tank-density in frame Dialog-Frame .
      return no-apply .
    end.
  end.
  if input frame Dialog-Frame f-tank-density <> ?
    and Valid-Density( input frame Dialog-Frame f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
  then do:
    message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
    apply "entry" to f-tank-density in frame Dialog-Frame .
    return no-apply .
  end.
  if input frame Dialog-Frame f-hour-pour <> ?
    and input frame Dialog-Frame f-hour-pour > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-pour in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-hour-start <> ?
    and input frame Dialog-Frame f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-min-pour > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-pour in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame Dialog-Frame .
     return no-apply .
  end.
  assign frame Dialog-Frame f-car-num f-car-vol f-tests
                             f-autoent-obj-type f-autoent-obj-code
                             f-item-pour f-hour-pour f-min-pour
                             f-hour-income f-min-income
                             f-hour-start f-min-start
                             f-hour-end f-min-end
                             f-date-start f-date-end
                             f-tank-vol f-tank-temp
                             f-tank-water f-tank-density
                             f-mouth f-fio
                             f-ptbocode
                             f-ptbotype
                             f-a-b-tarir
  .
  find clients no-lock where
       clients.obj-type = f-autoent-obj-type and
       clients.obj-code = f-autoent-obj-code no-error .
  if not available clients
  then do:
    assign
      v-log = no
    .
    message "Не найдено автопредприятие " f-autoent-obj-type " " f-autoent-obj-code " ." skip
            "Cохраняемся без ссылки на автопредприятие?"
    view-as alert-box question buttons yes-no update v-log .
    if v-log <> yes
    then do:
      return no-apply .
    end.
    assign
      f-autoent-obj-type = ""
      f-autoent-obj-code = ?
    .
  end.
  find clients no-lock where
       clients.obj-type = f-ptbotype and
       clients.obj-code = f-ptbocode no-error .
  if not available clients
  then do:
    assign
      v-log = no
    .
    message "Не найдена нефтебаза " f-ptbotype " " f-ptbocode " ." skip
            "Cохраняемся без ссылки на нефтебазу?"
    view-as alert-box question buttons yes-no update v-log .
    if v-log <> yes
    then do:
      return no-apply .
    end.
    assign
      f-ptbotype = ""
      f-ptbocode = ?
    .
  end.
  assign
    f-tank-weight = f-tank-vol * f-tank-density
  .
  assign
    p-car-num          = f-car-num
    p-car-vol          = string( f-car-vol )
    p-tests            = f-tests
    p-autoent-obj-type = f-autoent-obj-type
    p-autoent-obj-code = string( f-autoent-obj-code )
    p-item-pour        = f-item-pour
    p-time-pour        = string( f-hour-pour,   "99":U ) + ":" + string( f-min-pour,   "99":U )
    p-time-income      = string( f-hour-income, "99":U ) + ":" + string( f-min-income, "99":U )
    p-time-start       = f-hour-start * 3600 + f-min-start * 60
    p-time-end         = f-hour-end   * 3600 + f-min-end   * 60
    p-date-start       = f-date-start
    p-date-end         = f-date-end
    p-mouth            = string( f-mouth )
    p-fio              = f-fio
    p-ptbotype         = f-ptbotype
    p-ptbocode         = string( f-ptbocode     )
    p-tank-vol         = string( f-tank-vol     )
    p-tank-temp        = string( f-tank-temp    )
    p-tank-water       = string( f-tank-water   )
    p-tank-density     = string( f-tank-density )
    p-tank-weight      = string( f-tank-weight  )
    p-a-b-tarir        = string( f-a-b-tarir    )
    p-diameter         = string( f-diameter     )
    p-place-si         = string( f-place-si     )
    p-tank-density-pomi = string( f-tank-density-pomi )
  no-error .
  assign
    p-was-setting = yes
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-auto-tank IN FRAME Dialog-Frame
DO:
define variable v-rec-tank as recid     no-undo.
define variable v-rec-meas as recid     no-undo.
assign v-rec-tank = ?
       v-rec-meas = ?.
if v-autoent-obj-code <> 0 and v-autoent-obj-code <> ?
and can-find (first auto-tank-attr no-lock where auto-tank-attr.attr-code = "auto-firm"
                                             and auto-tank-attr.attr-value = v-autoent-obj-type + string(v-autoent-obj-code))
then do :
  run str/auto-tn.w (input parparentproc,
                input "b-sel",
                input v-autoent-obj-type,
                input v-autoent-obj-code,
                output v-rec-tank,
                output v-rec-meas) no-error.
end.
else do :
  message
  "Вы не указали автопредприятие или для " skip
  "указанного автопредприятия нет автоцистерн."   skip
  "Справочник будет открыт для всех автоцистерн." skip
  view-as alert-box information.
  run str/auto-tn.w (input parparentproc,
                input "b-sel",
                input "",
                input 0,
                output v-rec-tank,
                output v-rec-meas) no-error.
end.
if v-rec-tank <> ? then do:
  find first auto-tank where recid (auto-tank) = v-rec-tank no-lock.
  assign
      f-car-num    = auto-tank.auto-num
      f-car-vol    = auto-tank.brutto-qnty
      f-tank-vol   = f-car-vol
  .
  display f-car-num f-car-vol with frame Dialog-Frame.
  if v-rec-meas <> ? then do:
    find first auto-tank-meas where recid (auto-tank-meas) = v-rec-meas no-lock.
    assign
        f-tank-vol = auto-tank-meas.meas-qnty
    .
  end.
  assign
      f-mouth    = f-tank-vol - f-car-vol
  .
  display
    f-tank-vol
    f-mouth
  with frame Dialog-Frame.
end.
END.
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
DO:
  define variable ToolType                as integer no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable temp-for-pomi           as integer no-undo.
  define variable error-string            as character no-undo.
  define variable v-mm as com-handle.
  define variable v-proc as character no-undo.
  define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  assign
  f-car-vol
  f-tank-vol
  f-a-b-tarir
  f-diameter
  f-tank-temp
  f-tank-density-pomi
  .
  IF pomi-licvalue = "yes" THEN DO :
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
      find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input trn-doc.obj-type
  , input trn-doc.obj-code
  ) .
      if not error-status :error then do:
        if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                      else temp-for-pomi = 20 .
      end.
      v-proc = "Rosneft.MethodOfMetering31" .
      RELEASE OBJECT v-mm NO-ERROR.
      v-mm = ?.
      CREATE value("Rosneft.MethodOfMetering31") v-mm no-error.
      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-mm)
      THEN DO:
        RELEASE OBJECT v-mm NO-ERROR.
        v-mm = ?.
        message
          substitute( 'Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ ' ) skip
        view-as alert-box error.
        undo _trpomi, return no-apply .
      END.
      ELSE DO :
        if f-car-vol = ? or f-car-vol = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Объем по паспорту в литрах"  skip
          view-as alert-box error.
          apply "entry" to f-car-vol in frame Dialog-Frame .
          undo _trpomi, return no-apply  .
        end.
        if f-a-b-tarir = ? or f-a-b-tarir = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Уровень цистерны относительно тарировочной планки"  skip
          view-as alert-box error.
          apply "entry" to f-a-b-tarir in frame Dialog-Frame .
          undo _trpomi, return no-apply  .
        end.
        if f-diameter = ? or f-diameter = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Внутренний диаметр горловины"  skip
          view-as alert-box error.
          apply "entry" to f-diameter in frame Dialog-Frame .
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
        if f-tank-density-pomi = ? or f-tank-density-pomi = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Плотность топлива для ПО МИ"  skip
          view-as alert-box error.
          apply "entry" to f-tank-density-pomi in frame Dialog-Frame .
          undo _trpomi, return no-apply  .
        end.
        ASSIGN
          v-mm:V_real                 = f-car-vol
          v-mm:DeltaH                 = f-a-b-tarir
          v-mm:Dgor                   = f-diameter
          v-mm:Tv                     = f-tank-temp
          v-mm:Tr                     = f-tank-temp
          v-mm:R                      = ( f-tank-density-pomi * 1000 )
          v-mm:Tcy                    = temp-for-pomi
          v-mm:ToolType               = ToolType
          v-mm:A_Reservoir            = 0.0000125
          v-mm:DeltaOtn_V             = 0.4
          v-mm:DeltaAbs_R             = DeltaAbs_R
          v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
          v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
        .
        output stream outstream to value ("pomi.log") append.
        put stream outstream
                                     cur-time-string()       skip
          'Процедура'                v-proc                  skip
          'V_real                 =' f-car-vol               skip
          'DeltaH                 =' f-a-b-tarir             skip
          'Dgor                   =' f-diameter              skip
          'Tv                     =' f-tank-temp             skip
          'Tr                     =' f-tank-temp             skip
          'R                      =' ( f-tank-density-pomi * 1000 ) skip
          'Tcy                    =' temp-for-pomi           skip
          'ToolType               =' ToolType                skip
          'A_Reservoir            =' 0.0000125               skip
          'DeltaOtn_V             =' 0.4                     skip
          'DeltaAbs_R             =' DeltaAbs_R              skip
          'DeltaAbs_Tv            =' DeltaAbs_Tv             skip
          'DeltaAbs_Tr            =' DeltaAbs_Tr             skip
        .
        output stream outstream close.
        v-mm:Exec() .
        if v-mm:Result <> 0 then do :
          error-string = v-mm:ResultDetail .
          output stream outstream to value ("pomi.log") append.
            put stream outstream error-string format "x(1024)" skip.
          output stream outstream close.
          RELEASE OBJECT v-mm NO-ERROR.
          v-mm = ?.
          message
            substitute('Ошибка работы библиотеки ПО МИ &1',error-string) skip
          view-as alert-box error.
          undo _trpomi, return no-apply  .
        end.
        else do :
          assign
            f-tank-density    = decimal(v-mm:Rcy) / 1000
            f-tank-vol        = v-mm:Vcy
            f-tank-weight     = v-mm:Mcy
          .
          display
            f-tank-density
            f-tank-vol
            f-tank-weight
          with frame Dialog-Frame.
          output stream outstream to value ("pomi.log") append.
            put stream outstream
            "v-mm:Rcy" f-tank-density      skip
            "v-mm:Vcy" f-tank-vol          skip
            "v-mm:Mcy" f-tank-weight       skip .
          output stream outstream close.
          RELEASE OBJECT v-mm NO-ERROR.
          v-mm = ?.
        end.
      END.
    end.
  END.
  enable
  f-tank-density
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-clients IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.
find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
   run ref/cli-all.w (parparentproc
                , "b-sel"
                , 'орг':U
                , ?
                , ?
                , ?
                , ?
                , substitute("auto-tank-for-supp=&1&2",ub.trn-doc.cli-type,ub.trn-doc.cli-code)
                , output ref-list) .
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ f-autoent-obj-code
       clients.obj-type @ f-autoent-obj-type
       clients.obj-name @ f-autoent-obj-name with frame Dialog-Frame.
  assign
    v-autoent-obj-type = clients.obj-type
    v-autoent-obj-code = clients.obj-code
  .
end.
END.
ON CHOOSE OF b-ptb IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.
find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
   run ref/cli-all.w (parparentproc
                , "b-sel"
                , 'орг':U
                , ?
                , ?
                , ?
                , ?
                , substitute("tank-farm-for-supp=&1&2",ub.trn-doc.cli-type,ub.trn-doc.cli-code)
                , output ref-list) .
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ f-ptbocode
       clients.obj-type @ f-ptbotype
       clients.obj-name @ f-ptboname with frame Dialog-Frame.
end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  apply "LEAVE":U to f-car-vol      in frame Dialog-Frame .
  apply "LEAVE":U to f-tank-density in frame Dialog-Frame .
END.
ON LEAVE OF f-autoent-obj-code IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
END.
ON RETURN OF f-autoent-obj-code IN FRAME Dialog-Frame
DO:
run disp-obj-name.
apply "entry" to f-autoent-obj-code in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-autoent-obj-type IN FRAME Dialog-Frame
DO:
    run disp-obj-name.
END.
ON return OF f-autoent-obj-type IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
  apply "entry" to f-car-num in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-car-num IN FRAME Dialog-Frame
DO:
  apply "entry" to f-car-vol in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-car-vol IN FRAME Dialog-Frame
DO:
    if pomi-licvalue <> "yes" then do:
        display input frame Dialog-Frame f-car-vol + input frame Dialog-Frame f-mouth @ f-tank-vol with frame Dialog-Frame.
        display input frame Dialog-Frame f-tank-vol *
            input frame Dialog-Frame f-tank-density @ f-tank-weight with frame Dialog-Frame.
    end.
END.
ON return OF f-car-vol IN FRAME Dialog-Frame
DO:
  apply "entry" to f-tests in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-date-end IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-end in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-date-start IN FRAME Dialog-Frame
DO:
  apply "entry" to f-hour-start in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-hour-end IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-hour-end IN FRAME Dialog-Frame
DO:
    apply "entry" to f-min-end in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-hour-income IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-hour-income IN FRAME Dialog-Frame
DO:
        apply "entry" to f-min-income in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-hour-pour IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-hour-pour > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-pour in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-hour-pour IN FRAME Dialog-Frame
DO:
      apply "entry" to f-min-pour in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-hour-start IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-hour-start IN FRAME Dialog-Frame
DO:
apply "entry" to f-min-start in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-item-pour IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-pour in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-min-end IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-min-end IN FRAME Dialog-Frame
DO:
    apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-min-income IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-min-income IN FRAME Dialog-Frame
DO:
        apply "entry" to f-date-start in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-min-pour IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-pour > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-pour in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-min-pour IN FRAME Dialog-Frame
DO:
apply "entry" to f-mouth in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-min-start IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-min-start IN FRAME Dialog-Frame
DO:
  apply "entry" to f-date-end in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-mouth IN FRAME Dialog-Frame
DO:
    display input frame Dialog-Frame f-car-vol + input frame Dialog-Frame f-mouth @ f-tank-vol with frame Dialog-Frame.
    display input frame Dialog-Frame f-tank-vol *
          input frame Dialog-Frame f-tank-density @ f-tank-weight with frame Dialog-Frame.
END.
ON return OF f-mouth IN FRAME Dialog-Frame
DO:
apply "entry" to f-tank-density in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-ptbocode IN FRAME Dialog-Frame
DO:
  run disp-f-ptboname.
END.
ON RETURN OF f-ptbocode IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
apply "entry" to f-ptbocode in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-ptbotype IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
END.
ON return OF f-ptbotype IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
    apply "entry" to f-hour-pour in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-tank-density IN FRAME Dialog-Frame
DO:
    display input frame Dialog-Frame f-tank-vol *
          input frame Dialog-Frame f-tank-density @ f-tank-weight with frame Dialog-Frame.
END.
ON return OF f-tank-density IN FRAME Dialog-Frame
DO:
      apply "entry" to f-tank-temp in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-tank-temp IN FRAME Dialog-Frame
DO:
      apply "entry" to f-hour-income in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-tank-vol IN FRAME Dialog-Frame
DO:
      apply "entry" to f-tank-water in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-tank-water IN FRAME Dialog-Frame
DO:
      apply "entry" to f-tank-density in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-tank-weight IN FRAME Dialog-Frame
DO:
      apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-tests IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame Dialog-Frame.
return no-apply.
END.
ON CHOOSE OF r-sr-izm IN FRAME Dialog-Frame
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
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
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  if p-mode = "set-attr":U then do:
    run loc-get-set-attr in this-procedure
      ( input p-mode
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сохранении дополнительной информации" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    return .
  end.
  if p-mode = "get-attr":U then do:
    run loc-get-set-attr in this-procedure
      ( input p-mode
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении дополнительной информации" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    return .
  end.
  if can-find (first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code and ub.doc-line.doc-density <> 0) then do:
    find first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code
                                     and ub.doc-line.artic = buf_goods.artic
                                     and ub.doc-line.prod-code = buf_goods.prod-code
                                     and ub.doc-line.prod-type = buf_goods.prod-type no-error.
    if ub.doc-line.line-num > 1 then do :
      run loc-get-set-attr in this-procedure
        ( input "get-attr":U
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при чтении дополнительной информации" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if not ( ( p-car-num <> "" and p-car-num <> "?" ) or
               ( p-tests <> "" and p-tests <> "?" ) or
               ( p-car-vol <> "" and p-car-vol <> "?" ) or
               ( p-autoent-obj-type <> "" and p-autoent-obj-type <> "?" ) or
               ( p-autoent-obj-code <> "" and p-autoent-obj-code <> "?" ) or
               ( p-ptbotype <> "" and p-ptbotype <> "?" ) or
               ( p-ptbocode <> "" and p-ptbocode <> "?" )
               )
      then do :
        find first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code
                                        and ub.doc-line.doc-density <> 0
                                        and ub.doc-line.line-num = 1 no-error.
        find first buf_goods where buf_goods.artic     = ub.doc-line.artic
                              and buf_goods.prod-code = ub.doc-line.prod-code
                              and buf_goods.prod-type = ub.doc-line.prod-type no-error.
        assign
        v-last-gds-code = p-gds-code.
        p-gds-code = buf_goods.gds-code
        .
        run loc-get-set-attr in this-procedure
          ( input "get-attr":U
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при чтении дополнительной информации" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        assign
          p-car-vol      = "0"
          p-item-pour    = ""
          p-time-pour    = ""
          p-time-income  = ""
          p-time-start   = 0
          p-time-end     = 0
          p-date-start   = ?
          p-date-end     = ?
          p-mouth        = ""
          p-tank-vol     = ""
          p-tank-temp    = ""
          p-tank-water   = ""
          p-tank-density = ""
          p-tank-weight  = ""
          p-a-b-tarir    = ""
          p-gds-code     = v-last-gds-code
          p-diameter     = ""
          p-place-si     = ""
          p-tank-density-pomi = ""
          .
      end.
    end.
  end.
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  assign
    f-car-num = p-car-num
    f-tests = p-tests
  .
  assign
    f-car-vol = decimal(p-car-vol) no-error
  .
  if error-status:error then
    message "Неверно задан объем автоцистерны по паспорту " p-car-vol " ."
    view-as alert-box error.
  assign
    f-autoent-obj-type = p-autoent-obj-type
  .
  if f-autoent-obj-type = "" then do:
    assign
      f-autoent-obj-type = 'орг':U
    .
  end.
  assign
    f-autoent-obj-code = integer(p-autoent-obj-code) no-error
  .
  if error-status:error then do:
    message
      "Неверно указан код клиента " p-autoent-obj-code " ."
      view-as alert-box error.
  end.
  else do:
    find first clients no-lock
      where clients.obj-type = f-autoent-obj-type
        and clients.obj-code = f-autoent-obj-code
      no-error.
    if available clients then do:
      assign
        f-autoent-obj-name = clients.obj-name
      .
    end.
    else do:
      assign
        f-autoent-obj-name = ?
      .
    end.
  end.
  assign
    f-ptbotype = p-ptbotype
  .
  if f-ptbotype = "" then do:
    assign
      f-ptbotype = 'орг':U
    .
  end.
  assign
    f-ptbocode = integer( p-ptbocode ) no-error
  .
  if error-status:error then do:
    message
      "Неверно указан код нефтебазы " p-ptbocode " ."
      view-as alert-box error.
  end.
  else do:
    find first clients no-lock
      where clients.obj-type = f-ptbotype
        and clients.obj-code = f-ptbocode
      no-error.
    if available clients then assign f-ptboname = clients.obj-name.
    else assign f-ptboname = ?.
  end.
  assign f-item-pour = p-item-pour.
  assign
  f-tank-vol  = decimal(p-tank-vol) no-error.
  if error-status:error then
    message "Неверно определен объем в цистерне " p-tank-vol " . "
    view-as alert-box.
  assign
  f-tank-temp  = decimal(p-tank-temp) no-error.
  if error-status:error then
    message "Неверно определена температура в цистерне " p-tank-temp " . "
    view-as alert-box.
  assign
  f-tank-water  = decimal(p-tank-water) no-error.
  if error-status:error then
    message "Неверно определен объем воды в цистерне " p-tank-water " . "
    view-as alert-box.
  assign
  f-tank-density  = decimal(p-tank-density) no-error.
  if error-status:error then
    message "Неверно определена плотность в цистерне " p-tank-density " . "
    view-as alert-box.
  assign
  f-tank-weight  = decimal(p-tank-weight) no-error.
  if error-status:error then
    message "Неверно определен вес в цистерне " p-tank-weight " . "
    view-as alert-box.
  assign f-hour-pour = integer(substring(p-time-pour, 1, 2)) no-error.
  if error-status:error then do:
    message "Неверное время налива " p-time-pour
    view-as alert-box.
    assign f-hour-pour = 0
            f-min-pour  = 0.
  end.
  else do:
    assign f-min-pour = integer(substring(p-time-pour, 4, 2)) no-error.
    if error-status:error then do:
        message "Неверное время налива " p-time-pour
        view-as alert-box.
        assign f-hour-pour = 0
              f-min-pour  = 0.
    end.
  end.
  assign f-hour-income = integer(substring(p-time-income, 1, 2)) no-error.
  if error-status:error then do:
    message "Неверное время налива " p-time-income
    view-as alert-box.
    assign f-hour-income = 0
            f-min-income  = 0.
  end.
  else do:
    assign f-min-income = integer(substring(p-time-income, 4, 2)) no-error.
    if error-status:error then do:
        message "Неверное время налива " p-time-income
        view-as alert-box.
        assign f-hour-income = 0
              f-min-income  = 0.
    end.
  end.
  assign
  f-date-start = p-date-start
  f-date-end   = p-date-end
  f-hour-start = integer( truncate( p-time-start / 3600 , 0 ) )
  f-min-start  = integer( ( p-time-start - f-hour-start * 3600 ) / 60 )
  f-hour-end   = integer( truncate( p-time-end / 3600 , 0 ) )
  f-min-end    = integer( ( p-time-end - f-hour-end * 3600 ) / 60).
  assign
    f-mouth = decimal (p-mouth) no-error.
  if error-status:error then
    message "Неверно определен объем топлива в горловине " p-mouth " . "
    view-as alert-box.
  assign
    f-fio = p-fio
    f-ptbocode = integer( p-ptbocode )
    f-ptbotype = p-ptbotype
  .
  assign
  f-a-b-tarir  = decimal(p-a-b-tarir) no-error.
  if error-status:error then
    message "Неверно определен уровень цистерны относительно тарировочной планки " p-a-b-tarir " . "
    view-as alert-box.
  assign
  f-diameter = decimal (p-diameter) no-error.
  if error-status:error then
    message "Неверно определен внутренний диаметр горловины" p-diameter " . "
    view-as alert-box.
  assign
  f-place-si = integer(p-place-si) no-error.
  if error-status:error then
    message "Неверно определено средство измерения" p-place-si " . "
    view-as alert-box.
  f-tank-density-pomi = decimal(p-tank-density-pomi) no-error.
  if error-status:error then
    message "Неверно определена плотность топлива для ПО ИМ" p-tank-density-pomi " . "
    view-as alert-box.
  RUN enable_UI.
  display
    f-car-num f-car-vol f-tests f-autoent-obj-type f-autoent-obj-code f-autoent-obj-name
    f-item-pour f-hour-pour f-min-pour
    f-hour-income f-min-income
    f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-tank-vol f-tank-temp f-tank-water f-tank-density
    f-tank-weight
    f-mouth    f-fio
    f-ptbocode
    f-ptbotype
    f-a-b-tarir
    with frame Dialog-Frame.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
    disable
      f-car-num f-car-vol f-tests f-autoent-obj-type f-autoent-obj-code
      f-item-pour  f-tank-vol f-tank-temp f-tank-water f-tank-density
      f-tank-weight f-hour-pour f-min-pour
      f-hour-income f-min-income
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      b-save
      b-clients
      b-auto-tank
      f-mouth f-fio
      f-ptbocode
      f-ptbotype
      f-a-b-tarir
      with frame Dialog-Frame.
  end.
  run gbl/conf-rd.p ("pomi-lic", "", "", 0, "", "", "", no, output pomi-licvalue, output pomi-lictype) no-error.
  if not error-status:error and pomi-licvalue = "yes" then do :
    disable
      f-tank-water
      f-mouth
      f-tank-density
      with frame Dialog-Frame.
    display
      f-diameter
      f-place-si
      f-tank-density-pomi
      b-calc
      with frame Dialog-Frame.
    enable
      f-diameter
      f-place-si
      f-tank-density-pomi
      b-calc
      with frame Dialog-Frame.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-f-ptboname :
  find clients where clients.obj-code = input frame Dialog-Frame f-ptbocode and
                     clients.obj-type = input frame Dialog-Frame f-ptbotype no-lock no-error.
  if available clients then
  disp clients.obj-name @ f-ptboname with frame Dialog-Frame.
  else do:
      display ? @ f-ptboname with frame Dialog-Frame.
      apply "choose" to b-ptb in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE disp-obj-name :
  find clients where clients.obj-code = input frame Dialog-Frame f-autoent-obj-code and
                     clients.obj-type = input frame Dialog-Frame f-autoent-obj-type no-lock no-error.
  if available clients then
  disp clients.obj-name @ f-autoent-obj-name with frame Dialog-Frame.
  else do:
      display ? @ f-autoent-obj-name with frame Dialog-Frame.
      apply "choose" to b-clients in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-autoent-obj-code f-autoent-obj-type f-autoent-obj-name f-car-num
          f-car-vol f-tests f-fio f-ptbocode f-ptbotype f-ptboname f-hour-pour
          f-min-pour f-item-pour f-tank-water f-mouth f-tank-vol f-tank-temp
          f-tank-density f-tank-weight f-a-b-tarir
          f-hour-income f-min-income f-date-start
          f-hour-start f-min-start f-date-end f-hour-end f-min-end
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-help RECT-3 RECT-1 f-autoent-obj-code
         f-autoent-obj-type b-clients f-car-num f-car-vol b-auto-tank f-tests
         f-fio f-ptbocode f-ptbotype b-ptb f-hour-pour f-min-pour f-item-pour
         f-tank-water f-mouth f-tank-temp f-tank-density f-a-b-tarir
         r-sr-izm f-hour-income
         f-min-income f-date-start f-hour-start f-min-start f-date-end
         f-hour-end f-min-end
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE loc-get-set-attr :
  define input  parameter p-mode-attr as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_doc-line-attr for ub.doc-line-attr .
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "car-num"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-car-num = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "car-num":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-car-num )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "car-vol"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-car-vol = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "car-vol":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-car-vol )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tests"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tests = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tests":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tests )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "autoent-obj-type"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-autoent-obj-type = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "autoent-obj-type":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-autoent-obj-type )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "autoent-obj-code"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-autoent-obj-code = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "autoent-obj-code":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-autoent-obj-code )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "item-pour"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-item-pour = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "item-pour":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-item-pour )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "time-pour"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-time-pour = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "time-pour":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-time-pour )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "time-income"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-time-income = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "time-income":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-time-income )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "date-start"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-date-start = date( buf_doc-line-attr.attr-value )       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "date-start":U       .     end.
      assign       buf_doc-line-attr.attr-value = string( p-date-start, "99/99/9999" )    .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "time-start"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-time-start = integer( buf_doc-line-attr.attr-value ) no-error       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "time-start":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-time-start )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "date-end"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-date-end = date( buf_doc-line-attr.attr-value )       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "date-end":U       .     end.
      assign       buf_doc-line-attr.attr-value = string( p-date-end, "99/99/9999" )    .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "time-end"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-time-end = integer( buf_doc-line-attr.attr-value ) no-error       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "time-end":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-time-end )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-vol"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-vol = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-vol":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-vol )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-temp"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-temp = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-temp":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-temp )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-water"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-water = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-water":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-water )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-density"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-density = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-density":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-density )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-weight"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-weight = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-weight":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-weight )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "mouth"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-mouth = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "mouth":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-mouth )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "fio"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-fio = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "fio":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-fio )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "ptbotype"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-ptbotype = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "ptbotype":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-ptbotype )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "ptbocode"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-ptbocode = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "ptbocode":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-ptbocode )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "a-b-tarir"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-a-b-tarir = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "a-b-tarir":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-a-b-tarir )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "diameter"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-diameter = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "diameter":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-diameter )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "place-si"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-place-si = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "place-si":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-place-si )     .
    end.
        find first buf_doc-line-attr     where buf_doc-line-attr.doc-code  = p-doc-code       and buf_doc-line-attr.gds-code  = p-gds-code       and buf_doc-line-attr.attr-code = "tank-density-pomi"     no-error.
    if p-mode-attr = "get-attr":U then do:
      if available buf_doc-line-attr then do:       assign         p-tank-density-pomi = buf_doc-line-attr.attr-value       .     end.
    end.
    else do:
      if not available buf_doc-line-attr then do:       create buf_doc-line-attr .       assign         buf_doc-line-attr.doc-code  = p-doc-code         buf_doc-line-attr.gds-code  = p-gds-code         buf_doc-line-attr.attr-code = "tank-density-pomi":U       .     end.
      assign       buf_doc-line-attr.attr-value = substitute( "&1", p-tank-density-pomi )     .
    end.
    return .
  end.
END PROCEDURE.
