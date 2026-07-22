block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-ahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-ahsp.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по поставщикам за определенный период с выгрузкой в файл".
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-shift-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-shift-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-supp no-undo
  field cli-type as character
  field cli-code as integer
  index xpk is primary unique cli-type cli-code
  .
define temp-table temp-supp-gds no-undo
  field cli-type  as character
  field cli-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  .
define stream slog .
define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
define variable v-obj-type        like ub.gds-obj.obj-type no-undo .
define variable v-obj-code        like ub.gds-obj.obj-code no-undo .
define variable v-clear-archive   as logical   no-undo .
define variable v-new-start-date  as date      no-undo .
define variable v-new-detail-date as date      no-undo .
define variable v-file-name       as character no-undo .
define variable v-today           as date      no-undo .
define variable v-ok              as logical   no-undo .
do
on error undo, return error
:
  define variable v-user-select as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.
  define buffer restore-ahsp-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rsas':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по товарам"
    ,input true
    ,buffer restore-ahsp-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по поставщикам" skip
        "Невозможно произвести восстановление складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по поставщикам" .
  end.
  run gbl/lock-prc.p
    (input 'ahsp':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input true
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно произвести удаление складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по поставщикам" .
  end.
  define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
  run gbl/lockrngd.p
    (input  'grar':U
    ,input  'disable':U
    ,buffer buf_lock_gdsrenart_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования артикула товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
  run gbl/lockrngd.p
    (input  'grgc':U
    ,input  'disable':U
    ,buffer buf_lock_gdsrengc_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования кода товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-today
  )  .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-ahsp-calc          as logical   no-undo .
  define variable v-ahsp-del           as logical   no-undo .
  define variable v-ahsp-start-date    as date      no-undo .
  define variable v-ahsp-detail-date   as date      no-undo .
  define variable v-ahsp-recalc-date   as date      no-undo .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-calc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-start':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-recalc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-recalc-date = date(v-attr-value)
  .
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .
  assign
    v-month = month(v-ahsp-detail-date)
    v-year  = year(v-ahsp-detail-date)
  .
  assign
    v-month = v-month + 1
  .
  if v-month > 12
  then do:
    assign
      v-month = 1
      v-year  = v-year + 1
    .
  end.
  run gbl/d-inpmnt.w
    (input        "Введите месяц и год"
    ,input        ?
    ,input-output v-month
    ,input-output v-year
    ,output       v-ok
    ).
  if v-ok <> true
  then do:
    message
      "Дата очистки складского архива по поставщикам не задана" skip
      view-as alert-box information .
    undo, return error .
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .
  define variable v-num as integer   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Выберите способ удаления складского архива по поставщикам" + chr(10)
          + "Новая дата начала подробного складского архива по поставщикам " + string(v-new-detail-date, '99/99/9999':u) + chr(10)
          + "Сегодня " + string(v-today, '99/99/9999':u) + chr(10)
    ,input "|^"
    ,input "Удаление подробной информации" + '^confirm|':u
        + "Полная очистка складского архива по поставщикам" + '^confirm|':u
        + "Отказ"
    ,input "" + '|':u
        + "" + '|':u
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).
  case v-num :
    when 1
    then do:
      assign
        v-clear-archive = false
      .
    end.
    when 2
    then do:
      assign
        v-clear-archive = true
      .
    end.
    when 3
    then do:
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выборе способа очистки складского архива по поставщикам" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .
  if v-ahsp-calc = true
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-ahsp-del = true
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива поставщикам" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if (v-ahsp-start-date <> ?
     and v-ahsp-detail-date = ?)
  or (v-ahsp-start-date = ?
     and v-ahsp-detail-date <> ?)
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  v-ahsp-recalc-date <> ?
  and v-ahsp-detail-date <> ?
  and v-ahsp-recalc-date < v-ahsp-detail-date
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Дата перерасчета складского архива по поставщикам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "Дата перерасчета складского архива по поставщикам" string(v-ahsp-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" v-ahsp-detail-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-clear-archive = true
  then do:
    assign
      v-new-start-date = v-new-detail-date
    .
  end.
  else do:
    if v-ahsp-start-date <> ?
    then do:
      assign
        v-new-start-date = v-ahsp-start-date
      .
    end.
    else do:
      run find-ahsp-start-date in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-new-detail-date
        ,output v-new-start-date
        ) .
    end.
  end.
  run trg/bt_ahsp.p
    (input v-obj-type
    ,input v-obj-code
    ,input v-new-detail-date
    ,input true
    ,input v-cntxt-db-num
    ,input v-cntxt-userid
    ) .
  assign
    v-year  = year(v-new-detail-date)
    v-month = month(v-new-detail-date)
    v-day   = day(v-new-detail-date)
  .
  assign
    v-file-name = 'ahspdel':u
                + '_':u
                + (if v-obj-type = 'скл':U then 'stock':u else 'shop':u)
                + '_':u
                + string(v-obj-code)
                + '_':u
                + string(v-year, '9999':u)
                + string(v-month, '99':u)
                + string(v-day, '99':u)
                + '.txt'
  .
  assign
    v-ok = false
  .
  message
    "ВНИМАНИЕ!" skip
    "Последнее предупреждение перед удалением складского архива по поставщикам" skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по поставщикам" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по поставщикам" string(v-new-detail-date, '99/99/9999':u) skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "Удаленные данные будут сохранены в файле" v-file-name skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.
  define variable v-start-time     as integer   no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .
  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Удаление складского архива по поставщикам"
    .
  assign
    v-start-time = time
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .
  define variable v-fact-order           as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-archive-date         as date      no-undo .
  assign
    v-archive-date = v-new-detail-date - 1
  .
  run factord in this-procedure
    (input  v-archive-date
    ,input  1
    ,input  1
    ,input  ?
    ,input  0
    ,input  false
    ,output v-fact-order
    ,output v-shift-end-fact-order
    ,output v-day-end-fact-order
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run create-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-ahsp-start-date
    ,input v-ahsp-detail-date
    ,input v-new-start-date
    ,input v-new-detail-date
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании файла архивации" skip
      "Имя файла архивации" v-file-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run trg/ah-clicl.p
    (input v-obj-type
    ,input v-obj-code
    ,input 0
    ,input v-day-end-fact-order
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при cохранении складского архива по поставщикам"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-ahsp-start-date
    ,input v-ahsp-detail-date
    ,input v-new-start-date
    ,input v-new-detail-date
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при закрытии файла архивации" skip
      "Имя файла архивации" v-file-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-md5-signature as character no-undo .
  run gbl/md5.p
    (input  v-file-name
    ,output v-md5-signature
    ) .
  define variable v-create-chip-num as integer   no-undo .
  define variable v-action-type     as character no-undo .
  if v-clear-archive = true
  then do:
    assign
      v-action-type = 'delall-start':U
    .
  end.
  else do:
    assign
      v-action-type = 'deldet-start':U
    .
  end.
  run utl/arhiscr.p
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp':U
    ,input  v-action-type
    ,input  v-file-name
    ,input  v-md5-signature
    ,input  0
    ,input  ""
    ,input  ""
    ,input  v-new-detail-date
    ,output v-create-chip-num
    ) .
  define buffer lock_shift-obj for ub.shift-obj .
  run factord-lock-shift in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  v-archive-date
    ,buffer lock_shift-obj
    ) no-error .
  if error-status :error
  then do:
   define variable v-err as character no-undo .
   v-err = substitute("Ошибка при блокировке смены на объекте &2&3 дата &1" , v-archive-date, v-obj-type , v-obj-code  ) .
   run create-log-err in this-procedure (
        v-obj-type,
        v-obj-code,
        v-file-name ,
        v-err  ).
    undo, return error v-err .
  end.
  run ahrstutl-init in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-archive-date
    ) .
  run ahrstutl-store in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-archive-date
    ) .
  do transaction
  on error undo, return error return-value
  :
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-start':U
      ,input string(v-new-start-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты инициализации складского архива" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-detail':U
      ,input string(v-new-detail-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты инициализации складского архива" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-rest':U
      ,input 'true':u
      ) .
  end.
  find current calc-supp-arh-lock_batchprocess no-lock .
  if v-clear-archive = true
  then do:
    run ahrstutl-clear-ahsp in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-archive-date
      ) .
  end.
  else do:
    run utl/cmprahsp.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  define variable v-delete-attr-ahsp-del as logical   no-undo .
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input 'ahsp-rest':U
    ,output v-delete-attr-ahsp-del
    ) .
  if v-clear-archive = true
  then do:
    assign
      v-action-type = 'delall-stop':U
    .
  end.
  else do:
    assign
      v-action-type = 'deldet-stop':U
    .
  end.
  run utl/arhiscr.p
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp':U
    ,input  v-action-type
    ,input  ""
    ,input  ""
    ,input  0
    ,input  ""
    ,input  ""
    ,input  v-new-detail-date
    ,output v-create-chip-num
    ) .
  message
    "Удаление складского архива по поставщикам успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив по поставщикам на основании файла" skip
    "На объекте существует складской архив по поставщикам с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существуют подробный складской архив по поставщикам с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.
procedure create-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-ahsp-start-date  as date      no-undo .
  define input  parameter p-ahsp-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .
  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-ahsp-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-ahsp-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.
end procedure.
procedure close-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-ahsp-start-date  as date      no-undo .
  define input  parameter p-ahsp-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .
  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) append .
    export stream slog 'end-of-log':u .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-ahsp-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-ahsp-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.
end procedure.
procedure find-ahsp-start-date :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_stk-supp-tot for ub.stk-supp-tot .
    find first buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type  = p-obj-type
        and buf_stk-supp-tot.obj-code  = p-obj-code
      use-index fact-order
      no-error .
    if  available buf_stk-supp-tot
    and buf_stk-supp-tot.fact-date <= p-new-detail-date
    then do:
      assign
        p-new-start-date = buf_stk-supp-tot.fact-date
      .
    end.
    else do:
      assign
        p-new-start-date = p-new-detail-date
      .
    end.
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-action
    .
    display
      v-current-time
      v-current-action
      with frame a.
  end.
end procedure.
procedure show-count :
  define input  parameter p-count      as integer   no-undo .
  define input  parameter p-sub-action as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-count        = p-count
      v-sub-action   = p-sub-action
    .
    display
      v-current-time
      v-count
      v-sub-action
      with frame a.
  end.
end procedure.
procedure temp-supp-create :
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define buffer buf_temp-supp for temp-supp .
  do
  on error undo, return error return-value
  :
    find first buf_temp-supp
      where buf_temp-supp.cli-type  = p-cli-type
        and buf_temp-supp.cli-code  = p-cli-code
      no-error .
    if not available buf_temp-supp then do:
      create buf_temp-supp .
      assign
        buf_temp-supp.cli-type  = p-cli-type
        buf_temp-supp.cli-code  = p-cli-code
      .
    end.
  end.
end procedure.
procedure temp-supp-fill :
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-fact-order as decimal   no-undo .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order <= p-fact-order
    on error undo, return error
    :
      run temp-supp-create in this-procedure
        (input buf_stk-supp-tot.cli-type
        ,input buf_stk-supp-tot.cli-code
        ) .
    end.
  end.
end procedure.
procedure temp-supp-gds-create :
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                     like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                 like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.stk-supp-line.prod-code no-undo .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  do
  on error undo, return error return-value
  :
    find first buf_temp-supp-gds
      where buf_temp-supp-gds.cli-type  = p-cli-type
        and buf_temp-supp-gds.cli-code  = p-cli-code
        and buf_temp-supp-gds.artic     = p-artic
        and buf_temp-supp-gds.prod-type = p-prod-type
        and buf_temp-supp-gds.prod-code = p-prod-code
      no-error .
    if not available buf_temp-supp-gds then do:
      create buf_temp-supp-gds .
      assign
        buf_temp-supp-gds.cli-type  = p-cli-type
        buf_temp-supp-gds.cli-code  = p-cli-code
        buf_temp-supp-gds.artic     = p-artic
        buf_temp-supp-gds.prod-type = p-prod-type
        buf_temp-supp-gds.prod-code = p-prod-code
      .
    end.
  end.
end procedure.
procedure temp-supp-gds-fill :
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-fact-order as decimal   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order <= p-fact-order
    on error undo, return error
    :
      run temp-supp-gds-create in this-procedure
        (input buf_stk-supp-line.cli-type
        ,input buf_stk-supp-line.cli-code
        ,input buf_stk-supp-line.artic
        ,input buf_stk-supp-line.prod-type
        ,input buf_stk-supp-line.prod-code
        ) .
    end.
  end.
end procedure.
procedure ahrstutl-init :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_goods   for ub.goods .
  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  define variable v-shift-on             as logical   no-undo .
  define variable v-shift-date           as date      no-undo .
  define variable v-shift-num            as integer   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .
  define variable v-sum-type-list as character no-undo .
  do
  on error undo, return error
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    define variable v-ind as integer   no-undo .
    run show-action in this-procedure
      (input "Остаток по поставщикам. Анализ"
      ).
    run temp-supp-fill in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input v-day-end-fact-order
      ) .
    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    run show-action in this-procedure
      (input "Остаток по поставщикам. Считывание"
      ).
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_temp-supp
      on error undo, return error
      :
        run ahrstutl-init-supp-tot in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp.cli-type
          ,input buf_temp-supp.cli-code
          ,input entry(v-ind, v-sum-type-list)
          ,input p-fact-date
          ,input v-day-end-fact-order
          ,input v-shift-on
          ,input v-shift-date
          ,input v-shift-num
          ,input v-shift-end-fact-order
          ) .
      end.
    end.
    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Анализ"
      ).
    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    run temp-supp-gds-fill in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input v-day-end-fact-order
      ) .
    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Считывание"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_temp-supp-gds
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count mod 10 = 0 then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_temp-supp-gds.artic)
          ).
      end.
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-supp-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp-gds.cli-type
          ,input buf_temp-supp-gds.cli-code
          ,input buf_temp-supp-gds.artic
          ,input buf_temp-supp-gds.prod-type
          ,input buf_temp-supp-gds.prod-code
          ,input entry(v-ind, v-sum-type-list)
          ,input p-fact-date
          ,input v-day-end-fact-order
          ,input v-shift-on
          ,input v-shift-date
          ,input v-shift-num
          ,input v-shift-end-fact-order
          ) .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-supp-tot :
  define input  parameter p-obj-type                      as character no-undo .
  define input  parameter p-obj-code                      as integer   no-undo .
  define input  parameter p-cli-type                      as character no-undo .
  define input  parameter p-cli-code                      as integer   no-undo .
  define input  parameter p-root-sum-type                 as character no-undo .
  define input  parameter p-fact-date                     as date      no-undo .
  define input  parameter p-stk-supp-tot-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                      as logical   no-undo .
  define input  parameter p-shift-date                    as date      no-undo .
  define input  parameter p-shift-num                     as integer   no-undo .
  define input  parameter p-shift-stk-supp-tot-fact-order as decimal   no-undo .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_shift-stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define variable v-prev-stk-supp-tot-fact-order as decimal   no-undo .
  define variable v-prev-shift-stk-supp-tot-f-o  as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.cli-type   = p-cli-type
        and buf_stk-supp-tot.cli-code   = p-cli-code
        and buf_stk-supp-tot.sum-type   = p-root-sum-type
        and buf_stk-supp-tot.cat-id     = '##,##':U
        and buf_stk-supp-tot.fact-order <= p-stk-supp-tot-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-tot
    and buf_stk-supp-tot.fact-order <> p-stk-supp-tot-fact-order
    then do:
      assign
        v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
      .
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = p-obj-type
          and buf_stk-supp-tot.obj-code   = p-obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
          and buf_stk-supp-tot.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = p-stk-supp-tot-fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot then do:
          create buf_temp-stk-supp-tot .
          assign
                                    buf_temp-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
            buf_temp-stk-supp-tot.fact-order = p-stk-supp-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
        end.
        assign
                                                                      buf_temp-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
        .
      end.
    end.
    if p-shift-on then do:
      find last buf_shift-stk-supp-tot no-lock
        where buf_shift-stk-supp-tot.obj-type   = p-obj-type
          and buf_shift-stk-supp-tot.obj-code   = p-obj-code
          and buf_shift-stk-supp-tot.cli-type   = p-cli-type
          and buf_shift-stk-supp-tot.cli-code   = p-cli-code
          and buf_shift-stk-supp-tot.sum-type   = p-root-sum-type
          and buf_shift-stk-supp-tot.cat-id     = '##,##':U
          and buf_shift-stk-supp-tot.fact-order <= p-shift-stk-supp-tot-fact-order
          and buf_shift-stk-supp-tot.shift-date <> ?
        use-index category
        no-error .
      if available buf_shift-stk-supp-tot
      and buf_shift-stk-supp-tot.fact-order <> p-shift-stk-supp-tot-fact-order
      then do:
        assign
          v-prev-shift-stk-supp-tot-f-o = buf_shift-stk-supp-tot.fact-order
        .
        for each buf_shift-stk-supp-tot no-lock
          where buf_shift-stk-supp-tot.obj-type   = p-obj-type
            and buf_shift-stk-supp-tot.obj-code   = p-obj-code
            and buf_shift-stk-supp-tot.cli-type   = p-cli-type
            and buf_shift-stk-supp-tot.cli-code   = p-cli-code
            and buf_shift-stk-supp-tot.fact-order = v-prev-shift-stk-supp-tot-f-o
            and buf_shift-stk-supp-tot.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_shift-stk-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_shift-stk-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_shift-stk-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_shift-stk-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = p-shift-stk-supp-tot-fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_shift-stk-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot then do:
            create buf_temp-shift-stk-supp-tot .
            assign
                                          buf_temp-shift-stk-supp-tot.obj-type     = buf_shift-stk-supp-tot.obj-type     buf_temp-shift-stk-supp-tot.obj-code     = buf_shift-stk-supp-tot.obj-code     buf_temp-shift-stk-supp-tot.cli-type     = buf_shift-stk-supp-tot.cli-type     buf_temp-shift-stk-supp-tot.cli-code     = buf_shift-stk-supp-tot.cli-code     buf_temp-shift-stk-supp-tot.fact-order   = buf_shift-stk-supp-tot.fact-order   buf_temp-shift-stk-supp-tot.sum-type     = buf_shift-stk-supp-tot.sum-type     buf_temp-shift-stk-supp-tot.cat-id       = buf_shift-stk-supp-tot.cat-id       buf_temp-shift-stk-supp-tot.fact-date    = buf_shift-stk-supp-tot.fact-date    buf_temp-shift-stk-supp-tot.shift-num    = buf_shift-stk-supp-tot.shift-num    buf_temp-shift-stk-supp-tot.shift-date   = buf_shift-stk-supp-tot.shift-date
              buf_temp-shift-stk-supp-tot.fact-order = p-shift-stk-supp-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
            .
          end.
          assign
                                                                                    buf_temp-shift-stk-supp-tot.fact-qnty      = buf_shift-stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.sum-base       = buf_shift-stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.sum-rubl       = buf_shift-stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.vat-base       = buf_shift-stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.vat-rubl       = buf_shift-stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.slt-base       = buf_shift-stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.slt-rubl       = buf_shift-stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.road-tax-base  = buf_shift-stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.road-tax-rubl  = buf_shift-stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.excise-base    = buf_shift-stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.excise-rubl    = buf_shift-stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.transport-base = buf_shift-stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.transport-rubl = buf_shift-stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.other-base     = buf_shift-stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.other-rubl     = buf_shift-stk-supp-tot.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-supp-line :
  define input  parameter p-obj-type                  like ub.stk-supp-line.obj-type  no-undo .
  define input  parameter p-obj-code                  like ub.stk-supp-line.obj-code  no-undo .
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                     like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                 like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.stk-supp-line.prod-code no-undo .
  define input  parameter p-root-sum-type             as character no-undo .
  define input  parameter p-fact-date                 as date      no-undo .
  define input  parameter p-stk-supp-line-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                  as logical   no-undo .
  define input  parameter p-shift-date                as date      no-undo .
  define input  parameter p-shift-num                 as integer   no-undo .
  define input  parameter p-shift-stk-supp-line-fact-order as decimal   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_shift-stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define variable v-prev-stk-supp-line-fact-order as decimal   no-undo .
  define variable v-prev-shift-stk-supp-line-f-o  as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.cli-type   = p-cli-type
        and buf_stk-supp-line.cli-code   = p-cli-code
        and buf_stk-supp-line.artic      = p-artic
        and buf_stk-supp-line.prod-type  = p-prod-type
        and buf_stk-supp-line.prod-code  = p-prod-code
        and buf_stk-supp-line.sum-type   = p-root-sum-type
        and buf_stk-supp-line.fact-order <= p-stk-supp-line-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-line
    and buf_stk-supp-line.fact-order <> p-stk-supp-line-fact-order
    then do:
      assign
        v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
      .
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = p-obj-type
          and buf_stk-supp-line.obj-code   = p-obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.fact-order = v-prev-stk-supp-line-fact-order
          and buf_stk-supp-line.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = p-stk-supp-line-fact-order
            and buf_temp-stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
                                    buf_temp-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
            buf_temp-stk-supp-line.fact-order = p-stk-supp-line-fact-order
            buf_temp-stk-supp-line.fact-date  = p-fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
        end.
        assign
                                                                      buf_temp-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
        .
      end.
    end.
    if p-shift-on
    then do:
      find last buf_shift-stk-supp-line no-lock
        where buf_shift-stk-supp-line.obj-type   = p-obj-type
          and buf_shift-stk-supp-line.obj-code   = p-obj-code
          and buf_shift-stk-supp-line.cli-type   = p-cli-type
          and buf_shift-stk-supp-line.cli-code   = p-cli-code
          and buf_shift-stk-supp-line.artic      = p-artic
          and buf_shift-stk-supp-line.prod-type  = p-prod-type
          and buf_shift-stk-supp-line.prod-code  = p-prod-code
          and buf_shift-stk-supp-line.sum-type   = p-root-sum-type
          and buf_shift-stk-supp-line.fact-order <= p-shift-stk-supp-line-fact-order
          and buf_shift-stk-supp-line.shift-date <> ?
        use-index category
        no-error .
      if available buf_shift-stk-supp-line
      and buf_shift-stk-supp-line.fact-order <> p-shift-stk-supp-line-fact-order
      then do:
        assign
          v-prev-shift-stk-supp-line-f-o = buf_shift-stk-supp-line.fact-order
        .
        for each buf_shift-stk-supp-line no-lock
          where buf_shift-stk-supp-line.obj-type   = p-obj-type
            and buf_shift-stk-supp-line.obj-code   = p-obj-code
            and buf_shift-stk-supp-line.cli-type   = p-cli-type
            and buf_shift-stk-supp-line.cli-code   = p-cli-code
            and buf_shift-stk-supp-line.artic      = p-artic
            and buf_shift-stk-supp-line.prod-type  = p-prod-type
            and buf_shift-stk-supp-line.prod-code  = p-prod-code
            and buf_shift-stk-supp-line.fact-order = v-prev-shift-stk-supp-line-f-o
            and buf_shift-stk-supp-line.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_shift-stk-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_shift-stk-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_shift-stk-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_shift-stk-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_shift-stk-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_shift-stk-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_shift-stk-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = p-shift-stk-supp-line-fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_shift-stk-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
                                          buf_temp-shift-stk-supp-line.obj-type     = buf_shift-stk-supp-line.obj-type     buf_temp-shift-stk-supp-line.obj-code     = buf_shift-stk-supp-line.obj-code     buf_temp-shift-stk-supp-line.cli-type     = buf_shift-stk-supp-line.cli-type     buf_temp-shift-stk-supp-line.cli-code     = buf_shift-stk-supp-line.cli-code     buf_temp-shift-stk-supp-line.artic        = buf_shift-stk-supp-line.artic        buf_temp-shift-stk-supp-line.prod-type    = buf_shift-stk-supp-line.prod-type    buf_temp-shift-stk-supp-line.prod-code    = buf_shift-stk-supp-line.prod-code    buf_temp-shift-stk-supp-line.fact-order   = buf_shift-stk-supp-line.fact-order   buf_temp-shift-stk-supp-line.sum-type     = buf_shift-stk-supp-line.sum-type     buf_temp-shift-stk-supp-line.cat-id       = buf_shift-stk-supp-line.cat-id       buf_temp-shift-stk-supp-line.fact-date    = buf_shift-stk-supp-line.fact-date    buf_temp-shift-stk-supp-line.shift-num    = buf_shift-stk-supp-line.shift-num    buf_temp-shift-stk-supp-line.shift-date   = buf_shift-stk-supp-line.shift-date
              buf_temp-shift-stk-supp-line.fact-order = p-shift-stk-supp-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-line.shift-date = p-shift-date
              buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
            .
          end.
          assign
                                                                                    buf_temp-shift-stk-supp-line.fact-qnty      = buf_shift-stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.sum-base       = buf_shift-stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.sum-rubl       = buf_shift-stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.vat-base       = buf_shift-stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.vat-rubl       = buf_shift-stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.slt-base       = buf_shift-stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.slt-rubl       = buf_shift-stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.road-tax-base  = buf_shift-stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.road-tax-rubl  = buf_shift-stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.excise-base    = buf_shift-stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.excise-rubl    = buf_shift-stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.transport-base = buf_shift-stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.transport-rubl = buf_shift-stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.other-base     = buf_shift-stk-supp-line.other-base           buf_temp-shift-stk-supp-line.other-rubl     = buf_shift-stk-supp-line.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-store :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define variable v-shift-on             as logical   no-undo .
  define variable v-shift-date           as date      no-undo .
  define variable v-shift-num            as integer   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    for each buf_temp-stk-supp-tot
    on error undo, return error
    :
      create buf_stk-supp-tot .
      assign
                        buf_stk-supp-tot.obj-type     = buf_temp-stk-supp-tot.obj-type     buf_stk-supp-tot.obj-code     = buf_temp-stk-supp-tot.obj-code     buf_stk-supp-tot.cli-type     = buf_temp-stk-supp-tot.cli-type     buf_stk-supp-tot.cli-code     = buf_temp-stk-supp-tot.cli-code     buf_stk-supp-tot.fact-order   = buf_temp-stk-supp-tot.fact-order   buf_stk-supp-tot.sum-type     = buf_temp-stk-supp-tot.sum-type     buf_stk-supp-tot.cat-id       = buf_temp-stk-supp-tot.cat-id       buf_stk-supp-tot.fact-date    = buf_temp-stk-supp-tot.fact-date    buf_stk-supp-tot.shift-num    = buf_temp-stk-supp-tot.shift-num    buf_stk-supp-tot.shift-date   = buf_temp-stk-supp-tot.shift-date
                                                        buf_stk-supp-tot.fact-qnty      = buf_temp-stk-supp-tot.fact-qnty            buf_stk-supp-tot.sum-base       = buf_temp-stk-supp-tot.sum-base             buf_stk-supp-tot.sum-rubl       = buf_temp-stk-supp-tot.sum-rubl             buf_stk-supp-tot.vat-base       = buf_temp-stk-supp-tot.vat-base             buf_stk-supp-tot.vat-rubl       = buf_temp-stk-supp-tot.vat-rubl             buf_stk-supp-tot.slt-base       = buf_temp-stk-supp-tot.slt-base             buf_stk-supp-tot.slt-rubl       = buf_temp-stk-supp-tot.slt-rubl             buf_stk-supp-tot.road-tax-base  = buf_temp-stk-supp-tot.road-tax-base        buf_stk-supp-tot.road-tax-rubl  = buf_temp-stk-supp-tot.road-tax-rubl        buf_stk-supp-tot.excise-base    = buf_temp-stk-supp-tot.excise-base          buf_stk-supp-tot.excise-rubl    = buf_temp-stk-supp-tot.excise-rubl          buf_stk-supp-tot.transport-base = buf_temp-stk-supp-tot.transport-base       buf_stk-supp-tot.transport-rubl = buf_temp-stk-supp-tot.transport-rubl       buf_stk-supp-tot.other-base     = buf_temp-stk-supp-tot.other-base           buf_stk-supp-tot.other-rubl     = buf_temp-stk-supp-tot.other-rubl
        buf_stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
        buf_stk-supp-tot.fact-date  = buf_temp-stk-supp-tot.fact-date
        buf_stk-supp-tot.shift-num  = buf_temp-stk-supp-tot.shift-num
        buf_stk-supp-tot.shift-date = buf_temp-stk-supp-tot.shift-date
      .
    end.
    if v-shift-on = true then do:
      for each buf_temp-shift-stk-supp-tot
      on error undo, return error
      :
        create buf_stk-supp-tot .
        assign
                              buf_stk-supp-tot.obj-type     = buf_temp-shift-stk-supp-tot.obj-type     buf_stk-supp-tot.obj-code     = buf_temp-shift-stk-supp-tot.obj-code     buf_stk-supp-tot.cli-type     = buf_temp-shift-stk-supp-tot.cli-type     buf_stk-supp-tot.cli-code     = buf_temp-shift-stk-supp-tot.cli-code     buf_stk-supp-tot.fact-order   = buf_temp-shift-stk-supp-tot.fact-order   buf_stk-supp-tot.sum-type     = buf_temp-shift-stk-supp-tot.sum-type     buf_stk-supp-tot.cat-id       = buf_temp-shift-stk-supp-tot.cat-id       buf_stk-supp-tot.fact-date    = buf_temp-shift-stk-supp-tot.fact-date    buf_stk-supp-tot.shift-num    = buf_temp-shift-stk-supp-tot.shift-num    buf_stk-supp-tot.shift-date   = buf_temp-shift-stk-supp-tot.shift-date
                                                                      buf_stk-supp-tot.fact-qnty      = buf_temp-shift-stk-supp-tot.fact-qnty            buf_stk-supp-tot.sum-base       = buf_temp-shift-stk-supp-tot.sum-base             buf_stk-supp-tot.sum-rubl       = buf_temp-shift-stk-supp-tot.sum-rubl             buf_stk-supp-tot.vat-base       = buf_temp-shift-stk-supp-tot.vat-base             buf_stk-supp-tot.vat-rubl       = buf_temp-shift-stk-supp-tot.vat-rubl             buf_stk-supp-tot.slt-base       = buf_temp-shift-stk-supp-tot.slt-base             buf_stk-supp-tot.slt-rubl       = buf_temp-shift-stk-supp-tot.slt-rubl             buf_stk-supp-tot.road-tax-base  = buf_temp-shift-stk-supp-tot.road-tax-base        buf_stk-supp-tot.road-tax-rubl  = buf_temp-shift-stk-supp-tot.road-tax-rubl        buf_stk-supp-tot.excise-base    = buf_temp-shift-stk-supp-tot.excise-base          buf_stk-supp-tot.excise-rubl    = buf_temp-shift-stk-supp-tot.excise-rubl          buf_stk-supp-tot.transport-base = buf_temp-shift-stk-supp-tot.transport-base       buf_stk-supp-tot.transport-rubl = buf_temp-shift-stk-supp-tot.transport-rubl       buf_stk-supp-tot.other-base     = buf_temp-shift-stk-supp-tot.other-base           buf_stk-supp-tot.other-rubl     = buf_temp-shift-stk-supp-tot.other-rubl
          buf_stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
          buf_stk-supp-tot.fact-date  = buf_temp-shift-stk-supp-tot.fact-date
          buf_stk-supp-tot.shift-num  = buf_temp-shift-stk-supp-tot.shift-num
          buf_stk-supp-tot.shift-date = buf_temp-shift-stk-supp-tot.shift-date
        .
      end.
    end.
    for each buf_temp-stk-supp-line
    on error undo, return error
    :
      create buf_stk-supp-line .
      assign
                        buf_stk-supp-line.obj-type     = buf_temp-stk-supp-line.obj-type     buf_stk-supp-line.obj-code     = buf_temp-stk-supp-line.obj-code     buf_stk-supp-line.cli-type     = buf_temp-stk-supp-line.cli-type     buf_stk-supp-line.cli-code     = buf_temp-stk-supp-line.cli-code     buf_stk-supp-line.artic        = buf_temp-stk-supp-line.artic        buf_stk-supp-line.prod-type    = buf_temp-stk-supp-line.prod-type    buf_stk-supp-line.prod-code    = buf_temp-stk-supp-line.prod-code    buf_stk-supp-line.fact-order   = buf_temp-stk-supp-line.fact-order   buf_stk-supp-line.sum-type     = buf_temp-stk-supp-line.sum-type     buf_stk-supp-line.cat-id       = buf_temp-stk-supp-line.cat-id       buf_stk-supp-line.fact-date    = buf_temp-stk-supp-line.fact-date    buf_stk-supp-line.shift-num    = buf_temp-stk-supp-line.shift-num    buf_stk-supp-line.shift-date   = buf_temp-stk-supp-line.shift-date
                                                        buf_stk-supp-line.fact-qnty      = buf_temp-stk-supp-line.fact-qnty            buf_stk-supp-line.sum-base       = buf_temp-stk-supp-line.sum-base             buf_stk-supp-line.sum-rubl       = buf_temp-stk-supp-line.sum-rubl             buf_stk-supp-line.vat-base       = buf_temp-stk-supp-line.vat-base             buf_stk-supp-line.vat-rubl       = buf_temp-stk-supp-line.vat-rubl             buf_stk-supp-line.slt-base       = buf_temp-stk-supp-line.slt-base             buf_stk-supp-line.slt-rubl       = buf_temp-stk-supp-line.slt-rubl             buf_stk-supp-line.road-tax-base  = buf_temp-stk-supp-line.road-tax-base        buf_stk-supp-line.road-tax-rubl  = buf_temp-stk-supp-line.road-tax-rubl        buf_stk-supp-line.excise-base    = buf_temp-stk-supp-line.excise-base          buf_stk-supp-line.excise-rubl    = buf_temp-stk-supp-line.excise-rubl          buf_stk-supp-line.transport-base = buf_temp-stk-supp-line.transport-base       buf_stk-supp-line.transport-rubl = buf_temp-stk-supp-line.transport-rubl       buf_stk-supp-line.other-base     = buf_temp-stk-supp-line.other-base           buf_stk-supp-line.other-rubl     = buf_temp-stk-supp-line.other-rubl
        buf_stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
        buf_stk-supp-line.fact-date  = buf_temp-stk-supp-line.fact-date
        buf_stk-supp-line.shift-num  = buf_temp-stk-supp-line.shift-num
        buf_stk-supp-line.shift-date = buf_temp-stk-supp-line.shift-date
      .
    end.
    if v-shift-on = true then do:
      for each buf_temp-shift-stk-supp-line
      on error undo, return error
      :
        create buf_stk-supp-line .
        assign
                              buf_stk-supp-line.obj-type     = buf_temp-shift-stk-supp-line.obj-type     buf_stk-supp-line.obj-code     = buf_temp-shift-stk-supp-line.obj-code     buf_stk-supp-line.cli-type     = buf_temp-shift-stk-supp-line.cli-type     buf_stk-supp-line.cli-code     = buf_temp-shift-stk-supp-line.cli-code     buf_stk-supp-line.artic        = buf_temp-shift-stk-supp-line.artic        buf_stk-supp-line.prod-type    = buf_temp-shift-stk-supp-line.prod-type    buf_stk-supp-line.prod-code    = buf_temp-shift-stk-supp-line.prod-code    buf_stk-supp-line.fact-order   = buf_temp-shift-stk-supp-line.fact-order   buf_stk-supp-line.sum-type     = buf_temp-shift-stk-supp-line.sum-type     buf_stk-supp-line.cat-id       = buf_temp-shift-stk-supp-line.cat-id       buf_stk-supp-line.fact-date    = buf_temp-shift-stk-supp-line.fact-date    buf_stk-supp-line.shift-num    = buf_temp-shift-stk-supp-line.shift-num    buf_stk-supp-line.shift-date   = buf_temp-shift-stk-supp-line.shift-date
                                                                      buf_stk-supp-line.fact-qnty      = buf_temp-shift-stk-supp-line.fact-qnty            buf_stk-supp-line.sum-base       = buf_temp-shift-stk-supp-line.sum-base             buf_stk-supp-line.sum-rubl       = buf_temp-shift-stk-supp-line.sum-rubl             buf_stk-supp-line.vat-base       = buf_temp-shift-stk-supp-line.vat-base             buf_stk-supp-line.vat-rubl       = buf_temp-shift-stk-supp-line.vat-rubl             buf_stk-supp-line.slt-base       = buf_temp-shift-stk-supp-line.slt-base             buf_stk-supp-line.slt-rubl       = buf_temp-shift-stk-supp-line.slt-rubl             buf_stk-supp-line.road-tax-base  = buf_temp-shift-stk-supp-line.road-tax-base        buf_stk-supp-line.road-tax-rubl  = buf_temp-shift-stk-supp-line.road-tax-rubl        buf_stk-supp-line.excise-base    = buf_temp-shift-stk-supp-line.excise-base          buf_stk-supp-line.excise-rubl    = buf_temp-shift-stk-supp-line.excise-rubl          buf_stk-supp-line.transport-base = buf_temp-shift-stk-supp-line.transport-base       buf_stk-supp-line.transport-rubl = buf_temp-shift-stk-supp-line.transport-rubl       buf_stk-supp-line.other-base     = buf_temp-shift-stk-supp-line.other-base           buf_stk-supp-line.other-rubl     = buf_temp-shift-stk-supp-line.other-rubl
          buf_stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
          buf_stk-supp-line.fact-date  = buf_temp-shift-stk-supp-line.fact-date
          buf_stk-supp-line.shift-num  = buf_temp-shift-stk-supp-line.shift-num
          buf_stk-supp-line.shift-date = buf_temp-shift-stk-supp-line.shift-date
        .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-clear-ahsp :
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .
  define buffer buf_ot-supp-tot   for ub.ot-supp-tot .
  define buffer buf_ot-supp-line  for ub.ot-supp-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-ind as integer no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    assign
      v-day-end-fact-order   = v-day-end-fact-order   - 0.0000000001
      v-shift-end-fact-order = v-shift-end-fact-order - 0.0000000001
    .
    run show-action in this-procedure
      (input "Удаление оборота по документам"
      ).
    assign
      v-ind = 0
    .
    for each buf_ot-supp-tot
      where buf_ot-supp-tot.obj-type   = p-obj-type
        and buf_ot-supp-tot.obj-code   = p-obj-code
        and buf_ot-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-tot.doc-code)
          ).
      end.
      delete buf_ot-supp-tot .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .
    for each buf_ot-supp-line
      where buf_ot-supp-line.obj-type   = p-obj-type
        and buf_ot-supp-line.obj-code   = p-obj-code
        and buf_ot-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-line.doc-code)
                  + " Артикул " + string(buf_ot-supp-line.artic)
          ).
      end.
      delete buf_ot-supp-line .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-supp-tot
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_stk-supp-tot.fact-date, '99/99/9999':U )
          ).
      end.
      if buf_stk-supp-tot.shift-date = ?
      or (buf_stk-supp-tot.shift-date <> ?
          and
          buf_stk-supp-tot.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-tot .
      end.
    end.
    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-supp-line
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Артикул " + string(buf_stk-supp-line.artic)
          ).
      end.
      if buf_stk-supp-line.shift-date = ?
      or (buf_stk-supp-line.shift-date <> ?
          and
          buf_stk-supp-line.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-line .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-supp-tot-sum-type-list :
  define output parameter p-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .
    assign
      v-num-entries-TDEDT_List = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
    .
    assign
      p-sum-type-list = 'cost':U
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'sadt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'csdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
  end.
end procedure.
procedure ahrstutl-supp-line-sum-type-list :
  define output parameter p-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .
    assign
      v-num-entries-TDEDT_List = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
    .
    assign
      p-sum-type-list = 'cost':U
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'sadt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'csdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
  end.
end procedure.
procedure create-log-err :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-file-name as character no-undo .
  define input  parameter p-err       as character no-undo .
  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog  string(p-err) .
    output stream slog close .
  end.
end procedure.
