block-level on error undo, throw.
define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-parent-handle as handle        no-undo .
define input parameter p-log-handle    as handle        no-undo .
define input parameter p-hn-handle     as handle        no-undo .
define input parameter p-silent                       as logical no-undo .
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter par-mode2 as character no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter pard-card as character no-undo  case-sensitive.
define input parameter paremitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter parcli-type like ub.dis-card.cli-type no-undo .
define input parameter parcli-code like ub.dis-card.cli-code no-undo .
define input parameter par-status_ like ub.dis-card.status_ no-undo .
define input parameter par-type like ub.dis-card.type no-undo .
define input parameter pard-pcnt like ub.dis-card.d-pcnt no-undo .
define input parameter parcash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo .
define input parameter parcategory like ub.dis-card.category no-undo .
define input parameter pard-pcnt-method like ub.dis-card.d-pcnt-method no-undo .
define input parameter parcredit-card like ub.dis-card.credit-card no-undo .
define input parameter parlim-kr like ub.dis-card.lim-kr no-undo .
define input parameter pardebet-card like  ub.dis-card.debet-card  no-undo .
define input parameter parstaff-card like  ub.dis-card.staff-card  no-undo .
define input parameter parissue-date like ub.dis-card.issue-date no-undo .
define input parameter parissue-code like ub.dis-card.issue-code no-undo .
define input parameter parvalid-from like ub.dis-card.valid-from no-undo .
define input parameter parvalid-date like ub.dis-card.valid-date no-undo .
define input parameter parsourced-card like ub.dis-card.sourced-card no-undo .
define input parameter parcli-message like ub.dis-card.cli-message no-undo case-sensitive.
define input parameter parmask-card   like ub.dis-card.mask-card no-undo .
define input parameter parmain-card   like ub.dis-card.main-card no-undo .
define input parameter paris-subsid   like ub.dis-card.is-subsid no-undo .
define input parameter p-update-prop  as logical no-undo .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-card-property.
define variable vss-revision    as character no-undo init "$Revision: 560be6005277, 558, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 30 17:48:23 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке дисконтной карты".
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
procedure discardh_write-dis-card-proc  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
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
    buf_c-dc-hist.action =  integer('2':U)
    buf_c-dc-hist.subject = 'dis-card':U
    buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = (chr(4) +  'СПН':U)
        )
    then do:
      run str/callnews.p
        (input 'c-dis-card':U
        ,input (buffer buf_c-dis-card:handle)
        ).
      run str/callnews.p
        (input 'c-dc-hist':U
        ,input (buffer buf_c-dc-hist:handle)
        ).
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-mask-card :
define input parameter p-mask like ub.dis-card.d-card no-undo .
define input parameter p-silence as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .
define variable v-dec as decimal no-undo.
  do
  on error undo, return error
  :
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маска &1 может стоять только в конце", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(replace(replace(p-mask, chr(63), "0":U), "*":U, "0":U))
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0, * и ?", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
  end.
end procedure.
procedure check-cli-mask :
define input parameter p-mask like ub.dis-card-mask.mask no-undo .
define input parameter p-silence as logical no-undo .
define input parameter p-addvalidchars as character no-undo .
define input parameter p-mask-type as character no-undo .
define input parameter p-cc-run as integer no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .
define variable v-dec as decimal no-undo.
define variable v-dec-dop as character no-undo .
define variable v-old-dop as character no-undo .
define variable ii as integer no-undo .
  do
  on error undo, return error
  :
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(p-addvalidchars, "*") > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-addvalidchars, "*") > 0
    and index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маске &1 может стоять только в конце", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec-dop = replace(replace(p-mask, chr(63), "0":U), "*":U, "0":U)
    .
    do ii = 1 to num-entries(p-addvalidchars):
      assign
      v-old-dop = v-dec-dop
      v-dec-dop = replace(v-dec-dop, entry(ii, p-addvalidchars), "0":U)
      .
      if p-mask-type = entry(ii, p-addvalidchars)
      and (entry(ii, p-addvalidchars) <> 'C':U or p-cc-run > 0)
      and v-dec-dop = v-old-dop then do:
        assign
        p-descr = substitute("Маска &1 должна содержать хотя бы один символ &2", p-mask, p-mask-type)
        .
        if not p-silence then do:  message p-descr view-as alert-box error . end.
        return.
      end.
    end.
    assign
    v-dec = decimal(v-dec-dop)
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0,?&2"
                          , p-mask
                          , (if p-addvalidchars = "":u then "":U else (chr(44) + p-addvalidchars))
                          )
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
  end.
end procedure.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new SHARED temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info10 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info10, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info10, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info10 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info10, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info10, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info10, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info10, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info10, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info10, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info10 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info10, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info10 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE dd as decimal no-undo .
DEFINE VARIABLE VAR-ENTRY as character no-undo .
DEFINE VARIABLE varcard-num like ub.dis-card.card-num no-undo .
define variable v-ok as logical no-undo .
define variable v-descr as character no-undo .
define variable v-dop-d-card as character no-undo .
define variable ii as integer no-undo .
define variable old-sourced-card like ub.dis-card.sourced-card no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-deleted as logical no-undo .
define variable v-type as character no-undo .
define variable v-can-issue as logical no-undo .
define variable v-can-edit as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-import as logical no-undo .
define variable v-rum as logical no-undo .
define variable v-old-title as character no-undo .
define variable v-has-right-to-restore as logical no-undo .
define variable v-first-card like ub.dis-card.first-card no-undo .
define variable v-first-main-card like ub.dis-card.first-main-card no-undo .
define variable v-overissue-num like ub.dis-card.overissue-num no-undo .
define buffer source_dis-card for ub.dis-card.
define buffer main_dis-card for ub.dis-card.
define buffer other_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer buf_dis-host for ub.dis-host .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-mes15 as character no-undo .
    define variable v-param-type15 as character no-undo .
    define variable v-value-character15 as INTEGER no-undo .
    define variable v-value-date15 as date no-undo .
    define variable v-value-decimal15 as decimal no-undo .
    define variable v-value-integer15 AS integer no-undo .
    define variable v-value-logical15 AS LOGICAL no-undo .
    define variable v-tth15 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character15
        ,output v-value-date15
        ,output v-value-decimal15
        ,output v-value-integer15
        ,output v-value-logical15
        ,output v-param-type15
        ,INPUT-OUTPUT table-handle v-tth15
        ) no-error .
    if error-status :error then do:
      delete object v-tth15.
      v-mes15 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes15.
    end.
    delete object v-tth15.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer15)
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess16 for ub.batchprocess.
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
    ,buffer lock-batchprocess16
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
if g#db-num > 0 then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':u.
end.
if par-mode <> 'ДОБАВЛЕНИЕ':U
AND par-mode <> 'ИЗМЕНЕНИЕ':U
AND par-mode <> 'ДОБАВЛЕНИЕ-ИМПОРТ':U
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
if par-mode  = 'ДОБАВЛЕНИЕ-ИМПОРТ':U then do:
  v-import = yes.
  par-mode = 'ДОБАВЛЕНИЕ':U.
end.
if par-mode2 <> '':U then
assign
v-import = (par-mode2 = "import":U)
v-rum = (par-mode2 = "rum":U)
.
if num-entries(par-status_, chr(4)) > 1 then
assign
v-has-right-to-restore = logical(entry(2, par-status_, chr(4)))
par-status_ = entry(1, par-status_, chr(4) )
.
if par-type = "" then do:
  assign
  v-err-mess = substitute("Тип дисконтной карты не может быть пустым").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parcli-type <> 'чел':U
and parcli-type <> 'орг':U then do:
  assign
  v-err-mess =  substitute("Неверный тип клиента &1"
                          , (if parcli-type= ? then chr(63) else parcli-type)
                              ).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "cli-type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
find first buf_clients no-lock where
          buf_clients.obj-type = parcli-type
      AND buf_clients.obj-code = parcli-code no-error .
if not available buf_clients  then do:
  assign
  v-err-mess = substitute("Не найден клиент &1&2 для карты"
             , (if parcli-type= ? then chr(63) else parcli-type)
             , (if parcli-code= ? then chr(63) else string(parcli-code))).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "cli-code":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
FIND FIRST buf_dis-card-type share-LOCK WHERE
           buf_dis-card-type.type = par-type AND
           buf_dis-card-type.emitent-host-code = paremitent-host-code AND
           buf_dis-card-type.host-code = 0 AND
           buf_dis-card-type.obj-type = "":U AND
           buf_dis-card-type.obj-code = 0 No-ERROR.
if not avail buf_dis-card-type then do:
  assign
  v-err-mess = substitute("Неверный тип дисконтной карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if paremitent-host-code <> 0 and not can-find( first ub.sysconf No-LOCK WHERE
                       ub.sysconf.host-code = paremitent-host-code) then do:
  assign
  v-err-mess = substitute("Нет фирмы-эмитента дисконтной карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "host-code":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if pard-pcnt < 0 or parcash-d-pcnt < 0 then do:
  if pard-pcnt < 0 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть отрицательной", pard-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-pcnt":U.
  end.
  if parcash-d-pcnt < 0 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть отрицательной", parcash-d-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "cash-d-pcnt":U.
  end.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if pard-pcnt > 100 or parcash-d-pcnt > 100 then do:
  if pard-pcnt > 100 then  do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть больше 100%", pard-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-pcnt":U.
  end.
  if parcash-d-pcnt > 100 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть больше 100%", parcash-d-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "cash-d-pcnt":U.
  end.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if pard-pcnt > 50 or parcash-d-pcnt > 50 then do:
  if not p-silent then do:
    message "Вы уверены что скидка по дисконтной карте выше 50%?"
    view-as alert-box QUESTION buttons YES-NO update loc#log.
    if NOT loc#log  then do:
      if pard-pcnt > 50 then do:
        var-entry = "d-pcnt":U.
      end.
      else do:
        var-entry = "cash-d-pcnt":U.
      end.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
end.
if paremitent-host-code = 0 and parcredit-card then do:
  assign
  v-err-mess = substitute("Глобальная дисконтная карта не может быть кредитной").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "credit-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parcredit-card and parlim-kr <= 0 then do:
  assign
  v-err-mess  = substitute("Неверный лимит кредита &1, если дисконтная карта кредитная, лимит кредита должен быть положительным"
                           ,parlim-kr).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "lim-kr":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parcredit-card and pardebet-card then do:
  assign
  v-err-mess = substitute("Карта не может быть одновременно и кредитной и дебетовой").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "credit-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parissue-code = 0 and not parmask-card then do:
    assign
    v-err-mess = substitute("Не указан код магазина, выдавшего карту").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "issue-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
end.
if not parmask-card then do:
  find first ub.shop no-lock where
            ub.shop.obj-code = parissue-code NO-ERROR.
  if not avail ub.shop or (paremitent-host-code <> 0 and ub.shop.host-code <> paremitent-host-code) then do:
    assign
    v-err-mess = substitute("Не найден магазин &1, выдавший карту, или он принадлежит другой фирме", parissue-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "issue-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  define buffer shop_clients for ub.clients.
  find first shop_clients no-lock where
           shop_clients.obj-type = 'маг':U
       and shop_clients.obj-code = parissue-code .
  if shop_clients.stts <> integer('0':U) then do:
    if p-silent then do:
      assign
      v-err-mess = substitute("Магазин &1, выдавший карту, имеет статус 2&3" +
                              "Нельзя выдать карту от имени этого магазина!"
                              , parissue-code
                              , entry (lookup (string(shop_clients.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                              , chr(10)
                              ).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "issue-code":U.
      return error (if p-silent = ? then v-err-mess else var-entry).
    end.
    else do:
      assign
      v-err-mess = substitute("Магазин &1, выдавший карту, имеет статус &2&3" +
                              "Вы уверены, что хотите выдать карту от имени этого магазина?"
                              , parissue-code
                              , entry (lookup (string(shop_clients.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                              , chr(10)
                              ).
      define variable glog as logical no-undo .
      message
      v-err-mess view-as alert-box warning buttons yes-no update glog.
      if not glog then do:
        var-entry = "":U.
        return error var-entry.
      end.
    end.
  end.
end.
if parissue-date = ? then do:
  assign
  v-err-mess = substitute("Не указана дата выдачи карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "issue-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parvalid-from = ? then do:
  assign
  v-err-mess = substitute("Не указана дата начала действия карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-from":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parvalid-from < 01/01/2000
and buf_dis-card-type.card-media = integer('5':U)
 then do:
  assign
  v-err-mess = substitute("Дата начала действия карты типа EasyFuel не может быть ранее 01/01/2000").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-from":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parvalid-date = ?
and buf_dis-card-type.card-media = integer('5':U)
then do:
  assign
  v-err-mess = substitute("Не указана дата окончания действия карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if (parvalid-date - parvalid-from) > 4095
and buf_dis-card-type.card-media = integer('5':U)
then do:
  assign
  v-err-mess = substitute("Карта типа EasyFuel не может действовать больше 4095 дней &1" +
                          "Еесли начало срока действия карты &2, то конец срока действия может быть не позже &3"
                          , chr(10)
                          ,string(parvalid-from, "99/99/9999")
                          ,string(parvalid-from + 4095, "99/99/9999")
                            ).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parvalid-date < parissue-date then do:
  assign
  v-err-mess = substitute("Неверная дата окончания действия карты &1", parvalid-date).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parvalid-date < parvalid-from then do:
  assign
  v-err-mess = substitute("Неверная дата окончания действия карты &1", parvalid-date).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if  trim(pard-card) = "" then do:
  assign
  v-err-mess = substitute("Не указан номер карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "d-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.
if parmask-card then do:
  run check-mask-card in this-procedure (
                                          input pard-card
                                        , input no
                                        , output v-ok
                                        , output v-descr) no-error .
  if error-status:error then do:
    assign
    v-err-mess = substitute("Ошибка при проверке карты-маски: &1 &2", error-status:get-message(1), return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if not v-ok then do:
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
end.
else do:
  if par-type = '@client':U then do:
    if pard-card <> ('K':U + string(if parcli-type = 'орг':U then 1 else 0) + string(parcli-code, '999999999')) then do:
        assign
        v-err-mess = substitute("Для карты типа &1 возможно только уникальное значение номера карты клиента = &2"
                                 ,'@client':U
                                 ,('K':U + string(if parcli-type = 'орг':U then 1 else 0) + string(parcli-code, '999999999')) ).
        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
  else do:
    if trim(pard-card) <> pard-card then do:
      assign
      v-err-mess = substitute("В номере карты присутствуют недопустиые символы").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "d-card":U.
      return error (if p-silent = ? then v-err-mess else var-entry).
    end.
    if buf_dis-card-type.card-media = integer('5':U) then do:
      if length(pard-card) <> 8
      or trim(pard-card, "1234567890ABCDEF") <> ""
      or CAPS(pard-card) <> pard-card
      or pard-card = "00000000"
      then do:
        assign
        v-err-mess = substitute("Идентификатор карты EASYFUEL должен представлять 16-чное число&1" +
                                "и быть длиной 8 символов," +
                                "разрешены только цифры и ПРОПИСНЫЕ латинские A, B, C, D, E, F,&1" +
                                "идентификатор 00000000 не разрешен"
                                ,chr(10))
        .
        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).
      end.
    end.
    else do:
      dd = decimal( pard-card ) no-error.
      if ( error-status:error ) OR
          index( pard-card , "." ) > 0 OR
          index( pard-card , chr(44) ) > 0 OR
          index( pard-card , "-" ) > 0 OR
          index( pard-card , "+" ) > 0 then
          do:
          assign
          v-err-mess = substitute("Возможно только цифровое значение номера дисконтной карты клиента").
          run err-mess in this-procedure ( input-output v-err-mess).
          var-entry = "d-card":U.
          return error (if p-silent = yes then v-err-mess else var-entry).
      end.
      run ref/dcardi04.p (
                      input pard-card
                      ,input par-type
                      ,input paremitent-host-code
                      ,input parissue-code
                      ,output v-can-issue              ) no-error .
      if error-status:error then do:
        assign
        v-err-mess = substitute("Ошибка при проверке корректности № карты:&1&2 &4"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                    ).
          run err-mess in this-procedure ( input-output v-err-mess).
          var-entry = "d-card":U.
          return error (if p-silent = yes then v-err-mess else var-entry).
      end.
      if not v-can-issue then do:
        assign
        v-err-mess = substitute("Некорректный номер карты:&1"
                                  , return-value
                                    ).
        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).
      end.
    end.
  end.
end.
_main:
do for buf_dis-card,
       source_dis-card,
       main_dis-card
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  if can-find( FIRST ub.dis-card No-LOCK where
                    ub.dis-card.d-card = pard-card
                       ) then do:
    assign
    v-err-mess = substitute("Уже есть глобальная дисконтная карта&1 с номером &2"
                , (if paremitent-host-code = 0
                  then "":U
                  else substitute(" на фирме &1", paremitent-host-code))
                , pard-card
                ).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  define variable v-param-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable l-zeros AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  'dc-ref':U
      ,input  'l-zeros':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output l-zeros
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      )  .
  delete object v-tth no-error.
  if not l-zeros then do:
  assign
  v-dop-d-card = left-trim(pard-card, "0") .
  DO II = 1  to (19 - length(v-dop-d-card)) + 1:
    if can-find(first ub.dis-card no-lock where
                      ub.dis-card.d-card = v-dop-d-card
                  and ub.dis-card.status_ <> 'удал':U
                      )  then do:
    assign
      v-err-mess = substitute("Уже есть НЕУДАЛЕННАЯ дисконтная карта&1 с номером &2 - совпадает с &3 с точностью до лидирующих нулей"
                , (if paremitent-host-code = 0
                  then "":U
                  else substitute(" на фирме &1", paremitent-host-code))
                  ,v-dop-d-card
                  ,pard-card
                  ).
    run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "d-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    assign
    v-dop-d-card = "0" + v-dop-d-card
    .
  end.
  end.
  assign
  v-first-card = pard-card
  v-first-main-card = pard-card
  .
  if parsourced-card <> "" then do:
    find first source_dis-card exclusive-LOCK WHERE
              source_dis-card.d-card = parsourced-card  No-ERROR.
    if not available source_dis-card
    and not locked(source_dis-card)
    then do:
      assign
      v-err-mess  = substitute("Не найдена карта, к которой перевыпускается текущая карта", parsourced-card).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    if source_dis-card.status_ = 'неисп':U
    or source_dis-card.status_ = 'смкли':U then do:
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 имеет статус &2&3" +
                              "перевыпуск запрещен"
                  , parsourced-card
                  ,source_dis-card.status_
                  ,chr(10)
                  ).
    end.
    if source_dis-card.emitent-host-code <> paremitent-host-code then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 имеет другого эмитента &2"
                  , parsourced-card
                  ,source_dis-card.emitent-host-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    if source_dis-card.is-subsid then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 является дополнительной&2" +
                              "перевыпуск запрещен"
                  , parsourced-card
                  ,chr(10)).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    if NOT (source_dis-card.cli-type = parcli-type AND
            source_dis-card.cli-code = parcli-code) then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 выдана другому клиенту &2&3"
                  , parsourced-card
                  , source_dis-card.cli-type
                  , source_dis-card.cli-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    varcard-num = source_dis-card.card-num.
    if varcard-num = 0 then do:
      assign
      v-err-mess = substitute("Неверный внутренний № (&1) у карты &2, к которой перевыпускается текущая карта"
                  , varcard-num
                  , parsourced-card
                   ).
      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    for each other_dis-card no-lock where
            other_dis-card.card-num = source_dis-card.card-num
       AND  other_dis-card.sourced-card = parsourced-card:
        LEAVE.
    end.
    if available other_dis-card
    and
    other_dis-card.d-card <> pard-card  then do:
      assign
      v-err-mess = substitute("К карте &1 уже перевыпущена другая карта - &2"
                   , parsourced-card
                   , other_dis-card.d-card).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    assign
    v-first-main-card = source_dis-card.first-main-card
    v-first-card = source_dis-card.first-card.
    v-overissue-num = source_dis-card.overissue-num + 1.
  end.
  if paris-subsid <> no then do:
    find first main_dis-card exclusive-LOCK WHERE
              main_dis-card.d-card = parmain-card  No-ERROR.
    if not available main_dis-card
    and not locked(main_dis-card)
    then do:
      assign
      v-err-mess  = substitute("Не найдена ОСНОВНАЯ карта, к которой выпускается текущая ДОПОЛНИТЕЛЬНАЯ карта", parsourced-card).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "main-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    if main_dis-card.status_ = 'неисп':U
    or main_dis-card.status_ = 'смкли':U then do:
      v-err-mess = substitute("Основная карта, к которой перевыпускается текущая Дополнительная карта, - &1 имеет статус &2&3" +
                              "выпуск запрещен"
                  , parmain-card
                  ,main_dis-card.status_
                  ,chr(10)
                  ).
    end.
    if main_dis-card.is-subsid = yes
    or main_dis-card.status_ = 'смкли':U then do:
      v-err-mess = substitute("Основная карта к которой, перевыпускается текущая Дополнительная карта, - &1 сама является Дополнительной&2" +
                              "выпуск запрещен"
                  , parmain-card
                  ,chr(10)
                  ).
    end.
    if main_dis-card.emitent-host-code <> paremitent-host-code then do:
      assign
      v-err-mess = substitute("ОСНОВНАЯ Карта к которой, выпускается текущая карта, - &1 имеет другого эмитента &2"
                  , parmain-card
                  ,main_dis-card.emitent-host-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "main-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    assign
    v-first-main-card = main_dis-card.first-main-card
    v-first-card = main_dis-card.first-card
    v-overissue-num = main_dis-card.overissue-num.
  end.
  if varcard-num = 0 then do:
    run gen-b-code in this-procedure ( input 'dcgb':U, output varcard-num) no-error .
    if error-status:error then do:
      assign
      v-err-mess = substitute("Ошибка при генерации внутреннего № ДК").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "card-num":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
  CREATE buf_dis-card.
  assign
  buf_dis-card.d-card = pard-card
  buf_dis-card.card-num = varcard-num
  .
  if v-import
  and valid-handle(p-hn-handle) then do:
      run discardh_write-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = 'ДОБАВЛЕНИЕ':U
                                                        then integer('1':U)
                                                        else integer('2':U)
                                                       )
                                                ).
  end.
  assign
  buf_dis-card.emitent-host-code = paremitent-host-code
  buf_dis-card.status_ =  (if par-status_ = '':U or par-status_ = ?
                            then 'тек':U
                            else par-status_)
  buf_dis-card.cli-type = parcli-type
  buf_dis-card.cli-code = parcli-code
  buf_dis-card.sourced-card = parsourced-card
  buf_dis-card.type = par-type
  buf_dis-card.d-pcnt = pard-pcnt
  buf_dis-card.cash-d-pcnt = parcash-d-pcnt
  buf_dis-card.category = parcategory
  buf_dis-card.d-pcnt-method = pard-pcnt-method
  buf_dis-card.credit-card = parcredit-card
  buf_dis-card.lim-kr = parlim-kr
  buf_dis-card.issue-code = parissue-code
  buf_dis-card.issue-date = parissue-date
  buf_dis-card.valid-from = parvalid-from
  buf_dis-card.valid-date = parvalid-date
  buf_dis-card.debet-card = pardebet-card
  buf_dis-card.staff-card = parstaff-card
  buf_dis-card.cli-message = parcli-message
  buf_dis-card.mask-card  = parmask-card
  buf_dis-card.main-card  = parmain-card
  buf_dis-card.first-card = v-first-card
  buf_dis-card.first-main-card = v-first-main-card
  buf_dis-card.is-subsid  = paris-subsid
  buf_dis-card.overissue-num  = v-overissue-num
  par-rid = recid( buf_dis-card )
  .
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_send-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = 'ДОБАВЛЕНИЕ':U
                                                        then integer('1':U)
                                                        else integer('2':U)
                                                       )
                                                ).
  end.
  buf_Dis-card.trg-param = (if v-rum
                            then ('no-callnews':U + chr(44) + 'no-hist':U)
                            else '':U).
  release buf_dis-card no-error .
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении записи ДИСКОНТНАЯ КАРТА&1&2&3&4"
                            ,error-status:get-message(1)
                            , chr(10)
                            ,return-value
                            , chr(10)).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo _main, return error (if p-silent = yes then v-err-mess else '':U).
  end.
  if not v-rum then do:
    run str/saledc.p
        (
          input parparentproc
        ,input this-procedure :handle
        ,input ?
        ,input 'one-card-add':U
        ,input ?
        ,input '':U
        ,input 0
        ,input 0
        ,input 0
        ,input g#db-num
        ,input pard-card
        ,input ?
        ,input ?
        ,input ?
        ,input 1
        ,input 1
        ,input yes
        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value .
    end.
  end.
end.
else do:
  FIND FIRST buf_dis-card where
             recid(buf_dis-card) = par-rid No-ERROR.
  if not available buf_dis-card then do:
    assign
    v-err-mess = substitute("Не найдена или недоступна карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    return error '':u.
  end.
  if buf_dis-card-type.d-pcnt-byshop and
    ((buf_dis-card.d-pcnt <> pard-pcnt) OR
      (buf_dis-card.cash-d-pcnt <> parcash-d-pcnt)
     )
    then do:
    assign
    v-err-mess = substitute("Нельзя изменить скидку на карте с дифференциацией скидки по объектам - она задается типом карты").
    run err-mess in this-procedure ( input-output v-err-mess).
    if (buf_dis-card.d-pcnt <> pard-pcnt) then do:
      var-entry = "d-pcnt":U.
    end.
    else do:
      var-entry = "cash-d-pcnt":U.
    end.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.main-card <> parmain-card then do:
    assign
    v-err-mess = substitute("Нельзя изменить основную карту, к которой была выпущена данная дополнительная карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.is-subsid <> paris-subsid then do:
    assign
    v-err-mess = substitute("Нельзя изменить характеристику карты <ОСНОВНАЯ-или-ДОПОЛНИТЕЛЬНАЯ>").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.sourced-card <> parsourced-card then do:
    assign
    v-err-mess = substitute("Нельзя изменить карту, к которой была перевыпущена карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if paremitent-host-code <> 0 AND buf_dis-card.emitent-host-code <> paremitent-host-code then do:
    assign
    v-err-mess = substitute("Нельзя изменить эмитента карты с одной фирмы на другую").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "emitent-host-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if paremitent-host-code = 0 AND buf_dis-card.emitent-host-code <> 0
  and (parcredit-card = yes
       or (if v-curr-r-b = 'base':U
           then (buf_dis-card.saldo-base < ( - 0.001))
           else (buf_dis-card.saldo-rubl < ( - 0.001))
         )
       )
  then do:
    assign
    v-err-mess = substitute( "Нельзя кредитную карту или карту с отрицательным сальдо по фирме &1 сделать глобальной картой"
                 , buf_dis-card.emitent-host-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "emitent-host-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if paremitent-host-code <> 0 AND buf_dis-card.emitent-host-code = 0 then do:
      assign
      v-err-mess = substitute("Нельзя глобальную карту сделать картой по фирме &1", buf_dis-card.emitent-host-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "emitent-host-code":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.status_ = 'удал':U
  and not v-has-right-to-restore
  then do:
    if not  v-can-edit   then do:
      assign
      v-err-mess = substitute("У Вас нет прав на измение статуса удаленной карты!").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "status_":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
  if buf_dis-card.status_ = 'удал':U
  and buf_dis-card.mask-card = yes
  and not program-name(2) begins 'ref/dc-mask2.'
  then do:
    assign
    v-err-mess = substitute("Нельзя восстановить удаленную карту-маску!").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "status_":U.
    return error (if p-silent = ? then v-err-mess else var-entry).
  end.
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_write-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = 'ДОБАВЛЕНИЕ':U
                                                        then integer('1':U)
                                                        else integer('2':U)
                                                       )
                                                ).
  end.
  assign
  buf_dis-card.type = par-type
  buf_dis-card.emitent-host-code = paremitent-host-code
  buf_dis-card.d-pcnt = pard-pcnt
  buf_dis-card.cash-d-pcnt = parcash-d-pcnt
  buf_dis-card.category = parcategory
  buf_dis-card.d-pcnt-method = pard-pcnt-method
  buf_dis-card.credit-card = parcredit-card
  buf_dis-card.lim-kr = parlim-kr
  buf_dis-card.issue-code = parissue-code
  buf_dis-card.issue-date = parissue-date
  buf_dis-card.valid-from = parvalid-from
  buf_dis-card.valid-date = parvalid-date
  buf_dis-card.debet-card = pardebet-card
  buf_dis-card.staff-card = parstaff-card
  buf_dis-card.cli-message = parcli-message
  buf_dis-card.status_ =  (if buf_dis-card.status_ = 'неисп':U
                          or buf_dis-card.status_ = 'смкли':U
                          then buf_dis-card.status_
                          else par-status_)
  old-sourced-card = buf_dis-card.sourced-card
  buf_dis-card.cli-type = (if buf_dis-card.mask-card then parcli-type else buf_dis-card.cli-type)
  buf_dis-card.cli-code = (if buf_dis-card.mask-card then parcli-code else buf_dis-card.cli-code)
  buf_Dis-card.trg-param = (if v-rum
                            then ('no-callnews':U + chr(44) + 'no-hist':U)
                            else '':U)
  .
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_send-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = 'ДОБАВЛЕНИЕ':U
                                                        then integer('1':U)
                                                        else integer('2':U)
                                                       )
                                                ).
  end.
  release buf_dis-card no-error .
  if error-status:error then do:
    assign
    v-err-mess = substitute("Ошибка при сохранении записи ДИСКОНТНАЯ КАРТА&1&2&3&4"
                            ,error-status:get-message(1)
                            , chr(10)
                            ,return-value
                            , chr(10)).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo _main, return error v-err-mess.
  end.
end.
define variable v-chip-num as integer no-undo .
define variable v-corr-date as date no-undo .
define variable v-corr-time as integer no-undo .
define variable v-updated as logical no-undo .
define variable v-updated-chr as character no-undo .
  IF p-update-prop THEN DO:
    FOR EACH tt0-dis-card-property
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      assign
      v-chip-num = 0
      v-corr-date = ?
      v-corr-time = ?
      .
      v-updated = no.
      v-updated-chr = "".
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = pard-card
           and  buf_dis-card-property.host-code = tt0-dis-card-property.host-code
           and  buf_dis-card-property.obj-type = tt0-dis-card-property.obj-type
           and  buf_dis-card-property.obj-code = tt0-dis-card-property.obj-code
           and  buf_dis-card-property.dt-code = tt0-dis-card-property.dt-code
           and  buf_dis-card-property.node-code = tt0-dis-card-property.node-code no-error.
      if not available buf_Dis-card-property then do:
        v-updated = yes.
      end.
      else do:
        buffer-compare
        tt0-dis-card-property
        except card-num main-card first-main-card first-card
        to buf_dis-card-property
        save result in v-updated-chr.
        v-updated = (v-updated-chr <> "").
      end.
      if v-updated then do:
        run discprop-write in this-procedure (
                                              input PARd-card
                                            ,input tt0-dis-card-property.host-code
                                            ,input tt0-dis-card-property.obj-type
                                            ,input tt0-dis-card-property.obj-code
                                            ,input tt0-dis-card-property.dtm-code
                                            ,input tt0-dis-card-property.node-code
                                            ,input tt0-dis-card-property.dt-code
                                            ,input tt0-dis-card-property.sum-id
                                            ,input tt0-dis-card-property.property-value-character
                                            ,input tt0-dis-card-property.property-value-date
                                            ,input tt0-dis-card-property.property-value-decimal
                                            ,input tt0-dis-card-property.property-value-integer
                                            ,input tt0-dis-card-property.property-value-logical
                                            ,input '':U
                                            ,input '':U
                                            ,input-output v-chip-num
                                            ,input-output v-corr-date
                                            ,input-output v-corr-time
                                            )  no-error.
        IF ERROR-STATUS:ERROR THEN DO:
          assign
          v-err-mess = substitute("Ошибка при сохранении свойства дисконтной карты &1 &2 &3 &4:&5:&6&7 &8"
                                  , pard-card
                                  , tt0-dis-card-property.host-code
                                  , (tt0-dis-card-property.obj-type + string(tt0-dis-card-property.obj-code))
                                  , tt0-dis-card-property.dtm-code
                                  , tt0-dis-card-property.node-code
                                  , chr(10)
                                  ,error-status:get-message(1)
                                  ,return-value).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo _main, return error v-err-mess.
        END.
      end.
    END.
    FOR EACH buf_dis-card-property where buf_dis-card-property.d-card = pard-card
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_dis-card-property.dtm-code = 0 then next.
      FIND FIRST tt0-dis-card-property NO-LOCK WHERE
          tt0-dis-card-property.d-card = pard-card
      AND tt0-dis-card-property.host-code = buf_dis-card-property.host-code
      AND tt0-dis-card-property.obj-type = buf_dis-card-property.obj-type
      AND tt0-dis-card-property.obj-code = buf_dis-card-property.obj-code
      AND tt0-dis-card-property.dt-code = buf_dis-card-property.dt-code
      AND tt0-dis-card-property.node-code = buf_dis-card-property.node-code
      NO-ERROR.
      IF NOT AVAILABLE tt0-dis-card-property THEN DO:
          ASSIGN
          v-deleted = NO
          v-chip-num = 0
          v-corr-date = ?
          v-corr-time = ?
          .
          run discprop-delete in this-procedure(
                                                 input PARd-card
                                                ,input buf_dis-card-property.host-code
                                                ,input buf_dis-card-property.OBJ-TYPE
                                                ,input buf_dis-card-property.obj-code
                                                ,input buf_dis-card-property.dtm-code
                                                ,input buf_dis-card-property.node-code
                                                ,input buf_dis-card-property.dt-code
                                                ,input '':U
                                                ,input '':U
                                                ,output v-deleted
                                                ,input-output v-chip-num
                                                ,input-output v-corr-date
                                                ,input-output v-corr-time
                                                ) no-error   .
        IF NOT v-deleted
        or error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении свойства дисконтной карты &1 &2 &3 &4:&5:&6&7 &8"
                                  , pard-card
                                  , buf_dis-card-property.host-code
                                  , (buf_dis-card-property.obj-type + string(buf_dis-card-property.obj-code))
                                  , buf_dis-card-property.dt-code
                                  , buf_dis-card-property.node-code
                                  , chr(10)
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo _main, return error v-err-mess.
        END.
      END.
    END.
END.
if not parmask-card then do:
  if (parsourced-card <> "":U and par-mode = 'ДОБАВЛЕНИЕ':U)
  or (par-mode = 'ИЗМЕНЕНИЕ':U and parsourced-card <> old-sourced-card)
  then do:
    define variable v-sourced-status_ like ub.dis-card.status_ no-undo .
    assign
    v-sourced-status_ = 'удал':U.
    run ref/dcardi02.p (  input parparentproc
                    ,input recid(source_dis-card)
                    ,input p-silent
                    ,input v-has-right-to-restore
                    ,input par-mode2
                    ,input 'dis-card':U
                    ,input pard-card
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output v-sourced-status_) no-error .
    if error-status:error then do:
      assign
      v-err-mess = substitute("Ошибка при сохранении статуса дисконтной карты &1, к которой перевыпускается карта&2&3&4&5"
                              ,source_dis-card.d-card
                              ,error-status:get-message(1)
                              , chr(10)
                              ,return-value
                              , chr(10)).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo _main, return error v-err-mess.
    end.
    FIND FIRST dc-list WHERE
                dc-list.d-card = source_dis-card.d-card No-ERROR.
    IF NOT avail dc-list then do:
      create dc-list.
      assign
      dc-list.d-card = source_dis-card.d-card
      .
    end.
    FIND FIRST dc-list WHERE
                dc-list.d-card = pard-card No-ERROR.
    IF NOT avail dc-list then do:
      create dc-list.
      assign
      dc-list.d-card = pard-card
      .
    end.
    else do:
      find first dcp-list where
                dcp-list.d-card = pard-card
            AND dcp-list.host-code = ub.shop.host-code
            AND dcp-list.obj-type  = 'маг':U
            AND dcp-list.obj-code  = parissue-code no-error .
      if available dcp-list
      then delete dcp-list.
    end.
  end.
END.
define variable v-send-all as logical no-undo .
if not p-silent then do:
  for each dc-list NO-LOCK:
    if not can-find( first dcp-list where
                dcp-list.d-card = dc-list.d-card)  then do:
      assign
      v-send-all = yes.
      leave.
    end.
  end.
 if v-send-all
 then do:
   if valid-handle(p-log-handle) then do:
     run get-title in p-log-handle (
          output v-old-title
                                  ).
     run set-title in p-log-handle (
          input 'Отправка информации по клиентским карта на кассы'
                                 ).
     run str/sendclia.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input(string(g#db-num) + chr(4) +  chr(4) + "no":U + chr(4) + "O":U)
                  ) no-error .
     run set-title in p-log-handle (
          input v-old-title
                                 ).
   end.
   else do:
     run str/diallog.w (
                    input parparentproc
                  , input this-procedure
                  , input 'str/sendclia.p':U
                  , input(string(g#db-num) + chr(4) +  chr(4) + "no":U + chr(4) + "O":U)
                  , input yes
                  , input '':U
                  , input 'Отправка информации по клиентским картам на кассу') no-error .
   end.
  end.
end.
RETURN '':u.
end.
procedure create-dis-card :
define input parameter pard-card like ub.dis-card.d-card no-undo .
define input parameter parcard-num like ub.dis-card.card-num.
define input parameter paremitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter parcli-type like ub.dis-card.cli-type no-undo .
define input parameter parcli-code like ub.dis-card.cli-code no-undo .
define input parameter par-status_ like ub.dis-card.status_ no-undo .
define input parameter parsourced-card like ub.dis-card.sourced-card no-undo .
define output parameter par-rid as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
  do
  on error undo, return error
  :
    CREATE buf_dis-card.
    assign
    buf_dis-card.d-card = pard-card
    buf_dis-card.card-num = varcard-num
    buf_dis-card.emitent-host-code = paremitent-host-code
    buf_dis-card.status_ = (if par-status_ = '':U or par-status_ = ?
                            then 'тек':U
                            else par-status_)
    buf_dis-card.cli-type = parcli-type
    buf_dis-card.cli-code = parcli-code
    buf_dis-card.sourced-card = parsourced-card
    buf_dis-card.main-card  = parmain-card
    buf_dis-card.is-subsid  = paris-subsid
    buf_dis-card.first-card = v-first-card
    buf_dis-card.first-main-card = v-first-main-card
    par-rid = recid( buf_dis-card )
    .
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Карта №&1: эмитент: &2 тип: &3: &4", pard-card, paremitent-host-code, par-type, p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
