block-level on error undo, throw.
define input parameter p-rvs-code as character        no-undo.
define input parameter p-obj-type as character        no-undo.
define input parameter p-obj-code as integer          no-undo.
define output parameter p-ok      as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: 43fd28ac5b03, 3518, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/25 15:17:32 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rvs-attr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rvs-attr.p $":U .
define variable vss-description as character no-undo init "Оборот по по чекам".
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
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
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
define temp-table tt-doc-line-attr no-undo
  field gds-code    like ub.goods.gds-code
  field pl-code     like ub.place.pl-code
  field artic       like ub.goods.artic
  field prod-type   like ub.goods.prod-type
  field prod-code   like ub.goods.prod-code
  field attr-value  as decimal
  field rest        as decimal initial 0.0
  field oo          as decimal initial 0.0
  index pi is primary unique gds-code pl-code
.
define TEMP-TABLE tt-rvs-line-attr no-undo
  field rvs-code    like ub.rvs-line-attr.rvs-code
  field obj-type    like ub.rvs-line-attr.obj-type
  field obj-code    like ub.rvs-line-attr.obj-code
  field pl-code     like ub.rvs-line-attr.pl-code
  field gds-code    like ub.rvs-line-attr.gds-code
  field attr-code   like ub.rvs-line-attr.attr-code
  field attr-value  as decimal
  field attr-value_s  as character
index pi is primary unique gds-code pl-code obj-type obj-code attr-code
.
define buffer buf_tt-doc-line-attr  for tt-doc-line-attr .
define buffer buf_tt-rvs-line-attr  for tt-rvs-line-attr .
define buffer buf_place             for ub.place .
define buffer buf_pl-gds            for ub.pl-gds .
define buffer buf_inkas             for ub.inkas .
define buffer buf_doc-pl            for ub.doc-pl .
define buffer buf_trn-doc           for ub.trn-doc .
define buffer buf_goods             for ub.goods .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_doc-line-attr     for ub.doc-line-attr .
define buffer buf_doc-line-attr1    for ub.doc-line-attr.
define buffer curr_shift-obj        for ub.shift-obj .
define buffer prev_shift-obj        for ub.shift-obj .
define buffer buf_rvs-doc           for ub.rvs-doc .
define buffer buf_rvs-line          for ub.rvs-line .
define buffer buf_rvs-line-attr     for ub.rvs-line-attr .
define buffer buf_chk-doc           for ub.chk-doc .
define buffer buf_chk-gds           for ub.chk-gds .
define buffer buf_bar-code          for ub.bar-code .
define buffer buf_pl-pump-nozzle    for ub.pl-pump-nozzle .
define buffer buf_place-attr        for ub.place-attr.
define buffer buf_doc-attr          for ub.doc-attr.
define variable v-sign              as decimal   no-undo .
define variable v-pl-code           as integer   no-undo .
define variable vRvdDnstOn          as log no-undo.
define variable vRvdTmpOn           as log no-undo.
define variable vRvdLvlOn           as log no-undo.
define variable vSkipAuto           as log no-undo.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
  find first curr_shift-obj no-lock
    where curr_shift-obj.obj-type = p-obj-type
      and curr_shift-obj.obj-code = p-obj-code
      and curr_shift-obj.status_  = 'тек':U
    no-error .
  if not available curr_shift-obj then do:
    undo, return error substitute( "&1. Не найдена текущая смена.", vss-workfile ).
  end.
  for each buf_place no-lock
    where buf_place.obj-type = p-obj-type
      and buf_place.obj-code = p-obj-code
    ,first buf_pl-gds no-lock
    where buf_pl-gds.obj-type = p-obj-type
      and buf_pl-gds.obj-code = p-obj-code
      and buf_pl-gds.pl-code  = buf_place.pl-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    find first buf_tt-doc-line-attr
      where buf_tt-doc-line-attr.gds-code = buf_pl-gds.gds-code
        and buf_tt-doc-line-attr.pl-code  = buf_pl-gds.pl-code
      no-error .
    if not available buf_tt-doc-line-attr then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_pl-gds.gds-code
        no-error.
      if available buf_goods then do:
        create buf_tt-doc-line-attr.
        assign
          buf_tt-doc-line-attr.gds-code    = buf_pl-gds.gds-code
          buf_tt-doc-line-attr.pl-code     = buf_pl-gds.pl-code
          buf_tt-doc-line-attr.artic       = buf_goods.artic
          buf_tt-doc-line-attr.prod-type   = buf_goods.prod-type
          buf_tt-doc-line-attr.prod-code   = buf_goods.prod-code
        .
      end.
    end.
    if can-find(first buf_doc-attr no-lock where
                     buf_doc-attr.doc-code = p-rvs-code
                 and buf_doc-attr.attr-code = "rvs-auto"
                 and buf_doc-attr.attr-value = "Yes")
    then do:
       assign
          vRvdDnstOn = no
          vRvdTmpOn = no
          vRvdLvlOn = no
          .
       if buf_place.is-meas  = no then do:
          assign
             vRvdDnstOn = yes
             vRvdTmpOn = yes
             vRvdLvlOn = yes
             .
       end.
       else do:
          find first buf_place-attr where
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = "place-rvd-dnsty"
                and logical(buf_place-attr.attr-value) = yes
            no-lock no-error.
         if available buf_place-attr then vRvdDnstOn = yes.
         find first buf_place-attr where
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = "place-rvd-tmp"
                and logical(buf_place-attr.attr-value) = yes
            no-lock no-error.
         if available buf_place-attr then vRvdTmpOn = yes.
         find first buf_place-attr where
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = "place-rvd-lvl"
                and logical(buf_place-attr.attr-value) = yes
            no-lock no-error.
         if available buf_place-attr then vRvdLvlOn = yes.
       end.
       if vRvdDnstOn or
          vRvdTmpOn or
          vRvdLvlOn
       then do:
          find first buf_rvs-line no-lock
             where   buf_rvs-line.rvs-code = p-rvs-code
                 and buf_rvs-line.obj-type = p-obj-type
                 and buf_rvs-line.obj-code = p-obj-code
                 and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                 and buf_rvs-line.gds-code = buf_pl-gds.gds-code
             no-error .
          if available buf_rvs-line then do:
               find first tt-rvs-line-attr EXCLUSIVE-LOCK
                    where tt-rvs-line-attr.attr-code = "rvd-on"
                      and tt-rvs-line-attr.gds-code = buf_rvs-line.gds-code
                      and tt-rvs-line-attr.obj-code = buf_rvs-line.obj-code
                      and tt-rvs-line-attr.obj-type = buf_rvs-line.obj-type
                      and tt-rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                      and tt-rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                  no-error .
              if not AVAILABLE tt-rvs-line-attr then do:
                 create tt-rvs-line-attr .
                 ASSIGN
                    tt-rvs-line-attr.attr-code = "rvd-on"
                    tt-rvs-line-attr.gds-code =  buf_rvs-line.gds-code
                    tt-rvs-line-attr.obj-code = buf_rvs-line.obj-code
                    tt-rvs-line-attr.obj-type = buf_rvs-line.obj-type
                    tt-rvs-line-attr.pl-code = buf_rvs-line.pl-code
                    tt-rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                    tt-rvs-line-attr.attr-value_s = ""
                 .
              end.
              else tt-rvs-line-attr.attr-value_s = "".
              if vRvdDnstOn then tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "p"
                                                               else tt-rvs-line-attr.attr-value_s + ",p".
              if vRvdTmpOn then  tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "t"
                                                               else tt-rvs-line-attr.attr-value_s + ",t".
              if vRvdLvlOn then  tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "l"
                                                               else tt-rvs-line-attr.attr-value_s + ",l".
          end.
       end.
    end.
  end.
  find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type = p-obj-type
      and prev_shift-obj.obj-code = p-obj-code
      and ( ( prev_shift-obj.shift-date = curr_shift-obj.shift-date
              and prev_shift-obj.shift-num < curr_shift-obj.shift-num
            )
            or prev_shift-obj.shift-date < curr_shift-obj.shift-date
          )
    use-index pi
    no-error .
  if available prev_shift-obj then do:
    find first buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type   = p-obj-type
        and buf_rvs-doc.obj-code   = p-obj-code
        and buf_rvs-doc.shift-date = prev_shift-obj.shift-date
        and buf_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and buf_rvs-doc.status_    = 'факт':U
        and buf_rvs-doc.rvs-type   = 'смена':U
      no-error .
    if available buf_rvs-doc then do:
      for each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        ,first buf_tt-doc-line-attr
        where buf_tt-doc-line-attr.gds-code = buf_rvs-line.gds-code
          and buf_tt-doc-line-attr.pl-code  = buf_rvs-line.pl-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        assign
          buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_rvs-line.state-measure-qnty
        .
      end.
    end.
  end.
define variable v-today        as date         no-undo.
define variable v-time         as integer      no-undo.
  run cur-time in this-procedure ( output v-today, output v-time).
for each buf_chk-doc where buf_chk-doc.chk-date = v-today
                       and buf_chk-doc.obj-code = curr_shift-obj.obj-code
                       and buf_chk-doc.obj-type = curr_shift-obj.obj-type,
                       each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
                       first buf_bar-code where buf_bar-code.b-code = buf_chk-gds.b-code,
                       first tt-doc-line-attr where tt-doc-line-attr.gds-code = buf_bar-code.gds-code:
if (buf_chk-doc.chk-type = INTEGER('1':U) OR  buf_chk-doc.chk-type = INTEGER('6':U)) then do:
  v-pl-code = 0 .
  if buf_chk-gds.pl-code = 0 or buf_chk-gds.pl-code = ? then do:
    find first buf_pl-pump-nozzle no-lock where buf_pl-pump-nozzle.status_ <> 'блок':U
                                  and buf_pl-pump-nozzle.nozzle-code = buf_chk-gds.nozzle-code
                                  and buf_pl-pump-nozzle.pump-code = buf_chk-gds.pump
                                  and buf_pl-pump-nozzle.obj-code = buf_chk-doc.obj-code
                                  and buf_pl-pump-nozzle.obj-type = buf_chk-doc.obj-type no-error .
  if AVAILABLE buf_pl-pump-nozzle then do:
  v-pl-code = buf_pl-pump-nozzle.pl-code .
  end.
end.
   else v-pl-code = buf_chk-gds.pl-code .
   find first tt-rvs-line-attr EXCLUSIVE-LOCK where tt-rvs-line-attr.attr-code = "current-sale"
                                 and tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
                                 and tt-rvs-line-attr.obj-code = buf_chk-doc.obj-code
                                 and tt-rvs-line-attr.obj-type = buf_chk-doc.obj-type
                                 and tt-rvs-line-attr.pl-code = v-pl-code
                                 and tt-rvs-line-attr.rvs-code = p-rvs-code no-error .
  if not AVAILABLE tt-rvs-line-attr then do:
    create tt-rvs-line-attr .
    ASSIGN
    tt-rvs-line-attr.attr-code = "current-sale"
    tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
    tt-rvs-line-attr.obj-code = buf_chk-doc.obj-code
    tt-rvs-line-attr.obj-type = buf_chk-doc.obj-type
    tt-rvs-line-attr.pl-code = v-pl-code
    tt-rvs-line-attr.rvs-code = p-rvs-code
    .
  end.
    tt-rvs-line-attr.attr-value = tt-rvs-line-attr.attr-value + buf_chk-gds.doc-qnty .
end.
end.
for each buf_trn-doc no-lock where buf_trn-doc.doc-date = v-today
                       and buf_trn-doc.obj-code = p-obj-code
                       and buf_trn-doc.obj-type = p-obj-type
                       and buf_trn-doc.doc-type = 'при':U,
      each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
      first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic
                        and buf_goods.prod-code = buf_doc-line.prod-code
                        and buf_goods.prod-type = buf_doc-line.prod-type,
                        each tt-doc-line-attr no-lock where tt-doc-line-attr.gds-code = buf_goods.gds-code,
                        each buf_doc-pl no-lock
                        where buf_doc-pl.out-code = buf_trn-doc.doc-code
                          and buf_doc-pl.gds-code = tt-doc-line-attr.gds-code
                          and buf_doc-pl.pl-code  = tt-doc-line-attr.pl-code
                         :
   find first tt-rvs-line-attr EXCLUSIVE-LOCK where tt-rvs-line-attr.attr-code = "income"
                                 and tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
                                 and tt-rvs-line-attr.obj-code = p-obj-code
                                 and tt-rvs-line-attr.obj-type = p-obj-type
                                 and tt-rvs-line-attr.pl-code = tt-doc-line-attr.pl-code
                                 and tt-rvs-line-attr.rvs-code = p-rvs-code no-error .
  if not AVAILABLE tt-rvs-line-attr then do:
    create tt-rvs-line-attr .
    ASSIGN
    tt-rvs-line-attr.attr-code = "income"
    tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
    tt-rvs-line-attr.obj-code = p-obj-code
    tt-rvs-line-attr.obj-type = p-obj-type
    tt-rvs-line-attr.pl-code = tt-doc-line-attr.pl-code
    tt-rvs-line-attr.rvs-code = p-rvs-code
    .
  end.
    tt-rvs-line-attr.attr-value = tt-rvs-line-attr.attr-value + buf_doc-pl.fact-qnty .
end.
  for each buf_inkas no-lock
    where buf_inkas.obj-type   = p-obj-type
      and buf_inkas.obj-code   = p-obj-code
      and buf_inkas.status_    = 'новый':U
      and buf_inkas.shift-date = curr_shift-obj.shift-date
      and buf_inkas.shift-num  = curr_shift-obj.shift-num
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    for each buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_inkas.inkas-code
        and buf_trn-doc.ext-doc-type = 'es':U
      ,each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest - buf_doc-pl.fact-qnty
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   - buf_doc-pl.fact-qnty
      .
    end.
    for each buf_trn-doc no-lock
      where buf_trn-doc.out-code = buf_inkas.inkas-code
        and buf_trn-doc.ext-doc-type = 'rs':U
      ,each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_doc-pl.fact-qnty
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   + buf_doc-pl.fact-qnty
      .
    end.
  end.
  for each buf_trn-doc no-lock
    where buf_trn-doc.obj-type   = p-obj-type
      and buf_trn-doc.obj-code   = p-obj-code
      and buf_trn-doc.status_    = 'факт':U
      and buf_trn-doc.shift-date = curr_shift-obj.shift-date
      and buf_trn-doc.shift-num  = curr_shift-obj.shift-num
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    for each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if lookup( buf_trn-doc.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then do:
        assign
          v-sign = -1.0
        .
      end.
      else do:
        assign
          v-sign = 1.0
        .
        if lookup( buf_trn-doc.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then do:
          undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_trn-doc.ext-doc-type).
        end.
      end.
      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_doc-pl.fact-qnty * v-sign
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   + buf_doc-pl.fact-qnty * v-sign
      .
    end.
  end.
  do transaction
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    for each buf_tt-doc-line-attr
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      find first buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code  = p-rvs-code
          and buf_doc-line-attr.gds-code  = buf_tt-doc-line-attr.gds-code
          and buf_doc-line-attr.attr-code = substitute("rvs-&1", buf_tt-doc-line-attr.pl-code)
        no-error .
      if not available buf_doc-line-attr then do:
        create buf_doc-line-attr .
        assign
          buf_doc-line-attr.doc-code = p-rvs-code
          buf_doc-line-attr.gds-code = buf_tt-doc-line-attr.gds-code
          buf_doc-line-attr.attr-code = substitute("rvs-&1", buf_tt-doc-line-attr.pl-code)
        .
      end.
      assign
        buf_doc-line-attr.attr-value = substitute ( "&1&2&3", buf_tt-doc-line-attr.rest, chr(4), buf_tt-doc-line-attr.oo )
      .
    end.
    for each buf_tt-rvs-line-attr:
      find first buf_rvs-line-attr EXCLUSIVE-LOCK where buf_rvs-line-attr.attr-code = buf_tt-rvs-line-attr.attr-code
                                                    and buf_rvs-line-attr.obj-code = buf_tt-rvs-line-attr.obj-code
                                                    and buf_rvs-line-attr.obj-type = buf_tt-rvs-line-attr.obj-type
                                                    and buf_rvs-line-attr.pl-code = buf_tt-rvs-line-attr.pl-code
                                                    and buf_rvs-line-attr.rvs-code = buf_tt-rvs-line-attr.rvs-code
                                                    and buf_rvs-line-attr.gds-code = buf_tt-rvs-line-attr.gds-code no-error .
      if not AVAILABLE buf_rvs-line-attr then do:
        create buf_rvs-line-attr .
      assign
        buf_rvs-line-attr.attr-code = buf_tt-rvs-line-attr.attr-code
        buf_rvs-line-attr.obj-code = buf_tt-rvs-line-attr.obj-code
        buf_rvs-line-attr.obj-type = buf_tt-rvs-line-attr.obj-type
        buf_rvs-line-attr.pl-code = buf_tt-rvs-line-attr.pl-code
        buf_rvs-line-attr.rvs-code = buf_tt-rvs-line-attr.rvs-code
        buf_rvs-line-attr.gds-code = buf_tt-rvs-line-attr.gds-code
      .
      end.
      if buf_rvs-line-attr.attr-code = "rvd-on"
         then buf_rvs-line-attr.attr-value = buf_tt-rvs-line-attr.attr-value_s .
      else
      buf_rvs-line-attr.attr-value = string(buf_tt-rvs-line-attr.attr-value) .
    end.
  end.
  empty temp-table  buf_tt-doc-line-attr.
  empty TEMP-TABLE  buf_tt-rvs-line-attr.
  assign
    p-ok = true
  .
  return .
end.
