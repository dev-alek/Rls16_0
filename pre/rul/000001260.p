using Ibs.Th.Rul.Dis-card_.
using Ibs.Th.Rul.Clients_.
using Ibs.Th.Rul.Dis-card-sale_obj.
using Ibs.Th.Rul.Dis-card-type_.
using Ibs.Th.Rul.Dis-tot_.
block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-fact-date as date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table temp-d-card no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.
define INPUT parameter table for temp-d-card.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 4".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  variable garbcoll_ii as integer no-undo .
define  temp-table temp-gc no-undo
field ii as integer
field obj-r as handle
field cn as character
index pi is unique primary
ii
index icn
cn.
procedure garbcoll_create-gc-entry :
define input parameter p-cn as character no-undo .
define input parameter p-obj-r as handle no-undo .
  do
  on error undo, return error
  :
    create temp-gc.
    assign
    temp-gc.ii = garbcoll_ii
    garbcoll_ii = garbcoll_ii + 1
    temp-gc.cn = p-cn
    temp-gc.obj-r = p-obj-r
    .
  end.
end procedure.
procedure garbcoll_clear :
  do
  on error undo, return error
  :
    for each temp-gc:
      delete object temp-gc.obj-r.
      delete temp-gc.
    end.
  end.
end procedure.
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
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE vchk-pay NO-UNDO
FIELD d-card like ub.chk-doc.d-card
FIELD PAY-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD doc-date like ub.chk-pay.chk-date
FIELD cre-pay as logical
FIELD exch-rate as decimal
FIELD base-rate as decimal
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD tot-base like ub.chk-pay.tot-base
FIELD tot-rubl like ub.chk-pay.tot-rubl
FIELD pmnt-code like ub.payment.pmnt-code
field obj-type            like ub.clients.obj-type
field obj-code            like ub.clients.obj-code
INDEX PI IS PRIMARY UNIQUE
d-card pay-code curr-code doc-date cre-pay exch-rate base-rate
index iobj obj-type obj-code
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes7 as character no-undo .
    define variable v-param-type7 as character no-undo .
    define variable v-value-character7 as INTEGER no-undo .
    define variable v-value-date7 as date no-undo .
    define variable v-value-decimal7 as decimal no-undo .
    define variable v-value-integer7 AS integer no-undo .
    define variable v-value-logical7 AS LOGICAL no-undo .
    define variable v-tth7 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character7
        ,output v-value-date7
        ,output v-value-decimal7
        ,output v-value-integer7
        ,output v-value-logical7
        ,output v-param-type7
        ,INPUT-OUTPUT table-handle v-tth7
        ) no-error .
    if error-status :error then do:
      delete object v-tth7.
      v-mes7 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes7.
    end.
    delete object v-tth7.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer7)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess8 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess8
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info11 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info11, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info11, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info11 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info11, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info11, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info11, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info11, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info11, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info11, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info11 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info11, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info11 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
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
define SHARED temp-table temp-cmd no-undo
field cmd-code as integer
field db-list as character
index pi is unique primary
db-list
index icmd
cmd-code
.
define SHARED temp-table temp-smart-route no-undo
field key-field as character
field db-num as integer
index pi is unique primary
key-field
db-num
.
define SHARED temp-table temp-no-route no-undo
field rec-ord as integer
field db-num as integer
index pi is unique primary
db-num
rec-ord
index iro
rec-ord
.
define SHARED temp-table temp-smart-link no-undo
field uniq-key-rec as character
field key-field as character
field rec-ord as integer
field is-smart as logical
index pi is unique primary
key-field
uniq-key-rec
rec-ord
index iu
uniq-key-rec
index iro
rec-ord
.
define SHARED temp-table temp-nws-outline no-undo
like ub.nws-outline.
procedure create-smart-route :
define input parameter p-key-field as character no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error
  :
    find first buf_temp-smart-route where
              buf_temp-smart-route.key-field = p-key-field
          and buf_temp-smart-route.db-num = p-db-num no-error.
    if not available buf_temp-smart-route then do:
      create buf_temp-smart-route.
      assign
      buf_temp-smart-route.key-field = p-key-field
      buf_temp-smart-route.db-num = p-db-num
      .
    end.
  end.
end procedure.
procedure create-smart-route-link :
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define input parameter p-key-field as character no-undo .
define input parameter p-rec-ord as integer no-undo .
define input parameter p-is-smart as logical no-undo .
define variable v-key-rec as character no-undo .
define buffer buf_temp-smart-link for temp-smart-link.
  do
  on error undo, return error
  :
    run gen-key-rec in this-procedure ( input p-tbl-name
                                       ,input p-bh_tbl-name
                                       ,output v-key-rec     ).
   find first buf_temp-smart-link where
              buf_temp-smart-link.uniq-key-rec = v-key-rec
           and buf_temp-smart-link.key-field = p-key-field
           and buf_temp-smart-link.rec-ord = p-rec-ord
           no-error .
   if not available buf_temp-smart-link then do:
     create buf_temp-smart-link.
     assign
     buf_temp-smart-link.uniq-key-rec = v-key-rec
     buf_temp-smart-link.key-field = p-key-field
     buf_temp-smart-link.rec-ord = p-rec-ord
     buf_temp-smart-link.is-smart = p-is-smart
     .
   end.
  end.
end procedure.
procedure create-nws-outline :
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define input parameter p-outline-type as character no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-charkey_two as character no-undo .
define input parameter p-charkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .
define variable v-no-id as integer no-undo .
define variable v-rec-ord as integer no-undo .
  do
  on error undo, return error return-value
  :
    find last temp-nws-outline use-index pi no-error .
    v-no-id = (if available temp-nws-outline
               then (temp-nws-outline.no-id  + 1)
               else 1).
    create temp-nws-outline.
    assign
    temp-nws-outline.charkeY_one = p-charkey_one
    temp-nws-outline.charkeY_two = p-charkey_two
    temp-nws-outline.charkeY_three = p-charkey_three
    temp-nws-outline.key#_one = p-key#_one
    temp-nws-outline.key#_two = p-key#_two
    temp-nws-outline.key#_three = p-key#_three
    temp-nws-outline.no-id = v-no-id
    temp-nws-outline.outline-type = p-outline-type
    .
                                run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'nws-outline':U                                                                                          ,input '+update'                                                                                         ,input (buffer temp-nws-outline:handle)                                                                                    ,input ''                                                                                         ,output v-rec-ord                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'nws-outline':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run  create-smart-route in this-procedure (
                                                input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                               ,input -1).
    run create-smart-route-link in this-procedure (
                                                   input 'nws-outline':U
                                                  ,input (buffer temp-nws-outline:handle)
                                                  ,input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                                  ,input v-rec-ord
                                                  ,input no
                                                  ).
  end.
end procedure.
procedure create-no-route :
define input parameter p-rec-ord as integer no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
do
on error undo, return error
:
   find first buf_temp-no-route where
              buf_temp-no-route.rec-ord = p-rec-ord
           and buf_temp-no-route.db-num = p-db-num no-error .
   if not available buf_temp-no-route then do:
     create buf_temp-no-route.
     assign
     buf_temp-no-route.rec-ord = p-rec-ord
     buf_temp-no-route.db-num = p-db-num
     .
   end.
end.
end procedure.
procedure clear-from-rec-ord :
define input parameter p-rec-ord as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
define buffer buf_temp-smart-link for temp-smart-link.
do
on error undo, return error
:
for each buf_temp-no-route where
        buf_temp-no-route.rec-ord > p-rec-ord:
  delete buf_temp-no-route.
end.
for each buf_temp-smart-link where
        buf_temp-smart-link.rec-ord > p-rec-ord:
   delete buf_temp-smart-link.
end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure library-cls_get-handle :
define input parameter p-library-name as character no-undo .
define output parameter p-library-handle as handle no-undo .
  do
  on error undo, return error
  :
    CASE p-library-name:
      when "library" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library.
      end.
      when "library2" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library2.
      end.
    end case.
  end.
end procedure.
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info15
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info15
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info15 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info15 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info15 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info15 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info15 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info15 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info15 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info15 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-type as character no-undo .
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v-retry as logical no-undo .
define variable v-last-rec-ord as integer no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
define buffer buf_dis-card-sale_obj for temp-d-card.
define variable vh_dis-card-sale_obj as handle no-undo .
vh_dis-card-sale_obj = buffer buf_dis-card-sale_obj:handle.
define temp-table temp-clients_ no-undo like ub.clients.
define temp-table temp-dis-card_ no-undo like ub.dis-card.
define buffer buf_cash-pay for ub.cash-pay.
define stream instream.
define variable log-file-name                as character      no-undo init "indcard.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-seek                       as int64          no-undo .
function 00040000_get-readed-line returns character ( input p-seek as int64):
define variable v-line as character no-undo .
seek stream instream to p-seek.
import stream instream unformatted v-line.
return v-line.
end function.
function 00040000_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,chr(10)
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
return v-mess.
end function.
function 00040000_after-import_f returns logical ( input p-d-card as character):
  run 00040000_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.
 define variable p-dis-tot-obj-code as integer no-undo.
 define variable p-issue-code as integer no-undo.
 define variable p-issue-date as date no-undo.
 define variable p-valid-date as date no-undo.
 define variable p-cli-grp-code as integer no-undo.
 define variable p-lim-cr as decimal no-undo.
 define variable p-category as integer no-undo.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clientsh_write-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'clients':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'clients':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-clients.
  buffer-copy buf_clients to buf_c-clients
  assign
  buf_c-clients.obj-type           = buf_clients.obj-type
  buf_c-clients.obj-code           = buf_clients.obj-code
  buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
  buf_c-clients.corr-time          = v-time
  buf_c-clients.corr-user-db-num   = g#db-num
  buf_c-clients.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-clients.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-clients to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'clients':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = p-doc-type
  buf_c-cli-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-clients':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-clients:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-clients':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-clients':U
                                                    ,input buffer buf_c-clients:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'clients':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_clients:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'clients':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'clients':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'clients':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'clients':U
                                                ,input buffer buf_clients:handle
                                                ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                              ,input -1).
end.
end procedure.
procedure clientsh_write-firm-rul  :
define parameter buffer buf_firm for ub.firm .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'firm':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'firm':U
    buf_temp-hist-nws-option.key#_one = 2
    .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-firm.
  buffer-copy buf_firm to buf_c-firm
  assign
  buf_c-firm.firm-code          = buf_firm.firm-code
  buf_c-firm.chip-num           = next-value (s-cli-chip, ub)
  buf_c-firm.corr-time          = v-time
  buf_c-firm.corr-user-db-num   = g#db-num
  buf_c-firm.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-firm.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-firm to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'firm':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = 'trn-doc':U
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-firm':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-firm:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-firm':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-firm':U
                                                    ,input buffer buf_c-firm:handle
                                                    ,input string(buf_firm.firm-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ('орг':U + string(buf_firm.firm-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input ('орг':U + string(buf_firm.firm-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-firm-rul  :
define parameter buffer buf_firm for ub.firm.
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'firm':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_firm:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'firm':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'firm':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'firm':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'firm':U
                                                ,input buffer buf_firm:handle
                                                ,input ('орг':U + string(buf_firm.firm-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input ('орг':U + string(buf_firm.firm-code))
                                              ,input -1).
end.
end procedure.
procedure clientsh_write-person-rul  :
define parameter buffer buf_person for ub.person .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'person':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'person':U
    buf_temp-hist-nws-option.key#_one = 2
    .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-person.
  buffer-copy buf_person to buf_c-person
  assign
  buf_c-person.psn-code           = buf_person.psn-code
  buf_c-person.chip-num           = next-value (s-cli-chip, ub)
  buf_c-person.corr-time          = v-time
  buf_c-person.corr-user-db-num   = g#db-num
  buf_c-person.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-person.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-person to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'person':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = 'trn-doc':U
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-person':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-person:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-person':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-person':U
                                                    ,input buffer buf_c-person:handle
                                                    ,input string(buf_person.psn-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ('орг':U + string(buf_person.psn-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input ('орг':U + string(buf_person.psn-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-person-rul  :
define parameter buffer buf_person for ub.person.
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'person':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_person:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'person':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'person':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'person':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'person':U
                                                ,input buffer buf_person:handle
                                                ,input ('орг':U + string(buf_person.psn-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input ('орг':U + string(buf_person.psn-code))
                                              ,input -1).
end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discardh_write-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-card':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = 2
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-card':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card.
  buffer-copy buf_dis-card to buf_c-dis-card
  assign
  buf_c-dis-card.d-card             = buf_dis-card.d-card
  buf_c-dis-card.card-num           = buf_dis-card.card-num
  buf_c-dis-card.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-card.corr-time          = v-time
  buf_c-dis-card.corr-user-db-num   = g#db-num
  buf_c-dis-card.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else g#userid
                                            )
                                        )
  buf_c-dis-card.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-card to buf_c-dc-hist
  assign
  buf_c-dc-hist.action =  p-action
  buf_c-dc-hist.subject = 'dis-card':U
  buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-dis-card':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-card:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-card':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-dis-card':U
                                                    ,input buffer buf_c-dis-card:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                    ,input buffer buf_c-dc-hist:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure discardh_send-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if g#db-num > 0 then return.
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'dis-card':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-card:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  run create-smart-route-link in this-procedure ( input 'dis-card':U
                                                ,input buffer buf_dis-card:handle
                                                ,input buf_dis-card.d-card
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                              ,input -1).
end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dis-hsth_write-dis-host-rul :
define parameter buffer buf_dis-host for ub.dis-host .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if not available buf_dis-host then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-host':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-host':U
    buf_temp-hist-nws-option.key#_one = p-dtm-code
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-host.
  buffer-copy buf_dis-host to buf_c-dis-host
  assign
  buf_c-dis-host.d-card             = buf_dis-host.d-card
  buf_c-dis-host.host-code          = buf_dis-host.host-code
  buf_c-dis-host.card-num           = buf_dis-host.card-num
  buf_c-dis-host.dt-code            = buf_dis-host.dt-code
  buf_c-dis-host.main-card          = buf_dis-host.main-card
  buf_c-dis-host.first-main-card    = buf_dis-host.first-main-card
  buf_c-dis-host.first-card         = buf_dis-host.first-card
  buf_c-dis-host.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-host.corr-time          = v-time
  buf_c-dis-host.corr-user-db-num   = g#db-num
  buf_c-dis-host.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                      )
  buf_c-dis-host.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-host to buf_c-dc-hist
  assign
  buf_c-dc-hist.action = p-action
  buf_c-dc-hist.subject = 'dis-host':U
  buf_c-dc-hist.host-code =  buf_dis-host.host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
  and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-dis-host':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-host:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-host':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      case  buf_temp-hist-nws-option.smart-nws :
        when integer('0':U)
        or
        when integer('10':U)
        then do:
         if buf_dis-host.dt-code = 0
          and buf_dis-host.host-code  = 0
          and buf_Dis-host.whole-send-news = integer('-1':U) then do:
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input no
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input no
                                                        ).
            run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                      ,input -1).
          end.
          else do:
            run get-db-list-for-d-card2  in this-procedure ( input buf_dis-host.d-card).
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input yes
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input yes
                                                        ).
          end.
        end.
        when integer('1':U) then do:
         if buf_dis-host.dt-code = 0
          and buf_dis-host.host-code  = 0
          and buf_Dis-host.whole-send-news = integer('-1':U) then do:
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input no
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input no
                                                        ).
            run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                      ,input -1).
          end.
        end.
        otherwise do:
          run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                      ,input buffer buf_c-dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord2
                                                      ,input no
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord3
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
      end case.
    end.
  end.
end.
end procedure.
procedure dis-hsth_send-dis-host-rul :
define parameter buffer buf_dis-host for ub.dis-host .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if g#db-num > 0 then return.
  if not available buf_dis-host then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-host':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-host':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'dis-host':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-host:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-host':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  if g#db-num = 0 then do:
   case buf_temp-hist-nws-option.smart-nws:
      when integer('0':U)
      or
      when integer('10':U) then do:
        if buf_dis-host.dt-code = 0
        and buf_dis-host.host-code  = 0
        and buf_Dis-host.whole-send-news = integer('-1':U) then do:
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
        else do:
          run get-db-list-for-d-card2  in this-procedure ( input buf_dis-host.d-card).
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input yes
                                                      ).
        end.
      end.
      when integer('1':U) then do:
        if buf_dis-host.dt-code = 0
        and buf_dis-host.host-code  = 0
        and buf_Dis-host.whole-send-news = integer('-1':U) then do:
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
      end.
      otherwise do:
        run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                    ,input buffer buf_dis-host:handle
                                                    ,input buf_dis-host.d-card
                                                    ,input v-rec-ord1
                                                    ,input no
                                                    ).
        run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                  ,input -1).
      end.
    end.
  end.
end.
end procedure.
procedure get-db-list-for-d-card2 :
define input parameter p-d-card as character no-undo .
define variable v-current-db-processed as logical no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error return-value
  :
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = p-d-card,
       first buf_clients no-lock where
            buf_clients.obj-type = buf_dis-obj.obj-type
        and buf_clients.obj-code = buf_dis-obj.obj-code
    break by
    buf_clients.db-num:
      if first-of(buf_Clients.db-num) then do:
        find first buf_temp-smart-route no-lock where
              buf_temp-smart-route.key-field = p-d-card
          and buf_temp-smart-route.db-num = buf_clients.db-num
              no-error.
        if available buf_temp-smart-route then return.
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = buf_clients.db-num
        .
        if buf_clients.db-num = g#db-num then do:
          v-current-db-processed = yes.
        end.
      end.
    end.
    if not v-current-db-processed then do:
      find first buf_temp-smart-route no-lock where
            buf_temp-smart-route.key-field = p-d-card
        and buf_temp-smart-route.db-num = g#db-num  no-error.
      if not available buf_temp-smart-route then do:
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = g#db-num
        .
      end.
    end.
  end.
end procedure.
on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.
 define variable Card-number1 as  character no-undo .
 define variable Card1 as class Dis-card_ no-undo .
Card1 = new Dis-card_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save) .
 define variable Cli-code1 as  integer no-undo .
 define variable Cli-first-name1 as  character no-undo .
 define variable Cli-grp-code1 as  integer no-undo .
 define variable Cli-last-name1 as  character no-undo .
 define variable Cli-patronymic-name1 as  character no-undo .
 define variable Cli-phone1 as  character no-undo .
 define variable Cli-type1 as  character no-undo .
 define variable Client1 as class Clients_ no-undo .
Client1 = new Clients_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input "discards") .
 define variable D-pcnt1 as  decimal no-undo .
 define variable Dc-type1 as  character no-undo .
 define variable Dis-card-type1 as class Dis-card-type_ no-undo .
Dis-card-type1 = new Dis-card-type_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save) .
 define variable Emitent-host-code1 as  integer no-undo .
 define variable Import-sum-obj1 as class Dis-card-sale_obj no-undo .
Import-sum-obj1 = new Dis-card-sale_obj( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input vh_dis-card-sale_obj, input p-codex-id, input p-ruleset-id) .
 define variable Issue-code1 as  integer no-undo .
 define variable Issue-date1 as  date no-undo .
 define variable Lim-cr1 as  decimal no-undo .
 define variable Message1 as  character no-undo .
 define variable Netto-sum-base1 as  decimal no-undo .
 define variable Netto-sum-rubl1 as  decimal no-undo .
 define variable Num-chk1 as  integer no-undo .
 define variable Shop-code1 as  integer no-undo .
 define variable Tot-sum1 as class Dis-tot_ no-undo .
Tot-sum1 = new Dis-tot_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save) .
if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.
procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
assign
v-emitent-host-code = p-emitent-host-code
v-type = p-type.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт физ лиц/карт из файла &1", file-name)).
    input stream Instream from value(file-name).
    _stroka:
    REPEAT:
      v-retry = no.
      if retry then do:
        v-retry = yes.
      end.
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
      if not v-retry then
      num-rec = num-rec + 1.
      if not v-retry then do:
      run get-last-rec-ord in p-cmd-proc-handle ( input p-cmd-code, output v-last-rec-ord).
      v-retry-action = 0 .
      end.
     _release:
      do on error undo, retry:
        if  retry
        or v-retry
        then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Ошибка при импорте строки &1&2&3&2&4"
                                                                  , num-rec
                                                                  , chr(10)
                                                                  , error-status:get-message(1)
                                                                  , return-value)).
        end.
if v-retry-action < 1 then do:
Client1:Clients_release_ ( ) .
end.
if v-retry-action < 2 then do:
Card1:Dis-card_release_ ( ) .
end.
if v-retry-action < 3 then do:
Dis-card-type1:Dis-card-type_release_ ( ) .
end.
if v-retry-action < 4 then do:
Import-sum-obj1:Dis-card-sale_objrelease_ ( ) .
end.
if v-retry-action < 5 then do:
Tot-sum1:Dis-tot_release_ ( ) .
end.
      end.
       v-seek = seek(instream).
       _rule:
       do transaction on error undo _rule, retry _rule:
         if retry
         or v-retry
         then do:
            run write-log-and-file in p-log-handle (
                                                    input 1
                                                  , input log-file-name
                                                  , input 1
                                                  , input substitute("&1&2&3"
                                                                    , error-status:get-message(1)
                                                                    , chr(10)
                                                                    , return-value)).
           run undo-from-rec-ord in p-cmd-proc-handle ( input p-cmd-code, input v-last-rec-ord).
           run clear-from-rec-ord in this-procedure ( input v-last-rec-ord).
           next _stroka.
         end.
         else do:
_1260:
do:
 Card-number1 = "" .
 import stream INstream  DELIMITER ' '  Cli-type1 Cli-code1 Cli-last-name1 Cli-first-name1 Cli-patronymic-name1 Cli-phone1 Cli-grp-code1 Card-number1 D-pcnt1 Num-chk1 Netto-sum-base1 Netto-sum-rubl1 Shop-code1 Issue-code1 Issue-date1 Dc-type1 Lim-cr1  no-error .
IF  error-status:error = true  THEN do:
  _1287:
  do:
  IF  00040000_get-readed-line( input v-seek) = ""  THEN do:
    _1286:
    do:
     next _stroka .
    end.
  end.
  IF  num-rec = 1  THEN do:
    _1298:
    do:
     Message1 = 00040000_get-error-message() + "Строчка не разобрана!~nТребуемый формат строки(между полями пробелы - символьные поля закавычены):~nтип клиента или ?~nкод клиента или ?~nфамилия клиента или ?~nимя клиента или ?~nотчество клиента или ?~nтелефон клиента или ?~nкод группы клиентов или ?~nномер дисконтной карты - символьный - только цифры~nпроцент скидки - неотрицательный меньше 100 или ?~nчисло чеков клиента или ?~nсумма покупок в базовой валюте или ?~nномер магазина на который будут начислены итоги по дисконтной карте или ?~nномер магазина выдавшего дисконтную карту или ?~nдата выдачи дисконтной карты или ?~nтип карты или ?~nлимит кредита или ?" .
    end.
  end.
  else do:
    _1297:
    do:
     Message1 = 00040000_get-error-message() .
    end.
  end.
   Message1 = Message1 + "~nСтрока :" + String( num-rec) .
   run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
   next _stroka .
  end.
end.
IF  Card1:find_dis-card_no-error( INPUT Card-number1) = false  THEN do:
  _1264:
  do:
  IF  (Cli-type1 = ?) OR (Cli-code1 = ?) OR Cli-type1 = "?"  THEN do:
    _1270:
    do:
    IF  (Cli-type1 = ?) OR Cli-type1 = "?"  THEN do:
      _1271:
      do:
       Cli-type1 = 'чел':U .
      end.
    end.
    IF  (Cli-code1 = ?)  THEN do:
      _1294:
      do:
       Cli-code1 = 0 .
      end.
    end.
    IF  (Cli-grp-code1 = ?)  THEN do:
      _1269:
      do:
       Cli-grp-code1 = p-cli-grp-code .
      end.
    end.
    IF  Client1:create_clients_( INPUT Cli-type1, INPUT Cli-code1, INPUT Cli-last-name1, INPUT Cli-grp-code1) = false  THEN do:
      _1302:
      do:
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
       undo _stroka, retry _stroka .
      end.
    end.
    IF  Cli-type1 = 'чел':U  THEN do:
      _1285:
      do:
      IF  (Cli-first-name1 <> ?)  THEN do:
        _1293:
        do:
         Client1:name1 = Cli-first-name1 .
        end.
      end.
      IF  (Cli-patronymic-name1 <> ?)  THEN do:
        _1284:
        do:
         Client1:name2 = Cli-patronymic-name1 .
        end.
      end.
      end.
    end.
    IF  (Cli-phone1 <> ?)  THEN do:
      _1288:
      do:
       Client1:phone = Cli-phone1 .
      end.
    end.
    end.
  end.
  else do:
    _1289:
    do:
    IF  Client1:find_clients_no-error( INPUT Cli-type1, INPUT Cli-code1) = false  THEN do:
      _1292:
      do:
       Message1 = "Не найден клиент-держатель карты:" + Cli-type1 + String( Cli-code1) .
       Message1 = Message1 + "~nСтрока :" + String( num-rec) .
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
       undo _stroka, retry _stroka .
      end.
    end.
    end.
  end.
  IF  (Dc-type1 = ?) OR Dc-type1 = "?"  THEN do:
    _1265:
    do:
     Dc-type1 = v-type .
    end.
  end.
   Emitent-host-code1 = v-emitent-host-code .
  IF  Card1:create_dis-card_( INPUT v-current-obj-type, INPUT v-current-obj-code, INPUT Card-number1, INPUT Emitent-host-code1, INPUT Dc-type1, INPUT ( Cli-type1 + String( Cli-code1) )) = false  THEN do:
    _1274:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
  IF  (Issue-code1 = ?)  THEN do:
    _1273:
    do:
     Issue-code1 = p-issue-code .
    end.
  end.
   Card1:issue-code = Issue-code1 .
  IF  ( Issue-date1 = ? )  THEN do:
    _1263:
    do:
     Issue-date1 = p-issue-date .
    end.
  end.
   Card1:issue-date = Issue-date1 .
  IF  (Lim-cr1 = ? )  THEN do:
    _1301:
    do:
     Lim-cr1 = p-lim-cr .
    end.
  end.
   Card1:lim-kr = Lim-cr1 .
   Card1:category = p-category .
   Card1:valid-date = p-valid-date .
   Card1:valid-from = Issue-date1 .
   Dis-card-type1:find_dis-card-type_( INPUT Emitent-host-code1, INPUT Dc-type1) .
  IF  (D-pcnt1 = ? )  THEN do:
    _1291:
    do:
    IF  ( Dis-card-type1:dflt-d-pcnt-method = integer('1':U) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer('3':U) )  THEN do:
      _1290:
      do:
       D-pcnt1 = Dis-card-type1:dflt-pcnt# .
      end.
    end.
    IF  ( Dis-card-type1:dflt-d-pcnt-method = integer('2':U) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer('3':U) )  THEN do:
      _1300:
      do:
       D-pcnt1 = Dis-card-type1:dflt-cash-pcnt# .
      end.
    end.
    end.
  end.
  IF  ( Dis-card-type1:dflt-d-pcnt-method = integer('1':U) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer('3':U) )  THEN do:
    _1266:
    do:
     Card1:d-pcnt = D-pcnt1 .
    end.
  end.
  else do:
    _1296:
    do:
     Card1:d-pcnt = 0 .
    end.
  end.
  IF  ( Dis-card-type1:dflt-d-pcnt-method = integer('2':U) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer('3':U) )  THEN do:
    _1299:
    do:
     Card1:cash-d-pcnt = D-pcnt1 .
    end.
  end.
  else do:
    _1272:
    do:
     Card1:cash-d-pcnt = 0 .
    end.
  end.
   Card1:d-pcnt-method = Dis-card-type1:dflt-d-pcnt-method .
   Card1:credit-card = Dis-card-type1:dflt-credit-card .
   Card1:debet-card = Dis-card-type1:dflt-debet-card .
   Card1:staff-card = Dis-card-type1:dflt-staff-card .
  IF  (Shop-code1 = ?)  THEN do:
    _1295:
    do:
     Shop-code1 = p-dis-tot-obj-code .
    end.
  end.
  IF  ( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)  THEN do:
    _1268:
    do:
    IF  Import-sum-obj1:create_dis-card-sale_obj( INPUT Card-number1, INPUT 'маг':U, INPUT Shop-code1, INPUT v-current-doc-code, INPUT Issue-date1) = false  THEN do:
      _1267:
      do:
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
       undo _stroka, retry _stroka .
      end.
    end.
     Import-sum-obj1:pay-tot-base = Netto-sum-base1 .
     Import-sum-obj1:pay-tot-rubl = Netto-sum-rubl1 .
     Import-sum-obj1:gds-tot-base = Netto-sum-base1 .
     Import-sum-obj1:gds-tot-rubl = Netto-sum-rubl1 .
     Import-sum-obj1:num-chk = Num-chk1 .
     Import-sum-obj1:type = Dc-type1 .
     Import-sum-obj1:emitent-host-code = Emitent-host-code1 .
    end.
  end.
  IF  Tot-sum1:find_dis-tot_( INPUT Card-number1) = false  THEN do:
    _1283:
    do:
     Tot-sum1:create_dis-tot_( INPUT Card-number1) .
    end.
  end.
  IF  Client1:clients_save( ) = false  THEN do:
    _1277:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
   Card1:cli-code = Client1:obj-code .
   Import-sum-obj1:cli-type = Card1:cli-type .
   Import-sum-obj1:cli-code = Card1:cli-code .
  IF  Card1:dis-card_save( ) = false  THEN do:
    _1278:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
  IF  Tot-sum1:dis-tot_save( ) = false  THEN do:
    _1279:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
  IF  (( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)) and Import-sum-obj1:dis-card-sale_objsave( ) = false  THEN do:
    _1280:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
  IF  00040000_after-import_f( input Card-number1) = false  THEN do:
    _1936:
    do:
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
     undo _stroka, retry _stroka .
    end.
  end.
  end.
end.
else do:
  _1276:
  do:
  IF  (Shop-code1 = ?)  THEN do:
    _1282:
    do:
     Shop-code1 = p-dis-tot-obj-code .
    end.
  end.
   Cli-type1 = Card1:cli-type .
   Cli-code1 = Card1:cli-code .
   Emitent-host-code1 = Card1:emitent-host-code .
   Dc-type1 = Card1:type .
  IF  ( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)  THEN do:
    _1262:
    do:
    IF  Import-sum-obj1:find_dis-card-sale_obj_no-error( INPUT Card-number1) = false  THEN do:
      _1261:
      do:
       Message1 = "Нельзя импортировать итоги по уже имеющейся ДК" .
       Message1 = Message1 + "~nСтрока :" + String( num-rec) .
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
       undo _stroka, retry _stroka .
      end.
    end.
    IF  Import-sum-obj1:create_dis-card-sale_obj( INPUT Card-number1, INPUT 'маг':U, INPUT Shop-code1, INPUT v-current-doc-code, INPUT Issue-date1) = false  THEN do:
      _1275:
      do:
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
       undo _stroka, retry _stroka .
      end.
    end.
     Import-sum-obj1:pay-tot-base = Netto-sum-base1 .
     Import-sum-obj1:pay-tot-rubl = Netto-sum-rubl1 .
     Import-sum-obj1:gds-tot-base = Netto-sum-base1 .
     Import-sum-obj1:gds-tot-rubl = Netto-sum-rubl1 .
     Import-sum-obj1:num-chk = Num-chk1 .
     Import-sum-obj1:type = Dc-type1 .
     Import-sum-obj1:emitent-host-code = Emitent-host-code1 .
     Import-sum-obj1:cli-type = Cli-type1 .
     Import-sum-obj1:cli-code = Cli-code1 .
    IF  Import-sum-obj1:dis-card-sale_objsave( ) = false  THEN do:
      _1281:
      do:
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
       undo _stroka, retry _stroka .
      end.
    end.
    IF  00040000_after-import_f( input Card-number1) = false  THEN do:
      _1937:
      do:
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + chr(10) + "Строка: " + String(num-rec))).
assign v-view-log = yes .
       undo _stroka, retry _stroka .
      end.
    end.
    end.
  end.
  end.
end.
end.
        end.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry
        or v-retry
        then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("&1&2&3"
                                                                  , error-status:get-message(1)
                                                                  , chr(10)
                                                                  , v-last-error-message )).
        end.
if v-retry-action < 1 then do:
Client1:Clients_release_ ( ) .
end.
if v-retry-action < 2 then do:
Card1:Dis-card_release_ ( ) .
end.
if v-retry-action < 3 then do:
Dis-card-type1:Dis-card-type_release_ ( ) .
end.
if v-retry-action < 4 then do:
Import-sum-obj1:Dis-card-sale_objrelease_ ( ) .
end.
if v-retry-action < 5 then do:
Tot-sum1:Dis-tot_release_ ( ) .
end.
      end.
      if v-retry-action = 0 then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
      if num-rec modulo 100 = 0 then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Записи &1-&2: сохранение/пересылка в СПН...", num-rec - 100, num-rec)).
        find first buf_temp-cmd use-index pi.
        run after-command in p-parent-handle (buffer buf_temp-cmd) no-error.
        if error-status:error then do:
                   run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при сохранении/пересылке по СПН:&1&2&1&3"                                       , chr(10)                                       , error-status:get-message(1)                                       , return-value )).                      assign v-view-log = yes.
          undo _main, return error .
        end.
        run before-command in p-parent-handle (buffer buf_temp-cmd) no-error.
        if error-status:error then do:
                   run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при инициации сохранения/пересылки пакета по СПН:&1&2&1&3"                                       , chr(10)                                       , error-status:get-message(1)                                       , return-value )).                      assign v-view-log = yes.
        end.
        find first buf_temp-cmd use-index pi.
        p-cmd-code = buf_temp-cmd.cmd-code.
      end.
    end.
    if not v-stop then do:
      num-rec = num-rec - 1.
    end.
    input stream instream close.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
                                          , input substitute("Записи &1-&2: сохранение/пересылка в СПН..."
                                          , (num-rec - num-rec modulo 100 + 1), num-rec)).
    find first buf_temp-cmd use-index pi.
    run after-command in p-parent-handle (buffer buf_temp-cmd) no-error.
    if error-status:error then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при сохранении/пересылке по СПН:&1&2&1&3"                                   , chr(10)                                   , error-status:get-message(1)                                   , return-value )).                      assign v-view-log = yes.
      undo _main, return error .
    end.
    run before-command in p-parent-handle (buffer buf_temp-cmd) no-error.
    if error-status:error then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при инициации сохранения/пересылки пакета по СПН:&1&2&1&3"                                   , chr(10)                                   , error-status:get-message(1)                                   , return-value )).                      assign v-view-log = yes.
    end.
    find first buf_temp-cmd use-index pi.
    p-cmd-code = buf_temp-cmd.cmd-code.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
  end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
  do
  on error undo, return error
  :
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-dis-tot-obj-code"
 no-error.
if available buf_rule-call-param then do:
assign p-dis-tot-obj-code = buf_rule-call-param.param-value-integer.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-issue-code"
 no-error.
if available buf_rule-call-param then do:
assign p-issue-code = buf_rule-call-param.param-value-integer.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-issue-date"
 no-error.
if available buf_rule-call-param then do:
assign p-issue-date = buf_rule-call-param.param-value-date.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-valid-date"
 no-error.
if available buf_rule-call-param then do:
assign p-valid-date = buf_rule-call-param.param-value-date.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-cli-grp-code"
 no-error.
if available buf_rule-call-param then do:
assign p-cli-grp-code = buf_rule-call-param.param-value-integer.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-lim-cr"
 no-error.
if available buf_rule-call-param then do:
assign p-lim-cr = buf_rule-call-param.param-value-decimal.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-category"
 no-error.
if available buf_rule-call-param then do:
assign p-category = buf_rule-call-param.param-value-integer.
end.
    case p-ruleset-id:
      when 1 then do:
        for each buf_cash-pay no-lock where
               buf_cash-pay.curr-code = 0
        by buf_cash-pay.cdpay-code:
           if buf_cash-pay.is-cash then do:
             leave.
           end.
        end.
        if not available buf_cash-pay then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найдено ни одного типа кассового платежа с валютой &1 и свойством <НАЛИЧНЫЕ>,&2" +
                                 "к которому можно привязать импортируемые суммы покупок по ДК"
                                 , 0
                                 , chr(10)
                                 )).
          assign
          v-view-log = yes.
          .
          return error.
        end.
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-date = p-doc-date
        file-name  = p-process-file-name
        .
        if NOT g#db-num = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Импорт клиентов и их дисконтных карт возможен только в ГБД")).
          assign
          v-view-log = yes.
          .
          return "return".
        end.
        run gbl/filename.p (
                        input  file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найден файл для импорта физ.лиц/ДК &1", file-name)).
          assign
          v-view-log = yes.
          .
          return "return".
        end.
        assign
        file-name = v-full-path.
        run gbl/filnline.p (
                      input file-name
                      ,output v-end-new-line).
        if v-end-new-line = no then do:
          output stream Instream to value(file-name) append.
          put stream instream unformatted skip(1).
          output stream Instream close.
        end.
      end.
    end case.
  end.
end procedure.
procedure 00040000_set-vpay-chk  :
define input parameter p-bh as handle no-undo .
define buffer buf_vchk-pay for vchk-pay.
find first buf_vchk-pay no-lock where
          buf_vchk-pay.d-card = p-bh:buffer-field("d-card"):buffer-value
      and buf_vchk-pay.pay-code = buf_cash-pay.cdpay-code
      and buf_vchk-pay.curr-code = 0
      and buf_vchk-pay.doc-date = v-current-date
      and buf_vchk-pay.cre-pay = no
      and buf_vchk-pay.exch-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
      and buf_vchk-pay.base-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
      no-error .
 if not available buf_vchk-pay then do:
   create buf_vchk-pay.
   assign
   buf_vchk-pay.d-card = p-bh:buffer-field("d-card"):buffer-value
   buf_vchk-pay.pay-code = buf_cash-pay.cdpay-code
   buf_vchk-pay.curr-code = 0
   buf_vchk-pay.doc-date = v-current-date
   buf_vchk-pay.cre-pay = no
   buf_vchk-pay.exch-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
   buf_vchk-pay.base-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
   .
 end.
 assign
 buf_vchk-pay.tot-sum = buf_vchk-pay.tot-sum + p-bh:buffer-field("pay-tot-rubl"):buffer-value
 buf_vchk-pay.tot-base = buf_vchk-pay.tot-base + p-bh:buffer-field("pay-tot-base"):buffer-value
 buf_vchk-pay.tot-rubl = buf_vchk-pay.tot-rubl + p-bh:buffer-field("pay-tot-rubl"):buffer-value
 .
end procedure.
procedure create_clients_:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer buf_temp-clients_ for temp-clients_.
find first buf_temp-clients_ where
          buf_temp-clients_.obj-type = p-obj-type
     and  buf_temp-clients_.obj-code = p-obj-code no-error .
if not available buf_temp-clients_ then do:
  create buf_temp-clients_.
  assign
  buf_temp-clients_.obj-type = p-obj-type
  buf_temp-clients_.obj-code = p-obj-code
  .
end.
end procedure.
procedure create_dis-card_:
define input parameter p-d-card as character no-undo .
define buffer buf_temp-dis-card_ for temp-dis-card_.
find first buf_temp-dis-card_ where
          buf_temp-dis-card_.d-card = p-d-card no-error .
if not available buf_temp-dis-card_ then do:
  create buf_temp-dis-card_.
  assign
  buf_temp-dis-card_.d-card = p-d-card
  .
end.
end procedure.
procedure can-find_clients_  :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-clients_ where
                     temp-clients_.obj-type = p-obj-type
                 and temp-clients_.obj-code = p-obj-code no-error.
p-find = available temp-clients_.
end procedure.
procedure can-find_dis-card_  :
define input parameter p-d-card as character no-undo .
define output parameter p-find as logical no-undo .
find first temp-dis-card_ where
                     temp-dis-card_.d-card = p-d-card no-error.
p-find = available temp-dis-card_.
end procedure.
procedure delete-procedure :
  do
  on error undo, return error
  :
      for each temp-clients_:
        delete temp-clients_.
      end.
      for each temp-dis-card_:
        delete temp-dis-card_.
      end.
      run garbcoll_clear in this-procedure .
  end.
end procedure.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table import-temp-d-card no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.
procedure 00040000_after-import :
define input  parameter p-d-card as character no-undo .
define variable v-ii as integer   no-undo .
define variable v-jj as integer   no-undo .
define variable v-codex-id as integer   no-undo .
define variable v-ruleset-id as integer   no-undo .
define variable v-ai-ruleset-id-list as character no-undo extent 4.
define variable v-ai-codex-id-list as character no-undo .
define variable v-proc-name as character no-undo .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_import-temp-d-card for import-temp-d-card.
define buffer buf_rule-by-call for ub.rule-by-call.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
      assign
      v-ai-codex-id-list = (if g#db-num = 0
                         then "1,2"
                         else '':U)
      v-ai-ruleset-id-list[1] = string(5)
      v-ai-ruleset-id-list[2] = "6,5"
      v-ai-ruleset-id-list[3] = ''
      .
      find first buf_temp-d-card where
               buf_temp-d-card.d-card = p-d-card no-error.
      if not available buf_temp-d-card then do:
        find first buf_Dis-card exclusive-lock where
                  buf_dis-card.d-card = p-d-card no-error.
        if not available  buf_dis-card then do:
          undo main-block, return error substitute("ДК &1 не найдена").
        end.
      end.
      create buf_import-temp-d-card.
      if available buf_temp-d-card then do:
        buffer-copy buf_temp-d-card to buf_import-temp-d-card.
      end.
      else do:
        buffer-copy buf_dis-card to buf_import-temp-d-card
        assign
        buf_import-temp-d-card.obj-type = p-obj-type
        buf_import-temp-d-card.obj-code = p-obj-code
        buf_import-temp-d-card.host-code = p-host-code
        .
      end.
      release buf_temp-d-card.
      _codex:
      do v-jj = 1 to num-entries(v-ai-codex-id-list):
        if entry(v-jj, v-ai-codex-id-list) = '':U then next _codex.
        v-codex-id = integer(entry(v-jj, v-ai-codex-id-list)).
        do v-ii = 1 to num-entries(v-ai-ruleset-id-list[v-jj]):
           if entry(v-ii, v-ai-ruleset-id-list[v-jj]) = '':U then next.
           v-ruleset-id = integer(entry(v-ii, v-ai-ruleset-id-list[v-jj])).
          _rule-by-call:
          for each buf_rule-by-call no-lock where
                    buf_rule-by-call.call_id = p-call-id
              and buf_rule-by-call.can-calc = yes
              and buf_rule-by-call.codex_id = v-codex-id
              and buf_rule-by-call.ruleset_id = v-ruleset-id
          by buf_rule-by-call.call_Id
          by buf_rule-by-call.codex_id
          by buf_rule-by-call.ruleset_id
          by buf_rule-by-call.order_id
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ) :
            if not (buf_rule-by-call.profile_id = p-profile-id
                    or
                    buf_rule-by-call.profile_id = 1
                    )
            then next _rule-by-call.
            v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
            run value(v-proc-name)  (
                                                           input parparentproc
                                                          ,input p-parent-handle
                                                          ,input p-log-handle
                                                          ,input p-cont-handle
                                                          ,input v-codex-id
                                                          ,input v-ruleset-id
                                                          ,input p-call-id
                                                          ,input buf_rule-by-call.order_id
                                                          ,input buf_rule-by-call.rule_id
                                                          ,input buf_rule-by-call.profile
                                                          ,input buf_rule-by-call.is_dynamic
                                                          ,input p-doc-type
                                                          ,input buf_import-temp-d-card.host-code
                                                          ,input buf_import-temp-d-card.obj-type
                                                          ,input buf_import-temp-d-card.obj-code
                                                          ,input p-doc-code
                                                          ,input p-process-file-name
                                                          ,input p-doc-date
                                                          ,input p-fact-date
                                                          ,input p-save
                                                          ,input v-curr-r-b
                                                          ,input p-cmd-proc-handle
                                                          ,input p-cmd-code
                                                          ,input p-type
                                                          ,input p-emitent-host-code
                                                          ,input table import-temp-d-card
                                                          ) no-error .
        if error-status:error then do:
          undo main-block, return error substitute("Ошибка при выполнении правила &1 ( профайл &2) для ДК &3&4&5&4&6"
                                                   ,buf_rule-by-call.rule_id
                                                   ,buf_rule-by-call.profile_id
                                                   ,p-d-card
                                                   ,chr(10)
                                                   ,error-status:get-message(1)
                                                   ,return-value ).
        end.
      end.
    end.
  end.
  find first buf_import-temp-d-card where buf_import-temp-d-card.d-card = p-d-card.
  delete buf_import-temp-d-card.
end.
end procedure.
