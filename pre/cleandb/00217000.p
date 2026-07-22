block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 02/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00217000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00217000.p $".
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
define variable var-fact-order-docs as decimal no-undo.
define buffer arh-wth-cli              for ub.arh-wth-cli.
define buffer buf_arh-wth-cli          for ub.arh-wth-cli.
define buffer arh-wth-cli-attr         for ub.arh-wth-cli-attr.
define buffer arh-wth-cli-doc          for ub.arh-wth-cli-doc.
define buffer buf_arh-wth-cli-doc      for ub.arh-wth-cli-doc.
define buffer arh-wth-cli-doc-attr     for ub.arh-wth-cli-doc-attr.
define buffer arh-wth-cli-tot          for ub.arh-wth-cli-tot.
define buffer buf_arh-wth-cli-tot      for ub.arh-wth-cli-tot.
define buffer arh-wth-cli-tot-attr     for ub.arh-wth-cli-tot-attr.
define buffer arh-wth-tot              for ub.arh-wth-tot.
define buffer buf_arh-wth-tot          for ub.arh-wth-tot.
define buffer arh-wth-tot-attr         for ub.arh-wth-tot-attr.
define buffer arh-wth-w-p              for ub.arh-wth-w-p.
define buffer buf_arh-wth-w-p          for ub.arh-wth-w-p.
define buffer arh-wth-w-p-attr         for ub.arh-wth-w-p-attr.
on delete of ub.arh-wth-cli               override do: end.
on delete of ub.arh-wth-cli-attr          override do: end.
on delete of ub.arh-wth-cli-doc           override do: end.
on delete of ub.arh-wth-cli-doc-attr      override do: end.
on delete of ub.arh-wth-cli-tot           override do: end.
on delete of ub.arh-wth-cli-tot-attr      override do: end.
on delete of ub.arh-wth-tot               override do: end.
on delete of ub.arh-wth-tot-attr          override do: end.
on delete of ub.arh-wth-w-p               override do: end.
on delete of ub.arh-wth-w-p-attr          override do: end.
run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).
for each arh-wth-cli no-lock     where arh-wth-cli.fact-order < var-fact-order-docs  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))  :    for each arh-wth-cli-attr exclusive-lock        where arh-wth-cli-attr.cli-type     = arh-wth-cli.cli-type     and   arh-wth-cli-attr.cli-code     = arh-wth-cli.cli-code     and   arh-wth-cli-attr.ext-doc-type = arh-wth-cli.ext-doc-type and   arh-wth-cli-attr.wth-code     = arh-wth-cli.wth-code     and   arh-wth-cli-attr.par-code     = arh-wth-cli.par-code     and   arh-wth-cli-attr.ser-cod      = arh-wth-cli.ser-cod      and   arh-wth-cli-attr.db-num       = arh-wth-cli.db-num       and   arh-wth-cli-attr.gds-code     = arh-wth-cli.gds-code     and   arh-wth-cli-attr.obj-type     = arh-wth-cli.obj-type     and   arh-wth-cli-attr.obj-code     = arh-wth-cli.obj-code     and   arh-wth-cli-attr.sum-type     = arh-wth-cli.sum-type     and   arh-wth-cli-attr.fact-order   = arh-wth-cli.fact-order     :      delete arh-wth-cli-attr.       vDeleted = vDeleted + 1.     end.     find first buf_arh-wth-cli exclusive-lock          where recid(buf_arh-wth-cli) = recid(arh-wth-cli).     delete buf_arh-wth-cli.     vDeleted = vDeleted + 1.   end.
for each arh-wth-cli-doc no-lock     where arh-wth-cli-doc.fact-order < var-fact-order-docs  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))  :    for each arh-wth-cli-doc-attr exclusive-lock        where arh-wth-cli-doc-attr.cli-type      = arh-wth-cli-doc.cli-type      and   arh-wth-cli-doc-attr.cli-code      = arh-wth-cli-doc.cli-code      and   arh-wth-cli-doc-attr.wth-code      = arh-wth-cli-doc.wth-code      and   arh-wth-cli-doc-attr.par-code      = arh-wth-cli-doc.par-code      and   arh-wth-cli-doc-attr.host-code     = arh-wth-cli-doc.host-code     and   arh-wth-cli-doc-attr.contract-code = arh-wth-cli-doc.contract-code and   arh-wth-cli-doc-attr.gds-code      = arh-wth-cli-doc.gds-code      and   arh-wth-cli-doc-attr.obj-type      = arh-wth-cli-doc.obj-type      and   arh-wth-cli-doc-attr.obj-code      = arh-wth-cli-doc.obj-code      and   arh-wth-cli-doc-attr.w-p-code      = arh-wth-cli-doc.w-p-code      and   arh-wth-cli-doc-attr.ext-doc-type  = arh-wth-cli-doc.ext-doc-type  and   arh-wth-cli-doc-attr.sum-type      = arh-wth-cli-doc.sum-type      and   arh-wth-cli-doc-attr.fact-order    = arh-wth-cli-doc.fact-order     :      delete arh-wth-cli-doc-attr.       vDeleted = vDeleted + 1.     end.     find first buf_arh-wth-cli-doc exclusive-lock          where recid(buf_arh-wth-cli-doc) = recid(arh-wth-cli-doc).     delete buf_arh-wth-cli-doc.     vDeleted = vDeleted + 1.   end.
for each arh-wth-cli-tot no-lock     where arh-wth-cli-tot.fact-order < var-fact-order-docs  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))  :    for each arh-wth-cli-tot-attr exclusive-lock        where arh-wth-cli-tot-attr.cli-type     = arh-wth-cli-tot.cli-type     and   arh-wth-cli-tot-attr.cli-code     = arh-wth-cli-tot.cli-code     and   arh-wth-cli-tot-attr.obj-type     = arh-wth-cli-tot.obj-type     and   arh-wth-cli-tot-attr.obj-code     = arh-wth-cli-tot.obj-code     and   arh-wth-cli-tot-attr.ext-doc-type = arh-wth-cli-tot.ext-doc-type and   arh-wth-cli-tot-attr.sum-type     = arh-wth-cli-tot.sum-type     and   arh-wth-cli-tot-attr.fact-order   = arh-wth-cli-tot.fact-order     :      delete arh-wth-cli-tot-attr.       vDeleted = vDeleted + 1.     end.     find first buf_arh-wth-cli-tot exclusive-lock          where recid(buf_arh-wth-cli-tot) = recid(arh-wth-cli-tot).     delete buf_arh-wth-cli-tot.     vDeleted = vDeleted + 1.   end.
for each arh-wth-tot no-lock     where arh-wth-tot.fact-order < var-fact-order-docs  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))  :    for each arh-wth-tot-attr exclusive-lock        where arh-wth-tot-attr.obj-type     = arh-wth-tot.obj-type     and   arh-wth-tot-attr.obj-code     = arh-wth-tot.obj-code     and   arh-wth-tot-attr.wth-code     = arh-wth-tot.wth-code     and   arh-wth-tot-attr.par-code     = arh-wth-tot.par-code     and   arh-wth-tot-attr.ext-doc-type = arh-wth-tot.ext-doc-type and   arh-wth-tot-attr.sum-type     = arh-wth-tot.sum-type     and   arh-wth-tot-attr.fact-order   = arh-wth-tot.fact-order     :      delete arh-wth-tot-attr.       vDeleted = vDeleted + 1.     end.     find first buf_arh-wth-tot exclusive-lock          where recid(buf_arh-wth-tot) = recid(arh-wth-tot).     delete buf_arh-wth-tot.     vDeleted = vDeleted + 1.   end.
for each arh-wth-w-p no-lock     where arh-wth-w-p.fact-order < var-fact-order-docs  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))  :    for each arh-wth-w-p-attr exclusive-lock        where arh-wth-w-p-attr.obj-type   = arh-wth-w-p.obj-type   and   arh-wth-w-p-attr.obj-code   = arh-wth-w-p.obj-code   and   arh-wth-w-p-attr.w-p-code   = arh-wth-w-p.w-p-code   and   arh-wth-w-p-attr.wth-code   = arh-wth-w-p.wth-code   and   arh-wth-w-p-attr.par-code   = arh-wth-w-p.par-code   and   arh-wth-w-p-attr.out-code   = arh-wth-w-p.out-code   and   arh-wth-w-p-attr.sum-type   = arh-wth-w-p.sum-type   and   arh-wth-w-p-attr.fact-order = arh-wth-w-p.fact-order     :      delete arh-wth-w-p-attr.       vDeleted = vDeleted + 1.     end.     find first buf_arh-wth-w-p exclusive-lock          where recid(buf_arh-wth-w-p) = recid(arh-wth-w-p).     delete buf_arh-wth-w-p.     vDeleted = vDeleted + 1.   end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Архив покупатель-номинал МЦ", vDeleted).
return vResult.
