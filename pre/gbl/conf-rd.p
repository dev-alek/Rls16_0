block-level on error undo, throw.
define input param  p-code  as character no-undo .
define input param  h-code  as integer   no-undo .
define input param  o-type  as character no-undo .
define input param  o-code  as integer   no-undo .
define input param  g-name  as character no-undo .
define input param  u-name  as character no-undo .
define input param  e-name  as character no-undo .
define input param  msg-on  as logical   no-undo .
define output param p-value as character no-undo .
define output param p-type  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 6b203531fb4a, 3411, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2023/08/17 10:18:56 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: conf-rd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/conf-rd.p $":U .
define variable vss-description as character no-undo init "Чтение параметров конфигурации для текущей БД".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  p-code
  ,input  h-code
  ,input  o-type
  ,input  o-code
  ,input  g-name
  ,input  u-name
  ,input  e-name
  ,input  msg-on
  ,output p-value
  ,output p-type
  ) no-error .
if error-status :error then do:
  if error-status :get-message(1) <> "" then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры conf-rd" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value.
end.
