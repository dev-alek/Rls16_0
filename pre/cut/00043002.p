block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043002.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00043002.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 43.".
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
define buffer old-trn-doc              for src.trn-doc.
define buffer new-trn-doc              for dst.trn-doc.
define buffer old-doc-line             for src.doc-line.
define buffer new-doc-line             for dst.doc-line.
define buffer old-parts                for src.parts.
define buffer new-parts                for dst.parts.
define buffer new-goods                for dst.goods.
define buffer old-clients              for src.clients.
define buffer old-trn-doc-sum          for src.trn-doc-sum.
define buffer new-trn-doc-sum          for dst.trn-doc-sum.
define buffer old-c-trn-doc-sum          for src.c-trn-doc-sum.
define buffer new-c-trn-doc-sum          for dst.c-trn-doc-sum.
define buffer old-doc-line-sum         for src.doc-line-sum.
define buffer new-doc-line-sum         for dst.doc-line-sum.
define buffer old-c-doc-line-sum       for src.c-doc-line-sum.
define buffer new-c-doc-line-sum       for dst.c-doc-line-sum.
define buffer old-parts-root           for src.parts-root.
define buffer new-parts-root           for dst.parts-root.
define buffer old-parts-root-attr           for src.parts-root-attr.
define buffer new-parts-root-attr           for dst.parts-root-attr.
define buffer old-parts-attr           for src.parts-attr     .
define buffer new-parts-attr           for dst.parts-attr     .
define buffer old-parts-supp           for src.parts-supp.
define buffer new-parts-supp           for dst.parts-supp.
define buffer old-parts-supp-attr          for src.parts-supp-attr.
define buffer new-parts-supp-attr          for dst.parts-supp-attr.
define buffer old-arh-trn-doc-contract      for src.arh-trn-doc-contract.
define buffer old-arh-trn-doc-contract-attr      for src.arh-trn-doc-contract-attr.
define buffer old-next-arh-trn-doc-contract for src.arh-trn-doc-contract.
define buffer new-arh-trn-doc-contract      for dst.arh-trn-doc-contract.
define buffer new-arh-trn-doc-contract-attr      for dst.arh-trn-doc-contract-attr.
define buffer old-parts-obj-attr for src.parts-obj-attr.
define buffer new-parts-obj-attr for dst.parts-obj-attr.
define buffer old-c-parts-obj-attr for src.c-parts-obj-attr.
define buffer new-c-parts-obj-attr for dst.c-parts-obj-attr.
define variable var-fact-order-docs as decimal no-undo .
if transaction then do:
  return error substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile ).
end.
do
on error undo, return error
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
  on WRITE of dst.trn-doc-sum               override do: end.
  on WRITE of dst.c-trn-doc-sum               override do: end.
  on WRITE of dst.doc-line-sum              override do: end.
  on WRITE of dst.c-doc-line-sum            override do: end.
  on WRITE of dst.parts-root                override do: end.
  on WRITE of dst.parts-supp                override do: end.
  on WRITE of dst.parts-root-attr           override do: end.
  on WRITE of dst.parts-supp-attr           override do: end.
  on WRITE of dst.parts-attr                override do: end.
  on WRITE of dst.arh-trn-doc-contract      override do: end.
  on WRITE of dst.arh-trn-doc-contract-attr override do: end.
  on WRITE of dst.parts-obj-attr            override do: end.
  on WRITE of dst.c-parts-obj-attr          override do: end.
for each old-parts-supp  no-lock , first new-goods where new-goods.artic = old-parts-supp.artic and new-goods.prod-type = old-parts-supp.prod-type and new-goods.prod-code = old-parts-supp.prod-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-parts-supp.
   buffer-copy old-parts-supp to new-parts-supp.
end.
for each old-parts-supp-attr  no-lock , first new-goods where new-goods.artic = old-parts-supp-attr.artic and new-goods.prod-type = old-parts-supp-attr.prod-type and new-goods.prod-code = old-parts-supp-attr.prod-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-parts-supp-attr.
   buffer-copy old-parts-supp-attr to new-parts-supp-attr.
end.
  define buffer buf_new-goods            for dst.goods        .
       for each new-parts no-lock
                on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :
                find first buf_new-goods no-lock where
                      buf_new-goods.artic     =  new-parts.artic and
                      buf_new-goods.prod-type =  new-parts.prod-type and
                      buf_new-goods.prod-code =  new-parts.prod-code
                      no-error .
                for each old-parts-attr no-lock
                  where old-parts-attr.in-code = new-parts.in-code
                    and old-parts-attr.gds-code = buf_new-goods.gds-code
                    and old-parts-attr.part-code = new-parts.part-code
                on error undo, return error
                :
                  find first  new-parts-attr no-lock
                    where   new-parts-attr.in-code   =  old-parts-attr.in-code
                      and   new-parts-attr.gds-code  =  old-parts-attr.gds-code
                      and   new-parts-attr.part-code =  old-parts-attr.part-code
                    no-error  .
                  if not available new-parts-attr then do:
                    create new-parts-attr.
                    buffer-copy old-parts-attr to new-parts-attr
                    assign
                      new-parts-attr.fact-qnty = new-parts.fact-qnty
                      new-parts-attr.doc-qnty  = new-parts.qnty
                    .
                  end.
                end.
                for each old-parts-obj-attr no-lock
                  where old-parts-obj-attr.obj-type = new-parts.obj-type
                    and old-parts-obj-attr.obj-code = new-parts.obj-code
                    and old-parts-obj-attr.gds-code = buf_new-goods.gds-code
                    and old-parts-obj-attr.prt-code = new-parts.prt-code
                    and old-parts-obj-attr.in-code = new-parts.in-code
                    and old-parts-obj-attr.out-code = new-parts.out-code
                    and old-parts-obj-attr.part-code = new-parts.part-code
                on error undo, return error
                :
                    create new-parts-obj-attr.
                    buffer-copy old-parts-obj-attr to new-parts-obj-attr
                    .
                end.
                for each old-c-parts-obj-attr no-lock
                  where old-c-parts-obj-attr.obj-type = new-parts.obj-type
                    and old-c-parts-obj-attr.obj-code = new-parts.obj-code
                    and old-c-parts-obj-attr.gds-code = buf_new-goods.gds-code
                    and old-c-parts-obj-attr.prt-code = new-parts.prt-code
                    and old-c-parts-obj-attr.in-code = new-parts.in-code
                    and old-c-parts-obj-attr.out-code = new-parts.out-code
                    and old-c-parts-obj-attr.part-code = new-parts.part-code
                on error undo, return error
                :
                    create new-c-parts-obj-attr.
                    buffer-copy old-c-parts-obj-attr to new-c-parts-obj-attr
                    .
                end.
       end.
  for each new-trn-doc no-lock :
    for each old-trn-doc-sum no-lock  where
        old-trn-doc-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-trn-doc-sum.
        BUFFER-COPY old-trn-doc-sum to new-trn-doc-sum.
    end.
    if varstay-history then for each old-c-trn-doc-sum no-lock  where
        old-c-trn-doc-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-c-trn-doc-sum.
        BUFFER-COPY old-c-trn-doc-sum to new-c-trn-doc-sum.
    end.
    for each old-doc-line-sum no-lock  where
        old-doc-line-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-doc-line-sum.
        BUFFER-COPY old-doc-line-sum to new-doc-line-sum.
    end.
    if varstay-history then for each old-c-doc-line-sum no-lock  where
        old-c-doc-line-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-c-doc-line-sum.
        BUFFER-COPY old-c-doc-line-sum to new-c-doc-line-sum.
    end.
    for each old-parts-root no-lock  where
        old-parts-root.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-parts-root.
        BUFFER-COPY old-parts-root to new-parts-root.
    end.
    for each old-parts-root-attr no-lock  where
        old-parts-root-attr.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-parts-root-attr.
        BUFFER-COPY old-parts-root-attr to new-parts-root-attr.
    end.
  end.
  run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).
  for each old-clients no-lock where old-clients.db-num <> ? on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    for each old-arh-trn-doc-contract no-lock  where
        old-arh-trn-doc-contract.obj-type = old-clients.obj-type and
        old-arh-trn-doc-contract.obj-code = old-clients.obj-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        find first new-trn-doc no-lock where new-trn-doc.doc-code = old-arh-trn-doc-contract.doc-code no-error.
        if available new-trn-doc then do:
          create new-arh-trn-doc-contract.
          BUFFER-COPY old-arh-trn-doc-contract to new-arh-trn-doc-contract.
        end.
        else do:
          find first old-next-arh-trn-doc-contract where old-next-arh-trn-doc-contract.host-code     = old-arh-trn-doc-contract.host-code     and
                                                         old-next-arh-trn-doc-contract.contract-code = old-arh-trn-doc-contract.contract-code and
                                                         old-next-arh-trn-doc-contract.cli-type      = old-arh-trn-doc-contract.cli-type      and
                                                         old-next-arh-trn-doc-contract.cli-code      = old-arh-trn-doc-contract.cli-code      and
                                                         old-next-arh-trn-doc-contract.obj-type      = old-arh-trn-doc-contract.obj-type      and
                                                         old-next-arh-trn-doc-contract.obj-code      = old-arh-trn-doc-contract.obj-code      and
                                                         old-next-arh-trn-doc-contract.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                                                         old-next-arh-trn-doc-contract.sum-type      = old-arh-trn-doc-contract.sum-type      and
                                                         old-next-arh-trn-doc-contract.fact-order    > old-arh-trn-doc-contract.fact-order    and
                                                         old-next-arh-trn-doc-contract.fact-order    <= var-fact-order-docs                   no-lock no-error.
          if not available old-next-arh-trn-doc-contract then do:
            create new-arh-trn-doc-contract.
            BUFFER-COPY old-arh-trn-doc-contract to new-arh-trn-doc-contract.
          end.
        end.
        find first old-arh-trn-doc-contract-attr no-lock  where
                    old-arh-trn-doc-contract-attr.host-code     = old-arh-trn-doc-contract.host-code     and
                    old-arh-trn-doc-contract-attr.contract-code = old-arh-trn-doc-contract.contract-code and
                    old-arh-trn-doc-contract-attr.cli-type      = old-arh-trn-doc-contract.cli-type      and
                    old-arh-trn-doc-contract-attr.cli-code      = old-arh-trn-doc-contract.cli-code      and
                    old-arh-trn-doc-contract-attr.obj-type      = old-arh-trn-doc-contract.obj-type      and
                    old-arh-trn-doc-contract-attr.obj-code      = old-arh-trn-doc-contract.obj-code      and
                    old-arh-trn-doc-contract-attr.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                    old-arh-trn-doc-contract-attr.sum-type      = old-arh-trn-doc-contract.sum-type      and
                    old-arh-trn-doc-contract-attr.fact-order    = old-arh-trn-doc-contract.fact-order
                    no-error.
        if available old-arh-trn-doc-contract-attr then do:
            find first new-arh-trn-doc-contract-attr no-lock  where
                        new-arh-trn-doc-contract-attr.host-code     = old-arh-trn-doc-contract.host-code     and
                        new-arh-trn-doc-contract-attr.contract-code = old-arh-trn-doc-contract.contract-code and
                        new-arh-trn-doc-contract-attr.cli-type      = old-arh-trn-doc-contract.cli-type      and
                        new-arh-trn-doc-contract-attr.cli-code      = old-arh-trn-doc-contract.cli-code      and
                        new-arh-trn-doc-contract-attr.obj-type      = old-arh-trn-doc-contract.obj-type      and
                        new-arh-trn-doc-contract-attr.obj-code      = old-arh-trn-doc-contract.obj-code      and
                        new-arh-trn-doc-contract-attr.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                        new-arh-trn-doc-contract-attr.sum-type      = old-arh-trn-doc-contract.sum-type      and
                        new-arh-trn-doc-contract-attr.fact-order    = old-arh-trn-doc-contract.fact-order
                        no-error.
                if not available new-arh-trn-doc-contract-attr then do:
                    create new-arh-trn-doc-contract-attr.
                    BUFFER-COPY old-arh-trn-doc-contract-attr to new-arh-trn-doc-contract-attr.
                end.
        end.
    end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: trn-doc-sum doc-line-sum parts-root parts-supp parts-attr arh-trn-doc-contract part-obj-attr c-parts-obj-attr.".
end.
