define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-date-begin as date no-undo.
define input parameter p-time-begin as integer no-undo.
define input parameter p-date-end as date no-undo.
define input parameter p-time-end as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реализация по видам топлива".
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
define variable v-time-begin  as integer      no-undo.
define variable v-time-end    as integer      no-undo.
DEFINE TEMP-TABLE tt-gds-sale NO-UNDO
   field gds-code           like ub.goods.gds-code
   field gds-name           like ub.goods.gds-name
   field sale-qnty-mass     like ub.rvs-line.state-measure-qnty
   field sale-qnty-value    like ub.rvs-line.state-measure-qnty
   field density            as decimal
   field rvs-count          as integer
index pu as primary unique
      gds-code
 .
define buffer buf_tt-gds-sale    for tt-gds-sale.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-qiut AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-date-begin AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-end AS DATE FORMAT "99/99/99":U
     LABEL "Дата окончания"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE v-hour-begin AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-hour-end AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "время"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-minute-begin AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-minute-end AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-5 FOR
      buf_tt-gds-sale SCROLLING.
DEFINE BROWSE BROWSE-5
  QUERY BROWSE-5 DISPLAY
      buf_tt-gds-sale.gds-name        COLUMN-LABEL "Топливо"
buf_tt-gds-sale.sale-qnty-value COLUMN-LABEL "Литры"
buf_tt-gds-sale.sale-qnty-mass  COLUMN-LABEL "Килограммы"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.5 BY 8.75 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-qiut AT ROW 1 COL 1
     b-help AT ROW 1 COL 71
     v-date-begin AT ROW 2.25 COL 13 COLON-ALIGNED
     v-date-end AT ROW 2.25 COL 44.5 COLON-ALIGNED
     v-hour-begin AT ROW 3.5 COL 13 COLON-ALIGNED
     v-minute-begin AT ROW 3.5 COL 18.5 COLON-ALIGNED
     v-hour-end AT ROW 3.5 COL 44.5 COLON-ALIGNED
     v-minute-end AT ROW 3.5 COL 50 COLON-ALIGNED
     BROWSE-5 AT ROW 5 COL 1.5
     SPACE(0.74) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Реализация по видам топлива"
         CANCEL-BUTTON b-qiut.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON LEAVE OF v-date-begin IN FRAME Dialog-Frame
DO:
    ASSIGN
          v-date-begin
    .
    run mandatory-begin-end in this-procedure .
    run fill-sale in this-procedure .
    run enable_UI in this-procedure .
END.
ON LEAVE OF v-date-end IN FRAME Dialog-Frame
DO:
   ASSIGN
         v-date-begin
         v-date-end
   .
   run mandatory-begin-end in this-procedure .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.
ON LEAVE OF v-hour-begin IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-hour-begin
   .
   RUN mandatory-24 IN THIS-PROCEDURE
         (INPUT-OUTPUT v-hour-begin ) .
   run mandatory-begin-end in this-procedure .
   assign
      v-time-begin = v-hour-begin * 60 * 60 + v-minute-begin * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.
ON LEAVE OF v-hour-end IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-hour-end
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-hour-end ) .
   run mandatory-begin-end in this-procedure .
   assign
      v-time-end = v-hour-end * 60 * 60 + v-minute-end * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.
ON LEAVE OF v-minute-begin IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-minute-begin
   .
   run MANDATORY-60 IN THIS-PROCEDURE
         (INPUT-OUTPUT v-minute-begin ) .
   run mandatory-begin-end in this-procedure .
   assign
      v-time-begin = v-hour-begin * 60 * 60 + v-minute-begin * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.
ON LEAVE OF v-minute-end IN FRAME Dialog-Frame
DO:
   ASSIGN
   v-minute-end
   .
   run MANDATORY-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-minute-end ) .
   run mandatory-begin-end in this-procedure .
   assign
      v-time-end = v-hour-end * 60 * 60 + v-minute-end * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run reset-date in this-procedure .
   IF v-date-begin > v-date-end THEN DO:
      assign
         v-date-end = v-date-begin
      .
   END.
   IF v-date-begin = v-date-end
   AND v-hour-begin > v-hour-end
   THEN DO:
      assign
            v-hour-end = v-hour-begin
      .
   END.
   IF v-date-begin = v-date-end
   AND v-hour-begin = v-hour-end
   AND v-minute-begin > v-minute-end
   THEN DO:
      assign
         v-minute-end = v-minute-begin
      .
   END.
   run fill-sale in this-procedure .
   run enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-date-begin v-date-end v-hour-begin v-minute-begin v-hour-end
          v-minute-end
      WITH FRAME Dialog-Frame.
  ENABLE b-qiut b-help v-date-begin v-date-end v-hour-begin v-minute-begin
         v-hour-end v-minute-end BROWSE-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-5 FOR EACH buf_tt-gds-sale.
END PROCEDURE.
PROCEDURE fill-sale :
do
on error undo, return error
:
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-gds     for ub.chk-gds.
define buffer buf_pl-gds      for ub.pl-gds.
define buffer buf_tt-gds-sale for tt-gds-sale.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods.
define buffer buf_rvs-doc     for rvs-doc.
define buffer buf_rvs-line-pump     for rvs-line-pump.
define buffer buf_rvs-line    for rvs-line .
define buffer buf_doc-line    for doc-line .
define buffer buf_inkas       for inkas .
define buffer buf_shift-obj      for shift-obj.
define variable v-shift-num    as integer      no-undo.
define variable v-shift-date    as date      no-undo.
define variable v-delta-time    as integer      no-undo.
define variable v-delta-time-2  as integer      no-undo.
define variable v-rvs-code    as character    no-undo.
define variable v-density    as decimal      no-undo.
define variable v-fact-order-start    as decimal      no-undo.
define variable v-fact-order-end      as decimal      no-undo.
define variable v-close    as logical      no-undo.
   assign
      v-close        = FALSE
      v-shift-num    = 0
      v-shift-date   = ?
   .
   empty temp-table buf_tt-gds-sale.
   FIND FIRST buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
         and buf_shift-obj.obj-code =  p-obj-code
         and buf_shift-obj.status_ = 'тек':U
      no-lock
      no-error.
   IF AVAILABLE buf_shift-obj THEN DO:
      IF (buf_shift-obj.open-date < v-date-begin)
      OR (buf_shift-obj.open-date = v-date-begin
      AND buf_shift-obj.open-time <= v-time-begin)
      THEN DO:
         assign
            v-close = FALSE
         .
      end.
      else do:
         assign
            v-close = TRUE
         .
      end.
   END.
   IF v-close THEN DO:
      _chk:
      for each buf_chk-doc
         where  buf_chk-doc.obj-type   = p-obj-type
            and buf_chk-doc.obj-code  = p-obj-code
            and ((    buf_chk-doc.chk-date =  v-date-begin
                  and buf_chk-doc.chk-time >= v-time-begin)
                or
                 (buf_chk-doc.chk-date > v-date-begin)
                )
            and ((buf_chk-doc.chk-date = v-date-end
                  and buf_chk-doc.chk-time <= v-time-end)
                  or (buf_chk-doc.chk-date <  v-date-end))
            and (buf_chk-doc.chk-type = INTEGER('1':U)
             OR buf_chk-doc.chk-type  = INTEGER('6':U))
         and buf_chk-doc.out-code <> ?
         no-lock
         ,
        first buf_inkas
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = 'факт':U
         no-lock,
         each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
         :
            FIND FIRST buf_bar-code
               WHERE buf_bar-code.b-code = buf_chk-gds.b-code
               NO-LOCK
               .
            FIND first buf_pl-gds
               where buf_pl-gds.gds-code = buf_bar-code.gds-code
                  and buf_pl-gds.obj-type = p-obj-type
                  and buf_pl-gds.obj-code = p-obj-code
               no-lock
               no-error
               .
            IF not available buf_pl-gds THEN DO:
               next _chk.
            END.
            FIND first buf_goods
               where buf_goods.gds-code = buf_bar-code.gds-code
               no-lock
               .
         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_pl-gds.gds-code
               no-error.
         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_pl-gds.gds-code
                  no-lock
                  .
            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value + buf_chk-gds.doc-qnty
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  + buf_chk-gds.doc-qnty * buf_chk-gds.density
         .
      end.
   END.
   ELSE DO:
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.shift-date = v-shift-date
         and buf_rvs-doc.shift-num  = v-shift-num
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'контроль':U
         no-lock
         :
         IF v-date-begin = buf_rvs-doc.fact-date
         then do:
            IF v-delta-time > ABS(buf_rvs-doc.fact-time - v-time-begin)
            then do:
               assign
                  v-delta-time = ABS(buf_rvs-doc.fact-time - v-time-begin)
                  v-rvs-code  = buf_rvs-doc.rvs-code
                  v-fact-order-start = buf_rvs-doc.fact-order
               .
            end.
         end.
         else do:
            assign
            v-delta-time-2 = IF v-date-begin > buf_rvs-doc.fact-date
                           then ABS(buf_rvs-doc.fact-time - ((v-date-begin - buf_rvs-doc.fact-date) * 86400 - buf_rvs-doc.fact-time + v-time-begin))
                           else ABS(buf_rvs-doc.fact-time - ((buf_rvs-doc.fact-date - v-date-begin) * 86400 - v-time-begin + buf_rvs-doc.fact-time))
            .
            IF v-delta-time > v-delta-time-2
            then do:
               assign
                  v-delta-time = v-delta-time-2
                  v-rvs-code  = buf_rvs-doc.rvs-code
               .
            end.
         end.
      end.
      IF v-delta-time = 9999999 then do:
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
         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_rvs-line-pump.gds-code
               no-error.
         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  .
            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value - IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  - IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
         .
      END.
      assign
         v-delta-time = 9999999
      .
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.shift-date = v-shift-date
         and buf_rvs-doc.shift-num  = v-shift-num
         and buf_rvs-doc.status_    = 'факт':U
         and (buf_rvs-doc.rvs-type  = 'контроль':U
               OR
               buf_rvs-doc.rvs-type   = 'смена':U)
         no-lock
         :
         IF v-date-end = buf_rvs-doc.fact-date
         then do:
            IF v-delta-time > ABS(buf_rvs-doc.fact-time - v-time-end)
            then do:
               assign
                  v-delta-time = ABS(buf_rvs-doc.fact-time - v-time-end)
                  v-rvs-code  = buf_rvs-doc.rvs-code
                  v-fact-order-end = buf_rvs-doc.fact-order
               .
            end.
         end.
         else do:
            assign
            v-delta-time-2 = IF v-date-end > buf_rvs-doc.fact-date
                           then ABS(buf_rvs-doc.fact-time - ((v-date-end - buf_rvs-doc.fact-date) * 86400 - buf_rvs-doc.fact-time + v-time-end))
                           else ABS(buf_rvs-doc.fact-time - ((buf_rvs-doc.fact-date - v-date-end) * 86400 - v-time-end + buf_rvs-doc.fact-time))
            .
            IF v-delta-time > v-delta-time-2
            then do:
               assign
                  v-delta-time = v-delta-time-2
                  v-rvs-code  = buf_rvs-doc.rvs-code
               .
            end.
         end.
      end.
      IF v-delta-time = 9999999 then do:
         message
            "В смене, заданной для прогноза, нет контрольных сверок"
            skip
         view-as alert-box information.
         return.
      end.
      IF v-delta-time > 1800 then do:
         message
            "В смене, заданной для прогноза, контрольная сверка"
            "отстоит по времени от точки окончания прогноза более чем на 30 минут"
            skip
         view-as alert-box information.
      end.
      _buf_rvs-line-pump:
      for EACH buf_rvs-line-pump
         WHERE buf_rvs-line-pump.rvs-code = v-rvs-code
         NO-LOCK
         :
         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_rvs-line-pump.gds-code
               no-error.
         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  .
            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value + IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  + (IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0)
         .
      END.
      FOR each buf_rvs-doc
            where buf_rvs-doc.obj-type = p-obj-type
            and buf_rvs-doc.obj-code   = p-obj-code
            and buf_rvs-doc.shift-date = v-shift-date
            and buf_rvs-doc.shift-num  = v-shift-num
            and buf_rvs-doc.status_    = 'факт':U
            and (buf_rvs-doc.rvs-type  = 'контроль':U
                  OR
                  buf_rvs-doc.rvs-type   = 'смена':U)
            and buf_rvs-doc.fact-order >= v-fact-order-start
            and buf_rvs-doc.fact-order <= v-fact-order-end
            no-lock
            ,
            each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            ,
            first buf_tt-gds-sale
            where buf_tt-gds-sale.gds-code = buf_rvs-line.gds-code
            :
            assign
               buf_tt-gds-sale.density = buf_tt-gds-sale.density + buf_rvs-line.density
               buf_tt-gds-sale.rvs-count = buf_tt-gds-sale.rvs-count + 1
            .
      end.
      FOR EACH buf_tt-gds-sale
          :
            assign
               buf_tt-gds-sale.density = buf_tt-gds-sale.density / buf_tt-gds-sale.rvs-count
               buf_tt-gds-sale.sale-qnty-mass = buf_tt-gds-sale.sale-qnty-mass * buf_tt-gds-sale.density
            .
      end.
   END.
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
PROCEDURE mandatory-begin-end :
do
on error undo, return error
:
   IF v-date-begin > v-date-end THEN DO:
      message
         "Дата окончания не может быть меньше даты начала."
         skip
      view-as alert-box information.
      assign
            v-date-end = v-date-begin
      .
   END.
   IF v-date-begin = v-date-end
   AND v-hour-begin > v-hour-end
   THEN DO:
      message
         "Время окончания не может быть меньше даты начала."
         skip
      view-as alert-box information.
      assign
            v-hour-end = v-hour-begin
      .
   END.
   IF v-date-begin = v-date-end
   AND v-hour-begin = v-hour-end
   AND v-minute-begin > v-minute-end
   THEN DO:
   message
      "Время окончания не может быть меньше даты начала."
      skip
   view-as alert-box information.
   assign
      v-minute-end = v-minute-begin
   .
   END.
end.
END PROCEDURE.
PROCEDURE reset-date :
do
on error undo, return error
:
  define variable v-sec    as integer      no-undo.
  assign
     v-date-begin     = p-date-begin
     v-date-end       = p-date-end
     v-time-begin     = p-time-begin
     v-time-end       = p-time-end
     v-sec            = p-time-begin MOD 60
     v-minute-begin   = ((p-time-begin - v-sec) / 60) mod 60
     v-hour-begin     = (((p-time-begin - v-sec) / 60) - v-minute-begin) / 60
  .
  assign
     v-sec            = p-time-end MOD 60
     v-minute-end     = ((p-time-end - v-sec) / 60) mod 60
     v-hour-end       = (((p-time-end - v-sec) / 60) - v-minute-end) / 60
  .
end.
END PROCEDURE.
