block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-arh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-arh.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по товарам за определенный период с выгрузкой в файл".
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
define stream slog .
define buffer calc-arh-lock_batchprocess for ub.batchprocess .
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
  define buffer restore-arh-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rsar':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского складского архива по товарам"
    ,input true
    ,buffer restore-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по товарам" skip
        "Невозможно произвести восстановление складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по товарам" .
  end.
  run gbl/lock-prc.p
    (input 'btpr':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архивов по товарам"
    ,input true
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести удаление складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по товарам" .
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
  define variable v-arh-calc          as logical   no-undo .
  define variable v-arh-del           as logical   no-undo .
  define variable v-arh-start-date    as date      no-undo .
  define variable v-arh-detail-date   as date      no-undo .
  define variable v-arh-recalc-date   as date      no-undo .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'arh-calc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'arh-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'arh-start':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'arh-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'arh-recalc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-recalc-date = date(v-attr-value)
  .
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .
  assign
    v-month = month(v-arh-detail-date)
    v-year  = year(v-arh-detail-date)
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
      "Дата очистки складского архива по товарам не задана" skip
      view-as alert-box information .
    undo, return error .
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .
  define variable v-num as integer   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Выберите способ удаления складского архива по товарам" + chr(10)
          + "Новая дата начала подробного складского архива по товарам " + string(v-new-detail-date, '99/99/9999':u) + chr(10)
          + "Сегодня " + string(v-today, '99/99/9999':u) + chr(10)
    ,input "|^"
    ,input "Удаление подробной информации" + '^confirm|':u
        + "Полная очистка складского архива по товарам" + '^confirm|':u
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
        "Ошибка при выборе способа очистки складского архива по товарам" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .
  if v-arh-calc = true
  then do:
    message
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-arh-del = true
  then do:
    message
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if (v-arh-start-date <> ?
     and v-arh-detail-date = ?)
  or (v-arh-start-date = ?
     and v-arh-detail-date <> ?)
  then do:
    message
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Противоречивая информация в датах инициализации складского архива по товарам" skip
      "Дата начала складского архива по товарам" string(v-arh-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  v-arh-recalc-date <> ?
  and v-arh-detail-date <> ?
  and v-arh-recalc-date < v-arh-detail-date
  then do:
    message
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Дата перерасчета складского архива по товарам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива по товарам" skip
      "Дата перерасчета складского архива по товарам" string(v-arh-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по товарам" v-arh-detail-date skip
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
    if v-arh-start-date <> ?
    then do:
      assign
        v-new-start-date = v-arh-start-date
      .
    end.
    else do:
      run find-arh-start-date in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-new-detail-date
        ,output v-new-start-date
        ) .
    end.
  end.
  run trg/bt_arh.p
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
    v-file-name = 'arhdel':u
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
    "Последнее предупреждение перед удалением складского архива по товарам" skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по товарам" string(v-arh-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по товарам" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по товарам" string(v-new-detail-date, '99/99/9999':u) skip
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
  define frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Удаление складского архива по товарам"
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
    ,input v-arh-start-date
    ,input v-arh-detail-date
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
  run trg/arhclr.p
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
      "Ошибка при cохранении складского архива по товарам"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-arh-start-date
    ,input v-arh-detail-date
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
    ,input  'arh':U
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
   run create-log-err in this-procedure
      ( v-obj-type ,
        v-obj-code ,
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
      ,input 'arh-start':U
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
      ,input 'arh-detail':U
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
      ,input 'arh-rest':U
      ,input 'true':u
      ) .
  end.
  find current calc-arh-lock_batchprocess no-lock .
  if v-clear-archive = true
  then do:
    run ahrstutl-clear-arh in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-archive-date
      ) .
  end.
  else do:
    run utl/cmprarh.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  define variable v-delete-attr-arh-del as logical   no-undo .
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input 'arh-rest':U
    ,output v-delete-attr-arh-del
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
    ,input  'arh':U
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
    "Удаление складского архива по товарам успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив по товарам на основании файла" skip
    "На объекте существует складской архив по товарам с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существует подробный складской архив по товарам с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.
procedure create-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-arh-start-date  as date      no-undo .
  define input  parameter p-arh-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-arh-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-arh-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.
end procedure.
procedure close-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-arh-start-date  as date      no-undo .
  define input  parameter p-arh-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-arh-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-arh-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.
end procedure.
procedure find-arh-start-date :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_stk-tot for ub.stk-tot .
    find first buf_stk-tot no-lock
      where buf_stk-tot.obj-type  = p-obj-type
        and buf_stk-tot.obj-code  = p-obj-code
        and buf_stk-tot.sum-type  = 'crsa':U
        and buf_stk-tot.cat-id    = '##,##':U
        and buf_stk-tot.fact-date <> ?
      use-index category
      no-error .
    if  available buf_stk-tot
    and buf_stk-tot.fact-date <= p-new-detail-date
    then do:
      assign
        p-new-start-date = buf_stk-tot.fact-date
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
define temp-table temp-stk-tot no-undo like ub.stk-tot   field new-fact-qnty      like ub.stk-tot.fact-qnty            field new-sum-base       like ub.stk-tot.sum-base             field new-sum-rubl       like ub.stk-tot.sum-rubl             field new-vat-base       like ub.stk-tot.vat-base             field new-vat-rubl       like ub.stk-tot.vat-rubl             field new-slt-base       like ub.stk-tot.slt-base             field new-slt-rubl       like ub.stk-tot.slt-rubl             field new-road-tax-base  like ub.stk-tot.road-tax-base        field new-road-tax-rubl  like ub.stk-tot.road-tax-rubl        field new-excise-base    like ub.stk-tot.excise-base          field new-excise-rubl    like ub.stk-tot.excise-rubl          field new-transport-base like ub.stk-tot.transport-base       field new-transport-rubl like ub.stk-tot.transport-rubl       field new-other-base     like ub.stk-tot.other-base           field new-other-rubl     like ub.stk-tot.other-rubl         index pi is primary unique  obj-type obj-code fact-order sum-type cat-id   index category          obj-type obj-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
define temp-table temp-stk-line no-undo like ub.stk-line   field new-fact-qnty      like ub.stk-line.fact-qnty            field new-sum-base       like ub.stk-line.sum-base             field new-sum-rubl       like ub.stk-line.sum-rubl             field new-vat-base       like ub.stk-line.vat-base             field new-vat-rubl       like ub.stk-line.vat-rubl             field new-slt-base       like ub.stk-line.slt-base             field new-slt-rubl       like ub.stk-line.slt-rubl             field new-road-tax-base  like ub.stk-line.road-tax-base        field new-road-tax-rubl  like ub.stk-line.road-tax-rubl        field new-excise-base    like ub.stk-line.excise-base          field new-excise-rubl    like ub.stk-line.excise-rubl          field new-transport-base like ub.stk-line.transport-base       field new-transport-rubl like ub.stk-line.transport-rubl       field new-other-base     like ub.stk-line.other-base           field new-other-rubl     like ub.stk-line.other-rubl         index pi is primary unique  obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id   index category          obj-type obj-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
define temp-table temp-shift-stk-tot no-undo like ub.stk-tot   field new-fact-qnty      like ub.stk-tot.fact-qnty            field new-sum-base       like ub.stk-tot.sum-base             field new-sum-rubl       like ub.stk-tot.sum-rubl             field new-vat-base       like ub.stk-tot.vat-base             field new-vat-rubl       like ub.stk-tot.vat-rubl             field new-slt-base       like ub.stk-tot.slt-base             field new-slt-rubl       like ub.stk-tot.slt-rubl             field new-road-tax-base  like ub.stk-tot.road-tax-base        field new-road-tax-rubl  like ub.stk-tot.road-tax-rubl        field new-excise-base    like ub.stk-tot.excise-base          field new-excise-rubl    like ub.stk-tot.excise-rubl          field new-transport-base like ub.stk-tot.transport-base       field new-transport-rubl like ub.stk-tot.transport-rubl       field new-other-base     like ub.stk-tot.other-base           field new-other-rubl     like ub.stk-tot.other-rubl         index pi is primary unique  obj-type obj-code fact-order sum-type cat-id   index category          obj-type obj-code sum-type cat-id fact-order   index sum-type sum-type cat-id .
define temp-table temp-shift-stk-line no-undo like ub.stk-line   field new-fact-qnty      like ub.stk-line.fact-qnty            field new-sum-base       like ub.stk-line.sum-base             field new-sum-rubl       like ub.stk-line.sum-rubl             field new-vat-base       like ub.stk-line.vat-base             field new-vat-rubl       like ub.stk-line.vat-rubl             field new-slt-base       like ub.stk-line.slt-base             field new-slt-rubl       like ub.stk-line.slt-rubl             field new-road-tax-base  like ub.stk-line.road-tax-base        field new-road-tax-rubl  like ub.stk-line.road-tax-rubl        field new-excise-base    like ub.stk-line.excise-base          field new-excise-rubl    like ub.stk-line.excise-rubl          field new-transport-base like ub.stk-line.transport-base       field new-transport-rubl like ub.stk-line.transport-rubl       field new-other-base     like ub.stk-line.other-base           field new-other-rubl     like ub.stk-line.other-rubl         index pi is primary unique  obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id   index category          obj-type obj-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
procedure ahrstutl-init :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_goods   for ub.goods .
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
      (input "Остаток по объекту"
      ).
    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-init-tot in this-procedure
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-ind, v-sum-type-list)
        ,input p-fact-date
        ,input v-day-end-fact-order
        ,input v-shift-on
        ,input v-shift-date
        ,input v-shift-num
        ,input v-shift-end-fact-order
        ) .
    end.
    run show-action in this-procedure
      (input "Остаток по товарам"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_gds-obj.artic)
          ).
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_gds-obj.artic
          and buf_goods.prod-type = buf_gds-obj.prod-type
          and buf_goods.prod-code = buf_gds-obj.prod-code
        .
      run ahrstutl-line-sum-type-list in this-procedure
        (input buf_goods.gds-type = 'т':U
        ,output v-sum-type-list
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_gds-obj.artic
          ,input buf_gds-obj.prod-type
          ,input buf_gds-obj.prod-code
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
procedure ahrstutl-init-tot :
  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-root-sum-type            as character no-undo .
  define input  parameter p-fact-date                as date      no-undo .
  define input  parameter p-stk-tot-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                 as logical   no-undo .
  define input  parameter p-shift-date               as date      no-undo .
  define input  parameter p-shift-num                as integer   no-undo .
  define input  parameter p-shift-stk-tot-fact-order as decimal   no-undo .
  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_shift-stk-tot for ub.stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .
  define variable v-prev-stk-tot-fact-order       as decimal   no-undo .
  define variable v-prev-shift-stk-tot-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find last buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.sum-type   = p-root-sum-type
        and buf_stk-tot.cat-id     = '##,##':U
        and buf_stk-tot.fact-order <= p-stk-tot-fact-order
      use-index category
      no-error .
    if  available buf_stk-tot
    and buf_stk-tot.fact-order <> p-stk-tot-fact-order
    then do:
      assign
        v-prev-stk-tot-fact-order = buf_stk-tot.fact-order
      .
      for each buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = p-obj-type
          and buf_stk-tot.obj-code   = p-obj-code
          and buf_stk-tot.fact-order = v-prev-stk-tot-fact-order
          and buf_stk-tot.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = buf_stk-tot.obj-type
            and buf_temp-stk-tot.obj-code   = buf_stk-tot.obj-code
            and buf_temp-stk-tot.fact-order = p-stk-tot-fact-order
            and buf_temp-stk-tot.sum-type   = buf_stk-tot.sum-type
            and buf_temp-stk-tot.cat-id     = buf_stk-tot.cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
                                    buf_temp-stk-tot.obj-type     = buf_stk-tot.obj-type     buf_temp-stk-tot.obj-code     = buf_stk-tot.obj-code     buf_temp-stk-tot.fact-order   = buf_stk-tot.fact-order   buf_temp-stk-tot.sum-type     = buf_stk-tot.sum-type     buf_temp-stk-tot.cat-id       = buf_stk-tot.cat-id       buf_temp-stk-tot.fact-date    = buf_stk-tot.fact-date    buf_temp-stk-tot.shift-num    = buf_stk-tot.shift-num    buf_temp-stk-tot.shift-date   = buf_stk-tot.shift-date
            buf_temp-stk-tot.fact-order = p-stk-tot-fact-order
            buf_temp-stk-tot.fact-date  = p-fact-date
            buf_temp-stk-tot.shift-num  = 0
            buf_temp-stk-tot.shift-date = ?
          .
        end.
        assign
                                                                      buf_temp-stk-tot.fact-qnty      = buf_stk-tot.fact-qnty            buf_temp-stk-tot.sum-base       = buf_stk-tot.sum-base             buf_temp-stk-tot.sum-rubl       = buf_stk-tot.sum-rubl             buf_temp-stk-tot.vat-base       = buf_stk-tot.vat-base             buf_temp-stk-tot.vat-rubl       = buf_stk-tot.vat-rubl             buf_temp-stk-tot.slt-base       = buf_stk-tot.slt-base             buf_temp-stk-tot.slt-rubl       = buf_stk-tot.slt-rubl             buf_temp-stk-tot.road-tax-base  = buf_stk-tot.road-tax-base        buf_temp-stk-tot.road-tax-rubl  = buf_stk-tot.road-tax-rubl        buf_temp-stk-tot.excise-base    = buf_stk-tot.excise-base          buf_temp-stk-tot.excise-rubl    = buf_stk-tot.excise-rubl          buf_temp-stk-tot.transport-base = buf_stk-tot.transport-base       buf_temp-stk-tot.transport-rubl = buf_stk-tot.transport-rubl       buf_temp-stk-tot.other-base     = buf_stk-tot.other-base           buf_temp-stk-tot.other-rubl     = buf_stk-tot.other-rubl
        .
      end.
    end.
    if p-shift-on = true
    then do:
      find last buf_shift-stk-tot no-lock
        where buf_shift-stk-tot.obj-type   = p-obj-type
          and buf_shift-stk-tot.obj-code   = p-obj-code
          and buf_shift-stk-tot.sum-type   = p-root-sum-type
          and buf_shift-stk-tot.cat-id     = '##,##':U
          and buf_shift-stk-tot.fact-order <= p-shift-stk-tot-fact-order
          and buf_shift-stk-tot.shift-date <> ?
        use-index category
        no-error .
      if  available buf_shift-stk-tot
      and buf_shift-stk-tot.fact-order <> p-shift-stk-tot-fact-order
      then do:
        assign
          v-prev-shift-stk-tot-fact-order = buf_shift-stk-tot.fact-order
        .
        for each buf_shift-stk-tot no-lock
          where buf_shift-stk-tot.obj-type   = p-obj-type
            and buf_shift-stk-tot.obj-code   = p-obj-code
            and buf_shift-stk-tot.fact-order = v-prev-shift-stk-tot-fact-order
            and buf_shift-stk-tot.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-tot
            where buf_temp-shift-stk-tot.obj-type   = buf_shift-stk-tot.obj-type
              and buf_temp-shift-stk-tot.obj-code   = buf_shift-stk-tot.obj-code
              and buf_temp-shift-stk-tot.fact-order = p-shift-stk-tot-fact-order
              and buf_temp-shift-stk-tot.sum-type   = buf_shift-stk-tot.sum-type
              and buf_temp-shift-stk-tot.cat-id     = buf_shift-stk-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-tot
          then do:
            create buf_temp-shift-stk-tot .
            assign
                                          buf_temp-shift-stk-tot.obj-type     = buf_shift-stk-tot.obj-type     buf_temp-shift-stk-tot.obj-code     = buf_shift-stk-tot.obj-code     buf_temp-shift-stk-tot.fact-order   = buf_shift-stk-tot.fact-order   buf_temp-shift-stk-tot.sum-type     = buf_shift-stk-tot.sum-type     buf_temp-shift-stk-tot.cat-id       = buf_shift-stk-tot.cat-id       buf_temp-shift-stk-tot.fact-date    = buf_shift-stk-tot.fact-date    buf_temp-shift-stk-tot.shift-num    = buf_shift-stk-tot.shift-num    buf_temp-shift-stk-tot.shift-date   = buf_shift-stk-tot.shift-date
              buf_temp-shift-stk-tot.fact-order = p-shift-stk-tot-fact-order
              buf_temp-shift-stk-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-tot.shift-date = p-shift-date
              buf_temp-shift-stk-tot.shift-num  = p-shift-num
            .
          end.
          assign
                                                                                    buf_temp-shift-stk-tot.fact-qnty      = buf_shift-stk-tot.fact-qnty            buf_temp-shift-stk-tot.sum-base       = buf_shift-stk-tot.sum-base             buf_temp-shift-stk-tot.sum-rubl       = buf_shift-stk-tot.sum-rubl             buf_temp-shift-stk-tot.vat-base       = buf_shift-stk-tot.vat-base             buf_temp-shift-stk-tot.vat-rubl       = buf_shift-stk-tot.vat-rubl             buf_temp-shift-stk-tot.slt-base       = buf_shift-stk-tot.slt-base             buf_temp-shift-stk-tot.slt-rubl       = buf_shift-stk-tot.slt-rubl             buf_temp-shift-stk-tot.road-tax-base  = buf_shift-stk-tot.road-tax-base        buf_temp-shift-stk-tot.road-tax-rubl  = buf_shift-stk-tot.road-tax-rubl        buf_temp-shift-stk-tot.excise-base    = buf_shift-stk-tot.excise-base          buf_temp-shift-stk-tot.excise-rubl    = buf_shift-stk-tot.excise-rubl          buf_temp-shift-stk-tot.transport-base = buf_shift-stk-tot.transport-base       buf_temp-shift-stk-tot.transport-rubl = buf_shift-stk-tot.transport-rubl       buf_temp-shift-stk-tot.other-base     = buf_shift-stk-tot.other-base           buf_temp-shift-stk-tot.other-rubl     = buf_shift-stk-tot.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-line :
  define input  parameter p-obj-type                  like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code                  like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                     like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type                 like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.gds-obj.prod-code no-undo .
  define input  parameter p-root-sum-type             as character no-undo .
  define input  parameter p-fact-date                 as date      no-undo .
  define input  parameter p-stk-line-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                  as logical   no-undo .
  define input  parameter p-shift-date                as date      no-undo .
  define input  parameter p-shift-num                 as integer   no-undo .
  define input  parameter p-shift-stk-line-fact-order as decimal   no-undo .
  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_shift-stk-line for ub.stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .
  define variable v-prev-stk-line-fact-order       as decimal   no-undo .
  define variable v-prev-shift-stk-line-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.artic      = p-artic
        and buf_stk-line.prod-type  = p-prod-type
        and buf_stk-line.prod-code  = p-prod-code
        and buf_stk-line.sum-type   = p-root-sum-type
        and buf_stk-line.fact-order <= p-stk-line-fact-order
      use-index category
      no-error .
    if available buf_stk-line
    and buf_stk-line.fact-order <> p-stk-line-fact-order
    then do:
      assign
        v-prev-stk-line-fact-order = buf_stk-line.fact-order
      .
      for each buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.artic      = p-artic
          and buf_stk-line.prod-type  = p-prod-type
          and buf_stk-line.prod-code  = p-prod-code
          and buf_stk-line.fact-order = v-prev-stk-line-fact-order
          and buf_stk-line.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-line
          where buf_temp-stk-line.obj-type   = buf_stk-line.obj-type
            and buf_temp-stk-line.obj-code   = buf_stk-line.obj-code
            and buf_temp-stk-line.artic      = buf_stk-line.artic
            and buf_temp-stk-line.prod-type  = buf_stk-line.prod-type
            and buf_temp-stk-line.prod-code  = buf_stk-line.prod-code
            and buf_temp-stk-line.fact-order = p-stk-line-fact-order
            and buf_temp-stk-line.sum-type   = buf_stk-line.sum-type
            and buf_temp-stk-line.cat-id     = buf_stk-line.cat-id
          no-error .
        if not available buf_temp-stk-line
        then do:
          create buf_temp-stk-line .
          assign
                                    buf_temp-stk-line.obj-type     = buf_stk-line.obj-type     buf_temp-stk-line.obj-code     = buf_stk-line.obj-code     buf_temp-stk-line.artic        = buf_stk-line.artic        buf_temp-stk-line.prod-type    = buf_stk-line.prod-type    buf_temp-stk-line.prod-code    = buf_stk-line.prod-code    buf_temp-stk-line.fact-order   = buf_stk-line.fact-order   buf_temp-stk-line.sum-type     = buf_stk-line.sum-type     buf_temp-stk-line.cat-id       = buf_stk-line.cat-id       buf_temp-stk-line.fact-date    = buf_stk-line.fact-date    buf_temp-stk-line.shift-num    = buf_stk-line.shift-num    buf_temp-stk-line.shift-date   = buf_stk-line.shift-date
            buf_temp-stk-line.fact-order = p-stk-line-fact-order
            buf_temp-stk-line.fact-date  = p-fact-date
            buf_temp-stk-line.shift-num  = 0
            buf_temp-stk-line.shift-date = ?
          .
        end.
        assign
                                                                      buf_temp-stk-line.fact-qnty      = buf_stk-line.fact-qnty            buf_temp-stk-line.sum-base       = buf_stk-line.sum-base             buf_temp-stk-line.sum-rubl       = buf_stk-line.sum-rubl             buf_temp-stk-line.vat-base       = buf_stk-line.vat-base             buf_temp-stk-line.vat-rubl       = buf_stk-line.vat-rubl             buf_temp-stk-line.slt-base       = buf_stk-line.slt-base             buf_temp-stk-line.slt-rubl       = buf_stk-line.slt-rubl             buf_temp-stk-line.road-tax-base  = buf_stk-line.road-tax-base        buf_temp-stk-line.road-tax-rubl  = buf_stk-line.road-tax-rubl        buf_temp-stk-line.excise-base    = buf_stk-line.excise-base          buf_temp-stk-line.excise-rubl    = buf_stk-line.excise-rubl          buf_temp-stk-line.transport-base = buf_stk-line.transport-base       buf_temp-stk-line.transport-rubl = buf_stk-line.transport-rubl       buf_temp-stk-line.other-base     = buf_stk-line.other-base           buf_temp-stk-line.other-rubl     = buf_stk-line.other-rubl
        .
      end.
    end.
    if p-shift-on = true
    then do:
      find last buf_shift-stk-line no-lock
        where buf_shift-stk-line.obj-type   = p-obj-type
          and buf_shift-stk-line.obj-code   = p-obj-code
          and buf_shift-stk-line.artic      = p-artic
          and buf_shift-stk-line.prod-type  = p-prod-type
          and buf_shift-stk-line.prod-code  = p-prod-code
          and buf_shift-stk-line.sum-type   = p-root-sum-type
          and buf_shift-stk-line.cat-id     = '##,##':U
          and buf_shift-stk-line.fact-order <= p-shift-stk-line-fact-order
          and buf_shift-stk-line.shift-date <> ?
        use-index category
        no-error .
      if  available buf_shift-stk-line
      and buf_shift-stk-line.fact-order <> p-shift-stk-line-fact-order
      then do:
        assign
          v-prev-shift-stk-line-fact-order = buf_shift-stk-line.fact-order
        .
        for each buf_shift-stk-line no-lock
          where buf_shift-stk-line.obj-type   = p-obj-type
            and buf_shift-stk-line.obj-code   = p-obj-code
            and buf_shift-stk-line.artic      = p-artic
            and buf_shift-stk-line.prod-type  = p-prod-type
            and buf_shift-stk-line.prod-code  = p-prod-code
            and buf_shift-stk-line.fact-order = v-prev-shift-stk-line-fact-order
            and buf_shift-stk-line.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-line
            where buf_temp-shift-stk-line.obj-type   = buf_shift-stk-line.obj-type
              and buf_temp-shift-stk-line.obj-code   = buf_shift-stk-line.obj-code
              and buf_temp-shift-stk-line.artic      = buf_shift-stk-line.artic
              and buf_temp-shift-stk-line.prod-type  = buf_shift-stk-line.prod-type
              and buf_temp-shift-stk-line.prod-code  = buf_shift-stk-line.prod-code
              and buf_temp-shift-stk-line.fact-order = p-shift-stk-line-fact-order
              and buf_temp-shift-stk-line.sum-type   = buf_shift-stk-line.sum-type
              and buf_temp-shift-stk-line.cat-id     = buf_shift-stk-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-line
          then do:
            create buf_temp-shift-stk-line .
            assign
                                          buf_temp-shift-stk-line.obj-type     = buf_shift-stk-line.obj-type     buf_temp-shift-stk-line.obj-code     = buf_shift-stk-line.obj-code     buf_temp-shift-stk-line.artic        = buf_shift-stk-line.artic        buf_temp-shift-stk-line.prod-type    = buf_shift-stk-line.prod-type    buf_temp-shift-stk-line.prod-code    = buf_shift-stk-line.prod-code    buf_temp-shift-stk-line.fact-order   = buf_shift-stk-line.fact-order   buf_temp-shift-stk-line.sum-type     = buf_shift-stk-line.sum-type     buf_temp-shift-stk-line.cat-id       = buf_shift-stk-line.cat-id       buf_temp-shift-stk-line.fact-date    = buf_shift-stk-line.fact-date    buf_temp-shift-stk-line.shift-num    = buf_shift-stk-line.shift-num    buf_temp-shift-stk-line.shift-date   = buf_shift-stk-line.shift-date
              buf_temp-shift-stk-line.fact-order = p-shift-stk-line-fact-order
              buf_temp-shift-stk-line.fact-date  = p-fact-date
              buf_temp-shift-stk-line.shift-date = p-shift-date
              buf_temp-shift-stk-line.shift-num  = p-shift-num
            .
          end.
          assign
                                                                                    buf_temp-shift-stk-line.fact-qnty      = buf_shift-stk-line.fact-qnty            buf_temp-shift-stk-line.sum-base       = buf_shift-stk-line.sum-base             buf_temp-shift-stk-line.sum-rubl       = buf_shift-stk-line.sum-rubl             buf_temp-shift-stk-line.vat-base       = buf_shift-stk-line.vat-base             buf_temp-shift-stk-line.vat-rubl       = buf_shift-stk-line.vat-rubl             buf_temp-shift-stk-line.slt-base       = buf_shift-stk-line.slt-base             buf_temp-shift-stk-line.slt-rubl       = buf_shift-stk-line.slt-rubl             buf_temp-shift-stk-line.road-tax-base  = buf_shift-stk-line.road-tax-base        buf_temp-shift-stk-line.road-tax-rubl  = buf_shift-stk-line.road-tax-rubl        buf_temp-shift-stk-line.excise-base    = buf_shift-stk-line.excise-base          buf_temp-shift-stk-line.excise-rubl    = buf_shift-stk-line.excise-rubl          buf_temp-shift-stk-line.transport-base = buf_shift-stk-line.transport-base       buf_temp-shift-stk-line.transport-rubl = buf_shift-stk-line.transport-rubl       buf_temp-shift-stk-line.other-base     = buf_shift-stk-line.other-base           buf_temp-shift-stk-line.other-rubl     = buf_shift-stk-line.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-store :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .
  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .
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
    run show-action in this-procedure
      (input "Создание остатка"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_temp-stk-tot
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Остаток по объекту"
          ).
      end.
      create buf_stk-tot .
      assign
                        buf_stk-tot.obj-type     = buf_temp-stk-tot.obj-type     buf_stk-tot.obj-code     = buf_temp-stk-tot.obj-code     buf_stk-tot.fact-order   = buf_temp-stk-tot.fact-order   buf_stk-tot.sum-type     = buf_temp-stk-tot.sum-type     buf_stk-tot.cat-id       = buf_temp-stk-tot.cat-id       buf_stk-tot.fact-date    = buf_temp-stk-tot.fact-date    buf_stk-tot.shift-num    = buf_temp-stk-tot.shift-num    buf_stk-tot.shift-date   = buf_temp-stk-tot.shift-date
                                                        buf_stk-tot.fact-qnty      = buf_temp-stk-tot.fact-qnty            buf_stk-tot.sum-base       = buf_temp-stk-tot.sum-base             buf_stk-tot.sum-rubl       = buf_temp-stk-tot.sum-rubl             buf_stk-tot.vat-base       = buf_temp-stk-tot.vat-base             buf_stk-tot.vat-rubl       = buf_temp-stk-tot.vat-rubl             buf_stk-tot.slt-base       = buf_temp-stk-tot.slt-base             buf_stk-tot.slt-rubl       = buf_temp-stk-tot.slt-rubl             buf_stk-tot.road-tax-base  = buf_temp-stk-tot.road-tax-base        buf_stk-tot.road-tax-rubl  = buf_temp-stk-tot.road-tax-rubl        buf_stk-tot.excise-base    = buf_temp-stk-tot.excise-base          buf_stk-tot.excise-rubl    = buf_temp-stk-tot.excise-rubl          buf_stk-tot.transport-base = buf_temp-stk-tot.transport-base       buf_stk-tot.transport-rubl = buf_temp-stk-tot.transport-rubl       buf_stk-tot.other-base     = buf_temp-stk-tot.other-base           buf_stk-tot.other-rubl     = buf_temp-stk-tot.other-rubl
        buf_stk-tot.fact-order = buf_temp-stk-tot.fact-order
        buf_stk-tot.fact-date  = buf_temp-stk-tot.fact-date
        buf_stk-tot.shift-num  = buf_temp-stk-tot.shift-num
        buf_stk-tot.shift-date = buf_temp-stk-tot.shift-date
      .
    end.
    if v-shift-on = true
    then do:
      for each buf_temp-shift-stk-tot
      on error undo, return error
      :
        create buf_stk-tot .
        assign
                              buf_stk-tot.obj-type     = buf_temp-shift-stk-tot.obj-type     buf_stk-tot.obj-code     = buf_temp-shift-stk-tot.obj-code     buf_stk-tot.fact-order   = buf_temp-shift-stk-tot.fact-order   buf_stk-tot.sum-type     = buf_temp-shift-stk-tot.sum-type     buf_stk-tot.cat-id       = buf_temp-shift-stk-tot.cat-id       buf_stk-tot.fact-date    = buf_temp-shift-stk-tot.fact-date    buf_stk-tot.shift-num    = buf_temp-shift-stk-tot.shift-num    buf_stk-tot.shift-date   = buf_temp-shift-stk-tot.shift-date
                                                                      buf_stk-tot.fact-qnty      = buf_temp-shift-stk-tot.fact-qnty            buf_stk-tot.sum-base       = buf_temp-shift-stk-tot.sum-base             buf_stk-tot.sum-rubl       = buf_temp-shift-stk-tot.sum-rubl             buf_stk-tot.vat-base       = buf_temp-shift-stk-tot.vat-base             buf_stk-tot.vat-rubl       = buf_temp-shift-stk-tot.vat-rubl             buf_stk-tot.slt-base       = buf_temp-shift-stk-tot.slt-base             buf_stk-tot.slt-rubl       = buf_temp-shift-stk-tot.slt-rubl             buf_stk-tot.road-tax-base  = buf_temp-shift-stk-tot.road-tax-base        buf_stk-tot.road-tax-rubl  = buf_temp-shift-stk-tot.road-tax-rubl        buf_stk-tot.excise-base    = buf_temp-shift-stk-tot.excise-base          buf_stk-tot.excise-rubl    = buf_temp-shift-stk-tot.excise-rubl          buf_stk-tot.transport-base = buf_temp-shift-stk-tot.transport-base       buf_stk-tot.transport-rubl = buf_temp-shift-stk-tot.transport-rubl       buf_stk-tot.other-base     = buf_temp-shift-stk-tot.other-base           buf_stk-tot.other-rubl     = buf_temp-shift-stk-tot.other-rubl
          buf_stk-tot.fact-order = buf_temp-shift-stk-tot.fact-order
          buf_stk-tot.fact-date  = buf_temp-shift-stk-tot.fact-date
          buf_stk-tot.shift-num  = buf_temp-shift-stk-tot.shift-num
          buf_stk-tot.shift-date = buf_temp-shift-stk-tot.shift-date
        .
      end.
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-stk-line
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул" + string(buf_temp-stk-line.artic)
          ).
      end.
      create buf_stk-line .
      assign
                        buf_stk-line.obj-type     = buf_temp-stk-line.obj-type     buf_stk-line.obj-code     = buf_temp-stk-line.obj-code     buf_stk-line.artic        = buf_temp-stk-line.artic        buf_stk-line.prod-type    = buf_temp-stk-line.prod-type    buf_stk-line.prod-code    = buf_temp-stk-line.prod-code    buf_stk-line.fact-order   = buf_temp-stk-line.fact-order   buf_stk-line.sum-type     = buf_temp-stk-line.sum-type     buf_stk-line.cat-id       = buf_temp-stk-line.cat-id       buf_stk-line.fact-date    = buf_temp-stk-line.fact-date    buf_stk-line.shift-num    = buf_temp-stk-line.shift-num    buf_stk-line.shift-date   = buf_temp-stk-line.shift-date
                                                        buf_stk-line.fact-qnty      = buf_temp-stk-line.fact-qnty            buf_stk-line.sum-base       = buf_temp-stk-line.sum-base             buf_stk-line.sum-rubl       = buf_temp-stk-line.sum-rubl             buf_stk-line.vat-base       = buf_temp-stk-line.vat-base             buf_stk-line.vat-rubl       = buf_temp-stk-line.vat-rubl             buf_stk-line.slt-base       = buf_temp-stk-line.slt-base             buf_stk-line.slt-rubl       = buf_temp-stk-line.slt-rubl             buf_stk-line.road-tax-base  = buf_temp-stk-line.road-tax-base        buf_stk-line.road-tax-rubl  = buf_temp-stk-line.road-tax-rubl        buf_stk-line.excise-base    = buf_temp-stk-line.excise-base          buf_stk-line.excise-rubl    = buf_temp-stk-line.excise-rubl          buf_stk-line.transport-base = buf_temp-stk-line.transport-base       buf_stk-line.transport-rubl = buf_temp-stk-line.transport-rubl       buf_stk-line.other-base     = buf_temp-stk-line.other-base           buf_stk-line.other-rubl     = buf_temp-stk-line.other-rubl
        buf_stk-line.fact-order = buf_temp-stk-line.fact-order
        buf_stk-line.fact-date  = buf_temp-stk-line.fact-date
        buf_stk-line.shift-num  = buf_temp-stk-line.shift-num
        buf_stk-line.shift-date = buf_temp-stk-line.shift-date
      .
    end.
    if v-shift-on = true
    then do:
      for each buf_temp-shift-stk-line
      on error undo, return error
      :
        create buf_stk-line .
        assign
                              buf_stk-line.obj-type     = buf_temp-shift-stk-line.obj-type     buf_stk-line.obj-code     = buf_temp-shift-stk-line.obj-code     buf_stk-line.artic        = buf_temp-shift-stk-line.artic        buf_stk-line.prod-type    = buf_temp-shift-stk-line.prod-type    buf_stk-line.prod-code    = buf_temp-shift-stk-line.prod-code    buf_stk-line.fact-order   = buf_temp-shift-stk-line.fact-order   buf_stk-line.sum-type     = buf_temp-shift-stk-line.sum-type     buf_stk-line.cat-id       = buf_temp-shift-stk-line.cat-id       buf_stk-line.fact-date    = buf_temp-shift-stk-line.fact-date    buf_stk-line.shift-num    = buf_temp-shift-stk-line.shift-num    buf_stk-line.shift-date   = buf_temp-shift-stk-line.shift-date
                                                                      buf_stk-line.fact-qnty      = buf_temp-shift-stk-line.fact-qnty            buf_stk-line.sum-base       = buf_temp-shift-stk-line.sum-base             buf_stk-line.sum-rubl       = buf_temp-shift-stk-line.sum-rubl             buf_stk-line.vat-base       = buf_temp-shift-stk-line.vat-base             buf_stk-line.vat-rubl       = buf_temp-shift-stk-line.vat-rubl             buf_stk-line.slt-base       = buf_temp-shift-stk-line.slt-base             buf_stk-line.slt-rubl       = buf_temp-shift-stk-line.slt-rubl             buf_stk-line.road-tax-base  = buf_temp-shift-stk-line.road-tax-base        buf_stk-line.road-tax-rubl  = buf_temp-shift-stk-line.road-tax-rubl        buf_stk-line.excise-base    = buf_temp-shift-stk-line.excise-base          buf_stk-line.excise-rubl    = buf_temp-shift-stk-line.excise-rubl          buf_stk-line.transport-base = buf_temp-shift-stk-line.transport-base       buf_stk-line.transport-rubl = buf_temp-shift-stk-line.transport-rubl       buf_stk-line.other-base     = buf_temp-shift-stk-line.other-base           buf_stk-line.other-rubl     = buf_temp-shift-stk-line.other-rubl
          buf_stk-line.fact-order = buf_temp-shift-stk-line.fact-order
          buf_stk-line.fact-date  = buf_temp-shift-stk-line.fact-date
          buf_stk-line.shift-num  = buf_temp-shift-stk-line.shift-num
          buf_stk-line.shift-date = buf_temp-shift-stk-line.shift-date
        .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-clear-arh :
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .
  define buffer buf_ot-tot   for ub.ot-tot .
  define buffer buf_ot-line  for ub.ot-line .
  define buffer buf_stk-tot  for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .
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
    for each buf_ot-tot
      where buf_ot-tot.obj-type   = p-obj-type
        and buf_ot-tot.obj-code   = p-obj-code
        and buf_ot-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-tot.doc-code)
          ).
      end.
      delete buf_ot-tot .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .
    for each buf_ot-line
      where buf_ot-line.obj-type   = p-obj-type
        and buf_ot-line.obj-code   = p-obj-code
        and buf_ot-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-line.doc-code)
                  + " Артикул " + string(buf_ot-line.artic)
          ).
      end.
      delete buf_ot-line .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-tot
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_stk-tot.fact-date, '99/99/9999':U )
          ).
      end.
      if buf_stk-tot.shift-date = ?
      or (buf_stk-tot.shift-date <> ?
          and
          buf_stk-tot.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-tot .
      end.
    end.
    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-line
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Артикул " + string(buf_stk-line.artic)
          ).
      end.
      if buf_stk-line.shift-date = ?
      or (buf_stk-line.shift-date <> ?
          and
          buf_stk-line.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-line .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-tot-sum-type-list :
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
      p-sum-type-list = 'crsa':U
                      + chr(44)
                      + 'cost':U
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
                        + 'cgdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
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
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'adsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'gdsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'sdsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
  end.
end procedure.
procedure ahrstutl-line-sum-type-list :
  define input  parameter p-gds-goods     as logical   no-undo .
  define output parameter p-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .
    assign
      v-num-entries-TDEDT_List = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
    .
    if p-gds-goods
    then do:
      assign
        p-sum-type-list = 'crsa':U
                        + chr(44)
                        + 'cost':U
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
                          + 'cgdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
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
    else do:
      assign
        p-sum-type-list = 'cgsr':U
                        + chr(44)
                        + 'cssr':U
      .
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + chr(44)
                          + 'adsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + chr(44)
                          + 'gdsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + chr(44)
                          + 'sdsr':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        .
      end.
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
