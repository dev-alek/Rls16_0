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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter parparentproc as handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-doc-code like ub.trn-doc.doc-code   no-undo .
define input parameter table for tt-upd-attr-fuel .
define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable varrec-id as recid no-undo.
define variable v-no-news as logical   no-undo init false .
define variable pomi-licvalue   as character no-undo.
define variable pomi-lictype    as character no-undo.
define variable v-avai-acc-ship as logical no-undo.
define stream outstream.
define variable rdc-dnstvalue as character no-undo.
define variable rdc-dnsttype  as character no-undo.
define variable v-dop-info as character  no-undo .
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
define variable v-is-lgas as logical no-undo.
define buffer buf_trn-doc for ub.trn-doc .
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
DEFINE VARIABLE f-acc-ship AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.25 BY 1 NO-UNDO.
DEFINE VARIABLE f-acc-ship-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Допустимый % погрешности поставщика:"
     VIEW-AS FILL-IN
     SIZE 36.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-autoent AS CHARACTER FORMAT "X(256)":U INITIAL "Автопредприятие:"
     VIEW-AS FILL-IN
     SIZE 16.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45.5 BY 1.04 NO-UNDO.
DEFINE VARIABLE f-autoent-obj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-car AS CHARACTER FORMAT "X(256)":U INITIAL "Гос. N автоцистерны:"
     VIEW-AS FILL-IN
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-num AS CHARACTER FORMAT "X(256)":U INITIAL "?"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-condition AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 59.38 BY 1 NO-UNDO.
DEFINE VARIABLE f-condition-name AS CHARACTER FORMAT "X(256)":U INITIAL "Техническое состояние:"
     VIEW-AS FILL-IN
     SIZE 22.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-cert AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U
     LABEL "Дата конца слива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-income AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-income-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата прибытия на АЗС:"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-pasport AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-pour AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-pour-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата налива:"
     VIEW-AS FILL-IN
     SIZE 21.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала слива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc AS CHARACTER FORMAT "X(256)":U INITIAL "Документы НЕ предоставлены"
     VIEW-AS FILL-IN
     SIZE 36.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-fio AS CHARACTER FORMAT "X(256)":U INITIAL "?"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE VARIABLE f-fio-name AS CHARACTER FORMAT "X(256)":U INITIAL "Ф.И.О. водителя-экспедитора:"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время конца слива"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-income AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-income-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Время прибытия на АЗС:"
     VIEW-AS FILL-IN
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-pour AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-pour-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Время налива:"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время начала слива"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-insp AS CHARACTER FORMAT "X(256)":U INITIAL "Свидетельство о поверке:"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-insp-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата свидет. о поверке:"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-insp-cert AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-item-doc AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 82 BY 1 NO-UNDO.
DEFINE VARIABLE f-item-pour AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 82 BY 1 NO-UNDO.
DEFINE VARIABLE f-item-pour-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание к нефтебазе:"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-income AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-pour AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-pasport AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE f-pasport AS CHARACTER FORMAT "X(256)":U INITIAL "Паспорт качества №, дата:"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-pasport-num AS CHARACTER FORMAT "X(256)":U INITIAL " от"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptbocode AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptbocode-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Нефтебаза:"
     VIEW-AS FILL-IN
     SIZE 16.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptboname AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45.38 BY 1 NO-UNDO.
DEFINE VARIABLE f-ptbotype AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-seals-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Пломбы:"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-seals-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Состояние пломб:"
     VIEW-AS FILL-IN
     SIZE 16.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-seals-condition AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 33.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-seals-condition-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE b-doc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-clear AS LOGICAL INITIAL no
     LABEL "Произведена зачистка АЦ перед наполнением на ГНС"
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2.13
     b-quit AT ROW 1 COL 12.13
     b-help AT ROW 1 COL 73.63
     f-autoent AT ROW 2.46 COL 1.5 NO-LABEL WIDGET-ID 80
     f-autoent-obj-code AT ROW 2.46 COL 16.13 COLON-ALIGNED NO-LABEL
     f-autoent-obj-type AT ROW 2.46 COL 27.88 COLON-ALIGNED NO-LABEL
     f-autoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.63
     f-car AT ROW 3.75 COL 1.5 NO-LABEL WIDGET-ID 82
     f-car-num AT ROW 3.75 COL 20 COLON-ALIGNED NO-LABEL
     b-auto-tank AT ROW 3.79 COL 36.75
     f-condition-name AT ROW 5 COL 1.5 NO-LABEL WIDGET-ID 84
     f-condition AT ROW 5 COL 82.51 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
     f-seals-1 AT ROW 6.25 COL 1.5 NO-LABEL WIDGET-ID 86
     f-seals-condition AT ROW 6.25 COL 7 COLON-ALIGNED NO-LABEL
     f-insp AT ROW 6.25 COL 45.5 NO-LABEL WIDGET-ID 88
     f-insp-cert AT ROW 6.25 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 26
     f-seals-2 AT ROW 7.38 COL 1.5 NO-LABEL WIDGET-ID 90
     f-seals-condition-2 AT ROW 7.38 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     f-insp-2 AT ROW 7.46 COL 45.5 NO-LABEL WIDGET-ID 92
     f-date-cert AT ROW 7.46 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 34
     f-pasport AT ROW 8.63 COL 32.63 NO-LABEL WIDGET-ID 156
     f-num-pasport AT ROW 8.63 COL 64.13 RIGHT-ALIGNED NO-LABEL WIDGET-ID 154
     f-pasport-num AT ROW 8.63 COL 65 NO-LABEL WIDGET-ID 152
     f-date-pasport AT ROW 8.63 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 150
     f-fio-name AT ROW 9.75 COL 1.38 NO-LABEL WIDGET-ID 94
     f-fio AT ROW 9.75 COL 82.38 RIGHT-ALIGNED NO-LABEL
     f-ptbocode-1 AT ROW 11 COL 1.38 NO-LABEL WIDGET-ID 96
     f-ptbocode AT ROW 11 COL 16 COLON-ALIGNED NO-LABEL
     f-ptbotype AT ROW 11 COL 27.75 COLON-ALIGNED NO-LABEL
     f-ptboname AT ROW 11 COL 82.38 RIGHT-ALIGNED NO-LABEL
     b-ptb AT ROW 11.08 COL 34.5
     f-date-pour-1 AT ROW 12.17 COL 1.38 NO-LABEL WIDGET-ID 98
     f-date-pour AT ROW 12.17 COL 20.88 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     f-hour-pour-2 AT ROW 12.25 COL 38.13 NO-LABEL WIDGET-ID 100
     f-hour-pour AT ROW 12.25 COL 59.63 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     f-min-pour AT ROW 12.25 COL 63.13 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     f-date-income-2 AT ROW 13.5 COL 1.5 NO-LABEL WIDGET-ID 160
     f-date-income AT ROW 13.5 COL 21 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     f-hour-income-2 AT ROW 13.5 COL 38.13 NO-LABEL WIDGET-ID 102
     f-hour-income AT ROW 13.5 COL 59.75 COLON-ALIGNED NO-LABEL
     f-min-income AT ROW 13.5 COL 67.13 RIGHT-ALIGNED NO-LABEL
     f-item-pour-2 AT ROW 15.5 COL 1.38 NO-LABEL WIDGET-ID 104
     f-item-pour AT ROW 16.63 COL 82.38 RIGHT-ALIGNED NO-LABEL
     f-acc-ship-2 AT ROW 17.79 COL 1.38 NO-LABEL WIDGET-ID 106
     f-acc-ship AT ROW 17.79 COL 38 NO-LABEL WIDGET-ID 42
     f-doc AT ROW 18 COL 4.38 NO-LABEL WIDGET-ID 108
     b-doc AT ROW 18.08 COL 1.88 WIDGET-ID 48
     t-clear AT ROW 18.08 COL 31.88 WIDGET-ID 148
     f-item-doc AT ROW 19.17 COL 82.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 46
     f-date-start AT ROW 20.33 COL 19.13 COLON-ALIGNED WIDGET-ID 60
     f-date-end AT ROW 20.33 COL 59.38 COLON-ALIGNED WIDGET-ID 58
     f-hour-start AT ROW 21.5 COL 19 COLON-ALIGNED WIDGET-ID 50
     f-min-start AT ROW 21.5 COL 23.5 COLON-ALIGNED NO-LABEL WIDGET-ID 54
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     f-hour-end AT ROW 21.5 COL 59.5 COLON-ALIGNED WIDGET-ID 52
     f-min-end AT ROW 21.5 COL 64.13 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     "Примечание к нефтебазе" VIEW-AS TEXT
          SIZE 25.5 BY 1 AT ROW 15.5 COL 1
     SPACE(57.12) SKIP(7.03)
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
  assign frame Dialog-Frame  f-autoent-obj-code
                              f-autoent-obj-name
                              f-autoent-obj-type
                              f-car-num
                              f-condition
                              f-seals-condition
                              f-seals-condition-2
                              f-insp-cert
                              f-date-cert
                              f-pasport
                              f-pasport-num
                              f-date-pasport
                              f-num-pasport
                              f-fio
                              f-ptbocode
                              f-ptbotype
                              f-ptboname
                              f-hour-income
                              f-min-income
                              f-item-pour
                              f-hour-pour
                              f-min-pour
                              f-date-pour
                              f-date-income
                              f-acc-ship
                              b-doc
                              f-item-doc
                              f-hour-start
                              f-min-start
                              f-hour-end
                              f-min-end
                              f-date-start
                              f-date-end
                              t-clear
  .
  if input frame Dialog-Frame f-hour-income <> ?
    and input frame Dialog-Frame f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame Dialog-Frame .
     return no-apply .
  end.
  if input frame Dialog-Frame f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame Dialog-Frame .
     return no-apply .
  end.
  find ub.clients no-lock where
       ub.clients.obj-type = f-ptbotype and
       ub.clients.obj-code = f-ptbocode no-error .
  if not available ub.clients
  then do:
    assign
      f-ptbotype = ""
      f-ptbocode = ?
    .
  end.
  run save-attr.
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
  run str/auto-tn.w (input parparentproc,
              input "b-sel",
              input v-autoent-obj-type,
              input v-autoent-obj-code,
              output v-rec-tank,
              output v-rec-meas) no-error.
  if v-rec-tank <> ? then do:
    find first auto-tank where recid (auto-tank) = v-rec-tank no-lock.
    assign
        f-car-num    = auto-tank.auto-num
    .
    assign
      f-autoent-obj-type = auto-tank.firm-type
      f-autoent-obj-code = integer (auto-tank.firm-code).
      f-autoent-obj-type:screen-value = f-autoent-obj-type.
      f-autoent-obj-code:screen-value = string (f-autoent-obj-code).
    assign
      v-autoent-obj-type = f-autoent-obj-type
      v-autoent-obj-code =  f-autoent-obj-code
    .
    display f-car-num with frame Dialog-Frame.
  end.
  apply "leave" to f-car-num in frame Dialog-Frame.
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
  find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
  disp ub.clients.obj-code @ f-autoent-obj-code
       ub.clients.obj-type @ f-autoent-obj-type
       ub.clients.obj-name @ f-autoent-obj-name with frame Dialog-Frame.
  assign
    v-autoent-obj-type = ub.clients.obj-type
    v-autoent-obj-code = ub.clients.obj-code
  .
end.
END.
ON VALUE-CHANGED OF b-doc IN FRAME Dialog-Frame
DO:
  if b-doc:SCREEN-VALUE = "yes" then do:
    enable
    f-item-doc
    with frame Dialog-Frame .
  end.
  else do:
    HIDE
    f-item-doc
    in frame Dialog-Frame .
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
    find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
    disp ub.clients.obj-code @ f-ptbocode
         ub.clients.obj-type @ f-ptbotype
         ub.clients.obj-name @ f-ptboname with frame Dialog-Frame.
  end.
END.
ON return OF f-acc-ship IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-income in frame Dialog-Frame.
return no-apply.
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
ON leave OF f-car-num IN FRAME Dialog-Frame
DO:
  assign
    f-car-num.
  find first auto-tank where auto-tank.auto-num = f-car-num no-lock no-error.
  if not available (auto-tank) and not (f-car-num = ? or f-car-num = "" or f-car-num = "?")
  then do:
   message "АЦ с таким гос. номером не найдена. Введите корректный номер АЦ или выберите из справочника." view-as alert-box information title "Сообщение".
   apply "entry" to f-car-num in frame Dialog-Frame .
   return no-apply .
  end.
   if available auto-tank
      then
   do :
      if auto-tank.firm-type <> "" then
      do:
         assign
            f-autoent-obj-type = auto-tank.firm-type
            f-autoent-obj-code = integer (auto-tank.firm-code).
      end.
      else
      do:
         find first auto-tank-attr where auto-tank-attr.attr-code = "auto-firm" and auto-tank-attr.auto-num = auto-tank.auto-num no-error.
         if available (auto-tank-attr)
            then
         do:
            assign
               f-autoent-obj-type = substring (auto-tank-attr.attr-value, 1, 3)
               f-autoent-obj-code = integer (substring (auto-tank-attr.attr-value, 4)).
         end.
      end.
      f-autoent-obj-type:screen-value = f-autoent-obj-type.
      f-autoent-obj-code:screen-value = string (f-autoent-obj-code).
      assign
         v-autoent-obj-type = f-autoent-obj-type
         v-autoent-obj-code = f-autoent-obj-code
         .
      run disp-obj-name.
   end .
END.
ON return OF f-car-num IN FRAME Dialog-Frame
DO:
  apply "leave" to f-car-num in frame Dialog-Frame .
END.
ON return OF f-condition IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-date-cert IN FRAME Dialog-Frame
DO:
return no-apply.
END.
ON return OF f-date-pasport IN FRAME Dialog-Frame
DO:
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
  if input frame Dialog-Frame f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-hour-pour IN FRAME Dialog-Frame
DO:
      apply "entry" to f-min-income in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-hour-start IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-hour-start > 24
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-insp-cert IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-item-doc IN FRAME Dialog-Frame
DO:
return no-apply.
END.
ON return OF f-item-pour IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-income in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF f-min-end IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
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
return no-apply.
END.
ON LEAVE OF f-min-pour IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-min-pour IN FRAME Dialog-Frame
DO:
return no-apply.
END.
ON LEAVE OF f-min-start IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame Dialog-Frame .
     return no-apply .
  end.
END.
ON return OF f-num-pasport IN FRAME Dialog-Frame
DO:
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
    apply "entry" to f-hour-income in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-seals-condition IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame Dialog-Frame.
return no-apply.
END.
ON return OF f-seals-condition-2 IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame Dialog-Frame.
return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define buffer buf_doc-attr for ub.doc-attr.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'trn-lgas-corr':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if not varvalue = ""
    then frame Dialog-Frame:title = "Дополнительная информация по корр. накладной СУГ. Исх.накл. - " + varvalue.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       v-is-lgas = true.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-lgas-corr':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue = "yes" then do:
     assign
       v-is-lgas = true.
  end.
  for each tt-upd-attr-fuel no-lock:
    find first buf_doc-attr no-lock
      where buf_doc-attr.doc-code  = p-doc-code
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code
      no-error .
    if available buf_doc-attr then do:
      case tt-upd-attr-fuel.code:
        when 'ptbobj':U then do:
            assign
              f-ptbotype = entry (1, buf_doc-attr.attr-value, ";")
              f-ptbocode = integer (entry (2, buf_doc-attr.attr-value, ";"))
            no-error.
            find first clients no-lock
              where clients.obj-type = f-ptbotype
                and clients.obj-code = f-ptbocode
              no-error.
            if available clients
              then assign f-ptboname = clients.obj-name.
              else
                assign f-ptboname = ""
                f-ptbotype = ""
                f-ptbotype = ?.
        end.
        when 'ptb-item-pour':U then do:
            assign
              f-item-pour = buf_doc-attr.attr-value
            .
        end.
        when 'autoent':U then do:
            assign
              f-autoent-obj-type = entry (1, buf_doc-attr.attr-value, ";")
              f-autoent-obj-code = integer (entry (2, buf_doc-attr.attr-value, ";"))
            no-error.
            assign
              v-autoent-obj-type = f-autoent-obj-type
              v-autoent-obj-code = f-autoent-obj-code
            .
            find first ub.clients no-lock
              where ub.clients.obj-type = f-autoent-obj-type
                and ub.clients.obj-code = f-autoent-obj-code
              no-error.
            if available ub.clients then do:
              assign
                f-autoent-obj-name = ub.clients.obj-name
              .
            end.
            else do:
              assign
                f-autoent-obj-name = ?
                f-autoent-obj-code = ?
                f-autoent-obj-type = ""
              .
            end.
        end.
        when 'car-num':U then do:
            assign
              f-car-num = buf_doc-attr.attr-value
            .
        end.
        when 'fio-driver':U then do:
            assign
              f-fio = buf_doc-attr.attr-value
            .
        end.
        when 'time-income':U then do:
          assign f-hour-income = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время прибытия " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-income = 0
                    f-min-income  = 0.
          end.
          else do:
            assign f-min-income = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время прибытия " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-income = 0
                      f-min-income  = 0.
            end.
          end.
        end.
        when 'time-pour':U then do:
            assign f-hour-pour = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время налива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-pour = 0
                    f-min-pour  = 0.
          end.
          else do:
            assign f-min-pour = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время налива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-pour = 0
                      f-min-pour  = 0.
            end.
          end.
        end.
        when 'time-start':U then do:
            assign f-hour-start = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время начала слива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-start = 0
                    f-min-start  = 0.
          end.
          else do:
            assign f-min-start = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время начала слива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-start = 0
                      f-min-start  = 0.
            end.
          end.
        end.
        when 'time-end':U then do:
            assign f-hour-end = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время конца слива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-end = 0
                    f-min-end  = 0.
          end.
          else do:
            assign f-min-end = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время конца слива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-end = 0
                      f-min-end = 0.
            end.
          end.
        end.
        when 'date-pour':U then do:
            assign
              f-date-pour = date(buf_doc-attr.attr-value).
        end.
        when 'date-income':U then do:
            assign
              f-date-income = date(buf_doc-attr.attr-value).
        end.
        when 'inspection-cert':U then do:
            assign
              f-insp-cert = buf_doc-attr.attr-value.
        end.
        when 'date-cert':U then do:
            assign
              f-date-cert = date(buf_doc-attr.attr-value).
        end.
        when 'date-pasport':U then do:
            assign
              f-date-pasport = date(buf_doc-attr.attr-value).
        end.
        when 'num-pasport':U then do:
            assign
              f-num-pasport = buf_doc-attr.attr-value.
        end.
        when 'condition':U then do:
            assign
              f-condition = buf_doc-attr.attr-value.
        end.
        when 'seals-condition':U then do:
            if num-entries (buf_doc-attr.attr-value, chr(4)) = 2
            then do:
              assign
                f-seals-condition = entry (1, buf_doc-attr.attr-value, chr(4))
                f-seals-condition-2 = entry (2, buf_doc-attr.attr-value, chr(4))
              .
            end.
            else
              assign
                f-seals-condition = buf_doc-attr.attr-value.
        end.
        when 'doc-not':U then do:
            assign
              b-doc =  logical(buf_doc-attr.attr-value) no-error.
        end.
        when 'clear-ac':U then do:
            assign
              t-clear =  logical(buf_doc-attr.attr-value) no-error.
        end.
        when 'spisok-not-doc':U then do:
            assign
              f-item-doc =  buf_doc-attr.attr-value no-error.
        end.
        when 'trdcattr-date-start':U then do:
            assign
              f-date-start = date(buf_doc-attr.attr-value).
        end.
        when 'trdcattr-date-end':U then do:
            assign
              f-date-end = date(buf_doc-attr.attr-value).
        end.
      end case.
    end.
  end.
  if not v-avai-acc-ship
    then f-acc-ship = 0.25.
  RUN enable_UI.
  run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
  display
      f-autoent-obj-code
      f-autoent-obj-name
      f-autoent-obj-type
      f-car-num
      b-clients
      b-ptb
      b-auto-tank
      f-condition
      f-seals-condition
      f-seals-condition-2
      f-insp-cert
      f-date-cert
      f-num-pasport
      f-date-pasport
      f-fio
      f-ptbocode
      f-ptbotype
      f-ptboname
      f-hour-income
      f-min-income
      f-item-pour
      f-hour-pour
      f-min-pour
      f-date-pour
      f-date-income
      f-hour-pour
      f-min-pour
      b-save
      f-acc-ship
      b-doc
      f-date-start
      f-date-end
    with frame Dialog-Frame.
    if b-doc = no then do:
        hide
            f-item-doc
        in frame Dialog-Frame .
    end.
    hide
        f-hour-start
        f-hour-end
        f-min-end
        f-min-start
        f-date-start
        f-date-end
        t-clear
    in frame Dialog-Frame .
    if v-is-lgas then do:
      display
        f-hour-start
        f-hour-end
        f-min-end
        f-min-start
        f-date-start
        f-date-end
        t-clear
      with frame Dialog-Frame .
    end.
    hide
    f-acc-ship-2 f-acc-ship
    in frame Dialog-Frame .
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input ub.trn-doc.obj-type
  , input ub.trn-doc.obj-code
  ) .
  if ptrlprop-mand-choice-autocar
  then do:
    disable f-car-num with frame Dialog-Frame.
  end.
  if p-mode <> 'ИЗМЕНЕНИЕ':U and  p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    disable
      f-autoent-obj-code
      f-autoent-obj-name
      f-autoent-obj-type
      f-car-num
      b-clients
      b-ptb
      b-auto-tank
      f-condition
      f-seals-condition
      f-seals-condition-2
      f-insp-cert
      f-date-cert
      f-num-pasport
      f-date-pasport
      f-fio
      f-ptbocode
      f-ptbotype
      f-ptboname
      f-hour-income
      f-min-income
      f-item-pour
      f-date-pour
      f-date-income
      f-hour-pour
      f-min-pour
      b-save
      f-acc-ship
      b-doc
      f-hour-start
      f-hour-end
      f-min-end
      f-min-start
      f-date-start
      f-date-end
      t-clear
      with frame Dialog-Frame.
  end.
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
  v-dop-info = "".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'petrol':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
        for each thbjattr_thbj-attr :
            if thbjattr_thbj-attr.prop-code = 'dop-info' then v-dop-info =  thbjattr_thbj-attr.property-value-character .
        end.
      for each tt-upd-attr-fuel no-lock where lookup (tt-upd-attr-fuel.code, v-dop-info) > 0:
      case tt-upd-attr-fuel.code:
        when 'ptbobj':U then do:
            assign
              f-ptbotype:fgcolor  = 12
              f-ptbocode:fgcolor  = 12
              f-ptboname:fgcolor  = 12
              f-ptbocode-1:fgcolor  = 12
              .
        end.
        when 'ptb-item-pour':U then do:
            assign
              f-item-pour:fgcolor   = 12
              f-item-pour-2:fgcolor = 12
              .
        end.
        when 'autoent':U then do:
            assign
              f-autoent-obj-type:fgcolor  = 12
              f-autoent-obj-code:fgcolor  = 12
              f-autoent-obj-name:fgcolor  = 12
              f-autoent:fgcolor           = 12
              .
        end.
        when 'car-num':U then do:
            assign
              f-car-num:fgcolor = 12
              f-car:fgcolor     = 12
              .
        end.
        when 'fio-driver':U then do:
            assign
              f-fio:fgcolor = 12
              f-fio-name:fgcolor  = 12
              .
        end.
        when 'time-income':U then do:
            assign
              f-hour-income:fgcolor = 12
              f-min-income:fgcolor  = 12
              f-hour-income-2:fgcolor = 12
              .
        end.
        when 'time-pour':U then do:
            assign
              f-hour-pour:fgcolor = 12
              f-min-pour:fgcolor  = 12
              f-hour-pour-2:fgcolor = 12
              .
        end.
        when 'date-pour':U then do:
            assign
              f-date-pour:fgcolor = 12
              f-date-pour-1:fgcolor = 12
              .
        end.
        when 'date-income':U then do:
            assign
              f-date-income:fgcolor = 12
              f-date-income-2:fgcolor = 12
              .
        end.
        when 'inspection-cert':U then do:
            assign
              f-insp-cert:fgcolor = 12
              f-insp:fgcolor  = 12
              .
        end.
        when 'date-cert':U then do:
            assign
              f-date-cert:fgcolor = 12
              f-insp-2:fgcolor  = 12
              .
        end.
        when 'date-pasport':U then do:
            assign
              f-date-pasport:fgcolor = 12
              f-pasport-num:fgcolor  = 12
              .
        end.
        when 'num-pasport':U then do:
            assign
              f-num-pasport:fgcolor = 12
              f-pasport:fgcolor  = 12
              .
        end.
        when 'condition':U then do:
            assign
              f-condition:fgcolor = 12
              f-condition-name:fgcolor  = 12
              .
        end.
        when 'seals-condition':U then do:
            assign
              f-seals-condition:fgcolor = 12
              f-seals-1:fgcolor = 12
              f-seals-2:fgcolor = 12
              f-seals-condition-2:fgcolor = 12
              .
        end.
        when 'doc-not':U then do:
            assign
              b-doc:fgcolor = 12
              f-doc:fgcolor = 12
              .
        end.
        when 'spisok-not-doc':U then do:
            assign
              f-item-doc:bgcolor  = 12
              .
        end.
      end case.
      end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-f-ptboname :
  find ub.clients where ub.clients.obj-code = input frame Dialog-Frame f-ptbocode and
                     ub.clients.obj-type = input frame Dialog-Frame f-ptbotype no-lock no-error.
  if available ub.clients then
  disp ub.clients.obj-name @ f-ptboname with frame Dialog-Frame.
  else do:
      display ? @ f-ptboname with frame Dialog-Frame.
      apply "choose" to b-ptb in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE disp-obj-name :
  find ub.clients where ub.clients.obj-code = input frame Dialog-Frame f-autoent-obj-code and
                     ub.clients.obj-type = input frame Dialog-Frame f-autoent-obj-type no-lock no-error.
  if available ub.clients
  then do :
    assign
      v-autoent-obj-type = ub.clients.obj-type
      v-autoent-obj-code = ub.clients.obj-code
    .
    disp ub.clients.obj-name @ f-autoent-obj-name with frame Dialog-Frame.
  end .
  else do:
      display ? @ f-autoent-obj-name with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-autoent f-autoent-obj-code f-autoent-obj-type f-autoent-obj-name
          f-car f-car-num f-condition-name f-condition f-seals-1
          f-seals-condition f-insp f-insp-cert f-seals-2 f-seals-condition-2
          f-insp-2 f-date-cert f-pasport f-num-pasport f-pasport-num
          f-date-pasport f-fio-name f-fio f-ptbocode-1 f-ptbocode f-ptbotype
          f-ptboname f-date-pour-1 f-date-pour f-hour-pour-2 f-hour-pour
          f-min-pour f-date-income-2 f-date-income f-hour-income-2 f-hour-income
          f-min-income f-item-pour-2 f-item-pour f-acc-ship-2 f-acc-ship f-doc
          b-doc t-clear f-item-doc f-date-start f-date-end f-hour-start
          f-min-start f-hour-end f-min-end
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-help f-autoent-obj-code f-autoent-obj-type b-clients
         f-car-num b-auto-tank f-condition f-seals-condition f-insp-cert
         f-seals-condition-2 f-date-cert f-num-pasport f-date-pasport f-fio
         f-ptbocode f-ptbotype b-ptb f-date-pour f-hour-pour f-min-pour
         f-date-income f-hour-income f-min-income f-item-pour f-acc-ship b-doc
         t-clear f-date-start f-date-end f-hour-start f-min-start f-hour-end
         f-min-end
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE save-attr :
  define variable v-attr-value as character no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  do transaction:
    _LABEL_FOR:
    for each tt-upd-attr-fuel no-lock:
      assign
        v-attr-value = ? .
      case tt-upd-attr-fuel.code:
        when 'ptbobj':U then do:
            assign
              v-attr-value = f-ptbotype + ";" + string (f-ptbocode) when f-ptbotype <> "" and f-ptbocode <> ?.
        end.
        when 'ptb-item-pour':U then do:
            assign
              v-attr-value = f-item-pour when f-item-pour <> "".
        end.
        when 'autoent':U then do:
            assign
              v-attr-value = f-autoent-obj-type + ";" + string (f-autoent-obj-code) when f-autoent-obj-code <> ? and f-autoent-obj-type <> "".
        end.
        when 'car-num':U then do:
            assign
              v-attr-value = f-car-num when f-car-num <> "".
        end.
        when 'fio-driver':U then do:
            assign
              v-attr-value = f-fio when f-fio <> "".
        end.
        when 'date-income':U then do:
            assign
              v-attr-value = string(f-date-income) when string(f-date-income) <> "".
        end.
        when 'time-income':U then do:
            assign
              v-attr-value = string( f-hour-income,   "99":U ) + ":" + string( f-min-income,   "99":U ) when f-hour-income <> ? and f-min-income <> ?.
        end.
        when 'time-pour':U then do:
            assign
              v-attr-value = string( f-hour-pour,   "99":U ) + ":" + string( f-min-pour,   "99":U ) when f-hour-pour <> ? and f-min-pour <> ?.
        end.
        when 'time-start':U then do:
            assign
              v-attr-value = string( f-hour-start,   "99":U ) + ":" + string( f-min-start,   "99":U ) when f-hour-start <> ? and f-min-start <> ?.
        end.
        when 'time-end':U then do:
            assign
              v-attr-value = string( f-hour-end,   "99":U ) + ":" + string( f-min-end,   "99":U ) when f-hour-end <> ? and f-min-end <> ?.
        end.
        when 'date-pour':U then do:
            assign
              v-attr-value = string(f-date-pour) when string(f-date-pour) <> "".
        end.
        when 'inspection-cert':U then do:
            assign
              v-attr-value = f-insp-cert when f-insp-cert <> "".
        end.
        when 'date-cert':U then do:
            assign
              v-attr-value = string(f-date-cert) when string(f-date-cert) <> "".
        end.
        when 'date-pasport':U then do:
            assign
              v-attr-value = string(f-date-pasport) when string(f-date-pasport) <> "".
        end.
        when 'num-pasport':U then do:
            assign
              v-attr-value = string(f-num-pasport) when string(f-num-pasport) <> "".
        end.
        when 'condition':U then do:
            assign
              v-attr-value = f-condition when f-condition <> "".
        end.
        when 'seals-condition':U then do:
            assign
              v-attr-value = f-seals-condition when f-seals-condition <> "".
            assign
              v-attr-value = (if v-attr-value = ? then "" else v-attr-value) + chr(4) + f-seals-condition-2 when f-seals-condition-2 <> "".
        end.
        when 'doc-not':U then do:
            assign
              v-attr-value = string (b-doc) when string (b-doc) <> "".
        end.
        when 'clear-ac':U then do:
          if v-is-lgas
          then
            assign
              v-attr-value = string (t-clear) when string (t-clear) <> "".
        end.
        when 'spisok-not-doc':U then do:
        if b-doc = yes then do:
            assign
              v-attr-value = string (f-item-doc) when string (f-item-doc) <> "".
        end.
        else v-attr-value = "".
        end.
        when 'trdcattr-date-start':U then do:
            assign
              v-attr-value = string(f-date-start) when string(f-date-start) <> "".
        end.
        when 'trdcattr-date-end':U then do:
            assign
              v-attr-value = string(f-date-end) when string(f-date-end) <> "".
        end.
        otherwise
          next _LABEL_FOR.
      end case.
      find first buf_doc-attr
        where buf_doc-attr.doc-code  = p-doc-code
          and buf_doc-attr.attr-code = tt-upd-attr-fuel.code
        no-error .
      if v-attr-value <> ?
      then do:
        if not available buf_doc-attr
            then do:
              create buf_doc-attr.
              assign
                buf_doc-attr.doc-code   = p-doc-code
                buf_doc-attr.attr-code = tt-upd-attr-fuel.code.
            end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_doc-attr.doc-code ,
                       input buf_doc-attr.attr-code ,
                       input v-attr-value ) no-error .
        if error-status :error then do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
        end.
      end.
      else do:
        if available buf_doc-attr then delete buf_doc-attr.
      end.
    end.
  end.
END PROCEDURE.
