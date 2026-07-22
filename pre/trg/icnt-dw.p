block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.icnt-doc old buffer old-doc .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа счетчиков ТРК".
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
define variable v-host-code like ub.icnt-doc.host-code no-undo .
define buffer buf_icnt-doc for ub.icnt-doc .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.icnt-doc.obj-type
      and ub.clients.obj-code = ub.icnt-doc.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Не найден объект" ub.icnt-doc.obj-type ub.icnt-doc.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  run trg/chkdocnm.p
    (input ub.icnt-doc.doc-code
    ,input 'icnt-doc':U
    ,input recid(ub.icnt-doc)
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке уникальности кода документа" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if  ub.icnt-doc.status_ <> 'новый':U
  and ub.icnt-doc.status_ <> 'факт':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный статус документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Статус" ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if  ub.icnt-doc.doc-type <> 'инв-сч-трк':U
  and ub.icnt-doc.doc-type <> 'сч-трк-погр':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный тип документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Тип" ub.icnt-doc.doc-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if  ub.icnt-doc.ext-doc-type <> 'ip':U
  and ub.icnt-doc.ext-doc-type <> 'em':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный расш.тип документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Расш.Тип" ub.icnt-doc.ext-doc-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.icnt-doc.user-db-num
  ,output ub.icnt-doc.user-name
  ,output ub.icnt-doc.sys-date
  ,output ub.icnt-doc.sys-time
  ,output ub.icnt-doc.sys-time-int
  )  .
  end.
  if old-doc.status_ = ub.icnt-doc.status_ then do:
    return .
  end.
  run str/chk-icnt.p (input recid(ub.icnt-doc)) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке документа счетчиков ТРК" skip
      "Документ " ub.icnt-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news then do:
  end.
  if not new ub.icnt-doc
  and old-doc.status_     = 'факт':U
  and ub.icnt-doc.status_ <> 'факт':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " ub.icnt-doc.doc-code skip
      "Документ закрыт до статуса" 'факт':U skip
      "Нельзя изменить статус на " ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.icnt-doc.obj-type
  ,input  ub.icnt-doc.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Документ сверки" ub.icnt-doc.doc-code skip
     "Тип объекта"     ub.icnt-doc.obj-type skip
     "Код объекта"     ub.icnt-doc.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.icnt-doc.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ сверки" ub.icnt-doc.doc-code skip
      "Объект"  ub.icnt-doc.obj-type " " ub.icnt-doc.obj-code skip
      "Фирма"   ub.icnt-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.icnt-doc.status_ = 'факт':U then do:
    run change-status-fact in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении программы change-status-fact" skip
        "Документ счетчиков ТРК " ub.icnt-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  if  not g#news
  and ub.icnt-doc.creid = "" then do:
    assign
      ub.icnt-doc.creid = g#userid
    .
  end.
  if not g#news then do:
    if ub.icnt-doc.status_ <> 'новый':U then do:
      run str/callnews.p
         (input 'icnt-doc':U
         ,input (buffer ub.icnt-doc:handle)
         ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать icnt-doc для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'icnt-doc':U
        , input ( buffer ub.icnt-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
  if ub.icnt-doc.status_ = 'факт':U then
  do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_icnt-doc':U
  ,input  buffer old-doc:handle
  ,input  buffer ub.icnt-doc:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
      then
    do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
        , chr(10)
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
end.
procedure change-status-fact :
  do
  on error undo, return error
  :
    if g#news then do:
      if ub.icnt-doc.fact-order = ?
      or ub.icnt-doc.fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан фактический номер документа счетчиков ТРК" skip
          "Документ  счетчиков ТРК" ub.icnt-doc.doc-code skip
          "fact-order" ub.icnt-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if not g#news then do:
      run gbl/chk-date.p
        (input ub.icnt-doc.obj-type
        ,input ub.icnt-doc.obj-code
        ,input ub.icnt-doc.fact-date
        ,input ub.icnt-doc.fact-time
        ,input ub.icnt-doc.shift-date
        ,input ub.icnt-doc.shift-num
        ,input yes
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при установке дат, времен, смен в документе счетчиков ТРК." skip
          "Документ"          ub.icnt-doc.doc-code skip
          "Дата"              ub.icnt-doc.fact-date skip
          "Время"             ub.icnt-doc.fact-time skip
          "Дата начала смены" ub.icnt-doc.shift-date skip
          "Порядок смены"       ub.icnt-doc.shift-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if not g#news then do:
      if ub.icnt-doc.fact-order > 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер документа счетчиков ТРК " skip
          "Документ счетчиков ТРК " ub.icnt-doc.doc-code skip
          "fact-order" ub.icnt-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-fact-num as integer no-undo .
      assign
        v-fact-num = next-value (s-trn-fact, ub)
      .
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      define variable l-shift-on as logical no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.icnt-doc.obj-type
  ,input  ub.icnt-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запуске процедуры objat" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      run factord in this-procedure
        (input  ub.icnt-doc.fact-date
        ,input  ub.icnt-doc.fact-time
        ,input  v-fact-num
        ,input  ub.icnt-doc.shift-date
        ,input  ub.icnt-doc.shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера документа счетчиков ТРК" skip
          "doc-num"                 ub.icnt-doc.doc-code    skip
          "fact-date"               ub.icnt-doc.fact-date   skip
          "fact-time"               ub.icnt-doc.fact-time   skip
          "fact-num"                v-fact-num             skip
          "shift-date"              ub.icnt-doc.shift-date  skip
          "shift-num"               ub.icnt-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        ub.icnt-doc.fact-order = v-fact-order
      .
    end.
    if ub.icnt-doc.doc-type = 'инв-сч-трк':U then do:
      find first buf_icnt-doc no-lock
        where buf_icnt-doc.obj-type   =  ub.icnt-doc.obj-type
          and buf_icnt-doc.obj-code   =  ub.icnt-doc.obj-code
          and buf_icnt-doc.status_    =  ub.icnt-doc.status_
          and buf_icnt-doc.fact-order >= ub.icnt-doc.fact-order
          and recid(buf_icnt-doc)     <> recid(ub.icnt-doc)
        no-error .
      if available buf_icnt-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Имеется документ счетчиков ТРК с более высоким порядковым номером, чем текущий." skip
          "Закрываемый документ" skip
          chr(9) "Номер"                      ub.icnt-doc.doc-code    skip
          chr(9) "Факт-Номер"                 ub.icnt-doc.fact-order  skip
          chr(9) "Дата фактического закрытия" ub.icnt-doc.fact-date   skip
          chr(9) "Дата начала смены"          ub.icnt-doc.shift-date  skip
          chr(9) "Номер смены"                ub.icnt-doc.shift-num   skip
          chr(9) "Порядок смены"              ub.icnt-doc.shift-num   skip
          "Существует документ счетчиков ТРК " skip
          chr(9) "Номер"                      buf_icnt-doc.doc-code   skip
          chr(9) "Факт-Номер"                 buf_icnt-doc.fact-order skip
          chr(9) "Дата фактического закрытия" buf_icnt-doc.fact-date  skip
          chr(9) "Дата начала смены"          buf_icnt-doc.shift-date skip
          chr(9) "Номер смены"                buf_icnt-doc.shift-name skip
          chr(9) "Порядок смены"              buf_icnt-doc.shift-num skip
          view-as alert-box error .
        undo , return error .
      end.
    end.
  end.
end procedure.
