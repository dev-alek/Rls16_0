DEFINE BUFFER locked_dis-card FOR ub.dis-card.
DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.
DEFINE BUFFER X_prop-map FOR ub.prop-map.
DEFINE BUFFER X_prop-ref FOR ub.prop-ref.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter pard-card like ub.dis-card.d-card no-undo.
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-dis-card-property.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Свойства дисконтной карты ".
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
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
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
DEFINE NEW SHARED TEMP-TABLE cash-cli no-undo
FIELD cli-type          like ub.clients.obj-type
FIELD cli-code          like ub.clients.obj-code
FIELD cli-name          like ub.clients.obj-name
FIELD obj-name          like ub.clients.obj-name
FIELD cli-name2         like ub.person.name1
FIELD cli-name3         like ub.person.name2
FIELD cli-adr           like ub.firm.addres1
FIELD cli-adr2          like ub.firm.addres2
FIELD director          like ub.firm.director
FIELD e-mail            like ub.firm.e-mail
FIELD engl-name         like ub.firm.engl-name
FIELD is-pboul          like ub.firm.is-pboul
FIELD okonh             like ub.firm.okonh
FIELD okpo              like ub.firm.okpo
FIELD cli-city          like ub.firm.city
FIELD cli-ind           like ub.firm.ind
FIELD cli-inn           like ub.firm.inn
FIELD cli-phone         like ub.firm.phone
FIELD fax               like ub.firm.fax
FIELD telex             like ub.firm.telex
FIELD phone1-note       like ub.firm.phone1-note
FIELD post-addr1        like ub.firm.post-addr1
FIELD post-addr2        like ub.firm.post-addr2
FIELD position          like ub.firm.head-position
FIELD post-box          like ub.person.post-box
FIELD h-ka              as integer
FIELD kpp               like ub.person.kpp
FIELD justface          as integer
FIELD kat-pcnt          as integer
FIELD d-card            like ub.dis-card.d-card
FIELD lim-kr            like ub.clients.lim-kr
FIELD current-saldo     as decimal
FIELD current-saldo-rubl as decimal
FIELD current-saldo-base as decimal
FIELD d-pcnt            like ub.dis-card.d-pcnt
FIELD cash-d-pcnt       like ub.dis-card.cash-d-pcnt
FIELD d-pcnt-method     like ub.dis-card.d-pcnt-method
FIELD cli-status_       like ub.clients.stts
FIELD status_           as character
FIELD issue-code        like ub.dis-card.issue-code
FIELD issue-date        like ub.dis-card.issue-date
FIELD type              like ub.dis-card.type
FIELD emitent-host-code like ub.dis-card-type.emitent-host-code
FIELD d-pcnt-byshop     like ub.dis-card-type.d-pcnt-byshop
FIELD card-media        like ub.dis-card-type.card-media
FIELD credit-card       like ub.dis-card.credit-card
FIELD debet-card        like ub.dis-card.debet-card
FIELD staff-card        like ub.dis-card.staff-card
FIELD cli-message       like ub.dis-card.cli-message
FIELD fiscal-pay        like ub.dis-card-type.fiscal-pay
FIELD given-by          like ub.person.given-by
FIELD passport          as character
FIELD pay-code          like ub.dis-card-type.pay-code
FIELD mixed-pay         like ub.dis-card-type.mixed-pay
FIELD sourced-card      like ub.dis-card.sourced-card
FIELD mask-card         like ub.dis-card.mask-card
FIELD valid-date        as date initial 12/31/9999
FIELD property-value-chr as character extent 4
field dcr-pcnt            as integer
field dcr-abs             as integer
field dcr-pcnt-qnty       as integer
field dcr-pcnt-tot        as integer
field dcr-debet-pay       as integer
field dcr-credit-pay      as integer
field has-attrs           as logical
field has-attrs-lim       as logical
field ef-access-key       as character
field ef-format           as integer
FIELD crf as integer
FIELD rc as recid
index pi is unique primary crf
index icli cli-type cli-code
index idcard d-card
.
define NEW SHARED temp-table cash-cli-attr no-undo
field d-card             like ub.dis-card.d-card
field dc-petrol-code      as integer
field cdpay-code          as integer
field curr-code           as integer
field dc-car-brand        as character
field dc-car-reg-number   as character
field dc-limit-type       as character
field dc-limit            as decimal
field dc-limit-l          as decimal
field account-type        as integer
field dc-sum-id           as character
field dc-minnum           as decimal
field dc-maxnum           as decimal
field caller_id           as character
index pi is unique primary
d-card
dc-petrol-code
dc-sum-id
caller_id
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure disproph_write-dis-card-property-proc  :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-d-card      like ub.dis-card-property.d-card no-undo .
define input parameter p-dt-code      like ub.dis-card-property.dt-code no-undo .
define input parameter p-host-code   like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type    like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code    like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code    like ub.dis-card-property.dtm-code no-undo .
define input parameter p-card-num    like ub.dis-card-property.card-num  no-undo .
define input parameter p-main-card   like ub.dis-card-property.main-card  no-undo .
define input parameter p-first-card  like ub.dis-card-property.first-card  no-undo .
define input parameter p-first-main-card  like ub.dis-card-property.first-main-card  no-undo .
define input parameter p-node-code   like ub.dis-card-property.node-code no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define variable v-send as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not available buf_dis-card-property and not p-action = integer('1':U) then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена запись СВОЙСТВА ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
  v-send = integer('0':U).
  if not p-action = integer('1':U) then do:
    if available buf_dis-card then do:
      if g#news then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      end.
      else do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-from-prim'
  ,output v-send
  ) no-error .
      end.
    end.
  end.
  if v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    if p-action = integer('1':U) then do:
      create buf_c-dis-card-property.
      assign
      buf_c-dis-card-property.d-card            = p-d-card
      buf_c-dis-card-property.card-num          = p-card-num
      buf_c-dis-card-property.host-code         = p-host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.dt-code           = p-dt-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.main-card         = p-main-card
      buf_c-dis-card-property.first-main-card   = p-first-main-card
      buf_c-dis-card-property.first-card        = p-first-card
      buf_c-dis-card-property.chip-num          = (if p-chip-num = 0
                                                   then next-value (s-dc-chip, ub)
                                                   else p-chip-num)
      buf_c-dis-card-property.corr-time         = (if p-corr-time = ?
                                                   then v-time
                                                   else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num  = g#db-num
      buf_c-dis-card-property.corr-user-name    = if g#news then (chr(4) +  'СПН':U) else g#userid
      buf_c-dis-card-property.corr-date         = (if p-corr-date = ?
                                                   then v-date
                                                   else p-corr-date)
      .
    end.
    else do:
      create buf_c-dis-card-property.
      buffer-copy buf_dis-card-property to buf_c-dis-card-property
      assign
      buf_c-dis-card-property.d-card             = buf_dis-card-property.d-card
      buf_c-dis-card-property.card-num           = buf_dis-card-property.card-num
      buf_c-dis-card-property.dt-code             = buf_dis-card-property.dt-code
      buf_c-dis-card-property.main-card          = buf_dis-card-property.main-card
      buf_c-dis-card-property.first-main-card    = buf_dis-card-property.first-main-card
      buf_c-dis-card-property.first-card         = buf_dis-card-property.first-card
      buf_c-dis-card-property.host-code          = buf_dis-card-property.host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.chip-num           = (if p-chip-num = 0
                                                    then next-value (s-dc-chip, ub)
                                                    else p-chip-num)
      buf_c-dis-card-property.corr-time          = (if p-corr-time = ?
                                                    then v-time
                                                    else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num   = g#db-num
            buf_c-dis-card-property.corr-user-name    = (if g#news
                                                   then (chr(4) +  'СПН':U)
                                                   else (if g#esys
                                                         then (chr(4) +  'ВС':U)
                                                         else g#userid
                                                         )
                                                   )
      buf_c-dis-card-property.corr-date          = (if p-corr-date = ?
                                                    then v-date
                                                    else p-corr-date)
      .
      run gen-key-rec in this-procedure (
                                          input 'dis-card-property':U
                                        ,input buffer buf_dis-card-property:handle
                                        ,output v-uniq-key-rec).
    end.
    if p-chip-num = 0   then do:
      create buf_c-dc-hist.
      buffer-copy buf_c-dis-card-property to buf_c-dc-hist
      assign
      buf_c-dc-hist.action =  p-action
      buf_c-dc-hist.subject = 'dis-card-property':U
      buf_c-dc-hist.is-news = g#news
      buf_c-dc-hist.source-type = p-source-type
      buf_c-dc-hist.source-ref = p-source-ref
      buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
      .
    end.
    assign
    p-chip-num = buf_c-dis-card-property.chip-num
    p-corr-date = buf_c-dis-card-property.corr-date
    p-corr-time = buf_c-dis-card-property.corr-time
    .
    run disproph_send-nws in this-procedure (
                                              buffer buf_c-dis-card-property
                                             ,buffer buf_c-dc-hist
                                             ,buffer buf_dis-card
                                              ).
    end.
  end.
end procedure.
procedure disproph_send-nws :
define parameter buffer buf_c-dis-card-property for ub.c-dis-card-property.
define parameter buffer buf_c-dc-hist for ub.c-dc-hist.
define parameter buffer buf_Dis-card for ub.dis-card.
define variable v-dh-hn as integer no-undo .
main-block:
do
on error undo, return error return-value
:
  if g#news
  and g#db-num > 0
  and buf_c-dis-card-property.corr-user-db-num <> g#db-num
  then return.
  if g#db-num = 0
  or (g#news
      and g#db-num > 0
      and buf_c-dis-card-property.corr-user-name = (chr(4) +  'СПН':U)
      )
  then do:
    if not available buf_dis-card then do:
      find first buf_dis-card no-lock where
                buf_Dis-card.d-card = buf_c-dis-card-property.d-card no-error.
    end.
    if not available buf_dis-card then do:
      assign
      v-dh-hn = integer('0':U).
    end.
    else do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_c-dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-to-nws'
  ,output v-dh-hn
  ) no-error .
    end.
    if v-dh-hn >= 0 then do:
      run str/callnews.p (
        input 'c-dis-card-property':U
        ,input (buffer buf_c-dis-card-property:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
      end.
      if available buf_c-dc-hist then do:
        run str/callnews.p (
          input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
        end.
      end.
    end.
  end.
end.
end procedure.
procedure discprop-node-code :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-format as character no-undo .
define output parameter p-label as character no-undo .
define output parameter p-range as integer no-undo .
define output parameter p-rw-option as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code no-error .
if available buf_prop-head then do:
  if p-node-code > 0 then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = p-dtm-code
          and buf_prop-map.node-code = p-node-code no-error .
    if available buf_prop-map then do:
      assign
      p-data-type = buf_prop-map.node-value-type
      p-format = buf_prop-map.node-format
      p-label = buf_prop-map.node-label
      p-rw-option = buf_prop-map.rw-option
      .
    end.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  12.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  3.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  2.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  1.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  = "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  0.
  end.
end.
end.
end procedure.
procedure discprop-initial:
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-init-value-character as character no-undo .
define output parameter p-init-value-date as date no-undo .
define output parameter p-init-value-decimal as decimal no-undo .
define output parameter p-init-value-integer as integer no-undo .
define output parameter p-init-value-logical as logical no-undo .
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-map no-lock where
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code = p-node-code no-error.
if not available buf_prop-map then return error substitute("Не найдено свойство &1 для объекта &2"
                                                            , p-node-code
                                                            , p-dtm-code).
assign
p-init-value-character = buf_prop-map.init-value-character
p-init-value-date = buf_prop-map.init-value-date
p-init-value-decimal = buf_prop-map.init-value-decimal
p-init-value-integer = buf_prop-map.init-value-integer
p-init-value-logical = buf_prop-map.init-value-logical
.
end procedure.
Function discprop-usercanedit returns logical (  input p-dtm-code as integer, input p-db-num as integer):
define buffer buf_attr-prop for ub.attr-prop.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
      and buf_attr-prop.templ-rl-root = p-dtm-code
      and buf_attr-prop.upper-prop-code = "UserCanEdit"
      and buf_attr-prop.prop-code = (if p-db-num = 0 then 'DB0' else 'DBR':U) no-error.
if not available buf_attr-prop
or logical(buf_attr-prop.property-value) = no then do:
  return no.
end.
return yes.
end function.
procedure discprop-edit :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-edit-menu-section-num as integer no-undo .
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
     and  buf_attr-prop.templ-rl-root = integer(entry(1, p-dtm-code-node-name, chr(4)))
     and  buf_attr-prop.upper-prop-code = "ManualEdit":U
     and  buf_attr-prop.prop-code = "SectionNum":U no-error .
  if available buf_attr-prop then do:
    assign
    p-edit-menu-section-num = integer(buf_attr-prop.property-value).
  end.
end.
end procedure.
procedure discprop-node-name :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-tool-tip as character no-undo .
define output parameter p-node-label as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) )) no-error .
  assign
  p-tool-tip   = if available buf_prop-head
                 then buf_prop-head.prop-des
                 else entry(1, p-dtm-code-node-name, chr(4) )
  p-node-label = (if available buf_prop-head
                  then buf_prop-head.prop-label
                  else '':U)
  .
  if entry(2, p-dtm-code-node-name, chr(4) ) <> "" then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) ))
        and  buf_prop-map.node-code = integer(entry(2, p-dtm-code-node-name, chr(4) )) no-error.
    if available buf_prop-map then do:
      assign
      p-tool-tip   = buf_prop-map.node-description
      p-node-label = (if available buf_prop-head
                      then buf_prop-head.prop-label
                      else '':U) + ":" + buf_prop-map.node-label
      .
    end.
  end.
end.
end procedure.
procedure discprop-write :
define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code        like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code         like ub.dis-card-property.dt-code    no-undo .
define input parameter p-sum-id          like ub.dis-card-property.sum-id     no-undo .
define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
define input parameter p-source-type     as character no-undo .
define input parameter p-source-ref      as character no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  define buffer buf_dis-card-property for ub.dis-card-property .
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_prop-ref for ub.prop-ref.
  define variable v-data-type      as character no-undo .
  define variable v-data-type-1    as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-rw-option      as character no-undo .
  run discprop-node-code in this-procedure
    (
     input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  v-data-type-1 = entry(1, v-data-type).
  if p-dt-code = ? then do:
    find buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = p-dtm-code
    and buf_prop-ref.sum-id = p-sum-id no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Неопределен или неоднозначен ИТОГ/СРЕЗ для объекта-операнда &1 &2"
                                    ,p-dtm-code
                                    ,p-sum-id).
    end.
    assign
    p-dt-code = buf_prop-ref.dt-code.
  end.
  if discprop-usercanedit ( input p-dtm-code, input g#db-num)  = no then do:
    undo, return error "Нельзя редактировать свойство в данной БД".
  end.
  run discprop-check in this-procedure (
                                          input v-range
                                        ,input p-d-card
                                        ,input p-host-code
                                        ,input p-obj-type
                                        ,input p-obj-code
                                        ,input p-dtm-code
                                        ,input p-node-code
                                        ,input p-dt-code
                                      ) no-error .
  if error-status:error then undo,  return error return-value .
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error .
    find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card.
  if not available buf_dis-card-property then do:
    create buf_dis-card-property .
    assign
      buf_dis-card-property.d-card    = p-d-card
      buf_dis-card-property.host-code = p-host-code
      buf_dis-card-property.obj-type  = p-obj-type
      buf_dis-card-property.obj-code  = p-obj-code
      buf_dis-card-property.dt-code = p-dt-code
      buf_dis-card-property.node-code = p-node-code
      buf_dis-card-property.dtm-code = p-dtm-code
      buf_dis-card-property.sum-id   = p-sum-id
      buf_dis-card-property.card-num  = buf_dis-card.card-num
      buf_dis-card-property.main-card  = buf_dis-card.main-card
      buf_dis-card-property.first-card  = buf_dis-card.first-card
      buf_dis-card-property.first-main-card  = buf_dis-card.first-main-card
    .
  end.
  else do:
    if (v-data-type-1 = 'character':U
    and buf_dis-card-property.property-value-character = p-value-character)
    or  (v-data-type-1 = 'date':U
        and buf_dis-card-property.property-value-date = p-value-date)
    or  (v-data-type-1 = 'decimal':U
        and buf_dis-card-property.property-value-decimal = p-value-decimal)
    or  (v-data-type-1 = 'integer':U
        and buf_dis-card-property.property-value-integer = p-value-integer)
    or  (v-data-type-1 = 'logical':U
        and buf_dis-card-property.property-value-logical = p-value-logical)
    then return.
  end.
  run disproph_write-dis-card-property-proc  in this-procedure (
          buffer buf_dis-card-property
          ,buffer Buf_dis-card
          ,input p-d-card
          ,input p-dt-code
          ,input p-host-code
          ,input p-obj-type
          ,input p-obj-code
          ,input p-dtm-code
          ,input buf_dis-card.card-num
          ,input buf_dis-card.main-card
          ,input buf_dis-card.first-card
          ,input buf_dis-card.first-main-card
          ,input p-node-code
          ,input (if new(buf_dis-card-property) then integer('1':U) else integer('2':U))
          ,input p-source-type
          ,input p-source-ref
          ,input-output p-chip-num
          ,input-output p-corr-date
          ,input-output p-corr-time
          ).
  assign
  buf_dis-card-property.property-value-character = (if v-data-type-1 = 'character':U
                                                    then p-value-character
                                                    else buf_dis-card-property.property-value-character)
  buf_dis-card-property.property-value-date      = (if v-data-type-1 = 'date':U
                                                    then p-value-date
                                                    else buf_dis-card-property.property-value-date)
  buf_dis-card-property.property-value-decimal   = (if v-data-type-1 = 'decimal':U
                                                    then p-value-decimal
                                                    else buf_dis-card-property.property-value-decimal)
  buf_dis-card-property.property-value-integer   = (if v-data-type-1 = 'integer':U
                                                    then p-value-integer
                                                    else buf_dis-card-property.property-value-integer)
  buf_dis-card-property.property-value-logical   = (if v-data-type-1 = 'logical':U
                                                    then p-value-logical
                                                    else buf_dis-card-property.property-value-logical)
  buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U)
  .
  release buf_dis-card-property no-error .
  if error-status:error then do:
    return error return-value .
  end.
end.
end procedure.
procedure discprop-delete :
define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define output parameter p-deleted  as logical no-undo.
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define buffer buf_dis-card-property for ub.dis-card-property .
define buffer buf_dis-card for ub.dis-card.
define variable v-data-type      as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-range          as integer   no-undo .
define variable v-rw-option      as character   no-undo .
  run discprop-node-code in this-procedure
    (input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error NO-WAIT.
  if not available buf_dis-card-property then do:
    p-deleted = no.
  end.
  else do:
    run disproph_write-dis-card-property-proc  in this-procedure (
         buffer buf_dis-card-property
        ,buffer buf_dis-card
        ,input buf_dis-card-property.d-card
        ,input buf_dis-card-property.dt-code
        ,input buf_dis-card-property.host-code
        ,input buf_dis-card-property.obj-type
        ,input buf_dis-card-property.obj-code
        ,input buf_dis-card-property.dtm-code
        ,input buf_dis-card-property.card-num
        ,input buf_dis-card-property.main-card
        ,input buf_dis-card-property.first-card
        ,input buf_dis-card-property.first-main-card
        ,input buf_dis-card-property.node-code
        ,input integer('99':U)
        ,input p-source-type
        ,input p-source-ref
        ,input-output p-chip-num
        ,input-output p-corr-date
        ,input-output p-corr-time
         ).
    buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U).
    delete buf_dis-card-property no-error .
    if error-status:error then do:
      return error return-value.
    end.
    p-deleted = yes.
  end.
end.
end procedure.
procedure discprop-check :
define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .
define variable v-message as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  if p-host-code > 0 then do:
    FIND FIRST buf_sysconf No-LOCK WHERE
              buf_sysconf.host-code = p-host-code No-ERROR.
    IF NOT AVAIL buf_sysconf THEN DO:
      v-message = substitute("Не найдена фирма &1", p-host-code).
      RETURN ERROR v-message.
    END.
  end.
  if p-obj-type <> "":U or
      p-obj-code <> 0 then do:
    find first buf_clients No-LOCK WHERE
              buf_clients.obj-type = p-obj-type AND
              buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      v-message = substitute("Не найден объект &1&2", p-obj-type, p-obj-code).
      RETURN ERROR v-message.
    end.
  end.
  else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
    v-message = substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                            , p-obj-type
                            , p-obj-code
                            , p-host-code).
    RETURN ERROR v-message.
  end.
  if p-d-card <> "":U then do:
    find first buf_dis-card No-LOCK WHERE
                buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
      v-message =substitute("Не найдена ДК").
      return error  v-message.
    end.
    if buf_dis-card.emitent-host-code <> 0
    and p-host-code <> buf_dis-card.emitent-host-code then do:
      v-message = substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту").
      return error v-message.
    end.
    if buf_dis-card.emitent-host-code = 0
    and p-range = 1
    and p-host-code <> 0 then do:
      v-message = substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                            "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                              , chr(10)
                            ).
      return error v-message.
    end.
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table dc-list no-undo like ub.dis-card
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list-hist no-undo
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new SHARED temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-attr-property  no-undo
field upper-attr-code as character
field attr-code as character
field table-name as character
field edit-menu-section-num as integer
field attr-label as character
field menu-item-handle as widget-handle
field user-can-edit as logical
field menu-name as character
field parent-handle as handle
index pi is unique primary
table-name
menu-name
upper-attr-code
attr-code
index i-section
edit-menu-section-num
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure attr-pop-create-items :
define input parameter p-table-name as character no-undo .
define input parameter p-get-section-num-proc-name as character no-undo .
define input parameter p-get-attr-label-proc-name as character no-undo .
define input parameter p-attr-choose-proc-name as character no-undo .
define input parameter p-menu-handle as widget-handle no-undo .
define input parameter p-attr-list as character no-undo .
define variable ii as integer no-undo .
define variable V-CREATED as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-dop as character no-undo .
define variable v-attr-item as character no-undo .
define variable p-upper-attr-code as character no-undo .
define buffer buf_tt-attr-property for tt-attr-property.
  do
  on error undo, return error return-value
  :
     do ii = 1 to num-entries (p-attr-list):
       v-attr-item = entry(ii, p-attr-list) .
       find first tt-attr-property where
                 tt-attr-property.table-name = p-table-name
             and tt-attr-property.attr-code = v-attr-item
             and tt-attr-property.upper-attr-code = p-upper-attr-code
             and tt-attr-property.menu-name = p-menu-handle:name  no-error .
       if not available tt-attr-property then do:
         create tt-attr-property.
         assign
         tt-attr-property.table-name = p-table-name
         tt-attr-property.attr-code = v-attr-item
         tt-attr-property.upper-attr-code = p-upper-attr-code
         tt-attr-property.menu-name = p-menu-handle:name
         .
         run value ( p-get-section-num-proc-name) (
                                                   input tt-attr-property.attr-code
                                                  ,output tt-attr-property.edit-menu-section-num ) no-error .
         run value ( p-get-attr-label-proc-name ) (
                                        input tt-attr-property.attr-code
                                       ,output v-tool-tip
                                       ,output tt-attr-property.attr-label
                                      ) no-error .
         release tt-attr-property.
       end.
     end.
     for each tt-attr-property where tt-attr-property.menu-name = p-menu-handle:name
     break
     by  tt-attr-property.edit-menu-section-num
     by  tt-attr-property.attr-label
     :
       if tt-attr-property.edit-menu-section-num > 0
       then do:
          if not valid-handle(tt-attr-property.menu-item-handle) then do:
            if num-entries(tt-attr-property.attr-code, chr(4)) > 1
            and entry(2, tt-attr-property.attr-code, chr(4)) <> '':U
            then do:
              find first buf_tt-attr-property where
                        buf_tt-attr-property.table-name = p-table-name
                    and buf_tt-attr-property.menu-name = p-menu-handle:name
                    and buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                    and buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4)) no-error .
              if not available buf_tt-attr-property then do:
                create buf_tt-attr-property.
                assign
                buf_tt-attr-property.table-name = p-table-name
                buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4))
                buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                buf_tt-attr-property.menu-name = p-menu-handle:name
                .
                create sub-menu buf_tt-attr-property.menu-item-handle
                assign
                name = entry(1, tt-attr-property.attr-code, chr(4))  + chr(4)  + p-menu-handle:name
                parent = p-menu-handle.
              end.
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = tt-attr-property.attr-code  + chr(4)  + p-menu-handle:name
              parent = buf_tt-attr-property.menu-item-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name + "-2") (
                                                                         input  entry(1, tt-attr-property.attr-code, chr(4) )
                                                                        ,input entry(2, tt-attr-property.attr-code, chr(4) )
                                                                          ) .
              end triggers.
              assign
              v-created = yes.
            end.
            else do:
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = entry(1, tt-attr-property.attr-code, chr(4)) + chr(4)  + p-menu-handle:name
              parent = p-menu-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name) (
                                                                 input  entry(1, tt-attr-property.attr-code, chr(4) )) .
              end triggers.
              assign
              v-created = yes.
            end.
          end.
          if last-of(tt-attr-property.edit-menu-section-num)
            then do:
            find first buf_tt-attr-property where
                      buf_tt-attr-property.table-name = p-table-name
                 and  buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                         , p-table-name
                                                         , tt-attr-property.edit-menu-section-num
                                                         , p-menu-handle:name
                                                         )
                  and buf_tt-attr-property.menu-name = p-menu-handle:name  no-error .
            if not available buf_tt-attr-property then do:
              create buf_tt-attr-property.
              assign
              buf_tt-attr-property.table-name = p-table-name
              buf_tt-attr-property.edit-menu-section-num =  - 1
              buf_tt-attr-property.menu-name = p-menu-handle:name
              buf_tt-attr-property.upper-attr-code = ''
              buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                          , p-table-name
                                                          , tt-attr-property.edit-menu-section-num
                                                          , p-menu-handle:name
                                                          )
              .
              create menu-item buf_tt-attr-property.menu-item-handle
              assign
              subtype = "rule"
              parent = p-menu-handle
              .
            end.
          end.
       end.
     end.
     if not v-created then do:
        run attr-pop-clean-up in this-procedure ( input p-table-name).
     end.
  end.
end procedure.
procedure attr-pop-clean-up :
define input parameter p-table-name as character no-undo .
  for each tt-attr-property where
          tt-attr-property.table-name = p-table-name
    and tt-attr-property.edit-menu-section-num > 0:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
  for each tt-attr-property where
           tt-attr-property.table-name = p-table-name
       and tt-attr-property.edit-menu-section-num =  - 1:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE ub.dis-card-property
field rw-option as character
field prop-label as character
field node-label as character
field data-type as character
field range as integer
INDEX attrc is
UNIQUE PRIMARY
prop-label
node-label
dt-code
host-code
obj-type
obj-code
INDEX attrcl is UNIQUE
dt-code
node-code
host-code
obj-type
obj-code
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION proprefd_sum-id-des RETURNS CHARACTER
  ( INPUT p-sum-id AS CHARACTER, INPUT p-ref-type AS CHARACTER ) :
CASE p-ref-type:
    WHEN 'one-ptrl':U THEN DO:
       DEFINE BUFFER buf_goods FOR ub.goods.
       FIND FIRST buf_goods NO-LOCK WHERE
                 buf_goods.gds-code = integer(ENTRY(2, p-sum-id, "-")) NO-ERROR.
       IF NOT AVAILABLE buf_goods  THEN DO:
           RETURN "Неизвестное топливо".
       END.
       RETURN buf_goods.gds-name.
    END.
    OTHERWISE DO:
       RETURN "".
    END.
END CASE.
END FUNCTION.
FUNCTION proprefd_sum-id-des2 RETURNS CHARACTER
  ( INPUT p-sum-id AS CHARACTER, INPUT p-ref-type AS CHARACTER ) :
CASE p-ref-type:
    WHEN 'one-ptrl':U THEN DO:
       DEFINE BUFFER buf_goods FOR ub.goods.
       FIND FIRST buf_goods NO-LOCK WHERE
                 buf_goods.gds-code = integer(ENTRY(2, p-sum-id, "-")) NO-ERROR.
       IF NOT AVAILABLE buf_goods  THEN DO:
           RETURN "Неизвестное топливо".
       END.
       RETURN buf_goods.gds-name.
    END.
    OTHERWISE DO:
       RETURN p-sum-id.
    END.
END CASE.
END FUNCTION.
DEFINE VARIABLE v-ch AS WIDGET-HANDLE NO-UNDO EXTENT 5.
define variable updated as logical no-undo.
define variable dtm-node-option as character no-undo.
define variable dtm-option as integer no-undo.
define variable node-code-option as integer no-undo .
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-obj-type like ub.clients.obj-type no-undo.
define variable v-obj-code like ub.clients.obj-code no-undo.
define variable v-card-num like ub.dis-card.card-num no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE MENU MENU-b-ins .
FUNCTION display-character RETURNS CHARACTER
  ( INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER)  FORWARD.
FUNCTION get-prop-value RETURNS CHARACTER
     ( INPUT p-data-type AS CHARACTER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
 )  FORWARD.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить свойство ДК".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить свойство ДК".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-hist
     LABEL "Btn 2"
     SIZE 3 BY 1.
DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить свойство ДК".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр свойства ДК".
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE v-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Держатель карты"
      VIEW-AS TEXT
     SIZE 41.5 BY .67
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE v-first-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Первая карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE v-first-main-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Первая основная карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE v-main-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Основная карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE vard-card AS CHARACTER FORMAT "X(16)":U
     LABEL "Дисконтная карта"
      VIEW-AS TEXT
     SIZE 20.63 BY .67
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE rs-view AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Только по своему объекту/фирме/глобально", 0,
"Все", 1
     SIZE 49 BY 1 NO-UNDO.
DEFINE QUERY br-prop FOR
      temp-dis-card-property,
      X_prop-map,
      X_prop-ref SCROLLING.
DEFINE BROWSE br-prop
  QUERY br-prop DISPLAY
      substitute("&1:&2", temp-dis-card-property.prop-label, temp-dis-card-property.node-label) COLUMN-LABEL "Свойство" FORMAT "X(60)" WIDTH 25
proprefd_sum-id-des2(temp-dis-card-property.sum-id, X_prop-ref.ref-type) COLUMN-LABEL "Идентификатор/!Описание" FORMAT "X(255)" WIDTH 15
get-region( temp-dis-card-property.host-code, temp-dis-card-property.obj-type, temp-dis-card-property.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
get-prop-value( X_prop-map.node-value-type
               ,temp-dis-card-property.property-value-character
                ,temp-dis-card-property.property-value-date
                ,temp-dis-card-property.property-value-decimal
                ,temp-dis-card-property.property-value-integer
                ,temp-dis-card-property.property-value-logical) COLUMN-LABEL "Значение" FORMAT "X(255)"
          WIDTH 45
substitute("&1:&2", temp-dis-card-property.dtm-code, temp-dis-card-property.node-code) COLUMN-LABEL "Объект!-операнд:!свойство"
temp-dis-card-property.dt-code COLUMN-LABEL "Код среза"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15
         FONT 4.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-ins AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     b-chg AT ROW 1 COL 51
     b-del AT ROW 1 COL 61
     b-hist AT ROW 1 COL 92 WIDGET-ID 10
     b-help AT ROW 1 COL 95
     rs-view AT ROW 4 COL 12 NO-LABEL WIDGET-ID 12
     br-prop AT ROW 5 COL 1
     vard-card AT ROW 2 COL 18.5 COLON-ALIGNED
     v-first-main-card AT ROW 2 COL 75.5 COLON-ALIGNED WIDGET-ID 4
     v-cli-name AT ROW 3 COL 18.5 COLON-ALIGNED WIDGET-ID 2
     v-first-card AT ROW 3 COL 75.5 COLON-ALIGNED WIDGET-ID 6
     v-main-card AT ROW 4 COL 75.5 COLON-ALIGNED WIDGET-ID 8
     "Показывать:" VIEW-AS TEXT
          SIZE 10.5 BY 1 AT ROW 4 COL 1 WIDGET-ID 16
     SPACE(87.50) SKIP(15.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Свойства дисконтной карты"
         CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error .
  if error-status:error then return no-apply.
  run Openbr in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .
define variable glog as logical no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer   no-undo .
define variable v-num as integer   no-undo .
define buffer buf_attr-prop for ub.attr-prop.
define buffer buf_temp-dis-card-property for temp-dis-card-property.
if not avail temp-dis-card-property then return no-apply.
run discprop-node-code in this-procedure (
                                     input  temp-dis-card-property.dtm-code
                                    ,input  temp-dis-card-property.node-code
                                    ,output v-data-type
                                    ,output v-format
                                    ,output v-label
                                    ,output v-range
                                    ,output v-rw-option
                                    ).
if index(v-rw-option, "W") = 0
then do:
    message
    "Свойство нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
end.
  if discprop-usercanedit( input temp-dis-card-property.dtm-code, input v-cntxt-db-num) = no then do:
    message
    "Свойство нельзя удалить в данной БД"
    view-as alert-box error .
    return no-apply.
  end.
  glog = no.
run gbl/d-askw.w (
  input "Удаление свойства ДК"
,input substitute("Вы уверены, что хотите удалить свойство &1 (срез &2) для дисконтной карты &3"
              ,temp-dis-card-property.prop-label
              ,temp-dis-card-property.sum-id
              ,vard-card
           )
,input "|^"
,input substitute("Полностью^confirm|Элемент&1|Отказ"
                  ,(if index(v-rw-option, "O") > 0
                    then ""
                    else "^disable"))
,input "Все элементы свойства|"
      + v-label + "|"
      + "Отказ "
,input 2
,input 3
,output v-num
).
if v-num = 3 then do:
  return no-apply.
end.
  assign
  v-dtm-code =  temp-dis-card-property.dtm-code
  v-host-code = temp-dis-card-property.host-code
  v-obj-type = temp-dis-card-property.obj-type
  v-obj-code = temp-dis-card-property.obj-code
  v-dt-code = temp-dis-card-property.dt-code
v-node-code = temp-dis-card-property.node-code
  .
  for each buf_temp-dis-card-property where
          buf_temp-dis-card-property.dtm-code = v-dtm-code
      and buf_temp-dis-card-property.host-code = v-host-code
      and buf_temp-dis-card-property.obj-type = v-obj-type
      and buf_temp-dis-card-property.obj-code = v-obj-code
      and buf_temp-dis-card-property.dt-code = v-dt-code
  :
  if v-num = 2 and buf_temp-dis-card-property.node-code <> v-node-code then next.
   delete buf_temp-dis-card-property.
  end.
  updated = yes.
run Openbr in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
 IF NOT AVAILABLE temp-dis-card-property THEN RETURN NO-APPLY.
run ref/cdchist.w (
                INPUT parparentproc
                ,input p-host-code
                ,input p-obj-type
                ,input p-obj-code
                ,input "":U
                ,input "subject":U
                ,input temp-dis-card-property.d-card
                ,input ?
                ,input temp-dis-card-property.obj-type
                ,input temp-dis-card-property.obj-code
                ,input temp-dis-card-property.host-code
                ,input ?
                ,input "":U
                ,input 'dis-card-property':U
                ,input ?
                ,input-output v-ref-list
            ) no-error .
  APPLY "entry" TO br-prop.
END.
ON CHOOSE OF b-ins IN FRAME Dialog-Frame
DO:
define buffer buf_temp-dis-card-property for temp-dis-card-property.
if dtm-node-option = '':U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if dtm-node-option = '':U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  assign
  dtm-node-option = ''
  dtm-option = 0
  node-code-option = 0
  .
  return no-apply.
end.
Run Openbr in this-procedure .
find first buf_temp-dis-card-property no-lock where
           buf_temp-dis-card-property.dtm-code = dtm-option
       and buf_temp-dis-card-property.node-code = node-code-option
       and buf_temp-dis-card-property.host-code = v-host-code
      and buf_temp-dis-card-property.obj-type = v-obj-type
      and buf_temp-dis-card-property.obj-code = v-obj-code
                  no-error.
assign
dtm-node-option = '':U
dtm-option = 0
node-code-option = 0
.
if avail buf_temp-dis-card-property then
    temp-doc-rec = recid(buf_temp-dis-card-property).
    else temp-doc-rec = ?.
reposition br-prop to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON MOUSE-SELECT-DBLCLICK OF br-prop IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF br-prop IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF br-prop IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_attr-prop FOR ub.attr-prop.
  IF NOT AVAILABLE temp-dis-card-property THEN do:
     DISABLE
     b-lkp
     WITH frame Dialog-Frame.
     RETURN NO-APPLY.
  END.
  FIND FIRST buf_attr-prop NO-LOCK WHERE
            buf_attr-prop.TABLE-name = 'dis-card-property':U
       AND buf_attr-prop.templ-rl-root  = temp-dis-card-property.dtm-code
      AND buf_attr-prop.upper-prop-code = "InputForm":U
      AND buf_attr-prop.prop-code = "FormName" no-error.
  IF AVAILABLE buf_attr-prop THEN DO:
     ENABLE
     b-lkp
     WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    DISABLE
    b-lkp
    WITH frame Dialog-Frame.
  END.
  if p-mode <> 'ПРОСМОТР':U then do:
    enable
    b-del
    with frame Dialog-Frame .
    if g#db-num  > 0
    and (temp-dis-card-property.obj-type = ''
    or temp-dis-card-property.obj-code =0
    or temp-dis-card-property.host-code = 0) then do:
      disable
      b-del
      with frame Dialog-Frame .
    end.
  end.
END.
ON VALUE-CHANGED OF rs-view IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-view.
  RUN Openbr IN THIS-PROCEDURE.
END.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-prop :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-prop :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
 frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
ON ROW-DISPLAY OF br-prop IN frame Dialog-Frame
DO:
  IF AVAIL temp-dis-card-property THEN DO:
  END.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if NOT (p-mode = 'ПРОСМОТР':U
        or p-mode = 'ИЗМЕНЕНИЕ':U
        or p-mode = 'ДОБАВЛЕНИЕ':U
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode"
    view-as alert-box ERROR.
    return error.
  end.
  find first locked_dis-card no-lock where
              locked_dis-card.d-card = pard-card No-ERROR.
  IF NOT avail locked_dis-card  and p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена дисконтная карта" pard-card
    view-as alert-box.
    return error.
  END .
  IF AVAIL locked_dis-card THEN
  DO:
      assign
      v-card-num = locked_dis-card.card-num
      .
  END.
  IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
      FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = LOCKED_dis-card.cli-type
          AND    buf_clients.obj-code = LOCKED_dis-card.cli-code.
  END.
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = p-host-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова p-host-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = p-obj-type AND
                ub.clients.obj-code = p-obj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
         "Неверный параметр вызова p-obj-type/p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error.
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  OPEN QUERY br-prop FOR EACH temp-dis-card-property,            FIRST X_prop-map NO-LOCK WHERE         X_prop-map.dtm-code = temp-dis-card-property.dtm-code     AND X_prop-map.node-code = temp-dis-card-property.node-code,           FIRST X_prop-ref  NO-LOCK outer-join WHERE         X_prop-ref.dt-code = temp-dis-card-property.dt-code by temp-dis-card-property.dtm-code by temp-dis-card-property.dt-code by temp-dis-card-property.node-code      INDEXED-REPOSITION.
  APPLY "ENTRY" TO br-prop in frame Dialog-Frame .
  APPLY "VALUE-CHANGED" TO br-prop in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input 'dis-card-property':U ).
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE choose-to-edit :
define input parameter p-dtm-code as integer no-undo .
assign
dtm-node-option = string(p-dtm-code) + chr(4) + string(0)
dtm-option = p-dtm-code
.
APPLY "CHOOSE" to b-ins in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE choose-to-edit-2 :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code-option as integer no-undo .
assign
dtm-node-option = string(p-dtm-code) + chr(4) + string(p-node-code-option)
.
APPLY "CHOOSE" to b-ins in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-view vard-card v-first-main-card v-cli-name v-first-card
          v-main-card
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit b-ins b-lkp b-chg b-del b-hist b-help rs-view br-prop
         vard-card v-first-main-card v-cli-name v-first-card v-main-card
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-prop FOR EACH temp-dis-card-property,            FIRST X_prop-map NO-LOCK WHERE         X_prop-map.dtm-code = temp-dis-card-property.dtm-code     AND X_prop-map.node-code = temp-dis-card-property.node-code,           FIRST X_prop-ref  NO-LOCK outer-join WHERE         X_prop-ref.dt-code = temp-dis-card-property.dt-code by temp-dis-card-property.dtm-code by temp-dis-card-property.dt-code by temp-dis-card-property.node-code      INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-property-value-character as character no-undo .
define variable v-rw-option as character no-undo .
define variable v-range as integer no-undo .
define variable v-node-code-label as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-entry2 as character no-undo .
define buffer buf_prop-head for ub.prop-head.
for each  Temp-dis-card-property share-lock:
  delete Temp-dis-card-property.
end.
assign
dtm-node-option = '':U
dtm-option = 0
node-code-option = 0
.
if p-mode <> 'ДОБАВЛЕНИЕ':U then
Assign
vard-card = locked_dis-card.d-card
.
for each temp-dis-card-property:
  delete temp-dis-card-property.
end.
display vard-card
with frame Dialog-Frame  .
For each tt0-dis-card-property where
        tt0-dis-card-property.d-card = pard-card
        no-lock :
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = tt0-dis-card-property.dtm-code no-error .
  run discprop-node-code (
                       input tt0-dis-card-property.dtm-code
                      ,input tt0-dis-card-property.node-code
                      ,output v-data-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                       ).
    create temp-dis-card-property.
    assign
    temp-dis-card-property.d-card    = tt0-dis-card-property.d-card
    temp-dis-card-property.dt-code   = tt0-dis-card-property.dt-code
    temp-dis-card-property.sum-id    = tt0-dis-card-property.sum-id
    temp-dis-card-property.dtm-code = tt0-dis-card-property.dtm-code
    temp-dis-card-property.data-type  = v-data-type
    temp-dis-card-property.range      = v-range
    temp-dis-card-property.node-label = v-label
    temp-dis-card-property.prop-label = (if available buf_prop-head
                                         then buf_prop-head.prop-label
                                         else '':U)
    temp-dis-card-property.property-value-character = tt0-dis-card-property.property-value-character
    temp-dis-card-property.property-value-date = tt0-dis-card-property.property-value-date
    temp-dis-card-property.property-value-decimal = tt0-dis-card-property.property-value-decimal
    temp-dis-card-property.property-value-integer = tt0-dis-card-property.property-value-integer
    temp-dis-card-property.rw-option = v-rw-option
    temp-dis-card-property.node-code = tt0-dis-card-property.node-code
    temp-dis-card-property.host-code = tt0-dis-card-property.host-code
    temp-dis-card-property.obj-type = tt0-dis-card-property.obj-type
    temp-dis-card-property.obj-code = tt0-dis-card-property.obj-code
    .
End.
Run Openbr in this-procedure .
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-db-edit-prop-code as character no-undo .
define variable v-list as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_attr-prop for ub.attr-prop.
define buffer buf2_attr-prop for ub.attr-prop.
DEFINE VARIABLE v-h AS handle NO-UNDO.
v-h = br-prop:FIRST-COLUMN IN FRAME Dialog-Frame.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Свойство" then do:
    v-h:RESIZABLE = YES.
   end.
   IF v-h:LABEL =  "Идентификатор/!Описание" THEN DO:
      v-h:RESIZABLE = YES.
   END.
   IF v-h:LABEL = "Значение!(строковое)" THEN
   v-ch[1] = v-h.
   IF v-h:LABEL = "Значение!(Дата)" THEN
   v-ch[2] = v-h.
   IF v-h:LABEL = "Значение!(Десятичное)" THEN
   v-ch[3] = v-h.
   IF v-h:LABEL = "Значение!(Целое)" THEN
   v-ch[4] = v-h.
   IF v-h:LABEL = "Значение!(Логическое)" THEN
   v-ch[5] = v-h.
   v-h = v-h:NEXT-COLUMN.
END.
assign
b-ins:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
.
if p-mode <> 'ПРОСМОТР':U then do:
  if v-cntxt-db-num = 0 then do:
   v-db-edit-prop-code = 'DB0Edit':U.
  end.
  else do:
   v-db-edit-prop-code = 'DBREdit':U.
  end.
  for each buf_prop-head where
          buf_prop-head.storage-place = 'dis-card-property':U
      or  buf_prop-head.storage-place-host = 'dis-card-property':U
      or  buf_prop-head.storage-place-obj = 'dis-card-property':U:
    if discprop-usercanedit ( input buf_prop-head.dtm-code, input v-cntxt-db-num) = yes then do:
      v-list = v-list + (if v-list = '' then '' else chr(44)) + (string(buf_prop-head.dtm-code) + chr(4) + '':U).
    end.
  end.
  run attr-pop-create-items in this-procedure  (
                                            input 'dis-card-property':U
                                            ,input 'discprop-edit'
                                            ,input 'discprop-node-name'
                                            ,input 'choose-to-edit'
                                            ,input menu menu-b-ins:handle
                                            ,input v-list
                                          ).
end.
IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
  DISPLAY
  buf_clients.obj-name @ v-cli-name
  locked_dis-card.first-main-card @ v-first-main-card
  locked_dis-card.main-card @ v-main-card
  locked_dis-card.first-card @ v-first-card
  WITH FRAME Dialog-Frame.
END.
ELSE do:
   HIDE
   v-cli-name
   v-first-main-card
   v-first-card
   v-main-card
   IN FRAME Dialog-Frame.
END.
ENABLE
rs-view
b-exit when p-mode <> 'ПРОСМОТР':U
b-quit
b-del when p-mode <> 'ПРОСМОТР':U
b-ins when (p-mode <> 'ПРОСМОТР':U and  can-find( first tt-attr-property where
                                                    tt-attr-property.table-name = 'dis-card-property':U
                                                and tt-attr-property.edit-menu-section-num > 0))
b-chg when p-mode <> 'ПРОСМОТР':U
b-help
br-prop
b-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
rs-view = 0.
run Openbr in this-procedure .
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit
  in frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:col    = 1
  .
end.
APPLY "ENTRY" TO br-prop.
APPLY "VALUE-CHANGED" TO br-prop.
END PROCEDURE.
PROCEDURE Openbr :
CASE rs-view:
  WHEN 1  THEN DO:
      OPEN QUERY br-prop
      FOR EACH temp-dis-card-property,
          FIRST X_prop-map NO-LOCK WHERE
              X_prop-map.dtm-code = temp-dis-card-property.dtm-code
          AND X_prop-map.node-code = temp-dis-card-property.node-code,
          FIRST X_prop-ref NO-LOCK OUTER-JOIN WHERE
              X_prop-ref.dt-code = temp-dis-card-property.dt-code
      by temp-dis-card-property.dtm-code
      by temp-dis-card-property.dt-code
      by temp-dis-card-property.node-code
          INDEXED-REPOSITION.
  END.
  WHEN 0  THEN DO:
      OPEN QUERY br-prop
      FOR EACH temp-dis-card-property
      WHERE temp-dis-card-property.host-code = 0
      OR (temp-dis-card-property.host-code = p-host-code AND
          temp-dis-card-property.obj-type = '')
      OR (temp-dis-card-property.host-code = p-host-code AND
          temp-dis-card-property.obj-type = p-obj-type AND
          temp-dis-card-property.obj-code = p-obj-code
           ),
          FIRST X_prop-map NO-LOCK WHERE
              X_prop-map.dtm-code = temp-dis-card-property.dtm-code
          AND X_prop-map.node-code = temp-dis-card-property.node-code,
          FIRST X_prop-ref NO-LOCK OUTER-JOIN WHERE
              X_prop-ref.dt-code = temp-dis-card-property.dt-code
      by temp-dis-card-property.dtm-code
      by temp-dis-card-property.dt-code
      by temp-dis-card-property.node-code
          INDEXED-REPOSITION.
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable loc#log as logical no-undo.
define variable var-region  as character no-undo.
DEFINE VARIABLE v-sel-vals as character no-undo .
DEFINE VARIABLE v-sel-labels as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-dtm-option as integer no-undo .
define variable v-spr as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-setted as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-old-kat like ub.dis-card-property.property-value-character no-undo .
define buffer buf_attr-prop for ub.attr-prop.
if  discprop-usercanedit ( if p-add
                           then dtm-option
                           else temp-dis-card-property.dtm-code
                           , v-cntxt-db-num)  = no then do:
   message
  "Нельзя редактировать Данное свойство в данной БД"
  view-as alert-box .
  undo, return error .
end.
case p-add:
  when yes then do:
     run discprop-node-code in this-procedure (
                                         input  dtm-option
                                        ,input  node-code-option
                                        ,output v-data-type
                                        ,output v-format
                                        ,output v-label
                                        ,output v-range
                                        ,output v-rw-option
                                        ) no-error .
    if error-status :error then do:
      return error .
    end.
    if v-range > 4 then do:
      assign
      v-sel-vals =  if p-emitent-host-code = 0 and BinMask(integer(v-range), "XXX1":U)
                    then  ("1" + chr(44) )
                    else ''
      v-sel-labels = if p-emitent-host-code = 0 and BinMask(integer(v-range), "XXX1":U)
                    then  ("Глобально" + chr(44) )
                    else ''
      .
      assign
      v-sel-vals = v-sel-vals +
                   if p-emitent-host-code <> 0 and BinMask(integer(v-range), "XX1X":U)
                   then ("1":U + chr(44))
                   else "":U
      v-sel-labels = v-sel-labels +
                   if p-emitent-host-code <> 0 and BinMask(integer(v-range), "XX1X":U)
                   then ( substitute("Эмитент (фирма &1)", p-emitent-host-code) + chr(44))
                   else "":U
      .
      assign
      v-sel-vals = v-sel-vals +
                   if p-emitent-host-code = 0 and  BinMask(integer(v-range), "X1XX":U)
                   then ("2":U + chr(44))
                   else "":U
      v-sel-labels = v-sel-labels +
                   if p-emitent-host-code = 0 and  BinMask(integer(v-range), "X1XX":U)
                   then ( substitute("Фирма &1", p-host-code) + chr(44))
                   else "":U
      .
      assign
      v-sel-vals = v-sel-vals +
                   if BinMask(integer(v-range), "1XXX":U)
                   then ("4":U + chr(44))
                   else "":U
      v-sel-labels = v-sel-labels +
                   if BinMask(integer(v-range), "1XXX":U)
                   then ( substitute("&1&2", p-obj-type, p-obj-code) + chr(44))
                   else "":U
      .
        assign
      v-sel-labels = trim(v-sel-labels, chr(44))
      v-sel-vals   = trim(v-sel-vals, chr(44))
        .
      run gbl/d-list.w (
                          input "b-sel":U
                          ,input "Выберите область действия"
                          ,v-sel-vals
                          ,v-sel-labels
                          ,chr(44)
                          ,"":U
                          ,output var-region) no-error.
      if error-status:error then do:
        assign
        dtm-node-option = '':U
        dtm-option = 0
        node-code-option = 0
        .
        return error.
      end.
    end.
    else do:
      assign
      var-region = string(v-range)
      .
    end.
    CASE var-region:
        when "0":U then do:
            assign
            v-host-code = 0
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "1":U then do:
            assign
            v-host-code = (if p-emitent-host-code = 0 then 0 else p-emitent-host-code)
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "2":U then do:
            assign
            v-host-code = p-host-code
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "4":U then do:
            assign
            v-host-code = p-host-code
            v-obj-type = p-obj-type
            v-obj-code = p-obj-code
            .
        end.
    END CASE.
    define variable v-ref-list as character no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
    define buffer buf_dis-card-type for ub.dis-card-type.
    find first buf_dis-card-type no-lock where
              buf_Dis-card-type.type = p-type
          and buf_Dis-card-type.emitent-host-code = p-emitent-host-code
          and buf_Dis-card-type.host-code = 0
          and buf_Dis-card-type.obj-type = '':U
          and buf_Dis-card-type.obj-code = 0 .
    run ref/proprefs.w (
                    input parparentproc
                  ,input 'b-sel'
                  ,input "dtm-code"
                  ,input dtm-option
                  ,input '':U
                  ,input buf_Dis-card-type.uniq-key-rec
                  ,input-output  v-ref-list) no-error.
    find first buf_prop-ref no-lock where
              recid(buf_prop-ref) = integer(v-ref-list) no-error .
    if not available buf_prop-ref then return no-apply.
    run temp-dc-prop-exist in this-procedure (
                                               input pard-card
                                              ,input v-host-code
                                              ,input v-obj-type
                                              ,input v-obj-code
                                              ,input dtm-option
                                              ,input node-code-option
                                              ,input buf_prop-ref.dt-code
                                              ,output loc#log)  no-error.
    if error-status:error or loc#log then do:
      if loc#log then do:
        message
        "Уже есть такое свойство"
        view-as alert-box error .
      end.
      return error.
    end.
    assign
    v-dtm-option = dtm-option
    .
    if node-code-option > 0 then do:
      run discprop-initial in this-procedure (
                                              input  dtm-option
                                              ,input  node-code-option
                                              ,output v-value-character
                                              ,output v-value-date
                                              ,output v-value-decimal
                                              ,output v-value-integer
                                              ,output v-value-logical ) no-error .
    if error-status:error then do:
      message error-status:error error-status:get-message(1)  return-value
      view-as alert-box error .
      undo, return error .
    end.
   end.
  end.
  when no then do:
    run discprop-node-code in this-procedure (
                                     input TEMP-dis-card-property.dtm-code
                                    ,input TEMP-dis-card-property.node-code
                                    ,output v-data-type
                                    ,output v-format
                                    ,output v-label
                                    ,output v-range
                                    ,output v-rw-option
                                    ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении названия и типа свойства дисконтной карты!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
    assign
    v-value-character  = temp-dis-card-property.property-value-character
    v-value-date       = temp-dis-card-property.property-value-date
    v-value-decimal    = temp-dis-card-property.property-value-decimal
    v-value-integer    = temp-dis-card-property.property-value-integer
    v-value-logical    = temp-dis-card-property.property-value-logical
    .
  end.
END CASE.
if node-code-option > 0 then do:
  IF index(v-rw-option, "W") > 0
  Then DO:
    case v-data-type:
      when 'integer':U then do:
        run gbl/d-integer.w (
              input ?
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u  + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-integer
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-integer = v-value-integer.
      end.
      when 'decimal':U then do:
        run gbl/d-decimal.w (
              input ?
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u  + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-integer
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-decimal = v-value-decimal.
      end.
      when 'character':U then do:
        run gbl/d-character.w (
              input ?
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-character
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-character = v-value-character.
      end.
      when 'logical':U then do:
        run gbl/d-logical.w (
              input ?
              ,input ('title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-logical
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-logical = v-value-logical.
      end.
    end case.
  end.
  Else do:
    message "Изменение свойства невозможно !" view-as alert-box error.
    return error.
  end.
  run temp-dc-prop-write in this-procedure (
                  input pard-card
                  ,input (if p-add then v-host-code else temp-dis-card-property.host-code)
                  ,input (if p-add then v-obj-type else temp-dis-card-property.OBJ-TYPE)
                  ,input (if p-add then v-obj-code else temp-dis-card-property.obj-code)
                  ,input (if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                  ,input (if p-add then node-code-option else  temp-dis-card-property.node-code)
                  ,input (if p-add then buf_prop-ref.dt-code else  temp-dis-card-property.dt-code)
                  ,input (if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                  ,input property-value-character
                  ,input property-value-date
                  ,input property-value-decimal
                  ,input property-value-integer
                  ,input property-value-logical
                  ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
    br-prop:refresh() in frame Dialog-Frame no-error .
  END.
  else do:
    message
    substitute("Ошибка при сохранении свойства ДК&1" +
                "ДК &2&1" +
                "Свойство  &3.&4 &5"
                , chr(10)
                , pard-card
                ,(if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                ,(if p-add then node-code-option else  temp-dis-card-property.node-code)
                ,(if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                )
    return-value view-as alert-box .
    return error .
  end.
end.
else do:
  find first buf_attr-prop no-lock where
            buf_attr-prop.table-name = 'dis-card-property':U
        and buf_attr-prop.templ-rl-root = (if p-add then dtm-option else temp-dis-card-property.dtm-code)
        and buf_attr-prop.upper-prop-code = "InputForm":U
        and buf_attr-prop.prop-code = "FormName":U no-error.
  if not available buf_attr-prop then do:
  end.
  else do:
     run value ( buf_attr-prop.property-value) (
                                               INPUT parparentproc
                                              ,INPUT (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                              ,INPUT (if p-add then dtm-option else temp-dis-card-property.dtm-code)
                                              ,INPUT (if p-add then buf_prop-ref.sum-id else temp-dis-card-property.sum-id)
                                              ,INPUT (if p-add then buf_prop-ref.dt-code else temp-dis-card-property.dt-code)
                                              ,INPUT (if p-add then 0 else temp-dis-card-property.node-code)
                                              ,INPUT p-emitent-host-code
                                              ,INPUT p-type
                                              ,INPUT pard-card
                                              ,INPUT (if p-add then v-host-code else temp-dis-card-property.host-code)
                                              ,INPUT (if p-add then v-obj-type else temp-dis-card-property.obj-type)
                                              ,INPUT (if p-add then v-obj-code else temp-dis-card-property.obj-code)
                                              ,INPUT-OUTPUT TABLE temp-dis-card-property
                                              ,OUTPUT v-ok
                                                ) no-error .
      IF not error-status:error then do:
        if v-ok then do:
          assign
          updated = yes
          .
          br-prop:refresh() in frame Dialog-Frame no-error .
        end.
      END.
      else do:
        message
        substitute("Ошибка при сохранении свойства ДК&1" +
                    "ДК &2&1" +
                    "Свойство  &3 срез &4"
                    , chr(10)
                    , pard-card
                    ,(if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                    ,(if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                    )
        return-value view-as alert-box .
        return error .
      end.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-lkp :
define variable v-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-rw-option as character no-undo .
define variable property-value-character as character no-undo .
define variable property-value-date as date no-undo .
define variable property-value-decimal as decimal no-undo .
define variable property-value-integer as integer no-undo .
define variable property-value-logical as logical no-undo .
define variable v-range as integer no-undo .
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .
define variable v-ok as logical no-undo .
define buffer buf_attr-prop for ub.attr-prop.
  run discprop-node-code (
                       input temp-dis-card-property.dtm-code
                      ,input temp-dis-card-property.node-code
                      ,output v-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                      ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    message "Ошибка при определении названия и типа свойства дисконтной карты!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
    return error.
END.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
      and buf_attr-prop.templ-rl-root = temp-dis-card-property.dtm-code
      and buf_attr-prop.upper-prop-code = "InputForm":U
      and buf_attr-prop.prop-code = "FormName":U no-error.
if not available buf_attr-prop then do:
end.
else do:
  run value ( buf_attr-prop.property-value) (
                                           INPUT parparentproc
                                          ,INPUT 'ПРОСМОТР':U
                                          ,INPUT temp-dis-card-property.dtm-code
                                          ,INPUT temp-dis-card-property.sum-id
                                          ,INPUT temp-dis-card-property.dt-code
                                          ,INPUT temp-dis-card-property.node-code
                                          ,INPUT p-emitent-host-code
                                          ,INPUT p-type
                                          ,INPUT pard-card
                                          ,INPUT temp-dis-card-property.host-code
                                          ,INPUT temp-dis-card-property.obj-type
                                          ,INPUT temp-dis-card-property.obj-code
                                          ,INPUT-OUTPUT TABLE temp-dis-card-property
                                          ,OUTPUT v-ok
                                            ) no-error .
  apply "entry" to br-prop in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-chip-num as integer no-undo init 0.
define variable v-corr-date as date init ?.
define variable v-corr-time as integer no-undo init ?.
for each temp-dis-card-property NO-LOCK
break
by temp-dis-card-property.dt-code
:
   find first tt0-dis-card-property NO-LOCK WHERE
          tt0-dis-card-property.d-card = temp-dis-card-property.d-card
    AND   tt0-dis-card-property.host-code = temp-dis-card-property.host-code
    AND   tt0-dis-card-property.obj-type = temp-dis-card-property.obj-type
    AND   tt0-dis-card-property.obj-code = temp-dis-card-property.obj-code
    AND   tt0-dis-card-property.node-code = temp-dis-card-property.node-code
    AND   tt0-dis-card-property.dt-code = temp-dis-card-property.dt-code  no-error.
  assign
  v-updated = no.
  if available  tt0-dis-card-property then do:
    BUFFER-COMPARE temp-dis-card-property
    except card-num main-card first-card first-main-card
    TO tt0-dis-card-property
    case-sensitive
    SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    CASE p-update-instantly:
      when no then do:
        run tt0-dc-prop-write in this-procedure(
                                                   input PARd-card
                                                  ,input temp-dis-card-property.host-code
                                                  ,input temp-dis-card-property.obj-type
                                                  ,input temp-dis-card-property.obj-code
                                                  ,input temp-dis-card-property.dtm-code
                                                  ,input temp-dis-card-property.node-code
                                                  ,input temp-dis-card-property.dt-code
                                                  ,input temp-dis-card-property.sum-id
                                                  ,input temp-dis-card-property.property-value-character
                                                  ,input temp-dis-card-property.property-value-date
                                                  ,input temp-dis-card-property.property-value-decimal
                                                  ,input temp-dis-card-property.property-value-integer
                                                  ,input temp-dis-card-property.property-value-logical
                                                  )  no-error.
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении свойства ДК&1" +
                     "ДК &2&1" +
                     "Свойство &3.&4 срез &5" +
                     "&6&1&7"
                    ,chr(10)
                    ,pard-card
                    ,temp-dis-card-property.dtm-code
                    ,temp-dis-card-property.node-code
                    ,temp-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                    )
          view-as alert-box  error .
          undo, return error  .
        end.
        updated = yes.
      end.
      when yes then do:
        if first-of(temp-dis-card-property.dt-code) then do:
          assign
          v-chip-num = 0
          v-corr-date = ?
          v-corr-time = ?
          .
        end.
        run discprop-write in this-procedure (
                                             input PARd-card
                                            ,input temp-dis-card-property.host-code
                                            ,input temp-dis-card-property.obj-type
                                            ,input temp-dis-card-property.obj-code
                                            ,input temp-dis-card-property.dtm-code
                                            ,input temp-dis-card-property.node-code
                                            ,input temp-dis-card-property.dt-code
                                            ,input temp-dis-card-property.sum-id
                                            ,input temp-dis-card-property.property-value-character
                                            ,input temp-dis-card-property.property-value-date
                                            ,input temp-dis-card-property.property-value-decimal
                                            ,input temp-dis-card-property.property-value-integer
                                            ,input temp-dis-card-property.property-value-logical
                                            ,input '':U
                                            ,input '':U
                                            ,input-output v-chip-num
                                            ,input-output v-corr-date
                                            ,input-output v-corr-time
                                            )  no-error.
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении свойства ДК&1" +
                     "ДК &2&1"  +
                     "Свойство &3.&4 срез &5" +
                     "&6&1&7"
                    ,chr(10)
                    ,pard-card
                    ,temp-dis-card-property.dtm-code
                    ,temp-dis-card-property.node-code
                    ,temp-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                    )
          view-as alert-box error .
          undo, return error  .
        end.
        updated = yes.
      end.
    END CASE.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-dis-card-property
break by tt0-dis-card-property.dt-code
:
  if first-of(tt0-dis-card-property.dt-code) then do:
    assign
    v-chip-num = 0
    v-corr-date = ?
    v-corr-time = ?
    .
  end.
  FIND FIRST temp-dis-card-property NO-LOCK WHERE
            temp-dis-card-property.d-card = tt0-dis-card-property.d-card
        AND temp-dis-card-property.host-code = tt0-dis-card-property.host-code
        AND temp-dis-card-property.obj-type = tt0-dis-card-property.obj-type
        AND temp-dis-card-property.obj-code = tt0-dis-card-property.obj-code
        AND temp-dis-card-property.dtm-code = tt0-dis-card-property.dtm-code
        AND temp-dis-card-property.node-code = tt0-dis-card-property.node-code
        AND temp-dis-card-property.dt-code = tt0-dis-card-property.dt-code    NO-ERROR.
    IF NOT AVAILABLE temp-dis-card-property THEN DO:
      CASE p-update-instantly:
        when no then do:
          DELETE tt0-dis-card-property.
          assign
          v-deleted = yes.
        end.
        when yes then do:
          v-deleted = no.
          run discprop-delete in this-procedure(
                                                 input PARd-card
                                                ,input tt0-dis-card-property.host-code
                                                ,input tt0-dis-card-property.OBJ-TYPE
                                                ,input tt0-dis-card-property.obj-code
                                                ,input tt0-dis-card-property.dtm-code
                                                ,input tt0-dis-card-property.node-code
                                                ,input tt0-dis-card-property.dt-code
                                                ,input '':U
                                                ,input '':U
                                                ,output v-deleted
                                                ,input-output v-chip-num
                                                ,input-output v-corr-date
                                                ,input-output v-corr-time
                                                ) no-error   .
          if error-status:error or not v-deleted then do:
            message
            substitute("Ошибка при удалении свойства ДК&1" +
                       "ДК &2&1" +
                       "Свойство &3.&4 срез &5"
                      ,chr(10)
                      ,pard-card
                      ,tt0-dis-card-property.dtm-code
                      ,tt0-dis-card-property.node-code
                      ,tt0-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                      )
            return-value view-as alert-box .
            undo, return error.
          end.
        end.
      END CASE.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if can-find(first dcp-list) then do:
  run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/sendclia.p':U
                , input(string(g#db-num) + chr(4) + "shop=" + string(locked_Dis-card.issue-code) + chr(4) + "no":U + chr(4) + "E":U)
                , input yes
                , input '':U
                , input 'Отправка информации по клиентским картам на кассу ЭКСПОРТА') no-error .
end.
END PROCEDURE.
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch[1]:FGCOLOR = GREY_COLOR
v-ch[1]:BGCOLOR = GREY_Color
v-ch[1]:PFCOLOR = GREY_Color
v-ch[2]:FGCOLOR = GREY_COLOR
v-ch[2]:BGCOLOR = GREY_Color
v-ch[2]:PFCOLOR = GREY_Color
v-ch[3]:FGCOLOR = GREY_COLOR
v-ch[3]:BGCOLOR = GREY_Color
v-ch[3]:PFCOLOR = GREY_Color
v-ch[4]:FGCOLOR = GREY_COLOR
v-ch[4]:BGCOLOR = GREY_Color
v-ch[4]:PFCOLOR = GREY_Color
v-ch[5]:FGCOLOR = GREY_COLOR
v-ch[5]:BGCOLOR = GREY_Color
v-ch[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch[1]:FGCOLOR = BLACK_COLOR
      v-ch[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch[3]:FGCOLOR = BLACK_COLOR
      v-ch[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch[4]:FGCOLOR = BLACK_COLOR
      v-ch[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch[2]:FGCOLOR = BLACK_COLOR
      v-ch[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch[5]:FGCOLOR = BLACK_COLOR
       v-ch[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
PROCEDURE temp-dc-prop-exist :
do
  on error undo, return error
  :
    define input parameter p-d-card     like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code  like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type   like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code   like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code   like ub.dis-card-property.dtm-code  no-undo .
    define input parameter p-node-code  like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code    like ub.dis-card-property.dt-code  no-undo .
    define output parameter p-exist      as logical  no-undo .
    define buffer buf_temp-dis-card-property for temp-dis-card-property .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable V-RANGE          as integer   no-undo .
    define variable v-rw-option      as character no-undo .
    run discprop-node-code in this-procedure (
       input  p-dtm-code
      ,input  p-node-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,OUTPUT V-RANGE
      ,output v-rw-option
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-dis-card-property no-lock
      where buf_temp-dis-card-property.d-card    = p-d-card
        and buf_temp-dis-card-property.host-code = p-host-code
        and buf_temp-dis-card-property.obj-type  = p-obj-type
        and buf_temp-dis-card-property.obj-code  = p-obj-code
        and buf_temp-dis-card-property.dtm-code = p-dtm-code
        and buf_temp-dis-card-property.node-code = p-node-code
        and buf_temp-dis-card-property.dt-code = p-dt-code
      no-error .
    if  available buf_temp-dis-card-property then do:
      p-exist = yes.
    end.
  end.
END PROCEDURE.
PROCEDURE temp-dc-prop-write :
do
  on error undo, return error
  :
    define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
    define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
    define input parameter p-sum-id    like ub.dis-card-property.sum-id     no-undo .
    define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
    define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
    define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
    define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
    define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
    define buffer buf_temp-dis-card-property for temp-dis-card-property .
    define buffer buf_dis-card for ub.dis-card.
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-rw-option      as character no-undo .
    run discprop-node-code in this-procedure (
       input  p-dtm-code
      ,input  p-node-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-rw-option
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      run discprop-check in this-procedure  (
                       input v-range
                      ,input p-d-card
                      ,input p-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input p-dtm-code
                      ,input p-node-code
                      ,input p-dt-code
                    ) no-error .
      if error-status:error then undo,  return error return-value .
    end.
    find first buf_temp-dis-card-property exclusive-lock
      where buf_temp-dis-card-property.d-card    = p-d-card
        and buf_temp-dis-card-property.host-code = p-host-code
        and buf_temp-dis-card-property.obj-type  = p-obj-type
        and buf_temp-dis-card-property.obj-code  = p-obj-code
        and buf_temp-dis-card-property.dtm-code = p-dtm-code
        and buf_temp-dis-card-property.node-code = p-node-code
        and buf_temp-dis-card-property.dt-code = p-dt-code
      no-error .
    if not available buf_temp-dis-card-property then do:
      create buf_temp-dis-card-property .
      assign
      buf_temp-dis-card-property.d-card    = p-d-card
      buf_temp-dis-card-property.host-code = p-host-code
      buf_temp-dis-card-property.obj-type  = p-obj-type
      buf_temp-dis-card-property.obj-code  = p-obj-code
      buf_temp-dis-card-property.dtm-code = p-dtm-code
      buf_temp-dis-card-property.dt-code = p-dt-code
      buf_temp-dis-card-property.sum-id = p-sum-id
      buf_temp-dis-card-property.node-code = p-node-code
      buf_temp-dis-card-property.node-label = v-label
      buf_temp-dis-card-property.card-num  = 0
      .
    end.
    else do:
      if (v-type = 'character':U
      and buf_temp-dis-card-property.property-value-character = p-value-character)
      or  (v-type = 'date':U
          and buf_temp-dis-card-property.property-value-date = p-value-date)
      or  (v-type = 'decimal':U
          and buf_temp-dis-card-property.property-value-decimal = p-value-decimal)
      or  (v-type = 'integer':U
          and buf_temp-dis-card-property.property-value-integer = p-value-integer)
      or  (v-type = 'logical':U
          and buf_temp-dis-card-property.property-value-logical = p-value-logical)
      then return.
    end.
    assign
    buf_temp-dis-card-property.property-value-character = p-value-character
    buf_temp-dis-card-property.property-value-date = p-value-date
    buf_temp-dis-card-property.property-value-decimal = p-value-decimal
    buf_temp-dis-card-property.property-value-integer = p-value-integer
    buf_temp-dis-card-property.property-value-logical = p-value-logical
    .
    release buf_temp-dis-card-property no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
END PROCEDURE.
PROCEDURE tt0-dc-prop-write :
do
  on error undo, return error
  :
    define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code        like ub.dis-card-property.dtm-code  no-undo .
    define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code         like ub.dis-card-property.dt-code  no-undo .
    define input parameter p-sum-id          like ub.dis-card-property.sum-id  no-undo .
    define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
    define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
    define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
    define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
    define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
    define buffer buf_tt0-dis-card-property for tt0-dis-card-property .
    define buffer buf_dis-card for ub.dis-card.
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer no-undo .
    define variable v-rw-option      as character  no-undo .
    run discprop-node-code in this-procedure (
                                         input  p-dtm-code
                                        ,input  p-node-code
                                        ,output v-type
                                        ,output v-format
                                        ,output v-label
                                        ,output v-range
                                        ,output v-rw-option
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      run trg/dc-prop2.p (
                             input v-range
                            ,input p-d-card
                            ,input p-host-code
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input p-dtm-code
                            ,input p-node-code
                            ,input p-dt-code
                          ) no-error .
      if error-status:error then undo,  return error return-value .
    end.
    find first buf_tt0-dis-card-property exclusive-lock
      where buf_tt0-dis-card-property.d-card    = p-d-card
        and buf_tt0-dis-card-property.host-code = p-host-code
        and buf_tt0-dis-card-property.obj-type  = p-obj-type
        and buf_tt0-dis-card-property.obj-code  = p-obj-code
        and buf_tt0-dis-card-property.dt-code = p-dt-code
        and buf_tt0-dis-card-property.node-code = p-node-code
      no-error .
    if not available buf_tt0-dis-card-property then do:
      create buf_tt0-dis-card-property .
      assign
        buf_tt0-dis-card-property.d-card    = p-d-card
        buf_tt0-dis-card-property.host-code = p-host-code
        buf_tt0-dis-card-property.obj-type  = p-obj-type
        buf_tt0-dis-card-property.obj-code  = p-obj-code
        buf_tt0-dis-card-property.dtm-code = p-dtm-code
        buf_tt0-dis-card-property.node-code = p-node-code
        buf_tt0-dis-card-property.dt-code = p-dt-code
        buf_tt0-dis-card-property.sum-id = p-sum-id
        buf_tt0-dis-card-property.card-num  = 0
      .
    end.
    else do:
      if (v-type = 'character':U
      and buf_tt0-dis-card-property.property-value-character = p-value-character)
      or  (v-type = 'date':U
          and buf_tt0-dis-card-property.property-value-date = p-value-date)
      or  (v-type = 'decimal':U
          and buf_tt0-dis-card-property.property-value-decimal = p-value-decimal)
      or  (v-type = 'integer':U
          and buf_tt0-dis-card-property.property-value-integer = p-value-integer)
      or  (v-type = 'logical':U
          and buf_tt0-dis-card-property.property-value-logical = p-value-logical)
      then return.
    end.
    assign
    buf_tt0-dis-card-property.property-value-character = p-value-character
    buf_tt0-dis-card-property.property-value-date = p-value-date
    buf_tt0-dis-card-property.property-value-decimal = p-value-decimal
    buf_tt0-dis-card-property.property-value-integer = p-value-integer
    buf_tt0-dis-card-property.property-value-logical = p-value-logical
    .
    release buf_tt0-dis-card-property no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
END PROCEDURE.
FUNCTION display-character RETURNS CHARACTER
  ( INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER) :
DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.
IF trim(p-format, "*") = "" THEN
  v-string = string(p-character, p-format).
ELSE DO:
  v-string = p-character.
END.
RETURN v-string.
END FUNCTION.
FUNCTION get-prop-value RETURNS CHARACTER
     ( INPUT p-data-type AS CHARACTER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
 ) :
define buffer buf_cash-pay for ub.cash-pay.
case trim(p-data-type, chr(44)):
  when 'character':U then do:
    return p-value-character.
  end.
  when 'date':U then do:
    return string(p-value-date, "99/99/9999").
  end.
  when 'decimal':U then do:
    return string(p-value-decimal).
  end.
  when 'integer':U then do:
    return string(p-value-integer).
  end.
  when 'logical':U then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.
