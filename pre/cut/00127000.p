block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00127000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00127000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 127.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-ord-blank for src.ord-blank.
define buffer new-ord-blank for dst.ord-blank.
define buffer old-ord-doc   for src.ord-doc  .
define buffer new-ord-doc   for dst.ord-doc  .
define buffer old-edi-status   for src.edi-status  .
define buffer new-edi-status   for dst.edi-status  .
define buffer old-c-ord-doc   for src.c-ord-doc  .
define buffer new-c-ord-doc   for dst.c-ord-doc  .
define buffer old-c-ord-doc-attr   for src.c-ord-doc-attr  .
define buffer new-c-ord-doc-attr   for dst.c-ord-doc-attr  .
define buffer old-ord-doc-attr   for src.ord-doc-attr  .
define buffer new-ord-doc-attr   for dst.ord-doc-attr  .
define buffer old-ord-line  for src.ord-line .
define buffer new-ord-line  for dst.ord-line .
define buffer old-c-ord-line  for src.c-ord-line .
define buffer new-c-ord-line  for dst.c-ord-line .
define buffer old-c-ord-line-attr  for src.c-ord-line-attr .
define buffer new-c-ord-line-attr  for dst.c-ord-line-attr .
define buffer old-c-ord-dtl  for src.c-ord-dtl .
define buffer new-c-ord-dtl  for dst.c-ord-dtl .
define buffer old-ord-line-attr  for src.ord-line-attr .
define buffer new-ord-line-attr  for dst.ord-line-attr .
define buffer old-ord-dtl   for src.ord-dtl .
define buffer new-ord-dtl   for dst.ord-dtl .
define buffer old-ord-doc-rcv   for src.ord-doc-rcv  .
define buffer new-ord-doc-rcv   for dst.ord-doc-rcv  .
define buffer old-ord-rcv-attr   for src.ord-rcv-attr  .
define buffer new-ord-rcv-attr   for dst.ord-rcv-attr  .
define buffer old-ord-line-rcv  for src.ord-line-rcv .
define buffer new-ord-line-rcv  for dst.ord-line-rcv .
define buffer old-ord-rcv-line-attr   for src.ord-rcv-line-attr  .
define buffer new-ord-rcv-line-attr   for dst.ord-rcv-line-attr  .
define buffer old-ord-dtl-rcv   for src.ord-dtl-rcv .
define buffer new-ord-dtl-rcv   for dst.ord-dtl-rcv .
define buffer new-ord-cons     for dst.ord-cons.
define buffer new-ord-gds-cons for dst.ord-gds-cons.
define buffer new-ord-dtl-cons for dst.ord-dtl-cons.
define buffer old-ord-cons     for src.ord-cons.
define buffer old-ord-gds-cons for src.ord-gds-cons.
define buffer old-ord-dtl-cons for src.ord-dtl-cons.
define buffer new-ord-cons-attr       for dst.ord-cons-attr      .
define buffer new-ord-cons-line-attr  for dst.ord-cons-line-attr .
define buffer old-ord-cons-attr       for src.ord-cons-attr      .
define buffer old-ord-cons-line-attr  for src.ord-cons-line-attr .
define buffer new-ord-chain           for dst.ord-chain                .
define buffer new-ord-chain-attr      for dst.ord-chain-attr           .
define buffer new-ord-blank-attr      for dst.ord-blank-attr           .
define buffer new-ord-dtl-attr        for dst.ord-dtl-attr             .
define buffer old-ord-chain           for src.ord-chain                .
define buffer old-ord-chain-attr      for src.ord-chain-attr           .
define buffer old-ord-blank-attr      for src.ord-blank-attr           .
define buffer old-ord-dtl-attr        for src.ord-dtl-attr             .
define buffer old-sysconf     for src.sysconf.
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define buffer new-clients   for dst.clients.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
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
define variable v-beg-fact-order as integer no-undo .
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
define buffer buf_clients for src.clients .
on WRITE of dst.ord-blank             override do: end.
on WRITE of dst.ord-doc               override do: end.
on WRITE of dst.ord-line              override do: end.
on WRITE of dst.ord-dtl               override do: end.
on WRITE of dst.ord-doc-rcv           override do: end.
on WRITE of dst.ord-line-rcv          override do: end.
on WRITE of dst.ord-dtl-rcv           override do: end.
on WRITE of dst.c-ord-doc            override do: end.
on WRITE of dst.c-ord-doc-attr            override do: end.
on WRITE of dst.c-ord-line           override do: end.
on WRITE of dst.c-ord-line-attr           override do: end.
on WRITE of dst.c-ord-dtl           override do: end.
on WRITE of dst.ord-cons             override do: end.
on WRITE of dst.ord-gds-cons         override do: end.
on WRITE of dst.ord-dtl-cons         override do: end.
on WRITE of dst.ord-cons-attr        override do: end.
on WRITE of dst.ord-cons-line-attr   override do: end.
on WRITE of dst.ord-doc-attr         override do: end.
on WRITE of dst.ord-line-attr        override do: end.
on WRITE of dst.ord-rcv-attr         override do: end.
on WRITE of dst.ord-rcv-line-attr    override do: end.
on WRITE of dst.ord-chain            override do: end.
on WRITE of dst.ord-chain-attr       override do: end.
on WRITE of dst.ord-blank-attr       override do: end.
on WRITE of dst.ord-dtl-attr         override do: end.
on WRITE of dst.edi-status           override do: end.
define variable my-fact-order as decimal   no-undo .
run day-begin-fact-order (input vardate-actual-docs , output my-fact-order) .
for each old-ord-blank no-lock,
    first new-clients where new-clients.obj-type = old-ord-blank.cli-type and
                            new-clients.obj-code = old-ord-blank.cli-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-ord-blank.
    buffer-copy old-ord-blank to new-ord-blank.
    for each old-ord-blank-attr no-lock where
             old-ord-blank-attr.blank-name   = new-ord-blank.blank-name  and
             old-ord-blank-attr.cli-code     = new-ord-blank.cli-code    and
             old-ord-blank-attr.cli-type     = new-ord-blank.cli-type    :
        create new-ord-blank-attr.
        buffer-copy old-ord-blank-attr to new-ord-blank-attr.
    end.
end.
if vardate-actual-docs <> ? then do:
  for each buf_clients no-lock  where
          buf_clients.db-num <> ?
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                tt-objs.obj-code = buf_clients.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
          run proc-bod .
          run proc-bod-cons .
          run proc-bod-rcv .
    end.
    else do:
          run proc-bod1 ( input 'ОП':U) .
          run proc-bod1 ( input 'ФП':U) .
          run proc-bod1 ( input 'ОФ':U) .
          run proc-bod1 ( input 'ОО':U) .
          run proc-bod1 ( input 'ОР':U) .
          run proc-bod1-cons .
          run proc-bod1-rcv .
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц для заказов .".
end.
procedure proc-bod :
  do
  on error undo, return error return-value
  :
      for each old-ord-doc where
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.fact-order >= my-fact-order   and
          old-ord-doc.status_ = 'факт':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> 'ОП':U and
            old-ord-doc.doc-type <> 'ФП':U and
            old-ord-doc.doc-type <> 'ОФ':U and
            old-ord-doc.doc-type <> 'ОО':U and
            old-ord-doc.doc-type <> 'ОР':U then next.
         run make-2 .
      end.
      for each old-ord-doc where
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.status_ = 'поставка':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> 'ОП':U and
            old-ord-doc.doc-type <> 'ФП':U and
            old-ord-doc.doc-type <> 'ОФ':U and
            old-ord-doc.doc-type <> 'ОО':U and
            old-ord-doc.doc-type <> 'ОР':U then next.
         run make-2 .
      end.
      for each old-ord-doc where
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.status_ = 'согласование':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> 'ОП':U and
            old-ord-doc.doc-type <> 'ФП':U and
            old-ord-doc.doc-type <> 'ОФ':U and
            old-ord-doc.doc-type <> 'ОО':U and
            old-ord-doc.doc-type <> 'ОР':U then next.
         run make-2 .
      end.
      for each old-ord-doc where
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.status_ = 'новый':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> 'ОП':U and
            old-ord-doc.doc-type <> 'ФП':U and
            old-ord-doc.doc-type <> 'ОФ':U and
            old-ord-doc.doc-type <> 'ОО':U and
            old-ord-doc.doc-type <> 'ОР':U then next.
         run make-2 .
      end.
      for each old-ord-doc where
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.status_ = 'разрешено':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> 'ОП':U and
            old-ord-doc.doc-type <> 'ФП':U and
            old-ord-doc.doc-type <> 'ОФ':U and
            old-ord-doc.doc-type <> 'ОО':U and
            old-ord-doc.doc-type <> 'ОР':U then next.
         run make-2 .
      end.
end.
end procedure.
procedure proc-bod-cons :
  do
  on error undo, return error return-value
  :
   if buf_clients.obj-type = 'орг':U then do :
      for each old-ord-cons where
          old-ord-cons.host-code  = buf_clients.obj-code and
          old-ord-cons.status_    = 'факт':U and
          old-ord-cons.fact-date >= vardate-actual-docs
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-cons.
          buffer-copy old-ord-cons to new-ord-cons.
          for each old-ord-gds-cons where
                   old-ord-gds-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-gds-cons.
              buffer-copy old-ord-gds-cons to new-ord-gds-cons.
          end.
          for each old-ord-dtl-cons where
                   old-ord-dtl-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-cons.
              buffer-copy old-ord-dtl-cons to new-ord-dtl-cons.
          end.
          for each old-ord-cons-attr where
                   old-ord-cons-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-attr.
              buffer-copy old-ord-cons-attr to new-ord-cons-attr.
          end.
          for each old-ord-cons-line-attr where
                   old-ord-cons-line-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-line-attr.
              buffer-copy old-ord-cons-line-attr to new-ord-cons-line-attr.
          end.
      end.
  end.
  end.
end procedure.
procedure proc-bod-rcv :
  do
  on error undo, return error return-value
  :
      for each old-ord-doc-rcv where
          old-ord-doc-rcv.obj-code  = buf_clients.obj-code and
          old-ord-doc-rcv.obj-type  = buf_clients.obj-type and
          old-ord-doc-rcv.status_   = 'факт':U  and
          old-ord-doc-rcv.doc-code  = ""     and
          old-ord-doc-rcv.fact-order >= my-fact-order
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              run make-in.
      end.
  end.
end procedure.
procedure make-in :
  do
  on error undo, return error return-value
  :
  if can-find (first new-ord-doc-rcv no-lock where
                    new-ord-doc-rcv.rcv-code = old-ord-doc-rcv.rcv-code and
                    new-ord-doc-rcv.doc-code = old-ord-doc-rcv.doc-code ) then return .
    create new-ord-doc-rcv.
    buffer-copy old-ord-doc-rcv to new-ord-doc-rcv.
    for each  old-ord-chain where
              old-ord-chain.doc-code = new-ord-doc-rcv.rcv-code and
              old-ord-chain.doc-type = 'rcv'  and
              old-ord-chain.rel-doc-type = 'trn'
              no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-chain no-error .
        buffer-copy old-ord-chain to new-ord-chain no-error .
        if not error-status :error then do:
          for each  old-ord-chain-attr where
                    old-ord-chain-attr.db-num = new-ord-chain.db-num and
                    old-ord-chain-attr.rel-id = new-ord-chain.rel-id
                    no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             find first new-ord-chain-attr no-lock where
                        new-ord-chain-attr.db-num = new-ord-chain.db-num and
                        new-ord-chain-attr.rel-id = new-ord-chain.rel-id no-error .
              if not available new-ord-chain-attr then do:
                create new-ord-chain-attr.
                buffer-copy old-ord-chain-attr to new-ord-chain-attr.
              end.
          end.
        end.
    end.
    for each old-ord-line-rcv where
              old-ord-line-rcv.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-line-rcv.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-line-rcv.
        buffer-copy old-ord-line-rcv to new-ord-line-rcv.
    end.
    for each old-ord-dtl-rcv where
             old-ord-dtl-rcv.doc-code = new-ord-doc-rcv.doc-code and
             old-ord-dtl-rcv.rcv-code = new-ord-doc-rcv.rcv-code
             no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-dtl-rcv.
        buffer-copy old-ord-dtl-rcv to new-ord-dtl-rcv.
    end.
    for each old-ord-rcv-attr where
              old-ord-rcv-attr.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-rcv-attr.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-attr.
        buffer-copy old-ord-rcv-attr to new-ord-rcv-attr.
    end.
    for each old-ord-rcv-line-attr where
              old-ord-rcv-line-attr.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-rcv-line-attr.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-line-attr.
        buffer-copy old-ord-rcv-line-attr to new-ord-rcv-line-attr.
    end.
  end.
end procedure.
procedure make-2 :
  do
  on error undo, return error return-value
  :
          create new-ord-doc.
          buffer-copy old-ord-doc to new-ord-doc.
          for each old-ord-line where
                   old-ord-line.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line.
              buffer-copy old-ord-line to new-ord-line.
          end.
          for each old-ord-dtl where
                   old-ord-dtl.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl.
              buffer-copy old-ord-dtl to new-ord-dtl.
          end.
          for each old-ord-dtl-attr where
                   old-ord-dtl-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-attr.
              buffer-copy old-ord-dtl-attr to new-ord-dtl-attr.
          end.
          for each old-ord-line-attr where
                   old-ord-line-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line-attr.
              buffer-copy old-ord-line-attr to new-ord-line-attr.
          end.
          for each old-ord-doc-attr where
                   old-ord-doc-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-doc-attr.
              buffer-copy old-ord-doc-attr to new-ord-doc-attr.
          end.
          for each old-ord-doc-rcv where
                   old-ord-doc-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
            create new-ord-doc-rcv.
            buffer-copy old-ord-doc-rcv to new-ord-doc-rcv.
            if new-ord-doc.whole-send-news > 0 then do:
              for each old-edi-status where
                        old-edi-status.tbl-name = 'ord-doc-rcv':U
                    and old-edi-status.doc-code = new-ord-doc-rcv.rcv-code
                        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                  create new-edi-status.
                  buffer-copy old-edi-status to new-edi-status.
              end.
              for each old-edi-status where
                        old-edi-status.tbl-name = 'ord-line-rcv':U
                    and old-edi-status.doc-code begins (new-ord-doc-rcv.rcv-code + chr(4) )
                        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                  create new-edi-status.
                  buffer-copy old-edi-status to new-edi-status.
              end.
            end.
          end.
          for each old-ord-line-rcv where
                   old-ord-line-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line-rcv.
              buffer-copy old-ord-line-rcv to new-ord-line-rcv.
          end.
          for each old-ord-dtl-rcv where
                   old-ord-dtl-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-rcv.
              buffer-copy old-ord-dtl-rcv to new-ord-dtl-rcv.
          end.
    for each old-ord-rcv-attr where
              old-ord-rcv-attr.doc-code = new-ord-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-attr.
        buffer-copy old-ord-rcv-attr to new-ord-rcv-attr.
    end.
    for each old-ord-rcv-line-attr where
              old-ord-rcv-line-attr.doc-code = new-ord-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-line-attr.
        buffer-copy old-ord-rcv-line-attr to new-ord-rcv-line-attr.
    end.
    if new-ord-doc.whole-send-news > 0 then do:
      for each old-edi-status where
                old-edi-status.tbl-name = 'ord-doc':U
            and old-edi-status.doc-code = new-ord-doc.doc-code
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-edi-status.
          buffer-copy old-edi-status to new-edi-status.
      end.
      for each old-edi-status where
                old-edi-status.tbl-name = 'ord-line':U
            and old-edi-status.doc-code begins (new-ord-doc.doc-code + chr(4) )
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-edi-status.
          buffer-copy old-edi-status to new-edi-status.
      end.
    end.
    for each old-ord-chain of old-ord-doc
    no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-chain.
          buffer-copy old-ord-chain to new-ord-chain.
          for each old-ord-chain-attr of old-ord-chain
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-chain-attr.
          buffer-copy old-ord-chain-attr to new-ord-chain-attr.
          end.
    end.
    if varstay-history = true then do:
          for each old-c-ord-doc where
                   old-c-ord-doc.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-doc.
              buffer-copy old-c-ord-doc to new-c-ord-doc.
          end.
          for each old-c-ord-doc-attr where
                   old-c-ord-doc-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-doc-attr.
              buffer-copy old-c-ord-doc-attr to new-c-ord-doc-attr.
          end.
          for each old-c-ord-line where
                   old-c-ord-line.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-line.
              buffer-copy old-c-ord-line to new-c-ord-line.
          end.
          for each old-c-ord-line-attr where
                   old-c-ord-line-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-line-attr.
              buffer-copy old-c-ord-line-attr to new-c-ord-line-attr.
          end.
          for each old-c-ord-dtl where
                   old-c-ord-dtl.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-dtl.
              buffer-copy old-c-ord-dtl to new-c-ord-dtl.
          end.
    end.
  end.
end procedure.
procedure proc-bod1 :
  do
  on error undo, return error return-value
  :
define input  parameter p-val as character no-undo .
   for each old-sysconf no-lock :
      for each old-ord-doc where
          old-ord-doc.host-code = old-sysconf.host-code and
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.doc-type  = p-val
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         run make-2 .
      end.
   end.
end.
end procedure.
procedure proc-bod1-cons :
  do
  on error undo, return error return-value
  :
   if buf_clients.obj-type = 'орг':U then do :
      for each old-ord-cons where
          old-ord-cons.host-code  = buf_clients.obj-code and
          old-ord-cons.status_    = 'факт':U
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-cons.
          buffer-copy old-ord-cons to new-ord-cons.
          for each old-ord-gds-cons where
                   old-ord-gds-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-gds-cons.
              buffer-copy old-ord-gds-cons to new-ord-gds-cons.
          end.
          for each old-ord-dtl-cons where
                   old-ord-dtl-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-cons.
              buffer-copy old-ord-dtl-cons to new-ord-dtl-cons.
          end.
          for each old-ord-cons-attr where
                   old-ord-cons-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-attr.
              buffer-copy old-ord-cons-attr to new-ord-cons-attr.
          end.
          for each old-ord-cons-line-attr where
                   old-ord-cons-line-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-line-attr.
              buffer-copy old-ord-cons-line-attr to new-ord-cons-line-attr.
          end.
      end.
  end.
  end.
end procedure.
procedure proc-bod1-rcv :
  do
  on error undo, return error return-value
  :
      for each old-ord-doc-rcv where
          old-ord-doc-rcv.obj-code  = buf_clients.obj-code and
          old-ord-doc-rcv.obj-type  = buf_clients.obj-type and
          old-ord-doc-rcv.status_    = 'факт':U and
          old-ord-doc-rcv.doc-code    = ""
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              run make-in.
      end.
  end.
end procedure.
