block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.rvs-doc old buffer buf-old_rvs-doc.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись документа сверки ":U.
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
  define new global shared variable g#lib-rvs as handle no-undo.
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
define variable v-host-code     like ub.rvs-doc.host-code no-undo.
define variable varis-back-date as logical   no-undo initial "no".
define variable v-vid-ok        as logical   no-undo .
define variable v-vid-mes       as character no-undo .
define variable v-vid-action    as integer   no-undo .
define variable v-vid-param     as longchar  no-undo .
define variable v-mess          as character no-undo.
define buffer buf_rvs-doc    for ub.rvs-doc .
define buffer before_rvs-doc for ub.rvs-doc .
define buffer after_rvs-doc  for ub.rvs-doc .
define variable varshift-date as date    no-undo.
define variable varshift-num  as integer no-undo.
define variable varshift-name as char    no-undo.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  ub.rvs-doc.obj-type
  ,input  ub.rvs-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
    find first ub.clients no-lock
        where ub.clients.obj-type = ub.rvs-doc.obj-type
        and ub.clients.obj-code = ub.rvs-doc.obj-code
        no-error .
    if not available ub.clients then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильная ссылка на объект" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Не найден объект" ub.rvs-doc.obj-type ub.rvs-doc.obj-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    run trg/chkdocnm.p
        (input ub.rvs-doc.rvs-code
        ,input 'rvs-doc':U
        ,input recid(ub.rvs-doc)
        ) no-error .
    if error-status :error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке уникальности кода документа" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if  ub.rvs-doc.status_ <> 'новый':U
        and ub.rvs-doc.status_ <> 'разрешен':U
        and ub.rvs-doc.status_ <> 'нередакт':U
        and ub.rvs-doc.status_ <> 'факт':U then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильный статус документа сверки" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Статус" ub.rvs-doc.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if g#news <> yes
        and buf-old_rvs-doc.status_ <> ub.rvs-doc.status_
        then
    do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.rvs-doc.user-db-num
  ,output ub.rvs-doc.user-name
  ,output ub.rvs-doc.sys-date
  ,output ub.rvs-doc.sys-time
  ,output ub.rvs-doc.sys-time-int
  )  .
    end.
    if g#news <> yes
        and ( buf-old_rvs-doc.status_ <> ub.rvs-doc.status_
        or ( new ub.rvs-doc )
        )
        then
    do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer ub.rvs-doc
 ,input integer( (if new ub.rvs-doc then '1':U else '2':U) )
 ,input ub.rvs-doc.rvs-code
 ,input dynamic-next-value('s-corr-chip':U,'ub':U)
) no-error.
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка записи истории создания/изменения документа сверки &1", ub.rvs-doc.rvs-code ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    if buf-old_rvs-doc.status_ = ub.rvs-doc.status_ then
    do:
        return .
    end.
    if not new ub.rvs-doc
        and buf-old_rvs-doc.status_ = 'факт':U
        and ub.rvs-doc.status_     <> 'факт':U then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Документ закрыт до статуса" 'факт':U skip
            "Нельзя изменить статус документа на " ub.rvs-doc.status_ skip
            "Изменение статуса документа невозможно" skip
            view-as alert-box error .
        undo main-block, return error .
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.rvs-doc.obj-type
  ,input  ub.rvs-doc.obj-code
  ,output v-host-code
  ) no-error .
    if error-status :error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошика при определении кода фирмы для объекта" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "obj-type" ub.rvs-doc.obj-type skip
            "obj-code" ub.rvs-doc.obj-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if ub.rvs-doc.host-code <> v-host-code then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильно заполнено поле фирма" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Объект"  ub.rvs-doc.obj-type ub.rvs-doc.obj-code skip
            "Фирма"   ub.rvs-doc.host-code skip
            "Должна быть фирма" v-host-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if g#news = false
    and ub.rvs-doc.rvs-type <> 'проверка':U
    then do:
        run str/chk-rvs.p (input recid(ub.rvs-doc)) no-error.
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при проверке сверки" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error return-value + error-status :get-message(1) .
        end.
    end.
    if ub.rvs-doc.status_ = 'разрешен':U
        or ub.rvs-doc.status_ = 'нередакт':U
        or ( ub.rvs-doc.status_ = 'факт':U
        and g#news = false
        )
    and ub.rvs-doc.rvs-type <> 'проверка':U
        then
    do:
        run trg/lock-rvs.p
            ( input ub.rvs-doc.rvs-code
            , input "check-rvs-on=true"
            , input ""
            , input yes
            ) no-error.
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не заблокированы товары документа сверки" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                "Статус" ub.rvs-doc.status_ skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    if ub.rvs-doc.status_ = 'факт':U then
    do:
        run change-status-fact in this-procedure
            no-error .
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при выполнении программы change-status-fact" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    if g#news = false
        and ub.rvs-doc.creid = ""
        then
    do:
        assign
            ub.rvs-doc.creid = g#userid
            .
    end.
    if not g#news then
    do:
        if ub.rvs-doc.status_ = 'новый':U then
        do:
            if g#db-num <> 0
                and not (new ub.rvs-doc)
                then
            do:
                run nws/cmd-del.p
                    ( input 'rvs-doc':U
                    ,input (buffer ub.rvs-doc:handle)
                    ,input "":U
                    ) no-error .
                if error-status :error then
                do:
                    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
                end.
            end.
        end.
        else
        do:
            run str/callnews.p
                (input 'rvs-doc':U
                ,input (buffer ub.rvs-doc:handle)
                ) no-error .
            if error-status :error then
            do:
                undo, return error substitute( "&1. Невозможно маршрутизировать rvs-doc для отправки в новости. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
        end.
    end.
    if g#oxml = yes then
    do:
        run str/calloxml.p
            ( input 'update':U
            ,input 'rvs-doc':U
            ,input ( buffer ub.rvs-doc:handle )
            ) no-error.
        if error-status :error then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                ,chr(10)
                ,vss-workfile
                ,return-value
                ,error-status :get-message ( 1 )
                ).
        end.
    end.
    if ub.rvs-doc.rvs-type <> 'перед_док':U
        and ub.rvs-doc.rvs-type <> 'проверка':U
        and ( ub.rvs-doc.status_ = 'факт':U
        or ( ub.rvs-doc.status_ = 'новый':U
        and not new( ub.rvs-doc )
        )
        )
        then
    do:
        run trg/lock-rvs.p
            ( input ub.rvs-doc.rvs-code
            ,input "assign-rvs-on=false"
            ,input ""
            ,input false
            ) no-error.
        if error-status :error then
        do:
            undo, return error return-value .
        end.
    end.
    if  ub.rvs-doc.status_ = 'факт':U
    and ub.rvs-doc.rvs-type <> 'проверка':U
    and not g#news
    then do:
        v-mess = return-value.
        define variable v-person as character no-undo.
        for last  c-rvs-doc no-lock where
            c-rvs-doc.rvs-code = rvs-doc.rvs-code and
            c-rvs-doc.corr-user-db-num = g#db-num:
            for first  ub.clients where ub.clients.obj-type = 'чел':U and  ub.clients.obj-code = ub.rvs-doc.boss no-lock :
                v-person = clients.obj-name.
            end.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
            v-vid-action = 58 .
            v-vid-param =
                "Initiator=" + v-initiator + chr(4) +
                "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + chr(4) +
                "SHOP_NUM=" + string(ub.rvs-doc.obj-code) + chr(4) +
                "DocType=" + string(ub.rvs-doc.rvs-type) + chr(4) +
                "DocNum=" + string(ub.rvs-doc.rvs-code) + chr(4) +
                "FactDate=" + (if ub.rvs-doc.status_ = 'факт':U then string(rvs-doc.fact-date) else "") + chr(4) +
                "SHIFT_NUM_DOC=" + (if string( ub.rvs-doc.shift-num) = ? then '' else string( ub.rvs-doc.shift-num)) + (if string( ub.rvs-doc.shift-date) = ? then '' else string( ub.rvs-doc.shift-date , "99999999" )) + chr(4) +
                "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                "StatusOld=" + string(buf-old_rvs-doc.status_) + chr(4) +
                "StatusNew=" + string(ub.rvs-doc.status_) + chr(4) +
                "RESULT=" + string( 0 ) + chr(4) +
                "Description=" + v-mess no-error.
            run trg/userlog.p (
                input 'update':U
                , input 'c-rvs-doc':U
                , input ( buffer ub.c-rvs-doc :handle )
                , input v-vid-action
                , input v-vid-param
                ) no-error.
            if error-status :error
                then
            do:
                return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                    , chr(10)
                    , vss-workfile
                    , return-value
                    , error-status :get-message ( 1 ) ).
            end.
        end.
        for each rvs-line no-lock
            where rvs-line.rvs-code = ub.rvs-doc.rvs-code
            on error undo, return error return-value
            :
            find first rvs-line-attr no-lock
                where rvs-line-attr.obj-code  = rvs-line.obj-code
                and rvs-line-attr.obj-type  = rvs-line.obj-type
                and rvs-line-attr.gds-code  = rvs-line.gds-code
                and rvs-line-attr.pl-code   = rvs-line.pl-code
                and rvs-line-attr.rvs-code  = rvs-line.rvs-code
                and rvs-line-attr.attr-code = "CriticalDif" no-error.
            if available rvs-line-attr then
            do:
                v-vid-action = 56 .
                v-vid-param =
                    "Initiator=" + v-initiator + chr(4) +
                    "SHOP_NUM=" + string(ub.rvs-doc.obj-code) + chr(4) +
                    "DocType=" + string(ub.rvs-doc.rvs-type) + chr(4) +
                    "DocNum=" + string(ub.rvs-doc.rvs-code) + chr(4) +
                    "SHIFT_NUM_DOC=" + (if string( ub.rvs-doc.shift-num) = ? then '' else string( ub.rvs-doc.shift-num)) + (if string( ub.rvs-doc.shift-date) = ? then '' else string( ub.rvs-doc.shift-date , "99999999" )) + chr(4) +
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                    "PlCode=" + string( rvs-line.pl-code) + chr(4) +
                    "RESULT=0" + chr(4) +
                    "Temperature=" + string( rvs-line.state-temperature) + chr(4) +
                    "StateDensity=" + string(  rvs-line.state-density) + chr(4) +
                    "StateMeasureQnty=" + string(   rvs-line.state-measure-qnty  ) + chr(4) +
                    "StateBruttoQnty=" +  string( rvs-line.state-brutto-qnty ) + chr(4) +
                    "StateMeasureCliQnty=" + string( rvs-line.state-measure-cli-qnty)  + chr(4) +
                    "StateBruttoCliQnty=" + string( rvs-line.state-brutto-cli-qnty ) +  chr(4) +
                    "StateLevelTotal=" + string(  rvs-line.state-level-total) +  chr(4) +
                    "StateLevelPetrol=" + string(   rvs-line.state-level-petrol  ) +  chr(4) +
                    "StateLevelWater=" + string(  rvs-line.state-level-water    ) +  chr(4) +
                    "StateMeasureTcQnty=" + string(   rvs-line.state-measure-tc-qnty  ) +   chr(4) +
                    "StateBruttoTcQnty=" + string(    rvs-line.state-brutto-tc-qnty ) +   chr(4) +
                    "CriticalDiff=" + string(rvs-line-attr.attr-value) + chr(4) +
                    "Description=".
                run trg/userlog.p (
                    input 'update':U
                    , input 'rvs-doc':U
                    , input ( buffer ub.rvs-doc :handle )
                    , input v-vid-action
                    , input v-vid-param
                    ) no-error.
                if error-status :error
                    then
                do:
                    return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , chr(10)
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
            end.
        end.
    end.
    if ub.rvs-doc.status_ = 'факт':U
    and ub.rvs-doc.rvs-type <> 'проверка':U
    and g#news
      then
    do:
        run str/rvs-wt-email.p(ub.rvs-doc.rvs-code) no-error.
        if error-status:error then
            message return-value
                view-as alert-box error.
    end.
    define variable v-new-rvs-doc as logical no-undo .
    assign
        v-new-rvs-doc = new(ub.rvs-doc)
        .
    if v-new-rvs-doc = true
    and ub.rvs-doc.rvs-type <> 'проверка':U
    and not g#news
    then do:
        run trg/userlog.p (
            input 'create':U
            , input 'rvs-doc':U
            , input ( buffer ub.rvs-doc :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
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
        if g#news then
        do:
            if ub.rvs-doc.fact-order = ?
                or ub.rvs-doc.fact-order = 0 then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не задан фактический номер сверки" skip
                    "Документ сверки" ub.rvs-doc.rvs-code skip
                    "fact-order" ub.rvs-doc.fact-order skip
                    view-as alert-box error .
                undo, return error .
            end.
        end.
        if not g#news then
        do:
            run gbl/chk-date.p
                (input ub.rvs-doc.obj-type
                ,input ub.rvs-doc.obj-code
                ,input ub.rvs-doc.fact-date
                ,input ub.rvs-doc.fact-time
                ,input ub.rvs-doc.shift-date
                ,input ub.rvs-doc.shift-num
                ,input yes
                ) no-error.
            if error-status :error then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при установке дат, времен, смен в документе сверки." skip
                    "fact-num" ub.rvs-doc.rvs-code skip
                    "fact-date" ub.rvs-doc.fact-date skip
                    "fact-time" ub.rvs-doc.fact-time skip
                    "shift-date" ub.rvs-doc.shift-date skip
                    "shift-num" ub.rvs-doc.shift-num skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo, return error .
            end.
            if ub.rvs-doc.rvs-type = 'перед_док':U
                or ub.rvs-doc.rvs-type = 'после_док':U then
            do:
                find first ub.trn-doc no-lock
                    where ub.trn-doc.doc-code = ub.rvs-doc.out-code
                    no-error .
                if not available ub.trn-doc then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при поиске складского документа для сверки" skip
                        "Документ сверки"    ub.rvs-doc.rvs-code skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        view-as alert-box error .
                    undo, return error .
                end.
                find first buf_rvs-doc
                    where buf_rvs-doc.rvs-type = ub.rvs-doc.rvs-type
                    and buf_rvs-doc.out-code = ub.rvs-doc.rvs-code
                    and recid(buf_rvs-doc)   <> recid(ub.rvs-doc)
                    no-error .
                if available buf_rvs-doc then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Для складского документа указано более одной сверки одного и того же типа" skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        "Документ сверки" ub.rvs-doc.rvs-code skip
                        "Тип документа сверки" ub.rvs-doc.rvs-type skip
                        "Документ сверки 2" buf_rvs-doc.rvs-code skip
                        "Тип документа сверки 2" buf_rvs-doc.rvs-type skip
                        view-as alert-box error .
                    undo, return error .
                end.
                if ub.rvs-doc.rvs-type = 'после_док':U then
                do:
                    find first before_rvs-doc no-lock
                        where before_rvs-doc.out-code = ub.rvs-doc.out-code
                        and before_rvs-doc.rvs-type = 'перед_док':U
                        no-error .
                    if not available before_rvs-doc then
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Для склаского документа задана сверка после налива." skip
                            "Но отсутствует сверка до налива" skip
                            "Сверка после налива" ub.rvs-doc.rvs-code skip
                            "Складской документ"  ub.rvs-doc.out-code skip
                            "Тип сверки" ub.rvs-doc.rvs-type skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                    if ub.rvs-doc.fact-date  <> ub.trn-doc.fact-date
                        or ub.rvs-doc.shift-date <> ub.trn-doc.shift-date
                        or ub.rvs-doc.shift-num  <> ub.trn-doc.shift-num
                        then
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Несоответствие дат для документа сверки и складского документа" skip
                            "Документ сверки" skip
                            chr(9) "Документ сверки"    ub.rvs-doc.rvs-code skip
                            chr(9) "Дата фактического закрытия" ub.rvs-doc.fact-date skip
                            chr(9) "Дата начала смены"  ub.rvs-doc.shift-date skip
                            chr(9) "Номер смены"        ub.rvs-doc.shift-name skip
                            chr(9) "Порядок смены"        ub.rvs-doc.shift-num skip
                            chr(9) "Складской документ" ub.rvs-doc.out-code  skip
                            "Складской документ" skip
                            chr(9) "Складской документ" ub.trn-doc.doc-code skip
                            chr(9) "Дата фактического закрытия" ub.trn-doc.fact-date skip
                            chr(9) "Дата начала смены"  ub.trn-doc.shift-date skip
                            chr(9) "Номер смены"        ub.trn-doc.shift-name skip
                            chr(9) "Порядок смены"        ub.trn-doc.shift-num skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                    if ub.rvs-doc.fact-date  <> before_rvs-doc.fact-date
                        or ub.rvs-doc.shift-date <> before_rvs-doc.shift-date
                        or ub.rvs-doc.shift-num  <> before_rvs-doc.shift-num
                        then
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Несоответствие дат для документа сверки и складского документа" skip
                            "Документ сверки после налива" skip
                            chr(9) "Документ сверки"    ub.rvs-doc.rvs-code skip
                            chr(9) "Дата фактического закрытия" ub.rvs-doc.fact-date skip
                            chr(9) "Дата начала смены"  ub.rvs-doc.shift-date skip
                            chr(9) "Номер смены"        ub.rvs-doc.shift-name skip
                            chr(9) "Порядок смены"        ub.rvs-doc.shift-num skip
                            chr(9) "Складской документ" ub.rvs-doc.out-code  skip
                            "Документ сверки до налива" skip
                            chr(9) "Документ сверки"    before_rvs-doc.rvs-code skip
                            chr(9) "Дата фактического закрытия" before_rvs-doc.fact-date skip
                            chr(9) "Дата начала смены"  before_rvs-doc.shift-date skip
                            chr(9) "Номер смены"        before_rvs-doc.shift-name skip
                            chr(9) "Порядок смены"        before_rvs-doc.shift-num skip
                            chr(9) "Складской документ" before_rvs-doc.out-code  skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                end.
                if ub.rvs-doc.rvs-type = 'перед_док':U then
                do:
                    find first after_rvs-doc no-lock
                        where after_rvs-doc.out-code = ub.rvs-doc.out-code
                        and after_rvs-doc.rvs-type = 'после_док':U
                        no-error .
                    if not available after_rvs-doc then
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Для склаского документа задана сверка после налива." skip
                            "Но отсутствует сверка до налива" skip
                            "Сверка до налива"   ub.rvs-doc.rvs-code skip
                            "Складской документ" ub.rvs-doc.out-code skip
                            "Тип сверки" ub.rvs-doc.rvs-type skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                end.
            end.
            if ub.rvs-doc.rvs-type = 'смена':U then
            do:
                if  ub.rvs-doc.out-code <> ""
                    and ub.rvs-doc.out-code <> ?  then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Для документа сверки по смене указан номер документа" skip
                        "Документ сверки" ub.rvs-doc.rvs-code skip
                        "Тип документа" ub.rvs-doc.rvs-type skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        view-as alert-box error .
                    undo, return error .
                end.
            end.
            if ub.rvs-doc.fact-order > 0 then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибочно задан фактический номер документа сверки" skip
                    "Документ сверки" ub.rvs-doc.rvs-code skip
                    "fact-order" ub.rvs-doc.fact-order skip
                    view-as alert-box error .
                undo, return error .
            end.
            define variable v-fact-num as integer no-undo .
            assign
                v-fact-num = dynamic-next-value('s-trn-fact':U, 'ub':U)
                .
            define variable v-fact-order           as decimal no-undo .
            define variable v-shift-end-fact-order as decimal no-undo .
            define variable v-day-end-fact-order   as decimal no-undo .
            define variable l-shift-on             as logical no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.rvs-doc.obj-type
  ,input  ub.rvs-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
            if error-status :error then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при запуске процедуры objat" skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo, return error .
            end.
            run factord in this-procedure
                (input  ub.rvs-doc.fact-date
                ,input  ub.rvs-doc.fact-time
                ,input  v-fact-num
                ,input  ub.rvs-doc.shift-date
                ,input  ub.rvs-doc.shift-num
                ,input  l-shift-on
                ,output v-fact-order
                ,output v-shift-end-fact-order
                ,output v-day-end-fact-order
                ) no-error .
            if error-status :error
                or v-fact-order = ?
                or v-fact-order = 0 then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при определении фактического номера сверки" skip
                    "doc-num"                 ub.rvs-doc.rvs-code    skip
                    "fact-date"               ub.rvs-doc.fact-date   skip
                    "fact-time"               ub.rvs-doc.fact-time   skip
                    "fact-num"                v-fact-num             skip
                    "shift-date"              ub.rvs-doc.shift-date  skip
                    "shift-num"               ub.rvs-doc.shift-num   skip
                    "v-fact-order"            v-fact-order           skip
                    "v-shift-end-fact-order"  v-shift-end-fact-order skip
                    "v-day-end-fact-order"    v-day-end-fact-order   skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo, return error .
            end.
            if ub.rvs-doc.rvs-type = 'смена':U then
            do:
                assign
                    ub.rvs-doc.fact-order = v-shift-end-fact-order - 0.0000000001
                    .
            end.
            else
            do:
                assign
                    ub.rvs-doc.fact-order = v-fact-order
                    .
            end.
            find first ub.trn-doc where ub.trn-doc.doc-code = ub.rvs-doc.out-code no-error.
            if available ub.trn-doc and
                ub.trn-doc.is-back-date then
            do:
                assign
                    varis-back-date = yes.
            end.
            if ub.rvs-doc.rvs-type <> 'проверка':U
            then do :
              run clcavrgd in this-procedure (input rvs-doc.rvs-code)  no-error.
              if error-status:error then
              do:
                  message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка при расчете веса по средней плотности" skip
                      "Закрываемая сверка" skip
                      chr(9) "Документ сверки"   ub.rvs-doc.rvs-code skip
                      chr(9) "Тип сверки"        ub.rvs-doc.rvs-type skip
                      return-value                 skip
                      error-status:get-message(1)  skip
                      error-status:get-message(2)  skip
                      error-status:get-message(3)
                      view-as alert-box error .
                  undo , return error .
              end.
            end .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_rvs-doc':U
  ,input  buffer buf-old_rvs-doc:handle
  ,input  buffer ub.rvs-doc:handle
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
end procedure.
procedure clcavrgd:
define input parameter parrvs-code like ub.rvs-doc.rvs-code no-undo.
define buffer bf_rvs-doc    for ub.rvs-doc.
define buffer bf_rvs-line   for ub.rvs-line.
define buffer bf_goods      for ub.goods.
define buffer prev_rvs-line for ub.rvs-line.
define buffer prev_rvs-doc  for ub.rvs-doc.
define variable varsystem-cli-avrg-qnty like ub.rvs-line.system-cli-avrg-qnty no-undo.
define variable vardensity like ub.rvs-line.density no-undo.
find first bf_rvs-doc where bf_rvs-doc.rvs-code = parrvs-code no-error.
if not available bf_rvs-doc then return error "Неверный номер документа сверки(clcavrgd)".
for each bf_rvs-line where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code exclusive,
    first bf_goods where bf_goods.gds-code = bf_rvs-line.gds-code break by bf_rvs-line.gds-code on error undo, return error return-value :
    if first-of(bf_rvs-line.gds-code) then do:
       run str/avrgdens.p (input  bf_rvs-doc.obj-type,
                       input  bf_rvs-doc.obj-code,
                       input  bf_rvs-doc.shift-date,
                       input  bf_rvs-doc.shift-num,
                       input  bf_rvs-line.gds-code,
                       input  bf_rvs-doc.rvs-code,
                       input  no,
                       output vardensity) no-error.
       if error-status:error or
          vardensity = ?     then do:
          undo, return error.
       end.
    end.
    if bf_rvs-line.rvs-prev-code <> ? then do:
       find first prev_rvs-line where prev_rvs-line.rvs-code = bf_rvs-line.rvs-prev-code and
                                      prev_rvs-line.obj-type = bf_rvs-line.obj-type      and
                                      prev_rvs-line.obj-code = bf_rvs-line.obj-code      and
                                      prev_rvs-line.pl-code  = bf_rvs-line.pl-code       and
                                      prev_rvs-line.gds-code = bf_rvs-line.gds-code      no-lock no-error.
       if not available prev_rvs-line then do:
          undo, return error SUBSTITUTE
          ("Не найдена строка документа сверки с № &1 на которую имеет ссылку строка по складскому месту &2 товару &3 &4 &5 &6 .",
           bf_rvs-line.rvs-prev-code,
           bf_rvs-line.pl-code,
           bf_goods.artic,
           bf_goods.prod-type,
           bf_goods.prod-code,
           bf_goods.gds-name).
       end.
       find first prev_rvs-doc where prev_rvs-doc.rvs-code = prev_rvs-line.rvs-code No-LOCK No-ERROR.
       if not available prev_rvs-doc then do:
          undo, return error SUBSTITUTE
          ("Не найден документ сверки с № &1 на который имеет ссылку строка по складскому месту &2 товару &3 &4 &5 &6 .",
           bf_rvs-line.rvs-prev-code,
           bf_rvs-line.pl-code,
           bf_goods.artic,
           bf_goods.prod-type,
           bf_goods.prod-code,
           bf_goods.gds-name).
       end.
    end.
    else do:
       if bf_rvs-doc.rvs-type = 'смена':U then
          undo, return error SUBSTITUTE
         ("По складскому месту &1 товару &2 &3 &4 &5 нет ссылки на предыдущую сверку.",
          bf_rvs-line.pl-code,
          bf_goods.artic,
          bf_goods.prod-type,
          bf_goods.prod-code,
          bf_goods.gds-name).
   end.
   run calc_avrg_stock (input  bf_rvs-doc.shift-date,
                        input  bf_rvs-doc.shift-num,
                        input  bf_rvs-doc.obj-type,
                        input  bf_rvs-doc.obj-code,
                        input  bf_rvs-line.pl-code,
                        input  bf_rvs-line.gds-code,
                        input  vardensity,
                        output varsystem-cli-avrg-qnty) no-error.
   if error-status:error then do:
      undo, return error substitute ("Ошибка при расчета остатка по средней плотности &1.",return-value) .
   end.
   ASSIGN bf_rvs-line.system-cli-avrg-qnty =
          (if available prev_rvs-line then prev_rvs-line.system-cli-avrg-qnty else 0) + varsystem-cli-avrg-qnty.
   if bf_rvs-line.system-cli-avrg-qnty = ? then return error SUBSTITUTE
   ("Невозможно рассчитать вес по средней плотности для резервуара &1 товара &2 &3 &4 &5 .",
   bf_rvs-line.pl-code,
   bf_goods.artic,
   bf_rvs-line.obj-type,
   bf_rvs-line.obj-code,
   bf_goods.gds-name).
end.
end procedure.
procedure calc_avrg_stock:
define input  parameter parshift-date            like ub.rvs-doc.shift-date           no-undo.
define input  parameter parshift-num             like ub.rvs-doc.shift-num            no-undo.
define input  parameter parobj-type              like ub.rvs-doc.obj-type             no-undo.
define input  parameter parobj-code              like ub.rvs-doc.obj-code             no-undo.
define input  parameter parpl-code               like ub.rvs-line.pl-code             no-undo.
define input  parameter pargds-code              like ub.rvs-line.gds-code            no-undo.
define input  parameter pardensity               like ub.rvs-line.density             no-undo.
define output parameter parsystem-cli-avrg-qnty  like ub.rvs-doc.system-cli-avrg-qnty no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_doc-pl   for ub.doc-pl.
define buffer bf_goods    for ub.goods.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
for each bf_trn-doc where bf_trn-doc.obj-type   = parobj-type   and
                          bf_trn-doc.obj-code   = parobj-code   and
                          bf_trn-doc.shift-date = parshift-date and
                          bf_trn-doc.shift-num  = parshift-num  and
                          bf_trn-doc.status_    = 'факт':U       no-lock,
    first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                            bf_doc-line.artic     = bf_goods.artic      and
                            bf_doc-line.prod-type = bf_goods.prod-type  and
                            bf_doc-line.prod-code = bf_goods.prod-code  no-lock,
          first bf_doc-pl where bf_doc-pl.out-code = bf_trn-doc.doc-code and
                                bf_doc-pl.gds-code = pargds-code         and
                                bf_doc-pl.obj-type = parobj-type         and
                                bf_doc-pl.obj-code = parobj-code         and
                                bf_doc-pl.pl-code  = parpl-code:
    if lookup (bf_trn-doc.ext-doc-type, 'ie,re,iv,rv,im,io':U) > 0 then do:
       if bf_trn-doc.ext-doc-type = 'ie':U then do:
          assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + bf_doc-line.fact-density * bf_doc-pl.fact-qnty.
       end.
       else
          assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + pardensity * bf_doc-pl.fact-qnty.
    end.
    else do:
       if lookup (bf_trn-doc.ext-doc-type, 'ee,ep,es,rs,we,vt,vp,ap,mp,pc,ev,em,wm,eo':U) > 0 then do:
          if lookup (bf_trn-doc.ext-doc-type, 'vt,vp,rs':U) > 0 then do:
             assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + pardensity * bf_doc-pl.fact-qnty.
          end.
          else do:
             assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty - pardensity * bf_doc-pl.fact-qnty.
          end.
       end.
       else return error SUBSTITUTE
       ("Документ &1. Расширенный тип документа &2. Невозможно определить, реализация или поступление.",
       bf_trn-doc.doc-code,
       bf_trn-doc.ext-doc-type).
    end.
end.
end procedure.
