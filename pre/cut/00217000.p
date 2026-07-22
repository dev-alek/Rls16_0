block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00217000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00217000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 217.".
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
define buffer old-arh-wth-cli              for src.arh-wth-cli.
define buffer bf_arh-wth-cli               for src.arh-wth-cli.
define buffer new-arh-wth-cli              for dst.arh-wth-cli.
define buffer old-arh-wth-cli-attr         for src.arh-wth-cli-attr.
define buffer new-arh-wth-cli-attr         for dst.arh-wth-cli-attr.
define buffer old-arh-wth-cli-doc          for src.arh-wth-cli-doc.
define buffer bf_arh-wth-cli-doc           for src.arh-wth-cli-doc.
define buffer new-arh-wth-cli-doc          for dst.arh-wth-cli-doc.
define buffer old-arh-wth-cli-doc-attr     for src.arh-wth-cli-doc-attr.
define buffer new-arh-wth-cli-doc-attr     for dst.arh-wth-cli-doc-attr.
define buffer old-arh-wth-cli-tot          for src.arh-wth-cli-tot.
define buffer bf_arh-wth-cli-tot           for src.arh-wth-cli-tot.
define buffer new-arh-wth-cli-tot          for dst.arh-wth-cli-tot.
define buffer old-arh-wth-cli-tot-attr     for src.arh-wth-cli-tot-attr.
define buffer new-arh-wth-cli-tot-attr     for dst.arh-wth-cli-tot-attr.
define buffer old-arh-wth-tot              for src.arh-wth-tot.
define buffer bf_arh-wth-tot               for src.arh-wth-tot.
define buffer new-arh-wth-tot              for dst.arh-wth-tot.
define buffer old-arh-wth-tot-attr         for src.arh-wth-tot-attr.
define buffer new-arh-wth-tot-attr         for dst.arh-wth-tot-attr.
define buffer old-arh-wth-w-p              for src.arh-wth-w-p.
define buffer bf_arh-wth-w-p               for src.arh-wth-w-p.
define buffer new-arh-wth-w-p              for dst.arh-wth-w-p.
define buffer old-arh-wth-w-p-attr         for src.arh-wth-w-p-attr.
define buffer new-arh-wth-w-p-attr         for dst.arh-wth-w-p-attr.
define variable var-fact-order-docs as decimal no-undo.
on WRITE of dst.arh-wth-cli               override do: end.
on WRITE of dst.arh-wth-cli-attr          override do: end.
on WRITE of dst.arh-wth-cli-doc           override do: end.
on WRITE of dst.arh-wth-cli-doc-attr      override do: end.
on WRITE of dst.arh-wth-cli-tot           override do: end.
on WRITE of dst.arh-wth-cli-tot-attr      override do: end.
on WRITE of dst.arh-wth-tot               override do: end.
on WRITE of dst.arh-wth-tot-attr          override do: end.
on WRITE of dst.arh-wth-w-p               override do: end.
on WRITE of dst.arh-wth-w-p-attr          override do: end.
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
run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).
      for each old-arh-wth-cli no-lock on error undo, return error return-value :     if old-arh-wth-cli.fact-order > var-fact-order-docs then do:                  create new-arh-wth-cli.                                                       buffer-copy old-arh-wth-cli to new-arh-wth-cli.                     end.                                                                                  else do:                                                                                find first bf_arh-wth-cli where bf_arh-wth-cli.cli-type          = old-arh-wth-cli.cli-type                and                        bf_arh-wth-cli.cli-code          = old-arh-wth-cli.cli-code                and                        bf_arh-wth-cli.ext-doc-type      = old-arh-wth-cli.ext-doc-type            and                        bf_arh-wth-cli.wth-code          = old-arh-wth-cli.wth-code                and                        bf_arh-wth-cli.par-code          = old-arh-wth-cli.par-code                and                        bf_arh-wth-cli.ser-code          = old-arh-wth-cli.ser-code                and                        bf_arh-wth-cli.db-num            = old-arh-wth-cli.db-num                  and                        bf_arh-wth-cli.gds-code          = old-arh-wth-cli.gds-code                and                        bf_arh-wth-cli.obj-type          = old-arh-wth-cli.obj-type                and                        bf_arh-wth-cli.obj-code          = old-arh-wth-cli.obj-code                and                        bf_arh-wth-cli.sum-type          = old-arh-wth-cli.sum-type                and                        bf_arh-wth-cli.fact-order        > old-arh-wth-cli.fact-order              and                        bf_arh-wth-cli.fact-order       <= var-fact-order-docs no-error.                     if not available bf_arh-wth-cli then do:                                        create new-arh-wth-cli.                                                       buffer-copy old-arh-wth-cli to new-arh-wth-cli.                     end.                                                                                end.                                                                                end.
for each old-arh-wth-cli-attr   no-lock , first new-arh-wth-cli where   new-arh-wth-cli.cli-type          = old-arh-wth-cli-attr.cli-type                and   new-arh-wth-cli.cli-code          = old-arh-wth-cli-attr.cli-code                and   new-arh-wth-cli.ext-doc-type      = old-arh-wth-cli-attr.ext-doc-type            and   new-arh-wth-cli.wth-code          = old-arh-wth-cli-attr.wth-code                and   new-arh-wth-cli.par-code          = old-arh-wth-cli-attr.par-code                and   new-arh-wth-cli.ser-code          = old-arh-wth-cli-attr.ser-code                and   new-arh-wth-cli.db-num            = old-arh-wth-cli-attr.db-num                  and   new-arh-wth-cli.gds-code          = old-arh-wth-cli-attr.gds-code                and   new-arh-wth-cli.obj-type          = old-arh-wth-cli-attr.obj-type                and   new-arh-wth-cli.obj-code          = old-arh-wth-cli-attr.obj-code                and   new-arh-wth-cli.sum-type          = old-arh-wth-cli-attr.sum-type                and   new-arh-wth-cli.fact-order        = old-arh-wth-cli-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-wth-cli-attr.
   buffer-copy old-arh-wth-cli-attr to new-arh-wth-cli-attr.
end.
      for each old-arh-wth-cli-doc no-lock on error undo, return error return-value :     if old-arh-wth-cli-doc.fact-order > var-fact-order-docs then do:                  create new-arh-wth-cli-doc.                                                       buffer-copy old-arh-wth-cli-doc to new-arh-wth-cli-doc.                     end.                                                                                  else do:                                                                                find first bf_arh-wth-cli-doc where bf_arh-wth-cli-doc.cli-type          = old-arh-wth-cli-doc.cli-type                and                        bf_arh-wth-cli-doc.cli-code          = old-arh-wth-cli-doc.cli-code                and                        bf_arh-wth-cli-doc.wth-code          = old-arh-wth-cli-doc.wth-code                and                        bf_arh-wth-cli-doc.par-code          = old-arh-wth-cli-doc.par-code                and                        bf_arh-wth-cli-doc.host-code         = old-arh-wth-cli-doc.host-code               and                        bf_arh-wth-cli-doc.contract-code     = old-arh-wth-cli-doc.contract-code           and                        bf_arh-wth-cli-doc.gds-code          = old-arh-wth-cli-doc.gds-code                and                        bf_arh-wth-cli-doc.obj-type          = old-arh-wth-cli-doc.obj-type                and                        bf_arh-wth-cli-doc.obj-code          = old-arh-wth-cli-doc.obj-code                and                        bf_arh-wth-cli-doc.w-p-code          = old-arh-wth-cli-doc.w-p-code                and                        bf_arh-wth-cli-doc.ext-doc-type      = old-arh-wth-cli-doc.ext-doc-type            and                        bf_arh-wth-cli-doc.sum-type          = old-arh-wth-cli-doc.sum-type                and                        bf_arh-wth-cli-doc.fact-order        > old-arh-wth-cli-doc.fact-order              and                        bf_arh-wth-cli-doc.fact-order       <= var-fact-order-docs no-error.                     if not available bf_arh-wth-cli-doc then do:                                        create new-arh-wth-cli-doc.                                                       buffer-copy old-arh-wth-cli-doc to new-arh-wth-cli-doc.                     end.                                                                                end.                                                                                end.
for each old-arh-wth-cli-doc-attr   no-lock , first new-arh-wth-cli-doc where   new-arh-wth-cli-doc.cli-type          = old-arh-wth-cli-doc-attr.cli-type                and   new-arh-wth-cli-doc.cli-code          = old-arh-wth-cli-doc-attr.cli-code                and   new-arh-wth-cli-doc.wth-code          = old-arh-wth-cli-doc-attr.wth-code                and   new-arh-wth-cli-doc.par-code          = old-arh-wth-cli-doc-attr.par-code                and   new-arh-wth-cli-doc.host-code         = old-arh-wth-cli-doc-attr.host-code               and   new-arh-wth-cli-doc.contract-code     = old-arh-wth-cli-doc-attr.contract-code           and   new-arh-wth-cli-doc.gds-code          = old-arh-wth-cli-doc-attr.gds-code                and   new-arh-wth-cli-doc.obj-type          = old-arh-wth-cli-doc-attr.obj-type                and   new-arh-wth-cli-doc.obj-code          = old-arh-wth-cli-doc-attr.obj-code                and   new-arh-wth-cli-doc.w-p-code          = old-arh-wth-cli-doc-attr.w-p-code                and   new-arh-wth-cli-doc.ext-doc-type      = old-arh-wth-cli-doc-attr.ext-doc-type            and   new-arh-wth-cli-doc.sum-type          = old-arh-wth-cli-doc-attr.sum-type                and   new-arh-wth-cli-doc.fact-order        = old-arh-wth-cli-doc-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-wth-cli-doc-attr.
   buffer-copy old-arh-wth-cli-doc-attr to new-arh-wth-cli-doc-attr.
end.
      for each old-arh-wth-cli-tot no-lock on error undo, return error return-value :     if old-arh-wth-cli-tot.fact-order > var-fact-order-docs then do:                  create new-arh-wth-cli-tot.                                                       buffer-copy old-arh-wth-cli-tot to new-arh-wth-cli-tot.                     end.                                                                                  else do:                                                                                find first bf_arh-wth-cli-tot where bf_arh-wth-cli-tot.cli-type          = old-arh-wth-cli-tot.cli-type                and                        bf_arh-wth-cli-tot.cli-code          = old-arh-wth-cli-tot.cli-code                and                        bf_arh-wth-cli-tot.obj-type          = old-arh-wth-cli-tot.obj-type                and                        bf_arh-wth-cli-tot.obj-code          = old-arh-wth-cli-tot.obj-code                and                        bf_arh-wth-cli-tot.ext-doc-type      = old-arh-wth-cli-tot.ext-doc-type            and                        bf_arh-wth-cli-tot.sum-type          = old-arh-wth-cli-tot.sum-type                and                        bf_arh-wth-cli-tot.fact-order        > old-arh-wth-cli-tot.fact-order              and                        bf_arh-wth-cli-tot.fact-order       <= var-fact-order-docs no-error.                     if not available bf_arh-wth-cli-tot then do:                                        create new-arh-wth-cli-tot.                                                       buffer-copy old-arh-wth-cli-tot to new-arh-wth-cli-tot.                     end.                                                                                end.                                                                                end.
for each old-arh-wth-cli-tot-attr   no-lock , first new-arh-wth-cli-tot where   new-arh-wth-cli-tot.cli-type          = old-arh-wth-cli-tot-attr.cli-type                and   new-arh-wth-cli-tot.cli-code          = old-arh-wth-cli-tot-attr.cli-code                and   new-arh-wth-cli-tot.obj-type          = old-arh-wth-cli-tot-attr.obj-type                and   new-arh-wth-cli-tot.obj-code          = old-arh-wth-cli-tot-attr.obj-code                and   new-arh-wth-cli-tot.ext-doc-type      = old-arh-wth-cli-tot-attr.ext-doc-type            and   new-arh-wth-cli-tot.sum-type          = old-arh-wth-cli-tot-attr.sum-type                and   new-arh-wth-cli-tot.fact-order        = old-arh-wth-cli-tot-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-wth-cli-tot-attr.
   buffer-copy old-arh-wth-cli-tot-attr to new-arh-wth-cli-tot-attr.
end.
      for each old-arh-wth-tot no-lock on error undo, return error return-value :     if old-arh-wth-tot.fact-order > var-fact-order-docs then do:                  create new-arh-wth-tot.                                                       buffer-copy old-arh-wth-tot to new-arh-wth-tot.                     end.                                                                                  else do:                                                                                find first bf_arh-wth-tot where bf_arh-wth-tot.obj-type          = old-arh-wth-tot.obj-type                and                        bf_arh-wth-tot.obj-code          = old-arh-wth-tot.obj-code                and                        bf_arh-wth-tot.wth-code          = old-arh-wth-tot.wth-code                and                        bf_arh-wth-tot.par-code          = old-arh-wth-tot.par-code                and                        bf_arh-wth-tot.ext-doc-type      = old-arh-wth-tot.ext-doc-type            and                        bf_arh-wth-tot.sum-type          = old-arh-wth-tot.sum-type                and                        bf_arh-wth-tot.fact-order        > old-arh-wth-tot.fact-order              and                        bf_arh-wth-tot.fact-order       <= var-fact-order-docs no-error.                     if not available bf_arh-wth-tot then do:                                        create new-arh-wth-tot.                                                       buffer-copy old-arh-wth-tot to new-arh-wth-tot.                     end.                                                                                end.                                                                                end.
for each old-arh-wth-tot-attr   no-lock , first new-arh-wth-tot where   new-arh-wth-tot.obj-type          = old-arh-wth-tot-attr.obj-type                and   new-arh-wth-tot.obj-code          = old-arh-wth-tot-attr.obj-code                and   new-arh-wth-tot.wth-code          = old-arh-wth-tot-attr.wth-code                and   new-arh-wth-tot.par-code          = old-arh-wth-tot-attr.par-code                and   new-arh-wth-tot.ext-doc-type      = old-arh-wth-tot-attr.ext-doc-type            and   new-arh-wth-tot.sum-type          = old-arh-wth-tot-attr.sum-type                and   new-arh-wth-tot.fact-order        = old-arh-wth-tot-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-wth-tot-attr.
   buffer-copy old-arh-wth-tot-attr to new-arh-wth-tot-attr.
end.
      for each old-arh-wth-w-p no-lock on error undo, return error return-value :     if old-arh-wth-w-p.fact-order > var-fact-order-docs then do:                  create new-arh-wth-w-p.                                                       buffer-copy old-arh-wth-w-p to new-arh-wth-w-p.                     end.                                                                                  else do:                                                                                find first bf_arh-wth-w-p where bf_arh-wth-w-p.obj-type          = old-arh-wth-w-p.obj-type                and                        bf_arh-wth-w-p.obj-code          = old-arh-wth-w-p.obj-code                and                        bf_arh-wth-w-p.w-p-code          = old-arh-wth-w-p.w-p-code                and                        bf_arh-wth-w-p.wth-code          = old-arh-wth-w-p.wth-code                and                        bf_arh-wth-w-p.par-code          = old-arh-wth-w-p.par-code                and                        bf_arh-wth-w-p.out-code          = old-arh-wth-w-p.out-code                and                        bf_arh-wth-w-p.sum-type          = old-arh-wth-w-p.sum-type                and                        bf_arh-wth-w-p.fact-order        > old-arh-wth-w-p.fact-order              and                        bf_arh-wth-w-p.fact-order       <= var-fact-order-docs no-error.                     if not available bf_arh-wth-w-p then do:                                        create new-arh-wth-w-p.                                                       buffer-copy old-arh-wth-w-p to new-arh-wth-w-p.                     end.                                                                                end.                                                                                end.
for each old-arh-wth-w-p-attr   no-lock , first new-arh-wth-w-p where   new-arh-wth-w-p.obj-type          = old-arh-wth-w-p-attr.obj-type                and   new-arh-wth-w-p.obj-code          = old-arh-wth-w-p-attr.obj-code                and   new-arh-wth-w-p.w-p-code          = old-arh-wth-w-p-attr.w-p-code                and   new-arh-wth-w-p.wth-code          = old-arh-wth-w-p-attr.wth-code                and   new-arh-wth-w-p.par-code          = old-arh-wth-w-p-attr.par-code                and   new-arh-wth-w-p.out-code          = old-arh-wth-w-p-attr.out-code                and   new-arh-wth-w-p.sum-type          = old-arh-wth-w-p-attr.sum-type                and   new-arh-wth-w-p.fact-order        = old-arh-wth-w-p-attr.fact-order          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-arh-wth-w-p-attr.
   buffer-copy old-arh-wth-w-p-attr to new-arh-wth-w-p-attr.
end.
output stream str-gen close.
  return "Произведен экспорт таблиц:  arh-wth-cli arh-wth-cli-attr arh-wth-cli-doc arh-wth-cli-doc-attr arh-wth-cli-tot arh-wth-cli-tot-attr ~
arh-wth-tot arh-wth-tot-attr arh-wth-w-p arh-wth-w-p-attr .".
end.
