block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-aht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-aht.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по типам приобретения".
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream ahtlog .
define temp-table temp-aht-ot-tot no-undo like ub.aht-ot-tot .
define temp-table temp-aht-ot-line no-undo like ub.aht-ot-line .
define temp-table temp-aht-stk-tot no-undo like ub.aht-stk-tot .
define temp-table temp-aht-stk-line no-undo like ub.aht-stk-line .
procedure aht_get-sum-type :
  define input  parameter p-aht-type        as character no-undo .
  define output parameter p-allsum-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-aht-type :
      when 'r':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_выкупу_со_знаком':U
        .
      end.
      when 'c':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_закупка_со_знаком':U
        .
      end.
      when 'b':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_выгода_со_знаком':U
        .
      end.
      when 's':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_ответственному_хранению_со_знаком':U
        .
      end.
      when 'o':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_старой_консигнации_со_знаком':U
        .
      end.
      when 'v':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_услуге_со_знаком':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Неизвестное значение типа приобретения" skip
          "Тип приобретения" p-aht-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure aht_get-stk-sum-type :
  define input  parameter p-ot-sum-type      as character no-undo .
  define input  parameter p-ext-doc-type     as character no-undo .
  define output parameter p-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-stk-ext-sum-type = p-ot-sum-type + p-ext-doc-type
    .
  end.
end procedure.
procedure aht_store-ot-line :
  define input  parameter p-doc-code       as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-sum-type       as character no-undo .
  define input  parameter p-ext-doc-type   as character no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-fact-order     as decimal   no-undo .
  define input  parameter p-fact-qnty      as decimal   no-undo .
          define input  parameter p-cost-sum-base       as decimal   no-undo .     define input  parameter p-cost-sum-rubl       as decimal   no-undo .     define input  parameter p-cost-vat-base       as decimal   no-undo .     define input  parameter p-cost-vat-rubl       as decimal   no-undo .     define input  parameter p-cost-slt-base       as decimal   no-undo .     define input  parameter p-cost-slt-rubl       as decimal   no-undo .     define input  parameter p-cost-road-tax-base  as decimal   no-undo .     define input  parameter p-cost-road-tax-rubl  as decimal   no-undo .     define input  parameter p-cost-excise-base    as decimal   no-undo .     define input  parameter p-cost-excise-rubl    as decimal   no-undo .     define input  parameter p-cost-transport-base as decimal   no-undo .     define input  parameter p-cost-transport-rubl as decimal   no-undo .     define input  parameter p-cost-other-base     as decimal   no-undo .     define input  parameter p-cost-other-rubl     as decimal   no-undo .     define input  parameter p-cost-discnt-base    as decimal   no-undo .     define input  parameter p-cost-discnt-rubl    as decimal   no-undo .
          define input  parameter p-crsa-sum-base       as decimal   no-undo .     define input  parameter p-crsa-sum-rubl       as decimal   no-undo .     define input  parameter p-crsa-vat-base       as decimal   no-undo .     define input  parameter p-crsa-vat-rubl       as decimal   no-undo .     define input  parameter p-crsa-slt-base       as decimal   no-undo .     define input  parameter p-crsa-slt-rubl       as decimal   no-undo .     define input  parameter p-crsa-road-tax-base  as decimal   no-undo .     define input  parameter p-crsa-road-tax-rubl  as decimal   no-undo .     define input  parameter p-crsa-excise-base    as decimal   no-undo .     define input  parameter p-crsa-excise-rubl    as decimal   no-undo .     define input  parameter p-crsa-transport-base as decimal   no-undo .     define input  parameter p-crsa-transport-rubl as decimal   no-undo .     define input  parameter p-crsa-other-base     as decimal   no-undo .     define input  parameter p-crsa-other-rubl     as decimal   no-undo .     define input  parameter p-crsa-discnt-base    as decimal   no-undo .     define input  parameter p-crsa-discnt-rubl    as decimal   no-undo .
          define input  parameter p-sale-sum-base       as decimal   no-undo .     define input  parameter p-sale-sum-rubl       as decimal   no-undo .     define input  parameter p-sale-vat-base       as decimal   no-undo .     define input  parameter p-sale-vat-rubl       as decimal   no-undo .     define input  parameter p-sale-slt-base       as decimal   no-undo .     define input  parameter p-sale-slt-rubl       as decimal   no-undo .     define input  parameter p-sale-road-tax-base  as decimal   no-undo .     define input  parameter p-sale-road-tax-rubl  as decimal   no-undo .     define input  parameter p-sale-excise-base    as decimal   no-undo .     define input  parameter p-sale-excise-rubl    as decimal   no-undo .     define input  parameter p-sale-transport-base as decimal   no-undo .     define input  parameter p-sale-transport-rubl as decimal   no-undo .     define input  parameter p-sale-other-base     as decimal   no-undo .     define input  parameter p-sale-other-rubl     as decimal   no-undo .     define input  parameter p-sale-discnt-base    as decimal   no-undo .     define input  parameter p-sale-discnt-rubl    as decimal   no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  do
  on error undo, return error return-value
  :
    find first buf_temp-aht-ot-line
      where buf_temp-aht-ot-line.doc-code  = p-doc-code
        and buf_temp-aht-ot-line.gds-code  = p-gds-code
        and buf_temp-aht-ot-line.sum-type  = p-sum-type
      no-error .
    if not available buf_temp-aht-ot-line then do:
      create buf_temp-aht-ot-line .
      assign
        buf_temp-aht-ot-line.doc-code     = p-doc-code
        buf_temp-aht-ot-line.gds-code     = p-gds-code
        buf_temp-aht-ot-line.sum-type     = p-sum-type
        buf_temp-aht-ot-line.ext-doc-type = p-ext-doc-type
        buf_temp-aht-ot-line.obj-type     = p-obj-type
        buf_temp-aht-ot-line.obj-code     = p-obj-code
        buf_temp-aht-ot-line.fact-order   = p-fact-order
      .
    end.
    assign
      buf_temp-aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty + p-fact-qnty
                                                      buf_temp-aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base       + p-cost-sum-base            buf_temp-aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl       + p-cost-sum-rubl            buf_temp-aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base       + p-cost-vat-base            buf_temp-aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl       + p-cost-vat-rubl            buf_temp-aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base       + p-cost-slt-base            buf_temp-aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl       + p-cost-slt-rubl            buf_temp-aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base  + p-cost-road-tax-base       buf_temp-aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl  + p-cost-road-tax-rubl       buf_temp-aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base    + p-cost-excise-base         buf_temp-aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl    + p-cost-excise-rubl         buf_temp-aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base + p-cost-transport-base      buf_temp-aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl + p-cost-transport-rubl      buf_temp-aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base     + p-cost-other-base          buf_temp-aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl     + p-cost-other-rubl          buf_temp-aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base    + p-cost-discnt-base          buf_temp-aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl    + p-cost-discnt-rubl
                                                      buf_temp-aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base       + p-crsa-sum-base            buf_temp-aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl       + p-crsa-sum-rubl            buf_temp-aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base       + p-crsa-vat-base            buf_temp-aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl       + p-crsa-vat-rubl            buf_temp-aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base       + p-crsa-slt-base            buf_temp-aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl       + p-crsa-slt-rubl            buf_temp-aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base  + p-crsa-road-tax-base       buf_temp-aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl  + p-crsa-road-tax-rubl       buf_temp-aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base    + p-crsa-excise-base         buf_temp-aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl    + p-crsa-excise-rubl         buf_temp-aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base + p-crsa-transport-base      buf_temp-aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl + p-crsa-transport-rubl      buf_temp-aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base     + p-crsa-other-base          buf_temp-aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl     + p-crsa-other-rubl          buf_temp-aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base    + p-crsa-discnt-base          buf_temp-aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl    + p-crsa-discnt-rubl
                                                      buf_temp-aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base       + p-sale-sum-base            buf_temp-aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl       + p-sale-sum-rubl            buf_temp-aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base       + p-sale-vat-base            buf_temp-aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl       + p-sale-vat-rubl            buf_temp-aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base       + p-sale-slt-base            buf_temp-aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl       + p-sale-slt-rubl            buf_temp-aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base  + p-sale-road-tax-base       buf_temp-aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl  + p-sale-road-tax-rubl       buf_temp-aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base    + p-sale-excise-base         buf_temp-aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl    + p-sale-excise-rubl         buf_temp-aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base + p-sale-transport-base      buf_temp-aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl + p-sale-transport-rubl      buf_temp-aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base     + p-sale-other-base          buf_temp-aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl     + p-sale-other-rubl          buf_temp-aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base    + p-sale-discnt-base          buf_temp-aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl    + p-sale-discnt-rubl
    .
  end.
end procedure.
procedure aht_update-ot-tot :
  define input  parameter p-obj-type            like ub.trn-doc.obj-type     no-undo .
  define input  parameter p-obj-code            like ub.trn-doc.obj-code     no-undo .
  define input  parameter p-fact-order          like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type        like ub.trn-doc.ext-doc-type no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      find first buf_temp-aht-ot-tot
        where buf_temp-aht-ot-tot.doc-code = buf_temp-aht-ot-line.doc-code
          and buf_temp-aht-ot-tot.sum-type = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_temp-aht-ot-tot then do:
        create buf_temp-aht-ot-tot .
        assign
          buf_temp-aht-ot-tot.doc-code     = buf_temp-aht-ot-line.doc-code
          buf_temp-aht-ot-tot.sum-type     = buf_temp-aht-ot-line.sum-type
          buf_temp-aht-ot-tot.ext-doc-type = p-ext-doc-type
          buf_temp-aht-ot-tot.obj-type     = p-obj-type
          buf_temp-aht-ot-tot.obj-code     = p-obj-code
          buf_temp-aht-ot-tot.fact-order   = p-fact-order
        .
      end.
      assign
        buf_temp-aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                        buf_temp-aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_temp-aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_temp-aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_temp-aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_temp-aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_temp-aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_temp-aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_temp-aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_temp-aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_temp-aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_temp-aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_temp-aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_temp-aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_temp-aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_temp-aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_temp-aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                        buf_temp-aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_temp-aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_temp-aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_temp-aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_temp-aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_temp-aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_temp-aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_temp-aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_temp-aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_temp-aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_temp-aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_temp-aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_temp-aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_temp-aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_temp-aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_temp-aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
                                                                        buf_temp-aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_temp-aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_temp-aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_temp-aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_temp-aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_temp-aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_temp-aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_temp-aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_temp-aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_temp-aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_temp-aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_temp-aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_temp-aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_temp-aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_temp-aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_temp-aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_update-stk-table :
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-trn-doc        as logical   no-undo .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define variable v-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-tot.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input buf_temp-aht-ot-tot.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-line.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input buf_temp-aht-ot-line.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
  end.
end procedure.
procedure aht_store-stk-tot :
  define parameter buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define input  parameter p-stk-sum-type      as character no-undo .
  define input  parameter p-fact-order        like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order    like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type      like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale       as logical   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer new-buf_aht-stk-tot for ub.aht-stk-tot .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        and buf_aht-stk-tot.sum-type   = p-stk-sum-type
        and buf_aht-stk-tot.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-tot
    or buf_aht-stk-tot.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-tot .
      assign
        new-buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        new-buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        new-buf_aht-stk-tot.fact-order = p-fact-order
        new-buf_aht-stk-tot.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-tot then do:
        assign
          new-buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
                                                                      new-buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base             new-buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl             new-buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base             new-buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl             new-buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base             new-buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl             new-buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base        new-buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl        new-buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base          new-buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl          new-buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base       new-buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl       new-buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base           new-buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl           new-buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base          new-buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl
                                                                      new-buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base             new-buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl             new-buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base             new-buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl             new-buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base             new-buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl             new-buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base        new-buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl        new-buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base          new-buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl          new-buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base       new-buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl       new-buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base           new-buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl           new-buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base          new-buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base             new-buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl             new-buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base             new-buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl             new-buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base             new-buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl             new-buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base        new-buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl        new-buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base          new-buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl          new-buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base       new-buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl       new-buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base           new-buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl           new-buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base          new-buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
          and buf_aht-stk-tot.sum-type   = p-stk-sum-type
          and buf_aht-stk-tot.fact-order >= p-fact-order
          and buf_aht-stk-tot.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty + buf_temp-aht-ot-tot.fact-qnty
                                                                                          buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base       + buf_temp-aht-ot-tot.cost-sum-base            buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl       + buf_temp-aht-ot-tot.cost-sum-rubl            buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base       + buf_temp-aht-ot-tot.cost-vat-base            buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl       + buf_temp-aht-ot-tot.cost-vat-rubl            buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base       + buf_temp-aht-ot-tot.cost-slt-base            buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl       + buf_temp-aht-ot-tot.cost-slt-rubl            buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base  + buf_temp-aht-ot-tot.cost-road-tax-base       buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl  + buf_temp-aht-ot-tot.cost-road-tax-rubl       buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base    + buf_temp-aht-ot-tot.cost-excise-base         buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl    + buf_temp-aht-ot-tot.cost-excise-rubl         buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base + buf_temp-aht-ot-tot.cost-transport-base      buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl + buf_temp-aht-ot-tot.cost-transport-rubl      buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base     + buf_temp-aht-ot-tot.cost-other-base          buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl     + buf_temp-aht-ot-tot.cost-other-rubl          buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base    + buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl    + buf_temp-aht-ot-tot.cost-discnt-rubl
                                                                                          buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base       + buf_temp-aht-ot-tot.crsa-sum-base            buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl       + buf_temp-aht-ot-tot.crsa-sum-rubl            buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base       + buf_temp-aht-ot-tot.crsa-vat-base            buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl       + buf_temp-aht-ot-tot.crsa-vat-rubl            buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base       + buf_temp-aht-ot-tot.crsa-slt-base            buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl       + buf_temp-aht-ot-tot.crsa-slt-rubl            buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base  + buf_temp-aht-ot-tot.crsa-road-tax-base       buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-tot.crsa-road-tax-rubl       buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base    + buf_temp-aht-ot-tot.crsa-excise-base         buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl    + buf_temp-aht-ot-tot.crsa-excise-rubl         buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base + buf_temp-aht-ot-tot.crsa-transport-base      buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl + buf_temp-aht-ot-tot.crsa-transport-rubl      buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base     + buf_temp-aht-ot-tot.crsa-other-base          buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl     + buf_temp-aht-ot-tot.crsa-other-rubl          buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base    + buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl    + buf_temp-aht-ot-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base       + buf_temp-aht-ot-tot.sale-sum-base            buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl       + buf_temp-aht-ot-tot.sale-sum-rubl            buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base       + buf_temp-aht-ot-tot.sale-vat-base            buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl       + buf_temp-aht-ot-tot.sale-vat-rubl            buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base       + buf_temp-aht-ot-tot.sale-slt-base            buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl       + buf_temp-aht-ot-tot.sale-slt-rubl            buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base  + buf_temp-aht-ot-tot.sale-road-tax-base       buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl  + buf_temp-aht-ot-tot.sale-road-tax-rubl       buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base    + buf_temp-aht-ot-tot.sale-excise-base         buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl    + buf_temp-aht-ot-tot.sale-excise-rubl         buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base + buf_temp-aht-ot-tot.sale-transport-base      buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl + buf_temp-aht-ot-tot.sale-transport-rubl      buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base     + buf_temp-aht-ot-tot.sale-other-base          buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl     + buf_temp-aht-ot-tot.sale-other-rubl          buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base    + buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl    + buf_temp-aht-ot-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-stk-line :
  define parameter buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define input  parameter p-stk-sum-type   as character no-undo .
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale    as logical   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer new-buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        and buf_aht-stk-line.sum-type   = p-stk-sum-type
        and buf_aht-stk-line.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-line
    or buf_aht-stk-line.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-line .
      assign
        new-buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        new-buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        new-buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        new-buf_aht-stk-line.fact-order = p-fact-order
        new-buf_aht-stk-line.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-line then do:
        assign
          new-buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
                                                                      new-buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base             new-buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl             new-buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base             new-buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl             new-buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base             new-buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl             new-buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base        new-buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl        new-buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base          new-buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl          new-buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base       new-buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl       new-buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base           new-buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl           new-buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base          new-buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl
                                                                      new-buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base             new-buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl             new-buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base             new-buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl             new-buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base             new-buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl             new-buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base        new-buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl        new-buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base          new-buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl          new-buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base       new-buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl       new-buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base           new-buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl           new-buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base          new-buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base             new-buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl             new-buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base             new-buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl             new-buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base             new-buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl             new-buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base        new-buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl        new-buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base          new-buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl          new-buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base       new-buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl       new-buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base           new-buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl           new-buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base          new-buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
          and buf_aht-stk-line.sum-type   = p-stk-sum-type
          and buf_aht-stk-line.fact-order >= p-fact-order
          and buf_aht-stk-line.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                                          buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                                          buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-ot-table :
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_aht-ot-tot for ub.aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_aht-ot-line for ub.aht-ot-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-tot.cost-sum-base       = ? or    buf_temp-aht-ot-tot.cost-sum-rubl       = ? or    buf_temp-aht-ot-tot.cost-vat-base       = ? or    buf_temp-aht-ot-tot.cost-vat-rubl       = ? or    buf_temp-aht-ot-tot.cost-slt-base       = ? or    buf_temp-aht-ot-tot.cost-slt-rubl       = ? or    buf_temp-aht-ot-tot.cost-road-tax-base  = ? or    buf_temp-aht-ot-tot.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.cost-excise-base    = ? or    buf_temp-aht-ot-tot.cost-excise-rubl    = ? or    buf_temp-aht-ot-tot.cost-transport-base = ? or    buf_temp-aht-ot-tot.cost-transport-rubl = ? or    buf_temp-aht-ot-tot.cost-other-base     = ? or    buf_temp-aht-ot-tot.cost-other-rubl     = ? or    buf_temp-aht-ot-tot.cost-discnt-base    = ? or    buf_temp-aht-ot-tot.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.crsa-sum-base       = ? or    buf_temp-aht-ot-tot.crsa-sum-rubl       = ? or    buf_temp-aht-ot-tot.crsa-vat-base       = ? or    buf_temp-aht-ot-tot.crsa-vat-rubl       = ? or    buf_temp-aht-ot-tot.crsa-slt-base       = ? or    buf_temp-aht-ot-tot.crsa-slt-rubl       = ? or    buf_temp-aht-ot-tot.crsa-road-tax-base  = ? or    buf_temp-aht-ot-tot.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.crsa-excise-base    = ? or    buf_temp-aht-ot-tot.crsa-excise-rubl    = ? or    buf_temp-aht-ot-tot.crsa-transport-base = ? or    buf_temp-aht-ot-tot.crsa-transport-rubl = ? or    buf_temp-aht-ot-tot.crsa-other-base     = ? or    buf_temp-aht-ot-tot.crsa-other-rubl     = ? or    buf_temp-aht-ot-tot.crsa-discnt-base    = ? or    buf_temp-aht-ot-tot.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.sale-sum-base       = ? or    buf_temp-aht-ot-tot.sale-sum-rubl       = ? or    buf_temp-aht-ot-tot.sale-vat-base       = ? or    buf_temp-aht-ot-tot.sale-vat-rubl       = ? or    buf_temp-aht-ot-tot.sale-slt-base       = ? or    buf_temp-aht-ot-tot.sale-slt-rubl       = ? or    buf_temp-aht-ot-tot.sale-road-tax-base  = ? or    buf_temp-aht-ot-tot.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.sale-excise-base    = ? or    buf_temp-aht-ot-tot.sale-excise-rubl    = ? or    buf_temp-aht-ot-tot.sale-transport-base = ? or    buf_temp-aht-ot-tot.sale-transport-rubl = ? or    buf_temp-aht-ot-tot.sale-other-base     = ? or    buf_temp-aht-ot-tot.sale-other-rubl     = ? or    buf_temp-aht-ot-tot.sale-discnt-base    = ? or    buf_temp-aht-ot-tot.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-tot.doc-code skip
          "Тип суммы" buf_temp-aht-ot-tot.sum-type skip
          view-as alert-box error .
        output stream ahtlog to ahtlog.txt append .
        export stream ahtlog
          vss-include-info4 buf_temp-aht-ot-tot.doc-code .
                                                        export stream ahtlog "temp-aht-ot-tot.cost-sum-base"       buf_temp-aht-ot-tot.cost-sum-base        .     export stream ahtlog "temp-aht-ot-tot.cost-sum-rubl"       buf_temp-aht-ot-tot.cost-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-base"       buf_temp-aht-ot-tot.cost-vat-base        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-rubl"       buf_temp-aht-ot-tot.cost-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-base"       buf_temp-aht-ot-tot.cost-slt-base        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-rubl"       buf_temp-aht-ot-tot.cost-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-base"  buf_temp-aht-ot-tot.cost-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-rubl"  buf_temp-aht-ot-tot.cost-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.cost-excise-base"    buf_temp-aht-ot-tot.cost-excise-base     .     export stream ahtlog "temp-aht-ot-tot.cost-excise-rubl"    buf_temp-aht-ot-tot.cost-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.cost-transport-base" buf_temp-aht-ot-tot.cost-transport-base  .     export stream ahtlog "temp-aht-ot-tot.cost-transport-rubl" buf_temp-aht-ot-tot.cost-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.cost-other-base"     buf_temp-aht-ot-tot.cost-other-base      .     export stream ahtlog "temp-aht-ot-tot.cost-other-rubl"     buf_temp-aht-ot-tot.cost-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-base"    buf_temp-aht-ot-tot.cost-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-rubl"    buf_temp-aht-ot-tot.cost-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.crsa-sum-base"       buf_temp-aht-ot-tot.crsa-sum-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-sum-rubl"       buf_temp-aht-ot-tot.crsa-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-base"       buf_temp-aht-ot-tot.crsa-vat-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-rubl"       buf_temp-aht-ot-tot.crsa-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-base"       buf_temp-aht-ot-tot.crsa-slt-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-rubl"       buf_temp-aht-ot-tot.crsa-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-base"  buf_temp-aht-ot-tot.crsa-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-rubl"  buf_temp-aht-ot-tot.crsa-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-base"    buf_temp-aht-ot-tot.crsa-excise-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-rubl"    buf_temp-aht-ot-tot.crsa-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-base" buf_temp-aht-ot-tot.crsa-transport-base  .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-rubl" buf_temp-aht-ot-tot.crsa-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.crsa-other-base"     buf_temp-aht-ot-tot.crsa-other-base      .     export stream ahtlog "temp-aht-ot-tot.crsa-other-rubl"     buf_temp-aht-ot-tot.crsa-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-base"    buf_temp-aht-ot-tot.crsa-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-rubl"    buf_temp-aht-ot-tot.crsa-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.sale-sum-base"       buf_temp-aht-ot-tot.sale-sum-base        .     export stream ahtlog "temp-aht-ot-tot.sale-sum-rubl"       buf_temp-aht-ot-tot.sale-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-base"       buf_temp-aht-ot-tot.sale-vat-base        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-rubl"       buf_temp-aht-ot-tot.sale-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-base"       buf_temp-aht-ot-tot.sale-slt-base        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-rubl"       buf_temp-aht-ot-tot.sale-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-base"  buf_temp-aht-ot-tot.sale-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-rubl"  buf_temp-aht-ot-tot.sale-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.sale-excise-base"    buf_temp-aht-ot-tot.sale-excise-base     .     export stream ahtlog "temp-aht-ot-tot.sale-excise-rubl"    buf_temp-aht-ot-tot.sale-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.sale-transport-base" buf_temp-aht-ot-tot.sale-transport-base  .     export stream ahtlog "temp-aht-ot-tot.sale-transport-rubl" buf_temp-aht-ot-tot.sale-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.sale-other-base"     buf_temp-aht-ot-tot.sale-other-base      .     export stream ahtlog "temp-aht-ot-tot.sale-other-rubl"     buf_temp-aht-ot-tot.sale-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-base"    buf_temp-aht-ot-tot.sale-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-rubl"    buf_temp-aht-ot-tot.sale-discnt-rubl     .
        output stream ahtlog close .
        undo, return error .
      end.
      find first buf_aht-ot-tot exclusive-lock
        where buf_aht-ot-tot.doc-code = buf_temp-aht-ot-tot.doc-code
          and buf_aht-ot-tot.sum-type = buf_temp-aht-ot-tot.sum-type
        no-error .
      if not available buf_aht-ot-tot then do:
        create buf_aht-ot-tot .
      end.
                  assign
        buf_aht-ot-tot.doc-code     = buf_temp-aht-ot-tot.doc-code       buf_aht-ot-tot.sum-type     = buf_temp-aht-ot-tot.sum-type       buf_aht-ot-tot.ext-doc-type = buf_temp-aht-ot-tot.ext-doc-type   buf_aht-ot-tot.obj-type     = buf_temp-aht-ot-tot.obj-type       buf_aht-ot-tot.obj-code     = buf_temp-aht-ot-tot.obj-code       buf_aht-ot-tot.fact-order   = buf_temp-aht-ot-tot.fact-order
      .
      assign
        buf_aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty
                                                        buf_aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base             buf_aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl             buf_aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base             buf_aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl             buf_aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base             buf_aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl             buf_aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base        buf_aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl        buf_aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base          buf_aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl          buf_aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base       buf_aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl       buf_aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base           buf_aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl           buf_aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl
                                                        buf_aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base             buf_aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl             buf_aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base             buf_aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl             buf_aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base             buf_aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl             buf_aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base        buf_aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl        buf_aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base          buf_aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl          buf_aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base       buf_aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl       buf_aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base           buf_aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl           buf_aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl
                                                        buf_aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base             buf_aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl             buf_aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base             buf_aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl             buf_aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base             buf_aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl             buf_aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base        buf_aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl        buf_aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base          buf_aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl          buf_aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base       buf_aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl       buf_aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base           buf_aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl           buf_aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl
      .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-line.cost-sum-base       = ? or    buf_temp-aht-ot-line.cost-sum-rubl       = ? or    buf_temp-aht-ot-line.cost-vat-base       = ? or    buf_temp-aht-ot-line.cost-vat-rubl       = ? or    buf_temp-aht-ot-line.cost-slt-base       = ? or    buf_temp-aht-ot-line.cost-slt-rubl       = ? or    buf_temp-aht-ot-line.cost-road-tax-base  = ? or    buf_temp-aht-ot-line.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-line.cost-excise-base    = ? or    buf_temp-aht-ot-line.cost-excise-rubl    = ? or    buf_temp-aht-ot-line.cost-transport-base = ? or    buf_temp-aht-ot-line.cost-transport-rubl = ? or    buf_temp-aht-ot-line.cost-other-base     = ? or    buf_temp-aht-ot-line.cost-other-rubl     = ? or    buf_temp-aht-ot-line.cost-discnt-base    = ? or    buf_temp-aht-ot-line.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.crsa-sum-base       = ? or    buf_temp-aht-ot-line.crsa-sum-rubl       = ? or    buf_temp-aht-ot-line.crsa-vat-base       = ? or    buf_temp-aht-ot-line.crsa-vat-rubl       = ? or    buf_temp-aht-ot-line.crsa-slt-base       = ? or    buf_temp-aht-ot-line.crsa-slt-rubl       = ? or    buf_temp-aht-ot-line.crsa-road-tax-base  = ? or    buf_temp-aht-ot-line.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-line.crsa-excise-base    = ? or    buf_temp-aht-ot-line.crsa-excise-rubl    = ? or    buf_temp-aht-ot-line.crsa-transport-base = ? or    buf_temp-aht-ot-line.crsa-transport-rubl = ? or    buf_temp-aht-ot-line.crsa-other-base     = ? or    buf_temp-aht-ot-line.crsa-other-rubl     = ? or    buf_temp-aht-ot-line.crsa-discnt-base    = ? or    buf_temp-aht-ot-line.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.sale-sum-base       = ? or    buf_temp-aht-ot-line.sale-sum-rubl       = ? or    buf_temp-aht-ot-line.sale-vat-base       = ? or    buf_temp-aht-ot-line.sale-vat-rubl       = ? or    buf_temp-aht-ot-line.sale-slt-base       = ? or    buf_temp-aht-ot-line.sale-slt-rubl       = ? or    buf_temp-aht-ot-line.sale-road-tax-base  = ? or    buf_temp-aht-ot-line.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-line.sale-excise-base    = ? or    buf_temp-aht-ot-line.sale-excise-rubl    = ? or    buf_temp-aht-ot-line.sale-transport-base = ? or    buf_temp-aht-ot-line.sale-transport-rubl = ? or    buf_temp-aht-ot-line.sale-other-base     = ? or    buf_temp-aht-ot-line.sale-other-rubl     = ? or    buf_temp-aht-ot-line.sale-discnt-base    = ? or    buf_temp-aht-ot-line.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-line.doc-code skip
          "Код товара" buf_temp-aht-ot-line.gds-code skip
          "Тип суммы" buf_temp-aht-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_aht-ot-line exclusive-lock
        where buf_aht-ot-line.doc-code  = buf_temp-aht-ot-line.doc-code
          and buf_aht-ot-line.gds-code  = buf_temp-aht-ot-line.gds-code
          and buf_aht-ot-line.sum-type  = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_aht-ot-line then do:
        create buf_aht-ot-line .
      end.
                  assign
        buf_aht-ot-line.doc-code     = buf_temp-aht-ot-line.doc-code       buf_aht-ot-line.gds-code     = buf_temp-aht-ot-line.gds-code       buf_aht-ot-line.sum-type     = buf_temp-aht-ot-line.sum-type       buf_aht-ot-line.ext-doc-type = buf_temp-aht-ot-line.ext-doc-type   buf_aht-ot-line.obj-type     = buf_temp-aht-ot-line.obj-type       buf_aht-ot-line.obj-code     = buf_temp-aht-ot-line.obj-code       buf_aht-ot-line.fact-order   = buf_temp-aht-ot-line.fact-order
      .
      assign
        buf_aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty
                                                        buf_aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base             buf_aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl             buf_aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base             buf_aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl             buf_aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base             buf_aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl             buf_aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base        buf_aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl        buf_aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base          buf_aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl          buf_aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base       buf_aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl       buf_aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base           buf_aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl           buf_aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base          buf_aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl
                                                        buf_aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base             buf_aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl             buf_aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base             buf_aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl             buf_aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base             buf_aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl             buf_aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base        buf_aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl        buf_aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base          buf_aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl          buf_aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base       buf_aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl       buf_aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base           buf_aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl           buf_aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl
                                                        buf_aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base             buf_aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl             buf_aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base             buf_aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl             buf_aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base             buf_aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl             buf_aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base        buf_aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl        buf_aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base          buf_aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl          buf_aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base       buf_aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl       buf_aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base           buf_aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl           buf_aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base          buf_aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_add-document :
  define input  parameter p-doc-code     like ub.aht-doc.doc-code     no-undo .
  define input  parameter p-obj-type     like ub.aht-doc.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-doc.obj-code     no-undo .
  define input  parameter p-ext-doc-type like ub.aht-doc.ext-doc-type no-undo .
  define input  parameter p-is-trn-doc   like ub.aht-doc.is-trn-doc   no-undo .
  define input  parameter p-fact-order   like ub.aht-doc.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-doc.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-doc.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-doc.shift-num    no-undo .
  define buffer buf_aht-doc for ub.aht-doc .
  do
  on error undo, return error return-value
  :
    find first buf_aht-doc exclusive-lock
      where buf_aht-doc.doc-code = p-doc-code
      no-error .
    if available buf_aht-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Попытка повторного создания записи" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Не задан номер документа" skip
        "Документ" p-doc-code skip
        "Номер документа" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_aht-doc .
    assign
      buf_aht-doc.doc-code     = p-doc-code
      buf_aht-doc.obj-type     = p-obj-type
      buf_aht-doc.obj-code     = p-obj-code
      buf_aht-doc.ext-doc-type = p-ext-doc-type
      buf_aht-doc.is-trn-doc   = p-is-trn-doc
      buf_aht-doc.fact-order   = p-fact-order
      buf_aht-doc.fact-date    = p-fact-date
      buf_aht-doc.shift-date   = p-shift-date
      buf_aht-doc.shift-num    = p-shift-num
    .
  end.
end procedure.
procedure aht_add-date :
  define input  parameter p-obj-type     like ub.aht-stk.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-stk.obj-code     no-undo .
  define input  parameter p-stk-type     like ub.aht-stk.stk-type     no-undo .
  define input  parameter p-fact-order   like ub.aht-stk.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-stk.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-stk.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-stk.shift-num    no-undo .
  define buffer buf_aht-stk for ub.aht-stk .
  do
  on error undo, return error return-value
  :
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.stk-type   = p-stk-type
        and buf_aht-stk.fact-order = p-fact-order
      no-error .
    if not available buf_aht-stk then do:
      create buf_aht-stk .
      assign
        buf_aht-stk.obj-type   = p-obj-type
        buf_aht-stk.obj-code   = p-obj-code
        buf_aht-stk.stk-type   = p-stk-type
        buf_aht-stk.fact-order = p-fact-order
        buf_aht-stk.fact-date  = p-fact-date
        buf_aht-stk.shift-date = p-shift-date
        buf_aht-stk.shift-num  = p-shift-num
      .
    end.
  end.
end procedure.
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
define buffer calc-aht-lock_batchprocess for ub.batchprocess .
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
  define buffer restore-aht-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rsat':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по типам приобретения"
    ,input true
    ,buffer restore-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по типам приобретения" skip
        "Невозможно произвести восстановление складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по типам приобретения" .
  end.
  run gbl/lock-prc.p
    (input 'ahtb':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по типам приобретения" skip
        "Невозможно произвести удаление складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
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
  define variable v-aht-calc          as logical   no-undo .
  define variable v-aht-del           as logical   no-undo .
  define variable v-aht-start-date    as date      no-undo .
  define variable v-aht-detail-date   as date      no-undo .
  define variable v-aht-recalc-date   as date      no-undo .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-calc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-start':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-recalc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-recalc-date = date(v-attr-value)
  .
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .
  assign
    v-month = month(v-aht-detail-date)
    v-year  = year(v-aht-detail-date)
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
      "Дата очистки складского архива не задана" skip
      view-as alert-box information .
    undo, return error .
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .
  define variable v-num as integer   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Выберите способ удаления складского архива по типам приобретения." + chr(10)
          + "Новая дата начала подробного складского архива по типам приобретения " + string(v-new-detail-date, '99/99/9999':u) + chr(10)
          + "Сегодня " + string(v-today, '99/99/9999':u) + chr(10)
    ,input "|^"
    ,input "Удаление подробной информации" + '^confirm|':u
        + "Полная очистка складского архива" + '^confirm|':u
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
        "Ошибка при выборе способа очистки складского архива" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .
  if v-aht-calc = true
  then do:
    message
      "Складкой архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-aht-del = true
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if (v-aht-start-date <> ?
     and v-aht-detail-date = ?)
  or (v-aht-start-date = ?
     and v-aht-detail-date <> ?)
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  v-aht-recalc-date <> ?
  and v-aht-detail-date <> ?
  and v-aht-recalc-date < v-aht-detail-date
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Дата перерасчета складского архива по товарам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "Дата перерасчета складского архива по типам приобретения" string(v-aht-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" v-aht-detail-date skip
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
    if v-aht-start-date <> ?
    then do:
      assign
        v-new-start-date = v-aht-start-date
      .
    end.
    else do:
      run find-aht-start-date in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-new-detail-date
        ,output v-new-start-date
        ) .
    end.
  end.
  run trg/bt_aht.p
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
    v-file-name = 'ahtdel':u
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
    "Последнее предупреждение перед удалением складского архива по типам приобретения." skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по типам приобретения" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по типам приобретения" string(v-new-detail-date, '99/99/9999':u) skip
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
    title "Удаление складского архива по типам приобретения"
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
    ,input v-aht-start-date
    ,input v-aht-detail-date
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
  run trg/ahtclr.p
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
      "Ошибка при cохранении складского архива по типам приобретения"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-aht-start-date
    ,input v-aht-detail-date
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
    ,input  'aht':U
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
   v-err = substitute("Ошибка при блокировке смены на объекте &2&3 дата &1" , v-archive-date, v-obj-type , v-obj-code ) .
   run create-log-err in this-procedure
      ( v-obj-type  ,
        v-obj-code  ,
        v-file-name ,
        v-err ).
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
      ,input 'aht-start':U
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
      ,input 'aht-detail':U
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
      ,input 'aht-rest':U
      ,input 'true':u
      ) .
  end.
  find current calc-aht-lock_batchprocess no-lock .
  if v-clear-archive = true
  then do:
    run ahrstutl-clear-aht in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-archive-date
      ) .
  end.
  else do:
    run utl/cmpraht.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении складского архива по товару" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  define variable v-delete-attr-aht-del as logical   no-undo .
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input 'aht-rest':U
    ,output v-delete-attr-aht-del
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
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Удаление складского архива успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив на основании файла" skip
    "На объекте существует складской архив по типам приобретения с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существуют подробный складской архив по типам приобретения с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.
procedure create-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-aht-start-date  as date      no-undo .
  define input  parameter p-aht-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-aht-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-aht-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.
end procedure.
procedure close-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-aht-start-date  as date      no-undo .
  define input  parameter p-aht-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-aht-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-aht-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.
end procedure.
procedure find-aht-start-date :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-new-start-date = p-new-detail-date
    .
    define buffer buf_aht-stk for ub.aht-stk .
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type  = p-obj-type
        and buf_aht-stk.obj-code  = p-obj-code
        and buf_aht-stk.stk-type  = 'n':U
      use-index pi
      no-error .
    if  available buf_aht-stk
    and buf_aht-stk.fact-date < p-new-start-date
    then do:
      assign
        p-new-start-date = buf_aht-stk.fact-date
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
procedure ahrstutl-init :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
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
        ,input v-day-end-fact-order
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
          ,input buf_gds-obj.gds-code
          ,input entry(v-ind, v-sum-type-list)
          ,input v-day-end-fact-order
          ) .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-tot :
  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-sum-type                 as character no-undo .
  define input  parameter p-aht-stk-tot-fact-order   as decimal   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.sum-type   = p-sum-type
        and buf_aht-stk-tot.fact-order <= p-aht-stk-tot-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-tot
    and buf_aht-stk-tot.fact-order <> p-aht-stk-tot-fact-order
    then do:
      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = p-aht-stk-tot-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_aht-stk-tot.sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
                              buf_temp-aht-stk-tot.obj-type     = buf_aht-stk-tot.obj-type     buf_temp-aht-stk-tot.obj-code     = buf_aht-stk-tot.obj-code     buf_temp-aht-stk-tot.fact-order   = buf_aht-stk-tot.fact-order   buf_temp-aht-stk-tot.sum-type     = buf_aht-stk-tot.sum-type
          buf_temp-aht-stk-tot.fact-order = p-aht-stk-tot-fact-order
        .
      end.
      assign
        buf_temp-aht-stk-tot.fact-qnty = buf_temp-aht-stk-tot.fact-qnty
                                       + buf_aht-stk-tot.fact-qnty
                                                                        buf_temp-aht-stk-tot.cost-sum-base       = buf_temp-aht-stk-tot.cost-sum-base       + buf_aht-stk-tot.cost-sum-base            buf_temp-aht-stk-tot.cost-sum-rubl       = buf_temp-aht-stk-tot.cost-sum-rubl       + buf_aht-stk-tot.cost-sum-rubl            buf_temp-aht-stk-tot.cost-vat-base       = buf_temp-aht-stk-tot.cost-vat-base       + buf_aht-stk-tot.cost-vat-base            buf_temp-aht-stk-tot.cost-vat-rubl       = buf_temp-aht-stk-tot.cost-vat-rubl       + buf_aht-stk-tot.cost-vat-rubl            buf_temp-aht-stk-tot.cost-slt-base       = buf_temp-aht-stk-tot.cost-slt-base       + buf_aht-stk-tot.cost-slt-base            buf_temp-aht-stk-tot.cost-slt-rubl       = buf_temp-aht-stk-tot.cost-slt-rubl       + buf_aht-stk-tot.cost-slt-rubl            buf_temp-aht-stk-tot.cost-road-tax-base  = buf_temp-aht-stk-tot.cost-road-tax-base  + buf_aht-stk-tot.cost-road-tax-base       buf_temp-aht-stk-tot.cost-road-tax-rubl  = buf_temp-aht-stk-tot.cost-road-tax-rubl  + buf_aht-stk-tot.cost-road-tax-rubl       buf_temp-aht-stk-tot.cost-excise-base    = buf_temp-aht-stk-tot.cost-excise-base    + buf_aht-stk-tot.cost-excise-base         buf_temp-aht-stk-tot.cost-excise-rubl    = buf_temp-aht-stk-tot.cost-excise-rubl    + buf_aht-stk-tot.cost-excise-rubl         buf_temp-aht-stk-tot.cost-transport-base = buf_temp-aht-stk-tot.cost-transport-base + buf_aht-stk-tot.cost-transport-base      buf_temp-aht-stk-tot.cost-transport-rubl = buf_temp-aht-stk-tot.cost-transport-rubl + buf_aht-stk-tot.cost-transport-rubl      buf_temp-aht-stk-tot.cost-other-base     = buf_temp-aht-stk-tot.cost-other-base     + buf_aht-stk-tot.cost-other-base          buf_temp-aht-stk-tot.cost-other-rubl     = buf_temp-aht-stk-tot.cost-other-rubl     + buf_aht-stk-tot.cost-other-rubl          buf_temp-aht-stk-tot.cost-discnt-base    = buf_temp-aht-stk-tot.cost-discnt-base    + buf_aht-stk-tot.cost-discnt-base          buf_temp-aht-stk-tot.cost-discnt-rubl    = buf_temp-aht-stk-tot.cost-discnt-rubl    + buf_aht-stk-tot.cost-discnt-rubl
                                                                        buf_temp-aht-stk-tot.crsa-sum-base       = buf_temp-aht-stk-tot.crsa-sum-base       + buf_aht-stk-tot.crsa-sum-base            buf_temp-aht-stk-tot.crsa-sum-rubl       = buf_temp-aht-stk-tot.crsa-sum-rubl       + buf_aht-stk-tot.crsa-sum-rubl            buf_temp-aht-stk-tot.crsa-vat-base       = buf_temp-aht-stk-tot.crsa-vat-base       + buf_aht-stk-tot.crsa-vat-base            buf_temp-aht-stk-tot.crsa-vat-rubl       = buf_temp-aht-stk-tot.crsa-vat-rubl       + buf_aht-stk-tot.crsa-vat-rubl            buf_temp-aht-stk-tot.crsa-slt-base       = buf_temp-aht-stk-tot.crsa-slt-base       + buf_aht-stk-tot.crsa-slt-base            buf_temp-aht-stk-tot.crsa-slt-rubl       = buf_temp-aht-stk-tot.crsa-slt-rubl       + buf_aht-stk-tot.crsa-slt-rubl            buf_temp-aht-stk-tot.crsa-road-tax-base  = buf_temp-aht-stk-tot.crsa-road-tax-base  + buf_aht-stk-tot.crsa-road-tax-base       buf_temp-aht-stk-tot.crsa-road-tax-rubl  = buf_temp-aht-stk-tot.crsa-road-tax-rubl  + buf_aht-stk-tot.crsa-road-tax-rubl       buf_temp-aht-stk-tot.crsa-excise-base    = buf_temp-aht-stk-tot.crsa-excise-base    + buf_aht-stk-tot.crsa-excise-base         buf_temp-aht-stk-tot.crsa-excise-rubl    = buf_temp-aht-stk-tot.crsa-excise-rubl    + buf_aht-stk-tot.crsa-excise-rubl         buf_temp-aht-stk-tot.crsa-transport-base = buf_temp-aht-stk-tot.crsa-transport-base + buf_aht-stk-tot.crsa-transport-base      buf_temp-aht-stk-tot.crsa-transport-rubl = buf_temp-aht-stk-tot.crsa-transport-rubl + buf_aht-stk-tot.crsa-transport-rubl      buf_temp-aht-stk-tot.crsa-other-base     = buf_temp-aht-stk-tot.crsa-other-base     + buf_aht-stk-tot.crsa-other-base          buf_temp-aht-stk-tot.crsa-other-rubl     = buf_temp-aht-stk-tot.crsa-other-rubl     + buf_aht-stk-tot.crsa-other-rubl          buf_temp-aht-stk-tot.crsa-discnt-base    = buf_temp-aht-stk-tot.crsa-discnt-base    + buf_aht-stk-tot.crsa-discnt-base          buf_temp-aht-stk-tot.crsa-discnt-rubl    = buf_temp-aht-stk-tot.crsa-discnt-rubl    + buf_aht-stk-tot.crsa-discnt-rubl
                                                                        buf_temp-aht-stk-tot.sale-sum-base       = buf_temp-aht-stk-tot.sale-sum-base       + buf_aht-stk-tot.sale-sum-base            buf_temp-aht-stk-tot.sale-sum-rubl       = buf_temp-aht-stk-tot.sale-sum-rubl       + buf_aht-stk-tot.sale-sum-rubl            buf_temp-aht-stk-tot.sale-vat-base       = buf_temp-aht-stk-tot.sale-vat-base       + buf_aht-stk-tot.sale-vat-base            buf_temp-aht-stk-tot.sale-vat-rubl       = buf_temp-aht-stk-tot.sale-vat-rubl       + buf_aht-stk-tot.sale-vat-rubl            buf_temp-aht-stk-tot.sale-slt-base       = buf_temp-aht-stk-tot.sale-slt-base       + buf_aht-stk-tot.sale-slt-base            buf_temp-aht-stk-tot.sale-slt-rubl       = buf_temp-aht-stk-tot.sale-slt-rubl       + buf_aht-stk-tot.sale-slt-rubl            buf_temp-aht-stk-tot.sale-road-tax-base  = buf_temp-aht-stk-tot.sale-road-tax-base  + buf_aht-stk-tot.sale-road-tax-base       buf_temp-aht-stk-tot.sale-road-tax-rubl  = buf_temp-aht-stk-tot.sale-road-tax-rubl  + buf_aht-stk-tot.sale-road-tax-rubl       buf_temp-aht-stk-tot.sale-excise-base    = buf_temp-aht-stk-tot.sale-excise-base    + buf_aht-stk-tot.sale-excise-base         buf_temp-aht-stk-tot.sale-excise-rubl    = buf_temp-aht-stk-tot.sale-excise-rubl    + buf_aht-stk-tot.sale-excise-rubl         buf_temp-aht-stk-tot.sale-transport-base = buf_temp-aht-stk-tot.sale-transport-base + buf_aht-stk-tot.sale-transport-base      buf_temp-aht-stk-tot.sale-transport-rubl = buf_temp-aht-stk-tot.sale-transport-rubl + buf_aht-stk-tot.sale-transport-rubl      buf_temp-aht-stk-tot.sale-other-base     = buf_temp-aht-stk-tot.sale-other-base     + buf_aht-stk-tot.sale-other-base          buf_temp-aht-stk-tot.sale-other-rubl     = buf_temp-aht-stk-tot.sale-other-rubl     + buf_aht-stk-tot.sale-other-rubl          buf_temp-aht-stk-tot.sale-discnt-base    = buf_temp-aht-stk-tot.sale-discnt-base    + buf_aht-stk-tot.sale-discnt-base          buf_temp-aht-stk-tot.sale-discnt-rubl    = buf_temp-aht-stk-tot.sale-discnt-rubl    + buf_aht-stk-tot.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure ahrstutl-init-line :
  define input  parameter p-obj-type                as character no-undo .
  define input  parameter p-obj-code                as integer   no-undo .
  define input  parameter p-gds-code                as integer   no-undo .
  define input  parameter p-sum-type                as character no-undo .
  define input  parameter p-aht-stk-line-fact-order as decimal   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.gds-code   = p-gds-code
        and buf_aht-stk-line.sum-type   = p-sum-type
        and buf_aht-stk-line.fact-order <= p-aht-stk-line-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-line
    and buf_aht-stk-line.fact-order <> p-aht-stk-line-fact-order
    then do:
      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = p-aht-stk-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
                              buf_temp-aht-stk-line.obj-type     = buf_aht-stk-line.obj-type     buf_temp-aht-stk-line.obj-code     = buf_aht-stk-line.obj-code     buf_temp-aht-stk-line.gds-code     = buf_aht-stk-line.gds-code     buf_temp-aht-stk-line.fact-order   = buf_aht-stk-line.fact-order   buf_temp-aht-stk-line.sum-type     = buf_aht-stk-line.sum-type
          buf_temp-aht-stk-line.fact-order = p-aht-stk-line-fact-order
        .
      end.
      assign
        buf_temp-aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
                                        + buf_aht-stk-line.fact-qnty
                                                                        buf_temp-aht-stk-line.cost-sum-base       = buf_temp-aht-stk-line.cost-sum-base       + buf_aht-stk-line.cost-sum-base            buf_temp-aht-stk-line.cost-sum-rubl       = buf_temp-aht-stk-line.cost-sum-rubl       + buf_aht-stk-line.cost-sum-rubl            buf_temp-aht-stk-line.cost-vat-base       = buf_temp-aht-stk-line.cost-vat-base       + buf_aht-stk-line.cost-vat-base            buf_temp-aht-stk-line.cost-vat-rubl       = buf_temp-aht-stk-line.cost-vat-rubl       + buf_aht-stk-line.cost-vat-rubl            buf_temp-aht-stk-line.cost-slt-base       = buf_temp-aht-stk-line.cost-slt-base       + buf_aht-stk-line.cost-slt-base            buf_temp-aht-stk-line.cost-slt-rubl       = buf_temp-aht-stk-line.cost-slt-rubl       + buf_aht-stk-line.cost-slt-rubl            buf_temp-aht-stk-line.cost-road-tax-base  = buf_temp-aht-stk-line.cost-road-tax-base  + buf_aht-stk-line.cost-road-tax-base       buf_temp-aht-stk-line.cost-road-tax-rubl  = buf_temp-aht-stk-line.cost-road-tax-rubl  + buf_aht-stk-line.cost-road-tax-rubl       buf_temp-aht-stk-line.cost-excise-base    = buf_temp-aht-stk-line.cost-excise-base    + buf_aht-stk-line.cost-excise-base         buf_temp-aht-stk-line.cost-excise-rubl    = buf_temp-aht-stk-line.cost-excise-rubl    + buf_aht-stk-line.cost-excise-rubl         buf_temp-aht-stk-line.cost-transport-base = buf_temp-aht-stk-line.cost-transport-base + buf_aht-stk-line.cost-transport-base      buf_temp-aht-stk-line.cost-transport-rubl = buf_temp-aht-stk-line.cost-transport-rubl + buf_aht-stk-line.cost-transport-rubl      buf_temp-aht-stk-line.cost-other-base     = buf_temp-aht-stk-line.cost-other-base     + buf_aht-stk-line.cost-other-base          buf_temp-aht-stk-line.cost-other-rubl     = buf_temp-aht-stk-line.cost-other-rubl     + buf_aht-stk-line.cost-other-rubl          buf_temp-aht-stk-line.cost-discnt-base    = buf_temp-aht-stk-line.cost-discnt-base    + buf_aht-stk-line.cost-discnt-base          buf_temp-aht-stk-line.cost-discnt-rubl    = buf_temp-aht-stk-line.cost-discnt-rubl    + buf_aht-stk-line.cost-discnt-rubl
                                                                        buf_temp-aht-stk-line.crsa-sum-base       = buf_temp-aht-stk-line.crsa-sum-base       + buf_aht-stk-line.crsa-sum-base            buf_temp-aht-stk-line.crsa-sum-rubl       = buf_temp-aht-stk-line.crsa-sum-rubl       + buf_aht-stk-line.crsa-sum-rubl            buf_temp-aht-stk-line.crsa-vat-base       = buf_temp-aht-stk-line.crsa-vat-base       + buf_aht-stk-line.crsa-vat-base            buf_temp-aht-stk-line.crsa-vat-rubl       = buf_temp-aht-stk-line.crsa-vat-rubl       + buf_aht-stk-line.crsa-vat-rubl            buf_temp-aht-stk-line.crsa-slt-base       = buf_temp-aht-stk-line.crsa-slt-base       + buf_aht-stk-line.crsa-slt-base            buf_temp-aht-stk-line.crsa-slt-rubl       = buf_temp-aht-stk-line.crsa-slt-rubl       + buf_aht-stk-line.crsa-slt-rubl            buf_temp-aht-stk-line.crsa-road-tax-base  = buf_temp-aht-stk-line.crsa-road-tax-base  + buf_aht-stk-line.crsa-road-tax-base       buf_temp-aht-stk-line.crsa-road-tax-rubl  = buf_temp-aht-stk-line.crsa-road-tax-rubl  + buf_aht-stk-line.crsa-road-tax-rubl       buf_temp-aht-stk-line.crsa-excise-base    = buf_temp-aht-stk-line.crsa-excise-base    + buf_aht-stk-line.crsa-excise-base         buf_temp-aht-stk-line.crsa-excise-rubl    = buf_temp-aht-stk-line.crsa-excise-rubl    + buf_aht-stk-line.crsa-excise-rubl         buf_temp-aht-stk-line.crsa-transport-base = buf_temp-aht-stk-line.crsa-transport-base + buf_aht-stk-line.crsa-transport-base      buf_temp-aht-stk-line.crsa-transport-rubl = buf_temp-aht-stk-line.crsa-transport-rubl + buf_aht-stk-line.crsa-transport-rubl      buf_temp-aht-stk-line.crsa-other-base     = buf_temp-aht-stk-line.crsa-other-base     + buf_aht-stk-line.crsa-other-base          buf_temp-aht-stk-line.crsa-other-rubl     = buf_temp-aht-stk-line.crsa-other-rubl     + buf_aht-stk-line.crsa-other-rubl          buf_temp-aht-stk-line.crsa-discnt-base    = buf_temp-aht-stk-line.crsa-discnt-base    + buf_aht-stk-line.crsa-discnt-base          buf_temp-aht-stk-line.crsa-discnt-rubl    = buf_temp-aht-stk-line.crsa-discnt-rubl    + buf_aht-stk-line.crsa-discnt-rubl
                                                                        buf_temp-aht-stk-line.sale-sum-base       = buf_temp-aht-stk-line.sale-sum-base       + buf_aht-stk-line.sale-sum-base            buf_temp-aht-stk-line.sale-sum-rubl       = buf_temp-aht-stk-line.sale-sum-rubl       + buf_aht-stk-line.sale-sum-rubl            buf_temp-aht-stk-line.sale-vat-base       = buf_temp-aht-stk-line.sale-vat-base       + buf_aht-stk-line.sale-vat-base            buf_temp-aht-stk-line.sale-vat-rubl       = buf_temp-aht-stk-line.sale-vat-rubl       + buf_aht-stk-line.sale-vat-rubl            buf_temp-aht-stk-line.sale-slt-base       = buf_temp-aht-stk-line.sale-slt-base       + buf_aht-stk-line.sale-slt-base            buf_temp-aht-stk-line.sale-slt-rubl       = buf_temp-aht-stk-line.sale-slt-rubl       + buf_aht-stk-line.sale-slt-rubl            buf_temp-aht-stk-line.sale-road-tax-base  = buf_temp-aht-stk-line.sale-road-tax-base  + buf_aht-stk-line.sale-road-tax-base       buf_temp-aht-stk-line.sale-road-tax-rubl  = buf_temp-aht-stk-line.sale-road-tax-rubl  + buf_aht-stk-line.sale-road-tax-rubl       buf_temp-aht-stk-line.sale-excise-base    = buf_temp-aht-stk-line.sale-excise-base    + buf_aht-stk-line.sale-excise-base         buf_temp-aht-stk-line.sale-excise-rubl    = buf_temp-aht-stk-line.sale-excise-rubl    + buf_aht-stk-line.sale-excise-rubl         buf_temp-aht-stk-line.sale-transport-base = buf_temp-aht-stk-line.sale-transport-base + buf_aht-stk-line.sale-transport-base      buf_temp-aht-stk-line.sale-transport-rubl = buf_temp-aht-stk-line.sale-transport-rubl + buf_aht-stk-line.sale-transport-rubl      buf_temp-aht-stk-line.sale-other-base     = buf_temp-aht-stk-line.sale-other-base     + buf_aht-stk-line.sale-other-base          buf_temp-aht-stk-line.sale-other-rubl     = buf_temp-aht-stk-line.sale-other-rubl     + buf_aht-stk-line.sale-other-rubl          buf_temp-aht-stk-line.sale-discnt-base    = buf_temp-aht-stk-line.sale-discnt-base    + buf_aht-stk-line.sale-discnt-base          buf_temp-aht-stk-line.sale-discnt-rubl    = buf_temp-aht-stk-line.sale-discnt-rubl    + buf_aht-stk-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure ahrstutl-store :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define buffer buf_temp-aht-stk-tot  for temp-aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-tot       for ub.aht-stk-tot .
  define buffer buf_aht-stk-line      for ub.aht-stk-line .
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
    for each buf_temp-aht-stk-tot
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
       create buf_aht-stk-tot .
      assign
                        buf_aht-stk-tot.obj-type     = buf_temp-aht-stk-tot.obj-type     buf_aht-stk-tot.obj-code     = buf_temp-aht-stk-tot.obj-code     buf_aht-stk-tot.fact-order   = buf_temp-aht-stk-tot.fact-order   buf_aht-stk-tot.sum-type     = buf_temp-aht-stk-tot.sum-type
        buf_aht-stk-tot.fact-qnty = buf_temp-aht-stk-tot.fact-qnty
                                                        buf_aht-stk-tot.cost-sum-base       = buf_temp-aht-stk-tot.cost-sum-base             buf_aht-stk-tot.cost-sum-rubl       = buf_temp-aht-stk-tot.cost-sum-rubl             buf_aht-stk-tot.cost-vat-base       = buf_temp-aht-stk-tot.cost-vat-base             buf_aht-stk-tot.cost-vat-rubl       = buf_temp-aht-stk-tot.cost-vat-rubl             buf_aht-stk-tot.cost-slt-base       = buf_temp-aht-stk-tot.cost-slt-base             buf_aht-stk-tot.cost-slt-rubl       = buf_temp-aht-stk-tot.cost-slt-rubl             buf_aht-stk-tot.cost-road-tax-base  = buf_temp-aht-stk-tot.cost-road-tax-base        buf_aht-stk-tot.cost-road-tax-rubl  = buf_temp-aht-stk-tot.cost-road-tax-rubl        buf_aht-stk-tot.cost-excise-base    = buf_temp-aht-stk-tot.cost-excise-base          buf_aht-stk-tot.cost-excise-rubl    = buf_temp-aht-stk-tot.cost-excise-rubl          buf_aht-stk-tot.cost-transport-base = buf_temp-aht-stk-tot.cost-transport-base       buf_aht-stk-tot.cost-transport-rubl = buf_temp-aht-stk-tot.cost-transport-rubl       buf_aht-stk-tot.cost-other-base     = buf_temp-aht-stk-tot.cost-other-base           buf_aht-stk-tot.cost-other-rubl     = buf_temp-aht-stk-tot.cost-other-rubl           buf_aht-stk-tot.cost-discnt-base    = buf_temp-aht-stk-tot.cost-discnt-base          buf_aht-stk-tot.cost-discnt-rubl    = buf_temp-aht-stk-tot.cost-discnt-rubl
                                                        buf_aht-stk-tot.crsa-sum-base       = buf_temp-aht-stk-tot.crsa-sum-base             buf_aht-stk-tot.crsa-sum-rubl       = buf_temp-aht-stk-tot.crsa-sum-rubl             buf_aht-stk-tot.crsa-vat-base       = buf_temp-aht-stk-tot.crsa-vat-base             buf_aht-stk-tot.crsa-vat-rubl       = buf_temp-aht-stk-tot.crsa-vat-rubl             buf_aht-stk-tot.crsa-slt-base       = buf_temp-aht-stk-tot.crsa-slt-base             buf_aht-stk-tot.crsa-slt-rubl       = buf_temp-aht-stk-tot.crsa-slt-rubl             buf_aht-stk-tot.crsa-road-tax-base  = buf_temp-aht-stk-tot.crsa-road-tax-base        buf_aht-stk-tot.crsa-road-tax-rubl  = buf_temp-aht-stk-tot.crsa-road-tax-rubl        buf_aht-stk-tot.crsa-excise-base    = buf_temp-aht-stk-tot.crsa-excise-base          buf_aht-stk-tot.crsa-excise-rubl    = buf_temp-aht-stk-tot.crsa-excise-rubl          buf_aht-stk-tot.crsa-transport-base = buf_temp-aht-stk-tot.crsa-transport-base       buf_aht-stk-tot.crsa-transport-rubl = buf_temp-aht-stk-tot.crsa-transport-rubl       buf_aht-stk-tot.crsa-other-base     = buf_temp-aht-stk-tot.crsa-other-base           buf_aht-stk-tot.crsa-other-rubl     = buf_temp-aht-stk-tot.crsa-other-rubl           buf_aht-stk-tot.crsa-discnt-base    = buf_temp-aht-stk-tot.crsa-discnt-base          buf_aht-stk-tot.crsa-discnt-rubl    = buf_temp-aht-stk-tot.crsa-discnt-rubl
                                                        buf_aht-stk-tot.sale-sum-base       = buf_temp-aht-stk-tot.sale-sum-base             buf_aht-stk-tot.sale-sum-rubl       = buf_temp-aht-stk-tot.sale-sum-rubl             buf_aht-stk-tot.sale-vat-base       = buf_temp-aht-stk-tot.sale-vat-base             buf_aht-stk-tot.sale-vat-rubl       = buf_temp-aht-stk-tot.sale-vat-rubl             buf_aht-stk-tot.sale-slt-base       = buf_temp-aht-stk-tot.sale-slt-base             buf_aht-stk-tot.sale-slt-rubl       = buf_temp-aht-stk-tot.sale-slt-rubl             buf_aht-stk-tot.sale-road-tax-base  = buf_temp-aht-stk-tot.sale-road-tax-base        buf_aht-stk-tot.sale-road-tax-rubl  = buf_temp-aht-stk-tot.sale-road-tax-rubl        buf_aht-stk-tot.sale-excise-base    = buf_temp-aht-stk-tot.sale-excise-base          buf_aht-stk-tot.sale-excise-rubl    = buf_temp-aht-stk-tot.sale-excise-rubl          buf_aht-stk-tot.sale-transport-base = buf_temp-aht-stk-tot.sale-transport-base       buf_aht-stk-tot.sale-transport-rubl = buf_temp-aht-stk-tot.sale-transport-rubl       buf_aht-stk-tot.sale-other-base     = buf_temp-aht-stk-tot.sale-other-base           buf_aht-stk-tot.sale-other-rubl     = buf_temp-aht-stk-tot.sale-other-rubl           buf_aht-stk-tot.sale-discnt-base    = buf_temp-aht-stk-tot.sale-discnt-base          buf_aht-stk-tot.sale-discnt-rubl    = buf_temp-aht-stk-tot.sale-discnt-rubl
      .
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-aht-stk-line
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара" + string(buf_temp-aht-stk-line.gds-code)
          ).
      end.
      create buf_aht-stk-line .
      assign
                        buf_aht-stk-line.obj-type     = buf_temp-aht-stk-line.obj-type     buf_aht-stk-line.obj-code     = buf_temp-aht-stk-line.obj-code     buf_aht-stk-line.gds-code     = buf_temp-aht-stk-line.gds-code     buf_aht-stk-line.fact-order   = buf_temp-aht-stk-line.fact-order   buf_aht-stk-line.sum-type     = buf_temp-aht-stk-line.sum-type
        buf_aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
                                                        buf_aht-stk-line.cost-sum-base       = buf_temp-aht-stk-line.cost-sum-base             buf_aht-stk-line.cost-sum-rubl       = buf_temp-aht-stk-line.cost-sum-rubl             buf_aht-stk-line.cost-vat-base       = buf_temp-aht-stk-line.cost-vat-base             buf_aht-stk-line.cost-vat-rubl       = buf_temp-aht-stk-line.cost-vat-rubl             buf_aht-stk-line.cost-slt-base       = buf_temp-aht-stk-line.cost-slt-base             buf_aht-stk-line.cost-slt-rubl       = buf_temp-aht-stk-line.cost-slt-rubl             buf_aht-stk-line.cost-road-tax-base  = buf_temp-aht-stk-line.cost-road-tax-base        buf_aht-stk-line.cost-road-tax-rubl  = buf_temp-aht-stk-line.cost-road-tax-rubl        buf_aht-stk-line.cost-excise-base    = buf_temp-aht-stk-line.cost-excise-base          buf_aht-stk-line.cost-excise-rubl    = buf_temp-aht-stk-line.cost-excise-rubl          buf_aht-stk-line.cost-transport-base = buf_temp-aht-stk-line.cost-transport-base       buf_aht-stk-line.cost-transport-rubl = buf_temp-aht-stk-line.cost-transport-rubl       buf_aht-stk-line.cost-other-base     = buf_temp-aht-stk-line.cost-other-base           buf_aht-stk-line.cost-other-rubl     = buf_temp-aht-stk-line.cost-other-rubl           buf_aht-stk-line.cost-discnt-base    = buf_temp-aht-stk-line.cost-discnt-base          buf_aht-stk-line.cost-discnt-rubl    = buf_temp-aht-stk-line.cost-discnt-rubl
                                                        buf_aht-stk-line.crsa-sum-base       = buf_temp-aht-stk-line.crsa-sum-base             buf_aht-stk-line.crsa-sum-rubl       = buf_temp-aht-stk-line.crsa-sum-rubl             buf_aht-stk-line.crsa-vat-base       = buf_temp-aht-stk-line.crsa-vat-base             buf_aht-stk-line.crsa-vat-rubl       = buf_temp-aht-stk-line.crsa-vat-rubl             buf_aht-stk-line.crsa-slt-base       = buf_temp-aht-stk-line.crsa-slt-base             buf_aht-stk-line.crsa-slt-rubl       = buf_temp-aht-stk-line.crsa-slt-rubl             buf_aht-stk-line.crsa-road-tax-base  = buf_temp-aht-stk-line.crsa-road-tax-base        buf_aht-stk-line.crsa-road-tax-rubl  = buf_temp-aht-stk-line.crsa-road-tax-rubl        buf_aht-stk-line.crsa-excise-base    = buf_temp-aht-stk-line.crsa-excise-base          buf_aht-stk-line.crsa-excise-rubl    = buf_temp-aht-stk-line.crsa-excise-rubl          buf_aht-stk-line.crsa-transport-base = buf_temp-aht-stk-line.crsa-transport-base       buf_aht-stk-line.crsa-transport-rubl = buf_temp-aht-stk-line.crsa-transport-rubl       buf_aht-stk-line.crsa-other-base     = buf_temp-aht-stk-line.crsa-other-base           buf_aht-stk-line.crsa-other-rubl     = buf_temp-aht-stk-line.crsa-other-rubl           buf_aht-stk-line.crsa-discnt-base    = buf_temp-aht-stk-line.crsa-discnt-base          buf_aht-stk-line.crsa-discnt-rubl    = buf_temp-aht-stk-line.crsa-discnt-rubl
                                                        buf_aht-stk-line.sale-sum-base       = buf_temp-aht-stk-line.sale-sum-base             buf_aht-stk-line.sale-sum-rubl       = buf_temp-aht-stk-line.sale-sum-rubl             buf_aht-stk-line.sale-vat-base       = buf_temp-aht-stk-line.sale-vat-base             buf_aht-stk-line.sale-vat-rubl       = buf_temp-aht-stk-line.sale-vat-rubl             buf_aht-stk-line.sale-slt-base       = buf_temp-aht-stk-line.sale-slt-base             buf_aht-stk-line.sale-slt-rubl       = buf_temp-aht-stk-line.sale-slt-rubl             buf_aht-stk-line.sale-road-tax-base  = buf_temp-aht-stk-line.sale-road-tax-base        buf_aht-stk-line.sale-road-tax-rubl  = buf_temp-aht-stk-line.sale-road-tax-rubl        buf_aht-stk-line.sale-excise-base    = buf_temp-aht-stk-line.sale-excise-base          buf_aht-stk-line.sale-excise-rubl    = buf_temp-aht-stk-line.sale-excise-rubl          buf_aht-stk-line.sale-transport-base = buf_temp-aht-stk-line.sale-transport-base       buf_aht-stk-line.sale-transport-rubl = buf_temp-aht-stk-line.sale-transport-rubl       buf_aht-stk-line.sale-other-base     = buf_temp-aht-stk-line.sale-other-base           buf_aht-stk-line.sale-other-rubl     = buf_temp-aht-stk-line.sale-other-rubl           buf_aht-stk-line.sale-discnt-base    = buf_temp-aht-stk-line.sale-discnt-base          buf_aht-stk-line.sale-discnt-rubl    = buf_temp-aht-stk-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure ahrstutl-clear-aht :
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .
  define buffer buf_aht-ot-tot   for ub.aht-ot-tot .
  define buffer buf_aht-ot-line  for ub.aht-ot-line .
  define buffer buf_aht-stk-tot  for ub.aht-stk-tot .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
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
    for each buf_aht-ot-tot
      where buf_aht-ot-tot.obj-type   = p-obj-type
        and buf_aht-ot-tot.obj-code   = p-obj-code
        and buf_aht-ot-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-tot.doc-code)
          ).
      end.
      delete buf_aht-ot-tot .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-ot-line
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-line.doc-code)
                  + " Код товара " + string(buf_aht-ot-line.gds-code)
          ).
      end.
      delete buf_aht-ot-line .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-stk-tot
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        define variable v-fact-date as date      no-undo .
        run factord-to-date in this-procedure
          (input  buf_aht-stk-tot.fact-order
          ,output v-fact-date
          ) .
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(v-fact-date, '99/99/9999':U )
          ).
      end.
      delete buf_aht-stk-tot .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-stk-line
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Код товара " + string(buf_aht-stk-line.gds-code)
          ).
      end.
      delete buf_aht-stk-line .
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
      p-sum-type-list =                 'r':U
                      + chr(44) + 'c':U
                      + chr(44) + 'b':U
                      + chr(44) + 's':U
                      + chr(44) + 'o':U
                      + chr(44) + 'v':U
    .
    define variable v-ext-sum-type as character no-undo .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  'r':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'c':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'b':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  's':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'o':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'v':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
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
    assign
      p-sum-type-list =                 'r':U
                      + chr(44) + 'c':U
                      + chr(44) + 'b':U
                      + chr(44) + 's':U
                      + chr(44) + 'o':U
                      + chr(44) + 'v':U
    .
    define variable v-ext-sum-type as character no-undo .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  'r':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'c':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'b':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  's':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'o':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'v':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
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
