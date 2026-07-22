DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_prod-bc FOR ub.prod-bc.
DEFINE BUFFER X_prod-bc-db FOR ub.prod-bc-db.
DEFINE BUFFER X_scales-gds FOR ub.scales-gds.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-db-num   like ub.scales.db-num    no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары на всех весах".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-price RETURNS decimal
  (buffer loc-good for ub.goods,  shop-type as char , shop-code as integer, bcode as integer ) :
define variable scale-price as decimal no-undo.
define buffer buf_shop  for ub.shop.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  loc-good.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return ?.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  shop-type
  ,input  shop-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return ?.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  shop-type
  ,input  shop-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return ?.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
  if  gp-price-sale <> ? then do:
    define variable l-in-ov as logical no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  shop-type
  ,input  shop-code
  ,input  loc-good.artic
  ,input  loc-good.prod-type
  ,input  loc-good.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov
  ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка получения признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    find first buf_shop no-lock where buf_shop.obj-code = shop-code .
    if not (buf_shop.in-ov AND l-in-ov) then do:
      assign
        scale-price = gp-price-sale
      .
    end.
    else do:
      assign
        scale-price = ?
      .
    end.
  end.
  else do:
    assign
      scale-price = ?
    .
  end.
  RETURN scale-price.
END FUNCTION.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
FUNCTION scl-gds-ld returns integer ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-raw-dead-line / 24  + 01/01/2000 - v-today
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = p-raw-dead-line.
return v-dead-line .
end.
FUNCTION scl-gds-ld2 returns integer ( input p-deadline as integer
                                     , input p-deaddate as date
                                     , input p-deadflag as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
if p-deadflag > 0 then do:
  if p-deaddate = ? then return 0.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-deaddate - v-today + 1
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = (if p-deadline = ? then 0 else p-deadline).
return v-dead-line .
end.
FUNCTION scl-gds-ld-date returns date ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-sclin-ld > 0 then do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line / 24  + 01/01/2000 - 1
    .
  end.
  else  do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
else do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line  + v-today - 1
    .
  end.
  else do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
return v-dead-line-date.
end.
FUNCTION scl-gds-ld-parts returns integer ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return (v-last-date - 01/01/2000 + 1) * 24.
  end.
  else do:
    return 0.
  end.
end.
else do:
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return buf_goods.deadline.
  end.
  else return 0.
end.
END FUNCTION.
FUNCTION scl-gds-ld-parts-date returns date ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return v-last-date.
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-time).
    return v-today.
  end.
end.
else do:
  run cur-time in this-procedure ( output v-today, output v-time).
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return (v-today + buf_goods.deadline).
  end.
  else return v-today.
end.
END FUNCTION.
FUNCTION scl-gds-ld-to-raw returns integer ( input p-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  if p-dead-line = 0 then do:
    assign
    v-dead-line = 0
    .
  end.
  else do:
    assign
    v-dead-line = (v-today + p-dead-line - 01/01/2000) * 24
    .
  end.
end.
else v-dead-line = p-dead-line.
return v-dead-line.
end.
FUNCTION scl-gds-ld-to-date returns date ( input p-dead-line as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
return (v-today  + p-dead-line - 1).
end.
FUNCTION scl-gds-deadvalue returns character ( input p-deadline as integer
                                              ,input p-deaddate as date
                                              ,input p-deadflag as integer):
if p-deadflag = integer('0':U) then return string((if p-deadline = ? then 0 else p-deadline)).
else return string(p-deaddate, "99/99/9999").
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable temp-code like ub.scales-gds.b-code no-undo.
define variable rid-list    as  char    no-undo .
define variable scale-price as decimal.
define buffer l-goods for ub.goods.
define buffer l-scales-gds for ub.scales-gds.
define buffer l-bar-code for ub.bar-code.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-prod-bc-db for ub.prod-bc-db.
define buffer l-gds-obj-attr for ub.gds-obj-attr.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable current-db-num like ub.scales-gds.db-num.
define variable current-scales like ub.scales-gds.scales-num.
define variable current-b-code like ub.scales-gds.b-code.
define variable current-plu like ub.scales-gds.plu-code.
define variable line-rec    as recid             no-undo.
define variable glog        as logical no-undo .
define variable gds-rec     as recid             no-undo.
define variable v-doc-rec   as recid no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable db-mode as character no-undo .
FUNCTION get-scl-code RETURNS CHARACTER
  (    INPUT p-b-code AS INTEGER
     , INPUT p-b-str AS CHARACTER
     , BUFFER buf_prod-bc-db FOR ub.prod-bc-db )  FORWARD.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-ticket
     LABEL "&Ценники"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_OUT AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     LABEL "Начало артикула"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)"
     LABEL "Бар-код (весь)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)"
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.8 BY 1.13
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code",
"Вес.код", "ves",
"PLU", "plu",
"Штрих-код", "shtrih"
     SIZE 42 BY 1 NO-UNDO.
DEFINE QUERY br-lst FOR
      X_scales-gds,
      X_bar-code,
      X_goods,
      X_gds-obj-attr,
      X_prod-bc SCROLLING.
DEFINE QUERY br-lst-db FOR
      X_scales-gds,
      X_bar-code,
      X_goods,
      X_gds-obj-attr,
      X_prod-bc-db SCROLLING.
DEFINE BROWSE br-lst
  QUERY br-lst NO-LOCK DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL "*" FORMAT "X(1)":U
X_prod-bc.b-str COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
X_goods.gds-name FORMAT "X(30)":U
X_goods.artic FORMAT "X(16)":U
X_scales-gds.scales-num COLUMN-LABEL "Весы" FORMAT ">>9":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
entry (lookup (string(X_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) COLUMN-LABEL "Тип" format "x(3)"
X_scales-gds.b-code FORMAT "999999999":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT ">>>,>>9.999":U
entry (lookup (STRING(X_scales-gds.deadflag), '0,1':U) + 1, ',' + 'Дни,Дата':U) COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_goods.grp-name FORMAT "X(40)":U
X_goods.unit-base FORMAT "X(3)":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.obj-type +  STRING (X_scales-gds.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4
         BGCOLOR 15 FGCOLOR 0 .
DEFINE BROWSE br-lst-db
  QUERY br-lst-db NO-LOCK DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL "*" FORMAT "X(1)":U
get-scl-code( INPUT X_bar-code.b-code, INPUT X_gds-obj-attr.attr-value, BUFFER X_prod-bc-db) COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
X_goods.gds-name FORMAT "X(30)":U
X_goods.artic FORMAT "X(16)":U
X_scales-gds.scales-num COLUMN-LABEL "Весы" FORMAT ">>9":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
entry (lookup (string(X_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) COLUMN-LABEL "Тип" format "x(3)"
X_scales-gds.b-code FORMAT "999999999":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT ">>>,>>9.999":U
entry (lookup (STRING(X_scales-gds.deadflag), '0,1':U) + 1, ',' + 'Дни,Дата':U) COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_goods.grp-name FORMAT "X(40)":U
X_goods.unit-base FORMAT "X(3)":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.obj-type +  STRING (X_scales-gds.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4
         BGCOLOR 15 FGCOLOR 0 .
DEFINE FRAME Dialog-Frame
     Btn_OUT AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-ticket AT ROW 1 COL 24
     b-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     a-n-c AT ROW 3.17 COL 12.5 NO-LABEL
     loc-art AT ROW 3.17 COL 69.8 COLON-ALIGNED
     loc-name AT ROW 3.17 COL 69.8 COLON-ALIGNED
     loc-code AT ROW 3.17 COL 69.8 COLON-ALIGNED
     br-lst-db AT ROW 5 COL 1 WIDGET-ID 100
     br-lst AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     "Поиск :" VIEW-AS TEXT
          SIZE 7.9 BY 1 AT ROW 3.17 COL 4
          BGCOLOR 8 FGCOLOR 0
     SPACE(87.29) SKIP(19.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "ВСЕ товары на ВСЕХ весах".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-lst:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ASSIGN
       br-lst-db:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo .
if available X_scales-gds THEN
run ref/cscalgds.w (
                      input parparentproc
                    , INPUT "":U
                    , INPUT "one":U
                    , OUTPUT  rid-list
                    , INPUT X_scales-gds.db-num
                    , input X_scales-gds.scales-num
                    , input X_scales-gds.plu-code
                    ).
if db-mode = "self" then do:
  apply "entry" to br-lst.
end.
else do:
  apply "entry" to br-lst-db.
end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  if available X_scales-gds then  do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( X_scales-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry12 = lookup( v-str-recid12 , rid-list )
.
if v-num-entry12 > 0 then do:
  assign
    entry( v-num-entry12, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid12
  .
end.
    if db-mode = "self" then do:
      glog = br-lst:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-lst:select-next-row ().
        apply "iteration-changed" to br-lst in frame Dialog-Frame.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame Dialog-Frame.
      else
          disp num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
      apply "entry" to br-lst in frame Dialog-Frame.
    end.
    else do:
      glog = br-lst-db:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-lst-db:select-next-row ().
        apply "iteration-changed" to br-lst-db in frame Dialog-Frame.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame Dialog-Frame.
      else
          disp num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
      apply "entry" to br-lst-db in frame Dialog-Frame.
    end.
  end.
END.
ON CHOOSE OF b-ticket IN FRAME Dialog-Frame
DO:
    if available X_scales-gds then  do:
      if rid-list = "" then
          run rep/tick-scl.p (
                         input parparentproc
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input recid( X_bar-code )
                        ,input X_scales-gds.db-num
                        ,input X_scales-gds.scales-num
                        ,input "" ) .
      else
          run rep/tick-scl.p (
                           input parparentproc
                          ,input p-obj-type
                          ,input p-obj-code
                          ,input ?
                          ,input ?
                          ,input ?
                          ,input rid-list ) .
      rid-list = "" .
      RUN OpenBr  in this-procedure .
    end.
  if db-mode = "self" then do:
    apply "entry" to br-lst in frame Dialog-Frame.
  end.
  else do:
    apply "entry" to br-lst-db in frame Dialog-Frame.
  end.
END.
ON INSERT OF br-lst IN FRAME Dialog-Frame
DO:
    apply "CHOOSE" to b-mark in frame Dialog-Frame .
END.
ON MOUSE-SELECT-DBLCLICK OF br-lst IN FRAME Dialog-Frame
DO:
 define variable v-gds-rec as recid no-undo .
    if available X_scales-gds then do:
      v-gds-rec = recid(X_goods).
      run ref/gds-form.w ( input parparentproc
                         , input 'ПРОСМОТР':U
                         , input X_scales-gds.obj-type
                         , input X_scales-gds.obj-code
                         , input this-procedure:handle
                         , input-output v-gds-rec).
    end.
    apply "entry" to br-lst in frame Dialog-Frame .
END.
ON RETURN OF br-lst IN FRAME Dialog-Frame
DO:
define variable v-gds-rec as recid no-undo .
    if available X_scales-gds then do:
      v-gds-rec = recid(X_goods).
      run ref/gds-form.w (
                           input parparentproc
                         , input 'ПРОСМОТР':U
                         , input X_scales-gds.obj-type
                         , input X_scales-gds.obj-code
                         , input this-procedure:handle
                         , input-output gds-rec).
    end.
    apply "entry" to br-lst in frame Dialog-Frame .
END.
ON INSERT OF br-lst-db IN FRAME Dialog-Frame
DO:
    apply "CHOOSE" to b-mark in frame Dialog-Frame .
END.
ON MOUSE-SELECT-DBLCLICK OF br-lst-db IN FRAME Dialog-Frame
DO:
 define variable v-gds-rec as recid no-undo .
    if available X_scales-gds then do:
      v-gds-rec = recid(ub.goods).
      run ref/gds-form.w ( input parparentproc
                         , input 'ПРОСМОТР':U
                         , input X_scales-gds.obj-type
                         , input X_scales-gds.obj-code
                         , input this-procedure:handle
                         , input-output v-gds-rec).
    end.
    apply "entry" to br-lst-db in frame Dialog-Frame .
END.
ON RETURN OF br-lst-db IN FRAME Dialog-Frame
DO:
define variable v-gds-rec as recid no-undo .
  if available X_scales-gds then do:
    v-gds-rec = recid(X_goods).
    run ref/gds-form.w (
                          input parparentproc
                        , input 'ПРОСМОТР':U
                        , input X_scales-gds.obj-type
                        , input X_scales-gds.obj-code
                        , input this-procedure:handle
                        , input-output gds-rec).
  end.
  apply "entry" to br-lst-db in frame Dialog-Frame .
END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on value-changed of a-n-c in frame Dialog-Frame do:
  case input frame Dialog-Frame a-n-c :
    when "art" then do:
     if db-mode = "self" then do:
      apply "entry" to br-lst in frame Dialog-Frame.
     end.
     else do:
       apply "entry" to br-lst-db in frame Dialog-Frame.
     end.
      hide loc-name loc-code in frame Dialog-Frame.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame Dialog-Frame.
      disp loc-name with frame Dialog-Frame.
      hide loc-art loc-code in frame Dialog-Frame.
      apply "entry" to loc-name in frame Dialog-Frame.
    end.
    when "code" then do:
      enable loc-code with frame Dialog-Frame.
      loc-code:label = "Бар-код (весь)".
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "ves" then do:
      enable loc-code with frame Dialog-Frame.
      loc-code:label = "Вес. код".
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "PLU" then do:
      enable loc-code with frame Dialog-Frame.
      loc-code:label = "PLU".
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "shtrih" then do:
      enable loc-code with frame Dialog-Frame.
      loc-code:label = "Штрих.код".
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
  end.
end.
on any-printable of br-lst in frame Dialog-Frame,
                    br-lst-db in frame Dialog-Frame
  do:
  if input frame Dialog-Frame a-n-c = "art" then do:
    if last-event:label = " " and loc-art = "" then return no-apply.
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK ,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods NO-LOCK WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins (loc-art + last-event:label),
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end.
    else do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK ,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods NO-LOCK WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins (loc-art + last-event:label),
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
          find  FIRST l-prod-bc-db no-lock WHERE
                l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
            and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
    if avail l-scales-gds then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame Dialog-Frame.
      line-rec = recid (l-scales-gds).
      if db-mode = "self" then do:
      reposition br-lst to recid line-rec no-error.
      end.
      else do:
        reposition br-lst-db to recid line-rec no-error.
      end.
    end.
    else do:
      bell.
    end.
  end.
end.
on backspace of br-lst in frame Dialog-Frame,
                br-lst-db in frame Dialog-Frame
do:
  if input frame Dialog-Frame a-n-c = "art" then do:
    if loc-art = "" then return no-apply.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins loc-art NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end.
    else do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins loc-art NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
        find  FIRST l-prod-bc-db no-lock WHERE
              l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
          and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
    display
    loc-art with frame Dialog-Frame.
    line-rec = recid (l-scales-gds).
    if db-mode = "self" then do:
    reposition br-lst to recid line-rec no-error.
    end.
    else do:
      reposition br-lst-db to recid line-rec no-error.
    end.
  end.
end.
ON MOUSE-SELECT-DBLCLICK, return OF loc-code IN FRAME Dialog-Frame do:
define variable str-code    as integer           no-undo.
define variable r-bar-code  like ub.bar-code.b-code no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
  assign loc-code a-n-c.
  case a-n-c:
    when "code" or when "shtrih"  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer l-bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
     if error-status:error then do:
       message "Ошибка при разборе бар-кода".
       return no-apply.
     end.
     IF AVAIl l-bar-code then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  l-bar-code.gds-code
  ,input  ?
  ,output r-bar-code
  ) no-error .
        if error-status:error then do:
           message "Бар-код не найден.".
          return no-apply.
        end.
        if db-mode = "self" then do:
          FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
              FIRST l-bar-code WHERE
                    l-bar-code.b-code = l-scales-gds.b-code AND
                    l-bar-code.b-code = integer (r-bar-code) NO-LOCK,
              FIRST l-gds-obj-attr WHERE
                    l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                    l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK,
              FIRST l-prod-bc WHERE
                    l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
              BY l-scales-gds.db-num
              BY l-scales-gds.scales-num
              BY l-scales-gds.plu-code:
              LEAVE.
         END.
       end.
       else do:
          FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
              FIRST l-bar-code WHERE
                    l-bar-code.b-code = l-scales-gds.b-code AND
                    l-bar-code.b-code = integer (r-bar-code) NO-LOCK,
              FIRST l-gds-obj-attr WHERE
                    l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                    l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK
              BY l-scales-gds.db-num
              BY l-scales-gds.scales-num
              BY l-scales-gds.plu-code:
          find  FIRST l-prod-bc-db no-lock WHERE
                l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
            and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
          if not available l-prod-bc-db then do:
            find first l-prod-bc no-lock where
                      l-prod-bc.b-code = l-bar-code.b-code
                  and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
            if not available l-prod-bc then next.
          end.
              LEAVE.
         END.
       end.
       if avail l-scales-gds then do:
         line-rec = recid (l-scales-gds).
         if db-mode = "self" then do:
         reposition br-lst to recid line-rec no-error.
         end.
         else do:
           reposition br-lst-db to recid line-rec no-error.
         end.
        end.
        else do:
          message "Строка не найдена.".
        end.
      end.
      else DO:
         message "Бар-код не найден.".
      end.
    end.
    when "ves" then do:
      if db-mode = "self" then do:
        FIND FIRST l-prod-bc WHERE l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK No-ERROR.
        IF AVAIl l-prod-bc then do:
            FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                            FIRST l-prod-bc WHERE
                                  l-prod-bc.b-code = l-scales-gds.b-code AND
                                  l-prod-bc.bc-on = TRUE AND
                                  l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK,
                            FIRST l-bar-code WHERE
                                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                            FIRST l-goods WHERE
                                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
                          BY l-scales-gds.db-num
                          BY l-scales-gds.scales-num
                          BY l-scales-gds.plu-code:
                LEAVE.
        END.
        if avail l-scales-gds then do:
            line-rec = recid (l-scales-gds).
            if db-mode = "self" then do:
            reposition br-lst to recid line-rec no-error.
            end.
            else do:
              reposition br-lst-db to recid line-rec no-error.
            end.
          end.
          else message "Строка не найдена.".
        end.
        else do:
          message "Весовой код не найден.".
        end.
      end.
      else do:
        FIND FIRST l-prod-bc-db WHERE
               l-prod-bc-db.b-str = string(integer(loc-code), "99999")
           and l-prod-bc-db.db-num = p-db-num  NO-LOCK No-ERROR.
        IF AVAIl l-prod-bc-db then do:
            FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                            FIRST l-prod-bc-db WHERE
                                  l-prod-bc-db.b-code = l-scales-gds.b-code AND
                                  l-prod-bc-db.bc-on = TRUE AND
                                  l-prod-bc-db.b-str = string(integer(loc-code), "99999")
                                  and l-prod-bc-db.db-num = l-scales-gds.db-num
                                  NO-LOCK,
                            FIRST l-bar-code WHERE
                                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                            FIRST l-goods WHERE
                                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
                          BY l-scales-gds.db-num
                          BY l-scales-gds.scales-num
                          BY l-scales-gds.plu-code:
                LEAVE.
          END.
          if avail l-scales-gds then do:
              line-rec = recid (l-scales-gds).
              if db-mode = "self" then do:
              reposition br-lst to recid line-rec no-error.
              end.
              else do:
                reposition br-lst-db to recid line-rec no-error.
              end.
          end.
          else do:
            message "Строка не найдена.".
          end.
        end.
        else do:
          find first l-prod-bc where
               l-prod-bc.b-str = string(integer(loc-code), "99999")  NO-LOCK No-ERROR.
          if available l-prod-bc then do:
            FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
            FIRST l-prod-bc WHERE
                  l-prod-bc.b-code = l-scales-gds.b-code AND
                  l-prod-bc.bc-on = TRUE AND
                  l-prod-bc.b-str = string(integer(loc-code), "99999")
                  NO-LOCK,
            FIRST l-bar-code WHERE
                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
            FIRST l-goods WHERE
                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
            BY l-scales-gds.db-num
            BY l-scales-gds.scales-num
            BY l-scales-gds.plu-code:
              LEAVE.
            END.
            if avail l-scales-gds then do:
                line-rec = recid (l-scales-gds).
                if db-mode = "self" then do:
                reposition br-lst to recid line-rec no-error.
                end.
                else do:
                  reposition br-lst-db to recid line-rec no-error.
                end.
            end.
          end.
          else do:
            message "Весовой код не найден.".
        end.
        end.
      end.
    end.
    when "PLU" then do:
      FIND FIRST l-scales-gds WHERE
               l-scales-gds.db-num = p-db-num
           AND l-scales-gds.plu-code = integer(loc-code) NO-LOCK No-ERROR.
     IF AVAIl l-scales-gds then do:
        line-rec = recid (l-scales-gds).
        if db-mode = "self" then do:
        reposition br-lst to recid line-rec no-error.
        end.
        else do:
          reposition br-lst-db to recid line-rec no-error.
        end.
     end.
     else message "PLU не найден.".
    end.
  end case.
  apply "entry" to loc-code in frame Dialog-Frame.
  return no-apply.
end.
ON MOUSE-SELECT-DBLCLICK, return, Ctrl-J OF loc-name IN FRAME Dialog-Frame do:
  assign loc-name.
  if last-event:label = "Ctrl-J" then do:
   if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE
              ((l-scales-gds.db-num = current-db-num AND  l-scales-gds.scales-num = current-scales AND l-scales-gds.b-code > current-b-code ) OR
                l-scales-gds.scales-num > current-scales)
                                                      NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
   end.
   else do:
      FOR EACH l-scales-gds WHERE
              ((l-scales-gds.db-num = current-db-num AND  l-scales-gds.scales-num = current-scales AND l-scales-gds.b-code > current-b-code ) OR
                l-scales-gds.scales-num > current-scales) NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK
      BY l-scales-gds.db-num
      BY l-scales-gds.scales-num
      BY l-scales-gds.plu-code:
       find FIRST l-prod-bc-db no-lock WHERE
            l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
        and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
        LEAVE.
      END.
   end.
  end.
  else do:
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end.
    else do:
      FOR EACH l-scales-gds WHERE l-scales-gds.db-num = p-db-num NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = 'scales-code':U No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
        find FIRST l-prod-bc-db no-lock WHERE
            l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
        and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
  end.
  if avail l-scales-gds then do:
    assign
    current-db-num = l-scales-gds.db-num
    current-plu = l-scales-gds.plu-code
    current-scales = l-scales-gds.scales-num
    current-b-code =l-scales-gds.b-code
    line-rec = recid (l-scales-gds).
    if db-mode = "self" then do:
    reposition br-lst to recid line-rec no-error.
    end.
    else do:
      reposition br-lst-db to recid line-rec no-error.
    end.
  end.
  else do:
       message "Строка не найдена.".
   end.
  apply "entry" to loc-name in frame Dialog-Frame.
  return no-apply.
end.
on iteration-changed of br-lst in frame Dialog-Frame,
                        br-lst-db in frame Dialog-Frame
do:
  if not avail X_scales-gds or recid (X_scales-gds) <> line-rec then do:
    hide loc-art in frame Dialog-Frame.
    loc-art = "".
  end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-lst :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run gds-recid.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input THIS-PROCEDURE:HANDLE
                      ,input-output gds-rec).
  apply "entry" to br-lst in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-lst :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = ?. if available X_scales-gds then v-doc-rec = recid(X_scales-gds). run openbr in this-procedure . if db-mode = 'self' then reposition br-lst to recid(v-doc-rec). else reposition br-lst-db to recid(v-doc-rec). v-doc-rec = ? .
    apply "VALUE-CHANGED" to br-lst.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-lst as INT EXTENT 17 no-undo.
DEF VAR varmvibr-lst       as INT no-undo.
DEF VAR varmvjbr-lst       as INT no-undo.
DEF VAR varmvkbr-lst       as INT no-undo.
DEF VAR varmvlbr-lst       as INT no-undo.
DEF VAR move-elementbr-lst as INT no-undo.
def var jjbr-lst           as int no-undo.
do varmvibr-lst = 1 to EXTENT(cur-clmn-numbr-lst):
  ASSIGN cur-clmn-numbr-lst[varmvibr-lst] = varmvibr-lst.
END.
RUN start-mv-clmnbr-lst.
PROCEDURE start-mv-clmnbr-lst:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-lst do:
  RUN re-move-clmnbr-lst ( 6, 17).
END.
ON ctrl-cursor-left OF BROWSE br-lst do:
  RUN re-move-clmnbr-lst (17, 6).
END.
PROCEDURE re-move-clmnbr-lst:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-lst = 1 TO EXTENT(cur-clmn-numbr-lst):
    if cur-clmn-numbr-lst[varmvibr-lst] = source-column THEN cur-clmn-numbr-lst[varmvibr-lst] = -1.
  END.
  if br-lst:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-lst = source-column - 1 to target-column BY -1:
    DO varmvibr-lst = 1 TO EXTENT(cur-clmn-numbr-lst):
        if cur-clmn-numbr-lst[varmvibr-lst] = varmvjbr-lst THEN DO:
          cur-clmn-numbr-lst[varmvibr-lst] = cur-clmn-numbr-lst[varmvibr-lst] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-lst = source-column + 1 to target-column:
    DO varmvibr-lst = 1 TO EXTENT(cur-clmn-numbr-lst):
      if cur-clmn-numbr-lst[varmvibr-lst] = varmvjbr-lst THEN DO:
        cur-clmn-numbr-lst[varmvibr-lst] = cur-clmn-numbr-lst[varmvibr-lst] - 1.
      END.
    END.
  END.
  DO varmvibr-lst = 1 TO EXTENT(cur-clmn-numbr-lst):
    if cur-clmn-numbr-lst[varmvibr-lst] = -1 THEN cur-clmn-numbr-lst[varmvibr-lst] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-lst:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 6 then do:
    return .
  end.
  DO varmvibr-lst = 1 TO EXTENT(cur-clmn-numbr-lst):
    if cur-clmn-numbr-lst[varmvibr-lst] = cur-clmn-loc THEN move-elementbr-lst = varmvibr-lst.
  END.
  RUN re-move-clmnbr-lst (cur-clmn-loc, 6).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-lst:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-lst = 6 to EXTENT(cur-clmn-numbr-lst):
    RUN re-move-clmnbr-lst (cur-clmn-numbr-lst[varmvlbr-lst], varmvlbr-lst).
  END.
  RUN start-mv-clmnbr-lst.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type22 as character no-undo.
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
  ,output varscales-pref-type22
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type22 as character no-undo.
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
  ,output varpgscales-pref-type22
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
    IF p-db-num = v-cntxt-db-num THEN DO:
      db-mode = "self".
    END.
    ELSE DO:
       db-mode = "0".
    END.
    RUN Myenable in this-procedure .
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY a-n-c loc-art loc-name loc-code mark-num
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OUT b-mark b-ticket b-hist b-help a-n-c loc-art loc-name loc-code
         br-lst-db br-lst mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-lst FOR EACH X_scales-gds NO-LOCK,              EACH X_bar-code OF X_scales-gds NO-LOCK,              EACH X_goods OF X_bar-code NO-LOCK,              EACH X_gds-obj-attr OF X_goods NO-LOCK,              EACH X_prod-bc OF X_bar-code NO-LOCK     BY X_scales-gds.b-code      BY X_scales-gds.scales-num.    OPEN QUERY br-lst-db FOR EACH X_scales-gds NO-LOCK,              EACH X_bar-code OF X_scales-gds NO-LOCK,              EACH X_goods OF X_bar-code NO-LOCK,              EACH X_gds-obj-attr OF X_goods NO-LOCK,              EACH X_prod-bc-db OF X_bar-code NO-LOCK OUTER-JOIN     BY X_scales-gds.b-code      BY X_scales-gds.scales-num.
END PROCEDURE.
PROCEDURE gds-recid :
DEFINE variable glog as logical no-undo .
if available X_goods then do:
  gds-rec = recid(X_goods).
end.
else do:
  gds-rec = ?.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-mark
b-ticket
b-help
b-hist
Btn_OUT
br-lst  when db-mode = "self"
br-lst-db  when db-mode = "0"
mark-num
a-n-c
WITH FRAME Dialog-Frame.
hide
loc-art in frame Dialog-Frame
loc-name loc-code in frame Dialog-Frame
mark-num in frame Dialog-Frame.
if db-mode = "self" then do:
  hide
  br-lst-db
  in frame Dialog-Frame .
end.
else do:
  hide
  br-lst
  in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame.
run Openbr IN THIS-PROCEDURE.
Assign frame Dialog-Frame:title = substitute("&1 БД &2", frame Dialog-Frame:title, p-db-num).
if v-cntxt-db-num <> p-db-num then do:
  disable
  b-ticket
  with frame Dialog-Frame .
end.
if db-mode = "self" then do:
apply "entry" to br-lst in frame Dialog-Frame .
assign
glog = br-lst:select-row( 1 )
glog = br-lst:scroll-to-selected-row( 1 ) .
end.
else do:
  apply "entry" to br-lst-db in frame Dialog-Frame .
  assign
  glog = br-lst-db:select-row( 1 )
  glog = br-lst-db:scroll-to-selected-row( 1 ) .
end.
END PROCEDURE.
PROCEDURE OpenBr :
define variable glog as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите..." ).
if db-mode = "self" then do:
  OPEN QUERY br-lst
  FOR EACH X_scales-gds NO-LOCK where X_scales-gds.db-num = p-db-num,
    FIRST X_bar-code WHERE
          X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
    FIRST X_goods WHERE
          X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
    FIRST X_gds-obj-attr WHERE
          X_gds-obj-attr.gds-code = X_bar-code.gds-code AND
          X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND
          X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND
          X_gds-obj-attr.attr-code = 'scales-code':U NO-LOCK,
    FIRST X_prod-bc WHERE
          X_prod-bc.b-str = X_gds-obj-attr.attr-value NO-LOCK
            BY X_scales-gds.b-code
            BY X_scales-gds.scales-num.
  if num-entries( rid-list ) = 0 then
      HIDE mark-num in frame Dialog-Frame.
  else
      DISPLAY num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
  apply "entry" to br-lst in frame Dialog-Frame .
  if num-results( "br-lst" ) > 0 then
      assign
          glog = br-lst:select-row( 1 )
          glog = br-lst:scroll-to-selected-row( 1 ) .
end.
else do:
  OPEN QUERY br-lst-db
  FOR EACH X_scales-gds NO-LOCK where X_scales-gds.db-num = p-db-num,
    FIRST X_bar-code WHERE
          X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
    FIRST X_goods WHERE
          X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
    FIRST X_gds-obj-attr WHERE
          X_gds-obj-attr.gds-code = X_bar-code.gds-code AND
          X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND
          X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND
          X_gds-obj-attr.attr-code = 'scales-code':U NO-LOCK,
    FIRST X_prod-bc-db no-lock WHERE
          X_prod-bc-db.b-str = X_gds-obj-attr.attr-value
     and  X_prod-bc-db.db-num = p-db-num OUTER-JOIN
            BY X_scales-gds.b-code
            BY X_scales-gds.scales-num.
  if num-entries( rid-list ) = 0 then
      HIDE mark-num in frame Dialog-Frame.
  else
      DISPLAY num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
  apply "entry" to br-lst-db in frame Dialog-Frame .
  if num-results( "br-lst-db" ) > 0 then
      assign
          glog = br-lst-db:select-row( 1 )
          glog = br-lst-db:scroll-to-selected-row( 1 ) .
end.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
case db-mode:
  when "self" then do:
    case p-direction :
      when "first":U
      then do:
        get first br-lst.
      end.
      when "last":U
      then do:
        get last br-lst.
      end.
      when "prev":U
      then do:
        get prev br-lst.
        if not available X_scales-gds then do:
          message
          "Это первый товар списка"
          view-as alert-box.
        end.
      end.
      when "next":U
      then do:
        get next br-lst.
        if not available X_scales-gds then do:
          message
          "Это последний товар списка"
          view-as alert-box.
        end.
      end.
    end case .
  end.
  otherwise  do:
    case p-direction :
      when "first":U
      then do:
        get first br-lst-db.
      end.
      when "last":U
      then do:
        get last br-lst-db.
      end.
      when "prev":U
      then do:
        get prev br-lst-db.
        if not available X_scales-gds then do:
          message
          "Это первый товар списка"
          view-as alert-box.
        end.
      end.
      when "next":U
      then do:
        get next br-lst-db.
        if not available X_scales-gds then do:
          message
          "Это последний товар списка"
          view-as alert-box.
        end.
      end.
    end case .
  end.
end case.
assign
p-recid = recid(X_goods)
.
if db-mode = "self" then do:
  run reposition-query in this-procedure
    (input recid(X_scales-gds)
    ).
end.
else do:
  run reposition-query-db in this-procedure
    (input recid(X_scales-gds)
    ).
end.
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
if p-recid <> ?
then do:
  reposition br-lst to recid p-recid no-error.
end.
do with frame Dialog-Frame:
  apply "entry":u to browse br-lst .
  apply "VALUE-CHANGED":u to browse br-lst .
end.
END PROCEDURE.
PROCEDURE reposition-query-db :
define input parameter p-recid as recid no-undo .
if p-recid <> ?
then do:
  reposition br-lst-db to recid p-recid no-error.
end.
do with frame Dialog-Frame:
  apply "entry":u to browse br-lst .
  apply "VALUE-CHANGED":u to browse br-lst .
end.
END PROCEDURE.
FUNCTION get-scl-code RETURNS CHARACTER
  (    INPUT p-b-code AS INTEGER
     , INPUT p-b-str AS CHARACTER
     , BUFFER buf_prod-bc-db FOR ub.prod-bc-db ) :
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
IF AVAILABLE buf_prod-bc-db  THEN RETURN buf_prod-bc-db.b-str.
FIND FIRST buf_prod-bc NO-LOCK WHERE buf_prod-bc.b-code = p-b-code AND buf_prod-bc.b-str = p-b-str NO-ERROR.
IF AVAILABLE buf_prod-bc  THEN RETURN p-b-str.
RETURN chr(63).
END FUNCTION.
