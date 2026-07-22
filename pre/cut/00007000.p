block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: b1849e93de2b, 967, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 18 18:36:50 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00007000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00007000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 7.".
define buffer old-goods           for src.goods.
define buffer new-goods           for dst.goods.
define buffer old-goods-attr      for src.goods-attr.
define buffer new-goods-attr      for dst.goods-attr.
define buffer old-c-goods-attr    for src.c-goods-attr.
define buffer new-c-goods-attr    for dst.c-goods-attr.
define buffer old-gds-host-attr   for src.gds-host-attr.
define buffer new-gds-host-attr   for dst.gds-host-attr.
define buffer old-c-gds-host-attr for src.c-gds-host-attr.
define buffer new-c-gds-host-attr for dst.c-gds-host-attr.
define buffer old-gds-obj-attr    for src.gds-obj-attr.
define buffer new-gds-obj-attr    for dst.gds-obj-attr.
define buffer old-c-gds-obj-attr  for src.c-gds-obj-attr.
define buffer new-c-gds-obj-attr  for dst.c-gds-obj-attr.
define buffer old-c-gds-hist      for src.c-gds-hist.
define buffer new-c-gds-hist      for dst.c-gds-hist.
define buffer old-c-goods         for src.c-goods.
define buffer new-c-goods         for dst.c-goods.
define buffer old-bar-code        for src.bar-code.
define buffer new-bar-code        for dst.bar-code.
define buffer old-c-bar-code      for src.c-bar-code.
define buffer new-c-bar-code      for dst.c-bar-code.
define buffer old-bar-code-attr   for src.bar-code-attr.
define buffer new-bar-code-attr   for dst.bar-code-attr.
define buffer old-c-bar-code-attr for src.c-bar-code-attr.
define buffer new-c-bar-code-attr for dst.c-bar-code-attr.
define buffer old-bar-code-obj-attr   for src.bar-code-obj-attr.
define buffer new-bar-code-obj-attr   for dst.bar-code-obj-attr.
define buffer old-c-bar-code-obj-attr for src.c-bar-code-obj-attr.
define buffer new-c-bar-code-obj-attr for dst.c-bar-code-obj-attr.
define buffer old-prod-bc         for src.prod-bc.
define buffer new-prod-bc         for dst.prod-bc.
define buffer old-c-prod-bc       for src.c-prod-bc.
define buffer new-c-prod-bc       for dst.c-prod-bc.
define buffer old-prod-bc-attr    for src.prod-bc-attr.
define buffer new-prod-bc-attr    for dst.prod-bc-attr.
define buffer old-c-prod-bc-attr  for src.c-prod-bc-attr.
define buffer new-c-prod-bc-attr  for dst.c-prod-bc-attr.
define buffer old-prod-bc-db      for src.prod-bc-db.
define buffer new-prod-bc-db      for dst.prod-bc-db.
define buffer old-prod-bc-db-attr for src.prod-bc-db-attr.
define buffer new-prod-bc-db-attr for dst.prod-bc-db-attr.
define buffer old-c-prod-bc-db-attr for src.c-prod-bc-db-attr.
define buffer new-c-prod-bc-db-attr for dst.c-prod-bc-db-attr.
define buffer old-code-range      for src.code-range.
define buffer new-code-range      for dst.code-range.
define buffer old-gds-grp         for src.gds-grp.
define buffer new-gds-grp         for dst.gds-grp.
define buffer old-c-gds-grp       for src.c-gds-grp.
define buffer new-c-gds-grp       for dst.c-gds-grp.
define buffer old-gds-grp-obj     for src.gds-grp-obj.
define buffer new-gds-grp-obj     for dst.gds-grp-obj.
define buffer old-c-gds-grp-obj   for src.c-gds-grp-obj.
define buffer new-c-gds-grp-obj   for dst.c-gds-grp-obj.
define buffer old-gds-grp-obj-attr for src.gds-grp-obj-attr.
define buffer new-gds-grp-obj-attr for dst.gds-grp-obj-attr.
define buffer old-gds-grp-attr    for src.gds-grp-attr.
define buffer new-gds-grp-attr    for dst.gds-grp-attr.
define buffer old-c-gds-grp-attr  for src.c-gds-grp-attr.
define buffer new-c-gds-grp-attr  for dst.c-gds-grp-attr.
define buffer old-c-gds-grp-hist  for src.c-gds-grp-hist.
define buffer new-c-gds-grp-hist  for dst.c-gds-grp-hist.
define buffer old-gds-prt         for src.gds-prt.
define buffer new-gds-prt         for dst.gds-prt.
define buffer old-c-gds-prt       for src.c-gds-prt.
define buffer new-c-gds-prt       for dst.c-gds-prt.
define buffer old-gds-prt-attr    for src.gds-prt-attr.
define buffer new-gds-prt-attr    for dst.gds-prt-attr.
define buffer old-c-gds-prt-attr  for src.c-gds-prt-attr.
define buffer new-c-gds-prt-attr  for dst.c-gds-prt-attr.
define buffer old-lvl-name        for src.lvl-name.
define buffer new-lvl-name        for dst.lvl-name.
define buffer old-lvl-name-attr   for src.lvl-name-attr.
define buffer new-lvl-name-attr   for dst.lvl-name-attr.
define buffer old-parts           for dst.parts.
define buffer old-gds-obj         for src.gds-obj.
define buffer old-prt-obj         for src.prt-obj.
define buffer old-doc-line        for src.doc-line.
define buffer old-rvs-line        for src.rvs-line.
define buffer old-rvs-doc         for src.rvs-doc.
define buffer old-ord-line        for src.ord-line.
define buffer old-c-ord-line      for src.c-ord-line.
define buffer old-ord-doc         for src.ord-doc.
define buffer old-c-ord-doc       for src.c-ord-doc.
define buffer old-ord-line-rcv    for src.ord-line-rcv.
define buffer old-ord-doc-rcv     for src.ord-doc-rcv.
define buffer old-fbr-line        for src.fbr-line.
define buffer old-fbr-doc         for src.fbr-doc.
define buffer old-c-doc-line      for src.c-doc-line.
define buffer old-c-trn-doc       for src.c-trn-doc.
define buffer old-c-price-list    for src.c-price-list.
define buffer old-c-price-doc     for src.c-price-doc.
define buffer old-c-rvs-line      for src.c-rvs-line.
define buffer old-c-rvs-doc       for src.c-rvs-doc.
define buffer old-c-fbr-line      for src.c-fbr-line.
define buffer old-c-fbr-doc       for src.c-fbr-doc.
define buffer old-inkas           for src.inkas.
define buffer old-chk-gds         for src.chk-gds.
define buffer old-place           for src.place.
define buffer old-units           for src.units.
define buffer old-recipe          for src.recipe.
define buffer old-recipe-gds      for src.recipe-gds.
define buffer old-clients         for src.clients.
define buffer old-price-list      for src.price-list.
define buffer old-price-doc       for src.price-doc.
define buffer old-c-cd-doc        for src.c-cd-doc.
define buffer old-cd-doc          for src.cd-doc.
define buffer old-c-cd-doc-line   for src.c-cd-doc-line.
define buffer old-cd-doc-line     for src.cd-doc-line.
define buffer old_db              for src.db.
define buffer old-icnt-doc        for src.icnt-doc.
define buffer old-icnt-line       for src.icnt-line.
define buffer old-contract-specif for src.contract-specif.
define buffer old-dis-gds-rule    for src.dis-gds-rule.
define buffer new-dis-gds-rule    for dst.dis-gds-rule.
define buffer old-c-dis-gds-rule  for src.c-dis-gds-rule.
define buffer new-c-dis-gds-rule  for dst.c-dis-gds-rule.
define buffer old-dis-gds-rule-attr for src.dis-gds-rule-attr.
define buffer new-dis-gds-rule-attr for dst.dis-gds-rule-attr.
define buffer old-dis-grp-rule    for src.dis-grp-rule.
define buffer new-dis-grp-rule    for dst.dis-grp-rule.
define buffer old-c-dis-grp-rule  for src.c-dis-grp-rule.
define buffer new-c-dis-grp-rule  for dst.c-dis-grp-rule.
define buffer old-dis-grp-rule-attr for src.dis-grp-rule-attr.
define buffer new-dis-grp-rule-attr for dst.dis-grp-rule-attr.
define buffer old-ext-classif         for src.ext-classif.
define buffer new-ext-classif         for dst.ext-classif.
define buffer old-ext-classif-attr    for src.ext-classif-attr.
define buffer new-ext-classif-attr    for dst.ext-classif-attr.
define buffer old-c-ext-classif       for src.c-ext-classif.
define buffer new-c-ext-classif       for dst.c-ext-classif.
define buffer old-wth-gds             for src.wth-gds.
define variable varactual-goods  as logical no-undo.
define variable varin-date       as date    no-undo.
define variable varlast-date     as date    no-undo.
define variable i                as integer no-undo.
define variable varwrite-to-file as logical no-undo.
define variable var-date-docs    as date    no-undo .
define variable var-fact-order-docs as decimal no-undo .
define variable l-is-empty-scale as logical no-undo .
define stream LogStream.
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
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
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
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
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
on WRITE of dst.c-gds-hist override do: end.
on WRITE of dst.goods      override do: end.
on WRITE of dst.c-goods    override do: end.
on WRITE of dst.goods-attr override do: end.
on WRITE of dst.c-goods-attr override do: end.
on WRITE of dst.gds-host-attr override do: end.
on WRITE of dst.c-gds-host-attr override do: end.
on WRITE of dst.gds-obj-attr override do: end.
on WRITE of dst.c-gds-obj-attr override do: end.
on WRITE of dst.bar-code   override do: end.
on WRITE of dst.bar-code-attr   override do: end.
on WRITE of dst.c-bar-code override do: end.
on WRITE of dst.c-bar-code-attr override do: end.
on WRITE of dst.bar-code-obj-attr   override do: end.
on WRITE of dst.c-bar-code-obj-attr   override do: end.
on WRITE of dst.prod-bc    override do: end.
on WRITE of dst.c-prod-bc  override do: end.
on WRITE of dst.prod-bc-attr override do: end.
on WRITE of dst.c-prod-bc-attr override do: end.
on WRITE of dst.prod-bc-db    override do: end.
on WRITE of dst.prod-bc-db-attr    override do: end.
on WRITE of dst.c-prod-bc-db-attr  override do: end.
on WRITE of dst.code-range override do: end.
on WRITE of dst.gds-grp    override do: end.
on WRITE of dst.gds-grp-obj    override do: end.
on WRITE of dst.c-gds-grp  override do: end.
on WRITE of dst.c-gds-grp-obj  override do: end.
on WRITE of dst.gds-grp-obj-attr override do: end.
on WRITE of dst.gds-grp-attr    override do: end.
on WRITE of dst.c-gds-grp-attr  override do: end.
on WRITE of dst.c-gds-grp-hist  override do: end.
on WRITE of dst.gds-prt    override do: end.
on WRITE of dst.c-gds-prt    override do: end.
on WRITE of dst.gds-prt-attr    override do: end.
on WRITE of dst.c-gds-prt-attr  override do: end.
on WRITE of dst.lvl-name   override do: end.
on WRITE of dst.lvl-name-attr   override do: end.
on WRITE of dst.dis-gds-rule   override do: end.
on WRITE of dst.dis-gds-rule-attr   override do: end.
on WRITE of dst.c-dis-gds-rule override do: end.
on WRITE of dst.dis-grp-rule   override do: end.
on WRITE of dst.c-dis-grp-rule   override do: end.
on WRITE of dst.dis-grp-rule-attr   override do: end.
on WRITE of dst.ext-classif   override do: end.
on WRITE of dst.ext-classif-attr override do: end.
on WRITE of dst.c-ext-classif override do: end.
define temp-table temp-c-fbr-line no-undo
field artic      like src.c-fbr-line.artic
field prod-type  like src.c-fbr-line.prod-type
field prod-code  like src.c-fbr-line.prod-code
field fact-date  like src.c-fbr-doc.fact-date
index pi is unique primary
fact-date
artic
prod-type
prod-code
.
define temp-table temp-chk-gds no-undo
field gds-code  like src.goods.gds-code
field b-code    like src.chk-gds.b-code
field fact-date like src.inkas.fact-date
index pi is unique primary
fact-date
b-code
index igdscode
fact-date
gds-code
.
if vardate-actual-goods <> ? then do:
  if vartype-cut = 0 then do:
    for each old-c-fbr-doc no-lock:
      if old-c-fbr-doc.fact-date >= vardate-actual-goods then do:
        for each old-c-fbr-line where
                old-c-fbr-line.doc-code = old-c-fbr-doc.doc-code
            AND old-c-fbr-line.chip-num = old-c-fbr-doc.chip-num on error undo, return error return-value :
          find first temp-c-fbr-line where
                    temp-c-fbr-line.fact-date = old-c-fbr-doc.fact-date
                AND temp-c-fbr-line.artic    = old-c-fbr-line.artic
                AND temp-c-fbr-line.prod-type = old-c-fbr-line.prod-type
                AND temp-c-fbr-line.prod-code = old-c-fbr-line.prod-code no-error .
          if not available temp-c-fbr-line then do:
            create temp-c-fbr-line.
            buffer-copy
            old-c-fbr-line to temp-c-fbr-line
            assign
            temp-c-fbr-line.fact-date = old-c-fbr-doc.fact-date
            .
          end.
        end.
      end.
    end.
    for each old_db
    ,each old-clients no-lock
      where old-clients.db-num = old_db.db-num,
      each old-inkas no-lock where
          old-inkas.obj-type = old-clients.obj-type
      AND old-inkas.obj-code = old-clients.obj-code
      AND old-inkas.status_  = 'факт':U
      AND old-inkas.doc-date >= vardate-actual-goods
      on error undo, return error:
      for each old-chk-gds no-lock where
                  old-chk-gds.out-code = old-inkas.inkas-code:
        if old-chk-gds.line-sign = ?
        or old-chk-gds.line-sign = no then do:
          find first temp-chk-gds no-lock where
                      temp-chk-gds.fact-date = old-inkas.fact-date
                  and temp-chk-gds.b-code    = old-chk-gds.b-code no-error .
          if not available temp-chk-gds then do:
            find first old-bar-code no-lock where
                      old-bar-code.b-code = old-chk-gds.b-code no-error .
            if not available old-bar-code then do:
                return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            end.
            create temp-chk-gds.
            assign
            temp-chk-gds.fact-date = old-inkas.fact-date
            temp-chk-gds.b-code    = old-chk-gds.b-code
            temp-chk-gds.gds-code  = old-bar-code.gds-code
            .
          end.
        end.
      end.
    end.
  end.
  for each old-goods no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if vartype-cut = 1 then do:
      assign
      varactual-goods = true.
    end.
    if vartype-cut = 0 then do:
      assign
      varactual-goods  = false
      varwrite-to-file = false
      .
      if varstay-weight-goods then do:
        find old-units where old-units.unit-name = old-goods.unit-base no-lock.
        wt:
        do i = 1 to num-entries(old-units.type):
          if entry(i, old-units.type) = 'вес':U then do:
            assign
              varactual-goods = true
            .
            leave wt.
          end.
        end.
      end.
      if varstay-recipe-goods = true
      then do:
        find first old-recipe no-lock
              where old-recipe.artic     = old-goods.artic
                and old-recipe.prod-type = old-goods.prod-type
                and old-recipe.prod-code = old-goods.prod-code
        no-error.
        if available old-recipe
        then do:
            assign
                varactual-goods = true
            .
        end.
        else do:
            find first old-recipe-gds no-lock
                 where old-recipe-gds.artic     = old-goods.artic
                   and old-recipe-gds.prod-type = old-goods.prod-type
                   and old-recipe-gds.prod-code = old-goods.prod-code
            no-error.
            if available old-recipe-gds
            then do:
                assign
                    varactual-goods = true
                .
            end.
        end.
      end.
      if varactual-goods = false then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  old-goods.gds-code
  ,input  'empty-scale=request'
  ,output l-is-empty-scale
  )  .
        old-gds-obj:
        for each old-gds-obj no-lock
          where old-gds-obj.gds-code     = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-gds-obj.fact-qnty <> 0
          or old-gds-obj.avrg-qnty <> 0
          or old-gds-obj.in-date   >= vardate-actual-goods
          then do:
            if old-goods.stts <> 0
              and varnot-copy-del-goods
            then do:
              assign
                varwrite-to-file = true
              .
            end.
            else do:
              assign
                varactual-goods = true
              .
            end.
            if varactual-goods = false
            and  l-is-empty-scale = false then do:
              _prt-obj:
              for each old-prt-obj no-lock where
                      old-prt-obj.obj-type = old-gds-obj.obj-type
                  and old-prt-obj.obj-code = old-gds-obj.obj-code
                  and old-prt-obj.artic    = old-gds-obj.artic
                  and old-prt-obj.prod-type    = old-gds-obj.prod-type
                  and old-prt-obj.prod-code    = old-gds-obj.prod-code
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
              :
                if not old-prt-obj.is-term then next.
                if old-prt-obj.fact-qnty <> 0
                or old-prt-obj.free-qnty <> 0
                then do:
                  if old-goods.stts <> 0
                    and varnot-copy-del-goods
                  then do:
                    assign
                      varwrite-to-file = true
                    .
                  end.
                  else do:
                    assign
                      varactual-goods = true
                    .
                  end.
                  leave old-gds-obj.
                end.
              end.
            end.
            leave old-gds-obj.
          end.
        end.
      end.
      if varactual-goods = false then do:
          if old-goods.stts <> 0
             and varnot-copy-del-goods = true
          then do:
            assign
              var-date-docs = vardate-actual-docs
            .
          end.
          else do:
            assign
              var-date-docs = vardate-actual-goods
            .
          end.
          run factord-end-day in this-procedure ( var-date-docs - 1, output var-fact-order-docs).
          old-clients :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
              find last old-doc-line where old-doc-line.obj-type   = old-clients.obj-type and
                                           old-doc-line.obj-code   = old-clients.obj-code and
                                           old-doc-line.prod-type  = old-goods.prod-type  and
                                           old-doc-line.prod-code  = old-goods.prod-code  and
                                           old-doc-line.artic      = old-goods.artic      and
                                           old-doc-line.status_    = 'факт':U
                                           use-index fact-order no-lock no-error.
              if available old-doc-line                         and
                old-doc-line.fact-order >= var-fact-order-docs then do:
                assign
                  varactual-goods = true
                .
                leave old-clients.
              end.
          end.
        end.
        if varactual-goods = false then do:
          old-clients-parts-free :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            for each old-parts no-lock where
                    old-parts.obj-type  = old-clients.obj-type
                and old-parts.obj-code  = old-clients.obj-code
                and old-parts.artic     = old-goods.artic
                and old-parts.prod-type = old-goods.prod-type
                and old-parts.prod-code = old-goods.prod-code
                and old-parts.status_   = no
                and old-parts.rsrv-free = yes
                and old-parts.in-code   <> old-parts.out-code
            on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              assign
                varactual-goods = true
              .
              leave old-clients-parts-free.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old_icnt-line:
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            _icnt-line:
            for each old-icnt-line no-lock where
                    old-icnt-line.gds-code = old-goods.gds-code,
              first old-icnt-doc no-lock where
                  old-icnt-doc.obj-type = old-clients.obj-type
              and old-icnt-doc.obj-code = old-clients.obj-code
              and old-icnt-doc.doc-code = old-icnt-line.doc-code
              and old-icnt-doc.doc-date >= var-date-docs
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              assign
              varactual-goods = yes.
              leave old_icnt-line.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-clients-price :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            find old-gds-prt no-lock
            where old-gds-prt.upper-code = old-goods.prt-root
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            find first  old-bar-code no-lock
            where old-bar-code.gds-code  = old-goods.gds-code
              and old-bar-code.node-code = old-gds-prt.node-code
              and old-bar-code.part-code = ""
              and old-bar-code.in-code   = ""
              and old-bar-code.unit-cli  = old-goods.unit-base
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            for each old-price-list where old-price-list.obj-type   =  old-clients.obj-type and
                                          old-price-list.obj-code   =  old-clients.obj-code and
                                          old-price-list.price-type =  ""                   and
                                          old-price-list.fact-order >= var-fact-order-docs  and
                                          old-price-list.b-code     =  old-bar-code.b-code  no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-clients-price.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-rvs-doc :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num on error undo, return error return-value :
            for each old-rvs-line where old-rvs-line.obj-type = old-clients.obj-type and
                                        old-rvs-line.obj-code = old-clients.obj-code and
                                        old-rvs-line.gds-code = old-goods.gds-code   no-lock,
                first old-rvs-doc where old-rvs-doc.rvs-code    = old-rvs-line.rvs-code and
                                        old-rvs-doc.fact-order >= var-fact-order-docs   on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-rvs-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-ord-doc :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            for each old-ord-doc where old-ord-doc.obj-type    = old-clients.obj-type and
                                       old-ord-doc.obj-code    = old-clients.obj-code and
                                       old-ord-doc.status_     = 'факт':U              and
                                       old-ord-doc.fact-order >= var-fact-order-docs  no-lock,
              first old-ord-line where  old-ord-line.prod-type = old-goods.prod-type  and
                                        old-ord-line.prod-code = old-goods.prod-code  and
                                        old-ord-line.artic     = old-goods.artic      and
                                        old-ord-line.doc-code  = old-ord-doc.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-ord-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
            old-ord-doc-rcv :
            for each old_db
          ,each old-clients no-lock
            where old-clients.db-num = old_db.db-num
          on error undo, return error
          :
            for each old-ord-doc-rcv where old-ord-doc-rcv.obj-type    = old-clients.obj-type and
                                           old-ord-doc-rcv.obj-code    = old-clients.obj-code and
                                           old-ord-doc-rcv.status_     = 'факт':U              and
                                           old-ord-doc-rcv.fact-order >= var-fact-order-docs  no-lock,
              first old-ord-line-rcv where  old-ord-line-rcv.artic     = old-goods.artic          and
                                            old-ord-line-rcv.prod-type = old-goods.prod-type      and
                                            old-ord-line-rcv.prod-code = old-goods.prod-code      and
                                            old-ord-line-rcv.doc-code  = old-ord-doc-rcv.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-ord-doc-rcv.
            end.
          end.
        end.
        if varactual-goods = false then do:
            old-fbr-doc :
          for each old_db
           ,each old-clients no-lock where old-clients.db-num = old_db.db-num on error undo, return error return-value :
            for each old-fbr-doc where old-fbr-doc.obj-type   = old-clients.obj-type and
                                       old-fbr-doc.obj-code   = old-clients.obj-code and
                                       old-fbr-doc.status_    = 'факт':U              and
                                       old-fbr-doc.fact-date >= var-date-docs        no-lock,
              first old-fbr-line where  old-fbr-line.prod-type = old-goods.prod-type      and
                                        old-fbr-line.prod-code = old-goods.prod-code      and
                                        old-fbr-line.artic     = old-goods.artic          and
                                        old-fbr-line.doc-code  = old-ord-doc-rcv.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-fbr-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
            old-c-trn-doc :
            for each old_db
          ,each old-clients no-lock
            where old-clients.db-num = old_db.db-num
          on error undo, return error
          :
            for each old-c-trn-doc where old-c-trn-doc.obj-type   = old-clients.obj-type and
                                         old-c-trn-doc.obj-code   = old-clients.obj-code and
                                         old-c-trn-doc.status_    = 'факт':U              and
                                          old-c-trn-doc.doc-date >= var-date-docs        no-lock,
              first old-c-doc-line where old-c-doc-line.doc-code  = old-c-trn-doc.doc-code AND
                                         old-c-doc-line.chip-num  = old-c-trn-doc.chip-num AND
                                         old-c-doc-line.artic     = old-goods.artic        and
                                         old-c-doc-line.prod-type = old-goods.prod-type    and
                                         old-c-doc-line.prod-code = old-goods.prod-code    no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-c-trn-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-c-price-doc :
          for each old_db
        ,each old-clients no-lock
          where old-clients.db-num = old_db.db-num
        on error undo, return error
        :
            find old-gds-prt no-lock
            where old-gds-prt.upper-code = old-goods.prt-root
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            find first  old-bar-code no-lock
            where old-bar-code.gds-code  = old-goods.gds-code
              and old-bar-code.node-code = old-gds-prt.node-code
              and old-bar-code.part-code = "":u
              and old-bar-code.in-code   = "":u
              and old-bar-code.unit-cli  = old-goods.unit-base
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            for each old-c-price-doc where old-c-price-doc.obj-type    = old-clients.obj-type and
                                           old-c-price-doc.obj-code    = old-clients.obj-code and
                                           old-c-price-doc.status_     = 'факт':U              and
                                           old-c-price-doc.fact-order   >= var-fact-order-docs  no-lock,
              first old-c-price-list where old-c-price-list.doc-num    = old-c-price-doc.doc-num  and
                                           old-c-price-list.chip-num   = old-c-price-doc.chip-num and
                                           old-c-price-list.price-type = "":u                     and
                                           old-c-price-list.b-code     = old-bar-code.b-code      no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-c-price-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-c-rvs-doc :
          for each old_db
        ,each old-clients no-lock
          where old-clients.db-num = old_db.db-num
        on error undo, return error
        :
            for each old-c-rvs-doc where old-c-rvs-doc.obj-type    = old-clients.obj-type and
                                         old-c-rvs-doc.obj-code    = old-clients.obj-code and
                                         old-c-rvs-doc.status_     = 'факт':U              and
                                         old-c-rvs-doc.fact-order >= var-fact-order-docs  no-lock,
                first old-c-rvs-line where old-c-rvs-line.rvs-code = old-c-rvs-doc.rvs-code AND
                                          old-c-rvs-line.chip-num = old-c-rvs-doc.chip-num  AND
                                          old-c-rvs-line.gds-code  = old-goods.gds-code no-lock:
                assign
                  varactual-goods = true
                .
                leave old-c-rvs-doc.
            end.
          end.
        end.
        if varactual-goods = false then do:
          old-c-fbr-doc :
          for each temp-c-fbr-line where temp-c-fbr-line.fact-date >= var-date-docs       and
                                         temp-c-fbr-line.artic      = old-goods.artic     and
                                         temp-c-fbr-line.prod-type  = old-goods.prod-type and
                                         temp-c-fbr-line.prod-code  = old-goods.prod-code no-lock
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave old-c-fbr-doc.
          end.
        end.
        if varactual-goods = false then do:
          find first old-contract-specif where old-contract-specif.gds-code = old-goods.gds-code no-error .
          if available old-contract-specif then assign varactual-goods = true .
        end.
        if varactual-goods = false then do:
          old-chk-gds :
          for each temp-chk-gds no-lock where
                   temp-chk-gds.fact-date  > var-date-docs
               and temp-chk-gds.gds-code   = old-goods.gds-code
            on error undo, return error
            :
                assign
                  varactual-goods = true
                .
                leave old-chk-gds.
          end.
        end.
        if varactual-goods = false then do:
          old-wth-gds :
          for each old-wth-gds where old-wth-gds.gds-code = old-goods.gds-code
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave old-wth-gds.
          end.
        end.
        if varactual-goods = false then do:
          gds-grp-attr :
          for each old-gds-grp-attr where
                   old-gds-grp-attr.node-code = old-goods.grp-code      and
                   old-gds-grp-attr.attr-code = 'gds-grp-nabor':U and
                   old-gds-grp-attr.attr-value = "yes"  and
                   old-gds-grp-attr.host-code = 0  and
                   old-gds-grp-attr.obj-code  = 0  and
                   old-gds-grp-attr.obj-type  = ""
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave gds-grp-attr.
          end.
        end.
        old-c-cd-doc :
        for each old_db
      ,each old-clients no-lock
        where old-clients.db-num = old_db.db-num
      on error undo, return error  :
         for each old-c-cd-doc no-lock where
                 old-c-cd-doc.obj-type   = old-clients.obj-type
             and old-c-cd-doc.obj-code   = old-clients.obj-code,
          first old-c-cd-doc-line where
               old-c-cd-doc-line.obj-type  = old-c-cd-doc.obj-type
            and old-c-cd-doc-line.obj-code  = old-c-cd-doc.obj-code
            and old-c-cd-doc-line.pos-type  = old-c-cd-doc.pos-type
            and old-c-cd-doc-line.doc-type  = old-c-cd-doc.doc-type
            and old-c-cd-doc-line.doc-code  = old-c-cd-doc.doc-code
            and old-c-cd-doc-line.corr-user-db-num  = old-c-cd-doc.corr-user-db-num
            and old-c-cd-doc-line.chip-num  = old-c-cd-doc.chip-num
            and old-c-cd-doc-line.gds-code  = old-goods.gds-code
            no-lock on error undo, return error return-value :
          if old-c-cd-doc.datekey_one >= var-date-docs     and
          old-c-cd-doc.is-del = yes  then do:
            assign
              varactual-goods = true
            .
            leave old-c-cd-doc.
          end.
        end.
      end.
        old-cd-doc :
        for each old_db
      ,each old-clients no-lock
        where old-clients.db-num = old_db.db-num
      on error undo, return error  :
         for each old-cd-doc no-lock where
                 old-cd-doc.obj-type   = old-clients.obj-type
             and old-cd-doc.obj-code   = old-clients.obj-code,
          first old-cd-doc-line where
               old-cd-doc-line.obj-type  = old-cd-doc.obj-type
            and old-cd-doc-line.obj-code  = old-cd-doc.obj-code
            and old-cd-doc-line.pos-type  = old-cd-doc.pos-type
            and old-cd-doc-line.doc-type  = old-cd-doc.doc-type
            and old-cd-doc-line.doc-code  = old-cd-doc.doc-code
            and old-cd-doc-line.gds-code  = old-goods.gds-code
          no-lock on error undo, return error return-value :
          if old-cd-doc.datekey_one >= var-date-docs  then do:
            assign
              varactual-goods = true
            .
            leave old-cd-doc.
          end.
        end.
      end.
    end.
    if varactual-goods = true then do:
      do transaction
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
      create new-goods.
      buffer-copy old-goods to new-goods.
      end.
      for each old-goods-attr no-lock where
              old-goods-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-goods-attr.
        buffer-copy old-goods-attr to new-goods-attr.
      end.
      for each old-gds-obj-attr no-lock where
              old-gds-obj-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-gds-obj-attr.
        buffer-copy old-gds-obj-attr to new-gds-obj-attr.
      end.
      for each old-gds-host-attr no-lock where
              old-gds-host-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-gds-host-attr.
        buffer-copy old-gds-host-attr to new-gds-host-attr.
      end.
      if varstay-history then do:
        for each old-c-gds-hist no-lock where
                old-c-gds-hist.gds-code = old-goods.gds-code
            on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-hist.
          buffer-copy old-c-gds-hist to new-c-gds-hist.
        end.
        for each old-c-goods no-lock where
                old-c-goods.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-goods.
          buffer-copy old-c-goods to new-c-goods.
        end.
        for each old-c-goods-attr no-lock where
                old-c-goods-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-goods-attr.
          buffer-copy old-c-goods-attr to new-c-goods-attr.
        end.
        for each old-c-gds-host-attr no-lock where
                old-c-gds-host-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-host-attr.
          buffer-copy old-c-gds-host-attr to new-c-gds-host-attr.
        end.
        for each old-c-gds-obj-attr no-lock where
                old-c-gds-obj-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-obj-attr.
          buffer-copy old-c-gds-obj-attr to new-c-gds-obj-attr.
        end.
        for each old-c-bar-code-obj-attr no-lock where
                old-c-bar-code-obj-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-obj-attr.
          buffer-copy old-c-bar-code-obj-attr to new-c-bar-code-obj-attr.
        end.
        for each old-c-bar-code-attr no-lock where
                old-c-bar-code-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-attr.
          buffer-copy old-c-bar-code-attr to new-c-bar-code-attr.
        end.
      end.
    end.
    else do:
      if varwrite-to-file = true then do:
        output stream LogStream to "del-gds.txt" append.
        put stream LogStream unformatted
        "Артикул:" chr(32) old-goods.artic chr(32)
        "Производитель:" chr(32) old-goods.prod-code chr(32) old-goods.prod-type chr(32)
        "Название:" chr(32) old-goods.gds-name
        skip
        .
        output stream LogStream close.
      end.
    end.
  end.
  for each old-bar-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-goods where new-goods.gds-code  = old-bar-code.gds-code no-lock no-error.
    if available new-goods then do:
      create new-bar-code.
      buffer-copy old-bar-code to new-bar-code.
      if varstay-history then do:
        for each old-c-bar-code no-lock where
                old-c-bar-code.b-code = new-bar-code.b-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code.
          buffer-copy old-c-bar-code to new-c-bar-code.
        end.
      end.
    end.
    else do:
    end.
  end.
  for each old-bar-code-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-goods where new-goods.gds-code  = old-bar-code-attr.gds-code no-lock no-error.
    if available new-goods then do:
      create new-bar-code-attr.
      buffer-copy old-bar-code-attr to new-bar-code-attr.
      if varstay-history then do:
        for each old-c-bar-code-attr no-lock where
                old-c-bar-code-attr.b-code = new-bar-code-attr.b-code
            and old-c-bar-code-attr.attr-code = new-bar-code-attr.attr-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-attr.
          buffer-copy old-c-bar-code-attr to new-c-bar-code-attr.
    end.
      end.
    end.
  end.
  for each old-prod-bc no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc.
      buffer-copy old-prod-bc to new-prod-bc.
      if varstay-history then do:
        for each old-c-prod-bc no-lock
          where old-c-prod-bc.b-str = new-prod-bc.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc.b-code = new-prod-bc.b-code then do:
            create new-c-prod-bc.
            buffer-copy old-c-prod-bc to new-c-prod-bc.
          end.
        end.
      end.
    end.
  end.
  for each old-prod-bc-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-attr.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-attr.
      buffer-copy old-prod-bc-attr to new-prod-bc-attr.
      if varstay-history then do:
        for each old-c-prod-bc-attr no-lock
          where old-c-prod-bc-attr.b-str = new-prod-bc-attr.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc-attr.b-code = new-prod-bc-attr.b-code then do:
            create new-c-prod-bc-attr.
            buffer-copy old-c-prod-bc-attr to new-c-prod-bc-attr.
          end.
        end.
      end.
    end.
  end.
  for each old-prod-bc-db no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-db.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-db.
      buffer-copy old-prod-bc-db to new-prod-bc-db.
    end.
  end.
  define variable v-first-time as logical no-undo .
  define variable v-b-code as integer no-undo .
  define variable v-b-str as character no-undo .
  for each old-prod-bc-db-attr no-lock
  by old-prod-bc-db-attr.b-code
  by old-prod-bc-db-attr.b-str
  by old-prod-bc-db-attr.db-num
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if not (v-b-str = old-prod-bc-db-attr.b-str
           and
           v-b-code = old-prod-bc-db-attr.b-code) then do:
      assign
      v-first-time = yes
      v-b-str = old-prod-bc-db-attr.b-str
      v-b-code = old-prod-bc-db-attr.b-code
      .
    end.
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-db-attr.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-db-attr.
      buffer-copy old-prod-bc-db-attr to new-prod-bc-db-attr.
      if varstay-history
      and v-first-time
      then do:
        for each old-c-prod-bc-db-attr no-lock
          where old-c-prod-bc-db-attr.b-str = new-prod-bc-db-attr.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc-db-attr.b-code = new-prod-bc-db-attr.b-code then do:
            create new-c-prod-bc-db-attr.
            buffer-copy old-c-prod-bc-db-attr to new-c-prod-bc-db-attr.
          end.
        end.
      end.
    end.
  end.
  for each new-goods no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    for each old-dis-gds-rule where
            old-dis-gds-rule.gds-code = new-goods.gds-code:
      create new-dis-gds-rule.
      buffer-copy old-dis-gds-rule to new-dis-gds-rule.
    end.
      if varstay-history then do:
        for each old-c-dis-gds-rule no-lock where
                old-c-dis-gds-rule.gds-code = new-dis-gds-rule.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-dis-gds-rule.
          buffer-copy old-c-dis-gds-rule to new-c-dis-gds-rule.
        end.
      end.
    for each old-dis-gds-rule-attr where
            old-dis-gds-rule-attr.gds-code = new-goods.gds-code:
      create new-dis-gds-rule-attr.
      buffer-copy old-dis-gds-rule-attr to new-dis-gds-rule-attr.
    end.
  end.
  define variable v-tbl-row as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  for each old-ext-classif no-lock
    where old-ext-classif.classif-subject = 'goods':U and not old-ext-classif.classif-name = 'exp-esys-gds-code':U
  break by old-ext-classif.uniq-key-rec
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if first-of(old-ext-classif.uniq-key-rec) then do:
    run gen-row-keyr  in this-procedure (
                                         input  old-ext-classif.uniq-key-rec
                                        ,input  ?
                                        ,input "dst"
                                        ,input  ?
                                        ,input NO-LOCK
                                        ,output v-tbl-row
                                        ,output v-tbl-name ) no-error.
    if error-status:error then next.
    find first new-goods where rowid(new-goods)  = v-tbl-row no-lock no-error.
    if available new-goods then do:
      create new-ext-classif.
      buffer-copy old-ext-classif to new-ext-classif.
      if varstay-history then do:
        for each old-c-ext-classif no-lock where
                old-c-ext-classif.uniq-key-rec = old-ext-classif.uniq-key-rec
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-ext-classif.
          buffer-copy old-c-ext-classif to new-c-ext-classif.
        end.
      end.
      for each old-ext-classif-attr no-lock where
              old-ext-classif-attr.classif-subject = old-ext-classif.classif-subject
          and old-ext-classif-attr.classif-name = old-ext-classif.classif-name
          and old-ext-classif-attr.db-num = old-ext-classif.db-num
          and old-ext-classif-attr.key#_one = old-ext-classif.key#_one
          and old-ext-classif-attr.key#_two = old-ext-classif.key#_two
          and old-ext-classif-attr.key#_thre = old-ext-classif.key#_three
          and old-ext-classif-attr.charkey_one = old-ext-classif.charkey_one
          and old-ext-classif-attr.charkey_two = old-ext-classif.charkey_two
          and old-ext-classif-attr.charkey_thre = old-ext-classif.charkey_three
          and old-ext-classif-attr.nonunique = old-ext-classif.nonunique
       on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ext-classif-attr.
        buffer-copy old-ext-classif-attr to new-ext-classif-attr.
      end.
    end.
  end.
  end.
end.
for each old-code-range  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-code-range.
   buffer-copy old-code-range to new-code-range.
end.
for each old-gds-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-grp.
   buffer-copy old-gds-grp to new-gds-grp.
end.
for each old-gds-grp-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-grp-obj.
   buffer-copy old-gds-grp-obj to new-gds-grp-obj.
end.
for each old-gds-grp-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-grp-obj-attr.
   buffer-copy old-gds-grp-obj-attr to new-gds-grp-obj-attr.
end.
if varstay-history then do:
for each old-c-gds-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-grp.
   buffer-copy old-c-gds-grp to new-c-gds-grp.
end.
for each old-c-gds-grp-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-grp-obj.
   buffer-copy old-c-gds-grp-obj to new-c-gds-grp-obj.
end.
end.
for each old-dis-grp-rule  where old-dis-grp-rule.classif-type = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-dis-grp-rule.
   buffer-copy old-dis-grp-rule to new-dis-grp-rule.
end.
for each old-dis-grp-rule-attr  where old-dis-grp-rule-attr.classif-type = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-dis-grp-rule-attr.
   buffer-copy old-dis-grp-rule-attr to new-dis-grp-rule-attr.
end.
if varstay-history then do:
for each old-c-dis-grp-rule  where old-c-dis-grp-rule.classif-type = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-dis-grp-rule.
   buffer-copy old-c-dis-grp-rule to new-c-dis-grp-rule.
end.
end.
for each old-gds-grp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-grp-attr.
   buffer-copy old-gds-grp-attr to new-gds-grp-attr.
end.
if varstay-history then do:
for each old-c-gds-grp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-grp-attr.
   buffer-copy old-c-gds-grp-attr to new-c-gds-grp-attr.
end.
for each old-c-gds-grp-hist  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-grp-hist.
   buffer-copy old-c-gds-grp-hist to new-c-gds-grp-hist.
end.
end.
for each old-gds-prt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-prt.
   buffer-copy old-gds-prt to new-gds-prt.
end.
for each old-gds-prt-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-prt-attr.
   buffer-copy old-gds-prt-attr to new-gds-prt-attr.
end.
if varstay-history then do:
for each old-c-gds-prt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-prt.
   buffer-copy old-c-gds-prt to new-c-gds-prt.
end.
for each old-c-gds-prt-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-prt-attr.
   buffer-copy old-c-gds-prt-attr to new-c-gds-prt-attr.
end.
end.
for each old-lvl-name  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-lvl-name.
   buffer-copy old-lvl-name to new-lvl-name.
end.
for each old-lvl-name-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-lvl-name-attr.
   buffer-copy old-lvl-name-attr to new-lvl-name-attr.
end.
for each old-ext-classif  where old-ext-classif.classif-subject = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif.
   buffer-copy old-ext-classif to new-ext-classif.
end.
for each old-ext-classif  where old-ext-classif.classif-name = 'exp-esys-gds-code':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif.
   buffer-copy old-ext-classif to new-ext-classif.
end.
for each old-ext-classif-attr  where old-ext-classif-attr.classif-subject = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif-attr.
   buffer-copy old-ext-classif-attr to new-ext-classif-attr.
end.
for each old-ext-classif-attr  where old-ext-classif-attr.classif-name = 'exp-esys-gds-code':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif-attr.
   buffer-copy old-ext-classif-attr to new-ext-classif-attr.
end.
if varstay-history then do:
for each old-c-ext-classif  where old-c-ext-classif.classif-subject = 'gds-grp':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ext-classif.
   buffer-copy old-c-ext-classif to new-c-ext-classif.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: goods goods-attr gds-host-attr gds-obj-attr c-gds-hist c-goods c-goods-attr ~
c-gds-host-attr c-gds-obj-attr bar-code c-bar-code bar-code-attr c-bar-code-attr bar-code-attr c-bar-code-obj-attr prod-bc c-prod-bc prod-bc-attr c-prod-bc-attr prod-bc-db prod-bc-db-attr c-prod-bc-db-attr ~
dis-gds-rule   dis-gds-rule-attr   c-dis-gds-rule ~
code-range gds-grp c-gds-grp gds-grp-obj c-gds-grp-obj gds-grp-obj-attr dis-grp-rule dis-grp-rule-attr c-dis-grp-rule gds-grp-attr c-gds-grp-attr c-gds-grp-hist gds-prt c-gds-prt gds-prt-attr c-gds-prt-attr ~
lvl-name  lvl-name-attr ext-classif ext-classif-attr c-ext-classif ".
end.
