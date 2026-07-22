define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Мониторинг остатков резервуаров и прогноз реализации".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE TEMP-TABLE tt-place NO-UNDO
   field gds-code           like ub.goods.gds-code
   field pl-code            like ub.place.pl-code
   field loc1               like ub.place.loc1
   field gds-name           like ub.goods.gds-name
   field max-qnty           like ub.place.max-qnty
   field curr-qnty          like ub.rvs-line.state-measure-qnty
   field curr-qnty-start    like ub.rvs-line.state-measure-qnty
   field curr-fact-order    like ub.rvs-doc.fact-order
   field curr-rvs-code      like ub.rvs-doc.rvs-code
   field free-qnty          like ub.rvs-line.state-measure-qnty
   field curr-fill          as logical
   field sale-qnty-curr     like ub.rvs-line.state-measure-qnty
   field sale-start-qnty    like ub.rvs-line.state-measure-qnty
   field sale-fact-order    like ub.rvs-doc.fact-order
   field sale-time          as   integer
   field sale-rvs-code      like ub.rvs-doc.rvs-code
   field sale-fill            as logical
   field sale-qnty-prev       like ub.rvs-line.state-measure-qnty
   field sale-start-qnty-prev like ub.rvs-line.state-measure-qnty
   field sale-end-qnty-prev   like ub.rvs-line.state-measure-qnty
   field sale-time-prev       as   integer     INITIAL 999999
   field sale-time-prev-end   as   integer     INITIAL 999999
   field hnd                as   HANDLE
   field hnd-top            as   HANDLE
   field hnd-name           as   HANDLE
   field hnd-max-qnty       as   HANDLE
   field hnd-free-qnty      as   HANDLE
   field hnd-qnty           as   HANDLE
index pu as primary unique
      gds-code
      pl-code
index by-fill-sale
      sale-fill
index by-fill-curr
      curr-fill
.
DEFINE TEMP-TABLE tt-gds-pred NO-UNDO
   field gds-code           like ub.goods.gds-code
   field gds-name           like ub.goods.gds-name
   field start-qnty         like ub.rvs-line.state-measure-qnty
   field sale-qnty          like ub.rvs-line.state-measure-qnty
   field curr-qnty          like ub.rvs-line.state-measure-qnty
   field prediction-qnty    like ub.rvs-line.state-measure-qnty
   FIELD delta-time         AS INTEGER
   field count-pl           as integer
   field hnd                as   HANDLE
   field hnd-name           as   HANDLE
   field hnd-sale-qnty      as   HANDLE
   field hnd-qnty           as   HANDLE
   field hnd-pred-qnty      as   HANDLE
   field hnd-total-qnty     as   HANDLE
   field hnd-sale-qnty-l    as   HANDLE
   field hnd-qnty-l         as   HANDLE
   field hnd-pred-qnty-l    as   HANDLE
   field hnd-total-qnty-l   as   HANDLE
   field sale-time          as   integer
index pu as primary unique
      gds-code
.
define buffer buf_shift-obj   for ub.shift-obj.
define buffer br_tt-place     for tt-place.
define buffer br_tt-gds-pred  for tt-gds-pred.
define variable v-obj-code        as integer      no-undo.
define variable v-obj-type        as character    no-undo.
define variable v-shift-on        as logical no-undo .
define variable v-count-place     as integer      no-undo.
define variable v-max-qnty        as decimal      no-undo.
define variable v-rid-list        as character    no-undo.
DEFINE VARIABLE v-shift-date      AS DATE NO-UNDO.
DEFINE VARIABLE v-shift-num       AS INTEGER NO-UNDO.
define variable v-meas-time       as integer      no-undo.
define variable v-meas-date       as date      no-undo.
DEFINE VARIABLE v-shift-date-prev AS DATE NO-UNDO.
DEFINE VARIABLE v-shift-num-prev  AS INTEGER NO-UNDO.
DEFINE VARIABLE v-shift-date-prediction AS DATE    NO-UNDO.
DEFINE VARIABLE v-end-time-prediction   AS integer NO-UNDO.
DEFINE VARIABLE v-end-time-prediction-shift   AS integer NO-UNDO.
DEFINE VARIABLE v-start-time-prediction AS integer NO-UNDO.
define variable v-curr-date             as date    no-undo.
define variable v-browser    as logical      no-undo.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sale
     LABEL "&Реализация"
     SIZE 12 BY 1.
DEFINE BUTTON b-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 2"
     SIZE 3 BY 1.
DEFINE VARIABLE v-date-prediction AS DATE FORMAT "99/99/99":U
     LABEL "Сменная дата для прогноза"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 DROP-TARGET NO-UNDO.
DEFINE VARIABLE v-hour-prediction AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-minute-prediction AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-shift-num-prediction AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Порядок смены прогноза"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE rs-prediction AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "На конец смены", 1,
"На конкретное время", 2
     SIZE 21.5 BY 1.5 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 94 BY 10.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 94 BY 7.5.
DEFINE QUERY BROWSE-3 FOR
      br_tt-place SCROLLING.
DEFINE QUERY BROWSE-4 FOR
      br_tt-gds-pred SCROLLING.
DEFINE BROWSE BROWSE-3
  QUERY BROWSE-3 DISPLAY
      br_tt-place.gds-name FORMAT "x(40)" COLUMN-LABEL "Топливо"
 br_tt-place.loc1                        COLUMN-LABEL "Резервуар"
 br_tt-place.max-qnty
 br_tt-place.curr-qnty             COLUMN-LABEL "Текущее количество"
 (br_tt-place.max-qnty - br_tt-place.curr-qnty)             COLUMN-LABEL "Свободно"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94 BY 10.5 EXPANDABLE.
DEFINE BROWSE BROWSE-4
  QUERY BROWSE-4 DISPLAY
      br_tt-gds-pred.gds-name FORMAT "x(40)" COLUMN-LABEL "Топливо"
br_tt-gds-pred.curr-qnty COLUMN-LABEL "Остаток"
br_tt-gds-pred.sale-qnty COLUMN-LABEL "Реализация"
br_tt-gds-pred.prediction-qnty COLUMN-LABEL "Прогноз"
STRING(br_tt-gds-pred.sale-time, "HH:MM") FORMAT "x(6)" COLUMN-LABEL "измер.":C6
br_tt-gds-pred.delta-time FORMAT ">>>>9" COLUMN-LABEL "мин+/-"
    WITH NO-ROW-MARKERS SEPARATORS NO-TAB-STOP SIZE 94 BY 7.25 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 89
     BROWSE-3 AT ROW 2.5 COL 2.5
     v-date-prediction AT ROW 13.25 COL 27.5 COLON-ALIGNED
     b-sale AT ROW 13.25 COL 84.5
     rs-prediction AT ROW 13.5 COL 53 NO-LABEL
     v-hour-prediction AT ROW 14.08 COL 73.5 COLON-ALIGNED NO-LABEL
     v-minute-prediction AT ROW 14.08 COL 79 COLON-ALIGNED
     v-shift-num-prediction AT ROW 14.25 COL 27.5 COLON-ALIGNED
     b-shift AT ROW 14.25 COL 36
     BROWSE-4 AT ROW 15.5 COL 2.5
     "Тип прогноза:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 13.5 COL 39.5
     RECT-1 AT ROW 2.5 COL 2.5
     RECT-2 AT ROW 15.5 COL 2.5
     SPACE(2.50) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Мониторинг остатков резервуаров и прогноз реализации"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-sale IN FRAME Dialog-Frame
DO:
   define variable v-shift-list    as character    no-undo.
   define buffer buf_shift-obj      for ub.shift-obj.
   run rep/restsale.w ( parparentproc
                  , v-obj-type
                  , v-obj-code
                  , v-date-prediction
                  , v-start-time-prediction
                  , v-date-prediction
                  , v-end-time-prediction
                  ) NO-ERROR.
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры расчета продаж за интервал restsale.w" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
   end.
END.
ON CHOOSE OF b-shift IN FRAME Dialog-Frame
DO:
   run select-shift in this-procedure .
   run del-prediction in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-3 IN FRAME Dialog-Frame
DO:
   run show-histogramm in this-procedure.
   assign
      v-browser = FALSE
   .
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-4 IN FRAME Dialog-Frame
DO:
   run show-histogramm in this-procedure.
   assign
      v-browser = FALSE
   .
END.
ON MOUSE-SELECT-DBLCLICK OF RECT-1 IN FRAME Dialog-Frame
DO:
  run show-browser  in this-procedure.
   assign
      v-browser = TRUE
   .
END.
ON MOUSE-SELECT-DBLCLICK OF RECT-2 IN FRAME Dialog-Frame
DO:
  run show-browser  in this-procedure.
   assign
      v-browser = TRUE
   .
END.
ON VALUE-CHANGED OF rs-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
     rs-prediction
   .
   CASE rs-prediction:
      WHEN 1 THEN DO:
         DISABLE v-hour-prediction
               v-minute-prediction
         with frame Dialog-Frame.
         assign
            v-end-time-prediction = v-end-time-prediction-shift
         .
      END.
      OTHERWISE DO:
         ENABLE v-hour-prediction
               v-minute-prediction
         with frame Dialog-Frame.
         ASSIGN
            v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
         .
      END.
   END CASE.
   run del-prediction   in this-procedure .
   run fill-prediction  in this-procedure .
   run draw-pred        in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
END.
ON LEAVE OF v-date-prediction IN FRAME Dialog-Frame
DO:
  ASSIGN
      v-date-prediction
  .
  run find-date-shift in this-procedure
      ( input v-obj-type
      , input v-obj-code
      , input v-date-prediction
      , input v-start-time-prediction
      , output v-shift-date-prediction
      , output v-shift-num-prediction
      ) .
   run del-prediction   in this-procedure .
   run fill-prediction  in this-procedure .
   run draw-pred        in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
   DISPLAY v-shift-num-prediction
   WITH FRAME Dialog-Frame.
END.
ON LEAVE OF v-hour-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-hour-prediction
   .
   run mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-hour-prediction ) .
   ASSIGN
       v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
   .
   run del-prediction   in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
END.
ON LEAVE OF v-minute-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-minute-prediction
   .
   run mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-minute-prediction ) .
   ASSIGN
         v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
   .
   run del-prediction   in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-3 :handle
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   assign
      v-browser = TRUE
   .
   IF v-cntxt-db-num = 0 then do:
      define buffer buf_clients     for ub.clients.
    define variable v-ok    as logical      no-undo.
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  v-cntxt-db-num
      ,input  v-cntxt-userid
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,INPUT  "b-sel"
      ,output v-ok
      ,output v-obj-type
      ,output v-obj-code
      ) NO-ERROR.
      if error-status :error
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе объекта" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return.
      end.
      IF NOT v-ok THEN dO:
         message
            "Пользователь отказался от выбора объекта" skip
            view-as alert-box error .
         return.
      end.
   end.
   else do:
      assign
            v-obj-type = v-cntxt-obj-type
            v-obj-code = v-cntxt-obj-code
      .
   end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
   if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при запуске процедуры objat" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return.
   end.
   if not v-shift-on then do:
      message
         vss-workfile vss-revision vss-description skip
         "На объекте выключены смены." skip
         "Работа со сменами невозможна." skip
         "Объект:" v-obj-type v-obj-code skip
         view-as alert-box error .
      return.
   end.
   find first buf_shift-obj
        where buf_shift-obj.obj-type = v-obj-type
          and buf_shift-obj.obj-code = v-obj-code
          and buf_shift-obj.status_  = 'тек':U
        no-lock
        no-error
        .
   IF not available buf_shift-obj then do:
      message
         "На объекте" v-obj-type v-obj-code skip
         "Не найдена текущая смена" skip
         view-as alert-box error .
      return.
   end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-curr-date
  )  .
   assign
      v-date-prediction = v-curr-date - 7
      v-shift-date      = buf_shift-obj.shift-date
      v-shift-num       = buf_shift-obj.shift-num
   .
   release buf_shift-obj.
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND buf_shift-obj.shift-date = v-date-prediction
          AND buf_shift-obj.shift-num  = v-shift-num
   no-lock
   no-error.
   IF AVAILABLE buf_shift-obj then do:
      assign
         v-shift-num-prediction = v-shift-num
      .
   end.
   release buf_shift-obj.
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND ((    buf_shift-obj.shift-date = v-shift-date
                AND buf_shift-obj.shift-num  < v-shift-num
               )
               OR   buf_shift-obj.shift-date < v-shift-date
              )
        use-index pi
        no-lock
        NO-ERROR.
   if available buf_shift-obj then do:
      assign
         v-shift-date-prev = buf_shift-obj.shift-date
         v-shift-num-prev  = buf_shift-obj.shift-num
      .
   end.
   else do:
      message
         "На объекте" v-obj-type v-obj-code skip
         "Нет закрытых смен" skip
         view-as alert-box error .
      return.
   end.
   release buf_shift-obj.
   run fill-place in this-procedure .
   run fill-sale in this-procedure .
   RUN find-date-shift in this-procedure
         ( input v-obj-type
         , input v-obj-code
         , input v-date-prediction
         , input v-start-time-prediction
         , output v-shift-date-prediction
         , output v-shift-num-prediction
         ) .
   define variable v-sec    as integer      no-undo.
   assign
      v-sec = v-start-time-prediction MOD 60
      v-minute-prediction = ((v-start-time-prediction - v-sec) / 60) mod 60
      v-hour-prediction   = (((v-start-time-prediction - v-sec) / 60) - v-minute-prediction) / 60
   .
   IF v-shift-num-prediction = 0
   THEN DO:
      message
         "Не существует смены недельной давности, требуемой для прогноза."
         skip "Выберите смену для прогноза."
      view-as alert-box information.
      run select-shift in this-procedure .
   END.
   run fill-prediction in this-procedure .
   run draw-place in this-procedure .
   run draw-pred in this-procedure .
   run enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE del-prediction :
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.
do
on error undo, return error
:
   for each buf_tt-place
      :
      assign
         buf_tt-place.sale-start-qnty-prev = 0.0
         buf_tt-place.sale-end-qnty-prev   = 0.0
         buf_tt-place.sale-qnty-prev       = 0.0
         buf_tt-place.sale-time-prev       = 999999
         buf_tt-place.sale-time-prev-end   = 999999
      .
   end.
   FOR EACH buf_tt-gds-pred
       :
      assign
         buf_tt-gds-pred.prediction-qnty  = 0.0
      .
      DELETE OBJECT buf_tt-gds-pred.hnd .
      DELETE OBJECT buf_tt-gds-pred.hnd-name .
      DELETE OBJECT buf_tt-gds-pred.hnd-sale-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-pred-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-total-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-sale-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-pred-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-total-qnty-l .
   end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE draw-place :
define variable v-frame-width    as integer      no-undo.
define variable v-frame-left     as integer      no-undo.
define variable v-frame-bottom   as integer      no-undo.
define variable v-frame-top   as integer      no-undo.
define variable v-step    as integer      no-undo.
define variable v-rect-width    as integer      no-undo.
define variable v-c    as integer      no-undo.
DEFINE VARIABLE  but1  AS HANDLE.
define buffer buf_tt-place    for tt-place.
do
on error undo, return error
:
   assign
      v-frame-width  = RECT-1:width IN FRAME Dialog-Frame
      v-frame-left   = 0.5 + RECT-1:column   IN FRAME Dialog-Frame
      v-frame-top    = 2 + RECT-1:row      IN FRAME Dialog-Frame
      v-rect-width   = (v-frame-width - 2 ) / v-count-place
      v-frame-bottom = RECT-1:row          IN FRAME Dialog-Frame + RECT-1:height   IN FRAME Dialog-Frame
      v-step         = DECIMAL( v-max-qnty / (RECT-1:height IN FRAME Dialog-Frame - 3))
   .
   FOR EACH buf_tt-place:
      assign
         v-c = v-c + 1
      .
      CREATE RECTANGLE buf_tt-place.hnd-top
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1)
             ROW           = v-frame-top + DECIMAL(( v-max-qnty - buf_tt-place.max-qnty) / v-step)
             WIDTH         = v-rect-width
             HEIGHT        = IF DECIMAL((buf_tt-place.max-qnty) / v-step ) <= 0 THEN 0.1 ELSE DECIMAL((buf_tt-place.max-qnty) / v-step )
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             FILLED        = TRUE
      .
      CREATE RECTANGLE buf_tt-place.hnd
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1)
             ROW           = v-frame-top + DECIMAL(( v-max-qnty - buf_tt-place.curr-qnty) / v-step)
             WIDTH         = v-rect-width
             HEIGHT        = IF DECIMAL((buf_tt-place.curr-qnty) / v-step ) <= 0.1 THEN 0.1 ELSE DECIMAL((buf_tt-place.curr-qnty) / v-step )
             BGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
      .
      CREATE TEXT buf_tt-place.hnd-name
      ASSIGN COLUMN             = v-frame-left + v-rect-width * (v-c - 1)
             row           = RECT-1:ROW + 0.2
             FGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = buf_tt-place.gds-name
      .
      CREATE TEXT buf_tt-place.hnd-max-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1) + 1
             ROW           = MINIMUM( buf_tt-place.hnd-top:ROW - 0.7, buf_tt-place.hnd:ROW - 1.4)
             FGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 9
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("Max &1", buf_tt-place.max-qnty)
      .
      CREATE TEXT buf_tt-place.hnd-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1) + 1
             ROW           = buf_tt-place.hnd:ROW - 0.7
             FGCOLOR       = (v-c - 1)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 9
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("Тек &1", buf_tt-place.curr-qnty)
      .
   end.
end.
END PROCEDURE.
PROCEDURE draw-pred :
define variable v-frame-width    as integer      no-undo.
define variable v-frame-left     as integer      no-undo.
define variable v-frame-top   as integer      no-undo.
define variable v-rect-width    as integer      no-undo.
define variable v-c    as integer      no-undo.
DEFINE VARIABLE  but1  AS HANDLE.
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred     for tt-gds-pred.
do
on error undo, return error
:
   assign
      v-frame-width  = RECT-2:width IN FRAME Dialog-Frame
      v-frame-left   = 0.5 + RECT-2:column   IN FRAME Dialog-Frame
      v-frame-top    = RECT-2:row      IN FRAME Dialog-Frame
      v-rect-width   = (v-frame-width - 2 ) / v-count-place
   .
   FOR EACH buf_tt-gds-pred:
      assign
         v-c = v-c + buf_tt-gds-pred.count-pl
      .
      CREATE RECTANGLE buf_tt-gds-pred.hnd
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl)
             ROW           = v-frame-top - 0.25
             WIDTH         = v-rect-width * count-pl
             HEIGHT        = RECT-2:height - 0.5
             BGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
      .
      CREATE TEXT buf_tt-gds-pred.hnd-name
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             row           = RECT-2:ROW + 0.7
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = buf_tt-gds-pred.gds-name
      .
      CREATE TEXT buf_tt-gds-pred.hnd-sale-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 1.4
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Реализация"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-sale-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 2.1
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING( buf_tt-gds-pred.sale-qnty)
      .
      CREATE TEXT buf_tt-gds-pred.hnd-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 2.85
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Остаток"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 3.5
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING(buf_tt-gds-pred.curr-qnty)
      .
      CREATE TEXT buf_tt-gds-pred.hnd-pred-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 4.25
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Прогноз"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-pred-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 4.9
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING(buf_tt-gds-pred.prediction-qnty)
      .
      CREATE TEXT buf_tt-gds-pred.hnd-total-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 5.65
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Итого"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-total-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 6.3
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("&1", (IF (rs-prediction = 1)
                                                THEN (buf_tt-gds-pred.curr-qnty - buf_tt-gds-pred.prediction-qnty + buf_tt-gds-pred.sale-qnty)
                                                ELSE (buf_tt-gds-pred.curr-qnty - buf_tt-gds-pred.prediction-qnty))
                                                )
      .
   end.
end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-date-prediction rs-prediction v-hour-prediction v-minute-prediction
          v-shift-num-prediction
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-help RECT-1 RECT-2 BROWSE-3 v-date-prediction b-sale
         rs-prediction b-shift BROWSE-4
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-3 FOR EACH br_tt-place.    OPEN QUERY BROWSE-4 FOR EACH br_tt-gds-pred.
END PROCEDURE.
PROCEDURE fill-place :
DEFINE BUFFER buf_place       FOR ub.place.
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump     for ub.rvs-line-pump .
define buffer buf_goods       for ub.goods.
define buffer buf_pl-gds      for ub.pl-gds .
define buffer buf_tt-place    for tt-place.
define variable v-start-sale-qnty    as decimal      no-undo.
define variable v-found    as logical      no-undo.
define variable v-fill               as logical      no-undo.
do
on error undo, return error:
   find first buf_rvs-doc
      where  buf_rvs-doc.obj-type   = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prev
         and buf_rvs-doc.shift-num  = v-shift-num-prev
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'смена':U
      no-lock
      no-error
      .
   _place:
   FOR EACH buf_place
       WHERE buf_place.obj-type = v-obj-type
         and buf_place.obj-code = v-obj-code
       no-lock
       :
      find first buf_pl-gds
           where buf_pl-gds.pl-code = buf_place.pl-code
           no-lock
           no-error
           .
      IF NOT AVAILABLE buf_pl-gds THEN do:
         message
            "Не найдена привязка товара к резервуару:" buf_place.pl-code
            skip
         view-as alert-box information.
         NEXT _place.
      end.
      find first buf_goods
         where buf_goods.gds-code = buf_pl-gds.gds-code
         no-lock
         no-error
         .
      IF NOT AVAILABLE buf_goods THEN do:
         message
            "Не найден товар " buf_pl-gds.gds-code
            "для резервуара "  buf_place.pl-code
            skip
         view-as alert-box information.
         NEXT _place.
      end.
      CREATE buf_tt-place.
      assign
         buf_tt-place.gds-code   = buf_goods.gds-code
         buf_tt-place.pl-code    = buf_place.pl-code
         buf_tt-place.max-qnty   = buf_place.max-qnty
         buf_tt-place.loc1       = buf_place.loc1
         buf_tt-place.gds-name   = buf_goods.gds-name
         v-count-place           = v-count-place + 1
         v-max-qnty             = IF v-max-qnty > buf_place.max-qnty THEN v-max-qnty ELSE buf_place.max-qnty
      .
      assign
         v-start-sale-qnty = 0.0
      .
      FOR EACH   buf_rvs-line-pump
           WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
             and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
             and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
             and buf_rvs-line-pump.pl-code  = buf_place.pl-code
             and buf_rvs-line-pump.gds-code = buf_goods.gds-code
           NO-LOCK
           :
           ASSIGN
               v-start-sale-qnty = v-start-sale-qnty + buf_rvs-line-pump.state-mh-cnt
           .
      END.
      ASSIGN
         buf_tt-place.sale-start-qnty = v-start-sale-qnty
         buf_tt-place.sale-qnty-curr  = buf_tt-place.sale-qnty-curr - v-start-sale-qnty
      .
      FIND FIRST buf_rvs-line
            WHERE buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
               and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
               and buf_rvs-line.gds-code = buf_tt-place.gds-code
         NO-LOCK
         no-error
         .
      IF  AVAILABLE buf_rvs-line
      then do:
         assign
            buf_tt-place.curr-qnty-start        = buf_rvs-line.state-measure-qnty
         .
      end.
   END.
   IF NOT CAN-FIND( FIRST buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date
        and buf_rvs-doc.shift-num  = v-shift-num
        and buf_rvs-doc.status_    = 'факт':U
        and buf_rvs-doc.rvs-type   = 'контроль':U
        )
   THEN DO:
      message
         "В текущей смене нет контрольных сверок"
         skip
      view-as alert-box error.
      return error.
   END.
   FOR each buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date
        and buf_rvs-doc.shift-num  = v-shift-num
        and buf_rvs-doc.status_    = 'факт':U
        and buf_rvs-doc.rvs-type   = 'контроль':U
        use-index shift
      no-lock
      :
      FOR EACH  buf_tt-place
          :
          IF  buf_tt-place.sale-fact-order < buf_rvs-doc.fact-order THEN DO:
               assign
                  v-found = FALSE
               .
               FOR EACH buf_rvs-line-pump
                     WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                        and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                        and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                        and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                        and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
               :
                  IF v-found = FALSE THEN DO:
                     assign
                        v-found = TRUE
                        buf_tt-place.sale-qnty-curr = 0
                     .
                  END.
                  assign
                     buf_tt-place.sale-fact-order  = buf_rvs-doc.fact-order
                     buf_tt-place.sale-qnty-curr   = buf_tt-place.sale-qnty-curr + buf_rvs-line-pump.state-mh-cnt
                     buf_tt-place.sale-time        = buf_rvs-doc.fact-time
                     buf_tt-place.sale-fill        = TRUE
                  .
               END.
               IF v-found = TRUE THEN DO:
                     assign
                        buf_tt-place.sale-qnty-curr = buf_tt-place.sale-qnty-curr - buf_tt-place.sale-start-qnty
                     .
               END.
          END.
      end.
      FOR EACH  buf_tt-place
          where buf_tt-place.curr-fill     = FALSE
           :
            FIND FIRST buf_rvs-line
                 WHERE buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                   and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                   and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                   and buf_rvs-line.pl-code  = buf_tt-place.pl-code
                   and buf_rvs-line.gds-code = buf_tt-place.gds-code
               NO-LOCK
               no-error
               .
            IF  AVAILABLE buf_rvs-line
            AND buf_tt-place.curr-fact-order < buf_rvs-doc.fact-order
            then do:
               assign
                  buf_tt-place.curr-qnty        = buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-fact-order  = buf_rvs-doc.fact-order
                  buf_tt-place.free-qnty        = buf_tt-place.max-qnty - buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-fill        = TRUE
                  v-max-qnty                    = IF v-max-qnty > buf_tt-place.curr-qnty THEN v-max-qnty ELSE buf_tt-place.curr-qnty
               .
            end.
      end.
   END.
   IF can-find(FIRST buf_tt-place
               WHERE buf_tt-place.sale-fill = FALSE
               )
   OR can-find(FIRST buf_tt-place
               WHERE buf_tt-place.curr-fill = FALSE
               )
   THEN DO:
      message
              "Не все топливные товары,"
         skip "привязанные к резервуарам и ТРК,"
         skip "присутствуют в сверках текущей смены."
      view-as alert-box information.
   end.
   FOR EACH  buf_tt-place
       WHERE buf_tt-place.sale-fill = FALSE
       :
       assign
         buf_tt-place.sale-qnty-curr = 0.0
       .
   end.
   FOR EACH  buf_tt-place
       WHERE buf_tt-place.curr-fill = FALSE
       :
         assign
            buf_tt-place.curr-qnty        = buf_tt-place.curr-qnty-start
         .
   end.
END.
END PROCEDURE.
PROCEDURE fill-prediction :
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump    for ub.rvs-line-pump.
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.
define buffer buf_shift-obj      for ub.shift-obj .
define variable v-end-qnty-prev  as decimal      no-undo.
define variable v-sale-qnty-prev   as decimal      no-undo.
define variable v-meas-date-pred   as date         no-undo.
define variable v-meas-time-pred   as integer      no-undo.
define variable v-time             as integer init 999999     no-undo.
define variable v-delta-time       as integer      no-undo.
define variable v-delta-time-end       as integer      no-undo.
define variable v-rvs-code         as character    no-undo.
define variable v-found    as logical      no-undo.
define variable v-found-control    as logical      no-undo.
define variable v-found-control-end    as logical      no-undo.
do
on error undo, return error
:
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND ((    buf_shift-obj.shift-date = v-shift-date-prediction
                AND buf_shift-obj.shift-num  < v-shift-num-prediction
               )
               OR   buf_shift-obj.shift-date < v-shift-date-prediction
              )
        use-index pi
        no-lock
        NO-ERROR.
   if available buf_shift-obj then do:
      find first buf_rvs-doc
         where buf_rvs-doc.obj-type = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'смена':U
         no-lock
         .
      FOR EACH   buf_tt-place,
          each   buf_rvs-line-pump
           WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
             and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
             and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
             and buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
             and buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
           NO-LOCK
           :
            assign
               buf_tt-place.sale-start-qnty-prev = buf_tt-place.sale-start-qnty-prev + buf_rvs-line-pump.state-mh-cnt
            .
      END.
   end.
   FOR each buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date-prediction
        and buf_rvs-doc.shift-num  = v-shift-num-prediction
        and buf_rvs-doc.status_    = 'факт':U
        and (buf_rvs-doc.rvs-type   = 'контроль':U
         OR buf_rvs-doc.rvs-type   = 'смена':U)
      no-lock
      :
      IF NOT v-found-control THEN DO:
         assign
            v-found-control = TRUE
         .
      END.
      FOR EACH  buf_tt-place
          :
          IF   ABS(buf_tt-place.sale-time - buf_rvs-doc.fact-time)
            < ABS(buf_tt-place.sale-time - buf_tt-place.sale-time-prev)
          THEN DO:
               assign
                  v-found = FALSE
               .
               FOR EACH buf_rvs-line-pump
                     WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                        and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                        and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                        and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                        and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
               :
                  IF v-found = FALSE THEN DO:
                     assign
                        v-found = TRUE
                        buf_tt-place.sale-qnty-prev = 0
                     .
                  END.
                  assign
                     buf_tt-place.sale-qnty-prev   = buf_tt-place.sale-qnty-prev + buf_rvs-line-pump.state-mh-cnt
                     buf_tt-place.sale-time-prev   = buf_rvs-doc.fact-time
                     v-delta-time = IF (buf_tt-place.sale-time - buf_tt-place.sale-time-prev) > v-delta-time THEN (buf_tt-place.sale-time - buf_tt-place.sale-time-prev) ELSE v-delta-time
                     v-start-time-prediction  = buf_tt-place.sale-time-prev
                  .
               END.
               IF v-found = TRUE THEN DO:
                     assign
                        buf_tt-place.sale-qnty-prev = buf_tt-place.sale-qnty-prev - buf_tt-place.sale-start-qnty-prev
                     .
               END.
          END.
      end.
   end.
   IF NOT v-found-control then do:
      message
         "В смене, заданной для прогноза, нет контрольных сверок"
         skip
      view-as alert-box information.
      return .
   end.
   IF v-delta-time > 1800 then do:
      message
         "В смене, заданной для прогноза, контрольная сверка"
         "отстоит по времени от точки начала прогноза более чем на 30 минут"
         skip
      view-as alert-box information.
   end.
   _buf_rvs-line-pump:
   for EACH buf_rvs-line-pump
      WHERE buf_rvs-line-pump.rvs-code = v-rvs-code
      NO-LOCK
      :
      find first buf_tt-place
           where buf_tt-place.gds-code = buf_rvs-line-pump.gds-code
             and buf_tt-place.pl-code  = buf_rvs-line-pump.pl-code
             no-error
             .
      IF NOT available buf_tt-place then do:
         next _buf_rvs-line-pump.
      end.
      assign
         buf_tt-place.sale-qnty-prev = buf_rvs-line-pump.state-mh-cnt
      .
   END.
   CASE rs-prediction :
   WHEN 1 THEN DO:
      find first buf_rvs-doc
         where buf_rvs-doc.obj-type = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prediction
         and buf_rvs-doc.shift-num  = v-shift-num-prediction
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'смена':U
         no-lock
         .
         assign
            v-found-control-end = TRUE
         .
      FOR EACH   buf_tt-place
      :
         FOR each buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
              and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
              and buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
              and buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
            NO-LOCK
            :
            assign
               buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev + buf_rvs-line-pump.state-mh-cnt
            .
         END.
         assign
            buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev - buf_tt-place.sale-start-qnty-prev
         .
      END.
   END.
   OTHERWISE DO:
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type   = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prediction
         and buf_rvs-doc.shift-num  = v-shift-num-prediction
         and buf_rvs-doc.status_    = 'факт':U
         and (buf_rvs-doc.rvs-type  = 'контроль':U
               OR
               buf_rvs-doc.rvs-type   = 'смена':U)
         no-lock
         :
         IF NOT v-found-control-end THEN DO:
            assign
               v-found-control-end = TRUE
            .
         END.
         FOR EACH  buf_tt-place
            :
            IF  ABS(v-end-time-prediction - buf_rvs-doc.fact-time)
               < ABS(v-end-time-prediction - buf_tt-place.sale-time-prev-end)
            THEN DO:
                  assign
                     v-found = FALSE
                  .
                  FOR EACH buf_rvs-line-pump
                        WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                           and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                           and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                           and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                           and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
                  :
                     IF v-found = FALSE THEN DO:
                        assign
                           v-found = TRUE
                           buf_tt-place.sale-end-qnty-prev = 0
                        .
                     END.
                     assign
                        buf_tt-place.sale-end-qnty-prev   = buf_tt-place.sale-end-qnty-prev + buf_rvs-line-pump.state-mh-cnt
                        buf_tt-place.sale-time-prev-end   = buf_rvs-doc.fact-time
                        v-delta-time-end = IF (buf_tt-place.sale-time - buf_tt-place.sale-time-prev-end) > v-delta-time THEN (buf_tt-place.sale-time - buf_tt-place.sale-time-prev-end) ELSE v-delta-time-end
                     .
                  END.
                  IF v-found = TRUE THEN DO:
                        assign
                           buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev - buf_tt-place.sale-start-qnty-prev
                        .
                  END.
            END.
         end.
      end.
   END.
   END CASE.
   IF NOT v-found-control-end then do:
      message
         "В смене, заданной для прогноза, нет контрольных сверок"
         skip
      view-as alert-box information.
      return .
   end.
   IF v-delta-time-end > 1800 then do:
      message
         "В смене, заданной для прогноза, контрольная сверка"
         "отстоит по времени от точки начала прогноза более чем на 30 минут"
         skip v-delta-time
      view-as alert-box information.
   end.
   define variable v-delta    as integer      no-undo.
   for each buf_tt-place
       no-lock
       break by buf_tt-place.gds-code
       :
     assign
        v-end-qnty-prev   = v-end-qnty-prev  + buf_tt-place.sale-end-qnty-prev
        v-sale-qnty-prev  = v-sale-qnty-prev   + buf_tt-place.sale-qnty-prev
        v-delta           = IF (v-delta > ABS((buf_tt-place.sale-time-prev - buf_tt-place.sale-time) / 60)) THEN v-delta ELSE ABS((buf_tt-place.sale-time-prev - buf_tt-place.sale-time) / 60)
        v-time            = IF (v-time > buf_tt-place.sale-time) THEN buf_tt-place.sale-time ELSE v-time
     .
     IF LAST-OF(buf_tt-place.gds-code) then do:
        find first buf_tt-gds-pred
             where buf_tt-gds-pred.gds-code = buf_tt-place.gds-code
             no-lock
             .
               IF v-sale-qnty-prev = 0 THEN message
                  SUBSTITUTE("Для топлива &1 невозможно рассчитать прогноз", buf_tt-gds-pred.gds-name)
                  skip
               view-as alert-box information.
               assign
                  buf_tt-gds-pred.prediction-qnty  = IF (rs-prediction = 1) THEN  v-end-qnty-prev                     * buf_tt-gds-pred.sale-qnty / v-sale-qnty-prev
                                                                            ELSE (v-end-qnty-prev - v-sale-qnty-prev) * buf_tt-gds-pred.sale-qnty / v-sale-qnty-prev
                  buf_tt-gds-pred.delta-time = v-delta
                  buf_tt-gds-pred.sale-time = v-time
                  v-sale-qnty-prev   = 0.0
                  v-end-qnty-prev    = 0.0
                  v-delta            = 0
                  v-time             = 999999
               .
     end.
   end.
end.
END PROCEDURE.
PROCEDURE fill-sale :
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump    for ub.rvs-line-pump.
DEFINE BUFFER buf_place       FOR ub.place.
define buffer buf_goods       for ub.goods.
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.
define variable v-counter     as integer      no-undo.
define variable v-start-qnty  as decimal      no-undo.
define variable v-sale-qnty   as decimal      no-undo.
define variable v-curr-qnty   as decimal      no-undo.
define variable v-rvs-code    as character      no-undo.
do
on error undo, return error
:
   assign
      v-counter = 0
   .
   for each buf_tt-place
      no-lock
      break by buf_tt-place.gds-code
      :
      assign
         v-counter      = v-counter + 1
         v-start-qnty   = v-start-qnty  + buf_tt-place.curr-qnty
         v-sale-qnty    = v-sale-qnty   + buf_tt-place.sale-qnty-curr
         v-curr-qnty    = v-curr-qnty   + buf_tt-place.curr-qnty
      .
      IF LAST-OF(buf_tt-place.gds-code) then do:
         create buf_tt-gds-pred.
         assign
            buf_tt-gds-pred.gds-code   = buf_tt-place.gds-code
            buf_tt-gds-pred.gds-name   = buf_tt-place.gds-name
            buf_tt-gds-pred.start-qnty = v-start-qnty
            buf_tt-gds-pred.sale-qnty  = v-sale-qnty
            buf_tt-gds-pred.curr-qnty  = v-curr-qnty
            buf_tt-gds-pred.count-pl   = v-counter
            v-start-qnty       = 0.0
            v-sale-qnty        = 0.0
            v-curr-qnty        = 0.0
            v-counter          = 0
         .
      end.
   end.
end.
END PROCEDURE.
PROCEDURE find-date-shift :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-date as date no-undo .
define input parameter p-time as integer no-undo .
define output parameter p-shift-date as date no-undo .
define output parameter p-shift-num as integer no-undo .
define buffer buf_shift-obj      for ub.shift-obj.
define variable v-fact-order    as decimal      no-undo.
do
on error undo, return error
:
   run  day-begin-fact-order in this-procedure
        ( input p-date
        , output v-fact-order
        ) .
   for each  buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
         and buf_shift-obj.obj-code =  p-obj-code
         and buf_shift-obj.fact-order >= v-fact-order
         and (buf_shift-obj.open-date < p-date
            or (buf_shift-obj.open-date = p-date
               and buf_shift-obj.open-time > p-time))
         and (buf_shift-obj.close-date > p-date
            or (buf_shift-obj.close-date = p-date
               and buf_shift-obj.close-time > p-time))
         and buf_shift-obj.status_ = 'зкр':U
      no-lock
      :
      assign
         p-shift-date = buf_shift-obj.shift-date
         p-shift-num  = buf_shift-obj.shift-num
      .
      return .
   end.
end.
END PROCEDURE.
PROCEDURE mandatory-24 :
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.
PROCEDURE mandatory-60 :
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.
PROCEDURE select-shift :
define variable v-ok    as logical      no-undo.
define variable v-shift-list    as character    no-undo.
define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_shift-obj      for ub.shift-obj.
do
on error undo, return error
:
   _shift:
   do
   on error undo, retry
   :
      assign
         v-ok = false
      .
      run str/sht-all.w ( parparentproc
                        , v-obj-type
                        , v-obj-code
                        , "b-sel"
                        , "obj"
                        , v-obj-type
                        , v-obj-code
                        , ""
                        , input-output v-shift-list
                        ) no-error.
      IF error-status:error
      THEN do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
         view-as alert-box error .
         return no-apply.
      end.
      IF v-shift-list =  "":U
      THEN do:
         return no-apply.
      end.
      find first buf_shift-obj
         where recid (buf_shift-obj) = integer (entry(1,v-shift-list))
         no-lock
         .
      IF buf_shift-obj.status_ = 'тек':U
      then do:
         message
            "Выбранная смена не закрыта" skip
            "Выбрать другую ?"
            view-as alert-box error
            buttons YES-NO
            update v-ok
            .
         IF v-ok then dO:
            undo _shift, retry _shift.
         end.
         else do:
            return no-apply.
         end.
      end.
   END.
   find first buf_rvs-doc
      where buf_rvs-doc.obj-type    = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'смена':U
      no-lock
      no-error
      .
   Assign
      v-date-prediction       = buf_shift-obj.shift-date
      v-shift-date-prediction = buf_shift-obj.shift-date
      v-shift-num-prediction  = buf_shift-obj.shift-num
      v-end-time-prediction   = IF ( rs-prediction = 1 ) THEN buf_rvs-doc.fact-time ELSE v-end-time-prediction
      v-end-time-prediction-shift = buf_rvs-doc.fact-time
   .
   release buf_shift-obj.
end.
END PROCEDURE.
PROCEDURE show-browser :
do
on error undo, return error
WITH FRAME Dialog-Frame
:
  define buffer buf_tt-place     for tt-place.
  define buffer buf_tt-gds-pred     for tt-gds-pred.
  HIDE rect-1.
  HIDE rect-2.
  FOR EACH buf_tt-place :
      hide
         buf_tt-place.hnd
         buf_tt-place.hnd-top
         buf_tt-place.hnd-qnty
         buf_tt-place.hnd-max-qnty
         buf_tt-place.hnd-name
      .
  END.
  FOR EACH buf_tt-gds-pred :
      hide
         buf_tt-gds-pred.hnd
         buf_tt-gds-pred.hnd-name
         buf_tt-gds-pred.hnd-qnty
         buf_tt-gds-pred.hnd-sale-qnty
         buf_tt-gds-pred.hnd-pred-qnty
         buf_tt-gds-pred.hnd-total-qnty
         buf_tt-gds-pred.hnd-qnty-l
         buf_tt-gds-pred.hnd-sale-qnty-l
         buf_tt-gds-pred.hnd-pred-qnty-l
         buf_tt-gds-pred.hnd-total-qnty-l
      .
  END.
  DISPLAY
      BROWSE-3
      BROWSE-4
  .
end.
END PROCEDURE.
PROCEDURE show-histogramm :
do
on error undo, return error
WITH FRAME Dialog-Frame
:
  define buffer buf_tt-place     for tt-place.
  define buffer buf_tt-gds-pred     for tt-gds-pred.
  HIDE browse-3.
  HIDE browse-4.
  DISPLAY
      RECT-1
      RECT-2
      .
  FOR EACH buf_tt-place :
      Assign
            buf_tt-place.hnd-name      :HIDDEN = FALSE
            buf_tt-place.hnd-max-qnty  :HIDDEN = FALSE
            buf_tt-place.hnd-qnty      :HIDDEN = FALSE
            buf_tt-place.hnd-top       :HIDDEN = FALSE
            buf_tt-place.hnd           :HIDDEN = FALSE
      .
  END.
  FOR EACH buf_tt-gds-pred :
      assign
         buf_tt-gds-pred.hnd           :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-name      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-qnty      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-sale-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-pred-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-total-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-qnty-l      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-sale-qnty-l :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-pred-qnty-l :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-total-qnty-l :HIDDEN = FALSE
      .
  END.
end.
END PROCEDURE.
