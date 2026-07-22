block-level on error undo, throw.
define input parameter o-type    as character no-undo .
define input parameter o-code    as integer   no-undo .
define input parameter f-date    as date      no-undo .
define input parameter f-time    as integer   no-undo .
define input parameter s-date    as date      no-undo .
define input parameter s-num     as integer   no-undo .
define input parameter is-berate as logical   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: f4fc214ea39a, 40, test $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/05/23 10:49:54 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: chk-date.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/chk-date.p $":U .
define variable vss-description as character no-undo initial "Проверка правильного заведения даты в документе":U .
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6',o-type,o-code,f-date,f-time,s-date,s-num)
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
define variable diffshftvalue     as character no-undo initial ? .
define variable diffshfttype      as character no-undo initial ? .
define variable vardiffshft       as integer   no-undo initial ? .
define buffer bf_shop  for ub.shop.
define buffer bf_store for ub.store.
define variable h-code  like ub.shop.host-code.
define variable v-today as   date      no-undo.
if f-date = ? then do:
  if is-berate = yes then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не указана фактическая дата закрытия"
      view-as alert-box error.
  end.
  undo, return error "Не указана фактическая дата закрытия" .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  o-type
  ,input  o-code
  ,output v-today
  )  .
if f-date > v-today then do:
  if is-berate then do:
    message
      vss-workfile vss-revision vss-description skip
      "Фактическая дата закрытия: " f-date skip
      "больше сегодняшней: " v-today skip
      view-as alert-box error .
  end.
  undo, return error substitute( "Фактическая дата закрытия &1 больше сегодняшней &2", f-date, v-today ) .
end.
if f-time = ?
or f-time = 0 then do:
   if is-berate = yes then do:
     message
       vss-workfile vss-revision vss-description skip
       "Не указано фактическое время закрытия"
       "Фактическая дата закрытия" f-date skip
       view-as alert-box error.
   end.
   undo, return error substitute( "Не указано фактическое время закрытия. Фактическая дата закрытия &1.", f-date ) .
end.
define variable l-shift-on as logical no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  o-type
  ,input  o-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if l-shift-on = yes then do:
  if s-date = ? then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не указана дата начала смены." s-date skip
        view-as alert-box error.
    end.
    undo, return error substitute( "Не указана дата начала смены &1.", s-date ) .
  end.
if o-type = 'скл':U then do:
   find bf_store where bf_store.obj-code = o-code no-lock.
   assign h-code = bf_store.host-code.
end.
else do:
  find bf_shop where bf_shop.obj-code = o-code no-lock.
  assign h-code = bf_shop.host-code.
end.
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-integer   as integer    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .
   run adm/shattri.p ( input "get":U
                     , input  o-type
                     , input  o-code
                     , input  'obj-date':U
                     , input  'diffshft':U
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error
   then do:
      assign
         vardiffshft = 3
      .
   end.
   else do:
      assign
         vardiffshft = v-value-integer
      no-error
      .
    if error-status:error
    or vardiffshft < 0
    then do:
      if is-berate = yes then do:
        message "Неверно задан параметр diffshft: " diffshftvalue skip
                "Параметр может принимать целые значения > 0." skip
        view-as alert-box error.
      end.
      undo, return error substitute( "Неверно задан параметр diffshft: &1.&2" +
                                     "Параметр может принимать целые значения > 0.",
                                     diffshftvalue,
                                     chr(10) ) .
    end.
  end.
  delete object v-tth.
  if s-date > f-date
  or s-date < f-date - vardiffshft then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Дата смены не соответствует фактической дате закрытия." skip
        "Фактическая дата закрытия" f-date skip
        "Дата смены" s-date skip
        "Допустима сменная дата от " f-date - vardiffshft " до " f-date
        view-as alert-box error.
    end.
    undo, return error substitute( "Дата смены не соответствует фактической дате закрытия.&4" +
                                   "Фактическая дата закрытия &1.&4" +
                                   "Дата смены &2.&4" +
                                   "Допустима сменная дата от &3 до &1.",
                                   f-date,
                                   s-date,
                                   f-date - vardiffshft,
                                   chr(10) ) .
  end.
  if s-num = ?
  or s-num = 0 then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не указан порядок смены." skip
        "Фактическая дата закрытия" f-date skip
        "Дата смены" s-date skip
        view-as alert-box error.
    end.
    undo, return error substitute( "Не указан порядок смены.&3" +
                                   "Фактическая дата закрытия &1.&3" +
                                   "Дата смены &2.",
                                   f-date,
                                   s-date,
                                   chr(10) ) .
  end.
end.
