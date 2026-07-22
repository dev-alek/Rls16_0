block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable p-curr-obj-type like ub.clients.obj-type no-undo.
define variable p-curr-obj-code like ub.clients.obj-code no-undo.
define variable p-gds-name      like ub.goods.gds-name         no-undo.
define variable p-engl-name     like ub.goods.engl-name         no-undo.
define variable p-label-name    like ub.goods.label-name         no-undo.
define variable p-chk-name      like ub.goods.chk-name         no-undo.
define variable p-alpha1        like ub.goods.alpha1         no-undo.
define variable p-unit-cli      like ub.goods.unit-cli       no-undo.
define variable p-max-rate      like ub.goods.max-rate       no-undo.
define variable p-min-rate      like ub.goods.min-rate       no-undo.
define variable p-cli-base-rate like ub.goods.cli-base-rate       no-undo.
define variable p-qnty-cart     like ub.goods.qnty-cart      no-undo.
define variable p-ms-base       like ub.goods.ms-base        no-undo.
define variable p-wt-base       like ub.goods.wt-base      no-undo.
define variable p-ms-cart       like ub.goods.ms-cart        no-undo.
define variable p-wt-cart       like ub.goods.wt-cart      no-undo.
define variable p-calc-method   like ub.goods.calc-method  no-undo.
define variable p-increase-pc   like ub.goods.increase-pc  no-undo.
define variable p-negative-rest like ub.goods.negative-rest no-undo.
define variable p-okdp          like ub.goods.okdp          no-undo.
define variable p-destin        like ub.goods.destin        no-undo.
define variable p-attrib        like ub.goods.attrib        no-undo.
define variable p-user-rule     like ub.goods.user-rule     no-undo.
define variable p-sert          like ub.goods.sert          no-undo.
define variable p-struct        like ub.goods.struct        no-undo.
define variable p-deadline      like ub.goods.deadline      no-undo.
define variable p-cond-keep-code like ub.goods.cond-keep-code no-undo.
define variable p-sort          like ub.goods.sort          no-undo.
define variable p-proof         like ub.goods.proof         no-undo.
define variable p-normal-wastage  like ub.goods.normal-wastage  no-undo.
define variable p-normal-waste  like ub.goods.normal-waste  no-undo.
define variable p-tnved         like ub.goods.tnved         no-undo.
define variable p-nationality   like ub.goods.nationality   no-undo.
define variable p-unit-cst      like ub.goods.unit-cst      no-undo.
define variable p-cst-base-rate like ub.goods.cst-base-rate no-undo.
define variable p-fbr-grp-code  like ub.goods.fbr-grp-code  no-undo .
define variable p-ps            like ub.goods.ps            no-undo .
define variable p-date          as date                     no-undo .
define variable p-stts          as logical no-undo .
DEFINE VARIABLE var-fact-order like ub.tax-rate-value.fact-order no-undo .
define variable vss-revision    as character no-undo init "$Revision: 151fe727385f, 696, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jul 06 18:00:55 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: goods01r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/goods01r.p $":U .
define variable vss-description as character no-undo init "".
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
define shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
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
  define shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable custvalue      as char no-undo.
define variable custtype       as char no-undo.
define variable v-gds-rec as recid no-undo.
define variable v-nbc like ub.bar-code.b-code no-undo .
define variable v-dop as character no-undo .
define variable v-main-error as logical no-undo .
define variable vnum1 as integer no-undo .
define variable vnum2 as integer no-undo .
define variable v-call-point as character no-undo .
define variable i-line as integer no-undo .
define variable v-call-params as character no-undo .
define variable text-string as character no-undo .
define variable i-artic like ub.goods.artic no-undo .
define variable i-struct like ub.goods.struct no-undo .
define variable i-prod-code like ub.goods.prod-code no-undo .
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable v-stts as integer no-undo .
define stream inp.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_units for ub.units.
define buffer cli-units for ub.units.
define buffer buf_tt-tax for tt-tax.
define variable log-file-name                as character      no-undo init "gdsuform.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-val as character no-undo .
define variable v-do-str  as character no-undo .
define variable v-do      as logical no-undo extent 37.
define variable v-ii      as integer no-undo .
define variable num-rec   as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable glog as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-update-mode as character no-undo .
define variable v-file-name as character no-undo .
define variable v-encoding as character no-undo .
define variable v-found   as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
if num-entries(p-parameter, chr(1)) <> 4 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action9   as character no-undo .
  define variable v-printed9       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action9
    ,output v-printed9
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
end.
assign
v-call-point = entry(1, p-parameter, chr(1))
v-call-params = entry(2, p-parameter, chr(1))
v-val = entry(3, p-parameter, chr(1))
v-do-str = entry(4, p-parameter, chr(1))
.
log-file-name = v-call-point + ".txt".
if lookup(v-call-point, "gdsuform,struct,tnved,alpha1") = 0 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2неверный режим пакетного изменения товара &3"
                         , p-parameter
                         , chr(10)
                         , v-call-point
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action11   as character no-undo .
  define variable v-printed11       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action11
    ,output v-printed11
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
end.
assign
vnum1 = num-entries(v-val, chr(4))
vnum2 = num-entries(v-do-str, chr(4))
.
if vnum1 <> 40
or vnum2 <> 37
then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2неверное количество элементов списка (&3) &4"
                         , p-parameter
                         , chr(10)
                         , (if vnum1 <> 40 then vnum1 else vnum2)
                         , (if vnum1 <> 40 then "значений параметров" else "изменяемых полей")
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action13   as character no-undo .
  define variable v-printed13       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action13
    ,output v-printed13
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
end.
do v-ii = 1 to 37:
  assign
  v-do[v-ii] = logical(entry(v-ii, v-do-str, chr(4)))
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("1Ошибка входных параметров &1:&2&3&4"
                            , p-parameter
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action15   as character no-undo .
  define variable v-printed15       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action15
    ,output v-printed15
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
  end.
end.
assign
p-curr-obj-type = entry(1, v-val, chr(4))
p-curr-obj-code = integer(entry(2, v-val, chr(4)))
var-fact-order  = decimal(entry(3, v-val, chr(4)))
p-gds-name      = entry(4, v-val, chr(4))
p-engl-name     = entry(5, v-val, chr(4))
p-label-name    = entry(6, v-val, chr(4))
p-chk-name      = entry(7, v-val, chr(4))
p-alpha1        = entry(8, v-val, chr(4))
p-unit-cli      = entry(9, v-val, chr(4))
p-max-rate      = decimal(entry(10, v-val, chr(4)))
p-min-rate      = decimal(entry(11, v-val, chr(4)))
p-cli-base-rate = decimal(entry(12, v-val, chr(4)))
p-qnty-cart     = decimal(entry(13, v-val, chr(4)))
p-ms-base       = decimal(entry(14, v-val, chr(4)))
p-wt-base       = decimal(entry(15, v-val, chr(4)))
p-ms-cart       = decimal(entry(16, v-val, chr(4)))
p-wt-cart       = decimal(entry(17, v-val, chr(4)))
p-calc-method   = entry(18, v-val, chr(4))
p-increase-pc   = decimal(entry(19, v-val, chr(4)))
p-negative-rest = if v-do[17] then logical(entry(20, v-val, chr(4))) else no
p-okdp          = entry(21, v-val, chr(4))
p-destin        = entry(22, v-val, chr(4))
p-attrib        = entry(23, v-val, chr(4))
p-user-rule     = entry(24, v-val, chr(4))
p-sert          = entry(25, v-val, chr(4))
p-struct        = entry(26, v-val, chr(4))
p-deadline      = integer(entry(27, v-val, chr(4)))
p-cond-keep-code = integer(entry(28, v-val, chr(4)))
p-sort          = entry(29, v-val, chr(4))
p-proof          = decimal(entry(30, v-val, chr(4)))
p-normal-wastage = decimal(entry(31, v-val, chr(4)))
p-normal-waste   = decimal(entry(32, v-val, chr(4)))
p-tnved          = entry(33, v-val, chr(4))
p-nationality    = entry(34, v-val, chr(4))
p-unit-cst       = entry(35, v-val, chr(4))
p-cst-base-rate  = decimal(entry(36, v-val, chr(4)))
p-fbr-grp-code   = integer(entry(37, v-val, chr(4)))
p-ps             = entry(38, v-val, chr(4))
v-dop            = entry(39, v-val, chr(4))
p-date           =  if v-do[37]
                    then date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                   else ?
p-stts           = if v-do[36] then logical(entry(40, v-val, chr(4))) else no
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action17   as character no-undo .
  define variable v-printed17       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action17
    ,output v-printed17
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
end.
if not (p-curr-obj-type = 'маг':U
or p-curr-obj-type = 'скл':U)
or not
 can-find (first ub.clients no-lock where
                      ub.clients.obj-type = p-curr-obj-type
                 AND  ub.clients.obj-code = p-curr-obj-code )
                 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров p-curr-obj-type &1 p-curr-obj-code &2&3"
                         , p-curr-obj-type
                         , p-curr-obj-code
                         , chr(10)
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action19   as character no-undo .
  define variable v-printed19       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action19
    ,output v-printed19
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-jwlr'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
assign
is-jwlr = (dops = "yes":U) no-error
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-bttl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
assign
is-bttl = (dops = "yes":U) no-error
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
assign
is-ptrl = (dops = "yes":U) no-error
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение товаров")).
CASE v-call-point :
  when "struct":U then do:
    if num-entries(v-call-params, chr(4)) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения состава сырья&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , chr(10)
                              , num-entries(v-call-params, chr(4))
                              )).
        assign
        v-view-log = yes.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action22   as character no-undo .
  define variable v-printed22       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action22
    ,output v-printed22
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
    end.
    assign
    v-update-mode = entry(1, v-call-params, chr(4))
    v-file-name  = entry(2, v-call-params, chr(4))
    v-encoding   = entry(3, v-call-params, chr(4))
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _struct:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 2 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _struct.
      end.
      assign
      i-artic = entry (1, text-string, ";")
      i-struct = entry (2, text-string, ";")
      .
      if num-entries (text-string, ";") > 2 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _struct.
      end.
      v-found = no.
      for each buf_goods WHERE buf_goods.artic = i-artic:
        if buf_goods.struct <> "":U and v-update-mode = 'ДОБАВЛЕНИЕ':U then next.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last23 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last23 = gds-list.order-num .
  end.
  else do:
    v-last23 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last23 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
        assign
        gds-list.struct = i-struct.
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 в БД отсутствует&2Пропускаем"
                                            ,i-artic
                                            ,chr(10))
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end.
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end.
  when "tnved":U then do:
    if num-entries(v-call-params, chr(4)) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения кодов ТНВЭД&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , chr(10)
                              , num-entries(v-call-params, chr(4))
                              )).
        assign
        v-view-log = yes.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action25   as character no-undo .
  define variable v-printed25       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action25
    ,output v-printed25
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
    end.
    assign
    v-update-mode = entry(1, v-call-params, chr(4))
    v-file-name  = entry(2, v-call-params, chr(4))
    v-encoding   = entry(3, v-call-params, chr(4))
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _tnved:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      i-line = i-line + 1.
      i-prod-code = 0.
      assign
      i-artic = entry (1, text-string, ";")
      i-prod-code = integer(entry(2, text-string, ";"))
      i-tnved = entry (3, text-string, ";")
      no-error
      .
      if num-entries (text-string, ";") > 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      if length(i-tnved) <> 10 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Код ТНВЭД &1 - должен быть 10 символов (строка файла # &2)&3Пропускаем"
                                            ,i-tnved
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      v-found = no.
      for each buf_goods WHERE
             buf_goods.artic = i-artic
          and buf_goods.prod-type = 'орг':U
          and buf_goods.prod-code = i-prod-code:
        if buf_goods.tnved <> "":U and v-update-mode = 'ДОБАВЛЕНИЕ':U then next.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last26 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last26 = gds-list.order-num .
  end.
  else do:
    v-last26 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last26 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
        assign
        gds-list.tnved = i-tnved
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 (производитель &2&3 в БД отсутствует&4Пропускаем"
                                            ,i-artic
                                            ,'орг':U
                                            ,i-prod-code
                                            ,chr(10))
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end.
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end.
  when "alpha1":U then do:
    if num-entries(v-call-params, chr(4)) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения страны происхождения товара&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , chr(10)
                              , num-entries(v-call-params, chr(4))
                              )).
        assign
        v-view-log = yes.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action28   as character no-undo .
  define variable v-printed28       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action28
    ,output v-printed28
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
    end.
    if num-entries(v-call-params, chr(4)) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения страны происхождения товара&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , chr(10)
                              , num-entries(v-call-params, chr(4))
                              )).
        assign
        v-view-log = yes.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action30   as character no-undo .
  define variable v-printed30       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'gdsuform.txt')
    ,input  7
    ,output v-user-action30
    ,output v-printed30
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'gdsuform.txt').
end.
                        return.
    end.
    assign
    v-update-mode = entry(1, v-call-params, chr(4))
    v-file-name  = entry(2, v-call-params, chr(4))
    v-encoding   = entry(3, v-call-params, chr(4))
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _alpha1:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      i-prod-code = 0.
      assign
      i-artic = entry (1, text-string, ";")
      i-prod-code = integer(entry(2, text-string, ";"))
      i-alpha1 = entry (3, text-string, ";")
      no-error
      .
      if num-entries (text-string, ";") > 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      if not can-find(first ub.country no-lock where ub.country.alpha1 = i-alpha1) then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Код страны &1 отсутствует в справочнике стран (строка файла # &2)&3Пропускаем"
                                            ,i-alpha1
                                            ,i-line
                                            ,chr(10))
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      v-found = no.
      for each buf_goods WHERE
             buf_goods.artic = i-artic
          and buf_goods.prod-type = 'орг':U
          and buf_goods.prod-code = i-prod-code:
        if (buf_goods.alpha1 <> "":U
           and buf_goods.alpha1 <> "XX":U )
        and v-update-mode = 'ДОБАВЛЕНИЕ':U then next.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last31 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last31 = gds-list.order-num .
  end.
  else do:
    v-last31 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last31 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
        assign
        gds-list.alpha1 = i-alpha1
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 (производитель &2&3 в БД отсутствует&4Пропускаем"
                                            ,i-artic
                                            ,'орг':U
                                            ,i-prod-code
                                            ,chr(10))
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end.
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end.
end case.
num-rec = 0.
if v-do[6] then do:
  FIND FIRST cli-units No-LOCK WHERE
           cli-units.unit-name = p-unit-cli No-ERROR.
end.
_gds-list:
  FOR EACH gds-list NO-LOCK,
      FIRST buf_goods exclusive-lock WHERE
            buf_goods.prod-type = gds-list.prod-type AND
            buf_goods.prod-code = gds-list.prod-code AND
            buf_goods.artic = gds-list.artic,
      FIRST buf_gds-prt no-lock where
            buf_gds-prt.upper-code = buf_goods.prt-root
            on error undo, next:
    num-rec = num-rec + 1.
    FIND FIRST buf_units No-LOCK WHERE
    buf_units.unit-name = buf_goods.unit-base No-ERROR.
    if v-do[6] then do:
        if NOT can-do(buf_units.type, 'топ':U) = can-do(cli-units.type, 'топ':U)
        then next.
    end.
    if buf_goods.unit-base = p-unit-cli
    and p-cli-base-rate <> 1
    and v-do[9] then next.
    assign
    error-status:error = no
    v-main-error = no
    v-gds-rec  = recid(ub.goods)
    .
    IF v-do[37] then do:
      for each buf_tt-tax:
        FIND LAST ub.tax-rate-gds No-LOCK WHERE
                  ub.tax-rate-gds.gds-code = buf_goods.gds-code AND
                  ub.tax-rate-gds.tax-code = buf_tt-tax.tax-code AND
                  ub.tax-rate-gds.host-code = 0 AND
                  ub.tax-rate-gds.obj-type = "":U AND
                  ub.tax-rate-gds.obj-code = 0 AND
                  ub.tax-rate-gds.fact-order <= var-fact-order NO-ERROR.
        assign
        buf_tt-tax.fact-date = p-date
        buf_tt-tax.fact-order = var-fact-order
        buf_tt-tax.tax-rate-gds-rc = (if available ub.tax-rate-gds then recid(ub.tax-rate-gds) else ?)
        .
      end.
    end.
    if buf_goods.gds-type = 'у':U then dO:
      FIND FIRST buf_gds-obj no-lock where
                buf_gds-obj.gds-code = buf_goods.gds-code
            AND buf_gds-obj.obj-type = p-curr-obj-type
            AND buf_gds-obj.obj-code = p-curr-obj-code no-error .
    end.
    CASE v-call-point:
      when "struct":U then do:
        assign
        p-struct = gds-list.struct.
      end.
      when "tnved":U then do:
        assign
        p-tnved = gds-list.tnved.
      end.
      when "alpha1":U then do:
        assign
        p-alpha1 = gds-list.alpha1.
      end.
    END CASE.
     run ref/goods01.p (
    input parparentproc
  , input 'ИЗМЕНЕНИЕ':U
  , input no
  , input 0
  , input no
  , input yes
  , input no
  , input no
  , input no
  , input v-host-code
  , input p-curr-obj-type
  , input p-curr-obj-code
  , input (buf_goods.gds-type = 'т':U)
  , input ?
  , input buf_goods.gds-code
  , input buf_goods.artic
  , input buf_goods.prod-type
  , input buf_goods.prod-code
  , input buf_gds-prt.node-code
  , input buf_goods.grp-code
  , input (if v-do[1] then p-gds-name else  buf_goods.gds-name)
  , input "":U
  , input (if v-do[2] then p-engl-name else  buf_goods.engl-name)
  , input (if v-do[3] then p-label-name else  buf_goods.label-name)
  , input (if v-do[4] then p-chk-name else  buf_goods.chk-name)
  , input (if v-do[5] then p-alpha1 else  buf_goods.alpha1)
  , input buf_goods.unit-base
  , input (if v-do[6] then p-unit-cli else  buf_goods.unit-cli)
  , input (IF v-do[7] AND LOOKUP('2ед':U, buf_units.type) > 0
          then p-max-rate
          else buf_goods.max-rate)
  , input (IF v-do[8] AND LOOKUP('2ед':U, buf_units.type) > 0
          then p-min-rate
          else buf_goods.min-rate)
  , input (IF v-do[9] then p-cli-base-rate else buf_goods.cli-base-rate)
  , input (IF v-do[10] then p-qnty-cart else buf_goods.qnty-cart)
  , input (IF v-do[11]  then p-ms-base else buf_goods.ms-base)
  , input (IF v-do[12]  then p-wt-base else buf_goods.wt-base)
  , input (IF v-do[13] then p-ms-cart else buf_goods.ms-cart)
  , input (IF v-do[14] then p-wt-cart else buf_goods.wt-cart)
  , input (IF v-do[15] then p-calc-method else buf_goods.calc-method)
  , input (IF v-do[16] then p-increase-pc else buf_goods.increase-pc)
  , input (IF v-do[17] then p-negative-rest else buf_goods.negative-rest)
  , input (if buf_goods.gds-type = 'у':U and available buf_gds-obj
           then buf_gds-obj.price-base
           else 0)
  , input (if buf_goods.gds-type = 'у':U and available buf_gds-obj
           then  buf_gds-obj.price-rubl
           else 0)
  , input (IF v-do[18] then p-okdp else buf_goods.okdp)
  , input (IF v-do[19] then p-destin else buf_goods.destin)
  , input (IF v-do[20] then p-attrib else buf_goods.attrib)
  , input (IF v-do[21] then p-user-rule else buf_goods.user-rule)
  , input (IF v-do[22]  then p-sert else buf_goods.sert)
  , input (IF v-do[23] then p-struct else buf_goods.struct)
  , input (IF v-do[24] then p-deadline else buf_goods.deadline)
  , input (IF v-do[25] then p-cond-keep-code else buf_goods.cond-keep-code)
  , input (IF v-do[26] then p-sort else buf_goods.sort)
  , input (IF v-do[27] then p-proof else buf_goods.proof)
  , input (IF v-do[28] then p-normal-wastage else buf_goods.normal-wastage)
  , input (IF v-do[29] then p-normal-waste else buf_goods.normal-waste)
  , input (IF v-do[30]  then p-tnved else buf_goods.tnved)
  , input (IF v-do[31] then p-nationality else buf_goods.nationality)
  , input (IF v-do[32] then p-unit-cst else buf_goods.unit-cst)
  , input (IF v-do[33] then p-cst-base-rate else buf_goods.cst-base-rate)
  , input (if v-do[34] then p-fbr-grp-code else buf_goods.fbr-grp-code)
  , input (IF v-do[35] then p-PS else buf_goods.PS)
    , input no
  , input is-jwlr
  , input is-bttl
  , input is-ptrl
  , input custvalue
  , input no
  , input no
  , input no
  , input 0
  , input-output v-gds-rec
  , output v-nbc
                    ) no-error .
  if error-status:error then do:
    assign
    v-main-error = yes.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка изменения записи товара с кодом &1:&2&3 &4"
                          , gds-list.gds-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          ) ).
    assign
    v-view-log = yes.
  end.
  if not v-main-error then do:
   IF v-do[36] then do:
      v-stts = (if p-stts then 1 else 0).
      run ref/goods02.p (
                       input recid(buf_goods)
                      ,input yes
                      ,input-output v-stts) no-error.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка изменения статуса товара с кодом &1:&2&3 &4"
                              , gds-list.gds-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              ) ).
        assign
        v-view-log = yes.
      end.
    end.
  end.
  IF v-main-error then do:
    message
    substitute("Не удалось изменить товар с кодом &1&2" +
               "&3 &4&5 - &6&2" +
               "Продолжить изменение товаров по списку?"
              ,buf_goods.gds-code
              , chr(10)
              ,buf_goods.artic
              ,buf_goods.prod-type
              ,buf_goods.prod-code)
   view-as alert-box ERROR buttons YES-NO update glog.
   if not glog then do:
     IF num-rec > num-rec-ok then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Из выбранных &1 товаров удалось отредактировать &2"
                              , num-rec
                              , num-rec-ok
                              ) ).
        return.
     end.
   end.
  end.
  else num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _gds-list.
  end.
end.
IF num-rec > num-rec-ok then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&3&4Из выбранных &1 товаров удалось отредактировать &2&4Информация находится в файле &5.txt"
                        , num-rec
                        , num-rec-ok
                        , (if v-stop then "Процесс прерван пользователем" else "":U)
                        , chr(10)
                        , v-call-point
                        ) ).
end.
else do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("&1&2Пакетное изменение по списку товаров прошло"
                            , (if v-stop then "Процесс прерван пользователем" else "":U)
                            , chr(10)
                              ) ).
end.
