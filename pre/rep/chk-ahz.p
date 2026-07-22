block-level on error undo, throw.
define input        parameter p-obj-type          as character no-undo .
define input        parameter p-obj-code          as integer   no-undo .
define input        parameter p-verify-detail     as logical   no-undo .
define input        parameter p-verify-arh        as logical   no-undo .
define input        parameter p-verify-ahsp       as logical   no-undo .
define input        parameter p-verify-aht        as logical   no-undo .
define input        parameter p-check-act         as logical   no-undo .
define input        parameter p-check-act-db-num  as integer   no-undo .
define input        parameter p-check-act-user-id as character no-undo .
define input-output parameter p-date-start        as date      no-undo .
define input-output parameter p-date-end          as date      no-undo .
define output       parameter p-archive-ok        as logical   no-undo .
define output       parameter p-comment           as character no-undo .
define output       parameter p-can-print         as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 61c78e167033, 1728, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 26 18:20:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-ahz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/chk-ahz.p $":U .
define variable vss-description as character no-undo init "Проверка состояния складских архивов и возвращение правильных дат".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7',p-obj-type,p-obj-code,p-verify-arh,p-verify-ahsp,p-verify-aht,p-date-start,p-date-end)
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_ot-tot      for ub.ot-tot .
define buffer buf_ot-supp-tot for ub.ot-supp-tot .
define buffer buf_aht-ot-tot  for ub.aht-ot-tot .
define buffer buf_trn-doc     for ub.trn-doc .
do
on error undo, return error return-value
:
  if  p-verify-arh    = false
  and p-verify-ahsp   = false
  and p-verify-aht    = false
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указан складской архив, который необходимо проверить" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-date-start = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указана дата начала периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-date-end = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указана дата завершения периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    return .
  end.
  if p-date-start > p-date-end
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Дата начала периода не может быть больше даты завершения периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    return .
  end.
  define variable v-obj-exist as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'check-exist':u
  ,output v-obj-exist
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Не найден объект" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-shift-new as logical    no-undo .
  if p-verify-arh = true
  then do:
    define variable v-arh-calc          as logical   no-undo .
    define variable v-arh-del           as logical   no-undo .
    define variable v-arh-disable       as logical   no-undo .
    define variable v-arh-start-date    as date      no-undo .
    define variable v-arh-detail-date   as date      no-undo .
    define variable v-arh-recalc-date   as date      no-undo .
    define variable v-arh-last-stk-date as date      no-undo .
    define variable v-arh-last-stk-time as integer   no-undo .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-calc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-del':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-disable':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-start':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-start-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-detail':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-detail-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-recalc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-arh-recalc-date = date(v-attr-value)
    .
    assign
      v-arh-last-stk-date = ?
      v-arh-last-stk-time = 0
    .
    find last buf_ot-tot no-lock
      where buf_ot-tot.obj-code = p-obj-code
        and buf_ot-tot.obj-type = p-obj-type
      use-index obj-ot
      no-error .
    if available buf_ot-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-arh-last-stk-date = buf_trn-doc.fact-date
          v-arh-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.
    run check-date in this-procedure
      (input        v-arh-calc
      ,input        v-arh-del
      ,input        v-arh-disable
      ,input        v-arh-start-date
      ,input        v-arh-detail-date
      ,input        v-arh-recalc-date
      ,input        v-arh-last-stk-date
      ,input        v-arh-last-stk-time
      ,input        "Складской архив по товарам"
      ,input        'arh':u
      ,input        p-verify-detail
      ,input-output p-date-start
      ,input-output p-date-end
      ,output       p-archive-ok
      ,output       p-comment
      ,output       p-can-print
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.
  if p-verify-ahsp = true
  then do:
    define variable v-ahsp-calc          as logical   no-undo .
    define variable v-ahsp-del           as logical   no-undo .
    define variable v-ahsp-disable       as logical   no-undo .
    define variable v-ahsp-start-date    as date      no-undo .
    define variable v-ahsp-detail-date   as date      no-undo .
    define variable v-ahsp-recalc-date   as date      no-undo .
    define variable v-ahsp-last-stk-date as date      no-undo .
    define variable v-ahsp-last-stk-time as integer   no-undo .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-calc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-del':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-disable':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-start':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-start-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-detail':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-detail-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-recalc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-recalc-date = date(v-attr-value)
    .
    assign
      v-ahsp-last-stk-date = ?
      v-ahsp-last-stk-time = 0
    .
    find last buf_ot-supp-tot no-lock
      where buf_ot-supp-tot.obj-code = p-obj-code
        and buf_ot-supp-tot.obj-type = p-obj-type
      use-index fact-order
      no-error .
    if available buf_ot-supp-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-supp-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-ahsp-last-stk-date = buf_trn-doc.fact-date
          v-ahsp-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.
    run check-date in this-procedure
      (input        v-ahsp-calc
      ,input        v-ahsp-del
      ,input        v-ahsp-disable
      ,input        v-ahsp-start-date
      ,input        v-ahsp-detail-date
      ,input        v-ahsp-recalc-date
      ,input        v-ahsp-last-stk-date
      ,input        v-ahsp-last-stk-time
      ,input        "Складской архив по поставщикам"
      ,input        'ahsp':u
      ,input        p-verify-detail
      ,input-output p-date-start
      ,input-output p-date-end
      ,output       p-archive-ok
      ,output       p-comment
      ,output       p-can-print
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.
  if p-verify-aht = true
  then do:
    define variable v-aht-calc          as logical   no-undo .
    define variable v-aht-del           as logical   no-undo .
    define variable v-aht-disable       as logical   no-undo .
    define variable v-aht-start-date    as date      no-undo .
    define variable v-aht-detail-date   as date      no-undo .
    define variable v-aht-recalc-date   as date      no-undo .
    define variable v-aht-last-stk-date as date      no-undo .
    define variable v-aht-last-stk-time as integer   no-undo .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-calc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-del':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-del = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-disable':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-start':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-start-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-detail':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-detail-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-recalc':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-aht-recalc-date = date(v-attr-value)
    .
    assign
      v-aht-last-stk-date = ?
      v-aht-last-stk-time = 0
    .
    find last buf_aht-ot-tot no-lock
      where buf_aht-ot-tot.obj-code = p-obj-code
        and buf_aht-ot-tot.obj-type = p-obj-type
      use-index fact-order
      no-error .
    if available buf_aht-ot-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_aht-ot-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-aht-last-stk-date = buf_trn-doc.fact-date
          v-aht-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.
    run check-date in this-procedure
      (input        v-aht-calc
      ,input        v-aht-del
      ,input        v-aht-disable
      ,input        v-aht-start-date
      ,input        v-aht-detail-date
      ,input        v-aht-recalc-date
      ,input        v-aht-last-stk-date
      ,input        v-aht-last-stk-time
      ,input        "Складской архив по типам приобретения"
      ,input        'aht':u
      ,input        p-verify-detail
      ,input-output p-date-start
      ,input-output p-date-end
      ,output       p-archive-ok
      ,output       p-comment
      ,output       p-can-print
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.
  assign
    p-archive-ok = true
    p-comment    = ""
    p-can-print  = true
  .
  return .
end.
procedure check-date :
  define input        parameter p-calc          as logical   no-undo .
  define input        parameter p-del           as logical   no-undo .
  define input        parameter p-disable       as logical   no-undo .
  define input        parameter p-start-date    as date      no-undo .
  define input        parameter p-detail-date   as date      no-undo .
  define input        parameter p-recalc-date   as date      no-undo .
  define input        parameter p-last-stk-date as date      no-undo .
  define input        parameter p-last-stk-time as integer   no-undo .
  define input        parameter p-name          as character no-undo .
  define input        parameter p-ahz-type      as character no-undo .
  define input        parameter p-verify-detail as logical   no-undo .
  define input-output parameter p-date-start    as date      no-undo .
  define input-output parameter p-date-end      as date      no-undo .
  define output       parameter p-archive-ok    as logical   no-undo .
  define output       parameter p-comment       as character no-undo .
  define output       parameter p-can-print     as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  (p-calc = true
         or p-del  = true
        )
    and p-disable = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + "Расчет складского архива запрещен" + chr(10)
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print
          ) no-error .
      return .
    end.
    if p-calc = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + p-name + " не рассчитан" + chr(10)
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print )
          no-error .
      return .
    end.
    if p-del = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + "Начальные остатки по складскому архиву не рассчитаны" + chr(10)
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print )
          no-error .
      return .
    end.
    if (p-start-date  = ?
       and p-detail-date <> ?
       )
    or
       (p-start-date  <> ?
       and p-detail-date = ?
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при анализе дат складского архива" skip
        "Задана только одна дата" skip
        "" p-start-date skip
        "" p-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-date-start < p-start-date
    then do:
      assign
        p-date-start = p-start-date
      .
      if p-date-end < p-start-date
      then do:
        assign
          p-date-end = p-start-date
        .
      end.
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + "Дата начала периода не может быть раньше начала рассчитанного складского архива"
        p-can-print  = false
      .
      return .
    end.
    if  p-verify-detail = true
    and p-date-start < p-detail-date
    then do:
      assign
        p-date-start = p-detail-date
      .
      if p-date-end < p-date-start
      then do:
        assign
          p-date-end = p-date-start
        .
      end.
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + "Для подробного архива дата начала периода должна быть больше или равна началу подробного архива"
        p-can-print  = false
      .
      return .
    end.
    define variable v-new-date-start as date      no-undo .
    if  p-date-start > p-start-date
    and p-date-start < p-detail-date
    and day(p-date-start) <> 1
    and p-date-end <> p-date-start
    then do:
      assign
        v-new-date-start = date(month(p-date-start),1,year(p-date-start))
      .
      if v-new-date-start < p-start-date
      then do:
        run gbl/lastdate.p
          (input  p-date-start
          ,output v-new-date-start
          ) .
        assign
          v-new-date-start = v-new-date-start + 1
        .
      end.
      assign
        p-date-start = v-new-date-start
      .
      if p-date-end < p-date-start
      then do:
        run gbl/lastdate.p
          (input  p-date-start
          ,output p-date-end
          ) .
      end.
      assign
        p-archive-ok = false
        p-comment    = p-name + chr(10)
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                     + "Для сжатого складского архива дата начала периода должна быть началом месяца"
        p-can-print  = false
      .
      return .
    end.
    define variable v-new-date-end as date      no-undo .
    if  p-date-end > p-start-date
    and p-date-end < p-detail-date
    then do:
      run gbl/lastdate.p
        (input  p-date-end
        ,output v-new-date-end
        ) .
      if p-date-end <> v-new-date-end
      then do:
        assign
          p-date-end = v-new-date-end
        .
        assign
          p-archive-ok = false
          p-comment    = p-name + chr(10)
                       + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                       + "Для сжатого складского архива дата завершения периода должна быть последним днем месяца " + string(v-new-date-end,"99/99/9999")
          p-can-print  = false
        .
        return .
      end.
    end.
    define variable v-date-shift as date      no-undo .
    run ver-shift in this-procedure (
        input   p-date-end ,
        input   p-obj-type ,
        input   p-obj-code ,
        output  v-date-shift ) no-error .
    if p-last-stk-date = ?
    or (p-last-stk-date <> ?
        and p-date-end >= p-last-stk-date) or v-date-shift <= p-last-stk-date
    or (p-recalc-date <> ?
        and p-date-end >= p-recalc-date
       )
    then do:
      case p-ahz-type
      :
        when 'arh':u
        then do:
          run trg/bt_arh.p
            (input p-obj-type
            ,input p-obj-code
            ,input v-date-shift
            ,input p-check-act
            ,input p-check-act-db-num
            ,input p-check-act-user-id
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_arh.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + chr(10)
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                           + substitute("&1", return-value) + chr(10)
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + chr(10)
              p-can-print  = true
            .
            run ver-del-obj (
                input p-obj-type ,
                input p-obj-code ,
                input-output p-can-print )
                no-error .
            return .
          end.
        end.
        when 'ahsp':u
        then do:
          run trg/bt_ahsp.p
            (input p-obj-type
            ,input p-obj-code
            ,input v-date-shift
            ,input p-check-act
            ,input p-check-act-db-num
            ,input p-check-act-user-id
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_ahsp.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + chr(10)
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                           + substitute("&1", return-value) + chr(10)
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + chr(10)
              p-can-print  = true
            .
            run ver-del-obj (
                input p-obj-type ,
                input p-obj-code ,
                input-output p-can-print )
                no-error .
            return .
          end.
        end.
        when 'aht':u
        then do:
          run trg/bt_aht.p
            (input p-obj-type
            ,input p-obj-code
            ,input v-date-shift
            ,input p-check-act
            ,input p-check-act-db-num
            ,input p-check-act-user-id
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_aht.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + chr(10)
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
                           + substitute("&1", return-value) + chr(10)
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + chr(10)
              p-can-print  = true
            .
              run ver-del-obj (
                  input p-obj-type ,
                  input p-obj-code ,
                  input-output p-can-print )
                  no-error .
            return .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение параметра p-ahz-type" skip
            "Значение параметра" p-ahz-type skip
            view-as alert-box error .
          assign
            p-archive-ok = false
            p-comment    = ""
            p-can-print  = false
          .
          return .
        end.
      end.
    end.
    assign
      p-archive-ok = true
      p-comment    = ""
      p-can-print  = true
    .
    return .
  end.
end procedure.
procedure ver-shift :
define input  parameter p-date     as date      no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define output parameter p-date-shift   as date      no-undo .
define variable  l-shift-on as logical no-undo .
define buffer buf_shift-obj for ub.shift-obj  .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
  if l-shift-on = false then do:
     p-date-shift = p-date.
     return .
  end.
  for each  buf_shift-obj no-lock where
            buf_shift-obj.obj-type = p-obj-type and
            buf_shift-obj.obj-code = p-obj-code and
            buf_shift-obj.shift-date = p-date   by
            buf_shift-obj.close-date
            :
       p-date-shift = buf_shift-obj.close-date .
   end.
  if p-date-shift = ? or p-date-shift < p-date then p-date-shift = p-date .
end.
end procedure.
procedure ver-del-obj :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input-output parameter p-is-del as logical   no-undo .
define buffer buf_clients for ub.clients  .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock where
               buf_clients.obj-type = p-obj-type and
               buf_clients.obj-code = p-obj-code no-error .
     if buf_clients.stts <> 0 then do:
        p-is-del = true .
     end.
  end.
end procedure.
procedure ver-new-shiftobj :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-is-new   as logical   no-undo .
define buffer buf_shift-obj for ub.shift-obj  .
  do
  on error undo, return error return-value
  :
      p-is-new = false .
      run factord-lock-shift (
          input p-obj-type ,
          input p-obj-code ,
          input date('01/01/1900')  ,
          buffer buf_shift-obj
      ) no-error .
      if error-status :error then do:
        p-is-new = true  .
      end.
  end.
end procedure.
