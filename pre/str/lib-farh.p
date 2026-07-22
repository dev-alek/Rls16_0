block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 174449d8c587, 3618, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lib-farh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/lib-farh.p $":U .
define variable vss-description as character no-undo init "Библиотека для работы с финансовыми архивами".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
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
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
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
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
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
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
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
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
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
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
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
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
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
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
define new global shared variable g#lib-farh as handle no-undo .
define new global shared variable g#libfarhp as handle no-undo .
if (valid-handle(g#libfarhp) <> true) then do:   run str/libfarhp.p persistent no-error .   if error-status :error or (valid-handle(g#libfarhp) <> true) then do:     message       "Error starting libfarhp.p" skip       g#libfarhp skip       g#libfarhp :type skip       g#libfarhp :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
define new global shared variable g#libfarpo as handle no-undo .
if (valid-handle(g#libfarpo) <> true) then do:   run str/libfarpo.p persistent no-error .   if error-status :error or (valid-handle(g#libfarpo) <> true) then do:     message       "Error starting libfarpo.p" skip       g#libfarpo skip       g#libfarpo :type skip       g#libfarpo :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle (g#lib-farh)
and g#lib-farh <> this-procedure :handle
and g#lib-farh :get-signature('lib-farh_crfdsclk':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с финансовыми архивами" skip
    g#lib-farh skip
    g#lib-farh :type skip
    g#lib-farh :file-name skip
    valid-handle(g#lib-farh) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-farh = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#lib-farh = ?
  .
end.
define stream str-err.
procedure lib-farh_crfdsclk :
define input parameter parhost-code    like ub.fin-doc-schet-lk.host-code    no-undo.
define input parameter parcode-schet   like ub.fin-doc-schet-lk.code-schet   no-undo.
define input parameter paruser-name    like ub.fin-doc-schet-lk.user-name    no-undo.
define input parameter parfin-doc-code like ub.fin-doc-schet-lk.fin-doc-code no-undo.
define input parameter partype-lock    like ub.fin-doc-schet-lk.type-lock    no-undo.
define input parameter pardate-lock    like ub.fin-doc-schet-lk.date-lock    no-undo.
define input parameter partime-lock    like ub.fin-doc-schet-lk.time-lock    no-undo.
define buffer bf_fin-doc-schet-lk for ub.fin-doc-schet-lk.
do on error undo, return error return-value :
find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = parhost-code  and
                                     bf_fin-doc-schet-lk.code-schet = parcode-schet no-lock no-error.
if not available bf_fin-doc-schet-lk then do:
  create bf_fin-doc-schet-lk.
  assign
    bf_fin-doc-schet-lk.host-code     = parhost-code
    bf_fin-doc-schet-lk.code-schet    = parcode-schet
    bf_fin-doc-schet-lk.user-name     = paruser-name
    bf_fin-doc-schet-lk.fin-doc-code  = parfin-doc-code
    bf_fin-doc-schet-lk.type-lock     = partype-lock
    bf_fin-doc-schet-lk.date-lock     = pardate-lock
    bf_fin-doc-schet-lk.time-lock     = partime-lock    .
end.
end.
end procedure.
procedure lib-farh_crfdcrlk :
define input parameter parhost-code         like ub.fin-doc-schet-lk.host-code    no-undo.
define input parameter parfin-code-cor-acc  like ub.fin-code-cor-acc.fin-code     no-undo.
define input parameter paruser-name         like ub.fin-doc-schet-lk.user-name    no-undo.
define input parameter parfin-doc-code      like ub.fin-doc-schet-lk.fin-doc-code no-undo.
define input parameter partype-lock         like ub.fin-doc-schet-lk.type-lock    no-undo.
define input parameter pardate-lock         like ub.fin-doc-schet-lk.date-lock    no-undo.
define input parameter partime-lock         like ub.fin-doc-schet-lk.time-lock    no-undo.
define buffer bf_fin-doc-cor-acc-lk for ub.fin-doc-cor-acc-lk.
do on error undo, return error return-value :
find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                       bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc no-lock no-error.
if not available bf_fin-doc-cor-acc-lk then do:
  create bf_fin-doc-cor-acc-lk.
  assign
    bf_fin-doc-cor-acc-lk.host-code     = parhost-code
    bf_fin-doc-cor-acc-lk.fin-code      = parfin-code-cor-acc
    bf_fin-doc-cor-acc-lk.user-name     = paruser-name
    bf_fin-doc-cor-acc-lk.fin-doc-code  = parfin-doc-code
    bf_fin-doc-cor-acc-lk.type-lock     = partype-lock
    bf_fin-doc-cor-acc-lk.date-lock     = pardate-lock
    bf_fin-doc-cor-acc-lk.time-lock     = partime-lock    .
end.
end.
end procedure.
procedure lib-farh_lkschdoc :
define input parameter parhost-code    like ub.fin-schet.host-code.
define input parameter parcode-schet   like ub.fin-schet.code-schet.
define input parameter paruser-name    as character no-undo .
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code.
define buffer bf_fin-schet        for ub.fin-schet.
define buffer bf_fin-doc-schet-lk for ub.fin-doc-schet-lk.
do on error undo, return error return-value :
  find first bf_fin-schet where bf_fin-schet.host-code  = parhost-code  and
                                bf_fin-schet.code-schet = parcode-schet no-lock no-error.
  if not available bf_fin-schet then do:
    return error substitute ("Не найден счет с внутренним номером &1 по фирме &2.", parcode-schet, parhost-code).
  end.
  find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = bf_fin-schet.host-code  and
                                       bf_fin-doc-schet-lk.code-schet = bf_fin-schet.code-schet exclusive-lock no-error.
  if not available bf_fin-doc-schet-lk then do:
    run lib-farh_crfdsclk in this-procedure
      (input bf_fin-schet.host-code,
       input bf_fin-schet.code-schet,
       input paruser-name,
       input parfin-doc-code,
       input "расчет финансовых архивов":u,
       input today,
       input time) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = bf_fin-schet.host-code  and
                                       bf_fin-doc-schet-lk.code-schet = bf_fin-schet.code-schet exclusive-lock.
end.
end procedure.
procedure lib-farh_lkcordoc :
define input parameter parhost-code        like ub.fin-schet.host-code.
define input parameter parfin-code-cor-acc like ub.fin-code-cor-acc.fin-code.
define input parameter paruser-name        as character no-undo .
define input parameter pardoc-code         like ub.fin-doc.fin-doc-code.
define buffer bf_fin-doc-cor-acc-lk for ub.fin-doc-cor-acc-lk.
do on error undo, return error return-value :
  find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                         bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc exclusive-lock no-error.
  if not available bf_fin-doc-cor-acc-lk then do:
    run lib-farh_crfdcrlk in this-procedure
      (input parhost-code       ,
       input parfin-code-cor-acc,
       input paruser-name,
       input pardoc-code,
       input "расчет финансовых архивов":u,
       input today,
       input time) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                         bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc exclusive-lock.
end.
end procedure.
define temp-table tt-sum-con-fin-ob-obj no-undo
field obj-type      like ub.fin-ob.obj-type
field obj-code      like ub.fin-ob.obj-code
field sum-base      like ub.fin-ob.sum-base
field sum-rubl      like ub.fin-ob.sum-rubl
field sum-contract  like ub.fin-ob.sum-contract
field sum-doc       like ub.fin-doc.sum-doc
field sum-vat-base  like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl  like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc   like ub.fin-doc.sum-doc
field sum-slt-base  like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl  like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc   like ub.fin-doc.sum-doc
index pi is unique primary obj-type obj-code.
define temp-table tt-sum-con-fin-ob-tax-obj no-undo
field obj-type       like ub.fin-ob.obj-type
field obj-code       like ub.fin-ob.obj-code
field vat-pc         like ub.fin-ob-tax.vat-pc
field slt-pc         like ub.fin-ob-tax.slt-pc
field with-vat       like ub.fin-ob-tax.with-vat
field with-slt       like ub.fin-ob-tax.with-slt
field sum-doc        like ub.fin-ob-tax.sum-line-doc
field sum-rubl       like ub.fin-ob-tax.sum-line-rubl
field sum-base       like ub.fin-ob-tax.sum-line-base
field sum-contr      like ub.fin-ob-tax.sum-line-contr
field sum-vat-base   like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl   like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr  like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc    like ub.fin-doc.sum-doc
field sum-slt-base   like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl   like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr  like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc    like ub.fin-doc.sum-doc
index pi is unique primary obj-type obj-code vat-pc slt-pc with-vat with-slt
index nalog vat-pc slt-pc with-vat with-slt.
define temp-table tt-sum-fin-doc-tax no-undo
field vat-pc         like ub.fin-ob-tax.vat-pc
field slt-pc         like ub.fin-ob-tax.slt-pc
field with-vat       like ub.fin-ob-tax.with-vat
field with-slt       like ub.fin-ob-tax.with-slt
field sum-line-doc   like ub.fin-ob-tax.sum-line-doc
field sum-line-rubl  like ub.fin-ob-tax.sum-line-rubl
field sum-line-base  like ub.fin-ob-tax.sum-line-base
field sum-line-contr like ub.fin-ob-tax.sum-line-contr
field sum-vat-base   like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl   like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr  like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc    like ub.fin-doc.sum-doc
field sum-slt-base   like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl   like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr  like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc    like ub.fin-doc.sum-doc
index pi is unique primary vat-pc slt-pc with-vat with-slt.
define temp-table tt-sum-fin-ob-tax no-undo
field vat-pc        like ub.fin-ob-tax.vat-pc
field slt-pc        like ub.fin-ob-tax.slt-pc
field with-vat      like ub.fin-ob-tax.with-vat
field with-slt      like ub.fin-ob-tax.with-slt
field sum-vat-base  like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl  like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc   like ub.fin-doc.sum-doc
field sum-slt-base  like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl  like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc   like ub.fin-doc.sum-doc
index pi is unique primary vat-pc slt-pc with-vat with-slt.
procedure lib-farh_taskclcd:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter pararh-name     as character no-undo .
define input parameter paruser-name    as character no-undo .
define input parameter parmode         as character no-undo .
define buffer bf_contract                for ub.contract.
define buffer bf_fin-doc                 for ub.fin-doc.
define buffer bf_fin-doc-tax             for ub.fin-doc-tax.
define buffer bf_sysconf                 for ub.sysconf.
define variable varrel-dog-code       as   logical               no-undo.
define variable varcurr-dog-code      like ub.currency.curr-code no-undo.
define variable varhave-connect       as   logical               no-undo.
define variable varznaksum-doc        as   decimal               no-undo.
define variable varznaksum-rubl       as   decimal               no-undo.
define variable varznaksum-base       as   decimal               no-undo.
define variable varznaksum-contr      as   decimal               no-undo.
define variable varznaksum-vat-doc    as   decimal               no-undo.
define variable varznaksum-vat-rubl   as   decimal               no-undo.
define variable varznaksum-vat-base   as   decimal               no-undo.
define variable varznaksum-vat-contr  as   decimal               no-undo.
define variable varznaksum-slt-doc    as   decimal               no-undo.
define variable varznaksum-slt-rubl   as   decimal               no-undo.
define variable varznaksum-slt-base   as   decimal               no-undo.
define variable varznaksum-slt-contr  as   decimal               no-undo.
define variable varfin-doc-tax-vat-pc as   decimal               no-undo.
define variable varfin-doc-tax-slt-pc as   decimal               no-undo.
define variable v-curr-db-num         as   integer               no-undo.
define variable v-is-income as logical no-undo .
define variable v-is-expense as logical no-undo .
define variable v-is-cash as logical no-undo .
define variable v-is-cashless as logical no-undo .
define variable v-is-payoff as logical no-undo .
define variable v-recalc as logical no-undo .
do on error undo, return error return-value :
  find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                              bf_fin-doc.fin-doc-code = parfin-doc-code exclusive-lock no-error.
  if not available bf_fin-doc then do:
    return error substitute ("Не найден платежный документ с внутренним номером &1 по фирме &2.", parfin-doc-code, parhost-code).
  end.
  if bf_fin-doc.contract-code <> 0 then do:
    find first bf_contract where bf_contract.host-code     = bf_fin-doc.host-code     and
                                 bf_contract.contract-code = bf_fin-doc.contract-code no-lock no-error.
    if not available bf_contract then do:
      return error substitute ("По платежному документу с внутренним номером &1 на фирме &2 указан договор с внутренним номером &3, которого нет в базе данных.", bf_fin-doc.fin-doc-code, bf_fin-doc.host-code, bf_fin-doc.contract-code).
    end.
    assign
      varrel-dog-code  = yes
      varcurr-dog-code = bf_contract.curr-code.
  end.
  else do:
    assign
      varrel-dog-code = no.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_fin-doc.host-code no-lock.
  if bf_sysconf.fin-calc = 1 then do:
    run check-sum-doc  in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code, output varhave-connect).
  end.
  if parmode <> "close":u  and
     parmode <> "delete":u and
     parmode <> "recalc":u then do:
    return error substitute ("Неверный параметр вызова расчета финансовых архивов &1. Должен быть close или delete.", parmode).
  end.
  if parmode = "recalc":u  then do:
    v-recalc = yes.
    parmode = "close".
  end.
  if bf_fin-doc.status_ <> 'факт':U then do:
    return error substitute ("Платежный документ с номером &1 не находится в статусе &2.", bf_fin-doc.prn-doc-code, 'факт':U).
  end.
  run check-attr-doc in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code).
  run full-lock in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code, input paruser-name).
  run calc-sum  in this-procedure (input parmode,
                                   input bf_fin-doc.host-code,
                                   input bf_fin-doc.fin-doc-code,
                                   output varznaksum-doc      ,
                                   output varznaksum-rubl     ,
                                   output varznaksum-base     ,
                                   output varznaksum-contr    ,
                                   output varznaksum-vat-doc  ,
                                   output varznaksum-vat-rubl ,
                                   output varznaksum-vat-base ,
                                   output varznaksum-vat-contr,
                                   output varznaksum-slt-doc  ,
                                   output varznaksum-slt-rubl ,
                                   output varznaksum-slt-base ,
                                   output varznaksum-slt-contr
                                   ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
  assign
  v-is-income = lookup(bf_fin-doc.fin-ext-doc-type, 'пко,ппп,апп':U) > 0
  v-is-expense = lookup(bf_fin-doc.fin-ext-doc-type, 'рко,рпп,апр,':U) > 0
  v-is-cash = lookup(bf_fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
  v-is-cashless = lookup(bf_fin-doc.fin-ext-doc-type, 'ппп,рпп':U) > 0
  v-is-payoff = lookup(bf_fin-doc.fin-ext-doc-type, 'апп,апр':U) > 0
  .
  define variable v-obj-db-num as integer init ? no-undo .
  if bf_fin-doc.obj-type <> ''  then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  bf_fin-doc.obj-type
  ,input  bf_fin-doc.obj-code
  ,output v-obj-db-num
  )  .
    if bf_fin-doc.shift-flag = integer('1':U)
    and (v-obj-db-num = v-curr-db-num or v-recalc or v-curr-db-num = 0)
    then do:
    end.
  end.
  if v-obj-db-num = ? then  v-obj-db-num = bf_sysconf.firm-db-num.
    if v-is-cashless then do:
    if pararh-name = "all":u                        or
    lookup ('arh-fin-doc-an':U, pararh-name) > 0  and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input bf_fin-doc.an-uchet-code,
                                                      input bf_fin-doc.cel-nazn-code,
                                                      input bf_fin-doc.cor-acc,
                                                      input '':U,
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input bf_fin-doc.an-uchet-code,
                                                      input 0,
                                                      input 0,
                                                      input 'sum-schet-uchet':U,
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input 0,
                                                      input bf_fin-doc.cel-nazn-code,
                                                      input 0,
                                                      input 'sum-schet-cel-nazn':U,
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input 0,
                                                      input 0,
                                                      input bf_fin-doc.cor-acc,
                                                      input 'sum-schet-cor-acc':U,
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
    end.
  end.
    else do:
    if pararh-name = "all":u                        or
    lookup ('arh-fin-doc-an-nal':U, pararh-name) > 0 then do:
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input '':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input 'sum-rubl':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input 0,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input 'sum-base':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input 0,
                                                        input 'sum-without-schet-code':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input 'sum-uchet':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                       ).
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input 'sum-rubl-uchet':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                       ).
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input 'sum-cel-nazn':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input 'sum-rubl-cel-nazn':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
     if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input 'sum-cor-acc':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input 'sum-rubl-cor-acc':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input 'sum-base-uchet':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input 'sum-base-cel-nazn':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input 'sum-base-cor-acc':U,
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
    end.
  end.
    if v-is-cashless then do:
    if (pararh-name = "all":u                               or
    lookup ('arh-fin-doc-contr-schet':U, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet in g#libfarhp (input parmode,
                                                               input bf_fin-doc.host-code,
                                                               input bf_fin-doc.payer-type,
                                                               input bf_fin-doc.payer-code,
                                                               input bf_fin-doc.receiver-type,
                                                               input bf_fin-doc.receiver-code,
                                                               input bf_fin-doc.payer-code-schet,
                                                               input bf_fin-doc.receiver-code-schet,
                                                               input bf_fin-doc.fin-ext-doc-type,
                                                               input '':U,
                                                               input bf_fin-doc.fact-order,
                                                               input bf_fin-doc.fin-doc-code,
                                                               input bf_fin-doc.fact-date,
                                                               input bf_fin-doc.curr-code,
                                                               input bf_sysconf.base-code,
                                                               input varcurr-dog-code,
                                                               input varrel-dog-code,
                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                               input varznaksum-doc      ,
                                                               input varznaksum-rubl     ,
                                                               input varznaksum-base     ,
                                                               input varznaksum-contr    ,
                                                               input varznaksum-vat-doc  ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-base ,
                                                               input varznaksum-vat-contr,
                                                               input varznaksum-slt-doc  ,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-base ,
                                                               input varznaksum-slt-contr
                                                               ).
    end.
      if bf_sysconf.fin-calc = 1 then do:
      if pararh-name = "all":u                               or
      lookup ('arh-fin-doc-contr-schet-obj':U, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.obj-type,
                                                                       input bf_fin-doc.obj-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input bf_fin-doc.payer-code-schet,
                                                                       input bf_fin-doc.receiver-code-schet,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input '':U,
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input bf_fin-doc.curr-code,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varznaksum-doc      ,
                                                                       input varznaksum-rubl     ,
                                                                       input varznaksum-base     ,
                                                                       input varznaksum-contr    ,
                                                                       input varznaksum-vat-doc  ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-base ,
                                                                       input varznaksum-vat-contr,
                                                                       input varznaksum-slt-doc  ,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-base ,
                                                                       input varznaksum-slt-contr
                                                                       ).
        end.
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input tt-sum-con-fin-ob-obj.obj-type,
                                                                         input tt-sum-con-fin-ob-obj.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input bf_fin-doc.payer-code-schet,
                                                                         input bf_fin-doc.receiver-code-schet,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input '':U,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-doc       else - tt-sum-con-fin-ob-obj.sum-doc       ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-doc   else - tt-sum-con-fin-ob-obj.sum-vat-doc   ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-doc   else - tt-sum-con-fin-ob-obj.sum-slt-doc   ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                         ).
          end.
        end.
      end.
    end.
    if (pararh-name = "all":u                               or
    lookup ('arh-fin-doc-contr-schet':U, pararh-name) > 0)  and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet in g#libfarhp (input parmode,
                                                               input bf_fin-doc.host-code,
                                                               input bf_fin-doc.payer-type,
                                                               input bf_fin-doc.payer-code,
                                                               input bf_fin-doc.receiver-type,
                                                               input bf_fin-doc.receiver-code,
                                                               input 0,
                                                               input 0,
                                                               input bf_fin-doc.fin-ext-doc-type,
                                                               input 'sum-contract':U,
                                                               input bf_fin-doc.fact-order,
                                                               input bf_fin-doc.fin-doc-code,
                                                               input bf_fin-doc.fact-date,
                                                               input 0,
                                                               input bf_sysconf.base-code,
                                                               input varcurr-dog-code,
                                                               input varrel-dog-code,
                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                               input varznaksum-rubl     ,
                                                               input varznaksum-rubl     ,
                                                               input varznaksum-base     ,
                                                               input varznaksum-contr    ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-base ,
                                                               input varznaksum-vat-contr,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-base ,
                                                               input varznaksum-slt-contr
                                                               ).
    end.
      if bf_sysconf.fin-calc = 1 then do:
      if pararh-name = "all":u                               or
      lookup ('arh-fin-doc-contr-schet-obj':U, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.obj-type,
                                                                       input bf_fin-doc.obj-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input 0,
                                                                       input 0,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input 'sum-contract':U,
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input 0,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varznaksum-rubl     ,
                                                                       input varznaksum-rubl     ,
                                                                       input varznaksum-base     ,
                                                                       input varznaksum-contr    ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-base ,
                                                                       input varznaksum-vat-contr,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-base ,
                                                                       input varznaksum-slt-contr
                                                                       ).
        end.
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input tt-sum-con-fin-ob-obj.obj-type,
                                                                         input tt-sum-con-fin-ob-obj.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input 'sum-contract':U,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                         ).
          end.
        end.
      end.
    end.
  end.
    else do:
    if (pararh-name = "all":u                               or
    lookup ('arh-fin-doc-contr-schet-nal':U, pararh-name) > 0 ) and  v-curr-db-num = v-obj-db-num  then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet-n in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                 input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input '':U,
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input bf_fin-doc.curr-code,
                                                                 input bf_fin-doc.cashbookid,
                                                                 input bf_sysconf.base-code,
                                                                 input varcurr-dog-code,
                                                                 input varrel-dog-code,
                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                 input varznaksum-doc      ,
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-base     ,
                                                                 input varznaksum-contr    ,
                                                                 input varznaksum-vat-doc  ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-base ,
                                                                 input varznaksum-vat-contr,
                                                                 input varznaksum-slt-doc  ,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-base ,
                                                                 input varznaksum-slt-contr
                                                                 ).
    end.
      if bf_sysconf.fin-calc = 1 then do:
      if pararh-name = "all":u                               or
      lookup ('arh-fin-doc-contr-s-nal-obj':U, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.obj-type,
                                                                         input bf_fin-doc.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                         input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input '':U,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varznaksum-doc      ,
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-base     ,
                                                                         input varznaksum-contr    ,
                                                                         input varznaksum-vat-doc  ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-base ,
                                                                         input varznaksum-vat-contr,
                                                                         input varznaksum-slt-doc  ,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-base ,
                                                                         input varznaksum-slt-contr
                                                                         ).
        end.
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                           input bf_fin-doc.host-code,
                                                                           input tt-sum-con-fin-ob-obj.obj-type,
                                                                           input tt-sum-con-fin-ob-obj.obj-code,
                                                                           input bf_fin-doc.payer-type,
                                                                           input bf_fin-doc.payer-code,
                                                                           input bf_fin-doc.receiver-type,
                                                                           input bf_fin-doc.receiver-code,
                                                                           input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                           input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                           input bf_fin-doc.fin-ext-doc-type,
                                                                           input '':U,
                                                                           input bf_fin-doc.fact-order,
                                                                           input bf_fin-doc.fin-doc-code,
                                                                           input bf_fin-doc.fact-date,
                                                                           input bf_fin-doc.curr-code,
                                                                           input bf_sysconf.base-code,
                                                                           input varcurr-dog-code,
                                                                           input varrel-dog-code,
                                                                           input (if available bf_contract then bf_contract.contract-code else 0),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-doc       else - tt-sum-con-fin-ob-obj.sum-doc       ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-doc   else - tt-sum-con-fin-ob-obj.sum-vat-doc   ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-doc   else - tt-sum-con-fin-ob-obj.sum-slt-doc   ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                           ).
          end.
        end.
      end.
    end.
    if (pararh-name = "all":u                       or
    lookup ('arh-fin-doc-contr-schet-nal':U, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet-n in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input 0,
                                                                 input 0,
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input 'sum-contract':U,
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input 0,
                                                                 input bf_sysconf.base-code,
                                                                 input varcurr-dog-code,
                                                                 input varrel-dog-code,
                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-base     ,
                                                                 input varznaksum-contr    ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-base ,
                                                                 input varznaksum-vat-contr,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-base ,
                                                                 input varznaksum-slt-contr
                                                                 ).
    end.
      if bf_sysconf.fin-calc = 1 then do:
      if pararh-name = "all":u                               or
      lookup ('arh-fin-doc-contr-s-nal-obj':U, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.obj-type,
                                                                         input bf_fin-doc.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input 'sum-contract':U ,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-base     ,
                                                                         input varznaksum-contr    ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-base ,
                                                                         input varznaksum-vat-contr,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-base ,
                                                                         input varznaksum-slt-contr
                                                                         ).
        end.
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                           input bf_fin-doc.host-code,
                                                                           input tt-sum-con-fin-ob-obj.obj-type,
                                                                           input tt-sum-con-fin-ob-obj.obj-code,
                                                                           input bf_fin-doc.payer-type,
                                                                           input bf_fin-doc.payer-code,
                                                                           input bf_fin-doc.receiver-type,
                                                                           input bf_fin-doc.receiver-code,
                                                                           input 0,
                                                                           input 0,
                                                                           input bf_fin-doc.fin-ext-doc-type,
                                                                           input 'sum-contract':U,
                                                                           input bf_fin-doc.fact-order,
                                                                           input bf_fin-doc.fin-doc-code,
                                                                           input bf_fin-doc.fact-date,
                                                                           input 0,
                                                                           input bf_sysconf.base-code,
                                                                           input varcurr-dog-code,
                                                                           input varrel-dog-code,
                                                                           input (if available bf_contract then bf_contract.contract-code else 0),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                           ).
          end.
        end.
      end.
    end.
  end.
  if pararh-name = "all":u                                     or
  lookup ('arh-fin-doc-contr-schet-tax':U, pararh-name) > 0 or
  lookup ('arh-fin-doc-contr-s-tax-obj':U, pararh-name) > 0 or
  lookup ('arh-fin-doc-c-schet-tax-nal':U, pararh-name) > 0 or
  lookup ('arh-fin-doc-c-s-tax-nal-obj':U, pararh-name) > 0 then do:
    for each tt-sum-fin-doc-tax on error undo, return error return-value :
      delete tt-sum-fin-doc-tax.
    end.
    for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                  bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code
                                  break by bf_fin-doc-tax.host-code by bf_fin-doc-tax.fin-doc-code by round(bf_fin-doc-tax.vat-pc, 0) by round(bf_fin-doc-tax.slt-pc, 0) by bf_fin-doc-tax.with-vat by bf_fin-doc-tax.with-slt
                                  on error undo, return error return-value :
      assign
        varfin-doc-tax-vat-pc = round(bf_fin-doc-tax.vat-pc, 0)
        varfin-doc-tax-slt-pc = round(bf_fin-doc-tax.slt-pc, 0)
      .
      if first-of (bf_fin-doc-tax.with-slt) then do:
        create tt-sum-fin-doc-tax.
        assign
          tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc
          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc
          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
        .
      end.
      find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc   and
                                          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc   and
                                          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
      assign
        tt-sum-fin-doc-tax.sum-line-doc   = tt-sum-fin-doc-tax.sum-line-doc   + bf_fin-doc-tax.sum-line-doc
        tt-sum-fin-doc-tax.sum-line-rubl  = tt-sum-fin-doc-tax.sum-line-rubl  + bf_fin-doc-tax.sum-line-rubl
        tt-sum-fin-doc-tax.sum-line-base  = tt-sum-fin-doc-tax.sum-line-base  + bf_fin-doc-tax.sum-line-base
        tt-sum-fin-doc-tax.sum-line-contr = tt-sum-fin-doc-tax.sum-line-contr + bf_fin-doc-tax.sum-line-contr
        tt-sum-fin-doc-tax.sum-vat-rubl   = tt-sum-fin-doc-tax.sum-vat-rubl   + bf_fin-doc-tax.sum-vat-line-rubl
        tt-sum-fin-doc-tax.sum-vat-base   = tt-sum-fin-doc-tax.sum-vat-base   + bf_fin-doc-tax.sum-vat-line-base
        tt-sum-fin-doc-tax.sum-vat-contr  = tt-sum-fin-doc-tax.sum-vat-contr  + bf_fin-doc-tax.sum-vat-line-contr
        tt-sum-fin-doc-tax.sum-vat-doc    = tt-sum-fin-doc-tax.sum-vat-doc    + bf_fin-doc-tax.sum-vat-line-doc
        tt-sum-fin-doc-tax.sum-slt-rubl   = tt-sum-fin-doc-tax.sum-slt-rubl   + bf_fin-doc-tax.sum-slt-line-rubl
        tt-sum-fin-doc-tax.sum-slt-base   = tt-sum-fin-doc-tax.sum-slt-base   + bf_fin-doc-tax.sum-slt-line-base
        tt-sum-fin-doc-tax.sum-slt-contr  = tt-sum-fin-doc-tax.sum-slt-contr  + bf_fin-doc-tax.sum-slt-line-contr
        tt-sum-fin-doc-tax.sum-slt-doc    = tt-sum-fin-doc-tax.sum-slt-doc    + bf_fin-doc-tax.sum-slt-line-doc
      .
      if last-of (bf_fin-doc-tax.with-slt) then do:
        if v-is-cashless then do:
          if pararh-name = "all":u                                     or
          lookup ('arh-fin-doc-contr-schet-tax':U, pararh-name) > 0 then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax in g#libfarhp (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input bf_fin-doc.payer-code-schet,
                                                                       input bf_fin-doc.receiver-code-schet,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input '':U,
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input bf_fin-doc.curr-code,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varfin-doc-tax-vat-pc,
                                                                       input varfin-doc-tax-slt-pc,
                                                                       input bf_fin-doc-tax.with-vat,
                                                                       input bf_fin-doc-tax.with-slt,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                       ).
          end.
          if bf_sysconf.fin-calc = 1 then do:
            if pararh-name = "all":u                                     or
            lookup ('arh-fin-doc-contr-s-tax-obj':U, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                               input bf_fin-doc.host-code,
                                                                               input bf_fin-doc.obj-type,
                                                                               input bf_fin-doc.obj-code,
                                                                               input bf_fin-doc.payer-type,
                                                                               input bf_fin-doc.payer-code,
                                                                               input bf_fin-doc.receiver-type,
                                                                               input bf_fin-doc.receiver-code,
                                                                               input bf_fin-doc.payer-code-schet,
                                                                               input bf_fin-doc.receiver-code-schet,
                                                                               input bf_fin-doc.fin-ext-doc-type,
                                                                               input '':U,
                                                                               input bf_fin-doc.fact-order,
                                                                               input bf_fin-doc.fin-doc-code,
                                                                               input bf_fin-doc.fact-date,
                                                                               input bf_fin-doc.curr-code,
                                                                               input bf_sysconf.base-code,
                                                                               input varcurr-dog-code,
                                                                               input varrel-dog-code,
                                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                                               input varfin-doc-tax-vat-pc,
                                                                               input varfin-doc-tax-slt-pc,
                                                                               input bf_fin-doc-tax.with-vat,
                                                                               input bf_fin-doc-tax.with-slt,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                               ).
              end.
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input bf_fin-doc.payer-code-schet,
                                                                                 input bf_fin-doc.receiver-code-schet,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input '':U,
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input bf_fin-doc.curr-code,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-doc       else - tt-sum-con-fin-ob-tax-obj.sum-doc      ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-doc   else - tt-sum-con-fin-ob-tax-obj.sum-vat-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-doc   else - tt-sum-con-fin-ob-tax-obj.sum-slt-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                 ).
                end.
              end.
            end.
          end.
          if (pararh-name = "all":u                                     or
          lookup ('arh-fin-doc-contr-schet-tax':U, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax in g#libfarhp (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input 0,
                                                                       input 0,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input 'sum-contract':U,
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input 0,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varfin-doc-tax-vat-pc,
                                                                       input varfin-doc-tax-slt-pc,
                                                                       input bf_fin-doc-tax.with-vat,
                                                                       input bf_fin-doc-tax.with-slt,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                       ).
          end.
          if bf_sysconf.fin-calc = 1 then do:
            if pararh-name = "all":u                                     or
            lookup ('arh-fin-doc-contr-s-tax-obj':U, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                               input bf_fin-doc.host-code,
                                                                               input bf_fin-doc.obj-type,
                                                                               input bf_fin-doc.obj-code,
                                                                               input bf_fin-doc.payer-type,
                                                                               input bf_fin-doc.payer-code,
                                                                               input bf_fin-doc.receiver-type,
                                                                               input bf_fin-doc.receiver-code,
                                                                               input 0,
                                                                               input 0,
                                                                               input bf_fin-doc.fin-ext-doc-type,
                                                                               input 'sum-contract':U,
                                                                               input bf_fin-doc.fact-order,
                                                                               input bf_fin-doc.fin-doc-code,
                                                                               input bf_fin-doc.fact-date,
                                                                               input 0,
                                                                               input bf_sysconf.base-code,
                                                                               input varcurr-dog-code,
                                                                               input varrel-dog-code,
                                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                                               input varfin-doc-tax-vat-pc,
                                                                               input varfin-doc-tax-slt-pc,
                                                                               input bf_fin-doc-tax.with-vat,
                                                                               input bf_fin-doc-tax.with-slt,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                               ).
            end.
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input 0,
                                                                                 input 0,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input 'sum-contract':U,
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input 0,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                 ).
                end.
              end.
            end.
          end.
        end.
        else do:
          if (pararh-name = "all":u                                     or
          lookup ('arh-fin-doc-c-schet-tax-nal':U, pararh-name) > 0)  and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax-n in g#libfarhp (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                         input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input '':U,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varfin-doc-tax-vat-pc,
                                                                         input varfin-doc-tax-slt-pc,
                                                                         input bf_fin-doc-tax.with-vat,
                                                                         input bf_fin-doc-tax.with-slt,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                         ).
          end.
          if bf_sysconf.fin-calc = 1 then do:
            if pararh-name = "all":u                                     or
            lookup ('arh-fin-doc-c-s-tax-nal-obj':U, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input bf_fin-doc.obj-type,
                                                                                 input bf_fin-doc.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                                 input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input '':U,
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input bf_fin-doc.curr-code,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                                 ).
              end.
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                   input bf_fin-doc.host-code,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                   input bf_fin-doc.payer-type,
                                                                                   input bf_fin-doc.payer-code,
                                                                                   input bf_fin-doc.receiver-type,
                                                                                   input bf_fin-doc.receiver-code,
                                                                                   input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                                   input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                                   input '':U,
                                                                                   input bf_fin-doc.fact-order,
                                                                                   input bf_fin-doc.fin-doc-code,
                                                                                   input bf_fin-doc.fact-date,
                                                                                   input bf_fin-doc.curr-code,
                                                                                   input bf_sysconf.base-code,
                                                                                   input varcurr-dog-code,
                                                                                   input varrel-dog-code,
                                                                                   input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                   input varfin-doc-tax-vat-pc,
                                                                                   input varfin-doc-tax-slt-pc,
                                                                                   input bf_fin-doc-tax.with-vat,
                                                                                   input bf_fin-doc-tax.with-slt,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-doc       else - tt-sum-con-fin-ob-tax-obj.sum-doc      ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-doc   else - tt-sum-con-fin-ob-tax-obj.sum-vat-doc  ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-doc   else - tt-sum-con-fin-ob-tax-obj.sum-slt-doc  ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                   ).
                end.
              end.
            end.
          end.
          if (pararh-name = "all":u                                     or
          lookup ('arh-fin-doc-c-schet-tax-nal':U, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax-n in g#libfarhp (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                          input 'sum-contract':U,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varfin-doc-tax-vat-pc,
                                                                         input varfin-doc-tax-slt-pc,
                                                                         input bf_fin-doc-tax.with-vat,
                                                                         input bf_fin-doc-tax.with-slt,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr   )
                                                                         ).
          end.
          if bf_sysconf.fin-calc = 1 then do:
            if pararh-name = "all":u                                     or
            lookup ('arh-fin-doc-c-s-tax-nal-obj':U, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input bf_fin-doc.obj-type,
                                                                                 input bf_fin-doc.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input 0,
                                                                                 input 0,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input 'sum-contract':U,
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input 0,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                                 ).
              end.
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                   input bf_fin-doc.host-code,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                   input bf_fin-doc.payer-type,
                                                                                   input bf_fin-doc.payer-code,
                                                                                   input bf_fin-doc.receiver-type,
                                                                                   input bf_fin-doc.receiver-code,
                                                                                   input 0,
                                                                                   input 0,
                                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                                   input 'sum-contract':U,
                                                                                   input bf_fin-doc.fact-order,
                                                                                   input bf_fin-doc.fin-doc-code,
                                                                                   input bf_fin-doc.fact-date,
                                                                                   input 0,
                                                                                   input bf_sysconf.base-code,
                                                                                   input varcurr-dog-code,
                                                                                   input varrel-dog-code,
                                                                                   input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                   input varfin-doc-tax-vat-pc,
                                                                                   input varfin-doc-tax-slt-pc,
                                                                                   input bf_fin-doc-tax.with-vat,
                                                                                   input bf_fin-doc-tax.with-slt,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                   ).
                end.
              end.
            end.
          end.
        end.
      end.
    end.
  end.
    if v-is-cashless then do:
    if (pararh-name = "all":u                           or
    lookup ('arh-fin-doc-schet':U, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input bf_fin-doc.payer-type,
                                                          input bf_fin-doc.payer-code,
                                                          input bf_fin-doc.receiver-type,
                                                          input bf_fin-doc.receiver-code,
                                                          input bf_fin-doc.payer-code-schet,
                                                          input bf_fin-doc.receiver-code-schet,
                                                          input bf_fin-doc.fin-ext-doc-type,
                                                          input '':U,
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                          input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                          input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                          input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                          input 0,
                                                          input 0,
                                                          input "",
                                                          input 'firm':U,
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
      if bf_sysconf.firm-db-num = v-curr-db-num
      and bf_fin-doc.trn-doc-code = ''      then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                          input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                          input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                          input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                          input 0,
                                                          input 0,
                                                          input "",
                                                          input 'firm-without-obj':U,
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
    end.
    if pararh-name = "all":u                           or
    lookup ('arh-fin-doc-schet-obj':U, pararh-name) > 0 then do:
      if not (bf_fin-doc.obj-type = ''
             and bf_fin-doc.obj-code = 0) then do:
        run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input bf_fin-doc.payer-code-schet,
                                                            input bf_fin-doc.receiver-code-schet,
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input '':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ?  ,
                                                            input 0  ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc ,
                                                            input varznaksum-rubl,
                                                            input varznaksum-base,
                                                            input varznaksum-vat-doc     ,
                                                            input varznaksum-vat-rubl    ,
                                                            input varznaksum-vat-base    ,
                                                            input varznaksum-slt-doc     ,
                                                            input varznaksum-slt-rubl    ,
                                                            input varznaksum-slt-base
                                                            ).
        if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:
        run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0  ,
                                                            input 0   ,
                                                            input "" ,
                                                            input 'obj':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ? ,
                                                            input 0 ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc ,
                                                            input varznaksum-rubl,
                                                            input varznaksum-base,
                                                            input varznaksum-vat-doc     ,
                                                            input varznaksum-vat-rubl    ,
                                                            input varznaksum-vat-base    ,
                                                            input varznaksum-slt-doc     ,
                                                            input varznaksum-slt-rubl    ,
                                                            input varznaksum-slt-base
                                                            ).
          if bf_fin-doc.shift-fact-order <> 0
          then do:
           run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                                  input bf_fin-doc.host-code,
                                                                  input bf_fin-doc.obj-type,
                                                                  input bf_fin-doc.obj-code,
                                                                  input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                                  input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                                  input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                                  input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                                  input 0  ,
                                                                  input 0   ,
                                                                  input "" ,
                                                                  input 'shift-obj':U,
                                                                  input bf_fin-doc.shift-fact-order,
                                                                  input bf_fin-doc.fin-doc-code,
                                                                  input bf_fin-doc.fact-date,
                                                                  input bf_fin-doc.shift-date,
                                                                  input bf_fin-doc.shift-num,
                                                                  input bf_fin-doc.curr-code,
                                                                  input bf_sysconf.base-code,
                                                                  input varznaksum-doc ,
                                                                  input varznaksum-rubl,
                                                                  input varznaksum-base,
                                                                  input varznaksum-vat-doc     ,
                                                                  input varznaksum-vat-rubl    ,
                                                                  input varznaksum-vat-base    ,
                                                                  input varznaksum-slt-doc     ,
                                                                  input varznaksum-slt-rubl    ,
                                                                  input varznaksum-slt-base
                                                                  ).
         end.
         end.
       end.
     end.
  end.
    else do:
    if (pararh-name = "all":u                           or
    lookup ('arh-fin-doc-schet-nal':U, pararh-name) > 0 ) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                            input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input '':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input '',
                                                            input 'firm':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
      if bf_sysconf.firm-db-num = v-curr-db-num
      and bf_fin-doc.trn-doc-code = "" then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input '',
                                                            input 'firm-without-obj':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
    end.
    if not (bf_fin-doc.obj-type = ''
            and bf_fin-doc.obj-code = 0) then do:
      if pararh-name = "all":u                           or
      lookup ('arh-fin-doc-schet-nal-obj':U, pararh-name) > 0 then do:
       run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                            input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input '':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ?  ,
                                                            input 0  ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_fin-doc.cashbookid,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
       if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:
        if v-is-cash then
       run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo
                                                           (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input "",
                                                            input 'obj':U,
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ?  ,
                                                            input 0  ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_fin-doc.cashbookid,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
          if bf_fin-doc.shift-fact-order <> 0
          and v-is-cash
          then do:
          run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo
                                                              (input parmode,
                                                                input bf_fin-doc.host-code,
                                                                input bf_fin-doc.obj-type,
                                                                input bf_fin-doc.obj-code,
                                                                input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                                input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                                input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                                input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                                input 0,
                                                                input 0,
                                                                input "",
                                                                input 'shift-obj':U,
                                                                input bf_fin-doc.shift-fact-order,
                                                                input bf_fin-doc.fin-doc-code,
                                                                input bf_fin-doc.fact-date,
                                                                input bf_fin-doc.shift-date,
                                                                input bf_fin-doc.shift-num,
                                                                input bf_fin-doc.curr-code,
                                                                input bf_fin-doc.cashbookid,
                                                                input bf_sysconf.base-code,
                                                                input varznaksum-doc  ,
                                                                input varznaksum-rubl ,
                                                                input varznaksum-base ,
                                                                input varznaksum-vat-doc      ,
                                                                input varznaksum-vat-rubl     ,
                                                                input varznaksum-vat-base     ,
                                                                input varznaksum-slt-doc      ,
                                                                input varznaksum-slt-rubl     ,
                                                                input varznaksum-slt-base
                                                                ).
          end.
        end.
      end.
    end.
  end.
  if pararh-name = "all":u                               or
  lookup ('arh-fin-doc-schet-tax':U, pararh-name) > 0 or
  lookup ('arh-fin-doc-schet-tax-obj':U, pararh-name) > 0 or
  lookup ('arh-fin-doc-schet-tax-nal':U, pararh-name) > 0  or
  lookup ('arh-fin-doc-s-tax-nal-obj':U, pararh-name) > 0      then do:
    for each tt-sum-fin-doc-tax on error undo, return error return-value :
      delete tt-sum-fin-doc-tax.
    end.
    for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                  bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code
                                  break by bf_fin-doc-tax.host-code by bf_fin-doc-tax.fin-doc-code by round(bf_fin-doc-tax.vat-pc, 0) by round(bf_fin-doc-tax.slt-pc, 0) by bf_fin-doc-tax.with-vat by bf_fin-doc-tax.with-slt
                                  on error undo, return error return-value :
      assign
        varfin-doc-tax-vat-pc = round(bf_fin-doc-tax.vat-pc, 0)
        varfin-doc-tax-slt-pc = round(bf_fin-doc-tax.slt-pc, 0)
      .
      if first-of (bf_fin-doc-tax.with-slt) then do:
        create tt-sum-fin-doc-tax.
        assign
          tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc
          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc
          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
        .
      end.
      find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc   and
                                          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc   and
                                          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
      assign
        tt-sum-fin-doc-tax.sum-line-doc   = tt-sum-fin-doc-tax.sum-line-doc   + bf_fin-doc-tax.sum-line-doc
        tt-sum-fin-doc-tax.sum-line-rubl  = tt-sum-fin-doc-tax.sum-line-rubl  + bf_fin-doc-tax.sum-line-rubl
        tt-sum-fin-doc-tax.sum-line-base  = tt-sum-fin-doc-tax.sum-line-base  + bf_fin-doc-tax.sum-line-base
        tt-sum-fin-doc-tax.sum-line-contr = tt-sum-fin-doc-tax.sum-line-contr + bf_fin-doc-tax.sum-line-contr
        tt-sum-fin-doc-tax.sum-vat-rubl   = tt-sum-fin-doc-tax.sum-vat-rubl   + bf_fin-doc-tax.sum-vat-line-rubl
        tt-sum-fin-doc-tax.sum-vat-base   = tt-sum-fin-doc-tax.sum-vat-base   + bf_fin-doc-tax.sum-vat-line-base
        tt-sum-fin-doc-tax.sum-vat-contr  = tt-sum-fin-doc-tax.sum-vat-contr  + bf_fin-doc-tax.sum-vat-line-contr
        tt-sum-fin-doc-tax.sum-vat-doc    = tt-sum-fin-doc-tax.sum-vat-doc    + bf_fin-doc-tax.sum-vat-line-doc
        tt-sum-fin-doc-tax.sum-slt-rubl   = tt-sum-fin-doc-tax.sum-slt-rubl   + bf_fin-doc-tax.sum-slt-line-rubl
        tt-sum-fin-doc-tax.sum-slt-base   = tt-sum-fin-doc-tax.sum-slt-base   + bf_fin-doc-tax.sum-slt-line-base
        tt-sum-fin-doc-tax.sum-slt-contr  = tt-sum-fin-doc-tax.sum-slt-contr  + bf_fin-doc-tax.sum-slt-line-contr
        tt-sum-fin-doc-tax.sum-slt-doc    = tt-sum-fin-doc-tax.sum-slt-doc    + bf_fin-doc-tax.sum-slt-line-doc
      .
      if last-of (bf_fin-doc-tax.with-slt) then do:
        if v-is-cashless then do:
          if (pararh-name = "all":u                               or
          lookup ('arh-fin-doc-schet-tax':U, pararh-name) > 0 )   and  v-curr-db-num = v-obj-db-num
          then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-schet-tax in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input bf_fin-doc.payer-code-schet,
                                                                 input bf_fin-doc.receiver-code-schet,
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input '':U,
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input bf_fin-doc.curr-code,
                                                                 input bf_sysconf.base-code,
                                                                 input varfin-doc-tax-vat-pc,
                                                                 input varfin-doc-tax-slt-pc,
                                                                 input bf_fin-doc-tax.with-vat,
                                                                 input bf_fin-doc-tax.with-slt,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                 ).
          end.
        end.
        else do:
          if (pararh-name = "all":u                               or
          lookup ('arh-fin-doc-schet-tax-nal':U, pararh-name) > 0 )   and  v-curr-db-num = v-obj-db-num
          then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-schet-tax-n in g#libfarhp (input parmode,
                                                                   input bf_fin-doc.host-code,
                                                                   input bf_fin-doc.payer-type,
                                                                   input bf_fin-doc.payer-code,
                                                                   input bf_fin-doc.receiver-type,
                                                                   input bf_fin-doc.receiver-code,
                                                                   input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                   input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                   input '':U,
                                                                   input bf_fin-doc.fact-order,
                                                                   input bf_fin-doc.fin-doc-code,
                                                                   input bf_fin-doc.fact-date,
                                                                   input bf_fin-doc.curr-code,
                                                                   input bf_sysconf.base-code,
                                                                   input varfin-doc-tax-vat-pc,
                                                                   input varfin-doc-tax-slt-pc,
                                                                   input bf_fin-doc-tax.with-vat,
                                                                   input bf_fin-doc-tax.with-slt,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                   ).
          end.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure calc-sum:
define input parameter parmode         as   character               no-undo.
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define output parameter varznaksum-doc        as decimal no-undo.
define output parameter varznaksum-rubl       as decimal no-undo.
define output parameter varznaksum-base       as decimal no-undo.
define output parameter varznaksum-contr      as decimal no-undo.
define output parameter varznaksum-vat-doc    as decimal no-undo.
define output parameter varznaksum-vat-rubl   as decimal no-undo.
define output parameter varznaksum-vat-base   as decimal no-undo.
define output parameter varznaksum-vat-contr  as decimal no-undo.
define output parameter varznaksum-slt-doc    as decimal no-undo.
define output parameter varznaksum-slt-rubl   as decimal no-undo.
define output parameter varznaksum-slt-base   as decimal no-undo.
define output parameter varznaksum-slt-contr  as decimal no-undo.
define variable varsum-vat-doc        as   decimal               no-undo.
define variable varsum-vat-rubl       as   decimal               no-undo.
define variable varsum-vat-base       as   decimal               no-undo.
define variable varsum-vat-contr      as   decimal               no-undo.
define variable varsum-slt-doc        as   decimal               no-undo.
define variable varsum-slt-rubl       as   decimal               no-undo.
define variable varsum-slt-base       as   decimal               no-undo.
define variable varsum-slt-contr      as   decimal               no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
define buffer bf_fin-doc-tax for ub.fin-doc-tax.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2) ):
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
assign
  varsum-vat-doc   = 0
  varsum-vat-rubl  = 0
  varsum-vat-base  = 0
  varsum-vat-contr = 0
  varsum-slt-doc   = 0
  varsum-slt-rubl  = 0
  varsum-slt-base  = 0
  varsum-slt-contr = 0 .
for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                              bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
   assign
     varsum-vat-doc   = varsum-vat-doc   + bf_fin-doc-tax.sum-vat-line-doc
     varsum-vat-rubl  = varsum-vat-rubl  + bf_fin-doc-tax.sum-vat-line-rubl
     varsum-vat-base  = varsum-vat-base  + bf_fin-doc-tax.sum-vat-line-base
     varsum-vat-contr = varsum-vat-contr + bf_fin-doc-tax.sum-vat-line-contr
     varsum-slt-doc   = varsum-slt-doc   + bf_fin-doc-tax.sum-slt-line-doc
     varsum-slt-rubl  = varsum-slt-rubl  + bf_fin-doc-tax.sum-slt-line-rubl
     varsum-slt-base  = varsum-slt-base  + bf_fin-doc-tax.sum-slt-line-base
     varsum-slt-contr = varsum-slt-contr + bf_fin-doc-tax.sum-slt-line-contr
  .
end.
assign
  varznaksum-doc       = (if parmode = "close":u then bf_fin-doc.sum-doc   else - bf_fin-doc.sum-doc   )
  varznaksum-rubl      = (if parmode = "close":u then bf_fin-doc.sum-rubl  else - bf_fin-doc.sum-rubl  )
  varznaksum-base      = (if parmode = "close":u then bf_fin-doc.sum-base  else - bf_fin-doc.sum-base  )
  varznaksum-contr     = (if parmode = "close":u then bf_fin-doc.sum-contr else - bf_fin-doc.sum-contr )
  varznaksum-vat-doc   = (if parmode = "close":u then varsum-vat-doc       else - varsum-vat-doc       )
  varznaksum-vat-rubl  = (if parmode = "close":u then varsum-vat-rubl      else - varsum-vat-rubl      )
  varznaksum-vat-base  = (if parmode = "close":u then varsum-vat-base      else - varsum-vat-base      )
  varznaksum-vat-contr = (if parmode = "close":u then varsum-vat-contr     else - varsum-vat-contr     )
  varznaksum-slt-doc   = (if parmode = "close":u then varsum-slt-doc       else - varsum-slt-doc       )
  varznaksum-slt-rubl  = (if parmode = "close":u then varsum-slt-rubl      else - varsum-slt-rubl      )
  varznaksum-slt-base  = (if parmode = "close":u then varsum-slt-base      else - varsum-slt-base      )
  varznaksum-slt-contr = (if parmode = "close":u then varsum-slt-contr     else - varsum-slt-contr     )
.
end.
end procedure.
procedure check-attr-doc:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define buffer bf-payer_fin-schet         for ub.fin-schet.
define buffer bf-receiver_fin-schet      for ub.fin-schet.
define buffer bf-first_fin-code-cor-acc  for ub.fin-code-cor-acc.
define buffer bf-second_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer bf_fin-code-an-uchet       for ub.fin-code-an-uchet.
define buffer bf_fin-code-cel-nazn       for ub.fin-code-cel-nazn.
define buffer bf_fin-doc                 for ub.fin-doc.
define buffer bf_sysconf                 for ub.sysconf.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
  find first bf_sysconf where bf_sysconf.host-code = bf_fin-doc.host-code no-lock.
  if bf_fin-doc.fin-ext-doc-type = 'ппп':U  or
     bf_fin-doc.fin-ext-doc-type = 'рпп':U
     then do:
    find first bf-payer_fin-schet where bf-payer_fin-schet.host-code  = bf_fin-doc.host-code        and
                                        bf-payer_fin-schet.code-schet = bf_fin-doc.payer-code-schet no-lock no-error.
    if not available bf-payer_fin-schet then do:
      return error substitute ("Не найден счет плательщика по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.payer-code-schet).
    end.
    find first bf-receiver_fin-schet where bf-receiver_fin-schet.host-code  = bf_fin-doc.host-code           and
                                           bf-receiver_fin-schet.code-schet = bf_fin-doc.receiver-code-schet no-lock no-error.
    if not available bf-receiver_fin-schet then do:
      return error substitute ("Не найден счет получателя по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.receiver-code-schet).
    end.
    if bf-payer_fin-schet.curr-code <> bf-receiver_fin-schet.curr-code then do:
      return error substitute ("Счета плательщика и получателя документа с внутренним номером &1 на фирме &2 имеют разную валюту.", bf_fin-doc.fin-doc-code, bf_fin-doc.host-code).
    end.
  end.
  else do:
    find first bf-first_fin-code-cor-acc where bf-first_fin-code-cor-acc.host-code = bf_fin-doc.host-code and
                                               bf-first_fin-code-cor-acc.fin-code  = bf_fin-doc.cor-acc   no-lock no-error.
    if not available bf-first_fin-code-cor-acc then do:
      if bf_sysconf.is-corr-acc then do:
        return error substitute ("Не найден корреспондирующий счет по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.cor-acc).
      end.
    end.
    find first bf-second_fin-code-cor-acc where bf-second_fin-code-cor-acc.host-code = bf_fin-doc.host-code and
                                                bf-second_fin-code-cor-acc.fin-code  = bf_fin-doc.cor-acc1  no-lock no-error.
    if not available bf-second_fin-code-cor-acc then do:
      if bf_sysconf.is-cassa-acc and not bf_fin-doc.prn-doc-code begins "тех" and program-name(3) <> "trg/finddocdl.p" then do:
        return error substitute ("Не найден корреспондирующий счет по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.cor-acc1).
      end.
    end.
  end.
  find first bf_fin-code-an-uchet where bf_fin-code-an-uchet.host-code = bf_fin-doc.host-code     and
                                        bf_fin-code-an-uchet.fin-code  = bf_fin-doc.an-uchet-code no-lock no-error.
  if not available bf_fin-code-an-uchet then do:
    if bf_sysconf.is-an-uchet then do:
      return error substitute ("Не найден код аналитического учета по фирме &1. Код аналитического учета &2.", bf_fin-doc.host-code, bf_fin-doc.an-uchet-code).
    end.
  end.
  find first bf_fin-code-cel-nazn where bf_fin-code-cel-nazn.host-code = bf_fin-doc.host-code     and
                                        bf_fin-code-cel-nazn.fin-code  = bf_fin-doc.cel-nazn-code no-lock no-error.
  if not available bf_fin-code-cel-nazn then do:
    if bf_sysconf.is-code-cel-nazn then do:
      return error substitute ("Не найден код целевого назначения по фирме &1. Код целевого назначения &2.", bf_fin-doc.host-code, bf_fin-doc.cel-nazn-code).
    end.
  end.
  if not (bf_fin-doc.fin-ext-doc-type = 'пко':U      or
          bf_fin-doc.fin-ext-doc-type = 'рко':U     or
          bf_fin-doc.fin-ext-doc-type = 'ппп':U  or
          bf_fin-doc.fin-ext-doc-type = 'рпп':U or
          bf_fin-doc.fin-ext-doc-type = 'апп':U    or
          bf_fin-doc.fin-ext-doc-type = 'апр':U   ) then do:
    return error substitute ("Неизвестный расширенный тип &1 платежного документа с номером &2 внутренний номер &3.", bf_fin-doc.fin-ext-doc-type, bf_fin-doc.prn-doc-code, bf_fin-doc.fin-doc-code).
  end.
end.
end procedure.
procedure full-lock:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter paruser-name    as   character               no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
  case bf_fin-doc.fin-ext-doc-type :
    when 'пко':U    or
    when 'рко':U   or
    when 'апп':U  or
    when 'апр':U then do:
      run lib-farh_lkcordoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.cor-acc,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
      run lib-farh_lkcordoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.cor-acc1,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    when 'ппп':U  or
    when 'рпп':U then do:
      run lib-farh_lkschdoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.payer-code-schet,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
      run lib-farh_lkschdoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.receiver-code-schet,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    otherwise do:
      return error substitute ("Неизвестный расширенный тип &1 платежного документа с номером &2 внутренний номер &3.", bf_fin-doc.fin-ext-doc-type, bf_fin-doc.prn-doc-code, bf_fin-doc.fin-doc-code).
    end.
  end case.
end.
end procedure.
procedure check-sum-doc:
define input parameter parhost-code     like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code  like ub.fin-doc.fin-doc-code no-undo.
define output parameter varhave-connect as   logical                 no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
define buffer bf_fin-doc-tax for ub.fin-doc-tax.
define buffer bf_fin-connect for ub.fin-connect.
define buffer bf_clients     for ub.clients.
define buffer bf_fin-ob      for ub.fin-ob.
define buffer bf_fin-ob-tax  for ub.fin-ob-tax.
define variable varsum-vat-rubl-ob    as   decimal               no-undo.
define variable varsum-vat-base-ob    as   decimal               no-undo.
define variable varsum-vat-contr-ob   as   decimal               no-undo.
define variable varsum-vat-doc-ob     as   decimal               no-undo.
define variable varsum-slt-rubl-ob    as   decimal               no-undo.
define variable varsum-slt-base-ob    as   decimal               no-undo.
define variable varsum-slt-contr-ob   as   decimal               no-undo.
define variable varsum-slt-doc-ob     as   decimal               no-undo.
define variable varsum-vat-rubl-tot   as   decimal               no-undo.
define variable varsum-vat-base-tot   as   decimal               no-undo.
define variable varsum-vat-contr-tot  as   decimal               no-undo.
define variable varsum-vat-doc-tot    as   decimal               no-undo.
define variable varsum-slt-rubl-tot   as   decimal               no-undo.
define variable varsum-slt-base-tot   as   decimal               no-undo.
define variable varsum-slt-contr-tot  as   decimal               no-undo.
define variable varsum-slt-doc-tot    as   decimal               no-undo.
define variable varsum-line-doc       as   decimal               no-undo.
define variable varsum-line-rubl      as   decimal               no-undo.
define variable varsum-line-base      as   decimal               no-undo.
define variable varsum-line-contr     as   decimal               no-undo.
define variable varsum-vat-rubl-line  as   decimal               no-undo.
define variable varsum-vat-base-line  as   decimal               no-undo.
define variable varsum-vat-contr-line as   decimal               no-undo.
define variable varsum-vat-doc-line   as   decimal               no-undo.
define variable varsum-slt-rubl-line  as   decimal               no-undo.
define variable varsum-slt-base-line  as   decimal               no-undo.
define variable varsum-slt-contr-line as   decimal               no-undo.
define variable varsum-slt-doc-line   as   decimal               no-undo.
define variable varsum-rubl           as   decimal               no-undo.
define variable varsum-base           as   decimal               no-undo.
define variable varsum-contr          as   decimal               no-undo.
define variable varsum-doc            as   decimal               no-undo.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
  delete tt-sum-con-fin-ob-obj.
end.
for each tt-sum-con-fin-ob-tax-obj on error undo, return error return-value :
  delete tt-sum-con-fin-ob-tax-obj.
end.
for each tt-sum-fin-doc-tax on error undo, return error return-value :
  delete tt-sum-fin-doc-tax.
end.
for each tt-sum-fin-ob-tax on error undo, return error return-value :
  delete tt-sum-fin-ob-tax.
end.
find first bf_fin-connect where bf_fin-connect.host-code    = bf_fin-doc.host-code    and
                                bf_fin-connect.fin-doc-code = bf_fin-doc.fin-doc-code no-error.
if not available bf_fin-connect then do:
  if bf_fin-doc.obj-type = "":u and
     bf_fin-doc.obj-code = 0    then do:
    return error substitute ("По фирме &1 ведется финансовый учет по объектам. В платежном документе &2 с внутренним номером &3 не указан объект",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_fin-doc.obj-type and
                              bf_clients.obj-code = bf_fin-doc.obj-code no-lock no-error.
  if not available bf_clients then do:
    return error substitute ("По фирме &1 ведется финансовый учет по объектам. В платежном документе &2 с внутренним номером &3 указан объект &4 &5 которого нет в справочнике.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             bf_fin-doc.obj-type,
                             bf_fin-doc.obj-code).
  end.
  assign
    varhave-connect = no.
end.
else do:
  assign
    varhave-connect = yes.
  for each bf_fin-connect where bf_fin-connect.host-code    = bf_fin-doc.host-code    and
                                bf_fin-connect.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
    find first bf_fin-ob where bf_fin-ob.host-code = bf_fin-connect.host-code   and
                               bf_fin-ob.doc-code  = bf_fin-connect.fin-ob-code no-error.
    if not available bf_fin-ob then do:
      return error substitute ("Финансовый документ по фирме &1 с внутренним номером &2 имеет связь с финансовым обязательством с внутренним номером &3. Но этого финансового обязательства нет в базе данных.",
                               bf_fin-doc.host-code,
                               bf_fin-doc.fin-doc-code,
                               bf_fin-ob.doc-code).
    end.
    if bf_fin-ob.contract-code <> bf_fin-doc.contract-code then do:
      return error substitute ("Финансовый документ по фирме &1 с внутренним номером &2 имеет связь с финансовым обязательством с внутренним номером &3. Внутренний номер договора по финансовому документу &4. Внутренний номер договора по финансовому обязательству &5. Это недопустимо.",
                               bf_fin-doc.host-code,
                               bf_fin-doc.fin-doc-code,
                               bf_fin-ob.doc-code,
                               bf_fin-doc.contract-code,
                               bf_fin-ob.contract-code).
    end.
    assign
      varsum-rubl  = varsum-rubl  + bf_fin-connect.sum-rubl
      varsum-base  = varsum-base  + bf_fin-connect.sum-base
      varsum-contr = varsum-contr + bf_fin-connect.sum-contr
      varsum-doc   = varsum-doc   + bf_fin-connect.sum-doc.
    find first tt-sum-con-fin-ob-obj where tt-sum-con-fin-ob-obj.obj-type = bf_fin-ob.obj-type and
                                           tt-sum-con-fin-ob-obj.obj-code = bf_fin-ob.obj-code no-error.
    if not available tt-sum-con-fin-ob-obj then do:
      create tt-sum-con-fin-ob-obj.
      assign
        tt-sum-con-fin-ob-obj.obj-type = bf_fin-ob.obj-type
        tt-sum-con-fin-ob-obj.obj-code = bf_fin-ob.obj-code
      .
    end.
    assign
      tt-sum-con-fin-ob-obj.sum-base  = tt-sum-con-fin-ob-obj.sum-base  + bf_fin-connect.sum-base
      tt-sum-con-fin-ob-obj.sum-rubl  = tt-sum-con-fin-ob-obj.sum-rubl  + bf_fin-connect.sum-rubl
      tt-sum-con-fin-ob-obj.sum-contr = tt-sum-con-fin-ob-obj.sum-contr + bf_fin-connect.sum-contr
      tt-sum-con-fin-ob-obj.sum-doc   = tt-sum-con-fin-ob-obj.sum-doc   + bf_fin-connect.sum-doc
    .
    for each bf_fin-ob-tax where bf_fin-ob-tax.host-code = bf_fin-ob.host-code and
                                 bf_fin-ob-tax.doc-code  = bf_fin-ob.doc-code  on error undo, return error return-value :
      find first tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.obj-type = bf_fin-ob.obj-type     and
                                                 tt-sum-con-fin-ob-tax-obj.obj-code = bf_fin-ob.obj-code     and
                                                 tt-sum-con-fin-ob-tax-obj.vat-pc   = bf_fin-ob-tax.vat-pc   and
                                                 tt-sum-con-fin-ob-tax-obj.slt-pc   = bf_fin-ob-tax.slt-pc   and
                                                 tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-ob-tax.with-vat and
                                                 tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-ob-tax.with-slt no-error.
      if not available tt-sum-con-fin-ob-tax-obj then do:
        create tt-sum-con-fin-ob-tax-obj.
        assign
          tt-sum-con-fin-ob-tax-obj.obj-type = bf_fin-ob.obj-type
          tt-sum-con-fin-ob-tax-obj.obj-code = bf_fin-ob.obj-code
          tt-sum-con-fin-ob-tax-obj.vat-pc   = bf_fin-ob-tax.vat-pc
          tt-sum-con-fin-ob-tax-obj.slt-pc   = bf_fin-ob-tax.slt-pc
          tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-ob-tax.with-vat
          tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-ob-tax.with-slt
        .
      end.
      if bf_fin-ob.sum-rubl = bf_fin-connect.sum-rubl then do:
        assign
          varsum-line-doc       = bf_fin-ob-tax.sum-line-doc
          varsum-line-rubl      = bf_fin-ob-tax.sum-line-rubl
          varsum-line-base      = bf_fin-ob-tax.sum-line-base
          varsum-line-contr     = bf_fin-ob-tax.sum-line-contr
          varsum-vat-rubl-line  = bf_fin-ob-tax.sum-vat-line-rubl
          varsum-vat-base-line  = bf_fin-ob-tax.sum-vat-line-base
          varsum-vat-contr-line = bf_fin-ob-tax.sum-vat-line-contr
          varsum-vat-doc-line   = bf_fin-ob-tax.sum-vat-line-doc
          varsum-slt-rubl-line  = bf_fin-ob-tax.sum-slt-line-rubl
          varsum-slt-base-line  = bf_fin-ob-tax.sum-slt-line-base
          varsum-slt-contr-line = bf_fin-ob-tax.sum-slt-line-contr
          varsum-slt-doc-line   = bf_fin-ob-tax.sum-slt-line-doc
        .
      end.
      else do:
        assign
          varsum-line-doc       = bf_fin-ob-tax.sum-line-doc        * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-rubl      = bf_fin-ob-tax.sum-line-rubl       * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-base      = bf_fin-ob-tax.sum-line-base       * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-contr     = bf_fin-ob-tax.sum-line-contr      * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-rubl-line  = bf_fin-ob-tax.sum-vat-line-rubl   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-base-line  = bf_fin-ob-tax.sum-vat-line-base   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-contr-line = bf_fin-ob-tax.sum-vat-line-contr  * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-doc-line   = bf_fin-ob-tax.sum-vat-line-doc    * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-rubl-line  = bf_fin-ob-tax.sum-slt-line-rubl   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-base-line  = bf_fin-ob-tax.sum-slt-line-base   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-contr-line = bf_fin-ob-tax.sum-slt-line-contr  * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-doc-line   = bf_fin-ob-tax.sum-slt-line-doc    * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
        .
      end.
      assign
        tt-sum-con-fin-ob-tax-obj.sum-doc        = tt-sum-con-fin-ob-tax-obj.sum-doc        + varsum-line-doc
        tt-sum-con-fin-ob-tax-obj.sum-rubl       = tt-sum-con-fin-ob-tax-obj.sum-rubl       + varsum-line-rubl
        tt-sum-con-fin-ob-tax-obj.sum-base       = tt-sum-con-fin-ob-tax-obj.sum-base       + varsum-line-base
        tt-sum-con-fin-ob-tax-obj.sum-contr      = tt-sum-con-fin-ob-tax-obj.sum-contr      + varsum-line-contr
        tt-sum-con-fin-ob-tax-obj.sum-vat-rubl   = tt-sum-con-fin-ob-tax-obj.sum-vat-rubl   + varsum-vat-rubl-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-base   = tt-sum-con-fin-ob-tax-obj.sum-vat-base   + varsum-vat-base-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-contr  = tt-sum-con-fin-ob-tax-obj.sum-vat-contr  + varsum-vat-contr-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-doc    = tt-sum-con-fin-ob-tax-obj.sum-vat-doc    + varsum-vat-doc-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-rubl   = tt-sum-con-fin-ob-tax-obj.sum-slt-rubl   + varsum-slt-rubl-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-base   = tt-sum-con-fin-ob-tax-obj.sum-slt-base   + varsum-slt-base-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-contr  = tt-sum-con-fin-ob-tax-obj.sum-slt-contr  + varsum-slt-contr-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-doc    = tt-sum-con-fin-ob-tax-obj.sum-slt-doc    + varsum-slt-doc-line
      .
      assign
        varsum-vat-rubl-ob  = varsum-vat-rubl-ob  + varsum-vat-rubl-line
        varsum-vat-base-ob  = varsum-vat-base-ob  + varsum-vat-base-line
        varsum-vat-contr-ob = varsum-vat-contr-ob + varsum-vat-contr-line
        varsum-vat-doc-ob   = varsum-vat-doc-ob   + varsum-vat-doc-line
        varsum-slt-rubl-ob  = varsum-slt-rubl-ob  + varsum-slt-rubl-line
        varsum-slt-base-ob  = varsum-slt-base-ob  + varsum-slt-base-line
        varsum-slt-contr-ob = varsum-slt-contr-ob + varsum-slt-contr-line
        varsum-slt-doc-ob   = varsum-slt-doc-ob   + varsum-slt-doc-line
      .
      find first tt-sum-fin-ob-tax where tt-sum-fin-ob-tax.vat-pc   = bf_fin-ob-tax.vat-pc   and
                                         tt-sum-fin-ob-tax.slt-pc   = bf_fin-ob-tax.slt-pc   and
                                         tt-sum-fin-ob-tax.with-vat = bf_fin-ob-tax.with-vat and
                                         tt-sum-fin-ob-tax.with-slt = bf_fin-ob-tax.with-slt no-error.
      if not available tt-sum-fin-ob-tax then do:
        create tt-sum-fin-ob-tax.
        assign
          tt-sum-fin-ob-tax.vat-pc   = bf_fin-ob-tax.vat-pc
          tt-sum-fin-ob-tax.slt-pc   = bf_fin-ob-tax.slt-pc
          tt-sum-fin-ob-tax.with-vat = bf_fin-ob-tax.with-vat
          tt-sum-fin-ob-tax.with-slt = bf_fin-ob-tax.with-slt
        .
      end.
      assign
        tt-sum-fin-ob-tax.sum-vat-rubl  = tt-sum-fin-ob-tax.sum-vat-rubl  + varsum-vat-rubl-line
        tt-sum-fin-ob-tax.sum-vat-base  = tt-sum-fin-ob-tax.sum-vat-base  + varsum-vat-base-line
        tt-sum-fin-ob-tax.sum-vat-contr = tt-sum-fin-ob-tax.sum-vat-contr + varsum-vat-contr-line
        tt-sum-fin-ob-tax.sum-vat-doc   = tt-sum-fin-ob-tax.sum-vat-doc   + varsum-vat-doc-line
        tt-sum-fin-ob-tax.sum-slt-rubl  = tt-sum-fin-ob-tax.sum-slt-rubl  + varsum-slt-rubl-line
        tt-sum-fin-ob-tax.sum-slt-base  = tt-sum-fin-ob-tax.sum-slt-base  + varsum-slt-base-line
        tt-sum-fin-ob-tax.sum-slt-contr = tt-sum-fin-ob-tax.sum-slt-contr + varsum-slt-contr-line
        tt-sum-fin-ob-tax.sum-slt-doc   = tt-sum-fin-ob-tax.sum-slt-doc   + varsum-slt-doc-line
      .
    end.
  end.
  for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
    find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = bf_fin-doc-tax.vat-pc   and
                                        tt-sum-fin-doc-tax.slt-pc   = bf_fin-doc-tax.slt-pc   and
                                        tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                        tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
    if not available tt-sum-fin-doc-tax then do:
      create tt-sum-fin-doc-tax.
      assign
        tt-sum-fin-doc-tax.vat-pc   = bf_fin-doc-tax.vat-pc
        tt-sum-fin-doc-tax.slt-pc   = bf_fin-doc-tax.slt-pc
        tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
        tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
      .
    end.
    assign
      tt-sum-fin-doc-tax.sum-vat-rubl  = tt-sum-fin-doc-tax.sum-vat-rubl  + bf_fin-doc-tax.sum-vat-line-rubl
      tt-sum-fin-doc-tax.sum-vat-base  = tt-sum-fin-doc-tax.sum-vat-base  + bf_fin-doc-tax.sum-vat-line-base
      tt-sum-fin-doc-tax.sum-vat-contr = tt-sum-fin-doc-tax.sum-vat-contr + bf_fin-doc-tax.sum-vat-line-contr
      tt-sum-fin-doc-tax.sum-vat-doc   = tt-sum-fin-doc-tax.sum-vat-doc   + bf_fin-doc-tax.sum-vat-line-doc
      tt-sum-fin-doc-tax.sum-slt-rubl  = tt-sum-fin-doc-tax.sum-slt-rubl  + bf_fin-doc-tax.sum-slt-line-rubl
      tt-sum-fin-doc-tax.sum-slt-base  = tt-sum-fin-doc-tax.sum-slt-base  + bf_fin-doc-tax.sum-slt-line-base
      tt-sum-fin-doc-tax.sum-slt-contr = tt-sum-fin-doc-tax.sum-slt-contr + bf_fin-doc-tax.sum-slt-line-contr
      tt-sum-fin-doc-tax.sum-slt-doc   = tt-sum-fin-doc-tax.sum-slt-doc   + bf_fin-doc-tax.sum-slt-line-doc
    .
    assign
      varsum-vat-rubl-tot  = varsum-vat-rubl-tot  +  bf_fin-doc-tax.sum-vat-line-rubl
      varsum-vat-base-tot  = varsum-vat-base-tot  +  bf_fin-doc-tax.sum-vat-line-base
      varsum-vat-contr-tot = varsum-vat-contr-tot +  bf_fin-doc-tax.sum-vat-line-contr
      varsum-vat-doc-tot   = varsum-vat-doc-tot   +  bf_fin-doc-tax.sum-vat-line-doc
      varsum-slt-rubl-tot  = varsum-slt-rubl-tot  +  bf_fin-doc-tax.sum-slt-line-rubl
      varsum-slt-base-tot  = varsum-slt-base-tot  +  bf_fin-doc-tax.sum-slt-line-base
      varsum-slt-contr-tot = varsum-slt-contr-tot +  bf_fin-doc-tax.sum-slt-line-contr
      varsum-slt-doc-tot   = varsum-slt-doc-tot   +  bf_fin-doc-tax.sum-slt-line-doc
    .
  end.
end.
for each tt-sum-fin-doc-tax on error undo, return error return-value :
  find first tt-sum-fin-ob-tax where tt-sum-fin-ob-tax.vat-pc   = tt-sum-fin-doc-tax.vat-pc   and
                                     tt-sum-fin-ob-tax.slt-pc   = tt-sum-fin-doc-tax.slt-pc   and
                                     tt-sum-fin-ob-tax.with-vat = tt-sum-fin-doc-tax.with-vat         and
                                     tt-sum-fin-ob-tax.with-slt = tt-sum-fin-doc-tax.with-slt         no-error.
  if not available tt-sum-fin-ob-tax then do:
    return error substitute ("Финансовый документ по фирме &1 номер &2 с внутренним номером &3 имеет строку по налогам НДС &4, НП &5, с НДС &6, с НП &7. Но у финобязательств с которыми он имеет связи такой строки нет. Это недопустимо.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             tt-sum-fin-doc-tax.vat-pc,
                             tt-sum-fin-doc-tax.slt-pc,
                             tt-sum-fin-doc-tax.with-vat,
                             tt-sum-fin-doc-tax.with-slt).
  end.
end.
for each tt-sum-fin-ob-tax on error undo, return error return-value :
  find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = tt-sum-fin-ob-tax.vat-pc   and
                                      tt-sum-fin-doc-tax.slt-pc   = tt-sum-fin-ob-tax.slt-pc   and
                                      tt-sum-fin-doc-tax.with-vat = tt-sum-fin-ob-tax.with-vat and
                                      tt-sum-fin-doc-tax.with-slt = tt-sum-fin-ob-tax.with-slt no-error.
  if not available tt-sum-fin-ob-tax then do:
    return error substitute ("По финансовым обязательствам с которыми у финанасового документа по фирме &1 номер &2 с внутренним номером &3 есть связь есть строки по налогам НДС &4, НП &5, с НДС &6, с НП &7. Но у финансового документа такой строки нет. Это недопустимо.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             tt-sum-fin-ob-tax.vat-pc,
                             tt-sum-fin-ob-tax.slt-pc,
                             tt-sum-fin-ob-tax.with-vat,
                             tt-sum-fin-ob-tax.with-slt).
  end.
end.
for each tt-sum-con-fin-ob-tax-obj on error undo, return error return-value :
  find first tt-sum-con-fin-ob-obj where tt-sum-con-fin-ob-obj.obj-type = tt-sum-con-fin-ob-tax-obj.obj-type and
                                         tt-sum-con-fin-ob-obj.obj-code = tt-sum-con-fin-ob-tax-obj.obj-code .
  assign
    tt-sum-con-fin-ob-obj.sum-vat-rubl  = tt-sum-con-fin-ob-obj.sum-vat-rubl  +  tt-sum-con-fin-ob-tax-obj.sum-vat-rubl
    tt-sum-con-fin-ob-obj.sum-vat-base  = tt-sum-con-fin-ob-obj.sum-vat-base  +  tt-sum-con-fin-ob-tax-obj.sum-vat-base
    tt-sum-con-fin-ob-obj.sum-vat-contr = tt-sum-con-fin-ob-obj.sum-vat-contr +  tt-sum-con-fin-ob-tax-obj.sum-vat-contr
    tt-sum-con-fin-ob-obj.sum-vat-doc   = tt-sum-con-fin-ob-obj.sum-vat-doc   +  tt-sum-con-fin-ob-tax-obj.sum-vat-doc
    tt-sum-con-fin-ob-obj.sum-slt-rubl  = tt-sum-con-fin-ob-obj.sum-slt-rubl  +  tt-sum-con-fin-ob-tax-obj.sum-slt-rubl
    tt-sum-con-fin-ob-obj.sum-slt-base  = tt-sum-con-fin-ob-obj.sum-slt-base  +  tt-sum-con-fin-ob-tax-obj.sum-slt-base
    tt-sum-con-fin-ob-obj.sum-slt-contr = tt-sum-con-fin-ob-obj.sum-slt-contr +  tt-sum-con-fin-ob-tax-obj.sum-slt-contr
    tt-sum-con-fin-ob-obj.sum-slt-doc   = tt-sum-con-fin-ob-obj.sum-slt-doc   +  tt-sum-con-fin-ob-tax-obj.sum-slt-doc
  .
end.
end.
end procedure.
procedure lib-farh_finchkdb :
define input parameter p-host-code     like ub.fin-doc.host-code    no-undo.
define input parameter p-fin-doc-code  like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fin-ext-doc-type as character no-undo .
define input parameter p-cash-book-place as character no-undo .
define input parameter p-is-auto-obj as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-mess as character no-undo .
define variable v-curr-db-num as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-firm as logical no-undo .
define variable v-cash as logical no-undo .
define variable v-obj-place-to-compare as character no-undo .
define variable v-is-auto-obj as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
  if (p-obj-type = ''
          and
          p-obj-code = 0) then do:
    v-firm = yes.
  end.
  else do:
    v-obj-place-to-compare = p-obj-type + string(p-obj-code, "99999").
  end.
  if lookup(p-fin-ext-doc-type, 'пко,рко':U) > 0 then do:
    v-cash = yes.
  end.
  case v-firm:
    when yes then do:
      case v-curr-db-num:
        when buf_sysconf.firm-db-num then do:
          p-mess = "".
      p-ok = yes.
      return.
    end.
        otherwise do:
          p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) не указан объект&3"+
                              "такие документы могут создаваться/изменяться/удаляться только в главной БД фирмы&3" +
                              "номер текущей БД &4, номер ГЛАВНОЙ БД фирмы &5"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,chr(10)
                                ,v-curr-db-num
                                ,buf_sysconf.firm-db-num
                                ).
          return.
        end.
      end case.
    end.
    when no then do:
    find first buf_clients where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-lock no-error.
    if not available buf_clients then do:
      return error substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4, которого нет в справочнике."
                              ,p-host-code
                              ,p-fin-doc-code
                              ,p-obj-type
                              ,p-obj-code).
    end.
      case v-cash:
        when no then do:
          case v-curr-db-num:
            when buf_sysconf.firm-db-num then do:
              p-ok = yes.
              return.
            end.
            otherwise do:
              p-mess = substitute ("В Платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                  "документы типа &6 могут создаваться/изменяться/удаляться только в главной БД фирмы&5" +
                                  "номер текущей БД &7, номер главной БД фирмы &8"
                                    ,p-host-code
                                    ,p-fin-doc-code
                                    ,p-obj-type
                                    ,p-obj-code
                                    ,chr(10)
                                    ,p-fin-ext-doc-type
                                    ,v-curr-db-num
                                    ,buf_sysconf.firm-db-num).
              return.
            end.
          end case.
        end.
        when yes then do:
          define variable v-cash-book as integer no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-character8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
          case v-cash-book:
            when integer('1':U) then do:
              case v-curr-db-num:
                when v-obj-db-num then do:
                  case p-cash-book-place:
                    when '' then do:
                      p-mess = substitute ("В Платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                           "документы типа &6 могут создаваться/изменяться/удаляться на БД объекта,&5" +
                                           "если на нем ведется Операционная кассовая книга,&5" +
                                           "но при этом в платеже должна быть правильно указана Операционная касса"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,p-obj-type
                                ,p-obj-code
                                ,chr(10)
                                ,p-fin-ext-doc-type
                                            ).
          return.
        end.
                    when v-obj-place-to-compare then do:
                      p-mess = "".
          p-ok = yes.
        end.
                    otherwise do:
                      undo, return error substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , chr(10)
                                            ).
                    end.
                  end.
                end.
                when buf_sysconf.firm-db-num then do:
                  case p-cash-book-place:
                    when '' then do:
                      if p-is-auto-obj then do:
                        v-is-auto-obj = p-is-auto-obj.
                      end.
      else do:
                        run lib-farh_fautoobj in this-procedure ( input p-host-code
                                                                ,input p-fin-doc-code
                                                                ,output v-is-auto-obj) no-error.
                      end.
                      case v-is-auto-obj:
                        when yes then do:
                          p-ok = yes.
                        end.
                        otherwise do:
          p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                              "на БД объекта ведется Операционная кассовая книга&5" +
                                              "такие документы типа &6 могут создаваться/изменяться/удаляться только в БД объекта&5" +
                                              "номер текущей БД &7, ОПЕРАЦИОННАЯ КАССОВАЯ КНИГА ведется в БД &8"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,p-obj-type
                                ,p-obj-code
                                ,chr(10)
                                ,p-fin-ext-doc-type
                                ,v-curr-db-num
                                                ,v-obj-db-num).
        end.
                      end.
                    end.
                    when v-obj-place-to-compare then do:
                      p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                          "и указана Операционная касса &6,поэтому он может создаваться/изменяться/удаляться ТОЛЬКО&5" +
                                          "в главной БД фирмы и ТОЛЬКО если там ведется Операционная кассовая книга&5" +
                                          "номер текущей БД &7, Операционная кассовая книга ведется в БД &8"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,chr(10)
                                            ,p-fin-ext-doc-type
                                            ,v-curr-db-num
                                            ,v-obj-db-num).
                    end.
                    otherwise do:
                      undo, return error  substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , chr(10)
                                            ).
                    end.
                  end case.
                end.
                otherwise do:
                  p-mess = substitute ("Платежный документ с внутренним номером &2 (фирма &1) не может создаватся/изменяться/удалястья в БД &3"
                                        ,p-host-code
                                        ,p-fin-doc-code
                                        ,v-curr-db-num
                                        ).
                end.
              end case.
            end.
            when integer('0':U) then do:
              case v-curr-db-num:
                when buf_sysconf.firm-db-num then do:
                  case p-cash-book-place:
                    when '' then do:
                      p-mess = "".
          p-ok = yes.
        end.
                    when v-obj-place-to-compare then do:
                      p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                          "и указана Операционная касса &6,однакоу он может создаваться/изменяться/удаляться ТОЛЬКО&5" +
                                          "в главной БД фирмы потому что кассовая книга для &3&4 ведется там&5" +
                                          "номер текущей БД &7, Операционная кассовая книга ведется в БД &8"
                              ,p-host-code
                              ,p-fin-doc-code
                              ,p-obj-type
                              ,p-obj-code
                              ,chr(10)
                              ,p-fin-ext-doc-type
                              ,v-curr-db-num
                              ,buf_sysconf.firm-db-num).
      end.
                    otherwise do:
                      undo, return error  substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , chr(10)
                                            ).
                    end.
                  end case.
                end.
                otherwise do:
                  p-mess = substitute ("Платежный документ с внутренним номером &2 (фирма &1) не может создаваться/изменяться/удаляться&3" +
                                       " не в главной БД фирмы, потому что кассовая книга для объекта ведется в Главной БД фирмы&3" +
                                       "Текущая БД - &4 Главная Бд фирмы - &5"
                                        ,p-host-code
                                        ,p-fin-doc-code
                                        ,chr(10)
                                        ,v-curr-db-num
                                        ,buf_sysconf.firm-db-num
                                        ).
                end.
              end case.
            end.
            otherwise do:
              undo, return error substitute("Неверное значение места ведения кассовой книги (&3) для платежных документов по &1&2"
                                           ,p-obj-type
                                           ,p-obj-code
                                           ,v-cash-book).
      end.
          end case.
        end.
      end case.
    end.
  end case.
end.
end procedure.
procedure lib-farh_fautoobj :
define input parameter p-host-code as integer no-undo .
define input parameter p-fin-doc-code as integer no-undo .
define output parameter p-is-auto-obj as logical no-undo .
define buffer buf_fin-connect  for ub.fin-connect.
define buffer buf_fin-ob  for ub.fin-ob.
find first buf_fin-connect no-lock where
        buf_fin-connect.host-code      = p-host-code
    AND buf_fin-connect.fin-doc-code   = p-fin-doc-code no-error.
if available buf_fin-connect then do:
  find first buf_fin-ob no-lock where
            buf_fin-ob.doc-code =  buf_fin-connect.fin-ob-code no-error .
  if available buf_fin-ob and
  not (buf_fin-ob.obj-type = "":U
        and  buf_fin-ob.obj-code  = 0) then do:
    assign
    p-is-auto-obj = yes
    .
  end.
end.
end procedure.
