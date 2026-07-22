DEFINE BUFFER buy-clients FOR ub.clients.
DEFINE BUFFER obj-clients FOR ub.clients.
DEFINE TEMP-TABLE tt-turnover-buyer NO-UNDO LIKE ub.turnover-buyer.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input-output parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка Оборота ПОКУПАТЕЛЯ".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
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
DEFINE BUTTON B-b-r
     LABEL "<<"
     SIZE 4 BY 1.13 TOOLTIP "Пересчитать из базовой валюты в национальную".
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-r-b
     LABEL ">>"
     SIZE 4 BY 1.13 TOOLTIP "Пересчитать в базовую валюту".
DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Список смен".
DEFINE VARIABLE v-base-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-base-rate AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Курс"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Базовая валюта" NO-UNDO.
DEFINE VARIABLE v-base-scale AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "М-б" NO-UNDO.
DEFINE VARIABLE v-rubl-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 87.5 BY 6.25.
DEFINE QUERY Dialog-Frame FOR
      tt-turnover-buyer,
      buy-clients,
      obj-clients SCROLLING.
DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
          B-Help AT ROW 1 COL 77.88
     tt-turnover-buyer.des AT ROW 3.04 COL 13.13 COLON-ALIGNED HELP
          ""
          LABEL "Обоснование" FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 72.5 BY 1 TOOLTIP "Обоснование оборота"
     r-cli AT ROW 4 COL 29.5
     tt-turnover-buyer.fact-date AT ROW 4.96 COL 13.13 COLON-ALIGNED
          LABEL "Дата оборота"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-turnover-buyer.shift-date AT ROW 4.96 COL 37.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-turnover-buyer.shift-num AT ROW 4.96 COL 56.38 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-turnover-buyer.shift-name AT ROW 5 COL 50 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     r-shift AT ROW 5 COL 61.5
     tt-turnover-buyer.sum-doc-rubl AT ROW 7.92 COL 30 COLON-ALIGNED
          LABEL "Сумма в ценах реализации"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-doc-base AT ROW 7.92 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     B-r-b AT ROW 8.25 COL 54.5
     tt-turnover-buyer.sum-acc-rubl AT ROW 8.96 COL 30 COLON-ALIGNED
          LABEL "Сумма в учетных ценах"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-acc-base AT ROW 8.96 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     B-b-r AT ROW 9.75 COL 54.5
     tt-turnover-buyer.sum-vat-doc-rubl AT ROW 10 COL 30 COLON-ALIGNED
          LABEL "Сумма НДС в ценах реализации"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-doc-base AT ROW 10 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-acc-rubl AT ROW 11.04 COL 30 COLON-ALIGNED
          LABEL "Сумма НДС в учетных ценах"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-acc-base AT ROW 11.04 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.cli-code AT ROW 2.25 COL 13 COLON-ALIGNED
          LABEL "Покупатель"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 1
     tt-turnover-buyer.cli-type AT ROW 2.25 COL 22 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 1
     buy-clients.obj-name AT ROW 2.25 COL 27.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY .67
          FGCOLOR 1
     tt-turnover-buyer.obj-code AT ROW 4.13 COL 13 COLON-ALIGNED
          LABEL "Объект"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-turnover-buyer.obj-type AT ROW 4.13 COL 23 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     obj-clients.obj-name AT ROW 4.21 COL 31 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY .67
     v-rubl-abbr AT ROW 6.25 COL 30 COLON-ALIGNED NO-LABEL
     v-base-abbr AT ROW 6.25 COL 62 COLON-ALIGNED NO-LABEL
     v-base-rate AT ROW 7.25 COL 62.13 COLON-ALIGNED
     v-base-scale AT ROW 7.25 COL 77.63 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 6 COL 1
     SPACE(0.00) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление оборотов покупателю"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       r-shift:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN save-proc no-error .
  if error-status :error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    "Ошибка"
    view-as alert-box error
  .
  return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-b-r IN FRAME Dialog-Frame
DO:
assign
tt-turnover-buyer.sum-acc-base
tt-turnover-buyer.sum-doc-base
tt-turnover-buyer.sum-vat-acc-base
tt-turnover-buyer.sum-vat-doc-base
  tt-turnover-buyer.sum-acc-rubl     =  tt-turnover-buyer.sum-acc-base       / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-doc-rubl     =  tt-turnover-buyer.sum-doc-base       / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-vat-acc-rubl =  tt-turnover-buyer.sum-vat-acc-base   / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-vat-doc-rubl =  tt-turnover-buyer.sum-vat-doc-base   / v-base-scale * v-base-rate
.
  display tt-turnover-buyer.sum-acc-rubl
          tt-turnover-buyer.sum-doc-rubl
          tt-turnover-buyer.sum-vat-acc-rubl
          tt-turnover-buyer.sum-vat-doc-rubl
          with frame Dialog-Frame .
END.
ON CHOOSE OF B-r-b IN FRAME Dialog-Frame
DO:
assign
  tt-turnover-buyer.sum-acc-rubl
  tt-turnover-buyer.sum-doc-rubl
  tt-turnover-buyer.sum-vat-acc-rubl
  tt-turnover-buyer.sum-vat-doc-rubl
  tt-turnover-buyer.sum-acc-base     =  tt-turnover-buyer.sum-acc-rubl       / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-doc-base     =  tt-turnover-buyer.sum-doc-rubl       / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-vat-acc-base =  tt-turnover-buyer.sum-vat-acc-rubl   / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-vat-doc-base =  tt-turnover-buyer.sum-vat-doc-rubl   / v-base-rate * v-base-scale
.
  display tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base
          with frame Dialog-Frame .
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  define variable rep-rec2      as recid     no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-base-code   as integer   no-undo .
  define variable v-fact-date   as date      no-undo .
  define variable v-shift-date  as date      no-undo .
  define variable v-shift-num   as integer   no-undo .
  define variable v-shift-name  as character no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  assign
    v-base-rate  =  ?
    v-base-scale =  ?
    v-base-abbr  =  ""
  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    return no-apply .
  end.
  define buffer buf_obj-clients for ub.clients  .
  find first buf_obj-clients no-lock
    where buf_obj-clients.obj-type = v-obj-type
      and buf_obj-clients.obj-code = v-obj-code
    no-error .
  if available buf_obj-clients then do :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-clients.obj-type
  ,input  buf_obj-clients.obj-code
  ,output v-host-code
  ) no-error .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  ) no-error .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_obj-clients.obj-type
  ,input  buf_obj-clients.obj-code
  ,output v-fact-date
  ) no-error .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_obj-clients.obj-type
  ,input  buf_obj-clients.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
    if error-status :error then
       hide tt-turnover-buyer.shift-date  tt-turnover-buyer.shift-num  tt-turnover-buyer.shift-name r-shift in frame Dialog-Frame .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  ,output v-base-abbr
  ) no-error .
  end.
  OPEN QUERY Dialog-Frame FOR EACH tt-turnover-buyer NO-LOCK,              EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK,              EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK.
  GET FIRST Dialog-Frame.
  Display buf_obj-clients.obj-code @ tt-turnover-buyer.obj-code
          buf_obj-clients.obj-type @ tt-turnover-buyer.obj-type
          buf_obj-clients.obj-name @ obj-clients.obj-name
          v-base-rate
          v-base-scale
          v-base-abbr
          v-fact-date   @ tt-turnover-buyer.fact-date
          v-shift-date  @ tt-turnover-buyer.shift-date
          v-shift-num   @ tt-turnover-buyer.shift-num
          v-shift-name  @ tt-turnover-buyer.shift-name
          r-shift   when v-shift-date <> ?
          with frame Dialog-Frame .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_obj-clients.obj-type
  ,input  buf_obj-clients.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
    if error-status :error then
       hide tt-turnover-buyer.shift-date  tt-turnover-buyer.shift-num  tt-turnover-buyer.shift-name r-shift in frame Dialog-Frame .
END.
ON CHOOSE OF r-shift IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
    assign tt-turnover-buyer.obj-type tt-turnover-buyer.obj-code .
  run str/sht-all.w
   ( input parparentproc,
     input v-cntxt-obj-type,
     input v-cntxt-obj-code,
     input 'b-sel',
     input 'obj',
     input tt-turnover-buyer.obj-type,
     input tt-turnover-buyer.obj-code,
     input '':U,
     input-output varrid-list)
     no-error.
  if error-status:error or varrid-list = "":u then do:
    return no-apply.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        tt-turnover-buyer.fact-date  = bf_shift-obj.shift-date
        tt-turnover-buyer.shift-date = bf_shift-obj.shift-date
        tt-turnover-buyer.shift-num  = bf_shift-obj.shift-num
        tt-turnover-buyer.shift-name = bf_shift-obj.shift-name.
      display tt-turnover-buyer.fact-date tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num tt-turnover-buyer.shift-name with frame Dialog-Frame.
     end.
END.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
on delete-character of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
on ctrl-d of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
on ctrl-b of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
on ctrl-e of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
on ctrl-f of tt-turnover-buyer.fact-date in frame Dialog-Frame
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
  define MENU m-ed-date17
    MENU-ITEM m-ed-date17-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date17-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date17-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date17-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-turnover-buyer.fact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-turnover-buyer.fact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date17 :HANDLE
      tt-turnover-buyer.fact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle17 as handle no-undo .
  assign
    v-label-handle17 = tt-turnover-buyer.fact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle17)
  then do:
    if v-label-handle17 :tooltip = ""
    or v-label-handle17 :tooltip = ?
    then do:
      assign
        v-label-handle17 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date17-1 in menu m-ed-date17 DO:
    apply "ctrl-b":U to tt-turnover-buyer.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-2 in menu m-ed-date17 DO:
    apply "ctrl-d":U to tt-turnover-buyer.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-3 in menu m-ed-date17 DO:
    apply "ctrl-e":U to tt-turnover-buyer.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-4 in menu m-ed-date17 DO:
    apply "ctrl-f":U to tt-turnover-buyer.fact-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = 'ДОБАВЛЕНИЕ':U  then  run my-enable-add .
                          else run my-enable .
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-turnover-buyer.des.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-turnover-buyer NO-LOCK,              EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK,              EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-turnover-buyer THEN
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name tt-turnover-buyer.sum-doc-rubl
          tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-acc-rubl
          tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-acc-rubl
          tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.cli-code
          tt-turnover-buyer.cli-type tt-turnover-buyer.obj-code
          tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-Help RECT-1 tt-turnover-buyer.des r-cli
         tt-turnover-buyer.fact-date tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base B-r-b tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base B-b-r
         tt-turnover-buyer.sum-vat-doc-rubl tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
         tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
         buy-clients.obj-name tt-turnover-buyer.obj-code
         tt-turnover-buyer.obj-type obj-clients.obj-name v-rubl-abbr
         v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-enable :
define variable g-log as logical   no-undo .
define buffer buf_turnover-buyer for ub.turnover-buyer  .
define variable v-shift-date  as date     no-undo .
define variable v-shift-num   as integer  no-undo .
define variable v-shift-name as character no-undo.
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstall in g#library
(  output v-use-grp-buy
 , output v-use-oborot-buy
 , output v-use-qnty-group
 , output v-use-sum-group
 , output v-use-add-code
 , output v-use-sys-date-time
 , output v-use-shift-date-num
 , output v-use-cassa
 , output v-use-val
 , output v-use-pay-type
 , output v-use-cash-pay
 , output v-use-child
        )  .
if not ( v-use-grp-buy or v-use-oborot-buy )  then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.
  for each tt-turnover-buyer : delete tt-turnover-buyer . end.
  if p-mode = 'ПРОСМОТР':U
    then  find first buf_turnover-buyer no-lock where        recid(buf_turnover-buyer) = p-recid no-error .
    else  find first buf_turnover-buyer exclusive-lock where recid(buf_turnover-buyer) = p-recid no-error .
  create tt-turnover-buyer.
     BUFFER-COPY buf_turnover-buyer TO tt-turnover-buyer
  .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
v-rubl-abbr = "РУБ" .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-turnover-buyer.obj-type
  ,input  tt-turnover-buyer.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  ,output v-base-abbr
  )  .
  OPEN QUERY Dialog-Frame FOR EACH tt-turnover-buyer NO-LOCK,              EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK,              EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-turnover-buyer THEN do:
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name
          tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
          tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U  then
  ENABLE B-Cancel RECT-1 B-save B-Help tt-turnover-buyer.des
         tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-vat-acc-rubl
         tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-doc-rubl
         v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      b-r-b b-b-r
      WITH FRAME Dialog-Frame.
      else do:
  ENABLE B-Cancel B-Help
      WITH FRAME Dialog-Frame.
      B-Cancel:label = "&Выход" .
      hide B-save in frame Dialog-Frame .
      end.
  if tt-turnover-buyer.shift-date <> ? then do:
     display
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
     with frame Dialog-Frame .
  end.
  else do:
     hide
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
     in frame Dialog-Frame .
  end.
   ASSIGN frame Dialog-Frame:TITLE = "Обороты покупателя  "   + buy-clients.obj-name
   + " - " + caps(p-mode).
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-enable-add :
define buffer buf_global-state for ub.global-state  .
define variable g-log as logical   no-undo .
define buffer buf_turnover-buyer for ub.turnover-buyer  .
find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.
   find first buf_turnover-buyer no-lock where recid(buf_turnover-buyer) = p-recid no-error .
for each tt-turnover-buyer : delete tt-turnover-buyer . end.
  create tt-turnover-buyer.
     assign
        tt-turnover-buyer.cli-code  = p-cli-code
        tt-turnover-buyer.cli-type  = p-cli-type
        tt-turnover-buyer.sum-type   = ""
        tt-turnover-buyer.type       = 1
     .
  OPEN QUERY Dialog-Frame FOR EACH tt-turnover-buyer NO-LOCK,              EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK,              EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK.
  GET FIRST Dialog-Frame.
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
v-rubl-abbr = "РУБ" .
  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-turnover-buyer THEN do:
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name
          tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
          tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.
  end.
  ENABLE B-Cancel RECT-1 B-save B-Help tt-turnover-buyer.des r-shift
         tt-turnover-buyer.fact-date
         r-cli tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-vat-acc-rubl
         tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-doc-rubl tt-turnover-buyer.cli-code
         tt-turnover-buyer.cli-type buy-clients.obj-name
         tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
          b-r-b b-b-r
         obj-clients.obj-name v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  if buf_global-state.pl-use-shift-date-num  = false then do:
     tt-turnover-buyer.shift-date = ? .
     tt-turnover-buyer.shift-num  = ? .
     tt-turnover-buyer.shift-name = ? .
     hide
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
      r-shift
     in frame Dialog-Frame .
  end.
   ASSIGN frame Dialog-Frame:TITLE = "Обороты покупателя  "   + buy-clients.obj-name
   + " - " + caps(p-mode).
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE save-proc :
ASSIGN frame Dialog-Frame
 tt-turnover-buyer.des tt-turnover-buyer.fact-date tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
 tt-turnover-buyer.shift-name
 .
   define variable v-fact-order  as decimal   no-undo .
   define variable v-fact-time as decimal   no-undo .
   define variable v-shift-end-fact-order as decimal   no-undo .
   define variable v-day-end-fact-order  as decimal   no-undo .
   define variable l-shift-on as logical   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  tt-turnover-buyer.obj-type
  ,input  tt-turnover-buyer.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      v-fact-time = time .
      run factord in this-procedure
        (input  tt-turnover-buyer.fact-date
        ,input  v-fact-time
        ,input  1
        ,input  tt-turnover-buyer.shift-date
        ,input  tt-turnover-buyer.shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
    if p-mode = 'ДОБАВЛЕНИЕ':U  then do:
          find first ub.shift-obj where ub.shift-obj.obj-type   = tt-turnover-buyer.obj-type   and
                                        ub.shift-obj.obj-code   = tt-turnover-buyer.obj-code   and
                                        ub.shift-obj.shift-date = tt-turnover-buyer.shift-date and
                                        ub.shift-obj.shift-num  = tt-turnover-buyer.shift-num  no-lock no-error .
       find first ub.turnover-buyer no-lock WHERE
              ub.turnover-buyer.cli-code    = tt-turnover-buyer.cli-code AND
              ub.turnover-buyer.cli-type    = tt-turnover-buyer.cli-type AND
              ub.turnover-buyer.obj-code    = tt-turnover-buyer.obj-code and
              ub.turnover-buyer.obj-type    = tt-turnover-buyer.obj-type and
              ub.turnover-buyer.fact-order  = v-fact-order  no-error .
         if available ub.turnover-buyer then do:
            if l-shift-on then return error "На начало смены " + string(ub.turnover-buyer.shift-date) + "№ " + string(ub.turnover-buyer.shift-name) +  " уже есть оборот " .
            else return error "На начало дня  " + string(ub.turnover-buyer.fact-date) + " уже есть оборот " .
         end.
          create ub.turnover-buyer.
          assign
              ub.turnover-buyer.cli-code    = tt-turnover-buyer.cli-code
              ub.turnover-buyer.cli-type    = tt-turnover-buyer.cli-type
              ub.turnover-buyer.fact-date   = tt-turnover-buyer.fact-date
              ub.turnover-buyer.fact-order  = v-fact-order
              ub.turnover-buyer.obj-code    = tt-turnover-buyer.obj-code
              ub.turnover-buyer.obj-type    = tt-turnover-buyer.obj-type
              ub.turnover-buyer.shift-date  = tt-turnover-buyer.shift-date
              ub.turnover-buyer.shift-num   = tt-turnover-buyer.shift-num
              ub.turnover-buyer.shift-name  = if available ub.shift-obj then ub.shift-obj.shift-name else ""
              ub.turnover-buyer.type        = 1
              ub.turnover-buyer.qnty-check  = 0
              ub.turnover-buyer.qnty-check-itog  = 0
              ub.turnover-buyer.qnty-doc-itog  = 0
              ub.turnover-buyer.d-card    = ""
              ub.turnover-buyer.inkas-code = ""
          .
    end.
    else do:
      find first ub.turnover-buyer exclusive-lock where recid(ub.turnover-buyer) = p-recid no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
    end.
assign
  ub.turnover-buyer.sum-acc-base     = tt-turnover-buyer.sum-acc-base
  ub.turnover-buyer.sum-acc-rubl     = tt-turnover-buyer.sum-acc-rubl
  ub.turnover-buyer.sum-doc-base     = tt-turnover-buyer.sum-doc-base
  ub.turnover-buyer.sum-doc-rubl     = tt-turnover-buyer.sum-doc-rubl
  ub.turnover-buyer.sum-vat-acc-base = tt-turnover-buyer.sum-vat-acc-base
  ub.turnover-buyer.sum-vat-acc-rubl = tt-turnover-buyer.sum-vat-acc-rubl
  ub.turnover-buyer.sum-vat-doc-base = tt-turnover-buyer.sum-vat-doc-base
  ub.turnover-buyer.sum-vat-doc-rubl = tt-turnover-buyer.sum-vat-doc-rubl
  ub.turnover-buyer.sys-date         = today
  ub.turnover-buyer.sys-time         = time
  ub.turnover-buyer.sys-time-char    = string ( ub.turnover-buyer.sys-time,"hh:mm" )
  ub.turnover-buyer.des              = tt-turnover-buyer.des
  p-recid                            = recid ( ub.turnover-buyer )
.
END PROCEDURE.
