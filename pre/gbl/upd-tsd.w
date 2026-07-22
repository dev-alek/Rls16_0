define input parameter  parparentproc as widget-handle no-undo .
define input parameter  p-obj-type  like ub.clients.obj-type no-undo .
define input parameter  p-obj-code  like ub.clients.obj-code no-undo .
define input parameter  c-point     as character no-undo .
define input parameter  list-tabls  as character no-undo .
define input parameter  list-buf    as character no-undo .
define input parameter  list-fields as character no-undo .
define input parameter  list-labels as character no-undo .
define input parameter  list-spr    as character no-undo .
define input parameter  list-size    as character no-undo .
define input parameter  list-size-min    as character no-undo .
define input parameter  list-format    as character no-undo .
define input parameter  list-dim    as character no-undo .
define input parameter  kl          as integer   no-undo .
define output parameter ident       as recid     no-undo .
define output parameter P-LENGTH       as INTEGER     no-undo .
define output parameter P-NUM-CLMN       as INTEGER     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и редактирование шаблона печати".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,c-point,list-tabls,list-buf,list-fields,list-labels,list-spr,list-dim,kl)
    .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION yearofst RETURNS integer
  ( input p-year as integer ) :
DEFINE VARIABLE v-year-true as integer no-undo .
DEFINE VARIABLE v-y-o as integer no-undo .
DEFINE VARIABLE v-ost as integer no-undo .
if p-year < 0 or p-year > 99 then return ?.
assign
v-y-o = session:year-offset
v-ost = (v-y-o MODULO 100)
v-year-true = (if p-year < v-ost
               then (v-y-o + (v-y-o MODULO 100) + p-year)
               else (v-y-o - v-ost + p-year))
.
return v-year-true.
END FUNCTION.
def new shared var undo_ as logical initial no.
define variable select3 AS CHARACTER INITIAL "" no-undo.
define variable select3-size as character no-undo .
define variable select3-size-min as character no-undo .
define variable select3-csize as character no-undo .
define variable select3-format as character no-undo .
define variable select3-type as character no-undo .
define variable select3-codes as character no-undo .
define variable select3-label as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
field field-size as character
field field-size-min as character
field field-csize as character
field field-label as character
field field-clabel as character
field field-spr as character
field field-delim as character
field field-table-order as integer
field field-order as integer
index pi is unique primary
table-name
field-name
index iorder
field-order
index itorder
table-name
field-table-order
.
define  temp-table temp-shop no-undo
like ub.shop.
define buffer sel_t-f for t-f.
define variable v-rb as character no-undo.
define variable ii AS INTEGER no-undo.
define variable jj AS INTEGER no-undo.
define variable kk AS INTEGER no-undo.
define variable ll AS INTEGER no-undo.
define variable id AS RECID no-undo.
define variable file-name LIKE _FILE-NAME no-undo.
define variable v-new as logical no-undo .
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.
define variable v-delim as character no-undo.
define variable v-rec-num as integer no-undo.
define variable v-scl-format as character NO-UNDO INIT "99999":U.
define variable v-pg-format as character NO-UNDO INIT "99999":U.
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE BUTTON b-down
     LABEL "Вни&з":L
     SIZE 8.5 BY 1 TOOLTIP "Понизить порядок выбранного поля".
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-up
     LABEL "Ввер&х":L
     SIZE 8.5 BY 1 TOOLTIP "Повысить порядок выбранного поля".
DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 8.5 BY 1 TOOLTIP "Добавить поле в список сортируемых полей".
DEFINE BUTTON btn-codes
     LABEL "&Коды":L
     SIZE 8.5 BY 1 TOOLTIP "Убрать поле из списка сортируемых полей".
DEFINE BUTTON btn-remove
     LABEL "У&брать":L
     SIZE 8.5 BY 1 TOOLTIP "Убрать поле из списка сортируемых полей".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный фильтр"
     BGCOLOR 8 .
DEFINE VARIABLE CB-pg-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 12.5 BY 1 NO-UNDO.
DEFINE VARIABLE CB-scl-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 12.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-delim AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-rec-num AS INTEGER FORMAT ">>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 46 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE RS-tabs AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 97.38 BY .79 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 98.75 BY 1.88
     BGCOLOR 8 FGCOLOR 8 .
DEFINE VARIABLE S-delim AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 6.5 BY 1 NO-UNDO.
DEFINE QUERY BR-fields FOR
      t-f SCROLLING.
DEFINE QUERY BR-sel-fields FOR
      sel_t-f SCROLLING.
DEFINE QUERY DIALOG-1 FOR
      ubflt.filter SCROLLING.
DEFINE BROWSE BR-fields
  QUERY BR-fields DISPLAY
      t-f.field-label format "X(30)" column-label "Название поля"
t-f.field-size format "X(3)":U column-label "Длина!поля!рекоменд"
t-f.field-size-min format "X(3)":U column-label "Длина!поля!миним"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 12.17
         BGCOLOR 15 .
DEFINE BROWSE BR-sel-fields
  QUERY BR-sel-fields DISPLAY
      sel_t-f.field-label format "X(30)" column-label "Название поля"
sel_t-f.field-size format "X(3)":U column-label "Длина!поля!рекоменд"
sel_t-f.field-size-min format "X(3)":U column-label "Длина!поля!миним"
sel_t-f.field-csize format "X(3)":U column-label "Длина!поля!выбранная"
ENABLE
sel_t-f.field-csize
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46.5 BY 12.25
         BGCOLOR 15 .
DEFINE FRAME DIALOG-1
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ubflt.Filter.Naim AT ROW 2.67 COL 24.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 73.13 BY 1 TOOLTIP "Введите имя создаваемого шаблона печати"
          BGCOLOR 15
     RS-tabs AT ROW 4.5 COL 2 NO-LABEL
     f-num-clmn AT ROW 5.5 COL 56.88 COLON-ALIGNED NO-LABEL
     f-delim AT ROW 5.5 COL 76.75 COLON-ALIGNED NO-LABEL
     S-delim AT ROW 5.5 COL 93.38 NO-LABEL
     f-length AT ROW 5.54 COL 34.13 COLON-ALIGNED NO-LABEL
     f-rec-num AT ROW 6.71 COL 36.63 COLON-ALIGNED NO-LABEL
     CB-scl-format AT ROW 6.75 COL 64 COLON-ALIGNED NO-LABEL
     CB-pg-format AT ROW 6.75 COL 85 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     FILL-IN-4 AT ROW 8.04 COL 49.75 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 8.25 COL 2 NO-LABEL
     btn-add AT ROW 8.42 COL 42.38
     BR-sel-fields AT ROW 9.08 COL 51.5
     BR-fields AT ROW 9.25 COL 2
     btn-remove AT ROW 9.42 COL 42.38
     btn-codes AT ROW 10.42 COL 42.38
     b-up AT ROW 13.42 COL 42.5
     b-down AT ROW 14.42 COL 42.5
     "Формат вес. кода" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 7 COL 49.5
     "Количество выводимых записей" VIEW-AS TEXT
          SIZE 34.88 BY .67 AT ROW 6.92 COL 1.13
          BGCOLOR 1 FGCOLOR 15
     "Разделитель" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 5.63 COL 65.75
          BGCOLOR 1 FGCOLOR 15
     "ASCII" VIEW-AS TEXT
          SIZE 6.13 BY .67 AT ROW 5.63 COL 86
          BGCOLOR 1 FGCOLOR 15
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 5.63 COL 46.13
          BGCOLOR 1 FGCOLOR 15
     "Длина шаблона" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 5.71 COL 20.75
          BGCOLOR 1 FGCOLOR 15
     "штучн." VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 7 COL 79.5 WIDGET-ID 4
     RECT-1 AT ROW 2.25 COL 1
     SPACE(0.13) SKIP(17.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Редактирование шаблонов выгрузки в файл для ТСД":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ON CHOOSE OF b-down IN FRAME DIALOG-1
DO:
define variable v-order as integer no-undo.
define variable v-rec as recid no-undo.
define buffer buf_sel-t-f for t-f.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available sel_t-f then do:
    return no-apply.
end.
assign
v-rec = recid(sel_t-f).
find last buf_sel-t-f use-index iorder no-error.
if avail buf_sel-t-f then do:
    v-order = buf_sel-t-f.field-order.
end.
if sel_t-f.field-order = v-order then do:
    return no-apply.
end.
assign
v-order = sel_t-f.field-order.
find first buf_sel-t-f where
            buf_SEL-T-F.field-order > v-order
            and buf_sel-t-f.field-order > 0 use-index iorder no-error.
    if not available buf_sel-t-f then do:
        return no-apply.
    end.
assign
sel_t-f.field-order = buf_sel-t-f.field-order
buf_sel-t-f.field-order = v-order
.
  APPLY "VALUE-CHANGED" to Rs-tabs.
 OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
  run enable-buttons in this-procedure.
  REPOSITION br-sel-fields to recid v-rec no-error.
  apply "ENTRY" to br-sel-fields.
  APPLY "Value-changed" to BR-sel-fields.
END.
ON CHOOSE OF b-up IN FRAME DIALOG-1
DO:
define variable v-order as integer no-undo.
define variable v-rec as recid no-undo.
define buffer buf_sel-t-f for t-f.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available sel_t-f then do:
    return no-apply.
end.
if sel_t-f.field-order = 1 then do:
    return no-apply.
end.
assign
v-order = sel_t-f.field-order
v-rec = recid(sel_t-f).
.
find last buf_sel-t-f where
            buf_SEL-T-F.field-order < v-order
            and buf_sel-t-f.field-order > 0 use-index iorder  no-error.
    if not available buf_sel-t-f then do:
        return no-apply.
    end.
assign
sel_t-f.field-order = buf_sel-t-f.field-order
buf_sel-t-f.field-order = v-order
.
  APPLY "VALUE-CHANGED" to Rs-tabs.
 OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
 run enable-buttons in this-procedure.
REPOSITION br-sel-fields to recid v-rec no-error.
  apply "ENTRY" to br-sel-fields.
   APPLY "Value-changed" to BR-sel-fields.
END.
ON MOUSE-SELECT-DBLCLICK OF BR-fields IN FRAME DIALOG-1
DO:
  APPLY "CHOOSE" to btn-add.
END.
ON VALUE-CHANGED OF BR-sel-fields IN FRAME DIALOG-1
DO:
  if not avail sel_t-f then return no-apply.
  if sel_t-f.field-size = sel_t-f.field-size-min  then do:
    assign
    sel_t-f.field-csize:read-only in browse BR-sel-fields = yes.
  end.
  else do:
      assign
      sel_t-f.field-csize:read-only in browse BR-sel-fields = no.
     end.
END.
ON CHOOSE OF btn-add IN FRAME DIALOG-1
DO:
define variable v-max-order as integer no-undo.
define buffer buf_t-f for t-f.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not avail t-f then return no-apply.
find last buf_t-f no-lock use-index iorder no-error.
if avail buf_t-f then do:
    assign
    v-max-order = buf_t-f.field-order
    .
end.
Find first buf_t-f where
             recid(buf_t-f) = recid(t-f).
assign
buf_t-f.field-order = v-max-order + 1
v-num-clmn = v-num-clmn +  1
v-length = v-length + INTEGER(t-f.field-SIZE)
.
APPLY "VALUE-CHANGED" to Rs-tabs.
OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
RUN PROC-N-L IN THIS-PROCEDURE.
run enable-buttons in this-procedure.
REPOSITION br-sel-fields to recid recid(buf_t-f) no-error.
apply "ENTRY" to br-sel-fields.
APPLY "Value-changed" to BR-sel-fields.
browse br-sel-fields:set-repositioned-row(5, "CONDITIONAL").
END.
ON CHOOSE OF btn-codes IN FRAME DIALOG-1
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run adm/to-cd.w ( 'ИЗМЕНЕНИЕ':U ,
INPUT v-host-code,
INPUT p-obj-type,
INPUT p-obj-code,
INPUT ("Типы кодов для вывода в файл ТСД" + chr(32) + p-obj-type +
string(p-obj-code)),
INPUT-OUTPUT temp-shop.all-prt,
INPUT-OUTPUT temp-shop.cd-bc-alt,
INPUT-OUTPUT temp-shop.cd-bc-base,
INPUT-OUTPUT temp-shop.cd-loc-alt,
INPUT-OUTPUT temp-shop.cd-loc-base,
INPUT-OUTPUT temp-shop.cd-parts-all,
INPUT-OUTPUT temp-shop.cd-parts-not-blank,
INPUT-OUTPUT temp-shop.cd-parts-ser,
INPUT-OUTPUT temp-shop.cd-pb-alt,
INPUT-OUTPUT temp-shop.cd-pb-base,
INPUT-OUTPUT temp-shop.cd-sc-base) .
apply "ENTRY" to br-sel-fields.
   APPLY "Value-changed" to BR-sel-fields.
END.
ON CHOOSE OF btn-remove IN FRAME DIALOG-1
DO:
define variable v-order as integer no-undo.
define buffer buf_t-f for t-f.
define buffer buf1_t-f for t-f.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available sel_t-f then do:
    return no-apply.
end.
 find first buf_t-f where
         recid(buf_t-f) = recid(sel_t-f)
 .
 v-order = buf_t-f.field-order.
assign
buf_t-f.field-order = 0
v-num-clmn = v-num-clmn -  1
v-length = v-length - INTEGER(sel_t-f.field-SIZE)
.
for each buf_t-f where
             buf_t-f.field-order > v-order:
    find first buf1_t-f where
                recid(buf1_t-f) = recid(buf_t-f).
    assign
    buf1_t-f.field-order =   buf1_t-f.field-order - 1
    .
END.
APPLY "VALUE-CHANGED" to Rs-tabs.
OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
RUN PROC-N-L IN THIS-PROCEDURE.
run enable-buttons in this-procedure.
REPOSITION br-sel-fields to row v-order - 1 no-error.
apply "ENTRY" to br-sel-fields.
 APPLY "Value-changed" to BR-sel-fields.
END.
ON CHOOSE OF Btn_Cancel IN FRAME DIALOG-1
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
END.
ON CHOOSE OF Btn_OK IN FRAME DIALOG-1
DO:
define variable v-file-name as character no-undo.
define buffer buf_sel-t-f for t-f.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if (can-find(ubflt.filter where ubflt.filter.call-point = c-point
       and ubflt.filter.naim = input frame DIALOG-1 ubflt.filter.naim) and v-new) or
       input frame DIALOG-1 ubflt.filter.naim = "" then do:
    if input frame DIALOG-1 ubflt.filter.naim = ""
    then
    message "Пустое имя фильтра недопустимо".
    else message "Фильтр с таким именем уже сущестует".
    apply "entry" to ubflt.filter.naim.
    return no-apply.
end.
id = recid(ubflt.filter).
IDENT = RECID(ubflt.filter).
assign
select3 = "":U
select3-size = "":U
select3-size-min = "":U
select3-csize = "":U
select3-format = "":U
select3-type = "":U
select3-codes = "":U
select3-label = "":U
s-delim
f-rec-num
cb-scl-format
cb-pg-format
.
APPLY "Value-changed" to s-delim.
run check-delim in this-procedure (chr(int(s-delim))) no-error.
if error-status:error then return no-apply.
for each buf_sel-t-f no-lock where
         buf_sel-t-f.field-order > 0
by buf_sel-t-f.field-order
         :
  assign
  v-file-name = "":U.
  do ii = 1 to num-entries(buf_sel-t-f.field-name, '*':U):
      assign
      v-file-name = v-file-name + '*':U + buf_sel-t-f.table-name + ".":U + entry(ii, buf_sel-t-f.field-name, '*':U)
      .
  end.
  assign
  v-file-name = left-trim(v-file-name , '*':U)
  .
  assign
  select3 = select3 + chr(44) + v-file-name
  select3-size = select3-size + chr(44) + buf_sel-t-f.field-size
  select3-size-min = select3-size-min + chr(44) + buf_sel-t-f.field-size-min
  select3-csize = select3-csize + chr(44) + buf_sel-t-f.field-csize
  select3-format = select3-format + chr(4) + buf_sel-t-f.field-format
  select3-type = select3-type + chr(44) + buf_sel-t-f.field-type
  select3-label = select3-label + chr(44) + buf_sel-t-f.field-clabel
  .
end.
if lookup("function.b-code-tsd":U, select3) = 0 then do:
    message
    "Нельзя создать шаблон вывода без поля БАР-КОД"
    view-as alert-box error.
    return no-apply.
end.
assign
select3-codes =
                (if temp-shop.all-prt then "all-prt":U else "":U) + chr(44) +
                (if temp-shop.cd-bc-alt then "cd-bc-alt":U else "":U) + chr(44) +
                (if temp-shop.cd-bc-base then "cd-bc-base":U else "":U) + chr(44) +
                (if temp-shop.cd-loc-alt then "cd-loc-alt":U else "":U) + chr(44) +
                (if temp-shop.cd-loc-base then "cd-loc-base":U else "":U) + chr(44) +
                (if temp-shop.cd-parts-all then "cd-parts-all":U else "":U) + chr(44) +
                (if temp-shop.cd-parts-not-blank then "cd-parts-not-blank":U else "":U) + chr(44) +
                (if temp-shop.cd-parts-ser then "cd-parts-ser":U else "":U) + chr(44) +
                (if temp-shop.cd-pb-alt then "cd-pb-alt":U else "":U) + chr(44) +
                (if temp-shop.cd-pb-base then "cd-pb-base":U else "":U) + chr(44) +
                (if temp-shop.cd-sc-base then "cd-sc-base":U else "":U)
.
if trim(select3-codes, chr(44)) = "all-prt":u or trim(select3-codes, chr(44)) = "":U then do:
    message
    "Необходимо указать хотя бы один тип кода для вывода"
    view-as alert-box error.
    return no-apply.
end.
assign
Filter.naim = input frame DIALOG-1 ubflt.filter.naim
Filter.call-point = c-point
Filter.Tbl = List-Tabls
Filter.Flds = List-Fields
Filter.Fields-sort = left-trim(SELECT3, chr(44))
Filter.Fields-sort-rus = left-trim(SELECT3-label, chr(44)) + chr(4) +
                         left-trim(SELECT3-codes, chr(44)) + chr(4) +
                         s-delim + chr(4) +
                         string(f-rec-num)  + chr(4) + cb-scl-format + chr(4) + cb-pg-format
Filter.Where-ysl = left-trim(select3-size, chr(44)) + chr(4) +
                                    left-trim(select3-size-min, chr(44)) + chr(4) +
                                    left-trim(select3-csize, chr(44))
Filter.Where-ysl-rus = left-trim(select3-format, chr(4))
Filter.lst-cend = left-trim(select3-type, chr(44))
.
END.
ON VALUE-CHANGED OF RS-tabs IN FRAME DIALOG-1
DO:
if rs-tabs:visible in frame DIALOG-1 then
  assign
  rs-tabs.
OPEN QUERY br-fields FOR EACH t-f no-lock where t-f.table-name = RS-tabs
and t-f.field-order = 0 use-index itorder.
END.
ON VALUE-CHANGED OF S-delim IN FRAME DIALOG-1
DO:
  assign
  S-delim
  .
  Assign
  f-delim = chr(int(s-delim))
  f-delim = (if f-delim = '':U then 'нет' else f-delim)
  .
  display f-delim
  with frame DIALOG-1
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame DIALOG-1 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DIALOG-1 :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame DIALOG-1 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DIALOG-1 :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame DIALOG-1 :height
      v-frame-virtual-height = frame DIALOG-1 :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame DIALOG-1 :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame DIALOG-1 :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame DIALOG-1 :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame DIALOG-1 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DIALOG-1 :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame DIALOG-1 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DIALOG-1 :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame DIALOG-1 :width
      v-frame-virtual-width = frame DIALOG-1 :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame DIALOG-1 :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DIALOG-1 :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame DIALOG-1 :width = frame DIALOG-1 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame DIALOG-1 :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame DIALOG-1 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DIALOG-1
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DIALOG-1 :height - v-diasize-resize-button :height
                  - 1
                  - (frame DIALOG-1 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DIALOG-1 :width - v-diasize-resize-button :width
                  - 1
                  - (frame DIALOG-1 :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame DIALOG-1
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame DIALOG-1 :height
      v-col-delta = v-new-col - frame DIALOG-1 :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame DIALOG-1 :width
      v-diasize-current-frame-height = frame DIALOG-1 :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame DIALOG-1
    :
      assign
        v-diasize-orig-frame-height = frame DIALOG-1 :height
        v-diasize-orig-frame-width  = frame DIALOG-1 :width
        v-diasize-browse-handle     = browse br-sel-fields :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DIALOG-1 :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-sel-fields :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
  fill-in-3 = 'Доступные поля'.
  fill-in-4 = 'Выбранные поля'.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if not avail temp-shop then
create temp-shop.
IF Kl <> 0 THEN DO:
   FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl.
   assign
   select3 = ubflt.filter.Fields-sort
   select3-label = entry(1, ubflt.filter.Fields-sort-rus, chr(4))
   select3-codes = entry(2, ubflt.filter.Fields-sort-rus, chr(4))
   select3-size = entry(1, ubflt.filter.Where-ysl, chr(4))
   select3-size-min = entry(2, ubflt.filter.Where-ysl, chr(4))
   select3-csize = entry(3, ubflt.filter.Where-ysl, chr(4))
   select3-format = ubflt.filter.Where-ysl-rus
   select3-type = ubflt.filter.lst-cend
   .
  assign
  temp-shop.all-prt              = (lookup("all-prt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
  temp-shop.cd-bc-alt            = (lookup("cd-bc-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  temp-shop.cd-bc-base           = (lookup("cd-bc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
  temp-shop.cd-loc-alt           = (lookup("cd-loc-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
  temp-shop.cd-loc-base          = (lookup("cd-loc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
  temp-shop.cd-parts-all         = (lookup("cd-parts-all":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
  temp-shop.cd-parts-not-blank   = (lookup("cd-parts-not-blank":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  temp-shop.cd-parts-ser         = (lookup("cd-part-ser":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  temp-shop.cd-pb-alt            = (lookup("cd-pb-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  temp-shop.cd-pb-base           = (lookup("cd-pb-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  temp-shop.cd-sc-base           = (lookup("cd-sc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
  .
END.
ELSE DO:
   CREATE ubflt.filter.
   assign
   ubflt.filter.call-point = c-point
   Kl = Num-flt
   .
   v-new = yes.
   if p-obj-type = 'маг':U then do:
    find first ub.shop no-lock where
               ub.shop.obj-code = p-obj-code no-error .
    if avail ub.shop then do:
      buffer-copy ub.shop to temp-shop.
    end.
   end.
END.
assign
jj             = 0
.
run fill-table in this-procedure no-error.
RUN MYenable.
apply "VALUE-CHANGED" to RS-tabs.
RUN PROC-N-L IN THIS-PROCEDURE.
WAIT-FOR GO OF FRAME DIALOG-1 focus br-fields.
if undo_ then undo,retry.
END.
RUN disable_UI.
PROCEDURE check-delim :
define input parameter p-delim as character no-undo.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable-buttons :
 if available t-f then do:
    enable
    btn-add
    with frame DIALOG-1.
  end.
  if available sel_t-f then do:
    enable
    btn-remove
    b-down b-up
    with frame DIALOG-1.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-tabs f-num-clmn f-delim S-delim f-length f-rec-num CB-scl-format
          CB-pg-format FILL-IN-4 FILL-IN-3
      WITH FRAME DIALOG-1.
  IF AVAILABLE ubflt.Filter THEN
    DISPLAY ubflt.Filter.Naim
      WITH FRAME DIALOG-1.
  ENABLE Btn_OK Btn_Cancel b-help RECT-1 ubflt.Filter.Naim RS-tabs f-delim S-delim
         f-rec-num CB-scl-format CB-pg-format BR-sel-fields BR-fields
      WITH FRAME DIALOG-1.
  OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
END PROCEDURE.
PROCEDURE fill-table :
define variable v-label as character no-undo .
list-tabls_block:
do ii = 1 to num-entries(List-Buf):
  assign
  file-name = entry(ii, List-tabls).
  list-dim_block:
  do kk = jj + 1 to jj + int(entry(ii,List-dim)):
    if file-name = "function":U OR index(entry(1, entry(kk, list-spr), '.'), "ATTR":u) > 0 then do:
      create t-f.
      assign
      t-f.table-name = file-name
      t-f.field-name = entry(kk, List-Fields)
      t-f.field-type  = entry(2, entry(kk, list-spr), '.')
      t-f.field-label = entry(kk,List-Labels)
      t-f.field-clabel = t-f.field-label
      t-f.field-spr = "":U
      t-f.field-size = entry(kk,List-Size)
      t-f.field-size-min = entry(kk,List-Size-min)
      t-f.field-format = entry(kk,List-format, chr(4))
      t-f.field-table-order = kk
      .
    end.
    else do:
      find first _File where _File-Name = file-name.
      id = recid(_File).
      do ll = 1 to num-entries(entry(kk, List-Fields),'*'):
        find _Field no-lock where
            _Field._Field-name =  entry(ll,entry(kk, List-Fields),'*')
        and _Field._File-Recid = id
        no-error .
        if not available _Field then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неизвестное поле" entry(ll,entry(kk, List-Fields),'*') skip
          "Таблица" entry(ii, List-Tabls)
          view-as alert-box error .
          next list-dim_block .
        end.
        find first t-f where
                   t-f.table-name = _File._File-name
               AND t-f.field-name = entry(kk, List-Fields)
        no-error.
        if not available t-f then do:
          create t-f.
          assign
          t-f.table-name = _File._File-name
          t-f.field-name = entry(kk, List-Fields)
          t-f.field-spr = entry(kk,List-spr)
          t-f.field-size = entry(kk,List-Size)
          t-f.field-size = entry(kk,List-Size-min)
          t-f.field-format = entry(kk,List-format, chr(4))
          t-f.field-table-order = kk
          .
        end.
        if _field._label = ? then do:
          assign
          v-label = chr(63)
          .
        end.
        else do:
          if current-language = "english" or current-language = "romanian" then do:
            if current-language = "english" then
            v-label = (if entry(2,_field._desc,"`") <> ? then entry(2,_field._desc,"`") else chr(63)).
            else
            v-label = (if entry(3,_field._desc,"`") <> ? then entry(3,_field._desc,"`") else chr(63)).
          end.
          else do:
            v-label = (if _field._label <> ? then _field._label else chr(63)).
          end.
        end.
        assign
        t-f.field-name-0 = t-f.field-name-0 +
                           (if t-f.field-name-0 = "":U
                            then "":U
                            else '*':U) +
                           entry(ll,entry(kk, List-Fields), '*':U)
        t-f.field-label  = if entry(kk,List-Labels) <> ""
                           then entry(kk,List-Labels)
                           else t-f.field-label  +
                           (if t-f.field-label = "":U
                            then "":U
                            else '*':U) +
                            v-label
        t-f.field-clabel = t-f.field-label
        t-f.field-type   = t-f.field-type  +
                           (if t-f.field-type = "":U
                            then "":U
                            else '*':U) +
                            _field._data-type
        t-f.field-format = entry(kk, list-format, chr(4))
        .
      end.
    end.
    if avail t-f then do:
      assign
      t-f.field-order =  lookup(t-f.table-name + ".":U + t-f.field-name, select3)
      t-f.field-csize = if v-new
                        then t-f.field-size
                        else  (if t-f.field-order > 0
                              then entry(t-f.field-order, entry(3, ubflt.filter.where-ysl, chr(4)))
                              else t-f.field-size)
      v-num-clmn = v-num-clmn +  (if   t-f.field-order > 0 then 1 else 0)
      v-length = v-length + (if   t-f.field-order > 0
                             then integer(entry(t-f.field-order, entry(3, ubflt.filter.where-ysl, chr(4))))
                             else 0)
      v-delim = if v-new then chr(int(entry(1, string(asc(chr(44))) + ',1,2,3,4,5,6,7,0,59':U))) else chr(int(entry(3, ubflt.filter.fields-sort-rus, chr(4))))
      v-rec-num = if v-new then 50000 else int(entry(4, ubflt.filter.fields-sort-rus, chr(4)))
      v-scl-format = (IF v-new OR NUM-ENTRIES(ubflt.filter.fields-sort-rus, chr(4)) < 5
                THEN "99999":U
                ELSE ENTRY(5, ubflt.filter.fields-sort-rus, chr(4)))
      v-pg-format = (IF v-new OR NUM-ENTRIES(ubflt.filter.fields-sort-rus, chr(4)) < 6
                THEN "99999":U
                ELSE ENTRY(6, ubflt.filter.fields-sort-rus, chr(4)))
      .
    end.
  end.
  jj = jj + int(entry(ii,List-dim)).
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-delim-str as character no-undo.
DEFINE VARIABLE v-cb-scl-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cb-pg-format AS CHARACTER NO-UNDO.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type16 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type16
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type16 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type16
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
ASSIGN
v-cb-scl-format = ">>>>9":U + chr(44) +
                  "99999":U .
DO ii = 1 TO NUM-ENTRIES(varscales-pref):
   ASSIGN
   v-cb-scl-format = v-cb-scl-format + chr(44) + ENTRY(ii, varscales-pref) + "99999":U.
END.
ASSIGN
cb-scl-format:LIST-ITEMS IN FRAME DIALOG-1  = v-cb-scl-format
cb-scl-format = v-scl-format
.
ASSIGN
v-cb-pg-format = ">>>>9":U + chr(44) +
                  "99999":U .
DO ii = 1 TO NUM-ENTRIES(varpgscales-pref):
   ASSIGN
   v-cb-pg-format = v-cb-pg-format + chr(44) + substring(ENTRY(ii, varpgscales-pref), 1, 2) + "99999":U.
END.
ASSIGN
cb-pg-format:LIST-ITEMS IN FRAME DIALOG-1  = v-cb-pg-format
cb-pg-format = v-pg-format
.
do ii = 1 to num-entries(list-tabls):
assign
v-rb = v-rb +
           (if v-rb = "":U then "":U else chr(44)) +
            entry(ii, list-buf) + chr(44) + entry(ii, list-tabls) .
.
end.
assign rs-tabs:radio-buttons in frame DIALOG-1 = v-rb.
if num-entries(list-tabls) > 1 then do:
display
 RS-tabs
with frame DIALOG-1.
Enable
Rs-tabs
with frame DIALOG-1.
end.
else do:
    assign
    rs-tabs = list-tabls.
    hide
    rs-tabs in frame DIALOG-1.
end.
assign s-delim:list-items in frame DIALOG-1 = string(asc(chr(44))) + ',1,2,3,4,5,6,7,0,59':U.
assign
s-delim = if v-delim = '':U then '0' else string(asc(v-delim))
.
 DISPLAY
 FILL-IN-3
 FILL-IN-4
 s-delim
  v-rec-num @ f-rec-num
 CB-SCL-FORMAT
 CB-pg-FORMAT
 WITH FRAME DIALOG-1 .
  IF AVAILABLE ubflt.filter THEN
    DISPLAY ubflt.filter.Naim
      WITH FRAME DIALOG-1.
  hide b-down b-up
  in frame DIALOG-1.
  ENABLE
  Btn_OK
  RECT-1
  Btn_Cancel
  b-help
  ubflt.filter.Naim
  BR-fields
  BR-sel-fields
  S-delim
  btn-codes
  f-rec-num
  CB-SCL-FORMAT
  cb-pg-format
  WITH FRAME DIALOG-1 .
  OPEN QUERY BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
  APPLY "Value-changed" to BR-sel-fields.
  if Rs-tabs:visible in frame DIALOG-1 then
  APPLY "Value-changed" to rs-tabs.
  APPLY "Value-changed" to s-delim.
  run enable-buttons in this-procedure.
END PROCEDURE.
PROCEDURE PROC-N-L :
display
string(v-num-clmn, ">>9") @ f-num-clmn
string(v-length, ">>>>9") @ f-length
(if v-delim = '':u then 'нет' else v-delim) @ f-delim
WITH FRAME DIALOG-1.
END PROCEDURE.
