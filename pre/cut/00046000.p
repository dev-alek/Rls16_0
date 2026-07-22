block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00046000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00046000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 46.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-trn-doc   for src.c-trn-doc.
define buffer new-c-trn-doc   for dst.c-trn-doc.
define buffer old-c-doc-line  for src.c-doc-line.
define buffer new-c-doc-line  for dst.c-doc-line.
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define buffer old-c-doc-line-attr  for src.c-doc-line-attr.
define buffer new-c-doc-line-attr  for dst.c-doc-line-attr.
define buffer old-c-gds-dtl  for src.c-gds-dtl.
define buffer new-c-gds-dtl  for dst.c-gds-dtl.
define buffer old-c-gds-dtl-attr  for src.c-gds-dtl-attr.
define buffer new-c-gds-dtl-attr  for dst.c-gds-dtl-attr.
define buffer old-c-doc-pl        for src.c-doc-pl.
define buffer new-c-doc-pl        for dst.c-doc-pl.
define buffer old-c-doc-pl-pump   for src.c-doc-pl-pump.
define buffer new-c-doc-pl-pump   for dst.c-doc-pl-pump.
define buffer new-pump            for dst.pump.
define buffer new-place           for dst.place.
define buffer old-c-inkas          for src.c-inkas          .
define buffer new-c-inkas          for dst.c-inkas          .
define buffer old-c-sale-doc       for src.c-sale-doc       .
define buffer new-c-sale-doc       for dst.c-sale-doc       .
define buffer old-c-inkas-pay      for src.c-inkas-pay      .
define buffer new-c-inkas-pay      for dst.c-inkas-pay      .
define buffer old-c-inkas-pay-desk for src.c-inkas-pay-desk .
define buffer new-c-inkas-pay-desk for dst.c-inkas-pay-desk .
define buffer old-c-inkas-pay-wth  for src.c-inkas-pay-wth  .
define buffer new-c-inkas-pay-wth  for dst.c-inkas-pay-wth  .
define buffer old-c-doc-prts       for src.c-doc-prts       .
define buffer new-c-doc-prts       for dst.c-doc-prts       .
define buffer old-c-parts          for src.c-parts          .
define buffer new-c-parts          for dst.c-parts          .
define buffer old-c-parts-root     for src.c-parts-root          .
define buffer new-c-parts-root     for dst.c-parts-root          .
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
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
on WRITE of dst.c-trn-doc         override do: end.
on WRITE of dst.c-doc-line        override do: end.
on WRITE of dst.c-gds-dtl         override do: end.
on WRITE of dst.c-gds-dtl-attr         override do: end.
on WRITE of dst.c-doc-line-attr   override do: end.
on WRITE of dst.c-doc-pl          override do: end.
on WRITE of dst.c-doc-pl-pump     override do: end.
on write of dst.c-inkas           override do: end.
on write of dst.c-sale-doc        override do: end.
on write of dst.c-inkas-pay       override do: end.
on write of dst.c-inkas-pay-desk  override do: end.
on write of dst.c-inkas-pay-wth   override do: end.
on write of dst.c-doc-prts        override do: end.
on write of dst.c-parts           override do: end.
on write of dst.c-parts-root      override do: end.
if not varstay-history  then return .
define variable my-fact-order as decimal   no-undo .
run day-begin-fact-order (input vardate-actual-docs , output my-fact-order) .
if vardate-actual-docs <> ? then do:
   for each new-shop no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = 'маг':U           and
                                 tt-objs.obj-code = new-shop.obj-code no-error.
      end.
      if vartype-cut = 0      or
         (vartype-cut = 1 and available tt-objs) then do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = 'маг':U           and
                 old-c-trn-doc.obj-code                       = new-shop.obj-code and
                 old-c-trn-doc.status_                        = 'факт':U           and
                 old-c-trn-doc.fact-order                    >= my-fact-order
                 no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
      else do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = 'маг':U           and
                 old-c-trn-doc.obj-code                       = new-shop.obj-code and
                 old-c-trn-doc.status_                        = 'факт':U           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
   end.
   for each new-store no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = 'скл':U           and
                                 tt-objs.obj-code = new-store.obj-code no-error.
      end.
      if vartype-cut = 0      or
         (vartype-cut = 1 and available tt-objs) then do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = 'скл':U   and
                 old-c-trn-doc.obj-code   = new-store.obj-code            and
                 old-c-trn-doc.status_    = 'факт':U                       and
                 old-c-trn-doc.fact-order >= my-fact-order                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
      else do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = 'скл':U  and
                 old-c-trn-doc.obj-code   = new-store.obj-code            and
                 old-c-trn-doc.status_    = 'факт':U                       no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц:  c-trn-doc c-doc-line c-gds-dtl c-doc-line-attr c-doc-pl c-doc-pl-pump c-inkas c-sale-doc " +
"c-inkas-pay c-inkas-pay-desk c-inkas-pay-wth c-doc-prts  c-parts  c-parts-root".
end.
procedure proc-bod :
  do
  on error undo, return error return-value
  :
  for each old-c-doc-line where
           old-c-doc-line.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-doc-line.
          buffer-copy old-c-doc-line to new-c-doc-line.
  end.
  for each old-c-doc-line-attr where
           old-c-doc-line-attr.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-doc-line-attr.
          buffer-copy old-c-doc-line-attr to new-c-doc-line-attr.
  end.
  for each old-c-gds-dtl where
           old-c-gds-dtl.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-gds-dtl.
          buffer-copy old-c-gds-dtl to new-c-gds-dtl.
  end.
  for each old-c-gds-dtl-attr where
           old-c-gds-dtl-attr.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-gds-dtl-attr.
          buffer-copy old-c-gds-dtl-attr to new-c-gds-dtl-attr.
  end.
  for each new-place
       no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
       :
       for each old-c-doc-pl where
           old-c-doc-pl.obj-code = new-place.obj-code and
           old-c-doc-pl.obj-type = new-place.obj-type and
           old-c-doc-pl.pl-code  = new-place.pl-code  and
           old-c-doc-pl.out-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
              create new-c-doc-pl .
              buffer-copy old-c-doc-pl to new-c-doc-pl .
       end.
       for each new-pump where
                new-pump.obj-code = new-place.obj-code and
                new-pump.obj-type = new-place.obj-type
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :
          for each old-c-doc-pl-pump where
              old-c-doc-pl-pump.obj-code   = new-place.obj-code and
              old-c-doc-pl-pump.obj-type   = new-place.obj-type and
              old-c-doc-pl-pump.pl-code    = new-place.pl-code  and
              old-c-doc-pl-pump.pump-code  = new-pump.pump-code  and
              old-c-doc-pl-pump.out-code   = old-c-trn-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
              :
                  create new-c-doc-pl-pump .
                  buffer-copy old-c-doc-pl-pump to new-c-doc-pl-pump .
          end.
       end.
  end.
    for each old-c-doc-prts where
        old-c-doc-prts.out-code = old-c-trn-doc.doc-code
        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          create new-c-doc-prts .
          buffer-copy old-c-doc-prts to new-c-doc-prts .
    end.
    for each old-c-parts where
        old-c-parts.out-code = old-c-trn-doc.doc-code
        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          create new-c-parts .
          buffer-copy old-c-parts to new-c-parts .
    end.
      for each old-c-parts-root no-lock  where
          old-c-parts-root.doc-code = old-c-trn-doc.doc-code
          on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
          :
          create new-c-parts-root.
          BUFFER-COPY old-c-parts-root to new-c-parts-root.
      end.
      if old-c-trn-doc.ext-doc-type = 'es':U then do:
            for each old-c-inkas
              where old-c-inkas.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas.
                buffer-copy old-c-inkas to new-c-inkas.
            end.
            for each old-c-sale-doc
              where old-c-sale-doc.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-sale-doc.
                buffer-copy old-c-sale-doc to new-c-sale-doc.
            end.
            for each old-c-inkas-pay
              where old-c-inkas-pay.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay.
                buffer-copy old-c-inkas-pay to new-c-inkas-pay.
            end.
            for each old-c-inkas-pay-wth
              where old-c-inkas-pay-wth.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay-wth.
                buffer-copy old-c-inkas-pay-wth to new-c-inkas-pay.
            end.
            for each old-c-inkas-pay-desk
              where old-c-inkas-pay-desk.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay-desk.
                buffer-copy old-c-inkas-pay-desk to new-c-inkas-pay-desk.
            end.
      end.
  create new-c-trn-doc.
  buffer-copy old-c-trn-doc to new-c-trn-doc.
  end.
end procedure.
