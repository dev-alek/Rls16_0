block-level on error undo, throw.
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: d-infgds.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/d-infgds.p $":U .
define variable vss-description as character no-undo initial "Подробная информация о товаре для разработчиков".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define buffer buf_goods for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .
define variable v-bad-gds as logical   no-undo .
define variable v-message as character no-undo .
do
on error undo, return error return-value
:
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Товар не найден" skip
      "Код товара" p-gds-code skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable v-artic     as character no-undo .
  define variable v-prod-type as character no-undo .
  define variable v-prod-code as integer   no-undo .
  assign
    v-artic     = buf_goods.artic
    v-prod-type = buf_goods.prod-type
    v-prod-code = buf_goods.prod-code
  .
  find first buf_gds-obj exclusive-lock
    where buf_gds-obj.obj-type  = p-obj-type
      and buf_gds-obj.obj-code  = p-obj-code
      and buf_gds-obj.artic     = v-artic
      and buf_gds-obj.prod-type = v-prod-type
      and buf_gds-obj.prod-code = v-prod-code
    no-error .
  if available buf_gds-obj
  then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input v-artic
  ,input v-prod-type
  ,input v-prod-code
  ,input ?
  ,input 'return'
  ) no-error .
    if error-status :error
    then do:
      assign
        v-bad-gds = true
      .
      assign
        v-message = return-value
      .
    end.
  end.
  if v-bad-gds
  then do:
    message
      "Код товара" p-gds-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Объект" p-obj-type p-obj-code skip
      "Товар испорчен" skip
      v-message skip
      view-as alert-box error .
  end.
  else do:
    message
      "Код товара" p-gds-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Объект" p-obj-type p-obj-code skip
      "Товар целостный"
      view-as alert-box information .
  end.
end.
