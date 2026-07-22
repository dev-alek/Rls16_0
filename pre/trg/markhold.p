block-level on error undo, throw.
define input  parameter p-cat-code  as integer   no-undo .
define input  parameter p-lock-code as character no-undo .
define input  parameter p-fact-date as date      no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пометить межфирменные архивы, как требующие перерасчета с определенной даты".
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
      p-vss-parameters = substitute('&1|&2|&3',p-cat-code,p-lock-code,p-fact-date)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure holdattr-code :
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
            when 'begin-date':U then do:     assign     p-label = "Дата начала межфирменного архива"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата начала межфирменного архива"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'is-calc':U then do:     assign     p-label = "Произв.расчет арх."     p-type = 'L':U      p-format = "+/-"     p-label = "Произв.расчет арх."     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure holdattr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'begin-date':U then do:     assign     p-tooltip = "Дата начала межфирменного архива"     p-label = "Дата начала межфирменного архива" .   end.
            when 'is-calc':U then do:     assign     p-tooltip = "Производится расчет межфирменного архива"     p-label = "Произв.расчет арх." .   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure holdattr-value :
  do
  on error undo, return error
  :
    define input  parameter p-cat-code  like ub.hold-attr.cat-code     no-undo .
    define input  parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-value     like ub.hold-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if avail buf_hold-attr then do:
      assign
        p-value =  buf_hold-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure holdattr-write :
  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define input parameter p-value     like ub.hold-attr.attr-value no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if not available buf_hold-attr then do:
      create buf_hold-attr .
      assign
        buf_hold-attr.cat-code    = p-cat-code
        buf_hold-attr.attr-code = p-code
      .
    end.
    assign
      buf_hold-attr.attr-value = p-value
    .
  end.
end procedure.
procedure holdattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if  available buf_hold-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure holdattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cat-code   like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code     like ub.hold-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_hold-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_hold-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure holdattr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'begin-date':U then do:     assign     p-news = no.   end.
            when 'is-calc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
do
on error undo, return error return-value
:
  if  p-cat-code <> 1
  and p-cat-code <> 2
  and p-cat-code <> 3
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестная категория межфирменных архивов" skip
      "Категория" p-cat-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-fact-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Дата имеет неопределенное значение" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define buffer calc-hold-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input p-lock-code
    ,input p-cat-code
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input "Категория,,,,,,Расчет межфирменных архивов"
    ,input true
    ,buffer calc-hold-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитываются межфирменные архивы" skip
      "Категория" p-cat-code skip
      "Пометить межфирменные архивы, как требующие перерасчета" skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-hold-calc-value as character no-undo .
  define variable v-hold-calc-type  as character no-undo .
  define variable v-hold-calc       as logical   no-undo .
  run holdattr-value in this-procedure
    (input  p-cat-code
    ,input  'is-calc':U
    ,output v-hold-calc-value
    ,output v-hold-calc-type
    ) .
  assign
    v-hold-calc = (lookup(v-hold-calc-value, 'yes,true') > 0)
  .
  if v-hold-calc = true then do:
    return .
  end.
  define variable v-attr-begin-date-value as character no-undo .
  define variable v-attr-begin-date-type  as character no-undo .
  define variable v-attr-begin-date       as date      no-undo .
  assign
    v-attr-begin-date = ?
  .
  run holdattr-value in this-procedure
    (input  p-cat-code
    ,input  'begin-date':U
    ,output v-attr-begin-date-value
    ,output v-attr-begin-date-type
    ) .
  if v-attr-begin-date-value <> "" then do:
    assign
      v-attr-begin-date = date(v-attr-begin-date-value)
    .
  end.
  define variable v-start-date as date      no-undo .
  assign
    v-start-date = date(month(p-fact-date), 1, year(p-fact-date))
  .
  if  v-attr-begin-date <> ?
  and v-start-date < v-attr-begin-date
  then do:
    return .
  end.
  define buffer del_hold-time for ub.hold-time .
  find first del_hold-time exclusive-lock
    where del_hold-time.cat-code = p-cat-code
      and del_hold-time.time-type = 'мес':U
      and del_hold-time.start-date = v-start-date
    no-error .
  if  available del_hold-time then do:
  assign
    del_hold-time.status_ = 'удаленные':U
    del_hold-time.grpupdate-date = today
    del_hold-time.update-date = today
  .
  end.
end.
