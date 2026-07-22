block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 09/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00199000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00199000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
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
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter varcall-back           as handle no-undo.
define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.
define buffer buf_clients for ub.clients.
find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
define variable var-fact-order-findoc as decimal no-undo.
define buffer arh-fin-doc-an                  for ub.arh-fin-doc-an.
define buffer buf_arh-fin-doc-an              for ub.arh-fin-doc-an.
define buffer arh-fin-doc-an-attr             for ub.arh-fin-doc-an-attr.
define buffer arh-fin-doc-an-nal              for ub.arh-fin-doc-an-nal.
define buffer buf_arh-fin-doc-an-nal          for ub.arh-fin-doc-an-nal.
define buffer arh-fin-doc-an-nal-attr         for ub.arh-fin-doc-an-nal-attr.
define buffer arh-fin-doc-an-nal-obj          for ub.arh-fin-doc-an-nal-obj.
define buffer buf_arh-fin-doc-an-nal-obj      for ub.arh-fin-doc-an-nal-obj.
define buffer arh-fin-doc-an-nal-obj-attr     for ub.arh-fin-doc-an-nal-obj-attr.
define buffer arh-fin-doc-an-obj              for ub.arh-fin-doc-an-obj.
define buffer buf_arh-fin-doc-an-obj          for ub.arh-fin-doc-an-obj.
define buffer arh-fin-doc-an-obj-attr         for ub.arh-fin-doc-an-obj-attr.
define buffer arh-fin-doc-c-s-tax-nal-obj     for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer buf_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer arh-fin-doc-c-schet-tax-nal     for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer buf_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer arh-fin-doc-contr-s-nal-obj     for ub.arh-fin-doc-contr-s-nal-obj.
define buffer buf_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer arh-fin-doc-contr-s-tax-obj     for ub.arh-fin-doc-contr-s-tax-obj.
define buffer buf_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer arh-fin-doc-contr-schet         for ub.arh-fin-doc-contr-schet.
define buffer buf_arh-fin-doc-contr-schet     for ub.arh-fin-doc-contr-schet.
define buffer arh-fin-doc-contr-schet-attr    for ub.arh-fin-doc-contr-schet-attr.
define buffer arh-fin-doc-contr-schet-nal     for ub.arh-fin-doc-contr-schet-nal.
define buffer buf_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer arh-fin-doc-contr-schet-obj     for ub.arh-fin-doc-contr-schet-obj.
define buffer buf_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer arh-fin-doc-contr-schet-tax     for ub.arh-fin-doc-contr-schet-tax.
define buffer buf_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer arh-fin-doc-s-tax-nal-obj       for ub.arh-fin-doc-s-tax-nal-obj.
define buffer buf_arh-fin-doc-s-tax-nal-obj   for ub.arh-fin-doc-s-tax-nal-obj.
define buffer arh-fin-doc-schet               for ub.arh-fin-doc-schet.
define buffer buf_arh-fin-doc-schet           for ub.arh-fin-doc-schet.
define buffer arh-fin-doc-schet-attr          for ub.arh-fin-doc-schet-attr.
define buffer arh-fin-doc-schet-nal           for ub.arh-fin-doc-schet-nal.
define buffer buf_arh-fin-doc-schet-nal       for ub.arh-fin-doc-schet-nal.
define buffer arh-fin-doc-schet-nal-attr      for ub.arh-fin-doc-schet-nal-attr.
define buffer arh-fin-doc-schet-nal-obj       for ub.arh-fin-doc-schet-nal-obj.
define buffer buf_arh-fin-doc-schet-nal-obj   for ub.arh-fin-doc-schet-nal-obj.
define buffer arh-fin-doc-schet-obj           for ub.arh-fin-doc-schet-obj.
define buffer buf_arh-fin-doc-schet-obj       for ub.arh-fin-doc-schet-obj.
define buffer arh-fin-doc-schet-obj-attr      for ub.arh-fin-doc-schet-obj-attr.
define buffer arh-fin-doc-schet-tax           for ub.arh-fin-doc-schet-tax.
define buffer buf_arh-fin-doc-schet-tax       for ub.arh-fin-doc-schet-tax.
define buffer arh-fin-doc-schet-tax-attr      for ub.arh-fin-doc-schet-tax-attr.
define buffer arh-fin-doc-schet-tax-nal       for ub.arh-fin-doc-schet-tax-nal.
define buffer buf_arh-fin-doc-schet-tax-nal   for ub.arh-fin-doc-schet-tax-nal.
define buffer arh-fin-doc-schet-tax-obj       for ub.arh-fin-doc-schet-tax-obj.
define buffer buf_arh-fin-doc-schet-tax-obj   for ub.arh-fin-doc-schet-tax-obj.
define buffer arh-fin-ob-contr                for ub.arh-fin-ob-contr.
define buffer buf_arh-fin-ob-contr            for ub.arh-fin-ob-contr.
define buffer arh-fin-ob-contr-attr           for ub.arh-fin-ob-contr-attr.
define buffer arh-fin-ob-contr-obj            for ub.arh-fin-ob-contr-obj.
define buffer buf_arh-fin-ob-contr-obj        for ub.arh-fin-ob-contr-obj.
define buffer arh-fin-ob-contr-obj-attr       for ub.arh-fin-ob-contr-obj-attr.
on delete of ub.arh-fin-doc-an               override do: end.
on delete of ub.arh-fin-doc-an-attr          override do: end.
on delete of ub.arh-fin-doc-an-nal           override do: end.
on delete of ub.arh-fin-doc-an-nal-attr      override do: end.
on delete of ub.arh-fin-doc-an-nal-obj       override do: end.
on delete of ub.arh-fin-doc-an-nal-obj-attr  override do: end.
on delete of ub.arh-fin-doc-an-obj           override do: end.
on delete of ub.arh-fin-doc-an-obj-attr      override do: end.
on delete of ub.arh-fin-doc-c-s-tax-nal-obj  override do: end.
on delete of ub.arh-fin-doc-c-schet-tax-nal  override do: end.
on delete of ub.arh-fin-doc-contr-s-nal-obj  override do: end.
on delete of ub.arh-fin-doc-contr-s-tax-obj  override do: end.
on delete of ub.arh-fin-doc-contr-schet      override do: end.
on delete of ub.arh-fin-doc-contr-schet-attr override do: end.
on delete of ub.arh-fin-doc-contr-schet-nal  override do: end.
on delete of ub.arh-fin-doc-contr-schet-obj  override do: end.
on delete of ub.arh-fin-doc-contr-schet-tax  override do: end.
on delete of ub.arh-fin-doc-s-tax-nal-obj    override do: end.
on delete of ub.arh-fin-doc-schet            override do: end.
on delete of ub.arh-fin-doc-schet-attr       override do: end.
on delete of ub.arh-fin-doc-schet-nal        override do: end.
on delete of ub.arh-fin-doc-schet-nal-attr   override do: end.
on delete of ub.arh-fin-doc-schet-nal-obj    override do: end.
on delete of ub.arh-fin-doc-schet-obj        override do: end.
on delete of ub.arh-fin-doc-schet-obj-attr   override do: end.
on delete of ub.arh-fin-doc-schet-tax        override do: end.
on delete of ub.arh-fin-doc-schet-tax-attr   override do: end.
on delete of ub.arh-fin-doc-schet-tax-nal    override do: end.
on delete of ub.arh-fin-doc-schet-tax-obj    override do: end.
on delete of ub.arh-fin-ob-contr             override do: end.
on delete of ub.arh-fin-ob-contr-attr        override do: end.
on delete of ub.arh-fin-ob-contr-obj         override do: end.
on delete of ub.arh-fin-ob-contr-obj-attr    override do: end.
run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-findoc).
for each buf_clients no-lock where
         buf_clients.db-num <> ?
:
for each arh-fin-doc-an no-lock where
         arh-fin-doc-an.host-code  = buf_clients.host-code
     and arh-fin-doc-an.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-attr exclusive-lock where
           arh-fin-doc-an-attr.host-code         = arh-fin-doc-an.host-code
       and arh-fin-doc-an-attr.cli-type          = arh-fin-doc-an.cli-type
       and arh-fin-doc-an-attr.cli-code          = arh-fin-doc-an.cli-code
       and arh-fin-doc-an-attr.code-schet        = arh-fin-doc-an.code-schet
       and arh-fin-doc-an-attr.fin-ext-doc-type  = arh-fin-doc-an.fin-ext-doc-type
       and arh-fin-doc-an-attr.fin-code-an-uchet = arh-fin-doc-an.fin-code-an-uchet
       and arh-fin-doc-an-attr.fin-code-cel-nazn = arh-fin-doc-an.fin-code-cel-nazn
       and arh-fin-doc-an-attr.fin-code-cor-acc  = arh-fin-doc-an.fin-code-cor-acc
       and arh-fin-doc-an-attr.calc-curr-code    = arh-fin-doc-an.calc-curr-code
       and arh-fin-doc-an-attr.sum-type          = arh-fin-doc-an.sum-type
       and arh-fin-doc-an-attr.fact-order        = arh-fin-doc-an.fact-order
  :
    delete arh-fin-doc-an-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-an exclusive-lock where
           recid(buf_arh-fin-doc-an) = recid(arh-fin-doc-an) no-error no-wait.
if not avail buf_arh-fin-doc-an then
do:
  undo, return error "Ошибка удаления arh-fin-doc-an. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-an.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-an-nal no-lock where
         arh-fin-doc-an-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-an-nal.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-nal-attr exclusive-lock where
           arh-fin-doc-an-nal-attr.host-code         = arh-fin-doc-an-nal.host-code
       and arh-fin-doc-an-nal-attr.cli-type          = arh-fin-doc-an-nal.cli-type
       and arh-fin-doc-an-nal-attr.cli-code          = arh-fin-doc-an-nal.cli-code
       and arh-fin-doc-an-nal-attr.fin-code-acc      = arh-fin-doc-an-nal.fin-code-acc
       and arh-fin-doc-an-nal-attr.curr-code         = arh-fin-doc-an-nal.curr-code
       and arh-fin-doc-an-nal-attr.fin-ext-doc-type  = arh-fin-doc-an-nal.fin-ext-doc-type
       and arh-fin-doc-an-nal-attr.fin-code-an-uchet = arh-fin-doc-an-nal.fin-code-an-uchet
       and arh-fin-doc-an-nal-attr.fin-code-cel-nazn = arh-fin-doc-an-nal.fin-code-cel-nazn
       and arh-fin-doc-an-nal-attr.fin-code-cor-acc  = arh-fin-doc-an-nal.fin-code-cor-acc
       and arh-fin-doc-an-nal-attr.calc-curr-code    = arh-fin-doc-an-nal.calc-curr-code
       and arh-fin-doc-an-nal-attr.sum-type          = arh-fin-doc-an-nal.sum-type
       and arh-fin-doc-an-nal-attr.fact-order        = arh-fin-doc-an-nal.fact-order
  :
    delete arh-fin-doc-an-nal-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-an-nal exclusive-lock where
           recid(buf_arh-fin-doc-an-nal) = recid(arh-fin-doc-an-nal) no-error no-wait.
if not avail buf_arh-fin-doc-an-nal then
do:
  undo, return error "Ошибка удаления arh-fin-doc-an-nal. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-an-nal.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-an-nal-obj no-lock where
         arh-fin-doc-an-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-an-nal-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-nal-obj-attr exclusive-lock where
           arh-fin-doc-an-nal-obj-attr.host-code         = arh-fin-doc-an-nal-obj.host-code
       and arh-fin-doc-an-nal-obj-attr.obj-type          = arh-fin-doc-an-nal-obj.obj-type
       and arh-fin-doc-an-nal-obj-attr.obj-code          = arh-fin-doc-an-nal-obj.obj-code
       and arh-fin-doc-an-nal-obj-attr.cli-type          = arh-fin-doc-an-nal-obj.cli-type
       and arh-fin-doc-an-nal-obj-attr.cli-code          = arh-fin-doc-an-nal-obj.cli-code
       and arh-fin-doc-an-nal-obj-attr.fin-code-acc      = arh-fin-doc-an-nal-obj.fin-code-acc
       and arh-fin-doc-an-nal-obj-attr.curr-code         = arh-fin-doc-an-nal-obj.curr-code
       and arh-fin-doc-an-nal-obj-attr.fin-ext-doc-type  = arh-fin-doc-an-nal-obj.fin-ext-doc-type
       and arh-fin-doc-an-nal-obj-attr.fin-code-an-uchet = arh-fin-doc-an-nal-obj.fin-code-an-uchet
       and arh-fin-doc-an-nal-obj-attr.fin-code-cel-nazn = arh-fin-doc-an-nal-obj.fin-code-cel-nazn
       and arh-fin-doc-an-nal-obj-attr.fin-code-cor-acc  = arh-fin-doc-an-nal-obj.fin-code-cor-acc
       and arh-fin-doc-an-nal-obj-attr.calc-curr-code    = arh-fin-doc-an-nal-obj.calc-curr-code
       and arh-fin-doc-an-nal-obj-attr.sum-type          = arh-fin-doc-an-nal-obj.sum-type
       and arh-fin-doc-an-nal-obj-attr.fact-order        = arh-fin-doc-an-nal-obj.fact-order
  :
    delete arh-fin-doc-an-nal-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-an-nal-obj exclusive-lock where
           recid(buf_arh-fin-doc-an-nal-obj) = recid(arh-fin-doc-an-nal-obj) no-error no-wait.
if not avail buf_arh-fin-doc-an-nal-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-an-nal-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-an-nal-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-an-obj no-lock where
         arh-fin-doc-an-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-an-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-obj-attr exclusive-lock where
           arh-fin-doc-an-obj-attr.host-code         = arh-fin-doc-an-obj.host-code
       and arh-fin-doc-an-obj-attr.obj-type          = arh-fin-doc-an-obj.obj-type
       and arh-fin-doc-an-obj-attr.obj-code          = arh-fin-doc-an-obj.obj-code
       and arh-fin-doc-an-obj-attr.cli-type          = arh-fin-doc-an-obj.cli-type
       and arh-fin-doc-an-obj-attr.cli-code          = arh-fin-doc-an-obj.cli-code
       and arh-fin-doc-an-obj-attr.code-schet        = arh-fin-doc-an-obj.code-schet
       and arh-fin-doc-an-obj-attr.fin-ext-doc-type  = arh-fin-doc-an-obj.fin-ext-doc-type
       and arh-fin-doc-an-obj-attr.fin-code-an-uchet = arh-fin-doc-an-obj.fin-code-an-uchet
       and arh-fin-doc-an-obj-attr.fin-code-cel-nazn = arh-fin-doc-an-obj.fin-code-cel-nazn
       and arh-fin-doc-an-obj-attr.fin-code-cor-acc  = arh-fin-doc-an-obj.fin-code-cor-acc
       and arh-fin-doc-an-obj-attr.calc-curr-code    = arh-fin-doc-an-obj.calc-curr-code
       and arh-fin-doc-an-obj-attr.sum-type          = arh-fin-doc-an-obj.sum-type
       and arh-fin-doc-an-obj-attr.fact-order        = arh-fin-doc-an-obj.fact-order
  :
    delete arh-fin-doc-an-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-an-obj exclusive-lock where
           recid(buf_arh-fin-doc-an-obj) = recid(arh-fin-doc-an-obj) no-error no-wait.
if not avail buf_arh-fin-doc-an-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-an-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-an-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-c-s-tax-nal-obj no-lock where
         arh-fin-doc-c-s-tax-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-c-s-tax-nal-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-c-s-tax-nal-obj exclusive-lock where
           recid(buf_arh-fin-doc-c-s-tax-nal-obj) = recid(arh-fin-doc-c-s-tax-nal-obj) no-error no-wait.
if not avail buf_arh-fin-doc-c-s-tax-nal-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-c-s-tax-nal-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-c-s-tax-nal-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-c-schet-tax-nal no-lock where
         arh-fin-doc-c-schet-tax-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-c-schet-tax-nal.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-c-schet-tax-nal exclusive-lock where
           recid(buf_arh-fin-doc-c-schet-tax-nal) = recid(arh-fin-doc-c-schet-tax-nal) no-error no-wait.
if not avail buf_arh-fin-doc-c-schet-tax-nal then
do:
  undo, return error "Ошибка удаления arh-fin-doc-c-schet-tax-nal. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-c-schet-tax-nal.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-s-nal-obj no-lock where
         arh-fin-doc-contr-s-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-s-nal-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-contr-s-nal-obj exclusive-lock where
           recid(buf_arh-fin-doc-contr-s-nal-obj) = recid(arh-fin-doc-contr-s-nal-obj) no-error no-wait.
if not avail buf_arh-fin-doc-contr-s-nal-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-s-nal-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-s-nal-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-s-tax-obj no-lock where
         arh-fin-doc-contr-s-tax-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-s-tax-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-contr-s-tax-obj exclusive-lock where
           recid(buf_arh-fin-doc-contr-s-tax-obj) = recid(arh-fin-doc-contr-s-tax-obj) no-error no-wait.
if not avail buf_arh-fin-doc-contr-s-tax-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-s-tax-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-s-tax-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-schet no-lock where
         arh-fin-doc-contr-schet.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-contr-schet-attr exclusive-lock where
           arh-fin-doc-contr-schet-attr.host-code         = arh-fin-doc-contr-schet.host-code
       and arh-fin-doc-contr-schet-attr.contract-code     = arh-fin-doc-contr-schet.contract-code
       and arh-fin-doc-contr-schet-attr.cli-type          = arh-fin-doc-contr-schet.cli-type
       and arh-fin-doc-contr-schet-attr.cli-code          = arh-fin-doc-contr-schet.cli-code
       and arh-fin-doc-contr-schet-attr.code-schet        = arh-fin-doc-contr-schet.code-schet
       and arh-fin-doc-contr-schet-attr.fin-ext-doc-type  = arh-fin-doc-contr-schet.fin-ext-doc-type
       and arh-fin-doc-contr-schet-attr.calc-curr-code    = arh-fin-doc-contr-schet.calc-curr-code
       and arh-fin-doc-contr-schet-attr.sum-type          = arh-fin-doc-contr-schet.sum-type
       and arh-fin-doc-contr-schet-attr.fact-order        = arh-fin-doc-contr-schet.fact-order
  :
    delete arh-fin-doc-contr-schet-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-contr-schet exclusive-lock where
           recid(buf_arh-fin-doc-contr-schet) = recid(arh-fin-doc-contr-schet) no-error no-wait.
if not avail buf_arh-fin-doc-contr-schet then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-schet. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-schet.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-schet-nal no-lock where
         arh-fin-doc-contr-schet-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-nal.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-contr-schet-nal exclusive-lock where
           recid(buf_arh-fin-doc-contr-schet-nal) = recid(arh-fin-doc-contr-schet-nal) no-error no-wait.
if not avail buf_arh-fin-doc-contr-schet-nal then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-schet-nal. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-schet-nal.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-schet-obj no-lock where
         arh-fin-doc-contr-schet-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-contr-schet-obj exclusive-lock where
           recid(buf_arh-fin-doc-contr-schet-obj) = recid(arh-fin-doc-contr-schet-obj) no-error no-wait.
if not avail buf_arh-fin-doc-contr-schet-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-schet-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-schet-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-contr-schet-tax no-lock where
         arh-fin-doc-contr-schet-tax.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-tax.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-contr-schet-tax exclusive-lock where
           recid(buf_arh-fin-doc-contr-schet-tax) = recid(arh-fin-doc-contr-schet-tax) no-error no-wait.
if not avail buf_arh-fin-doc-contr-schet-tax then
do:
  undo, return error "Ошибка удаления arh-fin-doc-contr-schet-tax. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-contr-schet-tax.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-s-tax-nal-obj no-lock where
         arh-fin-doc-s-tax-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-s-tax-nal-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-s-tax-nal-obj exclusive-lock where
           recid(buf_arh-fin-doc-s-tax-nal-obj) = recid(arh-fin-doc-s-tax-nal-obj) no-error no-wait.
if not avail buf_arh-fin-doc-s-tax-nal-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-s-tax-nal-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-s-tax-nal-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet no-lock where
         arh-fin-doc-schet.host-code  = buf_clients.host-code
     and arh-fin-doc-schet.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-attr exclusive-lock where
           arh-fin-doc-schet-attr.host-code         = arh-fin-doc-schet.host-code
       and arh-fin-doc-schet-attr.cli-type          = arh-fin-doc-schet.cli-type
       and arh-fin-doc-schet-attr.cli-code          = arh-fin-doc-schet.cli-code
       and arh-fin-doc-schet-attr.code-schet        = arh-fin-doc-schet.code-schet
       and arh-fin-doc-schet-attr.fin-ext-doc-type  = arh-fin-doc-schet.fin-ext-doc-type
       and arh-fin-doc-schet-attr.calc-curr-code    = arh-fin-doc-schet.calc-curr-code
       and arh-fin-doc-schet-attr.sum-type          = arh-fin-doc-schet.sum-type
       and arh-fin-doc-schet-attr.fact-order        = arh-fin-doc-schet.fact-order
  :
    delete arh-fin-doc-schet-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-schet exclusive-lock where
           recid(buf_arh-fin-doc-schet) = recid(arh-fin-doc-schet) no-error no-wait.
if not avail buf_arh-fin-doc-schet then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-nal no-lock where
         arh-fin-doc-schet-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-nal.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-nal-attr exclusive-lock where
           arh-fin-doc-schet-nal-attr.host-code         = arh-fin-doc-schet-nal.host-code
       and arh-fin-doc-schet-nal-attr.cli-type          = arh-fin-doc-schet-nal.cli-type
       and arh-fin-doc-schet-nal-attr.cli-code          = arh-fin-doc-schet-nal.cli-code
       and arh-fin-doc-schet-nal-attr.fin-code-acc      = arh-fin-doc-schet-nal.fin-code-acc
       and arh-fin-doc-schet-nal-attr.curr-code         = arh-fin-doc-schet-nal.curr-code
       and arh-fin-doc-schet-nal-attr.fin-ext-doc-type  = arh-fin-doc-schet-nal.fin-ext-doc-type
       and arh-fin-doc-schet-nal-attr.calc-curr-code    = arh-fin-doc-schet-nal.calc-curr-code
       and arh-fin-doc-schet-nal-attr.sum-type          = arh-fin-doc-schet-nal.sum-type
       and arh-fin-doc-schet-nal-attr.fact-order        = arh-fin-doc-schet-nal.fact-order
  :
    delete arh-fin-doc-schet-nal-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-schet-nal exclusive-lock where
           recid(buf_arh-fin-doc-schet-nal) = recid(arh-fin-doc-schet-nal) no-error no-wait.
if not avail buf_arh-fin-doc-schet-nal then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-nal. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-nal.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-nal-obj no-lock where
         arh-fin-doc-schet-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-nal-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-schet-nal-obj exclusive-lock where
           recid(buf_arh-fin-doc-schet-nal-obj) = recid(arh-fin-doc-schet-nal-obj) no-error no-wait.
if not avail buf_arh-fin-doc-schet-nal-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-nal-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-nal-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-obj no-lock where
         arh-fin-doc-schet-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-obj-attr exclusive-lock where
           arh-fin-doc-schet-obj-attr.host-code         = arh-fin-doc-schet-obj.host-code
       and arh-fin-doc-schet-obj-attr.obj-type          = arh-fin-doc-schet-obj.obj-type
       and arh-fin-doc-schet-obj-attr.obj-code          = arh-fin-doc-schet-obj.obj-code
       and arh-fin-doc-schet-obj-attr.cli-type          = arh-fin-doc-schet-obj.cli-type
       and arh-fin-doc-schet-obj-attr.cli-code          = arh-fin-doc-schet-obj.cli-code
       and arh-fin-doc-schet-obj-attr.code-schet        = arh-fin-doc-schet-obj.code-schet
       and arh-fin-doc-schet-obj-attr.fin-ext-doc-type  = arh-fin-doc-schet-obj.fin-ext-doc-type
       and arh-fin-doc-schet-obj-attr.calc-curr-code    = arh-fin-doc-schet-obj.calc-curr-code
       and arh-fin-doc-schet-obj-attr.sum-type          = arh-fin-doc-schet-obj.sum-type
       and arh-fin-doc-schet-obj-attr.fact-order        = arh-fin-doc-schet-obj.fact-order
  :
    delete arh-fin-doc-schet-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-schet-obj exclusive-lock where
           recid(buf_arh-fin-doc-schet-obj) = recid(arh-fin-doc-schet-obj) no-error no-wait.
if not avail buf_arh-fin-doc-schet-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-tax no-lock where
         arh-fin-doc-schet-tax.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-tax-attr exclusive-lock where
           arh-fin-doc-schet-tax-attr.host-code         = arh-fin-doc-schet-tax.host-code
       and arh-fin-doc-schet-tax-attr.cli-type          = arh-fin-doc-schet-tax.cli-type
       and arh-fin-doc-schet-tax-attr.cli-code          = arh-fin-doc-schet-tax.cli-code
       and arh-fin-doc-schet-tax-attr.code-schet        = arh-fin-doc-schet-tax.code-schet
       and arh-fin-doc-schet-tax-attr.fin-ext-doc-type  = arh-fin-doc-schet-tax.fin-ext-doc-type
       and arh-fin-doc-schet-tax-attr.calc-curr-code    = arh-fin-doc-schet-tax.calc-curr-code
       and arh-fin-doc-schet-tax-attr.VAT-pc            = arh-fin-doc-schet-tax.VAT-pc
       and arh-fin-doc-schet-tax-attr.SLT-pc            = arh-fin-doc-schet-tax.SLT-pc
       and arh-fin-doc-schet-tax-attr.with-vat          = arh-fin-doc-schet-tax.with-vat
       and arh-fin-doc-schet-tax-attr.with-slt          = arh-fin-doc-schet-tax.with-slt
       and arh-fin-doc-schet-tax-attr.sum-type          = arh-fin-doc-schet-tax.sum-type
       and arh-fin-doc-schet-tax-attr.fact-order        = arh-fin-doc-schet-tax.fact-order
  :
    delete arh-fin-doc-schet-tax-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-doc-schet-tax exclusive-lock where
           recid(buf_arh-fin-doc-schet-tax) = recid(arh-fin-doc-schet-tax) no-error no-wait.
if not avail buf_arh-fin-doc-schet-tax then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-tax. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-tax.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-tax-nal no-lock where
         arh-fin-doc-schet-tax-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax-nal.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-schet-tax-nal exclusive-lock where
           recid(buf_arh-fin-doc-schet-tax-nal) = recid(arh-fin-doc-schet-tax-nal) no-error no-wait.
if not avail buf_arh-fin-doc-schet-tax-nal then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-tax-nal. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-tax-nal.
vDeleted = vDeleted + 1.
end.
for each arh-fin-doc-schet-tax-obj no-lock where
         arh-fin-doc-schet-tax-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first buf_arh-fin-doc-schet-tax-obj exclusive-lock where
           recid(buf_arh-fin-doc-schet-tax-obj) = recid(arh-fin-doc-schet-tax-obj) no-error no-wait.
if not avail buf_arh-fin-doc-schet-tax-obj then
do:
  undo, return error "Ошибка удаления arh-fin-doc-schet-tax-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-doc-schet-tax-obj.
vDeleted = vDeleted + 1.
end.
for each arh-fin-ob-contr no-lock where
         arh-fin-ob-contr.host-code  = buf_clients.host-code
     and arh-fin-ob-contr.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-ob-contr-attr exclusive-lock where
           arh-fin-ob-contr-attr.host-code         = arh-fin-ob-contr.host-code
       and arh-fin-ob-contr-attr.contract-code     = arh-fin-ob-contr.contract-code
       and arh-fin-ob-contr-attr.cli-type          = arh-fin-ob-contr.cli-type
       and arh-fin-ob-contr-attr.cli-code          = arh-fin-ob-contr.cli-code
       and arh-fin-ob-contr-attr.fin-ext-doc-type  = arh-fin-ob-contr.fin-ext-doc-type
       and arh-fin-ob-contr-attr.calc-curr-code    = arh-fin-ob-contr.calc-curr-code
       and arh-fin-ob-contr-attr.sum-type          = arh-fin-ob-contr.sum-type
       and arh-fin-ob-contr-attr.fact-order        = arh-fin-ob-contr.fact-order
  :
    delete arh-fin-ob-contr-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-ob-contr exclusive-lock where
           recid(buf_arh-fin-ob-contr) = recid(arh-fin-ob-contr) no-error no-wait.
if not avail buf_arh-fin-ob-contr then
do:
  undo, return error "Ошибка удаления arh-fin-ob-contr. Запись занята другим пользователем.".
end.
delete buf_arh-fin-ob-contr.
vDeleted = vDeleted + 1.
end.
for each arh-fin-ob-contr-obj no-lock where
         arh-fin-ob-contr-obj.host-code  = buf_clients.host-code
     and arh-fin-ob-contr-obj.fact-order < var-fact-order-findoc
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-ob-contr-obj-attr exclusive-lock where
           arh-fin-ob-contr-obj-attr.host-code         = arh-fin-ob-contr-obj.host-code
       and arh-fin-ob-contr-obj-attr.obj-type          = arh-fin-ob-contr-obj.obj-type
       and arh-fin-ob-contr-obj-attr.obj-code          = arh-fin-ob-contr-obj.obj-code
       and arh-fin-ob-contr-obj-attr.contract-code     = arh-fin-ob-contr-obj.contract-code
       and arh-fin-ob-contr-obj-attr.cli-type          = arh-fin-ob-contr-obj.cli-type
       and arh-fin-ob-contr-obj-attr.cli-code          = arh-fin-ob-contr-obj.cli-code
       and arh-fin-ob-contr-obj-attr.fin-ext-doc-type  = arh-fin-ob-contr-obj.fin-ext-doc-type
       and arh-fin-ob-contr-obj-attr.calc-curr-code    = arh-fin-ob-contr-obj.calc-curr-code
       and arh-fin-ob-contr-obj-attr.sum-type          = arh-fin-ob-contr-obj.sum-type
       and arh-fin-ob-contr-obj-attr.fact-order        = arh-fin-ob-contr-obj.fact-order
  :
    delete arh-fin-ob-contr-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  find first buf_arh-fin-ob-contr-obj exclusive-lock where
           recid(buf_arh-fin-ob-contr-obj) = recid(arh-fin-ob-contr-obj) no-error no-wait.
if not avail buf_arh-fin-ob-contr-obj then
do:
  undo, return error "Ошибка удаления arh-fin-ob-contr-obj. Запись занята другим пользователем.".
end.
delete buf_arh-fin-ob-contr-obj.
vDeleted = vDeleted + 1.
end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Архив финансовых док-тов", vDeleted).
return vResult.
