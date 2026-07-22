DEFINE TEMP-TABLE tt-tax-rate-value NO-UNDO LIKE ub.tax-rate-value
       field rc as recid
       field exp as logical
       index pi is unique primary
       tax-code
       rate-code
       host-code
       obj-type
       obj-code
       fact-order
       index irc is unique
       rc.
  define temp-table  tt-tax no-undo
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
  DEFINE INPUT PARAMETER TABLE FOR tt-tax.
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
  DEFINE OUTPUT PARAMETER TABLE FOR output-tax.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER parlist-mode as character no-undo.
DEFINE INPUT PARAMETER partable-mode as character no-undo.
DEFINE INPUT PARAMETER pargds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER parnode-code like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER parobj-code like ub.clients.obj-code no-undo.
DEFINE INPUT PARAMETER par-title as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Дерево ставок налогов".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define temp-table  safe-tax no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define var var-rc as recid.
define var fill-table-option as integer no-undo.
FUNCTION get-mark0 RETURNS LOGICAL
  ( buffer loc-output-tax for output-tax )  FORWARD.
FUNCTION get-var-rc RETURNS RECID
  ( input locpar-date as date)  FORWARD.
DEFINE MENU MENU-B-restore
       MENU-ITEM m_one          LABEL "Вернуть первоначальную ставку  по данному налогу"
       MENU-ITEM m_all          LABEL "Вернуть первоначальное ставку по всем налогам".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ext
     LABEL "&>>"
     SIZE 5 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-restore
     LABEL "Во&сстановить"
     SIZE 15 BY 1.
DEFINE BUTTON B-selrate
     LABEL "Вы&бор ставки"
     SIZE 15 BY 1.
DEFINE VARIABLE set-date AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1.04 TOOLTIP "Время включения ставки" NO-UNDO.
DEFINE VARIABLE RS-date AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущая дата", 1,
"Все", 0
     SIZE 22.88 BY .88 NO-UNDO.
DEFINE QUERY BR-tax-rate FOR
      ub.tax-rate SCROLLING.
DEFINE QUERY BR-tax-rate-value FOR
      tt-tax-rate-value SCROLLING.
DEFINE QUERY BR-tt-tax FOR
      output-tax SCROLLING.
DEFINE BROWSE BR-tax-rate
  QUERY BR-tax-rate DISPLAY
      IF tax-rate.rate-code = output-tax.rate-code and get-mark0(buffer output-tax) then "*" else "" FORMAT "X(1)":U
      tax-rate.rate-code COLUMN-LABEL "Код!ставки" FORMAT ">>9":U
      tax-rate.rate-name FORMAT "X(25)":U
      tax-rate.status_ FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 11.29
         TITLE "Коды ставок".
DEFINE BROWSE BR-tax-rate-value
  QUERY BR-tax-rate-value DISPLAY
      if tt-tax-rate-value.rc = var-rc and get-mark0(buffer output-tax) then "*" else "" FORMAT "X(1)":U
      tt-tax-rate-value.rate-value FORMAT ">,>>>,>>>,>>9.99":U
      tt-tax-rate-value.fact-date FORMAT "99/99/9999":U
      tt-tax-rate-value.status_ FORMAT "X(8)":U
      get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
      usrfulnf(tt-tax-rate-value.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      tt-tax-rate-value.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
            WIDTH 3
      tt-tax-rate-value.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(tt-tax-rate-value.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(5)":U
    WITH SEPARATORS SIZE 52.5 BY 11.25
         TITLE "Значения ставок неинд. налогов".
DEFINE BROWSE BR-tt-tax
  QUERY BR-tt-tax DISPLAY
      if get-mark0(buffer output-tax) then  "*" else '':U COLUMN-LABEL "*"
      output-tax.tax-code FORMAT "9":U
      output-tax.tax-name FORMAT "X(20)":U
      output-tax.tax-type FORMAT "X(1)":U
      output-tax.to-cashdesk COLUMN-LABEL "Посылать!на кассу" FORMAT "+/":U
      output-tax.individual COLUMN-LABEL "Инд." FORMAT "+/":U
      output-tax.rate-code COLUMN-LABEL "Код!ставки"
      output-tax.rate-value COLUMN-LABEL "Знач.!ставки" format "->>>9.99"
      output-tax.fact-date COLUMN-LABEL "Включена" FORMAT "99/99/9999":U
      usrfulnf(output-tax.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(10)":U
      output-tax.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>9":U
            WIDTH 6
      output-tax.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(output-tax.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(5)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.13
     B-exit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 71
     RS-date AT ROW 1.13 COL 21.75 NO-LABEL
     BR-tt-tax AT ROW 2.08 COL 1
     set-date AT ROW 9.67 COL 17.13 COLON-ALIGNED
     B-ext AT ROW 9.67 COL 47.25
     B-selrate AT ROW 9.71 COL 1
     B-restore AT ROW 9.71 COL 31.38
     BR-tax-rate AT ROW 10.88 COL 1
     BR-tax-rate-value AT ROW 10.92 COL 46.88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Значения ставок неиндивид. налогов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-restore:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-restore:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  RUn initialize-table(0).
  RUn fill-table(0, 1).
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-ext IN FRAME Dialog-Frame
DO:
   if not avail tt-tax-rate-value then RETURN NO-APPLY.
  RUN proc-ext(var-rc, Rs-date) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
        run ref/cgdshist.w (
                        input parparentproc
                      , input parhost-code
                      , input parobj-type
                      , input parobj-code
                      , input "":U
                      , "subject":U
                      , input pargds-code
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input "":U
                      , input 'tax-rate-gds':U
                      , input g#db-num
                      , input-output v-rid-list  ) no-error .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    RUn initialize-table(0).
       RUn fill-table(0, 1).
END.
ON CHOOSE OF B-restore IN FRAME Dialog-Frame
DO:
 if rs-date = 0 then return no-apply.
    if fill-table-option = -1 then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
 if fill-table-option = -1 then return no-apply.
 run proc-b-restore(fill-table-option) no-error.
 if error-status:error then do:
     fill-table-option = -1.
     return no-apply.
 end.
END.
ON CHOOSE OF B-selrate IN FRAME Dialog-Frame
DO:
  assign set-date.
  if not avail ub.tax-rate or
  (ub.tax-rate.rate-code = output-tax.rate-code AND
  (output-tax.fact-date = set-date or partable-mode = "GDS-GRP":U))  then do:
    bell.
    return no-apply.
  end.
  if rs-date = 0 then return no-apply.
  run proc-b-selrate no-error.
  if error-status:error then return no-apply.
END.
ON INSERT-MODE OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to b-selrate.
  return no-apply.
END.
ON VALUE-CHANGED OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  run Openbr-tax-rate-value(rs-date).
END.
ON MOUSE-SELECT-DBLCLICK OF BR-tax-rate-value IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to b-ext.
  return no-apply.
END.
ON VALUE-CHANGED OF BR-tt-tax IN FRAME Dialog-Frame
DO:
if not avail output-tax then return no-apply.
  run OpenBr-tax-rate.
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
    if rs-date = 0 then return no-apply.
  fill-table-option = 0.
  run proc-b-restore(fill-table-option) no-error.
    if error-status:error then do:
         fill-table-option = -1.
        return no-apply.
    end.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
    if rs-date = 0 then return no-apply.
  fill-table-option = output-tax.tax-code.
  run proc-b-restore(fill-table-option) no-error.
    if error-status:error then do:
        fill-table-option = -1.
        return no-apply.
    end.
END.
ON VALUE-CHANGED OF RS-date IN FRAME Dialog-Frame
DO:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  assign RS-date.
  case rs-date:
    when 1 then do:
      enable
      b-selrate when lookup('ПРОСМОТР':U, parlist-mode) = 0
      set-date when lookup('ПРОСМОТР':U, parlist-mode) = 0
      with frame Dialog-Frame.
    end.
    when 0 then do:
      disable
      b-selrate  set-date
      with frame Dialog-Frame.
      hide set-date in frame Dialog-Frame.
    end.
  end case.
  run fill-table(0, rs-date) no-error.
  if error-status:error then return no-apply.
  OPEN QUERY BR-tt-tax FOR EACH output-tax       WHERE output-tax.individual = FALSE NO-LOCK.
  run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
  var-rc = get-var-rc( v-today ).
  APPLY "Value-changed" to br-tt-tax.
  run Openbr-tax-rate-value(rs-date).
  APPLY "ENTRY" to br-tax-rate.
END.
ON LEAVE OF set-date IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
  if date(self:screen-value) < v-today then do:
    bell.
    return no-apply.
  end.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-tt-tax :handle
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of set-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of set-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of set-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of set-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of set-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of set-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
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
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if set-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      set-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      set-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = set-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to set-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to set-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to set-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to set-date in frame Dialog-Frame .
  END.
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-tax-rate :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-tax-rate-value :handle
  ) .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable v-today as date      no-undo.
   define variable v-time  as integer   no-undo.
  if (partable-mode = "GOODS" and pargds-code = 0 and parnode-code = 0)  OR
    (partable-mode = "GDS-GRP" and parnode-code = 0 ) then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный параметры partable-mode и/или pargds-code и/или parnode-code"
        view-as alert-box ERROR.
        return error.
    end.
    if parhost-code = 0 or parobj-type = "" or parobj-code = 0 then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный параметры parhost-code и/или parobj-type и/или parobj-code"
        view-as alert-box ERROR.
        return error.
    end.
    run initialize-table in this-procedure(0).
  run fill-table in this-procedure(0, rs-date).
  run MyEnable.
  run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
  var-rc = get-var-rc( v-today ).
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-date set-date
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-hist B-Help RS-date BR-tt-tax set-date B-ext B-selrate
         B-restore BR-tax-rate BR-tax-rate-value
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-tt-tax FOR EACH output-tax       WHERE output-tax.individual = FALSE NO-LOCK.
END PROCEDURE.
PROCEDURE fill-table :
define input parameter partax-code like ub.tax.tax-code no-undo.
define input parameter parrs-date as integer no-undo.
define variable var-rate-value like ub.tax-rate-value.rate-value no-undo.
define variable varfact-date as date no-undo.
CASE parrs-date:
    when 1 then do:
        for each output-tax:
          if partax-code = 0 or partax-code = output-tax.tax-code then do:
            delete output-tax.
          end.
        end.
        for each safe-tax no-lock:
          if partax-code = 0 or partax-code = safe-tax.tax-code then do:
            create output-tax.
            buffer-copy safe-tax to output-tax.
          end.
        end.
    end.
    when 0 then do:
      CASE partable-mode:
        when "GOODS":U then do:
          if pargds-code = 0 then return error.
          run gds-all-history in this-procedure(pargds-code) no-error.
          if error-status:error then return error.
        end.
        otherwise do:
            return error.
        end.
      END CASE.
    end.
end CASE.
END PROCEDURE.
PROCEDURE gds-all-history :
define input parameter locgds-code like ub.goods.gds-code no-undo.
define variable is-first as logical no-undo.
define variable nextfact-order like ub.tax-rate-gds.fact-order no-undo.
define variable max-fact-order like ub.tax-rate-gds.fact-order no-undo.
define variable var-rate-value like ub.tax-rate-value .rate-value no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_output-tax for output-tax.
for each output-tax:
  delete output-tax.
end.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
run factord-max-fact-order in this-procedure(output max-fact-order) .
for each tt-tax No-LOCK
         break by tt-tax.tax-code:
  if first-of(tt-tax.tax-code) then do:
    is-first = yes.
    for each safe-tax No-LOCK WHERE
              safe-tax.tax-code = tt-tax.tax-code
        BY safe-tax.fact-order descending:
      IF safe-tax.rate-code <> tt-tax.rate-code OR safe-tax.fact-date > v-today then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalo in g#library
  (input  ?
  ,input  tt-tax.tax-code
  ,input  safe-tax.rate-code
  ,input  safe-tax.fact-order
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output var-rate-value
  ) no-error .
        create output-tax.
        buffer-copy tt-tax except tax-rate-gds-rc to output-tax
        assign
        output-tax.rate-code = safe-tax.rate-code
        output-tax.rate-value = var-rate-value
        output-tax.fact-date = safe-tax.fact-date
        output-tax.next-order = if is-first then max-fact-order else nextfact-order
        output-tax.fact-order = safe-tax.fact-order
        output-tax.tax-rate-gds-rc = if safe-tax.fact-date > v-today then ? else tt-tax.tax-rate-gds-rc
        .
        assign
        is-first = no
        nextfact-order = output-tax.fact-order
        .
      end.
    END.
    FOR each ub.tax-rate-gds No-lock where
              ub.tax-rate-gds.gds-coDe = locgds-code AND
              ub.tax-rate-gds.tax-code = tt-tax.tax-code AND
              ub.tax-rate-gds.host-code = 0 AND
              ub.tax-rate-gds.obj-type = "":U AND
              ub.tax-rate-gds.obj-code = 0
              BY ub.tax-rate-gds.fact-order descending:
      FIND FIRST output-tax where
                output-tax.tax-code = tt-tax.tax-code AND
                output-tax.fact-order = ub.tax-rate-gds.fact-order No-ERROR.
      if not avail output-tax then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalo in g#library
  (input  ?
  ,input  ub.tax-rate-gds.tax-code
  ,input  ub.tax-rate-gds.rate-code
  ,input  ub.tax-rate-gds.fact-order
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output var-rate-value
  ) no-error .
        create output-tax.
        buffer-copy tt-tax except tax-rate-gds-rc to output-tax
        assign
        output-tax.rate-code = ub.tax-rate-gds.rate-code
        output-tax.rate-value = var-rate-value
        output-tax.fact-date = ub.tax-rate-gds.fact-date
        output-tax.next-order = if is-first then max-fact-order else nextfact-order
        output-tax.fact-order = ub.tax-rate-gds.fact-order
        output-tax.tax-rate-gds-rc = (if ub.tax-rate-gds.fact-date = tt-tax.fact-date then tt-tax.tax-rate-gds-rc else ?)
        .
        assign
        is-first = no
        nextfact-order = output-tax.fact-order
        .
      end.
    end.
  end.
END.
for each output-tax No-LOCK:
  var-rate-value = ?.
  for each ub.tax-rate-value No-LOCK WHERE
          ub.tax-rate-value.rate-code = output-tax.rate-code AND
          ub.tax-rate-value.tax-code = output-tax.tax-code AND
          ub.tax-rate-value.fact-order >= output-tax.fact-order AND
          ub.tax-rate-value.fact-order < output-tax.next-order AND
          ub.tax-rate-value.status_ = 'тек':U
  break
  by ub.tax-rate-value.fact-order
  by ub.tax-rate-value.host-code
  by ub.tax-rate-value.obj-type
  by ub.tax-rate-value.obj-code
  :
    if ub.tax-rate-value.host-code = 0 OR
        (ub.tax-rate-value.host-code = parhost-code
        and ub.tax-rate-value.obj-code = 0
        and ub.tax-rate-value.obj-type = "":U)
        or
        (ub.tax-rate-value.obj-type = parobj-type and
        ub.tax-rate-value.obj-code = parobj-code) then do:
        var-rate-value = ub.tax-rate-value.rate-value.
    end.
    if last-of(ub.tax-rate-value.fact-order) and var-rate-value <> ? then do:
      FIND FIRST b_output-tax where
                  b_output-tax.tax-code = output-tax.tax-code AND
                  b_output-tax.fact-order = ub.tax-rate-value.fact-order No-ERROR.
      if not avail b_output-tax then do:
        create b_output-tax.
        buffer-copy output-tax except tax-rate-gds-rc  to b_output-tax
        assign
        b_output-tax.rate-value = var-rate-value
        b_output-tax.fact-date = ub.tax-rate-value.fact-date
        b_output-tax.fact-order = ub.tax-rate-value.fact-order
        .
      end.
    end.
  end.
END.
END PROCEDURE.
PROCEDURE initialize-table :
define input parameter partax-code like ub.tax.tax-code no-undo.
for each safe-tax:
  if partax-code = 0 or partax-code = safe-tax.tax-code then do:
    delete safe-tax.
  end.
end.
for each tt-tax no-lock:
  if partax-code = 0 or partax-code = tt-tax.tax-code then do:
    create safe-tax.
    buffer-copy tt-tax to safe-tax.
  end.
end.
END PROCEDURE.
PROCEDURE MyENable :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
find first ub.clients no-lock where
           ub.clients.obj-type = 'орг':U and
           ub.clients.obj-code = parhost-code No-error.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
ASSIGN
br-tt-tax:title in frame Dialog-Frame = par-title
set-date = v-today
set-date:visible in frame Dialog-Frame = if LOOKUP('ПРОСМОТР':U, parlist-mode) > 0 then no else yes
set-date:visible in frame Dialog-Frame = (partable-mode = "GOODS":U)
b-quit:label in frame Dialog-Frame  = if LOOKUP('ПРОСМОТР':U, parlist-mode) > 0 then "Выход" else b-quit:label
b-exit:visible in frame Dialog-Frame = if LOOKUP('ПРОСМОТР':U, parlist-mode) > 0 then no else yes
b-restore:visible in frame Dialog-Frame = no
b-restore:MENU-MOUSE in frame Dialog-Frame = 1
RS-date = 1
RS-date:visible in frame Dialog-Frame = (partable-mode = "GOODS":U)
frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32) +
                            "Фирма: " + (if avail ub.clients
                                         then string(clients.obj-name, "x(30)")
                                         else string(parhost-code)) + chr(32) +
                            parobj-type + string(parobj-code)
.
if (partable-mode = "GOODS":U)
then
DISPLAY
RS-date
WITH FRAME Dialog-Frame.
if LOOKUP('ПРОСМОТР':U, parlist-mode) = 0 AND partable-mode = "GOODS":U then
display set-date
WITH FRAME Dialog-Frame.
ENABLE
B-exit when lookup('ПРОСМОТР':U, parlist-mode) = 0
b-quit
B-Help
b-hist WHEN partable-mode = "GOODS":U
B-selrate when lookup('ПРОСМОТР':U, parlist-mode) = 0
set-date when lookup('ПРОСМОТР':U, parlist-mode) = 0 and partable-mode = "GOODS":U
BR-tt-tax
BR-tax-rate
BR-tax-rate-value
B-ext
RS-date when ((pargds-code <> ? or parnode-code <> ?) AND partable-mode = "GOODS":U)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
OPEN QUERY BR-tt-tax FOR EACH output-tax       WHERE output-tax.individual = FALSE NO-LOCK.
var-rc = get-var-rc( v-today ).
APPLY "Value-changed" to br-tt-tax.
APPLY "ENTRY" to br-tax-rate.
END PROCEDURE.
PROCEDURE OpenBr-tax-rate :
define variable locvar-rc as recid     no-undo.
define variable v-today   as date      no-undo.
define variable v-time    as integer   no-undo.
define buffer b_tax-rate for ub.tax-rate.
Open query br-tax-rate for each ub.tax-rate where
ub.tax-rate.tax-code = output-tax.tax-code.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
assign
    var-rc = get-var-rc( v-today )
.
find first b_tax-rate No-LOCK WHERE
            b_tax-rate.rate-code = output-tax.rate-code AND
            b_tax-rate.tax-code = output-tax.tax-code no-error.
if avail b_tax-rate then do:
    locvar-rc = recid(b_tax-rate).
end.
reposition br-tax-rate to recid locvar-rc no-error.
APPLY "VALUE-CHANGED" to br-tax-rate in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr-tax-rate-value :
define input parameter par-date-option as integer no-undo.
define var var-tt-rc as recid.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
define var var-reg as integer no-undo.
define var curvar-rc as recid no-undo.
define var upnode-rc as recid no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable loc#log as logical no-undo .
define buffer b_tax-rate-value for ub.tax-rate-value.
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
run factord-end-day in this-procedure (input v-today, output var-fact-order).
for each tt-tax-rate-value:
    delete tt-tax-rate-value.
end.
find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = 'тек':U
            no-error.
if avail b_tax-rate-value then do:
    assign
    var-reg = 2
    curvar-rc = recid(b_tax-rate-value)
        .
end.
else do:
    find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = "":U AND
            b_tax-rate-value.obj-code = 0 AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = 'тек':U
            no-error.
    if avail b_tax-rate-value then do:
        assign
        var-reg = 1
          curvar-rc = recid(b_tax-rate-value)
                .
    end.
    else do:
        find last b_tax-rate-value No-LOCK WHERE
                b_tax-rate-value.rate-code = ub.tax-rate.rate-code AND
                b_tax-rate-value.tax-code = ub.tax-rate.tax-code AND
                b_tax-rate-value.host-code = 0 AND
                b_tax-rate-value.obj-type = "":U AND
                b_tax-rate-value.obj-code = 0 AND
                b_tax-rate-value.fact-order <= var-fact-order AND
                b_tax-rate-value.status_ = 'тек':U
                no-error.
        if avail b_tax-rate-value then do:
            assign
            var-reg = 0
            curvar-rc = recid(b_tax-rate-value)
            .
        end.
        else do:
            assign
            var-reg = -1
            curvar-rc = ?
            .
        end.
    end.
end.
CASE par-date-option:
    when 0 then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0
            :
    create
    tt-tax-rate-value.
    buffer-copy ub.tax-rate-value to tt-tax-rate-value
    assign
    tt-tax-rate-value.rc = recid(ub.tax-rate-value)
    .
    end.
  end.
  when 1 then do:
    FIND LAST ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            ub.tax-rate-value.fact-order <= var-fact-order AND
            ub.tax-rate-value.status_ = 'тек':U No-ERROR.
    if avail ub.tax-rate-value then  do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
    end.
  end.
END CASE.
if var-reg = 1 or var-reg = 2 then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code > 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
                  :
      if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
          create
          tt-tax-rate-value.
          buffer-copy ub.tax-rate-value to tt-tax-rate-value
          assign
          tt-tax-rate-value.rc = recid(ub.tax-rate-value)
          .
      end.
    end.
   for each tt-tax-rate-value where
            tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            tt-tax-rate-value.host-code = 0:
    tt-tax-rate-value.exp = yes.
   end.
end.
if var-reg = 2 then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = parhost-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
    if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
    end.
  end.
  for each tt-tax-rate-value where
        tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
        tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
        tt-tax-rate-value.host-code = parhost-code :
     tt-tax-rate-value.exp = yes.
  end.
end.
find first b_tt-tax-rate-value where
    b_tt-tax-rate-value.rc = curvar-rc no-lock no-error.
    if avail b_tt-tax-rate-value then
    var-tt-rc = recid(b_tt-tax-rate-value).
open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.
if br-tax-rate-value:focused-row in frame Dialog-Frame = 1 then do:
    loc#log = br-tax-rate-value:SELECT-PREV-ROW( ) .
    if loc#log then do:
        APPLY "CURSOR-DOWN" to br-tax-rate-value.
    end.
end.
END PROCEDURE.
PROCEDURE proc-b-restore :
define input parameter par-fill-table-option as integer no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
  RUn initialize-table(par-fill-table-option) no-error.
 RUn fill-table(par-fill-table-option, 1) no-error.
 if error-status:error then do:
    fill-table-option = -1.
    return error.
 end.
 Open query br-tt-tax for each output-tax NO-LOCK WHERE output-tax.individual = FALSE.
 run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
 assign
    var-rc = get-var-rc( v-today )
 .
Run openbr-tax-rate no-error.
 if error-status:error then do:
    return error.
 end.
Run openbr-tax-rate-value(RS-date) no-error.
 if error-status:error then do:
    return error.
 end.
END PROCEDURE.
PROCEDURE proc-b-selrate :
define variable vartax-value like ub.tax-rate-value.rate-value no-undo.
define variable curtax-rc as recid no-undo.
define variable var-fact-order like ub.tax-rate-gds.fact-order no-undo.
define variable loc#log as logical no-undo .
define buffer b_output-tax for output-tax.
DEFINE VARIABLE var-old-date as date no-undo .
DEFINE VARIABLE var-old-order like ub.tax-rate-gds.fact-order no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
  curtax-rc  = recid(output-tax).
  run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
  run factord-end-day in this-procedure (input set-date, output var-fact-order).
  var-old-date = output-tax.fact-date.
  if var-old-date <> ? then
  run factord-end-day in this-procedure (input var-old-date, output var-old-order).
  CASE set-date:
    when v-today then do:
      find first b_output-tax where
                  recid(b_output-tax) = recid(output-tax) No-ERROR.
    end.
    otherwise do:
      find first b_output-tax where
                 b_output-tax.tax-code = ub.tax-rate.tax-code AND
                 b_output-tax.rate-code = ub.tax-rate.rate-code AND
                 b_output-tax.fact-order = var-fact-order No-ERROR.
      if not avail b_output-tax then do:
        find first b_output-tax where
                  b_output-tax.tax-code = ub.tax-rate.tax-code AND
                  b_output-tax.fact-order = var-fact-order No-ERROR.
        if not avail b_output-tax then do:
          create b_output-tax.
        end.
      end.
    end.
  END CASE.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output vartax-value
  ) no-error .
  if error-status:error or vartax-value = ? then do:
     message "Неверное значение по ставке налога" view-as alert-box ERROR.
     return error.
  end.
  buffer-copy output-tax except tax-rate-gds-rc to b_output-tax
  assign
  b_output-tax.rate-code = ub.tax-rate.rate-code
  b_output-tax.rate-value = vartax-value
  b_output-tax.fact-date = (if partable-mode = "GOODS":U then set-date else ?)
  b_output-tax.fact-order = var-fact-order
  .
  if new(b_output-tax) then do:
    create safe-tax.
  end.
  else do:
    find first safe-tax where
               safe-tax.tax-code = b_output-tax.tax-code AND
               (safe-tax.fact-order = var-old-order or partable-mode = "GDS-GRP":U) No-ERROR.
    if not avail safe-tax then do:
      return error.
    end.
  end.
  buffer-copy output-tax except tax-rate-gds-rc to safe-tax
  assign
  safe-tax.rate-code = ub.tax-rate.rate-code
  safe-tax.rate-value = vartax-value
  safe-tax.fact-date = (if partable-mode = "GOODS":U then set-date else ?)
  safe-tax.fact-order = var-fact-order
  .
  var-rc = get-var-rc( v-today ).
  Open query br-tt-tax for each output-tax No-LOCK WHERE output-tax.individual = FALSE.
  REPOSITION br-tt-tax to recid curtax-rc No-ERROR.
  if br-tt-tax:focused-row in frame Dialog-Frame = 1 then do:
    loc#log = br-tt-tax:SELECT-PREV-ROW( ) .
    if loc#log then do:
        APPLY "CURSOR-DOWN" to br-tt-tax.
    end.
  end.
  Run openbr-tax-rate.
  Run openbr-tax-rate-value(RS-date).
END PROCEDURE.
PROCEDURE proc-ext :
define input parameter par-rc as recid no-undo.
define input parameter par-date-option as integer no-undo.
define var var-tt-rc as recid no-undo.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
if tt-tax-rate-value.host-code <> 0 and
   tt-tax-rate-value.obj-type <> "":U and
   tt-tax-rate-value.obj-code <> 0 THEN do:
   BELL.
   return error.
end.
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
run factord-end-day in this-procedure (input v-today, output var-fact-order).
var-tt-rc = recid(tt-tax-rate-value).
IF tt-tax-rate-value.host-code = 0 then do:
  if tt-tax-rate-value.exp = yes then do:
    FIND FIRST b_tt-tax-rate-value where
               b_tt-tax-rate-value.rc = par-rc No-ERROR.
    if avail b_tt-tax-rate-value and
             b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code
    then.
    else do:
      FOR EACH b_tt-tax-rate-value where
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              b_tt-tax-rate-value.host-code <> 0:
        delete b_tt-tax-rate-value.
      END.
      find first b_tt-tax-rate-value where
                 recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
      if avail b_tt-tax-rate-value then do:
        b_tt-tax-rate-value.exp = no.
      end.
    end.
  end.
  else do:
    FOR EACH ub.tax-rate-value NO-LOCK where
             ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
             ub.tax-rate-value.host-code <> 0 AND
             ub.tax-rate-value.obj-type = "" AND
             ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
      if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
        create
        b_tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
        assign
        b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
      end.
    end.
    find first b_tt-tax-rate-value where
                recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
    if avail b_tt-tax-rate-value then do:
        b_tt-tax-rate-value.exp = yes.
    end.
  end.
end.
else do:
  if tt-tax-rate-value.exp = yes then do:
    FIND FIRST b_tt-tax-rate-value where
               b_tt-tax-rate-value.rc = par-rc No-ERROR.
    if avail b_tt-tax-rate-value and
             b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
             b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
             b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code
    then.
    else do:
      FOR EACH b_tt-tax-rate-value where
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code AND
              b_tt-tax-rate-value.obj-type <> "" and
              b_tt-tax-rate-value.obj-code <> 0:
        delete b_tt-tax-rate-value.
      END.
      find first b_tt-tax-rate-value where
                 recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
      if avail b_tt-tax-rate-value then do:
                b_tt-tax-rate-value.exp = no.
      end.
    end.
  end.
  else do:
    FOR EACH ub.tax-rate-value NO-LOCK where
        ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
        ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
        ub.tax-rate-value.host-code = tt-tax-rate-value.host-code AND
        ub.tax-rate-value.obj-type <> "" AND
        ub.tax-rate-value.obj-code <> 0 AND
        (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
      if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
        create
        b_tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
        assign
        b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
      end.
    end.
    find first b_tt-tax-rate-value where
               recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
    if avail b_tt-tax-rate-value then do:
             b_tt-tax-rate-value.exp = yes.
    end.
  END.
end.
open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.
END PROCEDURE.
FUNCTION get-mark0 RETURNS LOGICAL
  ( buffer loc-output-tax for output-tax ) :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today                                   , output v-time                                   ).
if loc-output-tax.tax-rate-gds-rc <> ? or
   (parlist-mode = 'ДОБАВЛЕНИЕ':U and
   partable-mode = 'GOODS':U and loc-output-tax.fact-date = v-today)
   then return true.
  RETURN FALSE.
END FUNCTION.
FUNCTION get-var-rc RETURNS RECID
  ( input locpar-date as date) :
define var locvar-rc as recid no-undo.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
define buffer b_tax-rate-value for ub.tax-rate-value.
run factord-end-day in this-procedure (input locpar-date, output var-fact-order).
find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = output-tax.rate-code AND
            b_tax-rate-value.tax-code = output-tax.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = 'тек':U
            no-error.
if avail b_tax-rate-value then do:
    assign
    locvar-rc = recid(b_tax-rate-value)
        .
end.
else do:
    find last b_tax-rate-value No-LOCK WHERE
            b_tax-rate-value.rate-code = output-tax.rate-code AND
            b_tax-rate-value.tax-code = output-tax.tax-code AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = "":U AND
            b_tax-rate-value.obj-code = 0 AND
            b_tax-rate-value.fact-order <= var-fact-order AND
            b_tax-rate-value.status_ = 'тек':U
            no-error.
    if avail b_tax-rate-value then do:
        assign
        locvar-rc = recid(b_tax-rate-value)
                .
    end.
    else do:
        find last b_tax-rate-value No-LOCK WHERE
                b_tax-rate-value.rate-code = output-tax.rate-code AND
                b_tax-rate-value.tax-code = output-tax.tax-code AND
                b_tax-rate-value.host-code = 0 AND
                b_tax-rate-value.obj-type = "":U AND
                b_tax-rate-value.obj-code = 0 AND
                b_tax-rate-value.fact-order <= var-fact-order AND
                b_tax-rate-value.status_ = 'тек':U
                no-error.
        if avail b_tax-rate-value then do:
            assign
                        locvar-rc = recid(b_tax-rate-value)
                        .
        end.
        else do:
            assign
            locvar-rc = ?
            .
        end.
    end.
end.
RETURN locvar-rc.
END FUNCTION.
