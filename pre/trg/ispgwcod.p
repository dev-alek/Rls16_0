block-level on error undo, throw.
define input parameter p-b-code like ub.bar-code.b-code no-undo.
define input parameter p-question-pgweight as logical no-undo .
define input parameter p-question-global as logical no-undo .
define input parameter p-question-on     as logical no-undo .
define input parameter p-current-b-str like ub.prod-bc.b-str no-undo.
define output parameter p-answer as logical no-undo .
define output parameter p-on as logical no-undo .
define output parameter p-b-str like ub.prod-bc.b-str no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка наличия у товара штучных кодов для весов".
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
define variable l-prod-bc-global as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
DEFINE VARIABLE v-answer-global as logical no-undo init yes.
DEFINE VARIABLE v-answer-pgweight as logical no-undo init yes.
DEFINE VARIABLE v-answer-on     as logical no-undo init yes.
DEFINE VARIABLE v-found         as logical no-undo .
DEFINE VARIABLE v-found-b-str   like ub.prod-bc.b-str no-undo .
define buffer b-prod-bc for ub.prod-bc .
do
on error undo, return error
:
  _b-prod-bc:
  FOR EACH b-prod-bc where
          b-prod-bc.b-code = p-b-code no-LOCK:
    if p-current-b-str = b-prod-bc.b-str then NEXT _b-prod-bc.
    assign
    v-answer-global = yes
    v-answer-pgweight = yes
    v-answer-on     = yes
    .
    if p-question-global then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer b-prod-bc
  ,input  'global=request':u
  ,output l-prod-bc-global
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" b-prod-bc.b-code skip
          "Дополнительный бар-код" b-prod-bc.b-str skip
          "Действие global=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    if p-question-pgweight then do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer b-prod-bc
  ,input  'pgweight=request':u
  ,output l-prod-bc-pgweight
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" b-prod-bc.b-code skip
          "Дополнительный бар-код" b-prod-bc.b-str skip
          "Действие weight=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    if p-question-global and (NOT l-prod-bc-global) then do:
      v-answer-global = no.
    end.
    if p-question-pgweight and (NOT l-prod-bc-pgweight) then do:
      v-answer-pgweight = no.
    end.
    assign
    p-on = b-prod-bc.bc-on
    p-b-str = b-prod-bc.b-str
    .
    if p-question-on then do:
      assign
      v-answer-on = p-on
      .
    end.
    assign
    v-found = (if v-found = no then
              v-answer-global AND v-answer-pgweight
              else v-found)
    v-found-b-str = (if v-found-b-str = "":U
                     then b-prod-bc.b-str
                     else v-found-b-str
                     )
    p-answer = v-answer-global AND v-answer-pgweight AND v-answer-on.
    if p-answer then LEAVE.
  END.
  if (p-question-on and not p-answer)
  AND v-found then do:
    assign
    p-answer = yes
    p-on = no
    p-b-str = v-found-b-str
    .
  end.
 end.
