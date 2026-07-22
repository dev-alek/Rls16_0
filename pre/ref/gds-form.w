define input parameter parparentproc  as widget-handle no-undo.
define input parameter mode           as character no-undo .
define input parameter p-obj-type     like ub.clients.obj-type no-undo .
define input parameter p-obj-code     like ub.clients.obj-code no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter gds-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-form.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-form.w $":U .
define variable vss-description as character no-undo init "Карточка товара".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tt-goods no-undo like ub.goods.
define new shared temp-table tt-clients no-undo like ub.clients.
  define NEW SHARED temp-table  tt-tax no-undo
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
  define temp-table  output-tax no-undo
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
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrglib_grp no-undo
    field sel           as character
    field full-name     as character
    field out-code      as integer
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field name          as character
    field level         as integer
    field mark          as character
    field obj-type      as character
    field obj-code      as integer
    field global-code   as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index nc is unique obj-type obj-code node-code
    index sl obj-type obj-code sel
    index uc obj-type obj-code upper-code
.
define temp-table temp_fbrglib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field obj-type      as character
    field obj-code      as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index lv obj-type obj-code level
    index it obj-type obj-code is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as integer
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure fbrglib-get-sort-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-obj-type
           and buf_fbr-gds-grp.obj-code  = p-obj-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while true
    on error undo, return error "fbrglib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_fbr-gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_fbr-gds-grp.upper-code
        .
        if buf_fbr-gds-grp.upper-code = 1
        then do:
            leave.
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
procedure fbrglib-get-full-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    if p-node-code = 1
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 1
        .
        do while true
        on error undo, return error "fbrglib-get-full-name: Ошибка составления полного имени группы"
        :
            assign
                p-full-name  = buf_fbr-gds-grp.node-name
                            + (if p-full-name <> "" then chr(47) else "")
                            + p-full-name
                v-upper-code = buf_fbr-gds-grp.upper-code
            .
            if buf_fbr-gds-grp.upper-code = 1
            then do:
                leave.
            end.
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-node-code".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
procedure fbrglib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-obj-type     as character    no-undo.
define input parameter p-obj-code     as integer      no-undo.
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define variable v-node-name     as character      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run fbrglib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "fbrglib-find-grp-by-full-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_fbrglib_found-grp
    :
        delete temp_fbrglib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            assign
                v-node-name = entry( v-counter, p-search-name, chr(2) )
            .
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type   = p-obj-type
                   and buf_fbr-gds-grp.obj-code   = p-obj-code
                   and buf_fbr-gds-grp.upper-code = v-upper-code
                   and buf_fbr-gds-grp.node-name  = v-node-name
            no-error .
            if not available buf_fbr-gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_fbr-gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_fbr-gds-grp.node-name
                    v-upper-code = buf_fbr-gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name = v-full-name + chr(47)
                        temp_fbrglib_found-grp.sort-name = v-sort-name
                        temp_fbrglib_found-grp.node-code = v-upper-code
                        temp_fbrglib_found-grp.level     = v-counter
                        temp_fbrglib_found-grp.obj-type  = p-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-obj-code
                    .
                end.
            end.
        end.
        else do:
            for each buf_fbr-gds-grp no-lock
               where buf_fbr-gds-grp.obj-type   = p-obj-type
                 and buf_fbr-gds-grp.obj-code   = p-obj-code
                 and buf_fbr-gds-grp.upper-code = v-upper-code
                 and buf_fbr-gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_fbr-gds-grp.node-name
                    temp_fbrglib_found-grp.node-code = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.level     = v-level
                    temp_fbrglib_found-grp.obj-type  = p-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-obj-code
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_fbrglib_found-grp
                :
                    delete temp_fbrglib_found-grp.
                end.
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-full-name
    ).
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
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
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-start-obj-type
             and buf_fbr-gds-grp.obj-code   = p-start-obj-code
             and buf_fbr-gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run fbrglib-is-terminal in this-procedure (
                  input buf_fbr-gds-grp.obj-type
                , input buf_fbr-gds-grp.obj-code
                , input buf_fbr-gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.is-terminal = yes
                    temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_fbr-gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                        temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                        temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                        temp_fbrglib_found-grp.is-terminal = no
                        temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-start-obj-code
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
procedure fbrglib-expand-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-start-name as character    no-undo.
define output parameter p-end-name  as character    no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_fbrglib_found-grp     for temp_fbrglib_found-grp.
    run fbrglib-find-grp-by-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-start-name
        , input no
    ) no-error.
    run fbrglib-get-max-substring in this-procedure (
           input p-obj-type
        ,  input p-obj-code
        ,  input length( p-start-name )
        , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_fbrglib_found-grp
             where temp_fbrglib_found-grp.full-name = p-end-name
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                     no-error.
        if available temp_fbrglib_found-grp
        then do:
            find first buf_temp_fbrglib_found-grp
                 where buf_temp_fbrglib_found-grp.full-name begins p-end-name
                   and recid( buf_temp_fbrglib_found-grp ) <> recid( temp_fbrglib_found-grp )
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
            no-error.
            if not available buf_temp_fbrglib_found-grp
            then do:
                run fbrglib-is-terminal in this-procedure (
                      input p-obj-type
                    , input p-obj-code
                    , input temp_fbrglib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-get-max-substring :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_fbrglib_found-grp  where
                   temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
        no-error.
        if not available temp_fbrglib_found-grp
        then do:
            undo, return error "fbrglib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_fbrglib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "fbrglib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_fbrglib_found-grp
                where temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_fbrglib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
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
procedure fbrglib-is-terminal :
do
on error undo, return error "Ошибка процедуры fbrglib-is-terminal"
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-obj-type
           and buf_fbr-gds-grp.obj-code   = p-obj-code
           and buf_fbr-gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
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
procedure fbrglib-have-goods :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-node-code          as integer      no-undo.
define output parameter p-have-fbr-gds-obj  as logical      no-undo.
    define buffer buf_fbr-gds-obj         for ub.fbr-gds-obj.
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type     = p-obj-type
           and buf_fbr-gds-obj.obj-code     = p-obj-code
           and buf_fbr-gds-obj.fbr-grp-code = p-node-code
    no-error .
    if available buf_fbr-gds-obj
    then do:
        assign
            p-have-fbr-gds-obj = yes
        .
    end.
    else do:
        assign
            p-have-fbr-gds-obj = no
        .
    end.
end.
end procedure.
procedure fbrglib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    search-grp:
    for each buf_fbr-gds-grp no-lock
        where buf_fbr-gds-grp.obj-type  = p-start-obj-type
          and buf_fbr-gds-grp.obj-code  = p-start-obj-code
          and buf_fbr-gds-grp.node-code > p-start-code
    :
        if index( buf_fbr-gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_fbr-gds-grp.node-code
                v-found      = yes
            .
            run fbrglib-get-full-name in this-procedure (
                  input p-start-obj-type
                , input p-start-obj-code
                , input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "fbrglib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
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
procedure fbrglib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
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
        run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "fbrglib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-delete-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-deleted   as logical      no-undo.
    define variable v-have-goods    as logical        no-undo.
    define variable v-yesno         as logical        no-undo.
    define variable v-upper-code    as integer        no-undo.
    define variable v-root-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj           for ub.fbr-gds-obj.
    define buffer buf_second_fbr-gds-grp    for ub.fbr-gds-grp.
    run fbrglib-get-root-code in this-procedure (
        output v-root-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            "Корневую группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.upper-code   = p-node-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Не терминальную группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.node-code    = p-node-code
    .
    assign
        v-upper-code = buf_fbr-gds-grp.upper-code
    .
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ).
    if v-have-goods = yes
    then do:
        find first buf_second_fbr-gds-grp no-lock
             where buf_second_fbr-gds-grp.obj-type      = buf_fbr-gds-grp.obj-type
               and buf_second_fbr-gds-grp.obj-code      = buf_fbr-gds-grp.obj-code
               and buf_second_fbr-gds-grp.upper-code    = buf_fbr-gds-grp.upper-code
               and recid( buf_second_fbr-gds-grp )      <> recid( buf_fbr-gds-grp )
        no-error.
        if available buf_second_fbr-gds-grp
        then do:
            message
                "В группе есть товары,"
                skip "которые нельзя перенести в родительскую группу,"
                skip "потому что у родительской группы есть еще одна подгруппа."
                skip(1)
                skip "Перенесите товары в другую группу"
                skip "или удалите все остальные подгруппы родительской группы."
            view-as alert-box error.
            assign
                p-deleted = no
            .
            undo, return.
        end.
        message
            "В группе есть товары."
            skip "После удаления группы"
            skip "все ее товары будут привязаны"
            skip "к ее родительской группе."
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                for each buf_fbr-gds-obj exclusive-lock
                   where buf_fbr-gds-obj.obj-type     = p-obj-type
                     and buf_fbr-gds-obj.obj-code     = p-obj-code
                     and buf_fbr-gds-obj.fbr-grp-code = p-node-code
                on error undo, return error
                :
                    assign
                        buf_fbr-gds-obj.fbr-grp-code = v-upper-code
                    .
                end.
            end.
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error .
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
    else do:
        message
            "Имя группы: " buf_fbr-gds-grp.node-name
            "Код группы: " buf_fbr-gds-grp.node-code
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error.
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-add-grp :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-interface      as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define output parameter p-new-node-code as integer      no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-have-goods    as logical  no-undo.
    define variable v-host-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.upper-code = p-node-code
          AND buf_fbr-gds-grp.obj-type   = p-obj-type
          AND buf_fbr-gds-grp.obj-code   = p-obj-code
          AND buf_fbr-gds-grp.node-name  = p-node-name no-error .
    if available buf_fbr-gds-grp then do:
        if p-node-code <> 1 then do:
          find first buf_fbr-gds-grp no-lock where
                    buf_fbr-gds-grp.node-code = p-node-code
                AND buf_fbr-gds-grp.obj-type   = p-obj-type
                AND buf_fbr-gds-grp.obj-code   = p-obj-code  .
        end.
                message
        "Для объекта" p-obj-type p-obj-code
        "уже есть группа блюд" p-node-name "в подгруппе" (if p-node-code = 1 then "БЛЮДА" else buf_Fbr-gds-grp.node-name)
        view-as alert-box error .
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-gds-grp.
        assign
            buf_fbr-gds-grp.node-code   = next-value( s-gds-grp, ub )
            p-new-node-code             = buf_fbr-gds-grp.node-code
            buf_fbr-gds-grp.upper-code  = p-node-code
            buf_fbr-gds-grp.host-code   = v-host-code
            buf_fbr-gds-grp.obj-type    = p-obj-type
            buf_fbr-gds-grp.obj-code    = p-obj-code
            buf_fbr-gds-grp.node-name    = ""
            buf_fbr-gds-grp.out-code    = 0
        .
        if p-interface then do:
          run ref/fbrggrpd.w (
                input parparentproc
              , input 'ИЗМЕНЕНИЕ':U
              , input p-obj-type
              , input p-obj-code
              , input buf_fbr-gds-grp.node-code
              , input buf_fbr-gds-grp.upper-code
              , input buf_fbr-gds-grp.node-name
              , input buf_fbr-gds-grp.out-code
              , output buf_fbr-gds-grp.node-name
              , output buf_fbr-gds-grp.out-code
              , output p-cancel
          ).
          if p-cancel = yes
          then do:
              delete buf_fbr-gds-grp.
              undo, return.
          end.
        end.
        else do:
          find first bf_fbr-gds-grp no-lock
              where bf_fbr-gds-grp.obj-type   = p-obj-type
                and bf_fbr-gds-grp.obj-code   = p-obj-code
                and bf_fbr-gds-grp.out-code   = p-out-code
          no-error.
          assign
          buf_fbr-gds-grp.node-name    = p-node-name
          buf_fbr-gds-grp.global-code  = p-global-code
          buf_fbr-gds-grp.out-code     = (if available bf_fbr-gds-grp then 0 else p-out-code)
          .
        end.
        if v-have-goods = yes
        then do:
            for each buf_fbr-gds-obj exclusive-lock
               where buf_fbr-gds-obj.obj-type      = p-obj-type
                 and buf_fbr-gds-obj.obj-code      = p-obj-code
                 and buf_fbr-gds-obj.fbr-grp-code  = p-node-code
            on error undo, return error
            :
                assign
                    buf_fbr-gds-obj.fbr-grp-code = p-new-node-code
                .
            end.
        end.
    end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdspoatr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-name in g#attr-lib
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
procedure gdspoatr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-tooltip in g#attr-lib
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
procedure gdspoatr-value :
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-value in g#attr-lib
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
end procedure.
procedure gdspoatr-write :
  define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-write in g#attr-lib
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
end procedure.
procedure gdspoatr-exist :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-exist in g#attr-lib
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
end procedure.
procedure gdspoatr-delete :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-delete in g#attr-lib
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
end procedure.
procedure gdspoatr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdshattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-name in g#attr-lib
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
procedure gdshattr-tooltip :
define input  parameter p-code    as character no-undo .
define output parameter p-tooltip as character no-undo .
define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-tooltip in g#attr-lib
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
procedure gdshattr-value :
define input  parameter p-code as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as int no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-value in g#attr-lib
    (input  p-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-h-value :
define input  parameter p-code as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-h-value in g#attr-lib
    (input  p-code
    ,input  p-host-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-write :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-write in g#attr-lib
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
end procedure.
procedure gdshattr-EXIST :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-exist in g#attr-lib
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
end procedure.
procedure gdshattr-DELETE :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define output parameter p-DELETED  AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-delete in g#attr-lib
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
end procedure.
procedure gdshattr-news :
define input  parameter p-code           as character no-undo .
define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-news in g#attr-lib
      (
       input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-copy :
define input  parameter p-code           as character no-undo .
define output parameter p-copy           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-pers-proc no-undo
field proc-name as character
field vproc-handle as handle
field vparent-handle as handle
field user-name as character
field id as integer
field vpar as character
field rank-to-delete as integer
index pi is unique primary
proc-name
id
index puser
proc-name
user-name
index ppar
proc-name
vpar
index iparent
vparent-handle
proc-name
index iid
id
index ird
rank-to-delete
.
define variable v-per-proc-num as integer no-undo .
procedure perproc-create-proc :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define input  parameter p-proc-handle  as handle no-undo .
define input  parameter p-run        as logical no-undo .
define input  parameter p-parameter as character no-undo .
define input  parameter p-userid as character no-undo .
define input  parameter p-rank-to-delete as integer no-undo .
define output parameter p-id as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-proc-handle as handle no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
define buffer buf0_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    if v-per-proc-num > 200 then return error '>'.
    find first buf0_temp-pers-proc no-lock where
              buf0_temp-pers-proc.proc-name = p-proc-name use-index pi    no-error.
    if not available buf0_temp-pers-proc then do:
      if p-run then do:
        run value(p-proc-name) persistent SET v-proc-handle (input p-parameter) no-error.
        if error-status :error then undo, return error return-value .
      end.
      else v-proc-handle = p-proc-handle.
      find last buf0_temp-pers-proc no-lock use-index iid  no-error.
      create buf_temp-pers-proc.
      assign
      buf_temp-pers-proc.proc-name = p-proc-name
      buf_temp-pers-proc.id = (if not available buf0_temp-pers-proc
                                then  0
                                else buf0_temp-pers-proc.id + 1)
      buf_temp-pers-proc.user-name = p-userid
      buf_temp-pers-proc.vpar      = p-parameter
      buf_temp-pers-proc.vparent-handle = p-parent-handle
      buf_temp-pers-proc.vproc-handle = v-proc-handle
      buf_temp-pers-proc.rank-to-delete = p-rank-to-delete
      p-id = buf_temp-pers-proc.id
      v-per-proc-num = v-per-proc-num + 1
      .
    end.
    else p-id = buf0_temp-pers-proc.id.
  end.
end procedure.
procedure perproc-delete-proc-user :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-user-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.user-name = p-user-name:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-proc-id :
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
        buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-by-rank :
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    for each buf_temp-pers-proc where
    by buf_temp-pers-proc.rank-to-delete:
      APPLY "delete" to buf_temp-pers-proc.vproc-handle.
      delete procedure buf_temp-pers-proc.vproc-handle.
      delete buf_temp-pers-proc.
      v-per-proc-num = v-per-proc-num - 1.
    end.
  end.
end procedure.
procedure perproc-delete-proc-name-id :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-par :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-parameter as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.vpar      = p-parameter:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-from-parent :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     if p-proc-name = "":u then do:
      for each buf_temp-pers-proc where
         buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
     end.
     else do:
      for each buf_temp-pers-proc where
              buf_temp-pers-proc.proc-name = p-proc-name
        AND  buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
    end.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define temp-table temp-goods no-undo like ub.goods
field alc-prod as logical
field alc-mark as logical
field alc-choose-prod as integer.
define variable v-next-prev as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
DEFINE NEW SHARED BUFFER goods for ub.goods.
DEFINE TEMP-TABLE tt0-dis-gds-rule NO-UNDO LIKE ub.dis-gds-rule.
define buffer locked_dis-gds-rule for ub.dis-gds-rule.
DEFINE TEMP-TABLE tt0-gds-obj-attr NO-UNDO LIKE ub.gds-obj-attr.
define buffer locked_gds-obj-attr for ub.gds-obj-attr.
DEFINE TEMP-TABLE tt0-gds-host-attr NO-UNDO LIKE ub.gds-host-attr.
define buffer locked_gds-host-attr for ub.gds-host-attr.
define temp-table tt0-fbr-gds-obj no-undo like ub.fbr-gds-obj.
define buffer locked_fbr-gds-obj for ub.fbr-gds-obj.
define temp-table tt0-s-coeff no-undo like ub.s-coeff.
define buffer locked_s-coeff for ub.s-coeff.
define temp-table tt0-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table ttf-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table ttj-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table tt0-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.
define temp-table ttf-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.
define temp-table ttj-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.
define buffer locked_gds-obj-prop for ub.gds-obj-prop.
define buffer locked_gds-obj-prop-attr for ub.gds-obj-prop-attr.
define temp-table tt0-gds-add-charges no-undo like ub.gds-add-charges.
define buffer locked_gds-add-charges for ub.gds-add-charges.
define temp-table tt0-goods-attr no-undo like ub.goods-attr
field grp as logical
field fdisable as logical
index attr-code-activ fdisable gds-code attr-code
index attr-code                gds-code attr-code.
procedure addGdsGrpAttr:
   define input  parameter i-gds-code as integer no-undo.
   define input  parameter i-grp-code as integer no-undo.
   define variable vi as integer no-undo.
   define buffer buf_gds-grp-obj-attr for gds-grp-obj-attr.
   define buffer tt0-goods-attr for tt0-goods-attr.
   define buffer buf-goods-attr for tt0-goods-attr.
   for each tt0-goods-attr where tt0-goods-attr.grp:
      delete tt0-goods-attr.
   end.
   do vi = 1 to num-entries('alcohol-prod,egais-name,is-gas,ptrl-without-rvs,office-type,mark-type,emrc-type,IS18Plus,loyalty-gift,item-matter-mark,type-method-calc,group-np,fuel-type,is-loyalty-payment,ban-bonus,null-price,fasovka,time-coock,mark,sum-grp-gl,min-zapas,mercur_FGIS,perishable,production-only,15x80,8x50,6x50,calories,protein,fat,carbohydrate,calc-cal-rec,cash-parts,ptrl-as-good,dflt-insalepr,gds-ptrl-densities,gds-CommodityCode,gds-code-AIS,length-of,width-of,height-of,qnty-in-box,weight-box,qnty-on-pallet,weight-of-pallet,image-list,MercUnits,weighed-gds':U):
      find first buf_gds-grp-obj-attr no-lock
         where buf_gds-grp-obj-attr.node-code   = i-grp-code
           and buf_gds-grp-obj-attr.host-code   = 0
           and buf_gds-grp-obj-attr.obj-type    = ""
           and buf_gds-grp-obj-attr.obj-code    = 0
           and buf_gds-grp-obj-attr.attr-code   = entry(vi,'alcohol-prod,egais-name,is-gas,ptrl-without-rvs,office-type,mark-type,emrc-type,IS18Plus,loyalty-gift,item-matter-mark,type-method-calc,group-np,fuel-type,is-loyalty-payment,ban-bonus,null-price,fasovka,time-coock,mark,sum-grp-gl,min-zapas,mercur_FGIS,perishable,production-only,15x80,8x50,6x50,calories,protein,fat,carbohydrate,calc-cal-rec,cash-parts,ptrl-as-good,dflt-insalepr,gds-ptrl-densities,gds-CommodityCode,gds-code-AIS,length-of,width-of,height-of,qnty-in-box,weight-box,qnty-on-pallet,weight-of-pallet,image-list,MercUnits,weighed-gds':U)
      no-error .
      if available buf_gds-grp-obj-attr
      then do:
         find first tt0-goods-attr where tt0-goods-attr.gds-code   = i-gds-code
                                     and tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
                                     and tt0-goods-attr.grp
         no-error.
            create tt0-goods-attr.
         assign
            tt0-goods-attr.gds-code   = i-gds-code
            tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
            tt0-goods-attr.attr-value = buf_gds-grp-obj-attr.attr-value
            tt0-goods-attr.grp        = yes
         .
         tt0-goods-attr.fdisable = can-find (buf-goods-attr where buf-goods-attr.gds-code   eq tt0-goods-attr.gds-code
                                                              and buf-goods-attr.attr-code  eq tt0-goods-attr.attr-code
                                                              and buf-goods-attr.grp        ne yes).
         .
         end.
   end.
end.
define buffer locked_goods-attr for ub.goods-attr.
define buffer locked_goods for ub.goods.
define variable v-cli-alc-producer as character no-undo .
define variable v-attr-type as character no-undo .
define variable ref-list as char no-undo.
define variable g#log as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-base-code like ub.currency.curr-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable v-doc-prt as logical no-undo .
define variable v-flag-dgr-entry as logical no-undo .
define variable v-update-dgr as logical no-undo .
define variable v-found-copy-dgr as logical no-undo .
define variable v-flag-attr-obj-entry as logical no-undo .
define variable v-update-attr-obj as logical no-undo .
define variable v-found-copy-atr-obj as logical no-undo .
define variable v-flag-attr-host-entry as logical no-undo .
define variable v-update-attr-host as logical no-undo .
define variable v-found-copy-atr-host as logical no-undo .
define variable v-flag-fbr-gds-entry as logical no-undo .
define variable v-update-fbr-gds as logical no-undo .
define variable v-found-copy-fbr-gds as logical no-undo .
define variable v-fbr-gds-obj-recid as recid no-undo .
define variable v-fbr-gds-obj-template    as character        no-undo.
define variable v-flag-s-coeff-entry as logical no-undo .
define variable v-update-s-coeff as logical no-undo .
define variable v-found-copy-s-coeff as logical no-undo .
define variable v-update-gds-prop as logical no-undo .
define variable v-update-add-prop as logical no-undo .
define variable v-found-copy-gds-prop as logical no-undo .
define variable v-found-copy-add-prop as logical no-undo .
define variable v-flag-gds-prop-entry as logical no-undo .
define variable v-flag-add-prop-entry as logical no-undo .
define variable v-flag-attr-gbl-entry as logical no-undo .
define variable v-update-attr-gbl as logical no-undo .
define variable v-found-copy-atr-gbl as logical no-undo .
define variable v-gds-prop-recid  as recid no-undo .
define variable v-add-prop-recid  as recid no-undo .
define variable v-attr-obj-par            as integer no-undo .
define variable v-attr-host-par           as integer no-undo .
define variable v-fbr-gds-par             as integer no-undo .
define variable v-s-coeff-par             as integer no-undo .
define variable v-gds-prop-par             as integer no-undo .
define variable v-add-prop-par             as integer no-undo .
define variable v-attr-gbl-par            as integer no-undo .
DEFINE VARIABLE v-gds-attr-type AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-gds-attr-value-old AS character NO-UNDO init "no".
DEFINE VARIABLE v-gds-attr-mark-value-old AS character NO-UNDO init "no".
define variable f-name as char no-undo.
define variable impc as integer no-undo.
define variable impc-saved as integer no-undo.
define variable not-saved as character no-undo.
define variable text-string as char no-undo.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct AS integer NO-UNDO.
define variable p-prod AS integer NO-UNDO.
define variable p-tnved as integer no-undo .
define variable p-attrib as integer no-undo .
define variable p-destin as integer no-undo .
define variable p-sert as integer no-undo .
define variable p-user-rule as integer no-undo .
define variable p-alpha1 as integer no-undo .
define variable p-grp-code as integer no-undo .
define variable p-service as integer no-undo .
define variable p-gds-code like ub.goods.gds-code no-undo .
define variable p-mark as integer  no-undo .
define variable i-artic as char no-undo.
define variable i-prod-type as character no-undo .
define variable i-prod-code as integer no-undo .
define variable i-gds-name as char no-undo.
define variable i-engl-name as char no-undo.
define variable i-SLT-code as integer no-undo.
define variable i-unit-base as char no-undo.
define variable i-VAT-code as integer no-undo.
define variable i-struct as character no-undo.
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-attrib like ub.goods.attrib no-undo .
define variable i-destin like ub.goods.destin no-undo .
define variable i-sert like ub.goods.sert no-undo .
define variable i-user-rule like ub.goods.user-rule no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable i-grp-code like ub.goods.grp-code no-undo .
define variable i-service as logical no-undo .
define variable i-gds-code like ub.goods.gds-code no-undo .
define variable i-mark as integer  no-undo .
define variable copymode as logical.
define variable prev-artic like ub.goods.artic no-undo.
define variable AvtArt      like ub.bar-code.b-code no-undo.
define variable add-another    as logical no-undo.
define variable igoods         as logical no-undo.
define variable inp-avrg-base  as logical no-undo.
define variable inp-avrg-rubl  as logical no-undo.
define variable InpSelf        as logical no-undo.
define variable CostEntered    as logical no-undo.
define variable FirstIter      as logical init TRUE no-undo.
define variable custvalue      as character no-undo.
define variable custtype       as character no-undo.
define variable fbrvalue       as character no-undo.
define variable fbrtype        as character no-undo.
define variable addch-value    as character no-undo.
define variable addtype        as character no-undo.
define variable avrg-rate as decimal init 1 no-undo .
define NEW SHARED stream gds-file.
define variable prev-rec as recid init ? no-undo .
define buffer for-goods for ub.goods.
define buffer for-prodbc for ub.prod-bc.
define buffer bf-tt-tax for tt-tax.
define variable dif-nam1 as logical no-undo init yes.
define variable dif-nam2 as logical no-undo init no.
define variable dif-pdbc as logical no-undo init no.
define variable v-gds-copy as character no-undo init '0,0,0,0,0,0,0':U.
define variable tnvedimp as logical no-undo init no.
define variable unq-artc as logical no-undo init no.
define variable is-prt  as logical no-undo .
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable saved-name like goods.gds-name .
define variable saved-name2 like goods.gds-name .
define new shared var vattaxcd as integer no-undo.
define new shared var slttaxcd as integer no-undo.
define variable conf-par as character no-undo format "X(250)".
define variable par-type as character no-undo format "X(1)".
define variable choice as integer no-undo.
define variable ArtDis as logical no-undo init no.
define variable BarDis as logical no-undo init no.
define variable nbc as integer no-undo.
define variable var-artic-disable like ub.sysconf.artic-disable no-undo.
define variable var-negative-rest like ub.sysconf.negative-rest no-undo.
define variable vArtbar-off as char no-undo init "Отключено".
define variable vArtbar-auto as char no-undo init "Автом. артик".
define variable vArtbar-BarCOde as char no-undo init "Артик=>Бар-код".
define variable one-good as logical no-undo init yes.
define variable dfltggrp AS INTEGER NO-UNDO init -1.
define variable levels as integer no-undo.
define variable gdsfrmfi as char no-undo.
define variable v-dop-inf as char no-undo.
define variable wh as widget-handle extent 4 no-undo.
define variable whb-tnved as widget-handle no-undo.
define variable whb-unit-cst as widget-handle no-undo.
define variable whb-cond-keep-code as widget-handle no-undo.
define variable whl as widget-handle extent 4 no-undo.
define variable wh-tnved-name as widget-handle no-undo.
define variable wh-cond-keep-name as widget-handle no-undo.
define variable whl-tnved-name as widget-handle no-undo.
define variable whl-cond-keep-name as widget-handle no-undo.
define variable wph as logical no-undo .
define variable jj-tnved as integer no-undo.
define variable jj-unit-cst as integer no-undo.
define variable jj-cst-base-rate as integer no-undo.
define variable jj-cond-keep as integer no-undo.
define variable main-code like ub.bar-code.b-code no-undo.
define variable altcd-option as char no-undo.
define variable dopinf-option as char no-undo.
define variable prodbc-option as char no-undo.
define variable p-list as character no-undo .
define variable fbr-grp-code_ like ub.goods.fbr-grp-code no-undo.
DEFINE VARIABLE v-is-alc AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-choose-alc-prod AS CHARACTER NO-UNDO.
DEFINE variable v-alc-type-inner-code as integer no-undo .
define variable v-create-user-db-num  as integer no-undo .
define variable updated as logical no-undo.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
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
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fbr'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output fbrvalue
  ,output fbrtype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output addch-value
  ,output addtype
  ) no-error .
DEFINE BUTTON add-inf
     LABEL "Доп.инф.":L
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-altbc
     LABEL "&Коды"
     SIZE 10 BY 1.
DEFINE BUTTON b-altcd
     LABEL "&Неосн."
     SIZE 10 BY 1.
DEFINE BUTTON b-arch
     LABEL "Ар&хив":L
     SIZE 10 BY 1.
DEFINE BUTTON b-card
     LABEL "Уч&.карт.":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chk
     LABEL "&Чеки  ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 3 BY 1.
DEFINE BUTTON b-file
     LABEL "&Файл":L
     SIZE 10 BY 1.
DEFINE BUTTON b-inf
     LABEL "&Учет":L
     SIZE 10 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL ">&>":L
     SIZE 3 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.
DEFINE BUTTON b-parts
     LABEL "&Партии":L
     SIZE 10 BY 1.
DEFINE BUTTON b-place
     LABEL "Скл.&места":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prodbc
     LABEL "&Дополн.":L
     SIZE 10 BY 1.
DEFINE BUTTON b-price
     LABEL "&Цены":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.
DEFINE BUTTON b-recipe
     LABEL "Ре&цепт"
     SIZE 10 BY 1.
DEFINE BUTTON b-rest
     LABEL "&Остатки":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sert
     LABEL "Серти&ф":L
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-tax
     LABEL "&<<":L
     SIZE 3 BY 4
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-extart
     LABEL "Внеш.Арт":L
     SIZE 10 BY 1.
DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-base"
     size 3 by 0.88.
DEFINE BUTTON r-alpha1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-alpha1"
     size 3 by 0.88.
DEFINE BUTTON r-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-prod"
     size 3 by 0.88.
DEFINE BUTTON r-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     size 3 by 0.88.
DEFINE BUTTON r-fbr-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-fbr-grp"
     size 3 by 0.88.
DEFINE VARIABLE grp-full AS CHARACTER FORMAT "x(83)"
     LABEL "Группа"
     VIEW-AS FILL-IN
     size 85 by 1
     FGCOLOR 4 .
DEFINE VARIABLE country_name AS CHARACTER FORMAT "x(17)"
     LABEL ""
     VIEW-AS FILL-IN
     size 16.25 by 1
     FGCOLOR 4 .
DEFINE VARIABLE f-fbr-grp-name like ub.fbr-gds-grp.node-name FORMAT "X(30)"
     LABEL ""
     VIEW-AS FILL-IN
     size 28.75 by 1
     FGCOLOR 4 .
DEFINE VARIABLE Impmes AS CHARACTER FORMAT "X(12)":U INITIAL " ИМПОРТ"
      VIEW-AS TEXT
     size 15 by 0.67
     BGCOLOR 10 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Infmes AS CHARACTER FORMAT "X(60)":U INITIAL " ТОВАР НЕ СОХРАНЕН В БАЗЕ ДАННЫХ"
      VIEW-AS TEXT
     size 45 by 0.67
     BGCOLOR 10 FGCOLOR 0  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 25.5 by 4.08.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 19.13 by 4.08.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 26.88 by 4.08.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 26 by 4.08.
DEFINE VARIABLE ArtBar AS CHARACTER  FORMAT "X(15)"
     VIEW-AS COMBO-BOX
     LIST-ITEMS ""
     size 18.25 by 1
     BGCOLOR 8 FGCOLOR 0
     NO-UNDO.
DEFINE VARIABLE NegRest AS LOGICAL INITIAL no
     LABEL "Отриц. остатки"
     VIEW-AS TOGGLE-BOX
     size 16.5 by 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE QUERY BR-tt-tax FOR
      tt-tax SCROLLING.
DEFINE BROWSE BR-tt-tax
  QUERY BR-tt-tax DISPLAY
      tt-tax.tax-name
      tt-tax.tax-type
      tt-tax.tax-code
      tt-tax.rate-code COLUMN-LABEL "Ставка"
      tt-tax.rate-value format "->>>,>>9.99"
      tt-tax.fact-date column-LABEL "Включена" format "99/99/9999"
      ENABLE
      tt-tax.rate-code
     WITH NO-ROW-MARKERS separators SIZE 51 BY 4.
DEFINE BUTTON b-copy-name-to-lbl
     LABEL "Назв.->этикетка":L
     size 18 by 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE for-obj-last-base like ub.gds-obj.last-base
     VIEW-AS FILL-IN
     size 16 by 1
     BGCOLOR 15 FGCOLOR 4.
DEFINE VARIABLE for-obj-last-rubl like ub.gds-obj.last-rubl
     VIEW-AS FILL-IN
     size 16 by 1
     BGCOLOR 15 FGCOLOR 4.
DEFINE VARIABLE for-obj-price-base like ub.gds-obj.price-base
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 15 FGCOLOR 4
     FORMAT ">>>,>>>,>>9.9999"
     .
DEFINE VARIABLE for-obj-price-rubl like ub.gds-obj.price-rubl
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 15 FGCOLOR 4
     FORMAT ">>>,>>>,>>9.9999"
     .
DEFINE VARIABLE name-uchet-base as char init "Б.вал.  :"
     VIEW-AS TEXT
     size 10 by 1
     BGCOLOR 8 FGCOLOR 4.
DEFINE VARIABLE name-uchet-rubl as char init "Руб.    :"
     VIEW-AS TEXT
     size 10 by 1
     BGCOLOR 8 FGCOLOR 4.
DEFINE VARIABLE label-increase-pc as char init "Наценка:"
     VIEW-AS TEXT
     size 7.5 by 1
     BGCOLOR 8 FGCOLOR 0.
DEFINE VARIABLE label-min-rate as char FORMAT "X(17)" init
     "Min кол. в штуке" VIEW-AS TEXT
     size 16.25 by 0.88
     BGCOLOR 8 FGCOLOR 0.
DEFINE VARIABLE label-max-rate as char FORMAT "X(17)" init
     "Max кол. в штуке" VIEW-AS TEXT
     size 16.25 by 0.88
     BGCOLOR 8 FGCOLOR 0.
DEFINE BUTTON b-gdsfrmfi
     image file "cmp/b-must.bmp":u
     SIZE 3 BY 2.
DEFINE RECTANGLE RECT-label-name-1
     EDGE-PIXELS 0
     SIZE 0.2 BY 3.0
     BGCOLOR 12 .
DEFINE RECTANGLE RECT-label-name-2
     EDGE-PIXELS 0
     SIZE 0.2 BY 3.0
     BGCOLOR 12 .
def MENU m-altcd
    MENU-ITEM m-altcd-code-current    LABEL "Главный код - существующие неосновные цены"
    MENU-ITEM m-altcd-code-all        LABEL "Главный код - все неосновные коды"
    rule
    MENU-ITEM m-altcd-scl-gds-current LABEL "Товар - признаки - существующие неосновные цены"
    MENU-ITEM m-altcd-scl-gds-all     LABEL "Товар - признаки - все неосновные коды"
    rule
    MENU-ITEM m-altcd-par-gds-current LABEL "Товар - партии - существующие неосновные цены"
    MENU-ITEM m-altcd-par-gds-all     LABEL "Товар - партии - все неосновные коды"
.
def MENU m-dopinf
    MENU-ITEM m-dopinf-1 LABEL "Доп.инфо по карточке товара"  ACCELERATOR "ALT-2"
    MENU-ITEM m-dopinf-2 LABEL "Фото"  ACCELERATOR "ALT-2"
    MENU-ITEM m-dopinf-10 LABEL "Глобальные атрибуты товара"  ACCELERATOR "ALT-3"
    MENU-ITEM m-dopinf-3 LABEL "Атрибуты товара на фирме"  ACCELERATOR "ALT-4"
    MENU-ITEM m-dopinf-4 LABEL "Атрибуты товара на объекте"  ACCELERATOR "ALT-5"
    MENU-ITEM m-dopinf-5 LABEL "Атрибуты товара на объектах фирмы"  ACCELERATOR "ALT-6"
    MENU-ITEM m-dopinf-6 LABEL "Атрибуты товара (РЕСТОРАН) на объекте"  ACCELERATOR "ALT-7"
    MENU-ITEM m-dopinf-7 LABEL "Сезонные коэффициенты для товара в производстве"  ACCELERATOR "ALT-8"
    MENU-ITEM m-dopinf-11 LABEL "Скидки на товар, действующие на объекте"  ACCELERATOR "ALT-9"
    MENU-ITEM m-dopinf-12 LABEL "Скидки на товар, действующие на объектах фирмы"  ACCELERATOR "ALT-f1"
    MENU-ITEM m-dopinf-9 LABEL "Атрибуты товара на объекте для ЗАКАЗОВ"  ACCELERATOR "ALT-f3"
    MENU-ITEM m-dopinff-9 LABEL "Атрибуты товара на фирме   для ЗАКАЗОВ"
    MENU-ITEM m-dopinf-8 LABEL "Индикаторы товара на объекте"  ACCELERATOR "ALT-f2"
    MENU-ITEM m-dopinf-AM LABEL "Ассортиментные матрицы"
    MENU-ITEM m-dopinf-AC LABEL "Дополнительные расходы"
    MENU-ITEM m-dopinf-AU LABEL "Дополнительные единицы измерения"
.
def MENU m-prodbc
    MENU-ITEM m-prodbc-1 LABEL "По главному коду"  ACCELERATOR "ALT-2"
    MENU-ITEM m-prodbc-2 LABEL "По признакам"  ACCELERATOR "ALT-2"
    MENU-ITEM m-prodbc-3 LABEL "По партиям"  ACCELERATOR "ALT-3"
    rule
    MENU-ITEM m-prodbc-4 LABEL "Все по товару"  ACCELERATOR "ALT-4"
.
def MENU m-price
    MENU-ITEM m-price-1 LABEL "Цены"
    MENU-ITEM m-price-2 LABEL "Переоценки"
.
DEFINE FRAME d-gds-form
     b-exit AT ROW 1 COL 1
     b-arch AT ROW 1 COL 11
     b-price AT ROW 1 COL 21
     b-recipe AT ROW 1 COL 31
     b-card AT ROW 1 COL 41
     b-chk AT  ROW 1 COL 51
     b-prt AT ROW 1 COL 61
     b-parts AT ROW 1 COL 71
     b-place AT ROW 1 COL 81
     b-extart AT ROW 1 COL 91
     b-prev at row 2 col 1
     b-next at row 2 col 4
     b-altbc AT ROW 2 COL 11
     b-altcd AT ROW 2 COL 21
     b-prodbc AT ROW 2 COL 31
     b-rest AT ROW 2 COL 41
     b-inf AT ROW 2 COL 51
     b-file AT ROW 2 COL 61
     b-sert AT ROW 2 COL 71
     add-inf AT ROW 2 COL 81
     b-hist AT ROW 2 COL 92
     b-help AT ROW 2 COL 95
     grp-full at row 3.33 col 13 COLON-ALIGNED
     goods.artic at row 4.42 col 13 COLON-ALIGNED FORMAT "X(16)"
          VIEW-AS FILL-IN
          size 19.5 by 1
          BGCOLOR 3 FGCOLOR 15
     ArtBar at row 4.42 col 35.25 NO-LABEL
     ub.bar-code.b-code at row 4.42 col 43 COLON-ALIGNED FORMAT "9999999999"
          VIEW-AS FILL-IN
          size 10.5 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.gds-prt.node-name at row 4.42 col 54 COLON-ALIGNED NO-LABEL FORMAT "X(25)"
          VIEW-AS FILL-IN
          size 43.38 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-type at row 5.5 col 13 COLON-ALIGNED
          LABEL "Произв-ль"
          VIEW-AS FILL-IN
          size 4 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-code at row 5.5 col 17.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          size 11 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-name at row 5.5 col 34.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          size 62.88 by 1
          BGCOLOR 3 FGCOLOR 15
     r-prod at row 5.54 col 31.25
     ub.goods.gds-name at row 6.58 col 13 COLON-ALIGNED
          LABEL "Название" FORMAT "X(112)"
          VIEW-AS FILL-IN
          size 66.38 by 1
          BGCOLOR 3 FGCOLOR 15
     b-copy-name-to-lbl at row 6.58 col 81.38
     ub.goods.engl-name at row 7.63 col 13.13 COLON-ALIGNED
          LABEL "Англ. назв."
          VIEW-AS FILL-IN
          size 51.88 by 0.96
          FGCOLOR 4
     goods.alpha1 at row 7.63 col 73.5 COLON-ALIGNED
          LABEL "Страна"
          VIEW-AS FILL-IN
          size 4.38 by 1
     r-alpha1 at row 7.63 col 79.88
     country_name NO-LABEL at row 7.63 col 82.25
     rect-label-name-1 at row 7.63 col 40.38
     rect-label-name-2 at row 7.63 col 65.38
     goods.label-name at row 8.79 col 13.13 COLON-ALIGNED
          LABEL "Этикетка" FORMAT "X(112)"
          VIEW-AS FILL-IN
          size 84.38 by 0.96
          FGCOLOR 4
     goods.chk-name at row 9.92 col 13.13 COLON-ALIGNED
           LABEL "На  чеке" FORMAT "X(122)"
          VIEW-AS FILL-IN
          size 50.5 by 0.96
          FGCOLOR 4
     goods.okdp at row 9.88 col 70 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     NegRest at row 9.88 col 82.75
     goods.unit-base at row 11.04 col 14.5 COLON-ALIGNED
          LABEL "Учет.ед.изм."
          VIEW-AS FILL-IN
          size 6.5 by 1
     r-base at row 11.04 col 23.25
     goods.unit-cli at row 11.92 col 14.5 COLON-ALIGNED
          LABEL "Ед.  пост-ка"
          VIEW-AS FILL-IN
          size 6.5 by 1
     r-supp at row 11.92 col 23.25
     goods.cli-base-rate
          at row 12.94 col 7.75 COLON-ALIGNED
          LABEL "Коэф."
          FORMAT " >>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.min-rate
          at row 12.04 col 26  COLON-ALIGNED
          NO-LABEL
          FORMAT ">>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.max-rate
          at row 13.92 col 26  COLON-ALIGNED
          NO-LABEL
          FORMAT ">>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.qnty-cart at row 13.96 col 14 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.wt-base at row 11.04 col 59.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.ms-base at row 11.92 col 59.5 COLON-ALIGNED
          LABEL "Объем штуки"
          VIEW-AS FILL-IN
          size 10 by 1
     goods.ms-cart at row 13.96 col 59.5 COLON-ALIGNED
          LABEL "Объем упак-ки"
          VIEW-AS FILL-IN
          size 10 by 1
     goods.wt-cart at row 12.94 col 59.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.calc-method at row 11.42 col 74.75 NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          LIST-ITEMS
          'Учетная':U,'Группа':U,'Учет-резерв':U,'Накладная':U,'Накл-безНДС':U,'Учет-безНДС':U,'Учет+накл':U,'Уч+накл-НДС':U,'Не-считать':U,'НсП':U,'Производит':U,'Произв-НДС':U,'ПорогПр-НДС':U,'ПорогПр+НДС':U
          size 15 by 3.28
     label-increase-pc NO-LABEL
          at row 11.42 col 89.75
     goods.increase-pc format "->>9.99" at row 13.5 col 87.88 COLON-ALIGNED
          NO-LABEL
          VIEW-AS FILL-IN
          size 8.63 by 1
     name-uchet-base  at row 11.42 col 26 COLON-ALIGNED
          BGCOLOR 8 FGCOLOR 4
          NO-LABEL
     for-obj-price-base at row 11.42 col 47.5 COLON-ALIGNED
          LABEL "Учет.цена"
     for-obj-last-base at row 11.42 col 80 COLON-ALIGNED
          LABEL "Посл.прих.цена"
     name-uchet-rubl at row 12.54 col 26 COLON-ALIGNED
          BGCOLOR 8 FGCOLOR 4
          NO-LABEL
     for-obj-price-rubl at row 12.54 col 47.5 COLON-ALIGNED HELP
          ""
          LABEL "Учет.цена"
     for-obj-last-rubl at row 12.54 col 80 COLON-ALIGNED HELP
          ""
          LABEL "Посл.прих.цена"
     b-tax at row 15.17 col 1.13
     BR-tt-tax at row 15.17 col 4.25
.
DEFINE FRAME d-gds-form
     goods.PS at row 16.83 col 56 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          size 43.38 by 2.33
          BGCOLOR 15 FGCOLOR 0
     Impmes AT ROW 2 COL 12 COLON-ALIGNED NO-LABEL
     Infmes at row 19.33 col 10 COLON-ALIGNED NO-LABEL
     RECT-1 at row 10.96 col 1.38
     RECT-2 at row 10.96 col 27.13
     RECT-3 at row 10.96 col 46.25
     RECT-4 at row 10.96 col 73.5
     label-min-rate at row 11.13 col 27.88
     NO-LABEL
     label-max-rate at row 13 col 27.88
     NO-LABEL
     "Прим." VIEW-AS TEXT
          size 5 by 0.75 at row 16 col 56
          BGCOLOR 8 FGCOLOR 0
     "Группа блюд" VIEW-AS TEXT
          size 11.25 by 0.75 at row 15 col 56
          BGCOLOR 8 FGCOLOR 0
    r-fbr-grp at row 15 col 67.25
    f-fbr-grp-name at row 15 col 70.25 NO-LABEL
    b-gdsfrmfi at row 20.5 col 1.13
    SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-widget  no-undo like ub.custom-labels
field wh as widget-handle
field whl as widget-handle
.
PROCEDURE gdsfrmfi-to:
DEFINE INPUT PARAMETER v-gdsfrmfi as char no-undo.
DEFINE INPUT PARAMETER loc-mode as logical no-undo.
DEFINE OUTPUT PARAMETER v-dop-inf as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE VARiable jj as integer no-undo init 1.
define variable startrow as decimal no-undo init 19.5.
define variable startcolumn as decimal no-undo init 5.
define variable col-size as decimal no-undo init 50.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_widget for tt-widget.
IF v-gdsfrmfi = "" then do:
  return.
end.
create widget-pool "gdsfrmfi" persistent no-error.
wph = yes.
if error-status:error then return.
for each buf_widget:
  delete buf_widget.
end.
DO ii = 1 to NUm-ENTRIES(v-gdsfrmfi):
  find first buf_custom-labels no-lock where
          buf_custom-labels.language = "rus"
      and buf_custom-labels.call-type = 'add-fields':U
      and buf_custom-labels.call-point = 'gdsfrmfi':U
      and buf_custom-labels.tbl-name = entry(1, entry(ii, v-gdsfrmfi), ".")
      and buf_custom-labels.fld-name = entry(2, entry(ii, v-gdsfrmfi), ".") no-error .
  if available buf_custom-labels then do:
    create buf_widget.
    buffer-copy buf_custom-labels to buf_widget
    .
    create TEXT buf_widget.whl in widget-pool "gdsfrmfi"
    assign
    frame = frame d-gds-form:handle
    DATA-TYPE = 'character':U
    FORMAT = substitute("X(&1)", length(buf_widget.custom-label))
    screen-value = buf_widget.custom-label
    row = startrow + round(jj / 2, 0)
    column = startcolumn + (if jj mod 2 = 0 then col-size else 1)
    height-chars = 1
    visible = true
    .
    view buf_widget.whl.
    case buf_widget.widget-type:
       when  "fill-in" then do:
          create fill-in buf_widget.wh in widget-pool "gdsfrmfi"
          assign
          frame = frame d-gds-form:handle
          side-label-handle = buf_widget.whl
          DATA-TYPE = buf_widget.fld-data-type
          FORMAT = buf_widget.CUSTOM-FORMAT
          row = startrow + ROUND(jj / 2, 0)
          column = buf_widget.whl:column + buf_widget.whl:width-chars + 1
          height-chars = 1
          width-chars = minimum(buf_widget.widget-width, ((frame d-gds-form:width-chars )) - (buf_widget.whl:column + buf_widget.whl:width-chars + 1))
          sensitive = loc-mode
          visible = true
          tooltip = buf_widget.custom-tooltip
          .
       end.
       when "combo-box" then do:
          create combo-box buf_widget.wh in widget-pool "gdsfrmfi"
          assign
          frame = frame d-gds-form:handle
          side-label-handle = buf_widget.whl
          DATA-TYPE = buf_widget.fld-data-type
          FORMAT = buf_widget.CUSTOM-FORMAT
          row = startrow + ROUND(jj / 2, 0)
          column = buf_widget.whl:column + buf_widget.whl:width-chars + 1
          delimiter = chr(10)
          list-items = buf_widget.widget-list-items
          inner-lines = num-entries(buf_widget.widget-list-items, chr(10))
          subtype = "DROP-DOWN-LIST"
          width-chars = minimum(buf_widget.widget-width, ((frame d-gds-form:width-chars )) - (buf_widget.whl:column + buf_widget.whl:width-chars + 1))
          sensitive = loc-mode
          visible = true
          tooltip = buf_widget.custom-tooltip
          .
       end.
    end case.
    jj = jj + 1.
    release buf_widget.
    if jj = 5 then LEAVE.
  end.
END.
END PROCEDURE.
PROCEDURE gdsfrmfi-description:
define variable v-ok as logical no-undo .
run ref/cstmlabs.w ( input parparentproc
                     ,input 'add-fields':U
                     ,input 'gdsfrmfi':U
                     ,input no
                     ,input 4
                     ,output v-ok
                     ) no-error.
if v-ok then do:
  message
  "Изменения вступят в силу при следующем входе в карточку товара"
  view-as alert-box warning.
end.
END PROCEDURE.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE get-fields:
define buffer buf_widget for tt-widget.
for each buf_widget:
  if buf_widget.tbl-name = 'goods':U then do:
    buf_widget.wh:screen-value = string(buffer temp-goods:buffer-field(buf_widget.fld-name):buffer-value, buf_widget.custom-format).
  end.
end.
END PROCEDURE.
PROCEDURE set-fields:
define buffer buf_widget for tt-widget.
for each buf_widget:
  if buf_widget.tbl-name = 'goods':U then do:
    buffer temp-goods:buffer-field(buf_widget.fld-name):buffer-value = buf_widget.wh:input-value.
  end.
end.
END PROCEDURE.
ASSIGN
       FRAME d-gds-form:SCROLLABLE       = FALSE.
ASSIGN b-altcd:POPUP-MENU IN FRAME d-gds-form = MENU m-altcd:HANDLE.
ASSIGN b-altcd:MENU-MOUSE = 1.
ASSIGN add-inf:POPUP-MENU IN FRAME d-gds-form = MENU m-dopinf:HANDLE.
ASSIGN add-inf:MENU-MOUSE = 1.
ASSIGN b-prodbc:POPUP-MENU IN FRAME d-gds-form = MENU m-prodbc:HANDLE.
ASSIGN b-prodbc:MENU-MOUSE = 1.
ASSIGN b-price:POPUP-MENU IN FRAME d-gds-form = MENU m-price:HANDLE.
ASSIGN b-price:MENU-MOUSE = 1.
ON CHOOSE OF add-inf IN FRAME d-gds-form
DO:
  if dopinf-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if dopinf-option = "" then return no-apply.
 run proc-b-add-inf(input-output dopinf-option) no-error.
 if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF ArtBar IN FRAME d-gds-form
do:
    assign ArtBar .
    if ArtBAr = vArtBar-Auto then do:
        if nbc = 0 then do:
        end.
    end.
    run val-chg-ArtBar.
end.
ON VALUE-CHANGED OF goods.calc-method IN FRAME d-gds-form
do:
  if goods.calc-method:sensitive and goods.calc-method:visible in frame d-gds-form then do:
    CASE input frame d-gds-form goods.calc-method:screen-value:
      when 'Группа':U then do:
        hide
        label-increase-pc
        goods.increase-pc in frame d-gds-form.
      end.
      otherwise do:
        display
        label-increase-pc
        with frame d-gds-form.
        goods.increase-pc:visible in frame d-gds-form = yes.
      end.
    END CASE.
  end.
end.
ON LEAVE OF goods.artic IN FRAME d-gds-form
DO:
    HIDE Infmes in frame d-gds-form.
END.
ON return OF goods.artic IN FRAME d-gds-form
do:
    if input frame d-gds-form goods.artic = "" then
        do:
            message "Артикул не может быть пустым !".
            apply "entry" to goods.artic in frame d-gds-form.
            return no-apply.
        end.
    apply "entry" to ub.clients.obj-code in frame d-gds-form.
    return no-apply.
end.
ON LEAVE OF for-obj-price-base IN FRAME d-gds-form
do:
    if ( input frame d-gds-form for-obj-price-base <= 0 ) OR
       ( input frame d-gds-form for-obj-price-base = ? ) then .
    else do:
      if v-base-code <> 0 then do:
        if NOT InpSelf then do:
          if avrg-rate = 1 then do:
            FIND LAST ub.curr-accnt WHERE
                              ub.curr-accnt.curr-code = v-base-code NO-ERROR.
            avrg-rate = ub.curr-accnt.exch-rate * ub.curr-accnt.exch-scale .
            run ref/avrgrate.w ( input "rubl"
                               , input-output avrg-rate ) .
          end.
          if avrg-rate = 1
            then
          InpSelf = TRUE .
          else do:
            if NOT CostEntered then do:
              DISPLAY
              ( input frame d-gds-form for-obj-price-base ) * avrg-rate
                @ for-obj-price-rubl with frame d-gds-form.
              CostEntered = TRUE .
            end.
            else do:
              g#log = no.
              if  ( input frame d-gds-form for-obj-price-base ) * avrg-rate <>
                  input frame d-gds-form for-obj-price-rubl then do:
                  message "Пересчитать ср.учетную цену в руб.?" view-as alert-box
                  QUESTION buttons YES-NO update g#log.
                  if g#log then
                  DISPLAY
                      ( input frame d-gds-form for-obj-price-base ) * avrg-rate
                              @ for-obj-price-rubl with frame d-gds-form.
              end.
            end.
          end.
        end.
      end.
      else
      DISPLAY
      ( input frame d-gds-form for-obj-price-base )
        @ for-obj-price-rubl with frame d-gds-form.
      apply "entry" to for-obj-price-rubl in frame d-gds-form.
    end.
end.
ON LEAVE OF for-obj-price-rubl IN FRAME d-gds-form
do:
    if ( input frame d-gds-form for-obj-price-rubl <= 0 ) OR
       ( input frame d-gds-form for-obj-price-rubl = ? ) then .
    else do:
    if v-base-code <> 0 then do:
      if NOT InpSelf then do:
        if avrg-rate = 1 then do:
          FIND LAST ub.curr-accnt WHERE
                            ub.curr-accnt.curr-code = v-base-code NO-ERROR.
          avrg-rate = ub.curr-accnt.exch-rate * ub.curr-accnt.exch-scale .
          run ref/avrgrate.w ( input "base"
                             , input-output avrg-rate ) .
        end.
        if avrg-rate = 1
        then
        InpSelf = TRUE .
        else do:
          if NOT CostEntered then do:
            DISPLAY
            ( input frame d-gds-form for-obj-price-rubl ) / avrg-rate
             @ for-obj-price-base with frame d-gds-form.
             CostEntered = TRUE .
          end.
          else do:
            g#log = no.
            if ( input frame d-gds-form for-obj-price-rubl ) / avrg-rate <>
                 input frame d-gds-form for-obj-price-base then do:
              message "Пересчитать ср.учетную цену в вал.?" view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if g#log
                then
              DISPLAY
              ( input frame d-gds-form for-obj-price-rubl ) / avrg-rate
                @ for-obj-price-base with frame d-gds-form.
            end.
          end.
        end.
      end.
    end.
    else
    DISPLAY
    ( input frame d-gds-form for-obj-price-rubl )
      @ for-obj-price-base with frame d-gds-form.
    apply "entry" to for-obj-price-base in frame d-gds-form.
  end.
end.
on choose of MENU-ITEM m-dopinf-1 in menu m-dopinf DO:
  dopinf-option = "dop-inf":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-2 in menu m-dopinf DO:
  dopinf-option = "foto":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-10 in menu m-dopinf DO:
  dopinf-option = "dop-inf-gbl":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-3 in menu m-dopinf DO:
  dopinf-option = "dop-inf-host":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-4 in menu m-dopinf DO:
  dopinf-option = "dop-inf-obj-one":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-5 in menu m-dopinf DO:
  dopinf-option = "dop-inf-obj-cmp":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-6 in menu m-dopinf DO:
  dopinf-option = "dop-inf-fbr-gds-obj":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-7 in menu m-dopinf DO:
  dopinf-option = "dop-inf-s-coeff":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-8 in menu m-dopinf DO:
  dopinf-option = "indicators":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AM in menu m-dopinf DO:
  dopinf-option = "AM":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AC in menu m-dopinf DO:
  dopinf-option = "add-charg":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AU in menu m-dopinf DO:
  dopinf-option = "alt-units":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-9 in menu m-dopinf DO:
  dopinf-option = "orders":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinff-9 in menu m-dopinf DO:
  dopinf-option = "ordersf":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-11 in menu m-dopinf DO:
  dopinf-option = "dop-inf-dgr-one":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-12 in menu m-dopinf DO:
  dopinf-option = "dop-inf-dgr-cmp":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-code-current in menu m-altcd DO:
  altcd-option = "code-current":U.
  run proc-b-altcd(input-output altcd-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-code-all in menu m-altcd DO:
 altcd-option = "code-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-scl-gds-current in menu m-altcd DO:
 altcd-option = "scl-gds-current":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-scl-gds-all in menu m-altcd DO:
 altcd-option = "scl-gds-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-par-gds-current in menu m-altcd DO:
  altcd-option = "par-gds-current":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-altcd-par-gds-all in menu m-altcd DO:
 altcd-option = "par-gds-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-price-1 in menu m-price DO:
  run proc-b-price(input 1) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-price-2 in menu m-price DO:
  run proc-b-price(input 2) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-prodbc-1 in menu m-prodbc DO:
  prodbc-option = "code-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-prodbc-2 in menu m-prodbc DO:
  prodbc-option = "scl-gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-prodbc-3 in menu m-prodbc DO:
  prodbc-option = "par-gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-prodbc-4 in menu m-prodbc DO:
  prodbc-option = "gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.
ON CHOOSE OF b-altcd IN FRAME d-gds-form
DO:
  if altcd-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if altcd-option = "" then return no-apply.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
END.
ON CHOOSE OF b-prodbc IN FRAME d-gds-form
DO:
  if prodbc-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if prodbc-option = "" then return no-apply.
 run proc-b-prodbc(input-output prodbc-option) no-error.
 if error-status:error then return no-apply.
END.
ON CHOOSE OF b-altbc IN FRAME d-gds-form
DO:
  if mode <> 'ДОБАВЛЕНИЕ':U then do:
    gds-rec = recid (goods).
    run ref/alt-bc.w ( input parparentproc
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input main-code ).
  end.
  else do:
    assign
    saved-name2 = saved-name
    one-good = no
    .
    RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
    RUN check-add in this-procedure ( input 1) no-error.
    if error-status:error and NOT return-value = "next" then return no-apply.
    add-another = yes.
    VIEW Infmes in frame d-gds-form.
    DISPLAY Infmes with frame d-gds-form.
    run perproc-delete-from-parent( this-procedure , "").
    apply "go" to frame d-gds-form.
  end.
END.
ON choose OF b-arch IN FRAME d-gds-form
DO:
  if mode = 'ДОБАВЛЕНИЕ':U then  do:
    one-good = no.
        if temp-goods.alc-prod = yes then
do:
  if (input frame d-gds-form ub.goods.ms-base = 0) then
  do:
    message "Введите объем штуки в карточке товара" VIEW-AS ALERT-BOX .
    RETURN NO-APPLY.
  end.
  run clntattr-value in this-procedure ( input clients.obj-type
                                       , input clients.obj-code
                                       , input 'cli-alc-producer':U
                                       , output v-cli-alc-producer
                                       , output v-attr-type
                                       ) .
  if v-cli-alc-producer = "no" then
  do:
    message "Производитель товара не является производителем алкогольной продукции, установите соответствующий атрибут в справочнике клиентов." VIEW-AS ALERT-BOX .
    return no-apply .
  end.
end.
    RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
    RUN check-add in this-procedure ( input 0) no-error.
    if error-status:error and NOT return-value = "next" then return no-apply.
    add-another = yes.
    run ref/add-matr.p ( input parParentProc
                        ,input goods.gds-code) no-error .
      if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка добавления в Ассортиментную матрицу - add-matr.p"
          view-as alert-box error
        .
    VIEW Infmes in frame d-gds-form.
    DISPLAY Infmes with frame d-gds-form.
    run perproc-delete-from-parent( this-procedure , "").
    apply "go" to frame d-gds-form.
  end.
  else do:
    run local-gds_inf.
  end.
end.
ON choose OF b-card IN FRAME d-gds-form
DO:
    if f-name = "" then do:
        run rep/g-gdscrd.p (parParentProc ,
                      goods.artic,
                      goods.prod-type,
                      goods.prod-code,
                      ?,
                      ?,
                      p-obj-type,
                      p-obj-code
                      ) no-error.
        apply "entry" to b-card in frame d-gds-form.
    end.
    else do:
        run next-good no-error.
        if error-status:error then return no-apply.
       if ArtDis then do:
           message "Для импорта требуется, чтобы автоматичекий артикул был выключен.".
           return.
       end.
       RUN next-good-display.
    end.
end.
ON choose OF b-chk IN FRAME d-gds-form  DO:
  run proc-b-chk in this-procedure no-error.
  if error-status:error then do:
    apply "entry" to b-chk in frame d-gds-form.
    return no-apply.
  end.
end.
ON choose OF b-exit IN FRAME d-gds-form
DO:
define variable prod-bc-added as logical init yes.
assign
v-next-prev = ?.
if can-do( 'ИЗМЕНЕНИЕ,ДОБАВЛЕНИЕ':U, mode ) then  do:
  assign
  one-good = yes
  saved-name2 = saved-name.
if temp-goods.alc-prod = yes then
do:
  if temp-goods.alc-choose-prod = 0 then do:
        message "Введите вид алког. продукции в Доп. инфо" VIEW-AS ALERT-BOX .
        RETURN NO-APPLY.
  end.
  if (input frame d-gds-form ub.goods.ms-base = 0) then
  do:
    message "Введите объем штуки в карточке товара" VIEW-AS ALERT-BOX .
    RETURN NO-APPLY.
  end.
  run clntattr-value in this-procedure ( input clients.obj-type
                                       , input clients.obj-code
                                       , input 'cli-alc-producer':U
                                       , output v-cli-alc-producer
                                       , output v-attr-type
                                       ) .
  if v-cli-alc-producer = "no" then
  do:
    message "Производитель товара не является производителем алкогольной продукции, установите соответствующий атрибут в справочнике клиентов." VIEW-AS ALERT-BOX .
    return no-apply .
  end.
end.
  RUN check-add in this-procedure ( input 2)  no-error.
  if error-status:error then
      return no-apply.
  if NOT f-name = "" then dO:
  message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
  ",  сохранено " + string(impc-saved) ) view-as alert-box
  INFORMATION.
  DISABLE
  b-card with frame d-gds-form.
  display "" @ goods.artic with frame d-gds-form.
  end.
end.
if mode = 'ДОБАВЛЕНИЕ':U then DO:
    run ref/add-matr.p ( input parParentProc
                        ,input goods.gds-code) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка добавления в Ассортиментную матрицу - add-matr.p"
      view-as alert-box error
    .
end.
run perproc-delete-from-parent( this-procedure , "").
end.
ON choose OF b-hist IN FRAME d-gds-form
DO:
define variable v-rid-list as character no-undo .
run ref/cgdshist.w (
                  input parparentproc
                , input v-host-code
                , input p-obj-type
                , input p-obj-code
                , input "":U
                , input "one":U
                , input goods.gds-code
                , input ?
                , input ?
                , input ?
                , input ?
                , input "":U
                , input "":U
                , input v-cntxt-db-num
                , input-output v-rid-list  ) no-error .
 apply "entry" to b-hist in frame d-gds-form.
end.
ON choose OF b-file IN FRAME d-gds-form
DO:
  run start-import no-error.
  if error-status:error then return no-apply.
end.
ON choose OF b-inf IN FRAME d-gds-form
DO:
  def buffer for-gds-obj for ub.gds-obj.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if NOT g#log then return no-apply.
  if mode <> 'ДОБАВЛЕНИЕ':U AND NOT available ub.gds-obj then do:
    FIND FIRST for-gds-obj No-LOCK WHERE
               for-gds-obj.host-code = v-host-code AND
               for-gds-obj.artic = ub.goods.artic AND
               for-gds-obj.prod-type = ub.goods.prod-type AND
               for-gds-obj.prod-code = ub.goods.prod-code No-ERROR.
    if not avail for-gds-obj then do:
      if goods.gds-type = 'т':U
        then
      message "Еще не было НИ ОДНОГО прихода" skip
              "данного товара в ТЕКУЩУЮ фирму" skip
              string( "( " + trim( v-host-name ) + " )." , "x(35)" )
      view-as alert-box INFORMATION .
        else
      message "Для данной УСЛУГИ не определены" skip
              "учетные цены в ТЕКУЩЕЙ фирме" skip
              string( "( " + trim( v-host-name ) + " )." , "x(35)" )
      view-as alert-box INFORMATION .
      return no-apply.
    end.
  end.
  if for-obj-price-base:visible then do:
      IF (avail ub.units and lookup('2ед':U, ub.units.type) > 0 ) then
      VIEW
      ub.goods.min-rate
      ub.goods.max-rate
      IN FRAME d-gds-form.
      VIEW
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      ub.goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      IN frame d-gds-form.
    HIDE
    name-uchet-base
    name-uchet-rubl
    for-obj-price-rubl
    for-obj-last-rubl
    for-obj-price-base
    for-obj-last-base
    in frame d-gds-form.
    APPLY "Value-changed" to goods.calc-method in frame d-gds-form.
  end.
  else do:
    IF igoods OR (avail ub.goods and ub.goods.gds-type = 'т':U) then do:
      HIDE
      ub.goods.min-rate
      ub.goods.max-rate
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      ub.goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      in frame d-gds-form.
      DISPLAY
      name-uchet-base
      name-uchet-rubl
      (if avail gds-obj then ub.gds-obj.last-base else 0) @ for-obj-last-base
      (if avail gds-obj then ub.gds-obj.last-rubl else 0) @ for-obj-last-rubl
      (if avail gds-obj then ub.gds-obj.avrg-base else 0) @ for-obj-price-base
      (if avail gds-obj then ub.gds-obj.avrg-rubl else 0 ) @ for-obj-price-rubl
      WITH frame d-gds-form.
      DISABLE
      for-obj-price-base
      for-obj-price-rubl
      for-obj-last-base
      for-obj-last-rubl
      WITH frame d-gds-form.
      APPLY "Value-changed" to ub.goods.calc-method in frame d-gds-form.
    end.
    else do:
      HIDE
      ub.goods.min-rate
      ub.goods.max-rate
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      in frame d-gds-form.
      if mode = 'ИЗМЕНЕНИЕ':U OR MODE = 'ДОБАВЛЕНИЕ':U
        then
      ENABLE
      for-obj-price-base
      for-obj-price-rubl
      WITH frame d-gds-form.
      DISPLAY
      name-uchet-base
      name-uchet-rubl
      (if avail ub.gds-obj then ub.gds-obj.price-base else 0 ) @ for-obj-price-base
      (if avail ub.gds-obj then ub.gds-obj.price-rubl else 0 ) @ for-obj-price-rubl
      WITH frame d-gds-form.
      HIDE
      for-obj-last-base
      for-obj-last-rubl
      IN frame d-gds-form.
      APPLY "Value-changed" to goods.calc-method in frame d-gds-form.
      apply "entry" to for-obj-price-base in frame d-gds-form.
      return no-apply.
    END.
  end.
  apply "entry" to b-inf in frame d-gds-form.
END.
ON choose OF b-parts IN FRAME d-gds-form
DO:
define variable prt-rec as recid no-undo .
define variable glog as logical no-undo .
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
   IF NOT glog THEN DO:
     RETURN no-apply.
   END.
   run str/parts-l.w
     (
      INPUT parparentproc
     ,input p-obj-type
     ,input p-obj-code
     ,input goods.gds-code
     ,input ""
     ,input 'ПРОСМОТР':U
     ,input 'остатки':U
     ,input 'текущий':U
     ,input 'справочник':U
     ,output prt-rec
     ) .
    apply "entry" to b-parts in frame d-gds-form.
END.
ON choose OF b-place IN FRAME d-gds-form
DO:
  define variable rid-list as char no-undo.
  run ref/pl-gdss.w (  input parparentproc
                , input "":U
                , input p-obj-type
                , input p-obj-code
                , input 'ТОВАР':U
                , input recid(goods)
                , input ?
                , output rid-list).
  apply "entry" to b-place in frame d-gds-form.
END.
ON choose OF b-prt IN FRAME d-gds-form
DO:
define variable ref-rec as recid no-undo .
    if mode = 'ДОБАВЛЕНИЕ':U then
        do:
            run ref/gdsprts.w ( input parparentproc
                               ,input yes
                               ,output ref-rec).
            if ref-rec = ? then
                do:
                    apply "entry" to b-prt in frame d-gds-form.
                    return no-apply.
                end.
            FIND ub.gds-prt WHERE recid (ub.gds-prt) = ref-rec.
            DISPLAY ub.gds-prt.node-name with frame d-gds-form.
        end.
    else do:
      if available ub.goods
      then do:
        define variable v-sel-node-code as integer   no-undo .
        run str/prt-ref.w
          (input parparentproc
          ,input  ub.goods.gds-code
          ,input  'ПРОСМОТР':U
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  ""
          ,input  ""
          ,output v-sel-node-code
          ) .
      end.
      apply "entry" to b-prt in frame d-gds-form.
    end.
end.
ON CHOOSE OF b-recipe IN FRAME d-gds-form
DO:
    FIND ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK .
    if can-do( ub.units.type, 'сер':U ) then
        message "Для серийного товара" skip
                        "рецепт задать нельзя !" view-as alert-box INFORMATION .
    else
        do:
            FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
            if can-do( '_Пустая шкала':U, ub.gds-prt.node-name )
            then do:
                run ref/rcp-all.w (
                      input parParentProc
                    , input ( if mode = 'ИЗМЕНЕНИЕ':U then "b-add" else "nb-del,nb-chg" )
                    , input ""
                    , input recid(goods)
                    , input p-obj-type
                    , input p-obj-code
                    , output ref-list
                ).
            end.
            else do:
                message
                    "Рецепт можно определить"
                    skip "только для товара БЕЗ ПРИЗНАКОВ."
                view-as alert-box information .
            end.
        end.
END.
ON choose OF b-rest IN FRAME d-gds-form
DO:
  if mode = 'ПРОСМОТР':U
  then do:
    find ub.gds-prt no-lock
      where ub.gds-prt.upper-code = ub.goods.prt-root
      .
    assign
      gds-rec = recid( ub.goods )
    .
    run rep/gds-objs.w
      (input parparentproc
      ,input ub.goods.artic
      ,input ub.goods.prod-type
      ,input ub.goods.prod-code
      ,input v-host-code
      ,input -1
      ).
    apply "entry" to b-rest in frame d-gds-form.
  end.
  else do:
    RUN check-update-attr IN THIS-PROCEDURE(yes) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    if mode = 'ИЗМЕНЕНИЕ':U and not updated
    then gds-rec = ?.
    else if NOT f-name = "" then do:
        message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
          ",  сохранено " + string(impc-saved) ) view-as alert-box
          INFORMATION.
          display
          "" @ goods.artic
          with frame d-gds-form.
          DISABLE
          b-card
          with frame d-gds-form.
    end.
    run perproc-delete-from-parent( this-procedure , "").
    v-next-prev = ?.
    apply "go" to frame d-gds-form.
  end.
end.
ON choose OF b-sert IN FRAME d-gds-form
DO:
  run proc-b-sert no-error.
  if error-status:error then return no-apply.
end.
ON return OF goods.gds-name IN FRAME d-gds-form
DO:
    if input frame d-gds-form goods.gds-name = "" then
        do:
            message "Название не может быть пустым !".
            apply "entry" to goods.gds-name in frame d-gds-form.
            return no-apply.
        end.
    if input frame d-gds-form goods.unit-base = "" then
        apply "entry" to goods.unit-base in frame d-gds-form.
    else
        if mode = 'ДОБАВЛЕНИЕ':U then
            apply "entry" to b-arch in frame d-gds-form.
        else
            apply "entry" to b-exit in frame d-gds-form.
    return no-apply.
end.
ON LEAVE OF goods.gds-name IN FRAME d-gds-form
DO:
    run copy-name-to-lbl.
END.
ON CHOOSE OF b-copy-name-to-lbl IN FRAME d-gds-form
DO:
    run copy-name-to-lbl.
END.
ON VALUE-CHANGED OF NegRest IN FRAME d-gds-form
do:
    assign NegRest .
end.
ON leave OF ub.clients.obj-code IN FRAME d-gds-form
do:
    FIND ub.clients WHERE ub.clients.obj-type = input frame d-gds-form ub.clients.obj-type
                                and ub.clients.obj-code = input frame d-gds-form ub.clients.obj-code
                                no-lock no-error.
    if available ub.clients then
        DISPLAY ub.clients.obj-name with frame d-gds-form.
    HIDE Infmes in frame d-gds-form.
end.
ON return OF ub.clients.obj-code IN FRAME d-gds-form
do:
  define variable ref-rec as recid no-undo .
  FIND ub.clients WHERE ub.clients.obj-type = input frame d-gds-form ub.clients.obj-type
                              and ub.clients.obj-code = input frame d-gds-form ub.clients.obj-code
                              no-lock no-error.
  if available ub.clients then
      do:
          DISPLAY ub.clients.obj-name with frame d-gds-form.
          apply "entry" to ub.goods.gds-name in frame d-gds-form.
          return no-apply.
      end.
  else  do:
    run ref/cli-all.w ( input parParentProc
                       ,input "b-add,b-sel"
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,output ref-list) .
    if ref-list = "" then do:
      apply "entry" to ub.clients.obj-code in frame d-gds-form.
      return no-apply.
    end.
    ref-rec = integer (ref-list).
    FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
    DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name with frame d-gds-form.
    apply "entry" to ub.goods.gds-name in frame d-gds-form.
    return no-apply.
  end.
end.
ON LEAVE OF clients.obj-type IN FRAME d-gds-form
DO:
    HIDE Infmes in frame d-gds-form.
END.
ON choose OF r-base IN FRAME d-gds-form
do:
define variable ref-rec as recid no-undo .
    run ref/units.w ( input parparentproc
               , input yes
               , output ref-rec ).
    if ref-rec = ? then do:
            apply "entry" to r-base in frame d-gds-form.
            return no-apply.
     end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ goods.unit-base with frame d-gds-form.
    if avail ub.gds-grp then do:
      run ref/dtaxgdss.p (
                    input no
                   ,input ub.goods.unit-base:screen-value
                   ,input  ub.gds-grp.node-code
                   ,input ?
                   ,input ?
                   ,input v-host-code
                   ,input p-obj-type
                   ,input p-obj-code
                    ) no-error.
      if error-status:error then return no-apply.
    end.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return no-apply.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    if input frame d-gds-form goods.unit-cli =
            input frame d-gds-form goods.unit-base then
        do:
            DISPLAY 1 @ goods.cli-base-rate with frame d-gds-form.
            DISABLE goods.cli-base-rate with frame d-gds-form.
        end.
    else
        ENABLE goods.cli-base-rate with frame d-gds-form.
    apply "entry" to goods.unit-cli in frame d-gds-form.
end.
ON LEAVE OF goods.alpha1 IN FRAME d-gds-form
OR ENTER OF goods.alpha1 IN FRAME d-gds-form
DO:
  if not can-FIND( ub.country where ub.country.alpha1 = input frame d-gds-form ub.goods.alpha1 )
  and (ub.goods.alpha1:modified = yes or f-name = '':U)  then
  frame-value = "XX".
  FIND FIRST ub.COUNTRY WHERE ub.COUNTRY.alpha1 = frame-value No-LOCK No-ERROR.
  COUNTRY_name = if avail ub.country then ub.country.short-name else "".
  DISPLAY country_name with FRAME d-gds-form.
END.
ON return OF ub.goods.alpha1 IN FRAME d-gds-form
do:
define variable rid-list as character no-undo .
  if not can-FIND( ub.country where
                            ub.country.alpha1 = input frame d-gds-form goods.alpha1 ) then  do:
            run ref/countris.w ( input parparentproc
                                ,input "b-sel"
                                ,input-output rid-list ).
            if rid-list = '' then
                do:
                    apply "entry" to goods.alpha1 in frame d-gds-form.
                    return no-apply.
                end.
            FIND ub.country WHERE recid (ub.country) = integer(rid-list) NO-LOCK.
            DISPLAY ub.country.alpha1 @ ub.goods.alpha1 with frame d-gds-form.
        end.
    return no-apply.
end.
ON choose OF r-alpha1 IN FRAME d-gds-form
do:
define variable v-rid-list as character no-undo .
define buffer buf_country for ub.country.
find first buf_country no-lock where
         buf_country.alpha1 = (input frame d-gds-form  goods.alpha1) no-error.
if available buf_country then do:
  v-rid-list = string(recid(buf_country)).
end.
    run ref/countris.w (  input parparentproc
                      ,input "b-sel":U
                      ,input-output v-rid-list ).
if v-rid-list = '' then  do:
            apply "entry" to r-alpha1 in frame d-gds-form.
            return no-apply.
        end.
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    DISPLAY ub.country.alpha1 @ ub.goods.alpha1
                    ub.country.short-name @ country_name with frame d-gds-form.
end.
ON choose OF r-prod IN FRAME d-gds-form
do:
define variable ref-rec as recid no-undo .
  run ref/cli-all.w ( input parParentProc
                     ,input "b-add,b-sel"
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output ref-list) .
  if ref-list = "" then do:
    apply "entry" to r-prod in frame d-gds-form.
    return no-apply.
  end.
  ref-rec = integer( ref-list ).
  FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
  DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name with frame d-gds-form.
  apply "entry" to ub.goods.gds-name in frame d-gds-form.
end.
ON choose OF r-supp IN FRAME d-gds-form
do:
define variable ref-rec as recid no-undo .
    run ref/units.w (
                  input parparentproc
                 ,input yes
                 ,output ref-rec).
    if ref-rec = ? then
        do:
            apply "entry" to r-supp in frame d-gds-form.
            return no-apply.
        end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ ub.goods.unit-cli with frame d-gds-form.
    if input frame d-gds-form ub.goods.unit-cli =
            input frame d-gds-form ub.goods.unit-base then
        do:
            DISPLAY 1 @ ub.goods.cli-base-rate with frame d-gds-form.
            DISABLE ub.goods.cli-base-rate with frame d-gds-form.
            apply "entry" to ub.goods.calc-method in frame d-gds-form.
        end.
    else
        do:
            ENABLE ub.goods.cli-base-rate with frame d-gds-form.
            apply "entry" to ub.goods.cli-base-rate in frame d-gds-form.
        end.
end.
ON choose OF r-fbr-grp IN FRAME d-gds-form
do:
define variable v-recid-list as character no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
        buf_fbr-gds-grp.obj-type = "":U
    AND buf_fbr-gds-grp.obj-code = 0
    AND buf_fbr-gds-grp.node-code = fbr-grp-code_ no-error .
    if available buf_fbr-gds-grp then
    assign
    v-recid-list = string(recid(buf_fbr-gds-grp))
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input ("buttons-for-rubr-only" + chr(44) + "b-sel" + chr(44) +  'терм':U)
        , input-output v-recid-list
    ).
    if v-recid-list <> ""
    then do:
        find first buf_fbr-gds-grp no-lock
             where recid( buf_fbr-gds-grp )  = integer( entry( 1, v-recid-list ) )
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            return no-apply.
        end.
        assign
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        .
        display
        f-fbr-grp-name
        with frame d-gds-form.
    end.
end.
ON LEAVE OF goods.unit-base IN FRAME d-gds-form
DO:
    run leave-unit-base(frame-value) no-error.
    if error-status:error then return no-apply.
END.
ON return OF goods.unit-base IN FRAME d-gds-form
do:
define variable ref-rec as recid no-undo .
    if not can-FIND( ub.units where
                     ub.units.unit-name = input frame d-gds-form ub.goods.unit-base ) then do:
        run ref/units.w (
                     input parparentproc
                    ,input yes
                    ,output ref-rec ).
        if ref-rec = ? then
            do:
                apply "entry" to ub.goods.unit-base in frame d-gds-form.
                return no-apply.
            end.
        FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
        DISPLAY ub.units.unit-name @ ub.goods.unit-base with frame d-gds-form.
    end.
    apply "entry" to goods.unit-cli in frame d-gds-form.
    return no-apply.
end.
ON CHOOSE OF b-tax IN FRAME d-gds-form
DO:
 run proc-b-tax no-error.
 if error-status:error then return no-apply.
END.
ON ROW-ENTRY OF BR-tt-tax IN FRAME d-gds-form
DO:
  if mode = 'ИЗМЕНЕНИЕ':U then do :
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_upd-gds-tax':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  goods.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if not g#log then do:
      APPLY "ENTRY" TO goods.PS in frame d-gds-form.
      return no-apply.
    end.
  end.
END.
ON ROW-LEAVE OF BR-tt-tax IN FRAME d-gds-form
DO:
    if
    NOT integer(tt-tax.rate-code:screen-value in browse br-tt-tax) = tt-tax.rate-code OR
    NOT decimal(tt-tax.rate-value:screen-value in browse br-tt-tax) = tt-tax.rate-value OR
    NOT date(tt-tax.fact-date:screen-value in browse br-tt-tax) = tt-tax.fact-date
    then do:
        run row-leave-br-tt-tax(integer(tt-tax.rate-code:screen-value in browse br-tt-tax)) no-error.
        if error-status:error then return no-apply.
    end.
END.
ON RETURN OF tt-tax.rate-code IN BROWSE BR-tt-tax DO:
    define variable rt as recid NO-UNDO.
    define variable tax-rate-rid as char no-undo init "".
    define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
    DEFINE VARIABLE v-today as date no-undo .
    DEFINE VARIABLE v-time as integer no-undo .
    IF AVAIL tt-tax then do:
        if tt-tax.individual then do:
            if tt-tax.rate-code = ? then do:
                message "Ставка налога индивидуальна для каждого товара" skip
                                "и создается автоматически при создании товара!" view-as alert-box
                                WARNING.
                return no-apply.
            end.
            else do:
                message "Нельзя изменять ставку индивидуального налога!" view-as alert-box
                                ERROR.
                return no-apply.
            end.
        end.
        FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = tt-tax.tax-code NO-ERROR.
        if not avail ub.tax then return no-apply.
        FIND FIRST ub.tax-rate NO-LOCK WHERE ub.tax-rate.tax-code = tt-tax.tax-code AND
                                                                       ub.tax-rate.rate-code = tt-tax.rate-code NO-ERROR.
        if not avail ub.tax-rate then return no-apply.
        assign
        rt = recid(ub.tax)
        tax-rate-rid = string(recid(ub.tax-rate))
        .
        run ref/tax-tree.w (
                        input parparentproc
                       ,input "b-seltax-rate":U
                       ,input "ALL-TAX-RATES":U
                       ,input v-host-code
                       ,input p-obj-type
                       ,input p-obj-code
                       ,input rt
                       ,input-output tax-rate-rid) no-error .
        if NOT tax-rate-rid = "" then do:
            FIND FIRST tax-rate NO-LOCK WHERE
                       recid(tax-rate) = integer(tax-rate-rid) NO-ERROR.
            if not avail tax-rate then return no-apply.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  integer(tax-rate-rid)
  ,input  tax-rate.tax-code
  ,input  tax-rate.rate-code
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output taxvalue
  ) no-error .
            if error-status:error or taxvalue = ? then return no-apply.
            if mode = 'ДОБАВЛЕНИЕ':U and not copymode then v-today = 01/01/1990.
            else do:
              run cur-time in this-procedure(output v-today, output v-time).
            end.
            assign
            tt-tax.rate-code:screen-value in browse br-tt-tax = string(tax-rate.rate-code)
            tt-tax.rate-value:screen-value in browse br-tt-tax = string(taxvalue)
            tt-tax.fact-date:screen-value in browse br-tt-tax = string(v-today, "99/99/9999")
            .
         end.
     end.
END.
ON return OF goods.unit-cli IN FRAME d-gds-form
do:
define variable ref-rec as recid no-undo .
    if not can-find( ub.units where
                     ub.units.unit-name = input frame d-gds-form ub.goods.unit-cli ) then do:
        run ref/units.w (
                     input parparentproc
                    ,input yes
                    ,output ref-rec ).
        if ref-rec = ? then do:
          apply "entry" to ub.goods.unit-cli in frame d-gds-form.
          return no-apply.
        end.
        FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
        DISPLAY ub.units.unit-name @ goods.unit-cli with frame d-gds-form.
    end.
    if input frame d-gds-form ub.goods.unit-cli =
           input frame d-gds-form ub.goods.unit-base then
        do:
            DISPLAY 1 @ goods.cli-base-rate with frame d-gds-form.
            DISABLE goods.cli-base-rate with frame d-gds-form.
            apply "entry" to goods.calc-method in frame d-gds-form.
        end.
    else
        do:
            ENABLE goods.cli-base-rate with frame d-gds-form.
            apply "entry" to goods.cli-base-rate in frame d-gds-form.
        end.
    return no-apply.
end.
on leave of goods.qnty-cart in frame d-gds-form
do:
  define variable varlog as logical initial no no-undo.
  if (input frame d-gds-form goods.ms-base <> 0 and input frame d-gds-form goods.ms-base <> ? or
      input frame d-gds-form goods.wt-base <> 0 and input frame d-gds-form goods.wt-base <> ?   ) and
     (input frame d-gds-form goods.ms-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.ms-cart or
      input frame d-gds-form goods.wt-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.wt-cart   )
      then do:
    message "Вы хотите пересчитать вес и объем упаковки, исходя из количества в упаковке и веса и объема штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame d-gds-form goods.ms-base * input frame d-gds-form goods.qnty-cart @ goods.ms-cart
              input frame d-gds-form goods.wt-base * input frame d-gds-form goods.qnty-cart @ goods.wt-cart
      with frame d-gds-form.
    end.
  end.
end.
on leave of goods.ms-base in frame d-gds-form
do:
  define variable varlog as logical initial no no-undo.
  if input frame d-gds-form goods.qnty-cart <> 0 and
     input frame d-gds-form goods.qnty-cart <> ? and
     input frame d-gds-form goods.ms-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.ms-cart
      then do:
    message "Вы хотите пересчитать объем упаковки, исходя из количества в упаковке и объема штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame d-gds-form goods.ms-base * input frame d-gds-form goods.qnty-cart @ goods.ms-cart
      with frame d-gds-form.
    end.
  end.
end.
on leave of goods.wt-base in frame d-gds-form
do:
  define variable varlog as logical initial no no-undo.
  if input frame d-gds-form goods.qnty-cart <> 0 and
     input frame d-gds-form goods.qnty-cart <> ? and
     input frame d-gds-form goods.wt-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.wt-cart
      then do:
    message "Вы хотите пересчитать вес упаковки, исходя из количества в упаковке и веса штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame d-gds-form goods.wt-base * input frame d-gds-form goods.qnty-cart @ goods.wt-cart
      with frame d-gds-form.
    end.
  end.
end.
on leave of goods.ms-cart in frame d-gds-form
do:
  define variable varlog as logical initial no no-undo.
  if input frame d-gds-form goods.qnty-cart <> 0 and
     input frame d-gds-form goods.qnty-cart <> ? and
     input frame d-gds-form goods.ms-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.ms-cart
      then do:
    message "Вы хотите пересчитать объем штуки, исходя из количества в упаковке и объема упаковки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame d-gds-form goods.ms-cart / input frame d-gds-form goods.qnty-cart @ goods.ms-base
      with frame d-gds-form.
    end.
  end.
end.
on leave of goods.wt-cart in frame d-gds-form
do:
  define variable varlog as logical initial no no-undo.
  if input frame d-gds-form goods.qnty-cart <> 0 and
     input frame d-gds-form goods.qnty-cart <> ? and
     input frame d-gds-form goods.wt-base * input frame d-gds-form goods.qnty-cart <> input frame d-gds-form goods.wt-cart
      then do:
    message "Вы хотите пересчитать вес штуки, исходя из количества в упаковке и веса упаковки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame d-gds-form goods.wt-cart / input frame d-gds-form goods.qnty-cart @ goods.wt-base
      with frame d-gds-form.
    end.
  end.
end.
on choose of b-gdsfrmfi in frame d-gds-form do:
  if mode <> 'ПРОСМОТР':U then return no-apply.
  run gdsfrmfi-description in this-procedure .
end.
ON WINDOW-CLOSE OF FRAME d-gds-form
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON END-ERROR OF FRAME d-gds-form
DO:
  RUN check-update-attr IN THIS-PROCEDURE (yes) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run perproc-delete-from-parent( this-procedure , "").
  v-next-prev = ?.
END.
ON CHOOSE OF b-next IN FRAME d-gds-form
DO:
run reposition-goods in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF b-prev IN FRAME d-gds-form
DO:
run reposition-goods in this-procedure
  (input 'prev':U
  ).
END.
on choose of b-extart in frame d-gds-form do:
  run proc-b-extart in this-procedure ( input goods.gds-code ) no-error .
  if error-status :error then do :
    return no-apply.
  end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-gds-form:PARENT eq ?
THEN FRAME d-gds-form:PARENT = ACTIVE-WINDOW.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-gds-form
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
on choose of b-help in frame d-gds-form
do:
  apply "help":u to frame d-gds-form .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-gds-form:width - 0.3
                fh            = frame d-gds-form:first-child
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
ON WINDOW-CLOSE OF FRAME d-gds-form APPLY "END-ERROR":U TO SELF.
if LOOKUP('ДОБАВЛЕНИЕ':U, mode)  > 0 OR LOOKUP('КОПИРОВАНИЕ':U, mode) > 0 then do:
  assign
  igoods = if entry(2, mode) = 'т':U then yes else no
  no-error.
  if error-status:error then do:
    message "Выберите, что добавлять товар или услугу"
    view-as alert-box.
    return.
  end.
  mode = entry(1, mode).
end.
on alt-shift-f6 anywhere do:
  if available ub.goods
  then do:
    run gbl/d-infgds.p
      (input ub.goods.gds-code
      ,input p-obj-type
      ,input p-obj-code
      ) .
  end.
end.
run proc-settings in this-procedure (
input-output var-artic-disable,
input-output var-negative-rest,
input-output unq-artc,
input-output dif-nam1,
input-output dif-nam2,
input-output dif-pdbc,
input-output tnvedimp,
input-output v-gds-copy,
input-output vattaxcd,
input-output slttaxcd,
input-output dfltggrp,
input-output gdsfrmfi
) no-error .
if error-status:error then undo, return error.
for each temp-goods:
  delete temp-goods.
end.
assign
ArtDis = var-artic-disable
ArtBAr:list-items = IF v-cntxt-db-num = 0
then (vArtBar-off + chr(44) + vArtBar-Auto + chr(44) + vArtBar-BarCode)
else (vArtBar-off + chr(44) + vArtBar-Auto)
ArtBar = if Artdis then vArtBar-Auto else vArtBar-off
f-name = ""
add-another = yes
.
if mode = 'КОПИРОВАНИЕ':U then do:
  copymode = yes.
  FIND FIRST for-goods where recid(for-goods) = gds-rec NO-LOCK NO-ERROR.
  if not avail for-goods then return.
  find first temp-goods no-error.
  if not available temp-goods then do:
    create temp-goods.
  end.
  buffer-copy for-goods to temp-goods.
  FIND FIRST clients WHERE
              clients.obj-type = temp-goods.prod-type AND
              clients.obj-code = temp-goods.prod-code NO-LOCK NO-ERROR.
  FIND FIRST gds-obj WHERE
              gds-obj.obj-type = p-obj-type
         AND  gds-obj.obj-code = p-obj-code
         AND  gds-obj.artic = for-goods.artic
         AND  gds-obj.prod-type = for-goods.prod-type
         AND  gds-obj.prod-code = for-goods.prod-code NO-ERROR .
  FIND gds-prt WHERE gds-prt.upper-code = for-goods.prt-root NO-LOCK.
  FIND FIRST ub.bar-code WHERE
        ub.bar-code.gds-code  = for-goods.gds-code AND
        ub.bar-code.node-code = gds-prt.node-code AND
        ub.bar-code.in-code = "" AND
        ub.bar-code.part-code = "" AND
        ub.bar-code.unit-cli = for-goods.unit-base NO-LOCK NO-ERROR.
  IF NOT AVAIL ub.bar-code then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
    view-as alert-box ERROR.
    return error.
  end.
  FIND ub.gds-grp WHERE ub.gds-grp.node-code = for-goods.grp-code NO-LOCK.
  assign
  igoods = IF for-goods.gds-type = 'т':U
            THEN yes
            else no
  mode = 'ДОБАВЛЕНИЕ':U
  saved-name = temp-goods.gds-name.
  run fill-attr-tables in this-procedure ('gds-host-attr':U, mode) no-error.
  run fill-attr-tables in this-procedure ('goods-attr':U, mode) no-error.
  run fill-attr-tables in this-procedure ('fbr-gds-obj':U, mode) no-error .
  run fill-attr-tables in this-procedure ('s-coeff':U, mode) no-error .
  run fill-attr-tables in this-procedure ('gds-obj-attr':U, mode) no-error .
  run fill-attr-tables in this-procedure ('gds-obj-prop':U, mode) no-error.
  run fill-attr-tables in this-procedure ('gds-obj-prop':U + 'obj', mode) no-error.
  run fill-attr-tables in this-procedure ('gds-obj-prop':U + 'firm', mode) no-error.
  run fill-attr-tables in this-procedure ('gds-add-charges':U, mode) no-error.
  run fill-attr-tables in this-procedure ('dis-gds-rule':U, mode) no-error .
end.
if igoods = ? then return.
HIDE Infmes ImpMes in frame d-gds-form.
add-cycle:
do while
add-another
or v-next-prev = '':U
:
  add-another = no.
  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
      if mode = 'ИЗМЕНЕНИЕ':U then do:
        do TRANSACTION
        on error undo MAIN-BLOCK, return error
        on stop undo MAIN-BLOCK, return error:
        FIND first locked_goods Exclusive-lock WHERE recid (locked_goods) = gds-rec.
        find first goods where recid(goods) = recid(locked_goods).
        end.
      end.
      RUN enable-UI in this-procedure no-error.
      if error-status:error then do:
        v-next-prev = ?.
        undo main-block, return error .
      end.
      if wph = no then
      run gdsfrmfi-to  in this-procedure ( input gdsfrmfi
                                          ,input (if mode = 'ПРОСМОТР':U then no else yes)
                                          ,OUTPUT v-dop-inf
                                        )  .
      run get-fields in this-procedure .
      if (mode = 'ДОБАВЛЕНИЕ':U)  then do:
          if ArtDis then do:
          end.
          if index(InfMes, "НЕ СОХРАНЕН") > 0 then
          display prev-artic @ goods.artic with frame d-gds-form.
          else if ArtDIs then
          display  "" @ goods.artic with frame d-gds-form.
          else if f-name = "" then
          display "" @ goods.artic with frame d-gds-form.
      end.
      if available goods then do:
          if mode = 'ПРОСМОТР':U and  (goods.gds-type <> 'т':U) then  apply "choose" to b-inf in frame d-gds-form.
          if addch-value = 'yes' and (goods.gds-type <> 'т':U)
                      then MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = true  .
                      else MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = false .
      end.
      else do:
          if mode = 'ДОБАВЛЕНИЕ':U and igoods = false then  apply "choose" to b-inf in frame d-gds-form.
          if addch-value = 'yes' and igoods = false
                      then MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = true  .
                      else MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = false .
      end.
      IF mImagePh THEN MENU-ITEM m-dopinf-2:sensitive in MENU m-dopinf = true .
      ELSE MENU-ITEM m-dopinf-2:sensitive in MENU m-dopinf = false .
      case mode :
          when 'ДОБАВЛЕНИЕ':U then
              if f-name = "" then
                  do:
                      if ArtDis then
                          WAIT-FOR GO OF FRAME d-gds-form focus clients.obj-code.
                      else
                          WAIT-FOR GO OF FRAME d-gds-form focus goods.artic.
                  end.
              else
                  WAIT-FOR GO OF FRAME d-gds-form focus b-arch.
          when 'ИЗМЕНЕНИЕ':U then
              WAIT-FOR GO OF FRAME d-gds-form focus goods.gds-name.
          when 'ПРОСМОТР':U then
              if gds-prt.node-name = '_Пустая шкала':U then
                  WAIT-FOR GO OF FRAME d-gds-form focus b-exit.
              else
                  WAIT-FOR GO OF FRAME d-gds-form focus b-prt.
      end case.
  END.
  release goods.
end.
delete widget-pool "gdsfrmfi" no-error.
RUN disable_UI.
input stream gds-file close.
PROCEDURE check-add :
define input parameter pmode as integer no-undo.
DEFINE VARIABLE v-prev-rec as recid no-undo .
define variable choice-str as character no-undo .
define variable v-loc-update-dgr as logical no-undo .
define variable v-loc-update-attr-obj as logical no-undo .
define variable v-loc-update-attr-host as logical no-undo .
define variable v-loc-update-attr-gbl as logical no-undo .
define variable v-loc-update-fbr-gds as logical no-undo .
define variable v-loc-update-s-coeff as logical no-undo .
define variable v-loc-update-gds-prop as logical no-undo .
define variable v-loc-update-add-prop as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_bar-code for ub.bar-code .
run set-fields.
assign
prev-artic = input frame d-gds-form goods.artic
NegRest
.
if NOT available ub.gds-prt then do:
  FIND first ub.gds-prt WHERE
            ub.gds-prt.node-name = '_Пустая шкала':U NO-LOCK.
end.
if NOT ub.gds-prt.root then do:
  message
  "Шкала выбрана неправильно !"
  view-as alert-box error .
  return error.
end.
if input frame d-gds-form ub.goods.unit-base = input frame d-gds-form ub.goods.unit-cli then do:
  DISPLAY 1 @ ub.goods.cli-base-rate with frame d-gds-form.
  DISABLE ub.goods.cli-base-rate with frame d-gds-form.
end.
else do:
  ENABLE goods.cli-base-rate with frame d-gds-form.
end.
assign
v-prev-rec = gds-rec
gds-rec = if mode = 'ИЗМЕНЕНИЕ':U
          then recid(goods)
          else ?
.
choice-str = "yes".
if copymode and v-found-copy-atr-obj then v-update-attr-obj = yes.
if copymode and v-found-copy-atr-host then v-update-attr-host = yes.
if copymode and v-found-copy-atr-gbl then v-update-attr-gbl = yes.
if copymode and v-found-copy-fbr-gds then v-update-fbr-gds = yes.
if copymode and v-found-copy-s-coeff then v-update-s-coeff = yes.
if copymode and v-found-copy-gds-prop then v-update-gds-prop = yes.
if copymode and v-found-copy-add-prop then v-update-add-prop = yes.
if mode <> 'ДОБАВЛЕНИЕ':U then do:
  RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
end.
assign
v-loc-update-attr-obj = v-update-attr-obj
v-loc-update-attr-host = v-update-attr-host
v-loc-update-attr-gbl = v-update-attr-gbl
v-loc-update-fbr-gds = v-update-fbr-gds
v-loc-update-s-coeff = v-update-s-coeff
v-loc-update-gds-prop = v-update-gds-prop
v-loc-update-add-prop = v-update-add-prop
v-loc-update-dgr = v-update-dgr
.
if v-update-attr-obj
or v-update-attr-host
or v-update-attr-gbl
or v-update-fbr-gds
or v-update-s-coeff
or v-update-gds-prop
or v-update-add-prop
or v-update-dgr
then do:
  v-mess =    (
                       (if v-update-attr-gbl
                       then "Были изменены глобальные атрибуты товара"
                       else "":U) + chr(10) +
                      (if v-found-copy-atr-host then " или наследуются глобальыне атрибуты товара" else "":U) + chr(10) +
                       (if v-update-attr-host
                       then "Были изменены атрибуты товара на фирме"
                       else "":U) + chr(10) +
                      (if v-found-copy-atr-host then " или наследуются атрибуты товара на фирме" else "":U) + chr(10) +
                       (if v-update-attr-obj
                       then "Были изменены атрибуты товара на объекте"
                       else "":U) + chr(10) +
                       (if v-found-copy-atr-obj then " или наследуются атрибуты товара на объекте" else "":U) + chr(10) +
                       (if v-update-fbr-gds
                       then "Были изменены атрибуты РЕСТОРАН товара на объекте"
                       else "":U) + chr(10) +
                       (if v-found-copy-fbr-gds then " или наследуются атрибуты РЕСТОРАН товара на объекте" else "":U) + chr(10) +
                       (if v-update-s-coeff
                       then "Были изменены сезонные коэффициенты товара"
                       else "":U) + chr(10) +
                       (if v-found-copy-s-coeff then " или наследуются сезонные коэффициенты товара" else "":U) + chr(10) +
                       (if v-update-gds-prop
                       then "Были изменены индикаторы/атрибуты для заказа товара"
                       else "":U) + chr(10) +
                       (if v-found-copy-gds-prop then " или наследуются индикаторы/атрибуты для заказа товара" else "":U) + chr(10) +
                       (if v-update-add-prop
                       then "Были изменены Дополнительные расходы"
                       else "":U) + chr(10) +
                       (if v-found-copy-add-prop then " или наследуются Дополнительные расходы" else "":U) + chr(10)
                     ).
  v-mess = left-trim(v-mess, chr(10)).
  run gbl/d-toggle.w (
                       input "Сохранение изменений"
                      ,input v-mess
                      ,input "|"
                      ,input substitute("Товар^disable|" +
                                      "Глобальные атрибуты&1|" +
                                      "Атрибуты на фирме&2|" +
                                      "Атрибуты на объекте&3|" +
                                      "Атрибуты РЕСТОРАН&4|" +
                                      "Сезонные коэффициенты&5|" +
                                      "Скидки товара на объекте&6|" +
                                      "Индикаторы товара&7|" +
                                      "Дополнительные расходы&8"
                                      , (if v-update-attr-gbl then "":U else "^disable":U)
                                      , (if v-update-attr-host then "":U else "^disable":U)
                                      , (if v-update-attr-obj then "":U else "^disable":U)
                                      , (if v-update-fbr-gds then "":U else "^disable":U)
                                      , (if v-update-s-coeff then "":U else "^disable":U)
                                      , (if v-update-dgr then "":U else "^disable":U)
                                      , (if v-update-gds-prop then "":U else "^disable":U)
                                      , (if v-update-add-prop then "":U else "^disable":U)
                              )
                      ,input ("Сохранить изменения собственно товара|" +
                              "Сохранить изменения глобальных атрибутов товара|" +
                              "Сохранить изменения атрибутов товара на фирме|" +
                              "Сохранить изменения атрибутов товара на объекте|" +
                              "Сохранить изменения атрибутов РЕСТОРАН товара на объекте|" +
                              "Сохранить изменения сезонных коэффициентов|" +
                              "Сохранить изменения скидок на товар на объекте|" +
                              "Сохранить изменения индикаторов/атрибутов для заказа товара|" +
                              "Сохранить изменения дополнительных расходов"
                              )
                      ,input substitute("&1|&2|&3|&4|&5|&6|&7|&8|&9"
                                        , yes
                                        , v-update-attr-gbl
                                        , v-update-attr-host
                                        , v-update-attr-obj
                                        , v-update-fbr-gds
                                        , v-update-s-coeff
                                        , v-update-dgr
                                        , v-update-gds-prop
                                        , v-update-add-prop
                                      )
                      ,output choice-str) no-error .
  if choice-str = "":U then undo, return error .
  if not logical(entry(2, choice-str, "|":U))
  then v-loc-update-attr-gbl = no.
  if not logical(entry(3, choice-str, "|":U))
  then v-loc-update-attr-host = no.
  if not logical(entry(4, choice-str, "|":U))
  then v-loc-update-attr-obj = no.
  if not logical(entry(5, choice-str, "|":U))
  then v-loc-update-fbr-gds = no.
  if not logical(entry(6, choice-str, "|":U))
  then v-loc-update-s-coeff = no.
  if not logical(entry(7, choice-str, "|":U))
  then v-loc-update-dgr = no.
  if not logical(entry(8, choice-str, "|":U))
  then v-loc-update-gds-prop = no.
  if not logical(entry(9, choice-str, "|":U))
  then v-loc-update-add-prop = no.
end.
_main:
do transaction
on error undo, return error return-value
:
if logical(entry(1, choice-str, "|":U)) then do:
  run ref/goods01.p (
                input parparentproc
                ,input mode
                ,input copymode
                ,input pmode
                ,input yes
                ,input no
                ,input no
                ,input (f-name <> "":U)
                ,input one-good
                ,input v-host-code
                ,input p-obj-type
                ,input p-obj-code
                ,input igoods
                ,input (if copymode then recid(for-goods) else ?)
                ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                ,input frame d-gds-form goods.artic
                ,input frame d-gds-form ub.clients.obj-type
                ,input frame d-gds-form ub.clients.obj-code
                ,input gds-prt.node-code
                ,input (if avail ub.gds-grp then ub.gds-grp.node-code else -1)
                ,input frame d-gds-form ub.goods.gds-name
                ,input saved-name
                ,input frame d-gds-form ub.goods.engl-name
                ,input frame d-gds-form ub.goods.label-name
                ,input frame d-gds-form ub.goods.chk-name
                ,(if not avail ub.country
                  then "XX":U
                  else input frame d-gds-form ub.goods.alpha1
                )
                ,input frame d-gds-form ub.goods.unit-base
                ,input frame d-gds-form ub.goods.unit-cli
                ,INPUT FRAME d-gds-form ub.goods.max-rate
                ,INPUT FRAME d-gds-form ub.goods.min-rate
                ,INPUT FRAME d-gds-form ub.goods.cli-base-rate
                ,input frame d-gds-form ub.goods.qnty-cart
                ,input frame d-gds-form ub.goods.ms-base
                ,input frame d-gds-form ub.goods.wt-base
                ,input frame d-gds-form ub.goods.ms-cart
                ,input frame d-gds-form ub.goods.wt-cart
                ,input frame d-gds-form goods.calc-method
                ,input frame d-gds-form goods.increase-pc
                ,input NegRest
                ,input frame d-gds-form for-obj-price-base
                ,input frame d-gds-form for-obj-price-rubl
                ,input frame d-gds-form goods.okdp
                ,input temp-goods.destin
                ,input temp-goods.attrib
                ,input temp-goods.user-rule
                ,input temp-goods.sert
                ,input temp-goods.struct
                ,input temp-goods.deadline
                ,input temp-goods.cond-keep-code
                ,input temp-goods.sort
                ,input temp-goods.proof
                ,input temp-goods.normal-wastage
                ,input temp-goods.normal-waste
                ,input temp-goods.tnved
                ,input temp-goods.nationality
                ,input temp-goods.unit-cst
                ,input temp-goods.cst-base-rate
                ,input temp-goods.fbr-grp-code
                ,input frame d-gds-form goods.PS
                ,input unq-artc
                ,input is-jwlr
                ,input is-bttl
                ,input is-ptrl
                ,input custvalue
                ,input dif-nam1
                ,input dif-nam2
                ,input ArtDis
                ,input (if BarDis then 1 else 0)
                ,input-output gds-rec
                ,output nbc
                ) no-error .
  if error-status:error then do:
    assign
    gds-rec = if v-prev-rec <> ? and gds-rec = ?
              then v-prev-rec
              else gds-rec
    .
    CASE entry(1, return-value, chr(4)):
      when "unit-cli" then do:
        APPLY "ENTRY" to goods.unit-cli in frame d-gds-form.
        undo _main, return error .
      end.
      when "min-rate":U then do:
        APPLY "ENTRY" to goods.min-rate in frame d-gds-form.
        undo _main, return error .
      end.
      when "max-rate":U then do:
        APPLY "ENTRY" to goods.max-rate in frame d-gds-form.
        undo _main, return error .
      end.
      when "artic|prod-type|prod-code":U then do:
        if f-name = "" then do:
          not-saved = input frame d-gds-form goods.artic.
          Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
          undo _main, return error.
        end.
        else do:
          run gbl/d-askw.w (input "Внимание  !!",
                        input "Товар с таким артикулом и производителем УЖЕ есть в справочнике !",
                        input "|",
                        input "Перейти к СЛЕДУЮЩЕМУ|ВЫЙТИ из режима ИМПОРТА",
                        input "|",
                        input 1,
                        input 2,
                        output choice).
          if choice = 1 then g#log = YES.
          else g#log = no.
          case g#log:
            when YES then
            g#log = NOT g#log.
            when NO then
            g#log = ?.
          end case.
          if NOT g#log then do:
            not-saved = input frame d-gds-form goods.artic.
            Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
            VIEW Infmes in frame d-gds-form.
            DISPLAY Infmes with frame d-gds-form.
          end.
          else  not-saved = "".
          if NOT g#log or g#log = ? then
          undo _main, return error (if not g#log then "next" else "").
        end.
      END.
      when "artic|unq-artc":U then do:
        if NOT f-name = "" then do:
          g#log = NO.
          return error "next".
        end.
        undo _main, return error.
      end.
      when "artic":U then do:
        not-saved = input frame d-gds-form goods.artic.
        Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
        undo _main, return error.
      end.
      when "artic|next":U then do:
        not-saved = input frame d-gds-form goods.artic.
        Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
        VIEW Infmes in frame d-gds-form.
        DISPLAY Infmes with frame d-gds-form.
        undo _main, return error "next":U.
      end.
      when "artic|quit":U then do:
        not-saved = "".
        return error "":U.
      end.
      otherwise do:
        undo _main, return error.
      end.
    END CASE.
  end.
end.
if mode = 'ДОБАВЛЕНИЕ':U then do:
find first goods share-lock where recid(goods) = gds-rec .
  if not AVAILABLE goods then return no-apply.
  else do:
     if not v-loc-update-attr-gbl then
     do:
        message "Не задан атрибут Признак предмета расчета!"
           view-as alert-box.
        undo _main, return error .
     end.
     else
     do:
        find first tt0-goods-attr no-lock where tt0-goods-attr.attr-code = 'item-matter-mark':U no-error .
        if not available (tt0-goods-attr) then
        do:
           message "Не задан атрибут Признак предмета расчета!"
              view-as alert-box.
           undo _main, return error .
        end.
     end.
    if temp-goods.alc-prod = yes then
    do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT 'alcohol-prod':U
        ,INPUT temp-goods.alc-prod ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , 'alcohol-prod':U
                                    , chr(10)
                                    ,error-status:get-message(1)
                                    ,return-value).
        undo _main, return error v-err-mess.
      END.
      if temp-goods.alc-mark = yes then do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT 'mark':U
        ,INPUT temp-goods.alc-mark ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , 'mark':U
                                    , chr(10)
                                    ,error-status:get-message(1)
                                    ,return-value).
        undo _main, return error v-err-mess.
      END.
      end.
        find first ub.alc-type-gds
        where ub.alc-type-gds.gds-code = ub.goods.gds-code
        and ub.alc-type-gds.create-user-db-num = 0 EXCLUSIVE-LOCK no-error.
      if not available ub.alc-type-gds then
      do :
        create ub.alc-type-gds.
      end.
      else do:
        delete ub.alc-type-gds.
        create ub.alc-type-gds.
      end.
      assign
        ub.alc-type-gds.gds-code            = ub.goods.gds-code
        ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        ub.alc-type-gds.create-user-db-num  = 0
        ub.alc-type-gds.create-date = today
        .
      end.
   end.
   define variable v-value      as character no-undo .
   define variable v-type       as character no-undo .
   define buffer buf-grp for ub.gds-grp.
   define variable v-upper like  ub.gds-grp.node-code.
   find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
   do while v-value = '' and available buf-grp:
      v-upper = buf-grp.upper-code.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input 'sum-grps':U,
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.
        if v-value > "" then do:
          run gds-attr-write IN THIS-PROCEDURE(
              input ub.goods.gds-code
             ,INPUT 'sum-grp-gl':U
             ,INPUT v-value ) NO-ERROR.
        end.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input 'gg-mark-type':U,
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.
      if v-value > "" and v-value <> "not-type" then
      do:
         run gds-attr-write IN THIS-PROCEDURE(
            input ub.goods.gds-code
            ,INPUT 'mark-type':U
            ,INPUT v-value ) NO-ERROR.
         for each buf_bar-code no-lock where buf_bar-code.gds-code = ub.goods.gds-code:
            find first ub.prod-bc no-lock where ub.prod-bc.b-code = buf_bar-code.b-code and ub.prod-bc.bc-on-type = 'GTIN':U no-error .
            if not available (ub.prod-bc) then
            do:
               message   "Для маркированного товара необходимо завести код с типом GTIN"
                  view-as alert-box.
               undo _main, return error .
            end.
         end.
      end.
end.
end.
if mode <> 'ДОБАВЛЕНИЕ':U and mode <> 'ПРОСМОТР':U then do:
   find first tt0-goods-attr no-lock where tt0-goods-attr.attr-code = 'item-matter-mark':U no-error .
   if not available (tt0-goods-attr) then
   do:
   find first ub.goods-attr no-lock where ub.goods-attr.attr-code = 'item-matter-mark':U no-error .
   if not available (ub.goods-attr) then do:
      message "Не задан атрибут Признак предмета расчета!"
         view-as alert-box.
      undo _main, return error .
   end.
   end.
find first goods share-lock where recid(goods) = gds-rec .
  if temp-goods.alc-prod <> logical (v-gds-attr-value-old) then
  do:
    if temp-goods.alc-prod = yes then
    do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT 'alcohol-prod':U
        ,INPUT temp-goods.alc-prod ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , 'alcohol-prod':U
                                    , chr(10)
                                    ,error-status:get-message(1)
                                    ,return-value).
      END.
    end.
    else
    do:
      RUN gds-attr-delete IN THIS-PROCEDURE (
        input ub.goods.gds-code
        ,INPUT 'alcohol-prod':U
        ,output v-deleted ) NO-ERROR.
      IF NOT v-deleted
        or error-status:error
        THEN
      DO:
        assign
          v-err-mess = substitute("Ошибка при удалении атрибута товара &1 &2 :&3&4 &5"
                                  , ub.goods.gds-code
                                  , 'alcohol-prod':U
                                  , chr(10)
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
      END.
      find first ub.alc-type-gds
        where ub.alc-type-gds.gds-code = goods.gds-code
        and ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        and ub.alc-type-gds.create-user-db-num = 0 no-error.
        if available ub.alc-type-gds then
        delete ub.alc-type-gds.
    end.
  end.
  if temp-goods.alc-prod = yes then
    do:
      if temp-goods.alc-mark <> logical (v-gds-attr-mark-value-old) then do:
        run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT 'mark':U
        ,INPUT temp-goods.alc-mark ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , 'mark':U
                                    , chr(10)
                                    ,error-status:get-message(1)
                                    ,return-value).
      END.
      end.
        find first ub.alc-type-gds
        where ub.alc-type-gds.gds-code = ub.goods.gds-code
        and ub.alc-type-gds.create-user-db-num = 0 EXCLUSIVE-LOCK no-error.
      if not available ub.alc-type-gds then
      do :
        create ub.alc-type-gds.
      end.
      else do:
        delete ub.alc-type-gds.
        create ub.alc-type-gds.
      end.
      assign
        ub.alc-type-gds.gds-code            = ub.goods.gds-code
        ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        ub.alc-type-gds.create-user-db-num  = 0
        ub.alc-type-gds.create-date = today
        .
 end.
end.
end.
if v-loc-update-dgr then do:
  run ref/disgdru1.p (
                     input mode
                    ,input ub.goods.gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-dis-gds-rule
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении скидок товара на объекте:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-obj then do:
  run ref/gdsoatr1.p (
                     input mode
                    ,input ub.goods.gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-obj-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на объекте:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-host then do:
  run ref/gdshatr1.p (
                     input mode
                    ,input goods.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-host-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на фирме:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-gbl then do:
  run ref/gds-atr1.p (
                     input mode
                    ,input goods.gds-code
                    ,INPUT table tt0-goods-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении глобальных атрибутов товара на объекте:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-fbr-gds then do:
    run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input (if available locked_fbr-gds-obj
                                then 'ИЗМЕНЕНИЕ':U
                                else 'ДОБАВЛЕНИЕ':U)
                    , input no
                    , input goods.gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input integer(entry(9, v-fbr-gds-obj-template))
                    , input entry(7, v-fbr-gds-obj-template)
                    , input integer(entry(8, v-fbr-gds-obj-template))
                    , input logical(entry(1, v-fbr-gds-obj-template))
                    , input logical(entry(2, v-fbr-gds-obj-template))
                    , input logical(entry(3, v-fbr-gds-obj-template))
                    , input logical(entry(4, v-fbr-gds-obj-template))
                    , input logical(entry(5, v-fbr-gds-obj-template))
                    , input logical(entry(6, v-fbr-gds-obj-template))
                    ) no-error.
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов РЕСТОРАН товара на объекте:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-s-coeff then do:
  run ref/s-coeff1.p (
                     input mode
                    ,input goods.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-s-coeff
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении сезонных коэффициентов товара:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-gds-prop then do:
    find first ttf-gds-obj-prop no-error .
    if available ttf-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input ttf-gds-obj-prop.obj-type
        ,input ttf-gds-obj-prop.obj-code
        ,input ttf-gds-obj-prop.gdop-igt
        ,input ttf-gds-obj-prop.gdop-assort-min
        ,input ttf-gds-obj-prop.gdop-min-stock
        ,input ttf-gds-obj-prop.grop-level-always-presence
        ,input ttf-gds-obj-prop.grop-max-stock
        ,input ttf-gds-obj-prop.grop-min-order
        ,input table ttf-gds-obj-prop-attr
        ) no-error .
    end.
    find first tt0-gds-obj-prop no-error .
    if available tt0-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input tt0-gds-obj-prop.obj-type
        ,input tt0-gds-obj-prop.obj-code
        ,input tt0-gds-obj-prop.gdop-igt
        ,input tt0-gds-obj-prop.gdop-assort-min
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input table tt0-gds-obj-prop-attr
        ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении индикаторов/атрибутов для заказа товара на объекте:&1&2&1&3"
                    , chr(10)
                    , error-status:get-message(1)
                    , return-value )
          view-as alert-box
          error .
        end.
    end.
    find first ttj-gds-obj-prop no-error .
    if available ttj-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input ttJ-gds-obj-prop.obj-type
        ,input ttj-gds-obj-prop.obj-code
        ,input ?
        ,input ?
        ,input ttj-gds-obj-prop.gdop-min-stock
        ,input ttj-gds-obj-prop.grop-level-always-presence
        ,input ttj-gds-obj-prop.grop-max-stock
        ,input ttj-gds-obj-prop.grop-min-order
        ,input table ttj-gds-obj-prop-attr
        ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении параметров заказа товара на объекте:&1&2&1&3"
                    , chr(10)
                    , error-status:get-message(1)
                    , return-value )
          view-as alert-box
          error .
        end.
      end.
end.
if v-loc-update-add-prop then do:
    find first tt0-gds-add-charges no-error .
    if error-status :error then message error-status :get-message(1) .
    run ref/adcharg1.p
        (input-output v-add-prop-recid
        ,input goods.gds-code
        ,input tt0-gds-add-charges.algoritm
        ,input tt0-gds-add-charges.cost-include
        ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении дополнительных расходов :&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if mode = 'ДОБАВЛЕНИЕ':U then do:
  AvtArt = nbc .
  DISPLAY string( AvtArt ) @ goods.artic with frame d-gds-form .
  find first goods share-lock where
             recid(goods) = gds-rec .
  assign
  copymode = no
  saved-name = goods.gds-name
  Infmes = "Товар " + string(goods.artic) + " сохранен  - "  + string(goods.gds-code, "99999999999")
  impc-saved = impc-saved + 1
  nbc = 0
  .
end.
assign
temp-goods.cst-base-rate = goods.cst-base-rate
.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-gds-form.
END PROCEDURE.
PROCEDURE enable-UI :
define variable i-find as logical no-undo .
define variable ii as integer no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
is-prt = (IF error-status:error or conf-par <> "yes" then no else yes).
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'doc-prt=request':U
  ,output v-doc-prt
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-jwlr'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
assign
is-jwlr = (conf-par = "yes":U) no-error
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
  ,output conf-par
  ,output par-type
  ) no-error .
assign
is-bttl = (conf-par = "yes":U) no-error
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
  ,output conf-par
  ,output par-type
  ) no-error .
assign
is-ptrl = (conf-par = "yes":U) no-error
.
HIDE
frame d-gds-form name-uchet-base
frame d-gds-form name-uchet-rubl
frame d-gds-form for-obj-price-base
frame d-gds-form for-obj-last-base
frame d-gds-form for-obj-price-rubl
frame d-gds-form for-obj-last-rubl
frame d-gds-form b-extart
in frame d-gds-form.
CASE mode :
  when 'ДОБАВЛЕНИЕ':U then do:
    if not copymode then do:
      find first temp-goods no-error.
      if not available temp-goods then do:
       create temp-goods.
      end.
    end.
    ENABLE
    b-exit
    b-arch WHEN not dif-nam2
    b-inf when not igoods
    b-rest
    b-chk
    b-prt
    b-file when igoods
    b-help
    add-inf
    b-tax
    br-tt-tax
    ArtBar
    b-copy-name-to-lbl
    with frame d-gds-form.
    assign
    b-card:label = "След.->"
    menu-item m-dopinf-2:sensitive in menu m-dopinf = no
    .
    HIDE
    b-altcd
    b-prodbc
    ub.bar-code.b-code
    b-parts
    b-place
    b-recipe
    b-hist
    in frame d-gds-form.
    if copymode and f-name = "" then do:
      run ref/dtaxgdss.p (
                       input no
                      ,input for-goods.unit-base
                      ,input for-goods.grp-code
                      ,input  ?
                      ,input recid(for-goods)
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ) no-error.
      if error-status:error then return error.
      run enable-max-min in this-procedure ( input for-goods.unit-base) no-error.
      if error-status:error then return no-apply.
          OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
      FIND FIRST ub.country where ub.country.alpha1 = for-goods.alpha1 No-LOCK No-ERROR.
      assign
      ub.goods.PS:screen-value = temp-goods.ps
      ub.goods.calc-method:screen-value = string(temp-goods.calc-method)
      FirstIter = no
      NegRest = if (temp-goods.negative-rest) then var-negative-rest else FALSE
      .
      if temp-goods.fbr-grp-code <> ? then do:
        find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = temp-goods.fbr-grp-code no-error .
        if available buf_fbr-gds-grp then
        assign
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        .
      end.
      display
      temp-goods.gds-name @ goods.gds-name
      temp-goods.prod-type @ ub.clients.obj-type
      temp-goods.prod-code @ ub.clients.obj-code
      ub.clients.obj-name
      temp-goods.unit-base @ ub.goods.unit-base
      temp-goods.okdp @ ub.goods.okdp
      temp-goods.engl-name @  ub.goods.engl-name
      temp-goods.label-name @  ub.goods.label-name
      temp-goods.chk-name @  ub.goods.chk-name
      temp-goods.alpha1 @  ub.goods.alpha1
      (if length(temp-goods.grp-name) > 79 then
          ("..." + substr(temp-goods.grp-name, length(temp-goods.grp-name) - 79)) else
          temp-goods.grp-name) @  grp-full
      ub.gds-prt.node-name
      temp-goods.qnty-cart     @ goods.qnty-cart
      temp-goods.unit-cli      @ goods.unit-cli
      temp-goods.ms-base       @ goods.ms-base
      temp-goods.wt-base       @ goods.wt-base
      temp-goods.ms-cart       @ goods.ms-cart
      temp-goods.wt-cart       @ goods.wt-cart
      temp-goods.cli-base-rate @ goods.cli-base-rate
      temp-goods.increase-pc   @ goods.increase-pc
      if avail country then country.short-name else "" @ country_name
      f-fbr-grp-name
      with frame d-gds-form.
      IF temp-goods.min-rate <> 0 then
      DISPLAY
      temp-goods.min-rate @ goods.min-rate
      with frame d-gds-form.
      IF temp-goods.max-rate <> 0 then
      DISPLAY
      temp-goods.max-rate @ goods.max-rate
      with frame d-gds-form.
    end.
    if FirstIter
      then
    assign
    FirstIter = FALSE
    CostEntered = FALSE
    InpSelf = FALSE
    NegRest = if igoods then var-negative-rest else FALSE .
      else
    assign
    CostEntered = FALSE
    InpSelf = FALSE
    avrg-rate = 1
    .
    if ArtDis
      then
    ArtBar:FGCOLOR = 10 .
      else
    ArtBar:FGCOLOR = 0 .
    DISPLAY ArtBar NegRest      with frame d-gds-form.
    run val-chg-ArtBar in this-procedure .
    if f-name = "" then do:
     DISPLAY "" @ goods.artic with frame d-gds-form.
    end.
    else do:
      DISPLAY ImpMes with frame d-gds-form.
      assign
      i-artic = ";;;"
      i-find = no
      .
      _i-artic:
      DO WHILE i-artic = ";;;" or i-find:
        run next-good no-error.
        if error-status:error then return.
        i-find =  can-find (goods where
                        goods.artic = i-artic AND
                        goods.prod-type = input frame d-gds-form clients.obj-type AND
                        goods.prod-code = input frame d-gds-form clients.obj-code no-lock).
        if i-find then next _i-artic.
      END.
      if ArtDis then do:
        message "Для импорта требуется, чтобы автоматичекий артикул был выключен.".
        return.
      end.
      RUN next-good-display in this-procedure .
    end.
    if available ub.gds-grp then do:
      grp-full = "".
      RUN grplib-get-full-name in this-procedure (input gds-grp.node-code, output grp-full).
      if length(grp-full) > 79
        then
      assign
      grp-full = "..." + substr(grp-full, length(grp-full) - 79).
      DISPLAY grp-full with frame d-gds-form.
    end.
    if NOT igoods and NOT available clients
      then
    FIND clients WHERE
         clients.obj-type = 'орг':U and
         clients.obj-code = v-host-code no-error.
    if available clients
      then
    DISPLAY clients.obj-type clients.obj-code clients.obj-name with frame d-gds-form.
      else
    DISPLAY 'орг':U @ clients.obj-type with frame d-gds-form.
    if available gds-prt
      then
    DISPLAY gds-prt.node-name with frame d-gds-form.
    if ArtDis
      then
    DISABLE goods.artic with frame d-gds-form.
      else
    ENABLE goods.artic with frame d-gds-form.
    ENABLE
    goods.okdp clients.obj-type clients.obj-code r-prod b-altbc
    goods.gds-name goods.engl-name goods.label-name goods.chk-name
    goods.alpha1
    goods.unit-base
    r-base goods.unit-cli r-supp goods.cli-base-rate r-alpha1 r-fbr-grp
    goods.qnty-cart goods.ms-base goods.ms-cart
    goods.wt-base goods.wt-cart goods.PS
    NegRest
    goods.calc-method
    goods.increase-pc
    label-increase-pc
    label-min-rate
    label-max-rate
    with frame d-gds-form.
    if f-name = "" then do:
      run str/pr-listv.p (
                      input 'Учетная,Группа,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U
                    , 'Группа':U
                    , output p-list) .
      goods.calc-method:list-items in frame d-gds-form  = p-list .
    end.
    if f-name = "" then
    assign
    goods.calc-method:screen-value = 'Группа':U.
     if not g#log and f-name = "" then do:
       goods.increase-pc:screen-value = string(0).
     end.
     APPLY "Value-changed" to goods.calc-method in frame d-gds-form.
     if f-name <> "" then do:
       assign
       ArtBar:List-Items = If v-cntxt-db-num = 0
                           then (vArtBar-off + chr(44) + vArtBar-BarCOde)
                           else vArtBar-off
       .
       ENABLE b-card with frame d-gds-form.
     end.
     else
     ArtBar:List-Items = If v-cntxt-db-num = 0
                         then (vArtBar-off + chr(44) + vArtBar-Auto + chr(44) + vArtBar-BarCode)
                         else (vArtBar-off + chr(44) + vArtBar-Auto)
     .
     DISPLAY ArtBar With FRAME d-gds-form.
     run val-chg-ArtBar.
     assign
     b-exit:label = "&Ввод "
     b-arch:label = "Со&хр"
     b-altbc:label = "С+&Коды"
     b-rest:label = "&Отмена"
     b-chk:label = "&Группа"
     b-file:label = "&Импорт" .
     if copymode then do:
        if igoods then
        frame d-gds-form:title = "КОПИЯ ТОВАРA " +
        string(for-goods.artic) + " " + for-goods.gds-name + " " + title-mode(mode).
        else
        frame d-gds-form:title = "КОПИЯ УСЛУГИ " +
        string(for-goods.artic) + " " + for-goods.gds-name + " " + title-mode(mode).
     end.
     else do:
      if igoods
        then
      frame d-gds-form:title = "Т О В А Р" + fill(chr(32), 35) + title-mode(mode).
      else do:
            frame d-gds-form:title = "У С Л У Г А" + fill(chr(32), 34 ) + title-mode(mode).
            HIDE NegRest    in frame d-gds-form.
      end.
    end.
    if dfltggrp >= 0 and
    (f-name = ""
      OR
      (f-name <> "":U and  impc = 1)
    )
    then do:
      FIND gds-grp WHERE gds-grp.node-code = dfltggrp NO-LOCK No-ERROR.
      if avail gds-grp then do:
        RUN grplib-get-full-name in this-procedure(input gds-grp.node-code, output grp-full).
        DISPLAY
        (if length(grp-full) > 79
        then
        ("..." + substr(grp-full, length(grp-full) - 79))
        else
        grp-full) @ grp-full
        with frame d-gds-form.
      end.
      else do:
        message
        "Неверное значение настроечного параметра Код группы товаров по умолчанию (при создании нового товара)" skip
        "Нет группы товара с node-code=" dfltggrp
        "Обратитесь к администратору системы"
        view-as alert-box Warning.
        display
        "":U @ grp-full
        with frame d-gds-form.
      end.
    end.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    run str/pr-listv.p (
                     input 'Учетная,Группа,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U
                   , goods.calc-method
                   , output p-list) .
    goods.calc-method:list-items in frame d-gds-form  = p-list .
    run ref/dtaxgdss.p (
                  input no
                 ,input goods.unit-base
                 ,input goods.grp-code
                 ,input gds-rec
                 ,input gds-rec
                 ,input v-host-code
                 ,input p-obj-type
                 ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base) no-error.
    if error-status:error then return no-apply.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    find first temp-goods no-error.
    if not available temp-goods then do:
      create temp-goods.
    end.
    buffer-copy goods to temp-goods.
    FIND clients WHERE
         clients.obj-type = goods.prod-type AND
         clients.obj-code = goods.prod-code NO-LOCK.
    FIND gds-prt WHERE gds-prt.upper-code = goods.prt-root NO-LOCK.
    FIND FIRST ub.gds-obj share-lock WHERE
               ub.gds-obj.obj-type = p-obj-type AND
               ub.gds-obj.obj-code = p-obj-code AND
               ub.gds-obj.artic = ub.goods.artic AND
               ub.gds-obj.prod-type = ub.goods.prod-type AND
               ub.gds-obj.prod-code = ub.goods.prod-code NO-ERROR.
    FIND FIRST ub.bar-code WHERE
         ub.bar-code.gds-code  = ub.goods.gds-code AND
         ub.bar-code.node-code = ub.gds-prt.node-code AND
         ub.bar-code.in-code = "" AND
         ub.bar-code.part-code = ""  AND
        ub.bar-code.unit-cli = ub.goods.unit-base NO-LOCK NO-ERROR.
    IF ERROR-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
      view-as alert-box ERROR.
      return error.
    end.
    FIND gds-grp WHERE gds-grp.node-code = ub.goods.grp-code NO-LOCK.
    FIND country WHERE country.alpha1 = ub.goods.alpha1 No-LOCK NO-ERROR.
    if ub.goods.fbr-grp-code <> ? then do:
      find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = ub.goods.fbr-grp-code no-error .
        if available buf_fbr-gds-grp then
        assign
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        .
    end.
    assign
    b-exit:label = "&Ввод"
    b-rest:label = "&Отмена"
    b-chk:label = "&Группа"
    NegRest = ub.goods.negative-rest
    main-code = bar-code.b-code
    .
    DISPLAY
    (if length(goods.grp-name) > 79
       then ("..." + substr(goods.grp-name, length(goods.grp-name) - 79))
       else  ub.goods.grp-name)
    @ grp-full
    ub.goods.artic ub.goods.okdp bar-code.b-code gds-prt.node-name
    clients.obj-type clients.obj-code clients.obj-name
    ub.goods.gds-name ub.goods.engl-name ub.goods.label-name ub.goods.chk-name
    ub.goods.alpha1
    ub.goods.unit-base ub.goods.unit-cli ub.goods.cli-base-rate
    ub.goods.calc-method ub.goods.increase-pc ub.goods.qnty-cart ub.goods.ms-base ub.goods.ms-cart label-increase-pc
    label-min-rate
    label-max-rate
    ub.goods.wt-base
    ub.goods.wt-cart ub.goods.PS
    NegRest
    (if avail country
      then country.short-name
      else "")
      @ country_name
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    f-fbr-grp-name
    with frame d-gds-form.
    HIDE
    b-arch b-rest b-card b-parts b-place
    b-inf r-base r-prod b-file
    ArtBar in frame d-gds-form.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_calc-increase':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  ub.goods.grp-code
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
    assign
    menu-item m-dopinf-6:sensitive in menu m-dopinf = (fbrvalue = "yes")
    menu-item m-dopinf-7:sensitive in menu m-dopinf = (fbrvalue = "yes")
    .
    ENABLE
    b-exit
    b-altbc
    b-altcd
    b-prodbc
    b-chk
    b-prt
    b-help
    add-inf
    b-recipe
    b-rest
    b-sert
    b-hist
    ub.goods.okdp
    ub.goods.gds-name
    ub.goods.engl-name
    ub.goods.label-name
    ub.goods.chk-name
    ub.goods.unit-cli
    ub.goods.alpha1
    r-supp
    r-fbr-grp
    ub.goods.cli-base-rate
    r-alpha1
    ub.goods.qnty-cart
    ub.goods.ms-base
    ub.goods.wt-base
    ub.goods.ms-cart
    ub.goods.wt-cart
    ub.goods.PS
    br-tt-tax
    b-tax
    NegRest
    ub.goods.calc-method when g#log
    ub.goods.increase-pc when g#log
    label-increase-pc
    label-min-rate
    label-max-rate
    b-copy-name-to-lbl
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    with frame d-gds-form.
    IF ub.goods.gds-type = 'т':U then do:
      frame d-gds-form:title = "Т О В А Р".
    end.
    else do:
      frame d-gds-form:title = "У С Л У Г А".
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
      if g#log then do:
        HIDE
        ub.goods.min-rate
        ub.goods.max-rate
        ub.goods.qnty-cart
        ub.goods.ms-base
        ub.goods.wt-base
        ub.goods.ms-cart
        ub.goods.wt-cart
        ub.goods.calc-method
        ub.goods.increase-pc
        label-increase-pc
        label-min-rate
        label-max-rate
        RECT-2
        RECT-3
        RECT-4
        in frame d-gds-form.
        ENABLE
        for-obj-price-base
        for-obj-price-rubl
        WITH frame d-gds-form.
        DISPLAY
        name-uchet-base
        name-uchet-rubl
        (if avail gds-obj then gds-obj.price-base else ?) @ for-obj-price-base
        (if avail gds-obj then gds-obj.price-rubl else ?) @ for-obj-price-rubl
        WITH frame d-gds-form.
      end.
    END.
   APPLY "Value-changed" to ub.goods.calc-method in frame d-gds-form.
   if ub.goods.stts = 1
   then frame d-gds-form:title = frame d-gds-form:title + "      'статус':U :  УДАЛЕН".
   frame d-gds-form:title = frame d-gds-form:title + fill(chr(32), 34) + title-mode(mode).
  end.
  when 'ПРОСМОТР':U then do:
    display
      b-extart
    with frame d-gds-form.
    ENABLE
    b-exit b-arch b-altbc b-altcd b-prodbc b-price b-rest
    b-card b-chk b-prt b-parts b-place b-hist b-inf
    b-recipe b-sert b-help add-inf
    b-gdsfrmfi
    b-tax b-next b-prev
    b-extart
    with frame d-gds-form.
    FIND ub.goods WHERE recid (goods) = gds-rec NO-LOCK.
    find first temp-goods no-error.
    if not available temp-goods then do:
      create temp-goods.
    end.
    buffer-copy ub.goods to temp-goods.
    run str/pr-listv.p (
                     input 'Учетная,Группа,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U
                   , ub.goods.calc-method
                   , output p-list) .
    ub.goods.calc-method:list-items in frame d-gds-form  = p-list .
    run ref/dtaxgdss.p (
                   input no
                  ,input ub.goods.unit-base
                  ,input ub.goods.grp-code
                  ,input gds-rec
                  ,input gds-rec
                  ,input v-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                   ) no-error.
    if error-status:error then return error.
    assign
    tt-tax.rate-code:read-only in browse br-tt-tax = true.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST gds-obj WHERE
               gds-obj.obj-type = p-obj-type AND
               gds-obj.obj-code = p-obj-code AND
               gds-obj.artic = ub.goods.artic AND
               gds-obj.prod-type = ub.goods.prod-type AND
               gds-obj.prod-code = ub.goods.prod-code
            NO-LOCK NO-ERROR .
    FIND FIRST clients WHERE
               clients.obj-type = ub.goods.prod-type AND
               clients.obj-code = ub.goods.prod-code NO-LOCK.
    FIND FIRST gds-prt WHERE
               gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    FIND FIRST bar-code WHERE
               bar-code.gds-code = ub.goods.gds-code AND
               bar-code.node-code = gds-prt.node-code AND
               bar-code.in-code = "" AND
               bar-code.part-code = "" AND
               bar-code.unit-cli = ub.goods.unit-base NO-LOCK NO-error.
    IF ERROR-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
      view-as alert-box error.
      return error.
    end.
    FIND FIRST country where
               country.alpha1 = ub.goods.alpha1 NO-LOCK No-ERROR.
    if ub.goods.fbr-grp-code <> ? then do:
      find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = ub.goods.fbr-grp-code no-error .
      if available buf_Fbr-gds-grp then
      assign
      fbr-grp-code_ = buf_fbr-gds-grp.node-code
      f-fbr-grp-name = buf_fbr-gds-grp.node-name
      .
    end.
    HIDE
    r-base r-supp r-prod r-alpha1 r-fbr-grp b-file
    ArtBar in frame d-gds-form.
    NegRest = ub.goods.negative-rest .
    main-code = bar-code.b-code.
    assign
    menu-item m-dopinf-6:sensitive in menu m-dopinf = (fbrvalue = "yes")
    menu-item m-dopinf-7:sensitive in menu m-dopinf = (fbrvalue = "yes")
    .
    DISPLAY
    (if length(goods.grp-name) > 79
      then ("..." + substr(goods.grp-name, length(goods.grp-name) - 79))
      else ub.goods.grp-name)
      @ grp-full
    if avail country
      then country.short-name
      else "" @ country_name
    ub.goods.artic ub.goods.okdp bar-code.b-code clients.obj-type clients.obj-code
    clients.obj-name ub.goods.gds-name ub.goods.engl-name ub.goods.label-name ub.goods.chk-name
    ub.goods.unit-base ub.goods.unit-cli ub.goods.cli-base-rate ub.goods.alpha1
    ub.goods.calc-method ub.goods.increase-pc ub.goods.qnty-cart ub.goods.ms-base ub.goods.ms-cart label-increase-pc
    label-min-rate
    label-max-rate
    ub.goods.wt-base
    ub.goods.wt-cart ub.goods.PS NegRest
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    f-fbr-grp-name
    with frame d-gds-form.
    if gds-prt.node-name <> '_Пустая шкала':U
    then
    DISPLAY gds-prt.node-name with frame d-gds-form.
    if ub.goods.PS = ""
    then
    disable ub.goods.PS with frame d-gds-form.
    if ub.goods.gds-type = 'т':U
      then
    frame d-gds-form:title = "Т О В А Р".
      else
    frame d-gds-form:title = "У С Л У Г А".
    if ub.goods.stts = 1
      then
    frame d-gds-form:title = frame d-gds-form:title + "      'статус':U :  УДАЛЕН".
    frame d-gds-form:title = frame d-gds-form:title + fill(chr(32), 34) + title-mode(mode).
    APPLY "Value-changed" to ub.goods.calc-method in frame d-gds-form.
  end.
end CASE .
  RUN gds-attr-value (
    INPUT temp-goods.gds-code,
    INPUT 'alcohol-prod':U,
    OUTPUT v-gds-attr-value-old,
    OUTPUT v-gds-attr-type
    ).
     if v-gds-attr-value-old = "yes" then do:
     RUN gds-attr-value (
        INPUT temp-goods.gds-code,
        INPUT 'mark':U,
        OUTPUT v-gds-attr-mark-value-old,
        OUTPUT v-gds-attr-type
        ).
     find first ub.alc-type-gds no-lock
     where ub.alc-type-gds.gds-code = temp-goods.gds-code and
     ub.alc-type-gds.create-user-db-num = 0 no-error.
     if not AVAILABLE ub.alc-type-gds then do:
     assign
        temp-goods.alc-prod = no
        temp-goods.alc-mark = no
        .
     end.
     else
     assign
        temp-goods.alc-choose-prod = ub.alc-type-gds.alc-type-inner-code
        temp-goods.alc-prod = yes
        .
     if v-gds-attr-mark-value-old = "yes" then temp-goods.alc-mark = yes .
     end.
END PROCEDURE.
PROCEDURE copy-name-to-lbl:
   if mode = 'ДОБАВЛЕНИЕ':U and ub.goods.label-name:screen-value IN FRAME d-gds-form = ""
   or self:name = "b-copy-name-to-lbl"
   then
  DISPLAY ub.goods.gds-name:screen-value @ ub.goods.label-name with frame d-gds-form.
  if mode = 'ДОБАВЛЕНИЕ':U and ub.goods.chk-name:screen-value IN FRAME d-gds-form = ""
  or self:name = "b-copy-name-to-lbl"
  then
  DISPLAY replace(replace(goods.gds-name:screen-value, chr(39), ""), '"', "") @ ub.goods.chk-name with frame d-gds-form.
END.
PROCEDURE start-import:
    if ArtBar = vArtBar-Auto then
    assign
    ArtBar = vArtBar-Off.
    run val-chg-ArtBar.
    DiSPLAY ArtBar WITH FRAME d-gds-form.
    if NOT f-name = "" then do:
        message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
                         ",  сохранено " + string(impc-saved) )
                         view-as alert-box INFORMATION.
        assign
        f-name = ""
        not-saved = ''.
        display "" @ ub.goods.artic with frame d-gds-form.
        DISABLE b-card WITH frame d-gds-form.
    end.
    run ref/strtimp.w (
                           input parparentproc
                          ,input no
                          ,input vattaxcd
                          ,input slttaxcd
                          ,input custvalue
                          ,input tnvedimp
                          ,output f-name
                          ,output choice
                          ,output p-artic
                          ,output p-prod
                          ,OUTPUT p-name
                          ,OUTPUT p-engl-name
                          ,OUTPUT p-unit-base
                          ,OUTPUT p-VAT-code
                          ,OUTPUT p-SLT-code
                          ,OUTPUT p-struct
                          ,OUTPUT p-tnved
                          ,OUTPUT p-attrib
                          ,OUTPUT p-destin
                          ,OUTPUT p-sert
                          ,OUTPUT p-user-rule
                          ,OUTPUT p-alpha1
                          ,OUTPUT p-grp-code
                          ,OUTPUT p-service
                          ,OUTPUT p-gds-code
                          ,OUTPUT p-mark
                          ) no-error.
    if  error-status:error or f-name = "" then return error.
    CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (f-name) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (f-name) convert source "KOI8-R".
        END.
    END CASE.
    assign
    add-another = yes
    impc = 0
    impc-saved = 0.
    apply "go" to frame d-gds-form.
END.
PROCEDURE next-good:
  assign
  v-flag-attr-obj-entry   = no
  v-flag-attr-host-entry  = no
  v-flag-fbr-gds-entry    = no
  v-flag-s-coeff-entry    = no
  v-flag-gds-prop-entry   = no
  v-flag-add-prop-entry   = no
  v-update-attr-obj       = no
  v-update-attr-host      = no
  v-update-fbr-gds        = no
  v-update-s-coeff        = no
  v-update-gds-prop       = no
  v-update-add-prop       = no
  v-found-copy-atr-obj    = no
  v-found-copy-atr-host   = no
  v-found-copy-fbr-gds    = no
  v-found-copy-s-coeff    = no
  v-found-copy-gds-prop   = no
  v-found-copy-add-prop   = no
  .
    i-artic = "".
    if g#log = ? then do:
        input stream gds-file close.
    end.
    else DO on endkey undo, leave on error undo, leave:
        run ref/nxtgdsi.p (   input vattaxcd
                             ,input slttaxcd
                             ,input custvalue
                             ,input p-artic
                             ,input p-prod
                             ,input p-name
                             ,input p-engl-name
                             ,input p-unit-base
                             ,input p-VAT-code
                             ,input p-SLT-code
                             ,input p-struct
                             ,input p-tnved
                             ,input p-attrib
                             ,input p-destin
                             ,input p-sert
                             ,input p-user-rule
                             ,input p-alpha1
                             ,input p-grp-code
                             ,input p-service
                             ,input p-gds-code
                             ,p-mark
                             ,input (impc + 1)
                             ,input-output i-artic
                             ,input-output i-prod-type
                             ,input-output i-prod-code
                             ,input-output i-gds-name
                             ,input-output i-engl-name
                             ,input-output i-unit-base
                             ,input-output i-VAT-code
                             ,input-output i-SLT-code
                             ,input-output i-struct
                             ,input-output i-tnved
                             ,input-output i-attrib
                             ,input-output i-destin
                             ,input-output i-sert
                             ,input-output i-user-rule
                             ,input-output i-alpha1
                             ,input-output i-grp-code
                             ,input-output i-service
                             ,input-output i-gds-code
                             ,input-output i-mark
                              ) .
        assign
        impc = impc + 1
        ImpMes = "ИМПОРТ " + string (impc , "99999")
        InfMes = "".
        Display ImpMes with frame d-gds-form.
   END.
   IF ERROR-STATUS:ERROR OR g#log = ? THEN do:
     message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
                      ",  сохранено " + string(impc-saved) )
     view-as alert-box  INFORMATION.
     display "" @ ub.goods.artic with frame d-gds-form.
     assign f-name = ""
     impc = 0
     impc-saved = 0
     ImpMes = "ИМПОРТ"
     not-saved = ""
     ArtBar:List-items = if v-cntxt-db-num = 0
                                    then (vArtBar-off + chr(44) + vArtBar-Auto + chr(44) + vArtBar-BarCode)
                                    else (vArtBar-off + chr(44) + vArtBar-Auto)
     .
     DISPLAY ArtBar With FRAME d-gds-form.
     DISABLE b-card with frame d-gds-form.
     Hide ImpMes in frame d-gds-form.
     run val-chg-ArtBar.
     return error.
  END.
END.
PROCEDURE val-chg-ArtBAr:
    Assign frame d-gds-form ArtBar.
    Case ArtBar:
    When vArtBar-Auto then  do:
            assign
                ArtDis = yes
                BarDis = no
                ub.goods.artic:BGCOLOR in frame d-gds-form = 8
                ArtBar:FGCOLOR = 10
                AvtArt = nbc
                .
            DISPLAY
                ( if AvtArt = 0 then "" else string( AvtArt)) @ ub.goods.artic with frame d-gds-form.
            DISABLE ub.goods.artic b-file with frame d-gds-form.
            apply "entry" to ub.goods.gds-name in frame d-gds-form.
    end.
    WHEN vArtBar-Off then do:
            assign
                ArtDIs = no
                BarDis = no
                ub.goods.artic:BGCOLOR = 3
                ArtBar:FGCOLOR = 0 .
            ENABLE ub.goods.artic b-file with frame d-gds-form.
            apply "entry" to ub.goods.artic in frame d-gds-form.
    end.
    WHEN vArtBar-BarCode then do:
            assign
                ArtDIs = no
                BarDis = yes
                ub.goods.artic:BGCOLOR = 9
                ArtBar:FGCOLOR = 9 .
            ENABLE ub.goods.artic b-file with frame d-gds-form.
            apply "entry" to ub.goods.artic in frame d-gds-form.
    end.
    END CASE.
END PROCEDURE.
PROCEDURE next-good-display:
define buffer first_gds-grp for ub.gds-grp.
DISPLAY
i-artic           @ ub.goods.artic
i-gds-name  @ ub.goods.gds-name
i-engl-name @ ub.goods.engl-name
""                 @ ub.goods.label-name
""                 @ ub.goods.chk-name
i-unit-base   @ ub.goods.unit-base
i-unit-base   @ ub.goods.unit-cli
with frame d-gds-form
.
if p-prod <> 0 then do:
  DISPLAY
  i-prod-type       @ ub.clients.obj-type
  i-prod-code       @ ub.clients.obj-code
  with frame d-gds-form.
  apply "LEAVE" to ub.clients.obj-code in frame d-gds-form .
end.
if p-alpha1 <> 0 then do:
  DISPLAY
  i-alpha1          @ ub.goods.alpha1
  with frame d-gds-form.
  apply "LEAVE" to ub.goods.alpha1 in frame d-gds-form .
end.
if p-grp-code <> 0 then do:
  find first ub.gds-grp no-lock where ub.gds-grp.node-code = i-grp-code no-error .
  if avail ub.gds-grp then do:
    RUN grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output grp-full).
    DISPLAY
    (if length(grp-full) > 79
    then
    ("..." + substr(grp-full, length(grp-full) - 79))
    else
    grp-full) @ grp-full
    with frame d-gds-form.
  end.
end.
assign
temp-goods.attrib = i-attrib
temp-goods.destin = i-destin
temp-goods.sert = i-sert
temp-goods.user-rule = i-user-rule
temp-goods.struct = i-struct
.
if p-unit-base > 0 then do:
  run leave-unit-base(i-unit-base).
end.
find first first_gds-grp .
if p-VAT-code > 0 then do:
  FIND FIRST bf-tt-tax NO-LOCK where
            bf-tt-tax.tax-code = vattaxcd No-ERROR.
  if not avail bf-tt-tax then do:
    run ref/dtaxgdss.p (
                   input no
                  ,input i-unit-base
                  ,input (if available ub.gds-grp
                          then ub.gds-grp.node-code
                          else first_gds-grp.node-code)
                  ,input ?
                  ,input ?
                  ,input v-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return error.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST bf-tt-tax NO-LOCK where
              bf-tt-tax.tax-code = vattaxcd No-ERROR.
  end.
  if avail bf-tt-tax then do:
    REPOSITION br-tt-tax to recid recid(bf-tt-tax) No-ERROR.
    run ROW-LEAVE-BR-tt-tax(i-vat-code).
  end.
end.
if p-slt-code > 0 then do:
  FIND FIRST bf-tt-tax NO-LOCK where
            bf-tt-tax.tax-code = slttaxcd No-ERROR.
  if not avail bf-tt-tax then do:
    run ref/dtaxgdss.p (
                        input no
                       ,input i-unit-base
                       ,input (if available ub.gds-grp
                               then ub.gds-grp.node-code
                               else first_gds-grp.node-code)
                       ,input ?
                       ,input ?
                       ,input v-host-code
                       ,input p-obj-type
                       ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return error.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST bf-tt-tax NO-LOCK where
              bf-tt-tax.tax-code = slttaxcd No-ERROR.
  end.
  if avail bf-tt-tax then do:
    REPOSITION br-tt-tax to recid recid(bf-tt-tax) No-ERROR.
    run ROW-LEAVE-BR-tt-tax(i-slt-code).
  end.
end.
if p-tnved > 0 then do:
  assign
  temp-goods.tnved = i-tnved
  .
  run get-fields in this-procedure no-error .
end.
END.
PROCEDURE leave-unit-base:
DEFINE INPUT PARAMETER fv as char no-undo.
define variable loc#log as logical no-undo .
define buffer base_units for ub.units.
FIND first base_units no-lock where
         base_units.unit-name = input frame d-gds-form ub.goods.unit-base  no-error.
if not available base_units
then do:
  display "?" @ ub.goods.unit-base WITH FRAME d-gds-form.
end.
if available base_units
and lookup( 'топ':U, base_units.type) > 0 then do:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-petrolium_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc#log
    )  .
end.
  if not loc#log then do:
    display "?" @ ub.goods.unit-base WITH FRAME d-gds-form.
  end.
end.
if  NOT ub.goods.unit-base:screen-value = "?" and mode = 'ДОБАВЛЕНИЕ':U and avail ub.gds-grp then do:
  run ref/dtaxgdss.p (
                       input no
                      ,input fv
                      ,input ub.gds-grp.node-code
                      ,input ?
                      ,input ?
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ) no-error.
  if error-status:error then return error.
  run enable-max-min(fv) no-error.
  if error-status:error then return no-apply.
  OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
end.
END.
PROCEDURE row-leave-br-tt-tax.
DEFINE INPUT PARAMETER trc like ub.tax-rate.rate-code no-undo.
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
define variable var-fact-order like ub.tax-rate-value.fact-order no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  tt-tax.tax-code
  ,input  trc
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output taxvalue
  ) no-error .
  if error-status:error or taxvalue = ? then do:
      assign
      tt-tax.rate-code:screen-value in browse br-tt-tax = string(tt-tax.rate-code)
      tt-tax.fact-date:screen-value in browse br-tt-tax = string(tt-tax.fact-date)
      .
      return error.
  end.
  if mode = 'ДОБАВЛЕНИЕ':U and not copymode then v-today = 01/01/1990.
  else do:
    run cur-time in this-procedure(output v-today, output v-time).
  end.
  assign
  tt-tax.rate-value:screen-value in browse br-tt-tax = string(taxvalue)
  tt-tax.fact-date:screen-value in browse br-tt-tax = string(v-today, "99/99/9999")
  .
  FIND FIRST bf-tt-tax WHERE recid(bf-tt-tax) = recid(tt-tax) NO-ERROR.
  run factord-end-day in this-procedure (input date(tt-tax.fact-date:screen-value in browse br-tt-tax), output var-fact-order).
  assign
  bf-tt-tax.rate-code = integer(trc)
  bf-tt-tax.rate-value = decimal(tt-tax.rate-value:screen-value in browse br-tt-tax)
  bf-tt-tax.fact-date = date(tt-tax.fact-date:screen-value in browse br-tt-tax)
  bf-tt-tax.fact-order = var-fact-order
  .
  OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
END.
PROCEDURE enable-max-min:
DEFINE INPUT PARAMETER fv as char no-undo.
DEFINE BUFFER loc-units for ub.units.
      FIND FIRST loc-units No-LOCK WHERE
                 loc-units.unit-name = fv NO-ERROR.
      IF not avail loc-units then return error.
      IF LOOKUP('2ед':U, loc-units.type) > 0 then do:
        DISPLAY
        label-min-rate
        Label-max-rate
        with frame d-gds-form.
        ENABLE
        ub.goods.min-rate
        ub.goods.max-rate
        with frame d-gds-form.
        DISPLAY
        0 @ ub.goods.min-rate
        0 @ ub.goods.max-rate
        with frame d-gds-form.
      END.
      ELSE DO:
        DISABLE
        ub.goods.min-rate
        ub.goods.max-rate
        with frame d-gds-form.
        HIDE
        label-min-rate
        Label-max-rate
        ub.goods.min-rate
        ub.goods.max-rate
        IN frame d-gds-form.
      END.
END.
PROCEDURE proc-b-altcd :
  DEFINE INPUT-OUTPUT PARAMETER loc-altcd-option as char no-undo.
   run ref/alt-cds.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input loc-altcd-option
                  ,goods.gds-code
                  ,main-code
                  ,output ref-list).
  loc-altcd-option = "".
END PROCEDURE.
PROCEDURE proc-b-add-inf:
  DEFINE INPUT-OUTPUT PARAMETER loc-DOPINF-option as char no-undo.
  define variable v-recid as recid no-undo.
  DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
  case LOC-DOPINF-option:
    WHEN "dop-inf":U then do:
      define variable goodsname as char no-undo .
      define variable prodname as char no-undo .
      define variable prodaddress as char no-undo .
      define variable goods-unit-base as char no-undo .
      define variable glog as logical no-undo.
      if NOT can-do( 'ДОБАВЛЕНИЕ':U, mode ) then do:
        if ub.clients.obj-type = 'орг':U then
            FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code NO-LOCK .
        else
            FIND ub.person WHERE ub.person.psn-code = ub.clients.obj-code NO-LOCK .
        assign
            goodsname = ub.goods.gds-name
            prodname = ( trim( ub.clients.obj-name ) +
                                  "( " + ub.clients.obj-type + " " + string( ub.clients.obj-code ) + " )" )
            prodaddress = ( if ub.clients.obj-type = 'орг':U
                            then string( trim( firm.city ) + " " +
                                        trim( firm.addres1 ) + " " + trim( firm.addres2 ) )
                            else string( trim( person.city ) + " " + trim( person.address ) ) )
            goods-unit-base = input frame d-gds-form goods.unit-base
            .
      end.
      assign
        glog = true
      .
      if mode <> 'ДОБАВЛЕНИЕ':U and mode <> 'ПРОСМОТР':U then do :
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo_gbl':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  ub.goods.grp-code
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      if glog then do :
        run set-fields.
        run ref/p51121.w (
                          input parparentproc
                        , input p-obj-type
                        , input p-obj-code
                        , input mode
                        , input goodsname
                        , input prodname
                        , input prodaddress
                        , input (input frame d-gds-form goods.unit-base)
                        , input-output temp-goods.destin
                        , input-output temp-goods.attrib
                        , input-output temp-goods.user-rule
                        , input-output temp-goods.sert
                        , input-output temp-goods.struct
                        , input-output temp-goods.deadline
                        , input-output temp-goods.sort
                        , input-output temp-goods.tnved
                        , input-output temp-goods.unit-cst
                        , input-output temp-goods.cst-base-rate
                        , input-output temp-goods.nationality
                        , input-output temp-goods.normal-wastage
                        , input-output temp-goods.normal-waste
                        , input-output temp-goods.cond-keep-code
                        , input-output temp-goods.proof
            , INPUT-OUTPUT temp-goods.alc-prod
            , INPUT-OUTPUT temp-goods.alc-mark
                        , INPUT-OUTPUT temp-goods.alc-choose-prod
                        ) .
        run get-fields in this-procedure .
      end.
    END.
    WHEN "foto":U then do:
      if mode = 'ДОБАВЛЕНИЕ':U then do:
        BELL.
        loc-DOPINF-option = "".
        return error.
      end.
      run ref/gds-ph.p
        (input parparentproc
        ,buffer goods
        ,input mode
        ).
    end.
    WHEN "dop-inf-gbl":U then do:
      if not v-flag-attr-gbl-entry then do:
        run fill-attr-tables in this-procedure ('goods-attr':U, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run addGdsGrpAttr (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code, if avail gds-grp then gds-grp.node-code else -1 ).
      run ref/gds-atti.w (
                      input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-goods-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-gbl = v-update-attr-gbl OR v-updated-now
      .
    END.
    WHEN "dop-inf-host":U then do:
      if not v-flag-attr-host-entry then do:
        run fill-attr-tables in this-procedure ('gds-host-attr':U, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gdshatti.w (
                      input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-gds-host-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-host = v-update-attr-host OR v-updated-now
      .
    END.
    WHEN "dop-inf-fbr-gds-obj":U then do:
      if not v-flag-fbr-gds-entry then do:
        run fill-attr-tables in this-procedure ('fbr-gds-obj':U, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/fgdsobji.w (
                     input parparentproc
                    ,input (if available locked_fbr-gds-obj
                            then mode
                            else (if mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'ДОБАВЛЕНИЕ':U)
                           )
                    ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input no
                    ,input-output v-fbr-gds-obj-template
                    ,output v-updated-now
                    ,input-output v-recid
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      if v-updated-now then do:
        find first tt0-fbr-gds-obj where
                    tt0-fbr-gds-obj.obj-type = p-obj-type
                AND tt0-fbr-gds-obj.obj-code = p-obj-code no-error.
        if not available tt0-fbr-gds-obj then do:
          create tt0-fbr-gds-obj.
          assign
          tt0-fbr-gds-obj.gds-code = goods.gds-code
          tt0-fbr-gds-obj.obj-type = p-obj-type
          tt0-fbr-gds-obj.obj-code = p-obj-code
          .
        end.
        assign
        tt0-fbr-gds-obj.is-cd   = logical(entry(1, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-menu = logical(entry(2, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-modificator = logical(entry(3, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-null-price = logical(entry(4, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-season     = logical(entry(5, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-semi-finished  = logical(entry(6, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.fbr-obj-type      = entry(7, v-fbr-gds-obj-template)
        tt0-fbr-gds-obj.fbr-obj-code      = integer(entry(8, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.fbr-grp-code      = integer(entry(9, v-fbr-gds-obj-template))
        .
      end.
      ASSIGN
      v-update-fbr-gds = v-update-fbr-gds OR v-updated-now
      .
    END.
    WHEN "dop-inf-s-coeff":U then do:
      if not v-flag-s-coeff-entry then do:
        run fill-attr-tables in this-procedure ('s-coeff':U, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/scoeffs.w (
                     input parparentproc
                    ,input mode
                    ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input no
                    ,output v-updated-now
                    ,input-output table tt0-s-coeff
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-s-coeff = v-update-s-coeff OR v-updated-now
      .
    END.
    WHEN "dop-inf-obj-one":U
    or
    when "dop-inf-obj-cmp":U
    then do:
      if not v-flag-attr-obj-entry then do:
        run fill-attr-tables in this-procedure  ('gds-obj-attr':U, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gdsoatti.w (
                     input parparentproc
                     ,input  mode
                     ,input 'объект':U
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-gds-obj-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-obj = v-update-attr-obj OR v-updated-now
      .
    END.
    WHEN "dop-inf-dgr-one":U
    or
    when "dop-inf-dgr-cmp":U
    then do:
      if mode = 'ДОБАВЛЕНИЕ':U then do:
        message "Назначение скидки в режиме добавления запрещено. Сохраните товар, прежде чем назначить скидки." view-as alert-box error.
        undo, return error.
      end.
      if not v-flag-dgr-entry then do:
        run fill-attr-tables in this-procedure ( 'dis-gds-rule':U, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/dis-gdsi.w (
                     input parparentproc
                     ,input  mode
                     ,input 'объект':U
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input '':U
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-dis-gds-rule
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-dgr = v-update-dgr OR v-updated-now
      .
    END.
    WHEN "indicators":U then do:
      if not v-flag-gds-prop-entry  or true then do:
        run fill-attr-tables in this-procedure  ('gds-obj-prop':U, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gds-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-gds-obj-prop
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.
    when "AM":U then do:
       define variable v-spis as character no-undo .
        run ref/assmatrg.w
                      (input parparentproc
                      , "":U
                      ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input ?
                      ,input ?
                      ,input-output v-spis
                    ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
    end.
    WHEN "add-charg":U then do:
      if not v-flag-gds-prop-entry then do:
        run fill-attr-tables in this-procedure ('gds-add-charges':U, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/ad-charg.w (  input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input no
                     ,output v-updated-now
                     ,input-output table tt0-gds-add-charges
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-add-prop = v-update-add-prop OR v-updated-now
      .
    END.
    WHEN "alt-units":U then do:
  define variable v-ret-unit-name  as character no-undo .
  define variable v-ret-unit-coeff as decimal no-undo .
      run ref/alt-units.w (input parParentProc,
                           input mode,
                           input goods.gds-code,
                       input "",
                       output v-ret-unit-name,
                       output v-ret-unit-coeff) no-error .
      if error-status :error
      then do:
        assign
          loc-DOPINF-option = "":U
        .
        undo, return error.
      end.
    END.
    WHEN "orders":U then do:
      if not v-flag-gds-prop-entry or true  then do:
        run fill-attr-tables in this-procedure  ('gds-obj-prop':U + 'obj' , mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/ord-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table ttj-gds-obj-prop
                     ,input-output table ttj-gds-obj-prop-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.
    WHEN "ordersf":U then do:
      if not v-flag-gds-prop-entry or true  then do:
        run fill-attr-tables in this-procedure  ('gds-obj-prop':U + 'firm', mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/ord-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = 'ДОБАВЛЕНИЕ':U then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input 'орг':U
                     ,input v-host-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table ttf-gds-obj-prop
                     ,input-output table ttf-gds-obj-prop-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.
  end case.
  loc-DOPINF-option = "".
END.
procedure proc-b-price :
define input  parameter p-var as integer   no-undo .
define variable v-fact-order     as decimal no-undo .
define variable v-plt-id         as integer no-undo .
define variable v-plt-db-num     as integer no-undo .
define variable v-pdf-id         as integer no-undo .
define variable v-pdf-db-num     as integer no-undo .
define variable v-sale-price-doc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-var = 2 then do:
        run str/chg-sale.w
        ( input  parparentproc ,
          input  p-obj-type    ,
          input  p-obj-code    ,
          buffer goods ).
     end.
     else do:
        run str/chmplgds.w
        ( input  parparentproc ,
          input  goods.gds-code ,
          input  p-obj-type    ,
          input  p-obj-code    ,
          input  v-fact-order  ,
          output v-plt-id      ,
          output v-plt-db-num  ,
          output v-pdf-id      ,
          output v-pdf-db-num  ,
          output v-sale-price-doc ).
    end.
    apply "entry" to b-price in frame d-gds-form.
  end.
end procedure.
PROCEDURE proc-b-prodbc :
  DEFINE INPUT-OUTPUT PARAMETER loc-prodbc-option as char no-undo.
  run ref/prod-cds.w (input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input  loc-prodbc-option
                  ,input  goods.gds-code
                  ,input  main-code
                  ,output ref-list ).
  loc-prodbc-option = "".
END PROCEDURE.
PROCEDURE proc-b-sert :
  run ref/gds-sert.w ( input parparentproc
                      ,input  p-obj-type
                      ,input p-obj-code
                      ,input mode
                      ,input "gds"
                      ,input goods.gds-code
                      ,input ?
                      ,input ?
                      ,input ?) no-error.
END PROCEDURE.
PROCEDURE proc-settings:
define input-output parameter par-artic-disable like ub.sysconf.artic-disable no-undo.
define input-output parameter par-negative-rest like ub.sysconf.negative-rest no-undo.
define input-output parameter par-unq-artc as logical no-undo.
define input-output parameter par-dif-nam1 as logical no-undo.
define input-output parameter par-dif-nam2 as logical no-undo.
define input-output parameter par-dif-pdbc as logical no-undo .
define input-output parameter par-tnvedimp as logical no-undo .
define input-output parameter par-gds-copy as character no-undo .
define input-output parameter par-vattaxcd like ub.tax.tax-code no-undo.
define input-output parameter par-slttaxcd like ub.tax.tax-code no-undo.
define input-output parameter par-dfltggrp like ub.gds-grp.node-code no-undo.
define input-output parameter par-gdsfrmfi as character no-undo.
do
on error undo, return error
:
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .
define variable ii as integer no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-obj-type = ?
or p-obj-code = ? then do:
  assign
  p-obj-type = v-cntxt-obj-type
  p-obj-code = v-cntxt-obj-code
  .
end.
if p-obj-type = "":U
or p-obj-code = 0
or p-obj-type = ?
or p-obj-code = ? then do:
  message
  "Текущий объект не установлен" skip
  "Работа с карточкой товара в этом режиме еще не реализована"
  view-as alert-box error .
  undo, return error.
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
FIND ub.sysconf WHERE
     ub.sysconf.host-code = v-host-code NO-LOCK .
assign
par-artic-disable = ub.sysconf.artic-disable
par-negative-rest = ub.sysconf.negative-rest
.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  'gds-ref':U
    ,input  "":U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  delete object v-tth.
  message
  substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
            , chr(10)
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = 'gds-ref':U
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when 'dif-nam1':U then do:
      par-dif-nam1 = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'dif-nam2':U then do:
      par-dif-nam2 = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'dif-pdbc':U then do:
      par-dif-pdbc = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'gds-copy':U then do:
      par-gds-copy = thbjattr_thbj-attr.property-value-character.
    end.
    when 'tnvedimp':U then do:
      tnvedimp = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'gds-ref_obj':U
    ,input  'dfltggrp':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output par-dfltggrp
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  delete object v-tth.
  message
  substitute("Ошибка при получении опций работы со справочником товаров на объекте &4&5:&1&2 &3"
            , chr(10)
            , error-status:get-message(1)
            , return-value
            , p-obj-type
            , p-obj-code
            )
  view-as alert-box error .
  return error.
end.
do ii = 1 to num-entries(par-gds-copy):
  if ii = 1  then
  assign
  v-attr-obj-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 2  then
  assign
  v-attr-host-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 3 then
  assign
  v-fbr-gds-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 4 then
  assign
  v-s-coeff-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 5 then
  assign
  v-gds-prop-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 6 then
  assign
  v-attr-gbl-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 7 then
  assign
  v-add-prop-par = integer(entry(ii, par-gds-copy))
  no-error .
end.
assign
par-vattaxcd = integer('1':U)
par-slttaxcd = integer('2':U)
.
run uf-get in this-procedure (
    input 'gdsfrmfi':U
  ,input  v-cntxt-userid
  ,output v-uf-List_
  ,output v-uf-Naim
  ,output v-uf-print-graft
  ,output v-uf-sort-gr
  ,output v-uf-type-price
  ,output v-uf-type-val
  )  no-error.
if not error-status :error then do:
  assign
  par-gdsfrmfi = entry(1, v-uf-list_,  chr(4) ) no-error.
end.
end.
END PROCEDURE.
PROCEDURE proc-b-tax:
DEFINE VARIABLE locfor-title as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax for tt-tax.
DEFINE VARIABLE vtoday-fact-order as decimal no-undo .
if NOT can-find(first tt-tax No-LOCK ) then do:
  bell.
  return error.
end.
FOR EACH output-tax:
  DELETE output-tax.
END.
locfor-title =  "Ставки налогов и их значения: " +
                (if mode = 'ДОБАВЛЕНИЕ':U
                 then frame d-gds-form:title
                 else ( "товар с кодом " + string(goods.gds-code))
                 ).
run ref/taxgtree.w (
               input table tt-tax,
               output table output-tax,
               input parparentproc,
               input mode,
               input "GOODS":U,
               input (if mode = 'ДОБАВЛЕНИЕ':U
                      then ? else
                      goods.gds-code),
               input ?,
               input v-host-code,
               input p-obj-type,
               input p-obj-code,
               input locfor-title) no-error .
if error-status:error then return error.
DO on error UNDO, return error:
  FOR EACH tt-tax break by tt-tax.tax-code:
    if first-of(tt-tax.tax-code) then do:
      if tt-tax.individual then next.
      if mode = 'ДОБАВЛЕНИЕ':U and not copymode then v-today = 01/01/1990.
      else do:
        run cur-time in this-procedure(output v-today, output v-time).
      end.
      for each output-tax where
              output-tax.tax-code = tt-tax.tax-code:
        if output-tax.tax-rate-gds-rc <> ? then do:
          find first b_tt-tax where
                     b_tt-tax.tax-rate-gds-rc = output-tax.tax-rate-gds-rc .
          buffer-copy
          output-tax to b_tt-tax.
        end.
        else if mode = 'ДОБАВЛЕНИЕ':U and not copymode then do:
          run factord-end-day in this-procedure (input 01/01/1990 , output vtoday-fact-order).
          find first b_tt-tax where
                     b_tt-tax.tax-code = output-tax.tax-code AND
                     b_tt-tax.fact-order = vtoday-fact-order NO-ERROR.
          if avail b_tt-tax then
          buffer-copy
          output-tax to b_tt-tax.
        end.
        if output-tax.tax-rate-gds-rc = ? and (output-tax.fact-date > v-today OR
                                               ( mode = 'ДОБАВЛЕНИЕ':U and copymode AND
                                                 output-tax.fact-date = v-today )
                                              )
          then do:
          find first b_tt-tax where
                     b_tt-tax.tax-code = output-tax.tax-code and
                     b_tt-tax.fact-order = output-tax.fact-order no-error.
          if not avail b_tt-tax then create b_tt-tax.
          buffer-copy
          output-tax to b_tt-tax.
        end.
      end.
    end.
  END.
END.
OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
END PROCEDURE.
PROCEDURE proc-b-chk:
DEFINE VARIABLE rid-list as character no-undo .
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-cond as character no-undo init ?.
define variable v-grp  as character no-undo .
define variable v-old-code as integer no-undo .
define buffer buf_units for ub.units.
if lookup (mode, 'ИЗМЕНЕНИЕ,ДОБАВЛЕНИЕ':U) > 0 then do:
  if mode = 'ИЗМЕНЕНИЕ':U then do:
    g#log = yes.
    message "Выберите группу, в которую нужно переместить данный товар."
            view-as alert-box question buttons OK-Cancel update g#log.
    if not g#log then do:
      return error.
    end.
  end.
  v-grp = "".
  run ref/gds-grp.w (
                  input parparentproc
                , input ('терм':U + ',b-sel')
                , input p-obj-type
                , input p-obj-code
                , input-output v-grp).
  if v-grp = "" then do:
    return error.
  end.
  FIND ub.gds-grp WHERE recid (gds-grp) = integer (v-grp) No-ERROR.
  if not avail ub.gds-grp then do:
    return error.
  end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_upd-group':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  ub.gds-grp.node-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if NOT g#log then return error.
   define variable v-value      as character no-undo .
   define variable v-type       as character no-undo .
   define buffer buf-grp for ub.gds-grp.
   define variable v-upper like  ub.gds-grp.node-code.
   find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
      v-value = ''.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input 'alchol-grp':U,
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' or v-value = "no" then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.
        else temp-goods.alc-prod = yes .
        if v-value = "yes" then do:
     define variable v-value-mark as character no-undo .
      find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
      if available buf-grp then v-upper = buf-grp.upper-code.
      else message "Выберите группу товаров"
           view-as alert-box.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input 'mark-grp':U,
                output v-value-mark,
                output v-type
              ) no-error.
        if v-value-mark = "no" then temp-goods.alc-mark = no . else temp-goods.alc-mark = yes .
        end.
     define variable v-value-emrc as character no-undo .
     define variable v-type-emrc  as character no-undo .
     define variable old-value-emrc as character no-undo .
     old-value-emrc = "" .
     for first ub.gds-grp-obj-attr no-lock
        where ub.gds-grp-obj-attr.node-code   = v-old-code
        and ub.gds-grp-obj-attr.host-code   = 0
        and ub.gds-grp-obj-attr.obj-type    = ""
        and ub.gds-grp-obj-attr.obj-code    = 0
        and ub.gds-grp-obj-attr.attr-code   = 'emrc-type':U:
        old-value-emrc = ub.gds-grp-obj-attr.attr-value .
     end.
        for first ub.gds-grp-obj-attr no-lock
           where ub.gds-grp-obj-attr.node-code   = ub.gds-grp.node-code
           and ub.gds-grp-obj-attr.host-code   = 0
           and ub.gds-grp-obj-attr.obj-type    = ""
           and ub.gds-grp-obj-attr.obj-code    = 0
           and ub.gds-grp-obj-attr.attr-code   = 'emrc-type':U:
           v-value-emrc = ub.gds-grp-obj-attr.attr-value .
        end.
        define variable v-attr-emrc as character no-undo .
        define variable v-attr-type as character no-undo .
        define variable v-emrc-name as character no-undo .
        define variable v-del       as logical   no-undo .
        define buffer buf_goods-attr for ub.goods-attr .
        for first buf_goods-attr no-lock where buf_goods-attr.attr-code = 'emrc-type':U and
           buf_goods-attr.gds-code = temp-goods.gds-code:
           v-attr-emrc = buf_goods-attr.attr-value .
        end.
        if v-value-emrc <> old-value-emrc and v-attr-emrc = "" then
        do:
           message "При переносе в группу " + string(ub.gds-grp.node-name) + " для товара " + string(temp-goods.gds-name) skip
              "будет наследоваться значение новой группы тип ЕМЦ-" + if v-value-emrc <> "" then v-value-emrc else "000" + ". " skip
              "При утвердительном ответе товар переносится в новую группу, значение тип ЕМЦ-" + string (if v-value-emrc <> "" then v-value-emrc else "000")
              view-as alert-box question buttons yes-no-cancel update choice as logical .
           CASE choice:
              WHEN TRUE THEN
                 DO:
                 END.
              WHEN FALSE THEN
                 DO:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input temp-goods.gds-code
                       ,INPUT 'emrc-type':U
                       ,INPUT old-value-emrc ) .
                 END.
              OTHERWISE
              DO:
                 return error.
              end.
           END CASE.
        end.
   define variable lChoice as integer no-undo .
   if v-value-emrc <> v-attr-emrc and v-attr-emrc <> "" then
   do:
      find first ub.code no-lock where ub.Code.parent = "EMC" and ub.Code.code = v-attr-emrc no-error .
      if not available (ub.Code) then v-emrc-name = "Нет" .
      else v-emrc-name = ub.Code.CodeName .
      run gbl/d-askw.w (
         input "Сообщение"
         ,input  "На товар установлен атрибут «тип ЕМЦ» - " + v-emrc-name + ". При переносе товара значение может быть изменено."
         ,input "|"
         ,input "Наследовать|Оставить|Отмена"
         ,input "Наследовать атрибут от новой группы|Оставить текущее значение атрибута|Отмена"
         ,input 1
         ,input 3
         ,output lChoice).
      CASE lChoice:
         WHEN 1 THEN
            DO:
               if v-value-emrc = "" then
               do:
                  run gds-attr-delete IN THIS-PROCEDURE(
                     input temp-goods.gds-code
                     ,INPUT 'emrc-type':U
                     ,output v-del ) .
               end.
               else
               do:
                  run gds-attr-write IN THIS-PROCEDURE(
                     input temp-goods.gds-code
                     ,INPUT 'emrc-type':U
                     ,INPUT v-value-emrc ) NO-ERROR.
               end.
            END.
         WHEN 2 THEN
            DO:
               run gds-attr-write IN THIS-PROCEDURE(
                  input temp-goods.gds-code
                  ,INPUT 'emrc-type':U
                  ,INPUT v-attr-emrc ) .
            END.
         OTHERWISE
         DO:
            return error.
         end.
      END CASE.
   end.
  run chkgrp in this-procedure (buffer gds-grp) no-error .
  if error-status:error then return error.
  grp-full = "".
  RUN grplib-get-full-name in this-procedure (input ub.gds-grp.node-code, output grp-full).
  if length (grp-full) > 79 then
    grp-full = "..." + substr (grp-full, length (grp-full) - 79).
  run leave-unit-base(goods.unit-base:screen-value in frame d-gds-form) no-error.
  if error-status:error then do:
    return error.
  end.
  DISPLAY grp-full with frame d-gds-form.
  if goods.artic:sensitive then
    apply "entry" to goods.artic in frame d-gds-form.
  else
    apply "entry" to goods.gds-name in frame d-gds-form.
end.
else do:
    if ub.gds-prt.node-name = '_Пустая шкала':U or not v-doc-prt then do:
      find first buf_units No-LOCK WHERE
                buf_units.unit-name = ub.goods.unit-base .
      if lookup('сер':U, buf_units.type ) > 0 then do:
        run ref/gds-chks.w (input parparentproc
                      ,input recid(goods)
                      ,input "":U
                      ,input 'объект':U
                      ,input ?
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input "":U
                      ,input "":U
                      ,output rid-list
                        ).
      end.
      else do:
        run ref/gds-chk.w (
                       input parparentproc
                      ,input main-code
                      ,input "":U
                      ,input 'объект':U
                      ,input ?
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input "":U
                      ,input "":U
                      ,output rid-list
                        ).
      end.
    end.
  else
    message "Товар делится на признаки - смотрите чеки через шкалу."
            view-as alert-box INFORMATION .
  return error.
end.
END PROCEDURE.
PROCEDURE chkgrp:
define parameter buffer buf_gds-grp for ub.gds-grp.
run ref/dtaxgrps.p (buf_gds-grp.node-code,
               buf_gds-grp.upper-code,
               v-host-code,
               p-obj-type,
               p-obj-code) no-error.
if error-status:error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  for each tt-tax:
    delete tt-tax.
  end.
  return error.
end.
for each tt-tax:
  delete tt-tax.
end.
if goods.calc-method:screen-value in frame d-gds-form  = 'Группа':U  then do:
  if LOOKUP(buf_gds-grp.calc-method, goods.calc-method:list-items in frame d-gds-form) = 0 or
     buf_gds-grp.calc-method = ? then do:
    message "Неверный способ расчета учетной цены для товаров группы"
    view-as alert-box error .
    return error.
  end.
end.
END PROCEDURE.
procedure fill-attr-tables :
define input parameter p-table as character no-undo .
define input parameter p-mode  as character no-undo .
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-range as integer no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable other-db-num  like ub.db.db-num no-undo .
define variable other-host-code    like ub.sysconf.host-code no-undo .
define variable v-copy         as logical no-undo .
define variable v-update-attr  as logical no-undo .
define variable v-is-error     as logical no-undo .
define variable v-id           as integer no-undo .
define variable v-proc-handle  as handle  no-undo .
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_s-coeff    for ub.s-coeff.
do
on error undo, return error return-value
on stop undo, return error return-value
:
  CASE p-mode:
     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
        CASE p-table:
          when 'dis-gds-rule':U then do:
            FOR EACH tt0-dis-gds-rule:
              DELETE tt0-dis-gds-rule.
            END.
             FOR EACH locked_dis-gds-rule EXCLUSIVE-LOCK where
                      locked_dis-gds-rule.gds-code = goods.gds-code
                  AND (
                       (locked_dis-gds-rule.obj-type = p-obj-type
                  AND locked_dis-gds-rule.obj-code = p-obj-code)
                  or   (v-cntxt-db-num = 0
                       and
                       (locked_dis-gds-rule.obj-type = 'орг':U
                  AND locked_dis-gds-rule.obj-code = v-host-code))
                  or  (v-cntxt-db-num = 0
                      and
                      (locked_dis-gds-rule.obj-type = '':U
                  AND locked_dis-gds-rule.obj-code = 0))
                  )
              on error undo, return error "Записи Атрибутов товара на объекте заняты"
              :
                if locked_dis-gds-rule.discnt-role = '':U
                and locked_dis-gds-rule.pos-type = '':U
                and locked_dis-gds-rule.nonunique = '':U then next.
                run trg/lock-dgr.p persistent set v-proc-handle (recid(locked_dis-gds-rule)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-dgr.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-dis-gds-rule.
                BUFFER-COPY locked_dis-gds-rule TO tt0-dis-gds-rule.
            END.
            v-flag-dgr-entry = yes.
            FOR EACH buf_dis-gds-rule no-lock where
                    buf_dis-gds-rule.gds-code = goods.gds-code
            on error undo, return error
            :
                if (buf_dis-gds-rule.obj-type = p-obj-type
                AND buf_dis-gds-rule.obj-code = p-obj-code)
                or (v-cntxt-db-num = 0
                    and
                    (buf_dis-gds-rule.obj-type = 'орг':U
                AND buf_dis-gds-rule.obj-code = v-host-code))
                or (v-cntxt-db-num = 0
                    and
                    (buf_dis-gds-rule.obj-type = '':U
                AND buf_dis-gds-rule.obj-code = 0))
                   then NEXT.
                CREATE tt0-dis-gds-rule.
                BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
            END.
          end.
          when 'gds-obj-attr':U then do:
            FOR EACH tt0-gds-obj-attr:
              DELETE tt0-gds-obj-attr.
            END.
             FOR EACH locked_gds-obj-attr EXCLUSIVE-LOCK where
                      locked_gds-obj-attr.gds-code = goods.gds-code
                  AND locked_gds-obj-attr.obj-type = p-obj-type
                  AND locked_gds-obj-attr.obj-code = p-obj-code
              on error undo, return error "Записи Атрибутов товара на объекте заняты"
              :
                run trg/lock-goa.p persistent set v-proc-handle (recid(locked_gds-obj-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-goa.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-gds-obj-attr.
                BUFFER-COPY locked_gds-obj-attr TO tt0-gds-obj-attr.
            END.
            v-flag-attr-obj-entry = yes.
            FOR EACH buf_gds-obj-attr no-lock where
                    buf_gds-obj-attr.gds-code = goods.gds-code
            on error undo, return error
            :
                if buf_gds-obj-attr.obj-type = p-obj-type
                AND buf_gds-obj-attr.obj-code = p-obj-code then NEXT.
                CREATE tt0-gds-obj-attr.
                BUFFER-COPY buf_gds-obj-attr TO tt0-gds-obj-attr.
            END.
          end.
          when 'goods-attr':U then do:
            FOR EACH tt0-goods-attr WHERE tt0-goods-attr.attr-code <> 'alcohol-prod':U:
              DELETE tt0-goods-attr.
            END.
            FOR EACH locked_goods-attr EXCLUSIVE-LOCK where
                    locked_goods-attr.gds-code = goods.gds-code
            on error undo, return error "Записи Глобальных Атрибутов товара на фирме заняты"
            :
                run trg/lock-ga.p persistent set v-proc-handle (recid(locked_goods-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-ga.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-goods-attr.
                BUFFER-COPY locked_goods-attr TO tt0-goods-attr.
            END.
            v-flag-attr-gbl-entry = yes.
          end.
          when 'gds-host-attr':U then do:
            FOR EACH tt0-gds-host-attr:
              DELETE tt0-gds-host-attr.
            END.
            FOR EACH locked_gds-host-attr EXCLUSIVE-LOCK where
                    locked_gds-host-attr.gds-code = goods.gds-code
                AND locked_gds-host-attr.host-code = v-host-code
            on error undo, return error "Записи Атрибутов товара на фирме заняты"
            :
                run trg/lock-gha.p persistent set v-proc-handle (recid(locked_gds-host-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-gha.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-gds-host-attr.
                BUFFER-COPY locked_gds-host-attr TO tt0-gds-host-attr.
            END.
            v-flag-attr-host-entry = yes.
          end.
          when 'fbr-gds-obj':U then do:
            FOR EACH tt0-fbr-gds-obj:
              DELETE tt0-fbr-gds-obj.
            END.
            FIND FIRST locked_fbr-gds-obj EXCLUSIVE-LOCK where
                    locked_fbr-gds-obj.gds-code = goods.gds-code
                AND locked_fbr-gds-obj.obj-type = p-obj-type
                AND locked_fbr-gds-obj.obj-code = p-obj-code NO-WAIT no-error.
            if not available locked_fbr-gds-obj then do:
              if locked locked_fbr-gds-obj then do:
                return error  "Запись атрибуты РЕСТОРАН товара на объекте занята".
              end.
            end.
            if available locked_fbr-gds-obj then do:
              assign
              v-fbr-gds-obj-recid = recid(locked_fbr-gds-obj).
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj TO tt0-fbr-gds-obj.
            end.
          v-flag-fbr-gds-entry = yes.
        end.
        when 's-coeff':U then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
          find first locked_s-coeff exclusive-lock where
                      locked_s-coeff.gds-code = goods.gds-code
                AND locked_s-coeff.s-date = 01/01/1996
                AND locked_s-coeff.host-code = 0
                AND locked_s-coeff.obj-type = "":U
                AND locked_s-coeff.obj-code = 0 no-wait no-error.
          if not available locked_s-coeff then do:
            if locked locked_s-coeff then do:
              return error  "Записи сезонных коэффициентов к товару сейчас заняты".
            end.
          end.
          FOR EACH buf_s-coeff no-lock where
                  buf_s-coeff.gds-code = goods.gds-code
          on error undo, return error
          :
              CREATE tt0-s-coeff.
              BUFFER-COPY buf_s-coeff TO tt0-s-coeff.
          END.
          v-flag-s-coeff-entry = yes.
        end.
        when 'gds-obj-prop':U then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись индикаторов/атрибутов для заказа товара на объекте занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE tt0-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO tt0-gds-obj-prop.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when 'gds-obj-prop':U + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись индикаторов/атрибутов для заказа товара на объекте занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE ttj-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO ttj-gds-obj-prop.
          end.
          for each locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = goods.gds-code
              AND locked_gds-obj-prop-attr.obj-type = p-obj-type
              AND locked_gds-obj-prop-attr.obj-code = p-obj-code :
            if lookup(locked_gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
            CREATE ttj-gds-obj-prop-attr.
            BUFFER-COPY locked_gds-obj-prop-attr TO ttj-gds-obj-prop-attr.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when 'gds-obj-prop':U + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = 'орг':U
              AND locked_gds-obj-prop.obj-code = v-host-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись параметров товара на фирме занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE ttf-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO ttf-gds-obj-prop.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when 'gds-add-charges':U then do:
          FOR EACH tt0-gds-add-charges:
            DELETE tt0-gds-add-charges.
          END.
          FIND FIRST locked_gds-add-charges EXCLUSIVE-LOCK where
                  locked_gds-add-charges.gds-code = goods.gds-code
              NO-WAIT no-error.
          if not available locked_gds-add-charges then do:
            if locked locked_gds-add-charges then do:
              return error  "Запись дополнитеотных расходов".
            end.
          end.
          if available locked_gds-add-charges then do:
            assign
            v-add-prop-recid = recid(locked_gds-add-charges).
            CREATE tt0-gds-add-charges.
            BUFFER-COPY locked_gds-add-charges TO tt0-gds-add-charges.
          end.
        v-flag-add-prop-entry = yes.
      end.
      END CASE.
    END.
    WHEN 'ПРОСМОТР':U THEN DO:
      CASE p-table:
        when 'dis-gds-rule':U then do:
          FOR EACH tt0-dis-gds-rule:
            DELETE tt0-dis-gds-rule.
          END.
          FOR EACH locked_dis-gds-rule no-LOCK where
              locked_dis-gds-rule.gds-code = goods.gds-code:
              CREATE tt0-dis-gds-rule.
              BUFFER-COPY locked_dis-gds-rule TO tt0-dis-gds-rule.
          END.
        end.
        when 'gds-obj-attr':U then do:
          FOR EACH tt0-gds-obj-attr:
            DELETE tt0-gds-obj-attr.
          END.
          FOR EACH locked_gds-obj-attr no-LOCK where
              locked_gds-obj-attr.gds-code = goods.gds-code:
              CREATE tt0-gds-obj-attr.
              BUFFER-COPY locked_gds-obj-attr TO tt0-gds-obj-attr.
          END.
        end.
        when 'goods-attr':U then do:
          FOR EACH tt0-goods-attr:
            DELETE tt0-goods-attr.
          END.
          FOR EACH locked_goods-attr no-LOCK where
              locked_goods-attr.gds-code = goods.gds-code:
              CREATE tt0-goods-attr.
              BUFFER-COPY locked_goods-attr TO tt0-goods-attr.
          END.
        end.
        when 'gds-host-attr':U then do:
          FOR EACH tt0-gds-host-attr:
            DELETE tt0-gds-host-attr.
          END.
          FOR EACH locked_gds-host-attr no-LOCK where
              locked_gds-host-attr.gds-code = goods.gds-code
            AND locked_gds-host-attr.host-code = v-host-code:
              CREATE tt0-gds-host-attr.
              BUFFER-COPY locked_gds-host-attr TO tt0-gds-host-attr.
          END.
        end.
        when 'fbr-gds-obj':U then do:
          FOR EACH tt0-fbr-gds-obj:
            DELETE tt0-fbr-gds-obj.
          END.
          FOR EACH locked_fbr-gds-obj no-lock where
                  locked_fbr-gds-obj.gds-code = goods.gds-code
              AND locked_fbr-gds-obj.obj-type = p-obj-type
              AND locked_fbr-gds-obj.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj TO tt0-fbr-gds-obj.
          END.
        end.
        when 's-coeff':U then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
        end.
        when 'gds-obj-prop':U then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE tt0-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO tt0-gds-obj-prop.
          END.
        end.
        when 'gds-obj-prop':U + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          FOR EACH ttj-gds-obj-prop-attr:
            DELETE ttj-gds-obj-prop-attr.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE ttj-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO ttj-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = goods.gds-code
              AND locked_gds-obj-prop-attr.obj-type = p-obj-type
              AND locked_gds-obj-prop-attr.obj-code = p-obj-code
          on error undo, return error
          :
            if lookup(locked_gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
            CREATE ttj-gds-obj-prop-attr.
            BUFFER-COPY locked_gds-obj-prop-attr TO ttj-gds-obj-prop-attr.
          END.
        end.
        when 'gds-obj-prop':U + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = 'орг':U
              AND locked_gds-obj-prop.obj-code = v-host-code
          on error undo, return error
          :
              CREATE ttf-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO ttf-gds-obj-prop.
          END.
        end.
        when 'gds-add-charges':U then do:
          FOR EACH tt0-gds-add-charges:
            DELETE tt0-gds-add-charges.
          END.
          FOR EACH locked_gds-add-charges no-lock where
                  locked_gds-add-charges.gds-code = goods.gds-code
          on error undo, return error
          :
              CREATE tt0-gds-add-charges.
              BUFFER-COPY locked_gds-add-charges TO tt0-gds-add-charges.
          END.
        end.
      END CASE.
    END.
    WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
      if not copymode then return.
      CASE p-table:
        when 'gds-obj-attr':U then do:
          FOR EACH tt0-gds-obj-attr:
            DELETE tt0-gds-obj-attr.
          END.
          if v-attr-obj-par <> 0 then do:
            _gds-obj-attr:
            FOR EACH locked_gds-obj-attr no-lock where
                    locked_gds-obj-attr.gds-code = for-goods.gds-code:
              if v-attr-obj-par = 1
              and (locked_gds-obj-attr.obj-type <> p-obj-type
                  or
                  locked_gds-obj-attr.obj-code <> p-obj-code) then NEXT _gds-obj-attr.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-attr-obj-par = 2
              or v-attr-obj-par = 3
              then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-attr.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _gds-obj-attr.
                end.
              end.
              run gdsoattr-copy in this-procedure
                (input  locked_gds-obj-attr.attr-code
                ,output v-copy
                ) no-error .
              if error-status:error or not v-copy then next _gds-obj-attr.
              assign
              v-found-copy-atr-obj = yes.
              CREATE tt0-gds-obj-attr.
              BUFFER-COPY locked_gds-obj-attr EXCEPT gds-code TO tt0-gds-obj-attr.
            END.
          end.
          v-flag-attr-obj-entry = yes.
        end.
        when 'goods-attr':U then do:
          FOR EACH tt0-goods-attr:
            DELETE tt0-goods-attr.
          END.
          if v-attr-gbl-par <> 0 then do:
            _goods-attr:
            FOR EACH locked_goods-attr no-lock where
                    locked_goods-attr.gds-code = (if copymode then for-goods.gds-code else 0):
              run gds-attr-copy in this-procedure
                (input  locked_goods-attr.attr-code
                ,output v-copy
                ) no-error .
              if error-status:error or not v-copy then next _goods-attr.
              assign
              v-found-copy-atr-gbl = yes.
              CREATE tt0-goods-attr.
              BUFFER-COPY locked_goods-attr EXCEPT gds-code TO tt0-goods-attr.
            END.
          end.
          v-flag-attr-gbl-entry = yes.
        end.
        when 'gds-host-attr':U then do:
            FOR EACH tt0-gds-host-attr:
              DELETE tt0-gds-host-attr.
            END.
          if v-attr-host-par <> 0 then do:
            _gds-host-attr:
            FOR EACH locked_gds-host-attr no-lock where
                    locked_gds-host-attr.gds-code = for-goods.gds-code:
              if v-attr-host-par = 1
              and locked_gds-host-attr.host-code <> v-host-code then next _gds-host-attr.
              run gdshattr-copy in this-procedure
                (input  locked_gds-host-attr.attr-code
                ,output v-copy
                ) no-error .
              if error-status:error or not v-copy then next _gds-host-attr.
              assign
              v-found-copy-atr-host = yes.
              CREATE tt0-gds-host-attr.
              BUFFER-COPY locked_gds-host-attr EXCEPT gds-code TO tt0-gds-host-attr.
            END.
          end.
          v-flag-attr-host-entry = yes.
        end.
        when 'fbr-gds-obj':U then do:
          FOR EACH tt0-fbr-gds-obj:
            DELETE tt0-fbr-gds-obj.
          END.
          if v-fbr-gds-par <> 0 then do:
            _fbr-gds-obj:
            FOR EACH locked_fbr-gds-obj no-lock where
                  locked_fbr-gds-obj.gds-code = for-goods.gds-code:
              if v-fbr-gds-par = 1
              and (locked_fbr-gds-obj.obj-type <> p-obj-type
                  or
                  locked_fbr-gds-obj.obj-code <> p-obj-code) then NEXT _fbr-gds-obj.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-fbr-gds-par = 2
              or v-fbr-gds-par = 3
              then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_fbr-gds-obj.obj-type
  ,input  locked_fbr-gds-obj.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _fbr-gds-obj.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _fbr-gds-obj.
                end.
              end.
              assign
              v-found-copy-fbr-gds = yes.
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj EXCEPT gds-code TO tt0-fbr-gds-obj.
            END.
          end.
          v-flag-fbr-gds-entry = yes.
        end.
        when 's-coeff':U then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
          if v-s-coeff-par <> 0 then do:
            _s-coeff:
            FOR EACH buf_s-coeff no-lock where
                    buf_s-coeff.gds-code = for-goods.gds-code
            on error undo, return error
            :
              if v-s-coeff-par = 1
              and buf_s-coeff.host-code <> 0
              and (buf_s-coeff.obj-type <> p-obj-type
                  or
                  buf_s-coeff.obj-code <> p-obj-code) then NEXT _s-coeff.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-s-coeff-par = 2
              or v-s-coeff-par = 3
              then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_s-coeff.obj-type
  ,input  buf_s-coeff.obj-code
  ,output other-db-num
  ) no-error .
                if buf_s-coeff.host-code <> 0
                and other-db-num <> v-cntxt-db-num  then NEXT _s-coeff.
                if v-s-coeff-par = 2 then do:
                  if buf_s-coeff.host-code <> 0
                  And other-host-code <> buf_s-coeff.host-code then next _s-coeff.
                end.
              end.
              v-found-copy-s-coeff = yes.
              CREATE tt0-s-coeff.
              BUFFER-COPY buf_s-coeff except gds-code TO tt0-s-coeff.
            END.
            v-flag-s-coeff-entry = yes.
          end.
        end.
        when 'gds-obj-prop':U then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop.obj-code <> p-obj-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_gds-obj-prop.obj-type
  ,input  locked_gds-obj-prop.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE tt0-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO tt0-gds-obj-prop.
            END.
          end.
          v-flag-gds-prop-entry = yes.
        end.
        when 'gds-obj-prop':U + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop.obj-code <> p-obj-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_gds-obj-prop.obj-type
  ,input  locked_gds-obj-prop.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttj-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO ttj-gds-obj-prop.
            END.
          end.
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop-attr:
            FOR EACH locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = for-goods.gds-code:
              if lookup(locked_gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop-attr.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop-attr.obj-code <> p-obj-code) then NEXT _gds-obj-prop-attr.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_gds-obj-prop-attr.obj-type
  ,input  locked_gds-obj-prop-attr.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop-attr.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _gds-obj-prop-attr.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttj-gds-obj-prop-attr.
              BUFFER-COPY locked_gds-obj-prop-attr EXCEPT gds-code TO ttj-gds-obj-prop-attr.
          end.
          end.
          v-flag-gds-prop-entry = yes.
        end.
        when 'gds-obj-prop':U + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          FOR EACH ttf-gds-obj-prop-attr:
            DELETE ttf-gds-obj-prop-attr.
          END.
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> 'орг':U
                  or
                  locked_gds-obj-prop.obj-code <> v-host-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  locked_gds-obj-prop.obj-type
  ,input  locked_gds-obj-prop.obj-code
  ,output other-db-num
  ) no-error .
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  locked_gds-obj-attr.obj-type
  ,input  locked_gds-obj-attr.obj-code
  ,output other-host-code
  ) no-error .
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttf-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO ttf-gds-obj-prop.
            END.
          end.
          v-flag-gds-prop-entry = yes.
        end.
      END CASE.
    END.
  END CASE.
end.
end procedure.
procedure check-update-attr :
define input parameter p-exit-without-save as logical no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable v-updated as logical no-undo .
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-loc-update as logical no-undo .
do
on error undo, return error
  :
  if mode <> 'ДОБАВЛЕНИЕ':U then do:
    if v-update-attr-obj then do:
      v-loc-update = no.
      for each tt0-gds-obj-attr NO-LOCK where
              tt0-gds-obj-attr.obj-type = p-obj-type
            AND tt0-gds-obj-attr.obj-code = p-obj-code:
        find first locked_gds-obj-attr NO-LOCK WHERE
                locked_gds-obj-attr.gds-code = tt0-gds-obj-attr.gds-code
          AND   locked_gds-obj-attr.obj-type = tt0-gds-obj-attr.obj-type
          AND   locked_gds-obj-attr.obj-code = tt0-gds-obj-attr.obj-code
          AND   locked_gds-obj-attr.attr-code = tt0-gds-obj-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_gds-obj-attr then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-gds-obj-attr
                      TO locked_gds-obj-attr
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
        ASSIGN
        v-loc-update = (v-updated or v-loc-update).
      End.
      FOR EACH locked_gds-obj-attr where
              locked_gds-obj-attr.gds-code = goods.gds-code
          AND locked_gds-obj-attr.obj-type = p-obj-type
          AND locked_gds-obj-attr.obj-code = p-obj-code
              :
        FIND FIRST tt0-gds-obj-attr NO-LOCK WHERE
                  tt0-gds-obj-attr.gds-code = locked_gds-obj-attr.gds-code
              AND tt0-gds-obj-attr.obj-type = locked_gds-obj-attr.obj-type
              AND tt0-gds-obj-attr.obj-code = locked_gds-obj-attr.obj-code
              AND tt0-gds-obj-attr.attr-code = locked_gds-obj-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-gds-obj-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-attr-obj = v-loc-update.
    end.
    if v-update-dgr then do:
      v-loc-update = no.
      for each tt0-dis-gds-rule NO-LOCK where
                (tt0-dis-gds-rule.obj-type = p-obj-type
            AND tt0-dis-gds-rule.obj-code = p-obj-code)
            or  (v-cntxt-db-num = 0
                and
                (tt0-dis-gds-rule.obj-type = 'орг':U
            AND tt0-dis-gds-rule.obj-code = v-host-code))
            or  (v-cntxt-db-num = 0
                and
                (tt0-dis-gds-rule.obj-type = '':U
            AND tt0-dis-gds-rule.obj-code = 0))
            :
        find first locked_dis-gds-rule NO-LOCK WHERE
                locked_dis-gds-rule.gds-code = tt0-dis-gds-rule.gds-code
          AND   locked_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
          AND   locked_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
          AND   locked_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
          AND   locked_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
          AND   locked_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
           no-error.
        assign
        v-updated = no.
        if available  locked_dis-gds-rule then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-dis-gds-rule
                      TO locked_dis-gds-rule
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
        ASSIGN
        v-loc-update = (v-updated or v-loc-update).
      End.
      FOR EACH locked_dis-gds-rule where
              locked_dis-gds-rule.gds-code = goods.gds-code
           and  (
                (locked_dis-gds-rule.obj-type = p-obj-type
            AND locked_dis-gds-rule.obj-code = p-obj-code)
            or  (v-cntxt-db-num = 0
                and
                (locked_dis-gds-rule.obj-type = 'орг':U
            AND locked_dis-gds-rule.obj-code = v-host-code))
            or  (v-cntxt-db-num = 0
                and
                (locked_dis-gds-rule.obj-type = '':U
            AND locked_dis-gds-rule.obj-code = 0))
            )
              :
        FIND FIRST tt0-dis-gds-rule NO-LOCK WHERE
                  tt0-dis-gds-rule.gds-code = locked_dis-gds-rule.gds-code
              AND tt0-dis-gds-rule.obj-type = locked_dis-gds-rule.obj-type
              AND tt0-dis-gds-rule.obj-code = locked_dis-gds-rule.obj-code
              AND tt0-dis-gds-rule.pos-type = locked_dis-gds-rule.pos-type
              AND tt0-dis-gds-rule.discnt-role = locked_dis-gds-rule.discnt-role
              AND tt0-dis-gds-rule.nonunique = locked_dis-gds-rule.nonunique
                NO-ERROR.
          IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-dgr = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-attr-host then do:
      v-loc-update = no.
      for each tt0-gds-host-attr NO-LOCK where
              tt0-gds-host-attr.gds-code = goods.gds-code
            AND tt0-gds-host-attr.host-code = v-host-code:
        find first locked_gds-host-attr NO-LOCK WHERE
                locked_gds-host-attr.gds-code = tt0-gds-host-attr.gds-code
          AND   locked_gds-host-attr.host-code = tt0-gds-host-attr.host-code
          AND   locked_gds-host-attr.attr-code = tt0-gds-host-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_gds-host-attr then do:
         v-updated-str = "":U.
          BUFFER-COMPARE tt0-gds-host-attr
                      TO locked_gds-host-attr
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
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_gds-host-attr where
              locked_gds-host-attr.gds-code = goods.gds-code
          AND locked_gds-host-attr.host-code = v-host-code
              :
        FIND FIRST tt0-gds-host-attr NO-LOCK WHERE
                  tt0-gds-host-attr.gds-code = locked_gds-host-attr.gds-code
              AND tt0-gds-host-attr.host-code = locked_gds-host-attr.host-code
              AND tt0-gds-host-attr.attr-code = locked_gds-host-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-gds-host-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-attr-host = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-attr-gbl then do:
      v-loc-update = no.
      for each tt0-goods-attr NO-LOCK where
              tt0-goods-attr.gds-code = goods.gds-code:
        find first locked_goods-attr NO-LOCK WHERE
                locked_goods-attr.gds-code = tt0-goods-attr.gds-code
          AND   locked_goods-attr.attr-code = tt0-goods-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_goods-attr then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-goods-attr
                      TO locked_goods-attr
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
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_goods-attr where
              locked_goods-attr.gds-code = goods.gds-code:
        FIND FIRST tt0-goods-attr NO-LOCK WHERE
                  tt0-goods-attr.gds-code = locked_goods-attr.gds-code
              AND tt0-goods-attr.attr-code = locked_goods-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-goods-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update ).
          END.
      END.
      v-update-attr-host = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-fbr-gds then do:
      find first tt0-fbr-gds-obj no-error.
      if available locked_fbr-gds-obj
      and available tt0-fbr-gds-obj
      then do:
        v-updated-str = "":U.
        buffer-compare locked_fbr-gds-obj
        to tt0-fbr-gds-obj
        case-sensitive
        save result in v-updated-str.
        v-update-fbr-gds = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-fbr-gds-obj then
        v-update-fbr-gds = yes.
      end.
    end.
    if v-update-s-coeff then do:
      v-loc-update = no.
      for each tt0-s-coeff NO-LOCK:
        find first locked_s-coeff NO-LOCK WHERE
                locked_s-coeff.gds-code = tt0-s-coeff.gds-code
          AND   locked_s-coeff.host-code = tt0-s-coeff.host-code
          AND   locked_s-coeff.obj-type = tt0-s-coeff.obj-type
          AND   locked_s-coeff.obj-code = tt0-s-coeff.obj-code
          AND   locked_s-coeff.s-date   = tt0-s-coeff.s-date no-error.
        assign
        v-updated = no.
        if available  locked_s-coeff then do:
          BUFFER-COMPARE tt0-s-coeff
                      TO locked_s-coeff
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
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_s-coeff where
              locked_s-coeff.gds-code = goods.gds-code :
        FIND FIRST tt0-s-coeff NO-LOCK WHERE
                  tt0-s-coeff.gds-code = locked_s-coeff.gds-code
              AND tt0-s-coeff.host-code = locked_s-coeff.host-code
              AND tt0-s-coeff.obj-type = locked_s-coeff.obj-type
              AND tt0-s-coeff.obj-code = locked_s-coeff.obj-code
              AND tt0-s-coeff.s-date = locked_s-coeff.s-date NO-ERROR.
          IF NOT AVAILABLE tt0-s-coeff THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-s-coeff = v-loc-update.
    end.
    if v-update-gds-prop then do:
      find first tt0-gds-obj-prop no-error.
      if available locked_gds-obj-prop
      and available tt0-gds-obj-prop
      then do:
        v-updated-str = "":U.
        buffer-compare locked_gds-obj-prop
        to tt0-gds-obj-prop
        case-sensitive
        save result in v-updated-str.
        v-update-gds-prop = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-gds-obj-prop then
        v-update-gds-prop = yes.
      end.
      if v-update-gds-prop = false then do:
          find first ttf-gds-obj-prop no-error.
          if available locked_gds-obj-prop
          and available ttf-gds-obj-prop
          then do:
            v-updated-str = "":U.
            buffer-compare locked_gds-obj-prop
            to ttf-gds-obj-prop
            case-sensitive
            save result in v-updated-str.
            v-update-gds-prop = (v-updated-str <> "":U).
          end.
          else do:
            if available ttf-gds-obj-prop then
            v-update-gds-prop = yes.
          end.
            if v-update-gds-prop = false then do:
                find first ttj-gds-obj-prop no-error.
                if available locked_gds-obj-prop
                and available ttj-gds-obj-prop
                then do:
                  v-updated-str = "":U.
                  buffer-compare locked_gds-obj-prop
                  to ttj-gds-obj-prop
                  case-sensitive
                  save result in v-updated-str.
                  v-update-gds-prop = (v-updated-str <> "":U).
                end.
                else do:
                  if available ttj-gds-obj-prop then
                  v-update-gds-prop = yes.
                end.
          if v-update-gds-prop = false then do:
            for each ttj-gds-obj-prop-attr:
              if lookup(ttj-gds-obj-prop-attr.attr-code, 'CorrIztDel':u) > 0 then next.
              find first locked_gds-obj-prop-attr share-lock where
                        locked_gds-obj-prop-attr.gds-code = ttj-gds-obj-prop-attr.gds-code
                   and  locked_gds-obj-prop-attr.obj-type = ttj-gds-obj-prop-attr.obj-type
                   and  locked_gds-obj-prop-attr.obj-code = ttj-gds-obj-prop-attr.obj-code
                   and  locked_gds-obj-prop-attr.attr-code = ttj-gds-obj-prop-attr.attr-code no-error.
              if available locked_gds-obj-prop-attr then do:
                 buffer-compare locked_gds-obj-prop-attr
                 to ttj-gds-obj-prop-attr
                 case-sensitive
                 save result in v-updated-str.
                 v-update-gds-prop = (v-update-gds-prop or (v-updated-str <> "":U)).
              end.
              else do:
                define variable v-format         as character no-undo .
                define variable v-label          as character no-undo .
                define variable v-user-can-edit  as logical   no-undo .
                define variable v-output-display as logical   no-undo .
                define variable v-other          as character no-undo .
                define variable v-type           as character no-undo .
                define variable jj as integer no-undo .
                define variable v-init-value as character no-undo .
                run gdspoatr-name in this-procedure
                  (input  locked_gds-obj-prop-attr.attr-code
                  ,output v-type
                  ,output v-format
                  ,output v-label
                  ,output v-user-can-edit
                  ,output v-output-display
                  ,output v-other
                  ) no-error .
                if error-status :error then do:
                  undo, return error return-value .
              end.
                do jj = 1 to num-entries(v-other, chr(47)):
                  if entry(1, entry(jj, v-other, chr(47)), "=":U) = "init-value":U then do:
                    assign
                    v-init-value = string(entry(2, entry(jj, v-other, chr(47)), "=":U))
                    .
                  end.
                end.
                if ttj-gds-obj-prop-attr.attr-value <> v-init-value then do:
                  v-update-gds-prop = yes.
      end.
    end.
            end.
          end.
        end.
      end.
    end.
    if v-update-add-prop then do:
      find first tt0-gds-add-charges no-error.
      if available locked_gds-add-charges
      and available tt0-gds-add-charges
      then do:
        v-updated-str = "":U.
        buffer-compare locked_gds-add-charges
        to tt0-gds-add-charges
        case-sensitive
        save result in v-updated-str.
        v-update-add-prop = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-gds-add-charges then
        v-update-add-prop = yes.
      end.
    end.
  end.
  if copymode and v-found-copy-atr-obj then v-update-attr-obj = yes.
  if copymode and v-found-copy-atr-host then v-update-attr-host = yes.
  if copymode and v-found-copy-atr-gbl then v-update-attr-gbl = yes.
  if copymode and v-found-copy-fbr-gds  then v-update-fbr-gds = yes.
  if copymode and v-found-copy-s-coeff  then v-update-s-coeff = yes.
  if copymode and v-found-copy-gds-prop  then v-update-gds-prop = yes.
  if copymode and v-found-copy-add-prop  then v-update-add-prop = yes.
  if copymode and v-found-copy-dgr       then v-update-dgr = yes.
  if mode = 'ДОБАВЛЕНИЕ':U then return.
  if not p-exit-without-save then return.
  if v-update-attr-obj
  or v-update-attr-host
  or v-update-attr-gbl
  or v-update-fbr-gds
  or v-update-s-coeff
  or v-update-gds-prop
  or v-update-add-prop
  or v-update-dgr
  THEN DO:
       MESSAGE
      ( (if v-update-attr-obj
        then "Были изменены атрибуты товара на объекте"
        else "":U) + chr(10) +
      (if v-found-copy-atr-obj then " или были унаследованы атрибуты товара на объекте" else "":U) + chr(10) +
        (if v-update-attr-host
        then "Были изменены атрибуты товара на фирме"
        else "":U) + chr(10) +
      (if v-found-copy-atr-host then " или были унаследованы атрибуты товара на фирме" else "":U) + chr(10) +
      (if v-update-attr-gbl
        then "Были изменены глобальные атрибуты товара"
        else "":U) + chr(10) +
      (if v-found-copy-atr-gbl then " или были унаследованы глобальные атрибуты товара" else "":U) + chr(10) +
      ( if v-update-fbr-gds
        then "Были изменены атрибуты РЕСТОРАН товара на объекте"
        else "":U) + chr(10) +
      (if v-found-copy-fbr-gds then " или были унаследованы атрибуты РЕСТОРАН товара на объекте" else "":U) + chr(10) +
      ( if v-update-s-coeff
        then "Были изменены сезонные коэффициенты товара"
        else "":U) + chr(10) +
      ( if v-update-dgr
        then "Были изменены скидки товара на объекте"
        else "":U) + chr(10) +
      (if v-found-copy-s-coeff then " или были унаследованы сезонные коэффициенты товара" else "":U) + chr(10) +
      ( if v-update-gds-prop
        then "Были изменены индикаторы/атрибуты для заказа товара"
        else "":U) + chr(10) +
      (if v-found-copy-gds-prop then " или были унаследованы индикаторы/атрибуты для заказа товара" else "":U) + chr(10) +
      ( if v-update-add-prop
        then "Были изменены дополнительные расходы"
        else "":U) + chr(10) +
      (if v-found-copy-add-prop then " или были унаследованы дополнительные расходы" else "":U) + chr(10)
      )
       "Сделанные изменения будут отменены" skip
       "Продолжить?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
       IF NOT glog  THEN RETURN error.
   END.
  end.
end procedure.
procedure reposition-goods :
define input parameter p-direction as character no-undo .
define variable v-new-goods-recid as recid no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-goods in p-call-prog
      (input  p-direction
      ,output v-new-goods-recid
      ).
    if v-new-goods-recid <> ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = v-new-goods-recid
        no-error .
      assign
      gds-rec = v-new-goods-recid
      v-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список товаров не определен." view-as alert-box INFORMATION .
    undo, return.
  end.
end.
end procedure.
procedure cb-for-struct-i :
define output parameter p-struct as character no-undo .
  do
  on error undo, return error
  :
    p-struct = temp-goods.struct.
  end.
end procedure.
procedure proc-b-extart:
  define input  parameter p-gds-code like ub.goods.gds-code no-undo .
  do
  on error undo, return error return-value
  :
    run ref/eartform.w ( input parParentProc
                       , input 'ПРОСМОТР':U
                       , input p-gds-code
                       ) no-error .
    if error-status :error then do:
      message
        error-status :get-message(1)
      view-as alert-box information .
    end.
  end.
end procedure.
procedure proc-alc-attr:
end procedure.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure local-gds_inf :
  for each tt-goods
  :
    delete tt-goods.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  create tt-goods.
  buffer-copy goods to tt-goods.
  create tt-clients.
  assign
    tt-clients.obj-type = p-obj-type
    tt-clients.obj-code = p-obj-code
  .
  define variable v-ok as logical   no-undo .
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-clients.obj-type
  ,input  tt-clients.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_archive':U
    ,input  'firm':U
    ,input  v-chk-act-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok then do:
    run arc/gds_inf.w (parparentproc, tt-clients.obj-type, tt-clients.obj-code).
  end.
end procedure.
