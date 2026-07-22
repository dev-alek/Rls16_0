block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00199000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00199000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 199.".
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
define buffer old-arh-fin-doc-an              for src.arh-fin-doc-an.
define buffer bf_arh-fin-doc-an               for src.arh-fin-doc-an.
define buffer new-arh-fin-doc-an              for dst.arh-fin-doc-an.
define buffer old-arh-fin-doc-an-nal          for src.arh-fin-doc-an-nal.
define buffer bf_arh-fin-doc-an-nal           for src.arh-fin-doc-an-nal.
define buffer new-arh-fin-doc-an-nal          for dst.arh-fin-doc-an-nal.
define buffer old-arh-fin-doc-an-nal-obj      for src.arh-fin-doc-an-nal-obj.
define buffer bf_arh-fin-doc-an-nal-obj       for src.arh-fin-doc-an-nal-obj.
define buffer new-arh-fin-doc-an-nal-obj      for dst.arh-fin-doc-an-nal-obj.
define buffer old-arh-fin-doc-an-obj          for src.arh-fin-doc-an-obj.
define buffer bf_arh-fin-doc-an-obj           for src.arh-fin-doc-an-obj.
define buffer new-arh-fin-doc-an-obj          for dst.arh-fin-doc-an-obj.
define buffer old-arh-fin-doc-c-s-tax-nal-obj for src.arh-fin-doc-c-s-tax-nal-obj.
define buffer bf_arh-fin-doc-c-s-tax-nal-obj  for src.arh-fin-doc-c-s-tax-nal-obj.
define buffer new-arh-fin-doc-c-s-tax-nal-obj for dst.arh-fin-doc-c-s-tax-nal-obj.
define buffer old-arh-fin-doc-c-schet-tax-nal for src.arh-fin-doc-c-schet-tax-nal.
define buffer bf_arh-fin-doc-c-schet-tax-nal  for src.arh-fin-doc-c-schet-tax-nal.
define buffer new-arh-fin-doc-c-schet-tax-nal for dst.arh-fin-doc-c-schet-tax-nal.
define buffer old-arh-fin-doc-contr-s-nal-obj for src.arh-fin-doc-contr-s-nal-obj.
define buffer bf_arh-fin-doc-contr-s-nal-obj  for src.arh-fin-doc-contr-s-nal-obj.
define buffer new-arh-fin-doc-contr-s-nal-obj for dst.arh-fin-doc-contr-s-nal-obj.
define buffer old-arh-fin-doc-contr-s-tax-obj for src.arh-fin-doc-contr-s-tax-obj.
define buffer bf_arh-fin-doc-contr-s-tax-obj  for src.arh-fin-doc-contr-s-tax-obj.
define buffer new-arh-fin-doc-contr-s-tax-obj for dst.arh-fin-doc-contr-s-tax-obj.
define buffer old-arh-fin-doc-contr-schet     for src.arh-fin-doc-contr-schet.
define buffer bf_arh-fin-doc-contr-schet      for src.arh-fin-doc-contr-schet.
define buffer new-arh-fin-doc-contr-schet     for dst.arh-fin-doc-contr-schet.
define buffer old-arh-fin-doc-contr-schet-nal for src.arh-fin-doc-contr-schet-nal.
define buffer bf_arh-fin-doc-contr-schet-nal  for src.arh-fin-doc-contr-schet-nal.
define buffer new-arh-fin-doc-contr-schet-nal for dst.arh-fin-doc-contr-schet-nal.
define buffer old-arh-fin-doc-contr-schet-obj for src.arh-fin-doc-contr-schet-obj.
define buffer bf_arh-fin-doc-contr-schet-obj  for src.arh-fin-doc-contr-schet-obj.
define buffer new-arh-fin-doc-contr-schet-obj for dst.arh-fin-doc-contr-schet-obj.
define buffer old-arh-fin-doc-contr-schet-tax for src.arh-fin-doc-contr-schet-tax.
define buffer bf_arh-fin-doc-contr-schet-tax  for src.arh-fin-doc-contr-schet-tax.
define buffer new-arh-fin-doc-contr-schet-tax for dst.arh-fin-doc-contr-schet-tax.
define buffer old-arh-fin-doc-s-tax-nal-obj   for src.arh-fin-doc-s-tax-nal-obj.
define buffer bf_arh-fin-doc-s-tax-nal-obj    for src.arh-fin-doc-s-tax-nal-obj.
define buffer new-arh-fin-doc-s-tax-nal-obj   for dst.arh-fin-doc-s-tax-nal-obj.
define buffer old-arh-fin-doc-schet           for src.arh-fin-doc-schet.
define buffer bf_arh-fin-doc-schet            for src.arh-fin-doc-schet.
define buffer new-arh-fin-doc-schet           for dst.arh-fin-doc-schet.
define buffer old-arh-fin-doc-schet-nal       for src.arh-fin-doc-schet-nal.
define buffer bf_arh-fin-doc-schet-nal        for src.arh-fin-doc-schet-nal.
define buffer new-arh-fin-doc-schet-nal       for dst.arh-fin-doc-schet-nal.
define buffer old-arh-fin-doc-schet-nal-obj   for src.arh-fin-doc-schet-nal-obj.
define buffer bf_arh-fin-doc-schet-nal-obj    for src.arh-fin-doc-schet-nal-obj.
define buffer new-arh-fin-doc-schet-nal-obj   for dst.arh-fin-doc-schet-nal-obj.
define buffer old-arh-fin-doc-schet-obj       for src.arh-fin-doc-schet-obj.
define buffer bf_arh-fin-doc-schet-obj        for src.arh-fin-doc-schet-obj.
define buffer new-arh-fin-doc-schet-obj       for dst.arh-fin-doc-schet-obj.
define buffer old-arh-fin-doc-schet-tax       for src.arh-fin-doc-schet-tax.
define buffer bf_arh-fin-doc-schet-tax        for src.arh-fin-doc-schet-tax.
define buffer new-arh-fin-doc-schet-tax       for dst.arh-fin-doc-schet-tax.
define buffer old-arh-fin-doc-schet-tax-nal   for src.arh-fin-doc-schet-tax-nal.
define buffer bf_arh-fin-doc-schet-tax-nal    for src.arh-fin-doc-schet-tax-nal.
define buffer new-arh-fin-doc-schet-tax-nal   for dst.arh-fin-doc-schet-tax-nal.
define buffer old-arh-fin-doc-schet-tax-obj   for src.arh-fin-doc-schet-tax-obj.
define buffer bf_arh-fin-doc-schet-tax-obj    for src.arh-fin-doc-schet-tax-obj.
define buffer new-arh-fin-doc-schet-tax-obj   for dst.arh-fin-doc-schet-tax-obj.
define buffer old-arh-fin-ob-contr            for src.arh-fin-ob-contr.
define buffer bf_arh-fin-ob-contr             for src.arh-fin-ob-contr.
define buffer new-arh-fin-ob-contr            for dst.arh-fin-ob-contr.
define buffer old-arh-fin-ob-contr-obj        for src.arh-fin-ob-contr-obj.
define buffer bf_arh-fin-ob-contr-obj         for src.arh-fin-ob-contr-obj.
define buffer new-arh-fin-ob-contr-obj        for dst.arh-fin-ob-contr-obj.
define buffer new-arh-fin-doc-an-attr               for dst.arh-fin-doc-an-attr         .
define buffer new-arh-fin-doc-an-nal-attr           for dst.arh-fin-doc-an-nal-attr     .
define buffer new-arh-fin-doc-an-nal-obj-attr       for dst.arh-fin-doc-an-nal-obj-attr .
define buffer new-arh-fin-doc-an-obj-attr           for dst.arh-fin-doc-an-obj-attr     .
define buffer new-arh-fin-doc-contr-schet-attr      for dst.arh-fin-doc-contr-schet-attr.
define buffer new-arh-fin-doc-schet-attr            for dst.arh-fin-doc-schet-attr      .
define buffer new-arh-fin-doc-schet-nal-attr        for dst.arh-fin-doc-schet-nal-attr  .
define buffer new-arh-fin-doc-schet-obj-attr        for dst.arh-fin-doc-schet-obj-attr  .
define buffer new-arh-fin-doc-schet-tax-attr        for dst.arh-fin-doc-schet-tax-attr  .
define buffer new-arh-fin-ob-contr-attr             for dst.arh-fin-ob-contr-attr       .
define buffer new-arh-fin-ob-contr-obj-attr         for dst.arh-fin-ob-contr-obj-attr   .
define buffer old-arh-fin-doc-an-attr               for src.arh-fin-doc-an-attr         .
define buffer old-arh-fin-doc-an-nal-attr           for src.arh-fin-doc-an-nal-attr     .
define buffer old-arh-fin-doc-an-nal-obj-attr       for src.arh-fin-doc-an-nal-obj-attr .
define buffer old-arh-fin-doc-an-obj-attr           for src.arh-fin-doc-an-obj-attr     .
define buffer old-arh-fin-doc-contr-schet-attr      for src.arh-fin-doc-contr-schet-attr.
define buffer old-arh-fin-doc-schet-attr            for src.arh-fin-doc-schet-attr      .
define buffer old-arh-fin-doc-schet-nal-attr        for src.arh-fin-doc-schet-nal-attr  .
define buffer old-arh-fin-doc-schet-obj-attr        for src.arh-fin-doc-schet-obj-attr  .
define buffer old-arh-fin-doc-schet-tax-attr        for src.arh-fin-doc-schet-tax-attr  .
define buffer old-arh-fin-ob-contr-attr             for src.arh-fin-ob-contr-attr       .
define buffer old-arh-fin-ob-contr-obj-attr         for src.arh-fin-ob-contr-obj-attr   .
define variable var-fact-order-findoc as decimal no-undo.
on WRITE of dst.arh-fin-doc-an               override do: end.
on WRITE of dst.arh-fin-doc-an-nal           override do: end.
on WRITE of dst.arh-fin-doc-an-nal-obj       override do: end.
on WRITE of dst.arh-fin-doc-an-obj           override do: end.
on WRITE of dst.arh-fin-doc-c-s-tax-nal-obj  override do: end.
on WRITE of dst.arh-fin-doc-c-schet-tax-nal  override do: end.
on WRITE of dst.arh-fin-doc-contr-s-nal-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-s-tax-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet      override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-nal  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-tax  override do: end.
on WRITE of dst.arh-fin-doc-s-tax-nal-obj    override do: end.
on WRITE of dst.arh-fin-doc-schet            override do: end.
on WRITE of dst.arh-fin-doc-schet-nal        override do: end.
on WRITE of dst.arh-fin-doc-schet-nal-obj    override do: end.
on WRITE of dst.arh-fin-doc-schet-obj        override do: end.
on WRITE of dst.arh-fin-doc-schet-tax        override do: end.
on WRITE of dst.arh-fin-doc-schet-tax-nal    override do: end.
on WRITE of dst.arh-fin-doc-schet-tax-obj    override do: end.
on WRITE of dst.arh-fin-ob-contr             override do: end.
on WRITE of dst.arh-fin-ob-contr-obj         override do: end.
on WRITE of  dst.arh-fin-doc-an-attr          override do: end.
on WRITE of  dst.arh-fin-doc-an-nal-attr      override do: end.
on WRITE of  dst.arh-fin-doc-an-nal-obj-attr  override do: end.
on WRITE of  dst.arh-fin-doc-an-obj-attr      override do: end.
on WRITE of  dst.arh-fin-doc-contr-schet-attr override do: end.
on WRITE of  dst.arh-fin-doc-schet-attr       override do: end.
on WRITE of  dst.arh-fin-doc-schet-nal-attr   override do: end.
on WRITE of  dst.arh-fin-doc-schet-obj-attr   override do: end.
on WRITE of  dst.arh-fin-doc-schet-tax-attr   override do: end.
on WRITE of  dst.arh-fin-ob-contr-attr        override do: end.
on WRITE of  dst.arh-fin-ob-contr-obj-attr    override do: end.
do
on error undo, return error return-value
:
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
run factord-end-day in this-procedure ( vardate-actual-findoc - 1, output var-fact-order-findoc).
      for each old-arh-fin-doc-an no-lock on error undo, return error return-value :     if old-arh-fin-doc-an.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-an.                                                       buffer-copy old-arh-fin-doc-an to new-arh-fin-doc-an.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-an where bf_arh-fin-doc-an.host-code         = old-arh-fin-doc-an.host-code               and                        bf_arh-fin-doc-an.cli-type          = old-arh-fin-doc-an.cli-type                and                        bf_arh-fin-doc-an.cli-code          = old-arh-fin-doc-an.cli-code                and                        bf_arh-fin-doc-an.code-schet        = old-arh-fin-doc-an.code-schet              and                        bf_arh-fin-doc-an.fin-ext-doc-type  = old-arh-fin-doc-an.fin-ext-doc-type        and                        bf_arh-fin-doc-an.fin-code-an-uchet = old-arh-fin-doc-an.fin-code-an-uchet       and                        bf_arh-fin-doc-an.fin-code-cel-nazn = old-arh-fin-doc-an.fin-code-cel-nazn       and                        bf_arh-fin-doc-an.fin-code-cor-acc  = old-arh-fin-doc-an.fin-code-cor-acc        and                        bf_arh-fin-doc-an.calc-curr-code    = old-arh-fin-doc-an.calc-curr-code          and                        bf_arh-fin-doc-an.sum-type          = old-arh-fin-doc-an.sum-type                and                        bf_arh-fin-doc-an.fact-order        > old-arh-fin-doc-an.fact-order              and                        bf_arh-fin-doc-an.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-an then do:                                        create new-arh-fin-doc-an.                                                       buffer-copy old-arh-fin-doc-an to new-arh-fin-doc-an.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-an-nal no-lock on error undo, return error return-value :     if old-arh-fin-doc-an-nal.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-an-nal.                                                       buffer-copy old-arh-fin-doc-an-nal to new-arh-fin-doc-an-nal.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-an-nal where bf_arh-fin-doc-an-nal.host-code         = old-arh-fin-doc-an-nal.host-code               and                        bf_arh-fin-doc-an-nal.cli-type          = old-arh-fin-doc-an-nal.cli-type                and                        bf_arh-fin-doc-an-nal.cli-code          = old-arh-fin-doc-an-nal.cli-code                and                        bf_arh-fin-doc-an-nal.fin-code-acc      = old-arh-fin-doc-an-nal.fin-code-acc            and                        bf_arh-fin-doc-an-nal.curr-code         = old-arh-fin-doc-an-nal.curr-code               and                        bf_arh-fin-doc-an-nal.fin-ext-doc-type  = old-arh-fin-doc-an-nal.fin-ext-doc-type        and                        bf_arh-fin-doc-an-nal.fin-code-an-uchet = old-arh-fin-doc-an-nal.fin-code-an-uchet       and                        bf_arh-fin-doc-an-nal.fin-code-cel-nazn = old-arh-fin-doc-an-nal.fin-code-cel-nazn       and                        bf_arh-fin-doc-an-nal.fin-code-cor-acc  = old-arh-fin-doc-an-nal.fin-code-cor-acc        and                        bf_arh-fin-doc-an-nal.calc-curr-code    = old-arh-fin-doc-an-nal.calc-curr-code          and                        bf_arh-fin-doc-an-nal.sum-type          = old-arh-fin-doc-an-nal.sum-type                and                        bf_arh-fin-doc-an-nal.fact-order        > old-arh-fin-doc-an-nal.fact-order              and                        bf_arh-fin-doc-an-nal.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-an-nal then do:                                        create new-arh-fin-doc-an-nal.                                                       buffer-copy old-arh-fin-doc-an-nal to new-arh-fin-doc-an-nal.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-an-nal-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-an-nal-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-an-nal-obj.                                                       buffer-copy old-arh-fin-doc-an-nal-obj to new-arh-fin-doc-an-nal-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-an-nal-obj where bf_arh-fin-doc-an-nal-obj.host-code         = old-arh-fin-doc-an-nal-obj.host-code               and                        bf_arh-fin-doc-an-nal-obj.obj-type          = old-arh-fin-doc-an-nal-obj.obj-type                and                        bf_arh-fin-doc-an-nal-obj.obj-code          = old-arh-fin-doc-an-nal-obj.obj-code                and                        bf_arh-fin-doc-an-nal-obj.cli-type          = old-arh-fin-doc-an-nal-obj.cli-type                and                        bf_arh-fin-doc-an-nal-obj.cli-code          = old-arh-fin-doc-an-nal-obj.cli-code                and                        bf_arh-fin-doc-an-nal-obj.fin-code-acc      = old-arh-fin-doc-an-nal-obj.fin-code-acc            and                        bf_arh-fin-doc-an-nal-obj.curr-code         = old-arh-fin-doc-an-nal-obj.curr-code               and                        bf_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-an-nal-obj.fin-ext-doc-type        and                        bf_arh-fin-doc-an-nal-obj.fin-code-an-uchet = old-arh-fin-doc-an-nal-obj.fin-code-an-uchet       and                        bf_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = old-arh-fin-doc-an-nal-obj.fin-code-cel-nazn       and                        bf_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = old-arh-fin-doc-an-nal-obj.fin-code-cor-acc        and                        bf_arh-fin-doc-an-nal-obj.calc-curr-code    = old-arh-fin-doc-an-nal-obj.calc-curr-code          and                        bf_arh-fin-doc-an-nal-obj.sum-type          = old-arh-fin-doc-an-nal-obj.sum-type                and                        bf_arh-fin-doc-an-nal-obj.fact-order        > old-arh-fin-doc-an-nal-obj.fact-order              and                        bf_arh-fin-doc-an-nal-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-an-nal-obj then do:                                        create new-arh-fin-doc-an-nal-obj.                                                       buffer-copy old-arh-fin-doc-an-nal-obj to new-arh-fin-doc-an-nal-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-an-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-an-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-an-obj.                                                       buffer-copy old-arh-fin-doc-an-obj to new-arh-fin-doc-an-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-an-obj where bf_arh-fin-doc-an-obj.host-code         = old-arh-fin-doc-an-obj.host-code               and                        bf_arh-fin-doc-an-obj.obj-type          = old-arh-fin-doc-an-obj.obj-type                and                        bf_arh-fin-doc-an-obj.obj-code          = old-arh-fin-doc-an-obj.obj-code                and                        bf_arh-fin-doc-an-obj.cli-type          = old-arh-fin-doc-an-obj.cli-type                and                        bf_arh-fin-doc-an-obj.cli-code          = old-arh-fin-doc-an-obj.cli-code                and                        bf_arh-fin-doc-an-obj.code-schet        = old-arh-fin-doc-an-obj.code-schet              and                        bf_arh-fin-doc-an-obj.fin-ext-doc-type  = old-arh-fin-doc-an-obj.fin-ext-doc-type        and                        bf_arh-fin-doc-an-obj.fin-code-an-uchet = old-arh-fin-doc-an-obj.fin-code-an-uchet       and                        bf_arh-fin-doc-an-obj.fin-code-cel-nazn = old-arh-fin-doc-an-obj.fin-code-cel-nazn       and                        bf_arh-fin-doc-an-obj.fin-code-cor-acc  = old-arh-fin-doc-an-obj.fin-code-cor-acc        and                        bf_arh-fin-doc-an-obj.calc-curr-code    = old-arh-fin-doc-an-obj.calc-curr-code          and                        bf_arh-fin-doc-an-obj.sum-type          = old-arh-fin-doc-an-obj.sum-type                and                        bf_arh-fin-doc-an-obj.fact-order        > old-arh-fin-doc-an-obj.fact-order              and                        bf_arh-fin-doc-an-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-an-obj then do:                                        create new-arh-fin-doc-an-obj.                                                       buffer-copy old-arh-fin-doc-an-obj to new-arh-fin-doc-an-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-c-s-tax-nal-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-c-s-tax-nal-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-c-s-tax-nal-obj.                                                       buffer-copy old-arh-fin-doc-c-s-tax-nal-obj to new-arh-fin-doc-c-s-tax-nal-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-c-s-tax-nal-obj where bf_arh-fin-doc-c-s-tax-nal-obj.host-code         = old-arh-fin-doc-c-s-tax-nal-obj.host-code        and                        bf_arh-fin-doc-c-s-tax-nal-obj.obj-type          = old-arh-fin-doc-c-s-tax-nal-obj.obj-type         and                        bf_arh-fin-doc-c-s-tax-nal-obj.obj-code          = old-arh-fin-doc-c-s-tax-nal-obj.obj-code         and                        bf_arh-fin-doc-c-s-tax-nal-obj.contract-code     = old-arh-fin-doc-c-s-tax-nal-obj.contract-code    and                        bf_arh-fin-doc-c-s-tax-nal-obj.cli-type          = old-arh-fin-doc-c-s-tax-nal-obj.cli-type         and                        bf_arh-fin-doc-c-s-tax-nal-obj.cli-code          = old-arh-fin-doc-c-s-tax-nal-obj.cli-code         and                        bf_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc      = old-arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and                        bf_arh-fin-doc-c-s-tax-nal-obj.curr-code         = old-arh-fin-doc-c-s-tax-nal-obj.curr-code        and                        bf_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and                        bf_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code    = old-arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and                        bf_arh-fin-doc-c-s-tax-nal-obj.VAT-pc            = old-arh-fin-doc-c-s-tax-nal-obj.VAT-pc           and                        bf_arh-fin-doc-c-s-tax-nal-obj.SLT-pc            = old-arh-fin-doc-c-s-tax-nal-obj.SLT-pc           and                        bf_arh-fin-doc-c-s-tax-nal-obj.with-vat          = old-arh-fin-doc-c-s-tax-nal-obj.with-vat         and                        bf_arh-fin-doc-c-s-tax-nal-obj.with-slt          = old-arh-fin-doc-c-s-tax-nal-obj.with-slt         and                        bf_arh-fin-doc-c-s-tax-nal-obj.sum-type          = old-arh-fin-doc-c-s-tax-nal-obj.sum-type         and                        bf_arh-fin-doc-c-s-tax-nal-obj.fact-order        > old-arh-fin-doc-c-s-tax-nal-obj.fact-order       and                        bf_arh-fin-doc-c-s-tax-nal-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-c-s-tax-nal-obj then do:                                        create new-arh-fin-doc-c-s-tax-nal-obj.                                                       buffer-copy old-arh-fin-doc-c-s-tax-nal-obj to new-arh-fin-doc-c-s-tax-nal-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-c-schet-tax-nal no-lock on error undo, return error return-value :     if old-arh-fin-doc-c-schet-tax-nal.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-c-schet-tax-nal.                                                       buffer-copy old-arh-fin-doc-c-schet-tax-nal to new-arh-fin-doc-c-schet-tax-nal.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-c-schet-tax-nal where bf_arh-fin-doc-c-schet-tax-nal.host-code         = old-arh-fin-doc-c-schet-tax-nal.host-code        and                        bf_arh-fin-doc-c-schet-tax-nal.contract-code     = old-arh-fin-doc-c-schet-tax-nal.contract-code    and                        bf_arh-fin-doc-c-schet-tax-nal.cli-type          = old-arh-fin-doc-c-schet-tax-nal.cli-type         and                        bf_arh-fin-doc-c-schet-tax-nal.cli-code          = old-arh-fin-doc-c-schet-tax-nal.cli-code         and                        bf_arh-fin-doc-c-schet-tax-nal.fin-code-acc      = old-arh-fin-doc-c-schet-tax-nal.fin-code-acc     and                        bf_arh-fin-doc-c-schet-tax-nal.curr-code         = old-arh-fin-doc-c-schet-tax-nal.curr-code        and                        bf_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type  = old-arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and                        bf_arh-fin-doc-c-schet-tax-nal.calc-curr-code    = old-arh-fin-doc-c-schet-tax-nal.calc-curr-code   and                        bf_arh-fin-doc-c-schet-tax-nal.VAT-pc            = old-arh-fin-doc-c-schet-tax-nal.VAT-pc           and                        bf_arh-fin-doc-c-schet-tax-nal.SLT-pc            = old-arh-fin-doc-c-schet-tax-nal.SLT-pc           and                        bf_arh-fin-doc-c-schet-tax-nal.with-vat          = old-arh-fin-doc-c-schet-tax-nal.with-vat         and                        bf_arh-fin-doc-c-schet-tax-nal.with-slt          = old-arh-fin-doc-c-schet-tax-nal.with-slt         and                        bf_arh-fin-doc-c-schet-tax-nal.sum-type          = old-arh-fin-doc-c-schet-tax-nal.sum-type         and                        bf_arh-fin-doc-c-schet-tax-nal.fact-order        > old-arh-fin-doc-c-schet-tax-nal.fact-order       and                        bf_arh-fin-doc-c-schet-tax-nal.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-c-schet-tax-nal then do:                                        create new-arh-fin-doc-c-schet-tax-nal.                                                       buffer-copy old-arh-fin-doc-c-schet-tax-nal to new-arh-fin-doc-c-schet-tax-nal.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-s-nal-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-s-nal-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-s-nal-obj.                                                       buffer-copy old-arh-fin-doc-contr-s-nal-obj to new-arh-fin-doc-contr-s-nal-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-s-nal-obj where bf_arh-fin-doc-contr-s-nal-obj.host-code         = old-arh-fin-doc-contr-s-nal-obj.host-code        and                        bf_arh-fin-doc-contr-s-nal-obj.obj-type          = old-arh-fin-doc-contr-s-nal-obj.obj-type         and                        bf_arh-fin-doc-contr-s-nal-obj.obj-code          = old-arh-fin-doc-contr-s-nal-obj.obj-code         and                        bf_arh-fin-doc-contr-s-nal-obj.contract-code     = old-arh-fin-doc-contr-s-nal-obj.contract-code    and                        bf_arh-fin-doc-contr-s-nal-obj.cli-type          = old-arh-fin-doc-contr-s-nal-obj.cli-type         and                        bf_arh-fin-doc-contr-s-nal-obj.cli-code          = old-arh-fin-doc-contr-s-nal-obj.cli-code         and                        bf_arh-fin-doc-contr-s-nal-obj.fin-code-acc      = old-arh-fin-doc-contr-s-nal-obj.fin-code-acc     and                        bf_arh-fin-doc-contr-s-nal-obj.curr-code         = old-arh-fin-doc-contr-s-nal-obj.curr-code        and                        bf_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and                        bf_arh-fin-doc-contr-s-nal-obj.calc-curr-code    = old-arh-fin-doc-contr-s-nal-obj.calc-curr-code   and                        bf_arh-fin-doc-contr-s-nal-obj.sum-type          = old-arh-fin-doc-contr-s-nal-obj.sum-type         and                        bf_arh-fin-doc-contr-s-nal-obj.fact-order        > old-arh-fin-doc-contr-s-nal-obj.fact-order       and                        bf_arh-fin-doc-contr-s-nal-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-s-nal-obj then do:                                        create new-arh-fin-doc-contr-s-nal-obj.                                                       buffer-copy old-arh-fin-doc-contr-s-nal-obj to new-arh-fin-doc-contr-s-nal-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-s-tax-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-s-tax-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-s-tax-obj.                                                       buffer-copy old-arh-fin-doc-contr-s-tax-obj to new-arh-fin-doc-contr-s-tax-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-s-tax-obj where bf_arh-fin-doc-contr-s-tax-obj.host-code         = old-arh-fin-doc-contr-s-tax-obj.host-code        and                        bf_arh-fin-doc-contr-s-tax-obj.obj-type          = old-arh-fin-doc-contr-s-tax-obj.obj-type         and                        bf_arh-fin-doc-contr-s-tax-obj.obj-code          = old-arh-fin-doc-contr-s-tax-obj.obj-code         and                        bf_arh-fin-doc-contr-s-tax-obj.contract-code     = old-arh-fin-doc-contr-s-tax-obj.contract-code    and                        bf_arh-fin-doc-contr-s-tax-obj.cli-type          = old-arh-fin-doc-contr-s-tax-obj.cli-type         and                        bf_arh-fin-doc-contr-s-tax-obj.cli-code          = old-arh-fin-doc-contr-s-tax-obj.cli-code         and                        bf_arh-fin-doc-contr-s-tax-obj.code-schet        = old-arh-fin-doc-contr-s-tax-obj.code-schet       and                        bf_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type  = old-arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and                        bf_arh-fin-doc-contr-s-tax-obj.calc-curr-code    = old-arh-fin-doc-contr-s-tax-obj.calc-curr-code   and                        bf_arh-fin-doc-contr-s-tax-obj.VAT-pc            = old-arh-fin-doc-contr-s-tax-obj.VAT-pc           and                        bf_arh-fin-doc-contr-s-tax-obj.SLT-pc            = old-arh-fin-doc-contr-s-tax-obj.SLT-pc           and                        bf_arh-fin-doc-contr-s-tax-obj.with-vat          = old-arh-fin-doc-contr-s-tax-obj.with-vat         and                        bf_arh-fin-doc-contr-s-tax-obj.with-slt          = old-arh-fin-doc-contr-s-tax-obj.with-slt         and                        bf_arh-fin-doc-contr-s-tax-obj.sum-type          = old-arh-fin-doc-contr-s-tax-obj.sum-type         and                        bf_arh-fin-doc-contr-s-tax-obj.fact-order        > old-arh-fin-doc-contr-s-tax-obj.fact-order       and                        bf_arh-fin-doc-contr-s-tax-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-s-tax-obj then do:                                        create new-arh-fin-doc-contr-s-tax-obj.                                                       buffer-copy old-arh-fin-doc-contr-s-tax-obj to new-arh-fin-doc-contr-s-tax-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-schet no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-schet.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-schet.                                                       buffer-copy old-arh-fin-doc-contr-schet to new-arh-fin-doc-contr-schet.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-schet where bf_arh-fin-doc-contr-schet.host-code         = old-arh-fin-doc-contr-schet.host-code        and                        bf_arh-fin-doc-contr-schet.contract-code     = old-arh-fin-doc-contr-schet.contract-code    and                        bf_arh-fin-doc-contr-schet.cli-type          = old-arh-fin-doc-contr-schet.cli-type         and                        bf_arh-fin-doc-contr-schet.cli-code          = old-arh-fin-doc-contr-schet.cli-code         and                        bf_arh-fin-doc-contr-schet.code-schet        = old-arh-fin-doc-contr-schet.code-schet       and                        bf_arh-fin-doc-contr-schet.fin-ext-doc-type  = old-arh-fin-doc-contr-schet.fin-ext-doc-type and                        bf_arh-fin-doc-contr-schet.calc-curr-code    = old-arh-fin-doc-contr-schet.calc-curr-code   and                        bf_arh-fin-doc-contr-schet.sum-type          = old-arh-fin-doc-contr-schet.sum-type         and                        bf_arh-fin-doc-contr-schet.fact-order        > old-arh-fin-doc-contr-schet.fact-order       and                        bf_arh-fin-doc-contr-schet.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-schet then do:                                        create new-arh-fin-doc-contr-schet.                                                       buffer-copy old-arh-fin-doc-contr-schet to new-arh-fin-doc-contr-schet.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-schet-nal no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-schet-nal.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-schet-nal.                                                       buffer-copy old-arh-fin-doc-contr-schet-nal to new-arh-fin-doc-contr-schet-nal.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-schet-nal where bf_arh-fin-doc-contr-schet-nal.host-code         = old-arh-fin-doc-contr-schet-nal.host-code        and                        bf_arh-fin-doc-contr-schet-nal.contract-code     = old-arh-fin-doc-contr-schet-nal.contract-code    and                        bf_arh-fin-doc-contr-schet-nal.cli-type          = old-arh-fin-doc-contr-schet-nal.cli-type         and                        bf_arh-fin-doc-contr-schet-nal.cli-code          = old-arh-fin-doc-contr-schet-nal.cli-code         and                        bf_arh-fin-doc-contr-schet-nal.fin-code-acc      = old-arh-fin-doc-contr-schet-nal.fin-code-acc     and                        bf_arh-fin-doc-contr-schet-nal.curr-code         = old-arh-fin-doc-contr-schet-nal.curr-code        and                        bf_arh-fin-doc-contr-schet-nal.fin-ext-doc-type  = old-arh-fin-doc-contr-schet-nal.fin-ext-doc-type and                        bf_arh-fin-doc-contr-schet-nal.calc-curr-code    = old-arh-fin-doc-contr-schet-nal.calc-curr-code   and                        bf_arh-fin-doc-contr-schet-nal.sum-type          = old-arh-fin-doc-contr-schet-nal.sum-type         and                        bf_arh-fin-doc-contr-schet-nal.fact-order        > old-arh-fin-doc-contr-schet-nal.fact-order       and                        bf_arh-fin-doc-contr-schet-nal.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-schet-nal then do:                                        create new-arh-fin-doc-contr-schet-nal.                                                       buffer-copy old-arh-fin-doc-contr-schet-nal to new-arh-fin-doc-contr-schet-nal.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-schet-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-schet-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-schet-obj.                                                       buffer-copy old-arh-fin-doc-contr-schet-obj to new-arh-fin-doc-contr-schet-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-schet-obj where bf_arh-fin-doc-contr-schet-obj.host-code         = old-arh-fin-doc-contr-schet-obj.host-code        and                        bf_arh-fin-doc-contr-schet-obj.obj-type          = old-arh-fin-doc-contr-schet-obj.obj-type         and                        bf_arh-fin-doc-contr-schet-obj.obj-code          = old-arh-fin-doc-contr-schet-obj.obj-code         and                        bf_arh-fin-doc-contr-schet-obj.contract-code     = old-arh-fin-doc-contr-schet-obj.contract-code    and                        bf_arh-fin-doc-contr-schet-obj.cli-type          = old-arh-fin-doc-contr-schet-obj.cli-type         and                        bf_arh-fin-doc-contr-schet-obj.cli-code          = old-arh-fin-doc-contr-schet-obj.cli-code         and                        bf_arh-fin-doc-contr-schet-obj.code-schet        = old-arh-fin-doc-contr-schet-obj.code-schet       and                        bf_arh-fin-doc-contr-schet-obj.fin-ext-doc-type  = old-arh-fin-doc-contr-schet-obj.fin-ext-doc-type and                        bf_arh-fin-doc-contr-schet-obj.calc-curr-code    = old-arh-fin-doc-contr-schet-obj.calc-curr-code   and                        bf_arh-fin-doc-contr-schet-obj.sum-type          = old-arh-fin-doc-contr-schet-obj.sum-type         and                        bf_arh-fin-doc-contr-schet-obj.fact-order        > old-arh-fin-doc-contr-schet-obj.fact-order       and                        bf_arh-fin-doc-contr-schet-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-schet-obj then do:                                        create new-arh-fin-doc-contr-schet-obj.                                                       buffer-copy old-arh-fin-doc-contr-schet-obj to new-arh-fin-doc-contr-schet-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-contr-schet-tax no-lock on error undo, return error return-value :     if old-arh-fin-doc-contr-schet-tax.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-contr-schet-tax.                                                       buffer-copy old-arh-fin-doc-contr-schet-tax to new-arh-fin-doc-contr-schet-tax.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-contr-schet-tax where bf_arh-fin-doc-contr-schet-tax.host-code         = old-arh-fin-doc-contr-schet-tax.host-code        and                        bf_arh-fin-doc-contr-schet-tax.contract-code     = old-arh-fin-doc-contr-schet-tax.contract-code    and                        bf_arh-fin-doc-contr-schet-tax.cli-type          = old-arh-fin-doc-contr-schet-tax.cli-type         and                        bf_arh-fin-doc-contr-schet-tax.cli-code          = old-arh-fin-doc-contr-schet-tax.cli-code         and                        bf_arh-fin-doc-contr-schet-tax.code-schet        = old-arh-fin-doc-contr-schet-tax.code-schet       and                        bf_arh-fin-doc-contr-schet-tax.fin-ext-doc-type  = old-arh-fin-doc-contr-schet-tax.fin-ext-doc-type and                        bf_arh-fin-doc-contr-schet-tax.calc-curr-code    = old-arh-fin-doc-contr-schet-tax.calc-curr-code   and                        bf_arh-fin-doc-contr-schet-tax.VAT-pc            = old-arh-fin-doc-contr-schet-tax.VAT-pc           and                        bf_arh-fin-doc-contr-schet-tax.SLT-pc            = old-arh-fin-doc-contr-schet-tax.SLT-pc           and                        bf_arh-fin-doc-contr-schet-tax.with-vat          = old-arh-fin-doc-contr-schet-tax.with-vat         and                        bf_arh-fin-doc-contr-schet-tax.with-slt          = old-arh-fin-doc-contr-schet-tax.with-slt         and                        bf_arh-fin-doc-contr-schet-tax.sum-type          = old-arh-fin-doc-contr-schet-tax.sum-type         and                        bf_arh-fin-doc-contr-schet-tax.fact-order        > old-arh-fin-doc-contr-schet-tax.fact-order       and                        bf_arh-fin-doc-contr-schet-tax.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-contr-schet-tax then do:                                        create new-arh-fin-doc-contr-schet-tax.                                                       buffer-copy old-arh-fin-doc-contr-schet-tax to new-arh-fin-doc-contr-schet-tax.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-s-tax-nal-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-s-tax-nal-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-s-tax-nal-obj.                                                       buffer-copy old-arh-fin-doc-s-tax-nal-obj to new-arh-fin-doc-s-tax-nal-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-s-tax-nal-obj where bf_arh-fin-doc-s-tax-nal-obj.host-code         = old-arh-fin-doc-s-tax-nal-obj.host-code        and                        bf_arh-fin-doc-s-tax-nal-obj.obj-type          = old-arh-fin-doc-s-tax-nal-obj.obj-type         and                        bf_arh-fin-doc-s-tax-nal-obj.obj-code          = old-arh-fin-doc-s-tax-nal-obj.obj-code         and                        bf_arh-fin-doc-s-tax-nal-obj.cli-type          = old-arh-fin-doc-s-tax-nal-obj.cli-type         and                        bf_arh-fin-doc-s-tax-nal-obj.cli-code          = old-arh-fin-doc-s-tax-nal-obj.cli-code         and                        bf_arh-fin-doc-s-tax-nal-obj.fin-code-acc      = old-arh-fin-doc-s-tax-nal-obj.fin-code-acc     and                        bf_arh-fin-doc-s-tax-nal-obj.curr-code         = old-arh-fin-doc-s-tax-nal-obj.curr-code        and                        bf_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and                        bf_arh-fin-doc-s-tax-nal-obj.calc-curr-code    = old-arh-fin-doc-s-tax-nal-obj.calc-curr-code   and                        bf_arh-fin-doc-s-tax-nal-obj.VAT-pc            = old-arh-fin-doc-s-tax-nal-obj.VAT-pc           and                        bf_arh-fin-doc-s-tax-nal-obj.SLT-pc            = old-arh-fin-doc-s-tax-nal-obj.SLT-pc           and                        bf_arh-fin-doc-s-tax-nal-obj.with-vat          = old-arh-fin-doc-s-tax-nal-obj.with-vat         and                        bf_arh-fin-doc-s-tax-nal-obj.with-slt          = old-arh-fin-doc-s-tax-nal-obj.with-slt         and                        bf_arh-fin-doc-s-tax-nal-obj.sum-type          = old-arh-fin-doc-s-tax-nal-obj.sum-type         and                        bf_arh-fin-doc-s-tax-nal-obj.fact-order        > old-arh-fin-doc-s-tax-nal-obj.fact-order       and                        bf_arh-fin-doc-s-tax-nal-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-s-tax-nal-obj then do:                                        create new-arh-fin-doc-s-tax-nal-obj.                                                       buffer-copy old-arh-fin-doc-s-tax-nal-obj to new-arh-fin-doc-s-tax-nal-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet.                                                       buffer-copy old-arh-fin-doc-schet to new-arh-fin-doc-schet.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet where bf_arh-fin-doc-schet.host-code         = old-arh-fin-doc-schet.host-code        and                        bf_arh-fin-doc-schet.cli-type          = old-arh-fin-doc-schet.cli-type         and                        bf_arh-fin-doc-schet.cli-code          = old-arh-fin-doc-schet.cli-code         and                        bf_arh-fin-doc-schet.code-schet        = old-arh-fin-doc-schet.code-schet       and                        bf_arh-fin-doc-schet.fin-ext-doc-type  = old-arh-fin-doc-schet.fin-ext-doc-type and                        bf_arh-fin-doc-schet.calc-curr-code    = old-arh-fin-doc-schet.calc-curr-code   and                        bf_arh-fin-doc-schet.sum-type          = old-arh-fin-doc-schet.sum-type         and                        bf_arh-fin-doc-schet.fact-order        > old-arh-fin-doc-schet.fact-order       and                        bf_arh-fin-doc-schet.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet then do:                                        create new-arh-fin-doc-schet.                                                       buffer-copy old-arh-fin-doc-schet to new-arh-fin-doc-schet.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-nal no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-nal.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-nal.                                                       buffer-copy old-arh-fin-doc-schet-nal to new-arh-fin-doc-schet-nal.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-nal where bf_arh-fin-doc-schet-nal.host-code         = old-arh-fin-doc-schet-nal.host-code        and                        bf_arh-fin-doc-schet-nal.cli-type          = old-arh-fin-doc-schet-nal.cli-type         and                        bf_arh-fin-doc-schet-nal.cli-code          = old-arh-fin-doc-schet-nal.cli-code         and                        bf_arh-fin-doc-schet-nal.fin-code-acc      = old-arh-fin-doc-schet-nal.fin-code-acc     and                        bf_arh-fin-doc-schet-nal.curr-code         = old-arh-fin-doc-schet-nal.curr-code        and                        bf_arh-fin-doc-schet-nal.fin-ext-doc-type  = old-arh-fin-doc-schet-nal.fin-ext-doc-type and                        bf_arh-fin-doc-schet-nal.calc-curr-code    = old-arh-fin-doc-schet-nal.calc-curr-code   and                        bf_arh-fin-doc-schet-nal.sum-type          = old-arh-fin-doc-schet-nal.sum-type         and                        bf_arh-fin-doc-schet-nal.fact-order        > old-arh-fin-doc-schet-nal.fact-order       and                        bf_arh-fin-doc-schet-nal.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-nal then do:                                        create new-arh-fin-doc-schet-nal.                                                       buffer-copy old-arh-fin-doc-schet-nal to new-arh-fin-doc-schet-nal.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-nal-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-nal-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-nal-obj.                                                       buffer-copy old-arh-fin-doc-schet-nal-obj to new-arh-fin-doc-schet-nal-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-nal-obj where bf_arh-fin-doc-schet-nal-obj.host-code         = old-arh-fin-doc-schet-nal-obj.host-code        and                        bf_arh-fin-doc-schet-nal-obj.obj-type          = old-arh-fin-doc-schet-nal-obj.obj-type         and                        bf_arh-fin-doc-schet-nal-obj.obj-code          = old-arh-fin-doc-schet-nal-obj.obj-code         and                        bf_arh-fin-doc-schet-nal-obj.cli-type          = old-arh-fin-doc-schet-nal-obj.cli-type         and                        bf_arh-fin-doc-schet-nal-obj.cli-code          = old-arh-fin-doc-schet-nal-obj.cli-code         and                        bf_arh-fin-doc-schet-nal-obj.fin-code-acc      = old-arh-fin-doc-schet-nal-obj.fin-code-acc     and                        bf_arh-fin-doc-schet-nal-obj.curr-code         = old-arh-fin-doc-schet-nal-obj.curr-code        and                        bf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-schet-nal-obj.fin-ext-doc-type and                        bf_arh-fin-doc-schet-nal-obj.calc-curr-code    = old-arh-fin-doc-schet-nal-obj.calc-curr-code   and                        bf_arh-fin-doc-schet-nal-obj.sum-type          = old-arh-fin-doc-schet-nal-obj.sum-type         and                        bf_arh-fin-doc-schet-nal-obj.fact-order        > old-arh-fin-doc-schet-nal-obj.fact-order       and                        bf_arh-fin-doc-schet-nal-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-nal-obj then do:                                        create new-arh-fin-doc-schet-nal-obj.                                                       buffer-copy old-arh-fin-doc-schet-nal-obj to new-arh-fin-doc-schet-nal-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-obj.                                                       buffer-copy old-arh-fin-doc-schet-obj to new-arh-fin-doc-schet-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-obj where bf_arh-fin-doc-schet-obj.host-code         = old-arh-fin-doc-schet-obj.host-code        and                        bf_arh-fin-doc-schet-obj.obj-type          = old-arh-fin-doc-schet-obj.obj-type         and                        bf_arh-fin-doc-schet-obj.obj-code          = old-arh-fin-doc-schet-obj.obj-code         and                        bf_arh-fin-doc-schet-obj.cli-type          = old-arh-fin-doc-schet-obj.cli-type         and                        bf_arh-fin-doc-schet-obj.cli-code          = old-arh-fin-doc-schet-obj.cli-code         and                        bf_arh-fin-doc-schet-obj.code-schet        = old-arh-fin-doc-schet-obj.code-schet       and                        bf_arh-fin-doc-schet-obj.fin-ext-doc-type  = old-arh-fin-doc-schet-obj.fin-ext-doc-type and                        bf_arh-fin-doc-schet-obj.calc-curr-code    = old-arh-fin-doc-schet-obj.calc-curr-code   and                        bf_arh-fin-doc-schet-obj.sum-type          = old-arh-fin-doc-schet-obj.sum-type         and                        bf_arh-fin-doc-schet-obj.fact-order        > old-arh-fin-doc-schet-obj.fact-order       and                        bf_arh-fin-doc-schet-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-obj then do:                                        create new-arh-fin-doc-schet-obj.                                                       buffer-copy old-arh-fin-doc-schet-obj to new-arh-fin-doc-schet-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-tax no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-tax.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-tax.                                                       buffer-copy old-arh-fin-doc-schet-tax to new-arh-fin-doc-schet-tax.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-tax where bf_arh-fin-doc-schet-tax.host-code         = old-arh-fin-doc-schet-tax.host-code        and                        bf_arh-fin-doc-schet-tax.cli-type          = old-arh-fin-doc-schet-tax.cli-type         and                        bf_arh-fin-doc-schet-tax.cli-code          = old-arh-fin-doc-schet-tax.cli-code         and                        bf_arh-fin-doc-schet-tax.code-schet        = old-arh-fin-doc-schet-tax.code-schet       and                        bf_arh-fin-doc-schet-tax.fin-ext-doc-type  = old-arh-fin-doc-schet-tax.fin-ext-doc-type and                        bf_arh-fin-doc-schet-tax.calc-curr-code    = old-arh-fin-doc-schet-tax.calc-curr-code   and                        bf_arh-fin-doc-schet-tax.VAT-pc            = old-arh-fin-doc-schet-tax.VAT-pc           and                        bf_arh-fin-doc-schet-tax.SLT-pc            = old-arh-fin-doc-schet-tax.SLT-pc           and                        bf_arh-fin-doc-schet-tax.with-vat          = old-arh-fin-doc-schet-tax.with-vat         and                        bf_arh-fin-doc-schet-tax.with-slt          = old-arh-fin-doc-schet-tax.with-slt         and                        bf_arh-fin-doc-schet-tax.sum-type          = old-arh-fin-doc-schet-tax.sum-type         and                        bf_arh-fin-doc-schet-tax.fact-order        > old-arh-fin-doc-schet-tax.fact-order       and                        bf_arh-fin-doc-schet-tax.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-tax then do:                                        create new-arh-fin-doc-schet-tax.                                                       buffer-copy old-arh-fin-doc-schet-tax to new-arh-fin-doc-schet-tax.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-tax-nal no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-tax-nal.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-tax-nal.                                                       buffer-copy old-arh-fin-doc-schet-tax-nal to new-arh-fin-doc-schet-tax-nal.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-tax-nal where bf_arh-fin-doc-schet-tax-nal.host-code         = old-arh-fin-doc-schet-tax-nal.host-code        and                        bf_arh-fin-doc-schet-tax-nal.cli-type          = old-arh-fin-doc-schet-tax-nal.cli-type         and                        bf_arh-fin-doc-schet-tax-nal.cli-code          = old-arh-fin-doc-schet-tax-nal.cli-code         and                        bf_arh-fin-doc-schet-tax-nal.fin-code-acc      = old-arh-fin-doc-schet-tax-nal.fin-code-acc     and                        bf_arh-fin-doc-schet-tax-nal.curr-code         = old-arh-fin-doc-schet-tax-nal.curr-code        and                        bf_arh-fin-doc-schet-tax-nal.fin-ext-doc-type  = old-arh-fin-doc-schet-tax-nal.fin-ext-doc-type and                        bf_arh-fin-doc-schet-tax-nal.calc-curr-code    = old-arh-fin-doc-schet-tax-nal.calc-curr-code   and                        bf_arh-fin-doc-schet-tax-nal.VAT-pc            = old-arh-fin-doc-schet-tax-nal.VAT-pc           and                        bf_arh-fin-doc-schet-tax-nal.SLT-pc            = old-arh-fin-doc-schet-tax-nal.SLT-pc           and                        bf_arh-fin-doc-schet-tax-nal.with-vat          = old-arh-fin-doc-schet-tax-nal.with-vat         and                        bf_arh-fin-doc-schet-tax-nal.with-slt          = old-arh-fin-doc-schet-tax-nal.with-slt         and                        bf_arh-fin-doc-schet-tax-nal.sum-type          = old-arh-fin-doc-schet-tax-nal.sum-type         and                        bf_arh-fin-doc-schet-tax-nal.fact-order        > old-arh-fin-doc-schet-tax-nal.fact-order       and                        bf_arh-fin-doc-schet-tax-nal.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-tax-nal then do:                                        create new-arh-fin-doc-schet-tax-nal.                                                       buffer-copy old-arh-fin-doc-schet-tax-nal to new-arh-fin-doc-schet-tax-nal.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-doc-schet-tax-obj no-lock on error undo, return error return-value :     if old-arh-fin-doc-schet-tax-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-doc-schet-tax-obj.                                                       buffer-copy old-arh-fin-doc-schet-tax-obj to new-arh-fin-doc-schet-tax-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-doc-schet-tax-obj where bf_arh-fin-doc-schet-tax-obj.host-code         = old-arh-fin-doc-schet-tax-obj.host-code        and                        bf_arh-fin-doc-schet-tax-obj.obj-type          = old-arh-fin-doc-schet-tax-obj.obj-type         and                        bf_arh-fin-doc-schet-tax-obj.obj-code          = old-arh-fin-doc-schet-tax-obj.obj-code         and                        bf_arh-fin-doc-schet-tax-obj.cli-type          = old-arh-fin-doc-schet-tax-obj.cli-type         and                        bf_arh-fin-doc-schet-tax-obj.cli-code          = old-arh-fin-doc-schet-tax-obj.cli-code         and                        bf_arh-fin-doc-schet-tax-obj.code-schet        = old-arh-fin-doc-schet-tax-obj.code-schet       and                        bf_arh-fin-doc-schet-tax-obj.fin-ext-doc-type  = old-arh-fin-doc-schet-tax-obj.fin-ext-doc-type and                        bf_arh-fin-doc-schet-tax-obj.calc-curr-code    = old-arh-fin-doc-schet-tax-obj.calc-curr-code   and                        bf_arh-fin-doc-schet-tax-obj.VAT-pc            = old-arh-fin-doc-schet-tax-obj.VAT-pc           and                        bf_arh-fin-doc-schet-tax-obj.SLT-pc            = old-arh-fin-doc-schet-tax-obj.SLT-pc           and                        bf_arh-fin-doc-schet-tax-obj.with-vat          = old-arh-fin-doc-schet-tax-obj.with-vat         and                        bf_arh-fin-doc-schet-tax-obj.with-slt          = old-arh-fin-doc-schet-tax-obj.with-slt         and                        bf_arh-fin-doc-schet-tax-obj.sum-type          = old-arh-fin-doc-schet-tax-obj.sum-type         and                        bf_arh-fin-doc-schet-tax-obj.fact-order        > old-arh-fin-doc-schet-tax-obj.fact-order       and                        bf_arh-fin-doc-schet-tax-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-doc-schet-tax-obj then do:                                        create new-arh-fin-doc-schet-tax-obj.                                                       buffer-copy old-arh-fin-doc-schet-tax-obj to new-arh-fin-doc-schet-tax-obj.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-ob-contr no-lock on error undo, return error return-value :     if old-arh-fin-ob-contr.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-ob-contr.                                                       buffer-copy old-arh-fin-ob-contr to new-arh-fin-ob-contr.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-ob-contr where bf_arh-fin-ob-contr.host-code         = old-arh-fin-ob-contr.host-code        and                        bf_arh-fin-ob-contr.contract-code     = old-arh-fin-ob-contr.contract-code    and                        bf_arh-fin-ob-contr.cli-type          = old-arh-fin-ob-contr.cli-type         and                        bf_arh-fin-ob-contr.cli-code          = old-arh-fin-ob-contr.cli-code         and                        bf_arh-fin-ob-contr.fin-ext-doc-type  = old-arh-fin-ob-contr.fin-ext-doc-type and                        bf_arh-fin-ob-contr.calc-curr-code    = old-arh-fin-ob-contr.calc-curr-code   and                        bf_arh-fin-ob-contr.sum-type          = old-arh-fin-ob-contr.sum-type         and                        bf_arh-fin-ob-contr.fact-order        > old-arh-fin-ob-contr.fact-order       and                        bf_arh-fin-ob-contr.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-ob-contr then do:                                        create new-arh-fin-ob-contr.                                                       buffer-copy old-arh-fin-ob-contr to new-arh-fin-ob-contr.                     end.                                                                                end.                                                                                end.
      for each old-arh-fin-ob-contr-obj no-lock on error undo, return error return-value :     if old-arh-fin-ob-contr-obj.fact-order > var-fact-order-findoc then do:                  create new-arh-fin-ob-contr-obj.                                                       buffer-copy old-arh-fin-ob-contr-obj to new-arh-fin-ob-contr-obj.                     end.                                                                                  else do:                                                                                find first bf_arh-fin-ob-contr-obj where bf_arh-fin-ob-contr-obj.host-code         = old-arh-fin-ob-contr-obj.host-code        and                        bf_arh-fin-ob-contr-obj.obj-type          = old-arh-fin-ob-contr-obj.obj-type         and                        bf_arh-fin-ob-contr-obj.obj-code          = old-arh-fin-ob-contr-obj.obj-code         and                        bf_arh-fin-ob-contr-obj.contract-code     = old-arh-fin-ob-contr-obj.contract-code    and                        bf_arh-fin-ob-contr-obj.cli-type          = old-arh-fin-ob-contr-obj.cli-type         and                        bf_arh-fin-ob-contr-obj.cli-code          = old-arh-fin-ob-contr-obj.cli-code         and                        bf_arh-fin-ob-contr-obj.fin-ext-doc-type  = old-arh-fin-ob-contr-obj.fin-ext-doc-type and                        bf_arh-fin-ob-contr-obj.calc-curr-code    = old-arh-fin-ob-contr-obj.calc-curr-code   and                        bf_arh-fin-ob-contr-obj.sum-type          = old-arh-fin-ob-contr-obj.sum-type         and                        bf_arh-fin-ob-contr-obj.fact-order        > old-arh-fin-ob-contr-obj.fact-order       and                        bf_arh-fin-ob-contr-obj.fact-order       <= var-fact-order-findoc no-error.                     if not available bf_arh-fin-ob-contr-obj then do:                                        create new-arh-fin-ob-contr-obj.                                                       buffer-copy old-arh-fin-ob-contr-obj to new-arh-fin-ob-contr-obj.                     end.                                                                                end.                                                                                end.
for each old-arh-fin-doc-an-attr   no-lock , first new-arh-fin-doc-an where   new-arh-fin-doc-an.host-code         = old-arh-fin-doc-an-attr.host-code  and    new-arh-fin-doc-an.cli-type          = old-arh-fin-doc-an-attr.cli-type   and    new-arh-fin-doc-an.cli-code          = old-arh-fin-doc-an-attr.cli-code    and   new-arh-fin-doc-an.code-schet        = old-arh-fin-doc-an-attr.code-schet   and   new-arh-fin-doc-an.fin-ext-doc-type  = old-arh-fin-doc-an-attr.fin-ext-doc-type  and   new-arh-fin-doc-an.fin-code-an-uchet = old-arh-fin-doc-an-attr.fin-code-an-uchet  and   new-arh-fin-doc-an.fin-code-cel-nazn = old-arh-fin-doc-an-attr.fin-code-cel-nazn  and   new-arh-fin-doc-an.fin-code-cor-acc  = old-arh-fin-doc-an-attr.fin-code-cor-acc  and   new-arh-fin-doc-an.calc-curr-code    = old-arh-fin-doc-an-attr.calc-curr-code  and    new-arh-fin-doc-an.sum-type          = old-arh-fin-doc-an-attr.sum-type    and     new-arh-fin-doc-an.fact-order        = old-arh-fin-doc-an-attr.fact-order   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-an-attr.
   buffer-copy old-arh-fin-doc-an-attr to new-arh-fin-doc-an-attr.
end.
for each old-arh-fin-doc-an-nal-attr  no-lock , first new-arh-fin-doc-an-nal where new-arh-fin-doc-an-nal.host-code         = old-arh-fin-doc-an-nal-attr.host-code         and  new-arh-fin-doc-an-nal.cli-type          = old-arh-fin-doc-an-nal-attr.cli-type          and  new-arh-fin-doc-an-nal.cli-code          = old-arh-fin-doc-an-nal-attr.cli-code          and  new-arh-fin-doc-an-nal.fin-code-acc      = old-arh-fin-doc-an-nal-attr.fin-code-acc      and  new-arh-fin-doc-an-nal.curr-code         = old-arh-fin-doc-an-nal-attr.curr-code         and  new-arh-fin-doc-an-nal.fin-ext-doc-type  = old-arh-fin-doc-an-nal-attr.fin-ext-doc-type  and  new-arh-fin-doc-an-nal.fin-code-an-uchet = old-arh-fin-doc-an-nal-attr.fin-code-an-uchet and  new-arh-fin-doc-an-nal.fin-code-cel-nazn = old-arh-fin-doc-an-nal-attr.fin-code-cel-nazn and  new-arh-fin-doc-an-nal.fin-code-cor-acc  = old-arh-fin-doc-an-nal-attr.fin-code-cor-acc  and  new-arh-fin-doc-an-nal.calc-curr-code    = old-arh-fin-doc-an-nal-attr.calc-curr-code    and  new-arh-fin-doc-an-nal.sum-type          = old-arh-fin-doc-an-nal-attr.sum-type          and  new-arh-fin-doc-an-nal.fact-order        = old-arh-fin-doc-an-nal-attr.fact-order         no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-an-nal-attr.
   buffer-copy old-arh-fin-doc-an-nal-attr to new-arh-fin-doc-an-nal-attr.
end.
for each old-arh-fin-doc-an-nal-obj-attr  no-lock , first new-arh-fin-doc-an-nal-obj where new-arh-fin-doc-an-nal-obj.host-code         = old-arh-fin-doc-an-nal-obj-attr.host-code          and  new-arh-fin-doc-an-nal-obj.obj-type          = old-arh-fin-doc-an-nal-obj-attr.obj-type           and  new-arh-fin-doc-an-nal-obj.obj-code          = old-arh-fin-doc-an-nal-obj-attr.obj-code           and  new-arh-fin-doc-an-nal-obj.cli-type          = old-arh-fin-doc-an-nal-obj-attr.cli-type           and  new-arh-fin-doc-an-nal-obj.cli-code          = old-arh-fin-doc-an-nal-obj-attr.cli-code           and  new-arh-fin-doc-an-nal-obj.fin-code-acc      = old-arh-fin-doc-an-nal-obj-attr.fin-code-acc       and  new-arh-fin-doc-an-nal-obj.curr-code         = old-arh-fin-doc-an-nal-obj-attr.curr-code          and  new-arh-fin-doc-an-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-an-nal-obj-attr.fin-ext-doc-type   and  new-arh-fin-doc-an-nal-obj.fin-code-an-uchet = old-arh-fin-doc-an-nal-obj-attr.fin-code-an-uchet  and  new-arh-fin-doc-an-nal-obj.fin-code-cel-nazn = old-arh-fin-doc-an-nal-obj-attr.fin-code-cel-nazn  and  new-arh-fin-doc-an-nal-obj.fin-code-cor-acc  = old-arh-fin-doc-an-nal-obj-attr.fin-code-cor-acc   and  new-arh-fin-doc-an-nal-obj.calc-curr-code    = old-arh-fin-doc-an-nal-obj-attr.calc-curr-code     and  new-arh-fin-doc-an-nal-obj.sum-type          = old-arh-fin-doc-an-nal-obj-attr.sum-type           and  new-arh-fin-doc-an-nal-obj.fact-order        = old-arh-fin-doc-an-nal-obj-attr.fact-order       no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-an-nal-obj-attr.
   buffer-copy old-arh-fin-doc-an-nal-obj-attr to new-arh-fin-doc-an-nal-obj-attr.
end.
for each old-arh-fin-doc-an-obj-attr  no-lock , first new-arh-fin-doc-an-obj where new-arh-fin-doc-an-obj.host-code           = old-arh-fin-doc-an-obj-attr.host-code           and  new-arh-fin-doc-an-obj.obj-type            = old-arh-fin-doc-an-obj-attr.obj-type            and  new-arh-fin-doc-an-obj.obj-code            = old-arh-fin-doc-an-obj-attr.obj-code            and  new-arh-fin-doc-an-obj.cli-type            = old-arh-fin-doc-an-obj-attr.cli-type            and  new-arh-fin-doc-an-obj.cli-code            = old-arh-fin-doc-an-obj-attr.cli-code            and  new-arh-fin-doc-an-obj.code-schet          = old-arh-fin-doc-an-obj-attr.code-schet          and  new-arh-fin-doc-an-obj.fin-ext-doc-type    = old-arh-fin-doc-an-obj-attr.fin-ext-doc-type    and  new-arh-fin-doc-an-obj.fin-code-an-uchet   = old-arh-fin-doc-an-obj-attr.fin-code-an-uchet   and  new-arh-fin-doc-an-obj.fin-code-cel-nazn   = old-arh-fin-doc-an-obj-attr.fin-code-cel-nazn   and  new-arh-fin-doc-an-obj.fin-code-cor-acc    = old-arh-fin-doc-an-obj-attr.fin-code-cor-acc    and  new-arh-fin-doc-an-obj.calc-curr-code      = old-arh-fin-doc-an-obj-attr.calc-curr-code      and  new-arh-fin-doc-an-obj.sum-type            = old-arh-fin-doc-an-obj-attr.sum-type            and  new-arh-fin-doc-an-obj.fact-order          = old-arh-fin-doc-an-obj-attr.fact-order           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-an-obj-attr.
   buffer-copy old-arh-fin-doc-an-obj-attr to new-arh-fin-doc-an-obj-attr.
end.
for each old-arh-fin-doc-contr-schet-attr  no-lock , first new-arh-fin-doc-contr-schet where new-arh-fin-doc-contr-schet.host-code          = old-arh-fin-doc-contr-schet-attr.host-code           and  new-arh-fin-doc-contr-schet.contract-code      = old-arh-fin-doc-contr-schet-attr.contract-code       and  new-arh-fin-doc-contr-schet.cli-type           = old-arh-fin-doc-contr-schet-attr.cli-type            and  new-arh-fin-doc-contr-schet.cli-code           = old-arh-fin-doc-contr-schet-attr.cli-code            and  new-arh-fin-doc-contr-schet.code-schet         = old-arh-fin-doc-contr-schet-attr.code-schet          and  new-arh-fin-doc-contr-schet.fin-ext-doc-type   = old-arh-fin-doc-contr-schet-attr.fin-ext-doc-type    and  new-arh-fin-doc-contr-schet.calc-curr-code     = old-arh-fin-doc-contr-schet-attr.calc-curr-code      and  new-arh-fin-doc-contr-schet.sum-type           = old-arh-fin-doc-contr-schet-attr.sum-type            and  new-arh-fin-doc-contr-schet.fact-order         = old-arh-fin-doc-contr-schet-attr.fact-order           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-contr-schet-attr.
   buffer-copy old-arh-fin-doc-contr-schet-attr to new-arh-fin-doc-contr-schet-attr.
end.
for each old-arh-fin-doc-schet-attr  no-lock , first new-arh-fin-doc-schet where new-arh-fin-doc-schet.host-code        = old-arh-fin-doc-schet-attr.host-code          and  new-arh-fin-doc-schet.cli-type         = old-arh-fin-doc-schet-attr.cli-type           and  new-arh-fin-doc-schet.cli-code         = old-arh-fin-doc-schet-attr.cli-code           and  new-arh-fin-doc-schet.code-schet       = old-arh-fin-doc-schet-attr.code-schet         and  new-arh-fin-doc-schet.fin-ext-doc-type = old-arh-fin-doc-schet-attr.fin-ext-doc-type   and  new-arh-fin-doc-schet.calc-curr-code   = old-arh-fin-doc-schet-attr.calc-curr-code     and  new-arh-fin-doc-schet.sum-type         = old-arh-fin-doc-schet-attr.sum-type           and  new-arh-fin-doc-schet.fact-order       = old-arh-fin-doc-schet-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-schet-attr.
   buffer-copy old-arh-fin-doc-schet-attr to new-arh-fin-doc-schet-attr.
end.
for each old-arh-fin-doc-schet-nal-attr  no-lock , first new-arh-fin-doc-schet-nal where new-arh-fin-doc-schet-nal.host-code         = old-arh-fin-doc-schet-nal-attr.host-code           and  new-arh-fin-doc-schet-nal.cli-type          = old-arh-fin-doc-schet-nal-attr.cli-type            and  new-arh-fin-doc-schet-nal.cli-code          = old-arh-fin-doc-schet-nal-attr.cli-code            and  new-arh-fin-doc-schet-nal.fin-code-acc      = old-arh-fin-doc-schet-nal-attr.fin-code-acc        and  new-arh-fin-doc-schet-nal.curr-code         = old-arh-fin-doc-schet-nal-attr.curr-code           and  new-arh-fin-doc-schet-nal.fin-ext-doc-type  = old-arh-fin-doc-schet-nal-attr.fin-ext-doc-type    and  new-arh-fin-doc-schet-nal.calc-curr-code    = old-arh-fin-doc-schet-nal-attr.calc-curr-code      and  new-arh-fin-doc-schet-nal.sum-type          = old-arh-fin-doc-schet-nal-attr.sum-type            and  new-arh-fin-doc-schet-nal.fact-order        = old-arh-fin-doc-schet-nal-attr.fact-order           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-schet-nal-attr.
   buffer-copy old-arh-fin-doc-schet-nal-attr to new-arh-fin-doc-schet-nal-attr.
end.
for each old-arh-fin-doc-schet-obj-attr  no-lock , first new-arh-fin-doc-schet-obj where new-arh-fin-doc-schet-obj.host-code         = old-arh-fin-doc-schet-obj-attr.host-code           and  new-arh-fin-doc-schet-obj.obj-type          = old-arh-fin-doc-schet-obj-attr.obj-type            and  new-arh-fin-doc-schet-obj.obj-code          = old-arh-fin-doc-schet-obj-attr.obj-code            and  new-arh-fin-doc-schet-obj.cli-type          = old-arh-fin-doc-schet-obj-attr.cli-type            and  new-arh-fin-doc-schet-obj.cli-code          = old-arh-fin-doc-schet-obj-attr.cli-code            and  new-arh-fin-doc-schet-obj.code-schet        = old-arh-fin-doc-schet-obj-attr.code-schet          and  new-arh-fin-doc-schet-obj.fin-ext-doc-type  = old-arh-fin-doc-schet-obj-attr.fin-ext-doc-type    and  new-arh-fin-doc-schet-obj.calc-curr-code    = old-arh-fin-doc-schet-obj-attr.calc-curr-code      and  new-arh-fin-doc-schet-obj.sum-type          = old-arh-fin-doc-schet-obj-attr.sum-type            and  new-arh-fin-doc-schet-obj.fact-order        = old-arh-fin-doc-schet-obj-attr.fact-order           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-schet-obj-attr.
   buffer-copy old-arh-fin-doc-schet-obj-attr to new-arh-fin-doc-schet-obj-attr.
end.
for each old-arh-fin-doc-schet-tax-attr  no-lock , first new-arh-fin-doc-schet-tax where new-arh-fin-doc-schet-tax.host-code              = old-arh-fin-doc-schet-tax-attr.host-code        and  new-arh-fin-doc-schet-tax.cli-type               = old-arh-fin-doc-schet-tax-attr.cli-type         and  new-arh-fin-doc-schet-tax.cli-code               = old-arh-fin-doc-schet-tax-attr.cli-code         and  new-arh-fin-doc-schet-tax.code-schet             = old-arh-fin-doc-schet-tax-attr.code-schet       and  new-arh-fin-doc-schet-tax.fin-ext-doc-type       = old-arh-fin-doc-schet-tax-attr.fin-ext-doc-type and  new-arh-fin-doc-schet-tax.calc-curr-code         = old-arh-fin-doc-schet-tax-attr.calc-curr-code   and  new-arh-fin-doc-schet-tax.VAT-pc                 = old-arh-fin-doc-schet-tax-attr.VAT-pc           and  new-arh-fin-doc-schet-tax.SLT-pc                 = old-arh-fin-doc-schet-tax-attr.SLT-pc           and  new-arh-fin-doc-schet-tax.with-vat               = old-arh-fin-doc-schet-tax-attr.with-vat         and  new-arh-fin-doc-schet-tax.with-slt               = old-arh-fin-doc-schet-tax-attr.with-slt         and  new-arh-fin-doc-schet-tax.sum-type               = old-arh-fin-doc-schet-tax-attr.sum-type         and  new-arh-fin-doc-schet-tax.fact-order             = old-arh-fin-doc-schet-tax-attr.fact-order        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-doc-schet-tax-attr.
   buffer-copy old-arh-fin-doc-schet-tax-attr to new-arh-fin-doc-schet-tax-attr.
end.
for each old-arh-fin-ob-contr-attr  no-lock , first new-arh-fin-ob-contr      where new-arh-fin-ob-contr.host-code         = old-arh-fin-ob-contr-attr.host-code         and  new-arh-fin-ob-contr.contract-code     = old-arh-fin-ob-contr-attr.contract-code     and  new-arh-fin-ob-contr.cli-type          = old-arh-fin-ob-contr-attr.cli-type          and  new-arh-fin-ob-contr.cli-code          = old-arh-fin-ob-contr-attr.cli-code          and  new-arh-fin-ob-contr.fin-ext-doc-type  = old-arh-fin-ob-contr-attr.fin-ext-doc-type  and  new-arh-fin-ob-contr.calc-curr-code    = old-arh-fin-ob-contr-attr.calc-curr-code    and  new-arh-fin-ob-contr.sum-type          = old-arh-fin-ob-contr-attr.sum-type          and  new-arh-fin-ob-contr.fact-order        = old-arh-fin-ob-contr-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-ob-contr-attr.
   buffer-copy old-arh-fin-ob-contr-attr to new-arh-fin-ob-contr-attr.
end.
for each old-arh-fin-ob-contr-obj-attr  no-lock , first new-arh-fin-ob-contr-obj  where new-arh-fin-ob-contr-obj.host-code          = old-arh-fin-ob-contr-obj-attr.host-code          and  new-arh-fin-ob-contr-obj.obj-type           = old-arh-fin-ob-contr-obj-attr.obj-type           and  new-arh-fin-ob-contr-obj.obj-code           = old-arh-fin-ob-contr-obj-attr.obj-code           and  new-arh-fin-ob-contr-obj.contract-code      = old-arh-fin-ob-contr-obj-attr.contract-code      and  new-arh-fin-ob-contr-obj.cli-type           = old-arh-fin-ob-contr-obj-attr.cli-type           and  new-arh-fin-ob-contr-obj.cli-code           = old-arh-fin-ob-contr-obj-attr.cli-code           and  new-arh-fin-ob-contr-obj.fin-ext-doc-type   = old-arh-fin-ob-contr-obj-attr.fin-ext-doc-type   and  new-arh-fin-ob-contr-obj.calc-curr-code     = old-arh-fin-ob-contr-obj-attr.calc-curr-code     and  new-arh-fin-ob-contr-obj.sum-type           = old-arh-fin-ob-contr-obj-attr.sum-type           and  new-arh-fin-ob-contr-obj.fact-order         = old-arh-fin-ob-contr-obj-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-fin-ob-contr-obj-attr.
   buffer-copy old-arh-fin-ob-contr-obj-attr to new-arh-fin-ob-contr-obj-attr.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц:  arh-fin-doc-an arh-fin-doc-an-nal arh-fin-doc-an-nal-obj arh-fin-doc-an-obj arh-fin-doc-c-s-tax-nal-obj arh-fin-doc-c-schet-tax-nal arh-fin-doc-contr-s-nal-obj arh-fin-doc-contr-s-tax-obj arh-fin-doc-contr-schet arh-fin-doc-contr-schet-nal arh-fin-doc-contr-schet-obj arh-fin-doc-contr-schet-tax arh-fin-doc-s-tax-nal-obj arh-fin-doc-schet arh-fin-doc-schet-nal arh-fin-doc-schet-nal-obj arh-fin-doc-schet-obj arh-fin-doc-schet-tax arh-fin-doc-schet-tax-nal arh-fin-doc-schet-tax-obj arh-fin-ob-contr arh-fin-ob-contr-obj.".
end.
