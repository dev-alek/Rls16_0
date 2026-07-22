define input  parameter parparentproc   as widget-handle no-undo.
define input  parameter r-tmp           as recid     no-undo.
define input  parameter line-mode       as character no-undo .
define output parameter stp-cycle       as logical   no-undo.
define output parameter stp-exit        as logical   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма корректировки строки заказа" .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
define variable g#host-name       as character no-undo .
define variable g#host-code       as integer   no-undo .
define variable store-type        as character no-undo .
define variable store-code        as integer   no-undo .
define variable base-code         as integer   no-undo .
define variable g#report-num      as integer   no-undo .
define variable g#mainmenu-handle as handle    no-undo .
define variable g#log             as logical   no-undo .
define variable g#type            as character no-undo .
define variable loc-cli-base-rate as decimal   no-undo .
define variable is-edoc-nn        as logical   no-undo .
define variable is-edi            as logical   no-undo .
define variable par-is-edoc-nn    as character no-undo .
define variable par-is-edi        as character no-undo .
define variable is-edoc-nn-doc    as logical   no-undo .
define variable is-edi-doc        as logical   no-undo .
define variable v-dm-edi          as integer   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
g#mainmenu-handle = PARPARENTPROC .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output base-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define  shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define  shared buffer buf-goods   for ub.goods     .
define  shared buffer sb-cli-gds  for ub.cli-gds   .
define  shared buffer sb-gds-obj  for ub.gds-obj   .
define  shared buffer tmp#zakaz     for tmp#zakaz1.
define  shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define  shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define  shared  buffer shar_ord-doc  for ub.ord-doc .
define  shared  buffer shar_ord-line for ub.ord-line.
define  shared  buffer shar_ord-dtl  for ub.ord-dtl .
define  shared variable chexcelapplication      as com-handle no-undo .
define  shared variable chworkbook              as com-handle no-undo .
define  shared variable chworksheet             as com-handle no-undo .
define  shared variable chrange                 as com-handle no-undo .
define  shared variable chworksheet2            as com-handle no-undo .
define  shared variable chworksheet3            as com-handle no-undo .
define  shared variable accum-zakaz             as decimal no-undo .
define  shared variable accum-sum-zakaz         as decimal no-undo .
define  shared variable accum-count             as integer no-undo .
define  shared buffer buf-cli for ub.clients.
define  shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define  shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define  shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define    shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define    shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define    shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define    shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define    shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define    shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define    shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define   shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define   shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define  shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define    shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define  shared variable loc-status  as character  no-undo.
define  shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define  shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define  shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define  shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define  shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define  shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define  shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define  shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define  shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define  shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define  shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define  shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define  shared var loc-print-rubl as logical no-undo .
define  shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define    shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define  shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define  shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define  shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define  shared  variable temp-e-method  as character no-undo .
define  shared  variable x-tog-artic as logical   no-undo .
define  shared  variable x-tog-grp    as logical   no-undo .
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable   custvalue     as character initial ? no-undo.
define variable   custtype      as character initial ? no-undo.
define variable   prtvalue      as character initial ? no-undo.
define variable   prttype       as character initial ? no-undo.
define variable   partsvalue    as character initial ? no-undo.
define variable   partstype     as character initial ? no-undo.
define variable   vat-sumvalue  as character initial ? no-undo.
define variable   vat-sumtype   as character initial ? no-undo.
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   exctaxcdvalue as character initial ? no-undo.
define variable   vattaxcdvalue as character initial ? no-undo.
define variable   measfactvalue as character initial ? no-undo.
define variable   measfacttype  as character initial ? no-undo.
define variable   temp-mes      as character initial ? no-undo.
define variable   varroad-tax-label as character no-undo.
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable   dops          as character           no-undo format "X(250)".
define variable   dopst         as character           no-undo format "X(1)".
define variable   dop-slt       as character           no-undo format "X(250)".
define variable   dop-slt-st    as character           no-undo format "X(1)".
define variable   sum-vat       like ub.ord-line.sum-vat format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
define variable   varrvs-place        as   logical       no-undo.
define variable   var-code-temp like ub.place.pl-code no-undo.
define variable   rvs-recid     as recid           no-undo.
define variable   road-tax-cli  like ub.doc-line.road-tax initial 0 no-undo.
define variable   parprice-sale like ub.price-list.price-sale no-undo.
define var  pargds-code            like ub.goods.gds-code        no-undo.
define var  parobj-type            like ub.clients.obj-type      no-undo.
define var  parobj-code            like ub.clients.obj-code      no-undo.
define var  parext-gds-type        as   character      initial ? no-undo.
define var  parcli-qnty-input      as   logical        initial ? no-undo.
define var  pardensity-input       as   logical        initial ? no-undo.
define var  parcli-base-rate-input as   logical        initial ? no-undo.
define var  pardoc-qnty-input      as   logical        initial ? no-undo.
define var  parfact-qnty-input     as   logical        initial ? no-undo.
define var  parprice-cli-input     as   logical        initial ? no-undo.
define var  parbase-price-input    as   logical        initial ? no-undo.
define var  parbase-price-my       as   logical        initial ? no-undo.
define var  partax-3-input         as   logical        initial ? no-undo.
define var  parcli-qnty-calc       as   character      initial ? no-undo.
define var  pardensity-calc        as   character      initial ? no-undo.
define var  parcli-base-rate-calc  as   character      initial ? no-undo.
define var  pardoc-qnty-calc       as   character      initial ? no-undo.
define var  parfact-qnty-calc      as   character      initial ? no-undo.
define var  parprice-cli-calc      as   character      initial ? no-undo.
define var  parbase-price-calc     as   character      initial ? no-undo.
define var  partax-3-calc          as   character      initial ? no-undo.
define var  parround               as   integer        initial ? no-undo.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
function rvs-qnty returns decimal
( input p-gds-code as integer    ,
  input p-pl-code as integer  ) .
   for each ub.rvs-line no-lock  WHERE
            ub.rvs-line.gds-code = p-gds-code and
            ub.rvs-line.pl-code = ub.place.pl-code ,
      first ub.rvs-doc no-lock where
            ub.rvs-doc.rvs-code = ub.rvs-line.rvs-code and
            ub.rvs-doc.status_ = 'факт':U
            break
            by ub.rvs-doc.fact-order desc :
         return ub.rvs-line.state-measure-qnty .
    end.
    return 0 .
end function.
define variable   t-action    as      char no-undo.
define buffer     b-ord-line  for     tmp#zakaz .
define buffer     i-ord-doc   for     ub.ord-doc   .
define variable   kk          like    ub.ord-line.cli-base-rate no-undo .
define temp-table tt-ord-line no-undo like tmp#zakaz .
define buffer buf_gds-obj for ub.gds-obj  .
define variable var-report-r-b as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable v-fact-cli-qnty as character format "x(15)" no-undo .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1 TOOLTIP "Выход без сохранения"
     BGCOLOR 8 .
DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1 TOOLTIP "Выход с сохранением исправлений"
     BGCOLOR 8 .
DEFINE BUTTON B-prt
     LABEL "&Шкала"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-qnty
     LABEL "Про&чее"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-units"
     SIZE 3 BY .88 TOOLTIP "Выбор единицы измерения".
DEFINE VARIABLE abbr-base AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE abbr-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 4 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE abbr-rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE N-1 AS decimal FORMAT  "->>>>>>>>9.999":U INITIAL 0
      LABEL "Макс.кол!(баз.ед.изм)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE N-2 AS  decimal FORMAT  "->>>>>>>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-PETROL FOR
      obj-list,
      ub.place,
      ub.pl-gds SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tmp#zakaz,
      ub.goods,
      ub.gds-prt,
      ub.clients SCROLLING.
DEFINE BROWSE BR-PETROL
  QUERY BR-PETROL NO-LOCK DISPLAY
      ub.place.pl-code COLUMN-LABEL "Код места!хранения"
      ub.place.pl-name FORMAT "X(20)"
      ub.place.max-qnty format "->>>>>>>>>>9.999":U  column-LABEL "Макс.кол!(баз.ед.изм)"
      rvs-qnty ( ub.goods.gds-code , ub.place.pl-code) format "->>>>>>>>>>9.999":U   column-LABEL "Факт остаток по!последней сверке"
      ub.place.obj-type + " " + string( ub.place.obj-code) COLUMN-LABEL "Объект"     FORMAT "X(10)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 77 BY 6
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1.25
     B-Cancel AT ROW 1 COL 13.25
     b-exit-cycl AT ROW 1 COL 25.25
     B-qnty AT ROW 1 COL 56.25
     B-prt AT ROW 1 COL 68.25
     B-Help AT ROW 1 COL 80.25
     tmp#zakaz.cli-art AT ROW 3.75 COL 21.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          format "x(16)"
     r-units AT ROW 6.08 COL 38.75
     tmp#zakaz.cli-qnty AT ROW 6.13 COL 11.25 COLON-ALIGNED
          LABEL "По пост."
          VIEW-AS FILL-IN
          SIZE 17.75 BY 1 TOOLTIP "Количество в ед.изм. поставщика"
          format ">,>>>,>>>,>>9.<<<"
     tmp#zakaz.unit-cli AT ROW 6.13 COL 29.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tmp#zakaz.cli-base-rate AT ROW 7.08 COL 39.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.25 BY 1
     tmp#zakaz.qnty AT ROW 7.08 COL 11.25 COLON-ALIGNED
          format ">,>>>,>>>,>>9.<<<"
          LABEL "По док-ту"
          VIEW-AS FILL-IN
          SIZE 17.75 BY 1 TOOLTIP "Количество в базовых ед.изм."
     tot-cli AT ROW 9.25 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-cli AT ROW 9.54 COL 11.25 COLON-ALIGNED
          LABEL "По пост."
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     tmp#zakaz.order-cli-qnty AT ROW 6.13 COL 41.75
          LABEL "Было запрошено"
          VIEW-AS TEXT
          SIZE 6.5 BY 0.7
      tmp#zakaz.ord-dec1      AT ROW 9.54 COL 70
          LABEL "Запрошена цена"
          VIEW-AS TEXT
          SIZE 15 BY 0.7
     tmp#zakaz.VAT-pc AT ROW 10.54 COL 74 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1 TOOLTIP "Процент НДС"
     tmp#zakaz.v-vat AT ROW 10.54 COL 83
          VIEW-AS TOGGLE-BOX
          SIZE 2 BY 1 TOOLTIP "Направление расчета НДС"
     tmp#zakaz.sum-VAT AT ROW 10.54 COL 83 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12 BY 1 TOOLTIP "Сумма НДС"
     tmp#zakaz.SLT-pc AT ROW 11.54 COL 74 COLON-ALIGNED
          LABEL "НсП"
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1 TOOLTIP "Процент НсП"
     tmp#zakaz.sum-SLT AT ROW 11.54 COL 83 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY 1 TOOLTIP "Сумма НсП"
     tot-rubl AT ROW 10.38 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-base AT ROW 10.54 COL 11.25 COLON-ALIGNED
          format ">>>>>>>>>9.99<<<<<"
          LABEL "Учет."
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tot-base AT ROW 11.5 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-rubl AT ROW 11.54 COL 11.25 COLON-ALIGNED
          format ">>>>>>>>>9.99<<<<<"
          LABEL "Учет."
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     tmp#zakaz.line-num AT ROW 13.75 COL 47 COLON-ALIGNED
          LABEL "N п/п"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tmp#zakaz.cancel-date AT ROW 13.75 COL 79 COLON-ALIGNED FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата прекращения поставок товара"
     tmp#zakaz.road-tax AT ROW 14.71 COL 16.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tmp#zakaz.excise AT ROW 16.88 COL 16.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tmp#zakaz.transport-base AT ROW 19.17 COL 27.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.other-base AT ROW 19.17 COL 66.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.transport-rubl AT ROW 20.17 COL 27.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.other-rubl AT ROW 20.17 COL 66.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.artic AT ROW 2.17 COL 21.25 COLON-ALIGNED
          LABEL "Артикул"
           VIEW-AS TEXT
          SIZE 17 BY .67
     ub.goods.gds-name AT ROW 2.17 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 51.25 BY .67
          FGCOLOR 4
.
DEFINE FRAME Dialog-Frame
     tmp#zakaz.prod-type AT ROW 2.92 COL 31.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY .67
     ub.clients.obj-name AT ROW 2.92 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 49.75 BY .67
          FGCOLOR 4
     tmp#zakaz.prod-code AT ROW 2.96 COL 21.25 COLON-ALIGNED
          LABEL "Производитель"
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.goods.qnty-cart AT ROW 3.83 COL 78 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     ub.goods.wt-cart AT ROW 4.58 COL 78 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 12 BY .67
     ub.goods.unit-base AT ROW 7.13 COL 30 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.25 BY 1
     abbr-cli AT ROW 9.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-cli AT ROW 9.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     abbr-base AT ROW 10.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-base AT ROW 10.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     abbr-rubl AT ROW 11.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-rubl AT ROW 11.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     ub.gds-prt.node-name AT ROW 13 COL 70 COLON-ALIGNED NO-LABEL FORMAT "x(20)"
           VIEW-AS TEXT
          SIZE 20 BY .67
          FGCOLOR 1
     buf_gds-obj.fact-qnty AT ROW 15 COL 72 COLON-ALIGNED LABEL "Факт.кол-во(остатки)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     v-fact-cli-qnty AT ROW 16 COL 72 COLON-ALIGNED LABEL "Факт.кол-во(ед.пост.)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     buf_gds-obj.free-qnty AT ROW 17 COL 72 COLON-ALIGNED LABEL "Свободно"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     buf_gds-obj.avrg-qnty AT ROW 18 COL 72 COLON-ALIGNED LABEL "Положительные партии"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tmp#zakaz.sub-par AT ROW 18 COL 2 LABEL "Примечание"
          view-as editor scrollbar-vertical
          size 38 by 3
     tmp#zakaz.sum-road-tax AT ROW 15.71 COL 16.75 COLON-ALIGNED
          LABEL "Сумма 3 налога"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
          tooltip "Третья компонента налога"
     tmp#zakaz.sum-excise AT ROW 17 COL 16.75 COLON-ALIGNED
          LABEL "Сумма акциза"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     tmp#zakaz.sum-transport-base AT ROW 21.17 COL 27.38 COLON-ALIGNED
          LABEL "Сумма тр.налога (баз)"
           VIEW-AS TEXT
          SIZE 18.38 BY 0.7
     tmp#zakaz.sum-other-base AT ROW 21.17 COL 66.63 COLON-ALIGNED
          LABEL "Сумма др.налогов (баз)"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     tmp#zakaz.sum-transport-rubl AT ROW 22.17 COL 27.38 COLON-ALIGNED
          LABEL "Сумма тр.налога (руб)"
           VIEW-AS TEXT
          SIZE 18.25 BY 0.7
     tmp#zakaz.sum-other-rubl AT ROW 22.17 COL 66.63 COLON-ALIGNED
          LABEL "Сумма др.налогов (руб)"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     "Количество        Ед. изм.  Коэффициент" VIEW-AS TEXT
          SIZE 40.75 BY 1 AT ROW 4.92 COL 13.25
          BGCOLOR 3 FGCOLOR 15
     "Цена               Сумма                       Вал." VIEW-AS TEXT
          SIZE 56.13 BY 1 AT ROW 8.42 COL 13.38
          BGCOLOR 3 FGCOLOR 15
     SPACE(23.73) SKIP(13.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение строки заказа"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.
DEFINE FRAME FRAME-petrol
     BR-PETROL AT ROW 1 COL 1
     N-1 AT ROW 7 COL 30 COLON-ALIGNED no-label
     N-2 AT ROW 7 COL 47 COLON-ALIGNED NO-LABEL
     "Итого:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7 COL 1
          FGCOLOR 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 14.75
         SIZE 92 BY 8.5
         TITLE "Бензин".
ASSIGN FRAME FRAME-petrol:FRAME = FRAME Dialog-Frame:HANDLE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tot-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tot-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tot-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FRAME FRAME-petrol:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
  stp-cycle  =  false.
  stp-exit  =  false.
  run ver-value in this-procedure no-error.
  if error-status:error then do:
     return no-apply.
  end.
  if  tmp#zakaz.order-cli-qnty = tmp#zakaz.cli-qnty and tmp#zakaz.cli-qnty <> 0
  then do:
      message "Нельзя отправлять заказ на коррекцию с тем же количеством, которое было запрошено первоначально!" view-as alert-box .
      return no-apply.
  end.
  buffer-copy b-ord-line to shar_ord-line
     assign shar_ord-line.doc-code = loc-ord-num
     no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "BC"
    view-as alert-box error
  .
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
if line-mode = 'ПРОСМОТР':U then do:
    stp-cycle  =  false.
    stp-exit  =  true .
    return.
end.
define variable compare-log as logical no-undo .
if line-mode <> "ЦИКЛ":u   then do:
    BUFFER-COMPARE  tt-ord-line to tmp#zakaz save result in compare-log no-error.
    if compare-log = false then do:
        message "Вы действительно хотите выйти без сохранения изменений ?" view-as alert-box question
                buttons yes-no   update jjj as logical .
                if jjj = true then do:
                     BUFFER-COPY tt-ord-line to  tmp#zakaz .
                end.
                else do:
                  return no-apply .
                end.
    end.
end.
  stp-cycle  =  false.
  stp-exit  =  true .
  return "error".
END.
ON CHOOSE OF b-exit-cycl IN FRAME Dialog-Frame
DO:
  assign
     stp-cycle  =  true
     stp-exit   =  false.
     .
END.
ON CHOOSE OF B-prt IN FRAME Dialog-Frame
DO:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find current TMP#zakaz no-lock no-error  .
  if error-status :error or  not avail TMP#zakaz   then do:
       message "Не выбрана строка заказа" .
       return.
       end.
  find first ub.goods no-lock where ub.goods.prod-type = tmp#zakaz.prod-type and
                                 ub.goods.prod-code = tmp#zakaz.prod-code and
                                 ub.goods.artic     = tmp#zakaz.artic   no-error.
      run cus/ord-p.p
      ( parParentProc
      , ?
      , recid(TMP#zakaz)
      , recid(goods)
      , (If t-action = "lkp":U then  'ПРОСМОТР':U  else 'ШКАЛА':U )
      , input TMP#zakaz.qnty
      , input TMP#zakaz.cli-qnty
      ) .
END.
ON CHOOSE OF B-qnty IN FRAME Dialog-Frame
DO:
  MESSAGE "Режим отключен" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF r-units IN FRAME Dialog-Frame
DO:
define variable ref-rec as recid no-undo.
  define buffer bf-r-units for ub.units.
  run ref/units.w ( parparentproc, yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find bf-r-units where recid (bf-r-units) = ref-rec no-lock.
  ASSIGN tmp#zakaz.unit-cli  = bf-r-units.unit-name.
  release bf-r-units.
  display tmp#zakaz.unit-cli with frame Dialog-Frame.
  apply "entry" to tmp#zakaz.cli-base-rate.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
assign
  tmp#zakaz.sum-transport-rubl :label = "Сумма тр.налога (руб)"
  tmp#zakaz.sum-other-rubl     :label = "Сумма др.налогов (руб)"
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'edoc-nn'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edoc-nn
  ,output par-type
  ) no-error .
if error-status :error then is-edoc-nn = false .
assign
  is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edi
  ,output par-type
  ) no-error .
if error-status :error then is-edi = false .
assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
.
run edoc-nn-proc in this-procedure .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON LEAVE OF tmp#zakaz.cli-qnty IN FRAME Dialog-Frame
DO:
define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.
IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-cli
                    and LOOKUP('шту':U, ub.units.type) > 0 )  AND
   TRUNC(input frame Dialog-Frame tmp#zakaz.cli-qnty, 0)
   <>    input frame Dialog-Frame tmp#zakaz.cli-qnty
   THEN DO:
      MESSAGE "Единица изм поставщика " ub.goods.unit-cli " - штучная." skip
              "Кол-во должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN NO-APPLY.
  END.
if ub.goods.qnty-cart <> 0 then do:
  if input frame Dialog-Frame tmp#zakaz.cli-qnty / ub.goods.qnty-cart -
  truncate ( input frame Dialog-Frame tmp#zakaz.cli-qnty / ub.goods.qnty-cart , 0 ) <> 0 then do:
      g#log = yes.
      message "Товар рекомендуется выписывать упаковками." skip (2)
              "Округлить до целого числа упаковок ?"
               view-as alert-box question buttons yes-no update g#log .
      if g#log then do:
        if round (input frame Dialog-Frame tmp#zakaz.cli-qnty / ub.goods.qnty-cart, 0) = 0 then do:
          display
              ub.goods.qnty-cart @ tmp#zakaz.cli-qnty
              with frame Dialog-Frame.
        end.
        else do:
          display
            round ( input frame Dialog-Frame tmp#zakaz.cli-qnty / ub.goods.qnty-cart, 0) * ub.goods.qnty-cart @ tmp#zakaz.cli-qnty
            with frame Dialog-Frame.
        end.
      end.
  end.
end.
 if tmp#zakaz.cli-base-rate:sensitive in frame dialog-frame then do:
    assign
      KK = input frame Dialog-Frame tmp#zakaz.cli-base-rate
      tmp#zakaz.cli-base-rate = input frame Dialog-Frame tmp#zakaz.cli-base-rate.
    .
    end.
 else do:
    if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
    kk = ub.goods.cli-base-rate.
    else KK = b-ord-line.cli-base-rate.
  end.
  if lookup('cli-base-rate',parcli-qnty-calc) = 0 then do:
  assign
    tot-cli = input frame Dialog-Frame tmp#zakaz.price-cli * input frame Dialog-Frame tmp#zakaz.cli-qnty
    tmp#zakaz.qnty = ( input frame Dialog-Frame tmp#zakaz.cli-qnty ) * kk .
    DISPLAY  tot-cli tmp#zakaz.qnty   WITH FRAME Dialog-Frame.
       tmp#zakaz.cli-base-rate = kk .
       DISPLAY   tmp#zakaz.cli-base-rate WITH FRAME Dialog-Frame.
  apply "leave" to tmp#zakaz.qnty .
  DISPLAY  tot-cli tmp#zakaz.qnty WITH FRAME Dialog-Frame.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF tmp#zakaz.qnty IN FRAME Dialog-Frame
DO:
  define variable t-sum like tmp#zakaz.qnty no-undo .
  t-sum = 0.
  for each tmp#zakaz-dtl where
      tmp#zakaz-dtl.artic     = tmp#zakaz.artic and
      tmp#zakaz-dtl.prod-type = tmp#zakaz.prod-type and
      tmp#zakaz-dtl.prod-code = tmp#zakaz.prod-code  :
      t-sum = t-sum + tmp#zakaz-dtl.qnty.
   end.
   if t-sum > tmp#zakaz.qnty then do:
      MESSAGE "Количество по признакам больше чем по строке товара ! " skip t-sum
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      return no-apply.
   end.
 IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base
                    and LOOKUP('шту':U, ub.units.type) > 0)  AND
   TRUNC(input frame Dialog-Frame tmp#zakaz.qnty, 0)
   <>    input frame Dialog-Frame tmp#zakaz.qnty
   THEN DO:
      MESSAGE "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.
 if pardoc-qnty-input = true then do:
    if lookup('cli-base-rate',parcli-qnty-calc) > 0 then do:
     assign
        kk = (input frame Dialog-Frame tmp#zakaz.qnty) / (input frame Dialog-Frame tmp#zakaz.cli-qnty )
     .
     if kk  = ? then kk = 1.
     b-ord-line.cli-base-rate = kk  .
    end.
    else do:
        if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
          kk = ub.goods.cli-base-rate .
          else KK = b-ord-line.cli-base-rate .
        assign
            tmp#zakaz.cli-qnty = input frame Dialog-Frame tmp#zakaz.qnty / kk
            tot-cli = input frame Dialog-Frame tmp#zakaz.price-cli * input frame Dialog-Frame tmp#zakaz.cli-qnty
            .
            DISPLAY  tot-cli tmp#zakaz.cli-qnty   WITH FRAME Dialog-Frame.
                tmp#zakaz.cli-base-rate = kk .
                DISPLAY   tmp#zakaz.cli-base-rate WITH FRAME Dialog-Frame.
       end.
  run ass-var in this-procedure .
  end.
END.
ON LEAVE OF tmp#zakaz.price-base IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tmp#zakaz.price-base > 5000 and base-code = 1 then
  message "Внимание !!!" skip (2)
                  "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
                  "Вы не ошиблись ?".
if tmp#zakaz.price-base <> input frame Dialog-Frame tmp#zakaz.price-base then
  assign
    tmp#zakaz.price-rubl = input frame Dialog-Frame tmp#zakaz.price-base * loc-base-rate / loc-base-scale
    tmp#zakaz.price-cli  = tmp#zakaz.price-rubl / loc-exch-rate * loc-exch-scale *
    tmp#zakaz.cli-base-rate
    .
    DISPLAY
    tmp#zakaz.price-RUBL
    tmp#zakaz.price-cli
    WITH FRAME Dialog-Frame .
 run ass-var in this-procedure  .
END.
ON LEAVE OF tmp#zakaz.price-rubl IN FRAME Dialog-Frame
DO:
if tmp#zakaz.price-rubl <> input frame Dialog-Frame tmp#zakaz.price-rubl then
  assign
    tmp#zakaz.price-base = input frame Dialog-Frame tmp#zakaz.price-rubl / loc-base-rate * loc-base-scale
    tmp#zakaz.price-cli  = input frame Dialog-Frame tmp#zakaz.price-rubl / loc-exch-rate * loc-exch-scale /
    tmp#zakaz.cli-base-rate
    .
    DISPLAY
    tmp#zakaz.price-base
    tmp#zakaz.price-cli
    WITH FRAME Dialog-Frame .
    run ass-var in this-procedure .
END.
ON LEAVE OF tmp#zakaz.price-cli IN FRAME Dialog-Frame
DO:
if tmp#zakaz.price-cli <> input frame Dialog-Frame tmp#zakaz.price-cli then
  assign
    tot-cli = input frame Dialog-Frame tmp#zakaz.price-cli *  input frame Dialog-Frame tmp#zakaz.cli-qnty
    .
 run ass-var in this-procedure .
END.
ON LEAVE OF tmp#zakaz.cli-base-rate IN FRAME Dialog-Frame
DO:
  run proc-c-b-r in this-procedure .
END.
procedure proc-c-b-r:
 assign frame Dialog-Frame  tmp#zakaz.cli-base-rate.
 if lookup ("doc-qnty", parcli-base-rate-calc) > 0 then do:
    apply "leave" to tmp#zakaz.cli-qnty in frame Dialog-Frame .
    end.
 if lookup ("cli-qnty", parcli-base-rate-calc) > 0 then do:
    apply "leave" to tmp#zakaz.qnty in frame Dialog-Frame .
    end.
 run ass-var in this-procedure .
END procedure.
ON LEAVE OF tmp#zakaz.excise ,
            tmp#zakaz.other-base ,
            tmp#zakaz.other-rubl,
            tmp#zakaz.road-tax ,
            tmp#zakaz.transport-base ,
            tmp#zakaz.transport-rubl ,
            tmp#zakaz.sum-vat
            IN FRAME Dialog-Frame
do:
  run ass-var in this-procedure .
end.
on leave of tmp#zakaz.sum-vat in frame Dialog-Frame do:
   if input frame Dialog-Frame tmp#zakaz.sum-vat <> tmp#zakaz.sum-vat then do:
     if input frame Dialog-Frame tmp#zakaz.price-cli <> 0 and
        input frame Dialog-Frame tmp#zakaz.sum-vat >=
        (input frame Dialog-Frame tmp#zakaz.cli-qnty * input frame Dialog-Frame tmp#zakaz.price-cli -
         (if vat_type = 'в т. ч.':U then input frame Dialog-Frame tmp#zakaz.sum-vat else 0))
        then do:
        message "НДС не может быть больше 99.999...%" skip
                "НДС:"  input frame Dialog-Frame tmp#zakaz.sum-vat skip
                "Сумма:" input frame Dialog-Frame tmp#zakaz.cli-qnty * input frame Dialog-Frame tmp#zakaz.price-cli
                view-as alert-box error.
        display tmp#zakaz.sum-vat with frame Dialog-Frame.
        return no-apply.
     end.
     else do:
       if input frame Dialog-Frame tmp#zakaz.sum-vat = 0.00 then do:
          g#log = no.
          message "Вы хотите установить НДС в 0?"
          view-as alert-box question buttons yes-no update g#log.
          if g#log = yes then do:
             assign frame Dialog-Frame tmp#zakaz.sum-vat.
             run calc-vat-pc in this-procedure .
          end.
          else do:
              display tmp#zakaz.sum-vat with frame Dialog-Frame.
              return no-apply.
          end.
       end.
       else do:
          assign frame Dialog-Frame tmp#zakaz.sum-vat.
          run calc-vat-pc in this-procedure .
       end.
     end.
   end.
end.
procedure calc-vat-pc:
  tmp#zakaz.vat-pc = (input frame Dialog-Frame tmp#zakaz.sum-vat / (input frame Dialog-Frame tmp#zakaz.cli-qnty * input frame Dialog-Frame tmp#zakaz.price-cli
           * ( 1 - (if slt_type = 'в т. ч.':U then (input frame Dialog-Frame tmp#zakaz.slt-pc / (100 + input frame Dialog-Frame tmp#zakaz.slt-pc)) else 0))
          - (if vat_type =  'в т. ч.':U then input frame Dialog-Frame tmp#zakaz.sum-vat else 0))) * 100.
  run ass-var in this-procedure .
end procedure.
ON LEAVE OF tmp#zakaz.vat-pc OR
   LEAVE OF tmp#zakaz.SLT-pc IN FRAME Dialog-Frame DO:
   if input frame Dialog-Frame tmp#zakaz.vat-pc <> tmp#zakaz.vat-pc or
      input frame Dialog-Frame tmp#zakaz.slt-pc <> tmp#zakaz.slt-pc then do:
      if vat-sumvalue <> "yes" then do:
         IF INDEX(input frame Dialog-Frame tmp#zakaz.vat-pc, dops) = 0 then do:
            message "Неверное значение НДС:" input frame Dialog-Frame tmp#zakaz.vat-pc  SKIP
                    "Разрешенные значения: " dops "."
                    view-as alert-box.
            display tmp#zakaz.vat-pc with frame Dialog-Frame.
            return no-apply.
         end.
         IF INDEX(input frame Dialog-Frame tmp#zakaz.slt-pc, dop-slt) = 0 then do:
            message "Неверное значение НсП."   SKIP
                    "Разрешенные значения: " dop-slt "."
                    view-as alert-box.
            display tmp#zakaz.slt-pc with frame Dialog-Frame.
            return no-apply.
         end.
      end.
      assign frame Dialog-Frame tmp#zakaz.vat-pc
             frame Dialog-Frame tmp#zakaz.slt-pc.
      run ass-var in this-procedure .
   end.
END.
procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.
if  loc-base-rate =  0  and
    loc-base-scale = 0  and
    loc-exch-rate  = 0  and
    loc-exch-scale = 0  then return.
if vat_type = "" or vat_type = ? then do:
assign
     vat_type   = 'в т. ч.':U
     slt_type   = 'без':U
.
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   loc-base-rate
  ,input   loc-base-scale
  ,input   loc-exch-rate
  ,input   loc-exch-scale
  ,input   vat_type
  ,input   slt_type
  ,input   tmp#zakaz.artic
  ,input   tmp#zakaz.prod-type
  ,input   tmp#zakaz.prod-code
  ,input   tmp#zakaz.price-cli
  ,input   tmp#zakaz.cli-base-rate
  ,input   tmp#zakaz.price-rubl
  ,input   input frame Dialog-Frame tmp#zakaz.vat-pc
  ,input   input frame Dialog-Frame tmp#zakaz.slt-pc
  ,input   input frame Dialog-Frame tmp#zakaz.road-tax
  ,input   input frame Dialog-Frame tmp#zakaz.transport-rubl
  ,input   input frame Dialog-Frame tmp#zakaz.other-rubl
  ,output  varprice-cli-dt
  ,output  varprice-cli-unit-base-dt
  ,output  varprice-road-tax-dt
  ,output  varprice-other-exp-dt
  ,output  varprice-transport-exp-dt
  ,output  varprice-without-abs-dt
  ,output  varprice-slt-dt
  ,output  varprice-no-slt-dt
  ,output  varprice-vat-dt
  ,output  varprice-no-vat-slt-dt
  ,output  varprice-rubl-dt
  ,output  varprice-road-tax-rubl-dt
  ,output  varprice-other-exp-rubl-dt
  ,output  varprice-transport-exp-rubl-dt
  ,output  varprice-without-abs-rubl-dt
  ,output  varprice-slt-rubl-dt
  ,output  varprice-no-slt-rubl-dt
  ,output  varprice-vat-rubl-dt
  ,output  varprice-no-vat-slt-rubl-dt
  ,output  varprice-base-dt
  ,output  varprice-road-tax-base-dt
  ,output  varprice-other-exp-base-dt
  ,output  varprice-transport-exp-base-dt
  ,output  varprice-without-abs-base-dt
  ,output  varprice-slt-base-dt
  ,output  varprice-no-slt-base-dt
  ,output  varprice-vat-base-dt
  ,output  varprice-no-vat-slt-base-dt
  ) no-error.
    if error-status:error then do:
      return error substitute( "Ошибка при пересчете линии заказа . &1" , return-value ) .
    end.
   assign
    tmp#zakaz.sum-vat    = varprice-vat-dt  * input frame Dialog-Frame tmp#zakaz.cli-qnty
    tmp#zakaz.sum-slt    = varprice-slt-dt
    tmp#zakaz.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    tmp#zakaz.other-base = varprice-other-exp-base-dt
    tmp#zakaz.other-rubl = varprice-other-exp-rubl-dt
    tmp#zakaz.price-rubl = varprice-rubl-dt
    tmp#zakaz.price-base = varprice-base-dt
    tmp#zakaz.price-cli  = varprice-cli-dt
     .
end procedure.
procedure ass-var :
 do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
 assign
    pargds-code =  ub.goods.gds-code
    parobj-type =  loc-store-type
    parobj-code =  loc-store-code
 .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_kndinpin in g#lib-calc
  (
   input  pargds-code
  ,input  loc-cli-type
  ,input  loc-cli-code
  ,input  parobj-type
  ,input  parobj-code
  ,output parext-gds-type
  ,output parcli-qnty-input
  ,output pardensity-input
  ,output parcli-base-rate-input
  ,output pardoc-qnty-input
  ,output parfact-qnty-input
  ,output parprice-cli-input
  ,output parbase-price-input
  ,output partax-3-input
  ,output parcli-qnty-calc
  ,output pardensity-calc
  ,output parcli-base-rate-calc
  ,output pardoc-qnty-calc
  ,output parfact-qnty-calc
  ,output parprice-cli-calc
  ,output parbase-price-calc
  ,output partax-3-calc
  ,output parround
  ) no-error.
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "1"
  view-as alert-box error
.
if  parext-gds-type =  'sg':U then
  do:
   assign
    parcli-qnty-input   = true
    parprice-cli-input  = true
   .
  end.
if g#type =  'ОФ':U then
assign
parbase-price-my = false
parbase-price-input = false
parprice-cli-input  = false
.
else
assign
  parbase-price-my = true
.
run tax-name in this-procedure (input 'rdt':U, output varroad-tax-label) no-error.
assign
  tmp#zakaz.road-tax:label in frame Dialog-Frame = varroad-tax-label
   .
if parbase-price-calc = 'cli-price' then do:
 assign  frame Dialog-Frame tmp#zakaz.cli-art tmp#zakaz.VAT-pc tmp#zakaz.cli-qnty tmp#zakaz.SLT-pc tmp#zakaz.qnty tmp#zakaz.price-cli tmp#zakaz.line-num tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type tmp#zakaz.prod-code tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base tmp#zakaz.sum-rubl tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl tmp#zakaz.price-rubl tmp#zakaz.price-base .
 assign
    tmp#zakaz.sum-rubl = input frame Dialog-Frame tmp#zakaz.price-rubl  * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-base = tmp#zakaz.price-base  * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-cli  = tmp#zakaz.price-cli   * input frame Dialog-Frame tmp#zakaz.cli-qnty
    tot-rubl     = input frame Dialog-Frame tmp#zakaz.price-rubl * input frame Dialog-Frame tmp#zakaz.qnty
    tot-base     = tmp#zakaz.price-base * input frame Dialog-Frame tmp#zakaz.qnty
    tot-cli      = tmp#zakaz.price-cli  * input frame Dialog-Frame tmp#zakaz.cli-qnty
    .
end.
else do:
   assign  frame Dialog-Frame tmp#zakaz.cli-art tmp#zakaz.VAT-pc tmp#zakaz.cli-qnty tmp#zakaz.SLT-pc tmp#zakaz.qnty tmp#zakaz.price-cli tmp#zakaz.line-num tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type tmp#zakaz.prod-code tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base tmp#zakaz.sum-rubl tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl.
 assign
    tmp#zakaz.sum-rubl = tmp#zakaz.price-rubl  * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-base = tmp#zakaz.price-base  * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-cli  = input frame Dialog-Frame tmp#zakaz.price-cli   * input frame Dialog-Frame tmp#zakaz.cli-qnty
    tot-rubl     = tmp#zakaz.price-rubl * input frame Dialog-Frame tmp#zakaz.qnty
    tot-base     = tmp#zakaz.price-base * input frame Dialog-Frame tmp#zakaz.qnty
    tot-cli      = input frame Dialog-Frame tmp#zakaz.price-cli  * input frame Dialog-Frame tmp#zakaz.cli-qnty
    .
end.
 assign
    tmp#zakaz.sum-excise          = input frame Dialog-Frame tmp#zakaz.excise         * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-other-base      = input frame Dialog-Frame tmp#zakaz.other-base     * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-other-rubl      = input frame Dialog-Frame tmp#zakaz.other-rubl     * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-road-tax        = input frame Dialog-Frame tmp#zakaz.road-tax       * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-transport-base  = input frame Dialog-Frame tmp#zakaz.transport-base * input frame Dialog-Frame tmp#zakaz.qnty
    tmp#zakaz.sum-transport-rubl  = input frame Dialog-Frame tmp#zakaz.transport-rubl * input frame Dialog-Frame tmp#zakaz.qnty
    .
run disp-total in this-procedure .
 enable
      tmp#zakaz.qnty           when pardoc-qnty-input = true
      tmp#zakaz.cli-qnty       when parcli-qnty-input = true
      tmp#zakaz.price-base
      tmp#zakaz.price-rubl     when parbase-price-input = true
      tmp#zakaz.price-cli      when parprice-cli-input  = true
      tmp#zakaz.road-tax       when partax-3-input = true
      tmp#zakaz.cli-base-rate  when parcli-base-rate-input = true
      tmp#zakaz.unit-cli       when parcli-base-rate-input = true
      r-units            when parcli-base-rate-input = true
     with frame Dialog-Frame .
disable
      tmp#zakaz.qnty when pardoc-qnty-input = false
      tmp#zakaz.cli-qnty when parcli-qnty-input = false
      tmp#zakaz.price-base
      tmp#zakaz.price-rubl when parbase-price-input = false
      tmp#zakaz.price-cli  when parprice-cli-input  = false
      tmp#zakaz.road-tax   when partax-3-input = false
      tmp#zakaz.cli-base-rate  when parcli-base-rate-input = false
      tmp#zakaz.unit-cli when parcli-base-rate-input = false
      r-units when parcli-base-rate-input = false
     with frame Dialog-Frame .
 if loc-doc-type = 'ОФ':U  Then do:
    display
        tmp#zakaz.qnty
        tmp#zakaz.cli-qnty
        tmp#zakaz.unit-cli
        tmp#zakaz.cli-base-rate
        with frame Dialog-Frame .
        hide     tmp#zakaz.price-rubl        tmp#zakaz.price-base in frame Dialog-Frame .
      end.
      else do:
      display
            tmp#zakaz.qnty
            tmp#zakaz.cli-qnty
            tmp#zakaz.price-rubl
            tmp#zakaz.price-base
            tmp#zakaz.price-cli
            tmp#zakaz.sum-rubl
            tmp#zakaz.sum-base
            tmp#zakaz.sum-cli
            tmp#zakaz.sum-excise
            tmp#zakaz.sum-other-base
            tmp#zakaz.sum-other-rubl
            tmp#zakaz.sum-road-tax
            tmp#zakaz.sum-transport-base
            tmp#zakaz.sum-transport-rubl
            tmp#zakaz.unit-cli
            tmp#zakaz.cli-base-rate
            tmp#zakaz.sum-vat
            tmp#zakaz.sum-slt
            tmp#zakaz.vat-pc
            tmp#zakaz.slt-pc
      with frame Dialog-Frame .
      end.
      Hide tot-cli  tot-rubl tot-base in FRAME Dialog-Frame.
  run edoc-nn-proc in this-procedure .
 end.
end procedure.
PROCEDURE apply-focus-next-entry :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define input parameter p-widget-handle as handle no-undo .
  do with frame Dialog-Frame :
      if tmp#zakaz.cli-qnty :handle = p-widget-handle then do:
         if tmp#zakaz.cli-base-rate:sensitive then
            apply "entry":u to tmp#zakaz.cli-base-rate   in frame Dialog-Frame .
         if tmp#zakaz.price-cli:sensitive then
            apply "entry":u to tmp#zakaz.price-cli   in frame Dialog-Frame .
         if tmp#zakaz.price-rubl:sensitive then
            apply "entry":u to tmp#zakaz.price-rubl  in frame Dialog-Frame .
         if tmp#zakaz.price-base:sensitive then
            apply "entry":u to tmp#zakaz.price-base  in frame Dialog-Frame .
         end.
      if tmp#zakaz.qnty :handle = p-widget-handle then  do:
         if tmp#zakaz.cli-base-rate:sensitive then
            apply "entry":u to tmp#zakaz.cli-base-rate   in frame Dialog-Frame .
         if tmp#zakaz.price-rubl:sensitive then
            apply "entry":u to tmp#zakaz.price-rubl  in frame Dialog-Frame .
         if tmp#zakaz.price-base:sensitive then
            apply "entry":u to tmp#zakaz.price-base  in frame Dialog-Frame .
         if tmp#zakaz.price-cli:sensitive  then
            apply "entry":u to tmp#zakaz.price-cli   in frame Dialog-Frame .
         end.
  end.
end.
END PROCEDURE.
ON  RETURN OF tmp#zakaz.cli-qnty IN FRAME  Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure  (input  tmp#zakaz.cli-qnty :handle ) .
  return no-apply .
END.
ON  RETURN OF tmp#zakaz.qnty IN FRAME  Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure  (input  tmp#zakaz.qnty :handle ) .
  return no-apply .
END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-PETROL :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  g#type = loc-doc-type .
  find first i-ord-doc where i-ord-doc.doc-code = loc-ord-num no-lock no-error .
  if available i-ord-doc then do:
      loc-store-code  = i-ord-doc.obj-code .
      loc-store-type  = i-ord-doc.obj-type .
  end.
  if loc-doc-type = 'ФП':U then do:
        for each ub.shop no-lock where ub.shop.host-code   = g#host-code:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'маг':U ,
   input ub.shop.obj-code )
  no-error .
        end.
        for each ub.store no-lock  where ub.store.host-code  = g#host-code:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'скл':U ,
   input ub.store.obj-code )
  no-error .
        end.
    end.
    else do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input loc-store-type ,
   input loc-store-code )
   .
    end.
  find first tmp#zakaz  where  recid ( tmp#zakaz )  = r-tmp  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "tmp#zakaz"
    view-as alert-box error
  .
  find first b-ord-line where  recid ( b-ord-line ) = r-tmp  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "b-ord-line"
    view-as alert-box error
  .
  if line-mode = 'ИЗМЕНЕНИЕ':U or line-mode = 'ДОБАВЛЕНИЕ':U or line-mode = "ЦИКЛ":u  then do:
  find first shar_ord-line  exclusive-lock  where
      shar_ord-line.doc-code  = loc-ord-num          and
      shar_ord-line.artic     = b-ord-line.artic     and
      shar_ord-line.prod-type = b-ord-line.prod-type and
      shar_ord-line.prod-code = b-ord-line.prod-code  no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                 error-status :get-message(1)
                 "Ошибка поиска строки заказа"
                 "№ :" loc-ord-num    skip
                 "артикул :"
                  b-ord-line.artic
                  b-ord-line.prod-type
                  b-ord-line.prod-code
                  view-as alert-box error .
         return error.
         end.
  end.
  else do:
  find first shar_ord-line  no-lock   where
      shar_ord-line.doc-code  = loc-ord-num          and
      shar_ord-line.artic     = b-ord-line.artic     and
      shar_ord-line.prod-type = b-ord-line.prod-type and
      shar_ord-line.prod-code = b-ord-line.prod-code  no-error .
   end.
  create tt-ord-line.
  BUFFER-COPY tmp#zakaz to tt-ord-line.
  find first   ub.currency where ub.currency.curr-code = LOC-EXCH-CODE no-lock no-error.
  if available ub.currency then   abbr-cli  = ub.currency.curr-abbr .
  find first   ub.currency where ub.currency.curr-code = base-CODE no-lock no-error.
  if available ub.currency then   abbr-base = ub.currency.curr-abbr .
  abbr-rubl = "РУБ"  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'vat-ext'   then  dops        = thbjattr_thbj-attr.property-value-character .
        if thbjattr_thbj-attr.prop-code = 'slt-ext'   then  dop-slt     = thbjattr_thbj-attr.property-value-character .
        if thbjattr_thbj-attr.prop-code = 'vat-sum'   then  vat-sumvalue= string(thbjattr_thbj-attr.property-value-logical, "yes/no") .
    end.
    empty temp-table thbjattr_thbj-attr.
   assign
   rdtaxcdvalue  = '3':U
   exctaxcdvalue = '4':U
   vattaxcdvalue = '1':U
   .
 run enable_ui.
 if  g#type <> 'ФП':U then do:
      find first buf_gds-obj no-lock where
        buf_gds-obj.artic     = ub.goods.artic        and
        buf_gds-obj.prod-type = ub.goods.prod-type    and
        buf_gds-obj.prod-code = ub.goods.prod-code    and
        buf_gds-obj.obj-type = loc-store-type     and
        buf_gds-obj.obj-code = loc-store-code     no-error .
      if available buf_gds-obj then
      display
          buf_gds-obj.fact-qnty @ buf_gds-obj.fact-qnty
          string (round (buf_gds-obj.fact-qnty / ub.goods.cli-base-rate , 3 )) + " " + ub.goods.unit-cli @ v-fact-cli-qnty
          buf_gds-obj.free-qnty
          buf_gds-obj.avrg-qnty
          with frame Dialog-Frame .
          if not available buf_gds-obj then
      display
          "-Новый товар-" @ buf_gds-obj.fact-qnty
          with frame Dialog-Frame .
 end.
 else do:
   hide
    buf_gds-obj.fact-qnty
    v-fact-cli-qnty
    buf_gds-obj.free-qnty
    buf_gds-obj.avrg-qnty
    in frame Dialog-Frame .
 end.
 if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
    kk = ub.goods.cli-base-rate.
    else KK = b-ord-line.cli-base-rate.
   b-ord-line.cli-base-rate  = kk.
   run ui-on no-error .
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
 if  g#type <> 'ФП':U then do:
      find first buf_gds-obj no-lock where
        buf_gds-obj.artic     = ub.goods.artic        and
        buf_gds-obj.prod-type = ub.goods.prod-type    and
        buf_gds-obj.prod-code = ub.goods.prod-code    and
        buf_gds-obj.obj-type = loc-store-type     and
        buf_gds-obj.obj-code = loc-store-code     no-error .
      if available buf_gds-obj then
      display
          buf_gds-obj.fact-qnty @ buf_gds-obj.fact-qnty
          buf_gds-obj.free-qnty
          buf_gds-obj.avrg-qnty
          with frame Dialog-Frame .
          if not available buf_gds-obj then
      display
          "-Новый товар-" @ buf_gds-obj.fact-qnty
          with frame Dialog-Frame .
 end.
  tmp#zakaz.sum-road-tax:label  =  "Сумма по " + substring( tmp#zakaz.road-tax:label ,1 , 5) +  "." .
  if (i-ord-doc.whole-send-news = integer('1':U)
      and
      (i-ord-doc.ord-int1 = integer('3':U) or i-ord-doc.ord-int1 = integer('4':U))
      )
  or (i-ord-doc.whole-send-news = integer('2':U)
      and
      (i-ord-doc.ord-int1 = integer('6':U)
       or
       i-ord-doc.ord-int1 = integer('5':U)
       or
       i-ord-doc.ord-int1 = integer('4':U)
      ))
  then do:
     disable all with frame Dialog-Frame .
     enable B-OK with frame Dialog-Frame .
  end.
  if tmp#zakaz.cli-qnty:sensitive in frame Dialog-Frame then do:
      WAIT-FOR GO OF FRAME Dialog-Frame focus  tmp#zakaz.cli-qnty .
  end.
  else do:
      WAIT-FOR GO OF FRAME Dialog-Frame focus  tmp#zakaz.qnty .
  end.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-petrol.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tmp#zakaz       WHERE r-tmp = recid ( tmp#zakaz   ) NO-LOCK,       EACH ub.goods WHERE ub.goods.artic = tmp#zakaz.artic   AND ub.goods.prod-code = tmp#zakaz.prod-code   AND ub.goods.prod-type = tmp#zakaz.prod-type NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,       EACH ub.clients WHERE ub.clients.obj-code = tmp#zakaz.prod-code   AND ub.clients.obj-type = tmp#zakaz.prod-type NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY abbr-cli abbr-base abbr-rubl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name ub.goods.qnty-cart ub.goods.wt-cart ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tmp#zakaz THEN
    DISPLAY tmp#zakaz.cli-art tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT
          tmp#zakaz.cli-qnty tmp#zakaz.unit-cli tmp#zakaz.SLT-pc
          tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli
          tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num
          tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise
          tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl
          tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type
          tmp#zakaz.prod-code tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base
          tmp#zakaz.sum-rubl tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise
          tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base
          tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel b-exit-cycl B-qnty B-prt B-help
         tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT r-units
         tmp#zakaz.cli-qnty tmp#zakaz.unit-cli tmp#zakaz.SLT-pc
         tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli
         tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num
         tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise
         tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl
         tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type
         ub.clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart
         tmp#zakaz.sum-SLT ub.goods.unit-base abbr-cli tmp#zakaz.sum-cli abbr-base
         tmp#zakaz.sum-base abbr-rubl tmp#zakaz.sum-rubl ub.gds-prt.node-name
         tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base
         tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl
         tmp#zakaz.sum-other-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE UI-on :
 do
 on error undo, return error return-value
 :
define variable gds-rec as recid no-undo .
define variable sss as character no-undo .
find current ub.goods no-lock no-error .
gds-rec = recid( ub.goods ) .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "is-petrl.i"
  view-as alert-box error
.
is-petrolium = false .
if is-petrolium = true then  run run-petrol in this-procedure no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "run-petrol"
  view-as alert-box error
.
run ass-var in this-procedure no-error .
if error-status :error then
 message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "из программы ass-var"
  view-as alert-box error
.
  assign
    tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
    tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
    tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
  .
if g#type <> 'ОФ':U  then do:
    display
    tmp#zakaz.sum-rubl
    tmp#zakaz.sum-base
    tmp#zakaz.sum-cli
    with frame Dialog-Frame .
end.
sss = (if g#type = 'ОФ':U  then "Заявка № " else "Заказ № ") + loc-ord-num + line-mode.
 assign frame Dialog-Frame:title  = sss  .
   if slt_type = 'без':U and g#type <> 'ОФ':U then do:
      disable tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT      with frame Dialog-Frame .
      display tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT      with frame Dialog-Frame .
   end.
   if vat_type = 'без':U and g#type <> 'ОФ':U then do:
      disable tmp#zakaz.vat-pc  tmp#zakaz.sum-vat      with frame Dialog-Frame .
      display tmp#zakaz.vat-pc  tmp#zakaz.sum-vat      with frame Dialog-Frame .
   end.
   if  g#type = 'ОФ':U or line-mode = 'ПРОСМОТР':U then do:
      disable tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT  tmp#zakaz.vat-pc  tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame Dialog-Frame .
      display tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT  tmp#zakaz.vat-pc  tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame Dialog-Frame .
   end.
   disable tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame Dialog-Frame .
   if line-mode = 'ПРОСМОТР':U then do:
     disable all with frame Dialog-Frame .
     enable B-Cancel with frame Dialog-Frame .
   end.
  if  line-mode = "ЦИКЛ":U then do:
     enable  b-exit-cycl with frame Dialog-Frame.
     display b-exit-cycl  with frame Dialog-Frame.
  end.
  if  line-mode = 'ИЗМЕНЕНИЕ':U then do:
     disable  b-exit-cycl  with frame Dialog-Frame.
  end.
  if  line-mode = 'ПРОСМОТР':U then do:
     disable  b-exit-cycl   with frame Dialog-Frame.
  end.
  hide tmp#zakaz.excise             tmp#zakaz.sum-excise
       tmp#zakaz.transport-base     tmp#zakaz.transport-rubl
       tmp#zakaz.sum-transport-base tmp#zakaz.sum-transport-rubl
       tmp#zakaz.other-base         tmp#zakaz.other-rubl
       tmp#zakaz.sum-other-base     tmp#zakaz.sum-other-rubl
       B-qnty B-prt        tmp#zakaz.line-num
      in frame Dialog-Frame .
  if  g#type = 'ОФ':U  then do:
    hide
     tmp#zakaz.VAT-pc
     tmp#zakaz.v-vat
     tmp#zakaz.sum-VAT
     tmp#zakaz.SLT-pc
     tot-cli
     tmp#zakaz.price-cli
     tot-rubl
     tmp#zakaz.price-base
     tot-base
     tmp#zakaz.price-rubl
     tmp#zakaz.line-num
     tmp#zakaz.cancel-date
     tmp#zakaz.road-tax
     tmp#zakaz.excise
     tmp#zakaz.transport-base
     tmp#zakaz.other-base
     tmp#zakaz.transport-rubl
     tmp#zakaz.other-rubl
     tmp#zakaz.sum-SLT
     tmp#zakaz.sum-cli
     abbr-base
     tmp#zakaz.sum-base
     abbr-rubl
     tmp#zakaz.sum-rubl
     tmp#zakaz.sum-road-tax
     tmp#zakaz.sum-excise
     tmp#zakaz.sum-transport-base
     tmp#zakaz.sum-other-base
     tmp#zakaz.sum-transport-rubl
     tmp#zakaz.sum-other-rubl
     in frame Dialog-Frame .
  end.
end.
END PROCEDURE.
procedure run-petrol :
  do
  on error undo, return error
  :
 assign
   N-1 = 0  N-2 = 0
 .
 for each obj-list ,
    EACH ub.place no-lock
      WHERE  ub.place.obj-code = obj-list.obj-code
         AND ub.place.obj-type = obj-list.obj-type ,
         first ub.pl-gds no-lock where
                    ub.pl-gds.gds-code = ub.goods.gds-code  and
                    ub.pl-gds.pl-code = ub.place.pl-code    and
                    ub.pl-gds.obj-code = ub.place.obj-code  and
                    ub.pl-gds.obj-type = ub.place.obj-type  :
         N-1 = N-1 + ub.place.max-qnty.
         find LAST ub.rvs-line no-lock  WHERE
                    ub.rvs-line.gds-code = ub.goods.gds-code and
                    ub.rvs-line.pl-code = ub.place.pl-code
                    no-error .
                    if avail  ub.rvs-line then do:
                       find first ub.rvs-doc no-lock where ub.rvs-doc.rvs-code = ub.rvs-line.rvs-code and
                                           ub.rvs-doc.status_ = 'факт':U no-error .
                       if available ub.rvs-doc then do:
                          N-2  =  N-2 + ub.rvs-line.state-measure-qnty .
                       end.
                    end.
 end.
 N-2 = N-1 - N-2.
  DISPLAY N-1 N-2
      WITH FRAME FRAME-petrol.
  ENABLE BR-PETROL N-1 N-2
      WITH FRAME FRAME-petrol.
  VIEW FRAME FRAME-petrol.
  OPEN QUERY BR-PETROL for each obj-list ,        EACH ub.place NO-LOCK        WHERE  ub.place.obj-code = obj-list.obj-code           AND ub.place.obj-type = obj-list.obj-type ,       FIRST ub.pl-gds no-lock         WHERE  ub.pl-gds.obj-code = ub.place.obj-code           AND ub.pl-gds.obj-type = ub.place.obj-type           AND ub.pl-gds.pl-code  = ub.place.pl-code           AND ub.pl-gds.gds-code = ub.goods.gds-code .
end.
end procedure.
procedure ver-value :
 do
 on error undo, return error return-value
 :
define buffer bf-units-cli for ub.units.
 if   tmp#zakaz.cli-art:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.cli-art  <> tmp#zakaz.cli-art  then apply "leave" to tmp#zakaz.cli-art  in frame Dialog-Frame.
 if   tmp#zakaz.vat-pc:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.vat-pc  <> tmp#zakaz.vat-pc  then apply "leave" to tmp#zakaz.vat-pc  in frame Dialog-Frame.
 if   tmp#zakaz.sum-vat:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-vat  <> tmp#zakaz.sum-vat  then apply "leave" to tmp#zakaz.sum-vat  in frame Dialog-Frame.
 if   tmp#zakaz.cli-qnty:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.cli-qnty  <> tmp#zakaz.cli-qnty  then apply "leave" to tmp#zakaz.cli-qnty  in frame Dialog-Frame.
 if   tmp#zakaz.slt-pc:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.slt-pc  <> tmp#zakaz.slt-pc  then apply "leave" to tmp#zakaz.slt-pc  in frame Dialog-Frame.
 if   tmp#zakaz.sum-slt:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-slt  <> tmp#zakaz.sum-slt  then apply "leave" to tmp#zakaz.sum-slt  in frame Dialog-Frame.
 if   tmp#zakaz.qnty:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.qnty  <> tmp#zakaz.qnty  then apply "leave" to tmp#zakaz.qnty  in frame Dialog-Frame.
 if   tmp#zakaz.price-cli:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.price-cli  <> tmp#zakaz.price-cli  then apply "leave" to tmp#zakaz.price-cli  in frame Dialog-Frame.
 if   tmp#zakaz.price-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.price-base  <> tmp#zakaz.price-base  then apply "leave" to tmp#zakaz.price-base  in frame Dialog-Frame.
 if   tmp#zakaz.price-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.price-rubl  <> tmp#zakaz.price-rubl  then apply "leave" to tmp#zakaz.price-rubl  in frame Dialog-Frame.
 if   tmp#zakaz.cli-base-rate:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.cli-base-rate  <> tmp#zakaz.cli-base-rate  then apply "leave" to tmp#zakaz.cli-base-rate  in frame Dialog-Frame.
 if   tmp#zakaz.road-tax:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.road-tax  <> tmp#zakaz.road-tax  then apply "leave" to tmp#zakaz.road-tax  in frame Dialog-Frame.
 if   tmp#zakaz.line-num:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.line-num  <> tmp#zakaz.line-num  then apply "leave" to tmp#zakaz.line-num  in frame Dialog-Frame.
 if   tmp#zakaz.sum-road-tax:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-road-tax  <> tmp#zakaz.sum-road-tax  then apply "leave" to tmp#zakaz.sum-road-tax  in frame Dialog-Frame.
 if   tmp#zakaz.cancel-date:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.cancel-date  <> tmp#zakaz.cancel-date  then apply "leave" to tmp#zakaz.cancel-date  in frame Dialog-Frame.
 if   tmp#zakaz.excise:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.excise  <> tmp#zakaz.excise  then apply "leave" to tmp#zakaz.excise  in frame Dialog-Frame.
 if   tmp#zakaz.sum-excise:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-excise  <> tmp#zakaz.sum-excise  then apply "leave" to tmp#zakaz.sum-excise  in frame Dialog-Frame.
 if   tmp#zakaz.transport-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.transport-base  <> tmp#zakaz.transport-base  then apply "leave" to tmp#zakaz.transport-base  in frame Dialog-Frame.
 if   tmp#zakaz.other-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.other-base  <> tmp#zakaz.other-base  then apply "leave" to tmp#zakaz.other-base  in frame Dialog-Frame.
 if   tmp#zakaz.transport-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.transport-rubl  <> tmp#zakaz.transport-rubl  then apply "leave" to tmp#zakaz.transport-rubl  in frame Dialog-Frame.
 if   tmp#zakaz.other-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.other-rubl  <> tmp#zakaz.other-rubl  then apply "leave" to tmp#zakaz.other-rubl  in frame Dialog-Frame.
 if   tmp#zakaz.sum-transport-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-transport-base  <> tmp#zakaz.sum-transport-base  then apply "leave" to tmp#zakaz.sum-transport-base  in frame Dialog-Frame.
 if   tmp#zakaz.sum-other-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-other-base  <> tmp#zakaz.sum-other-base  then apply "leave" to tmp#zakaz.sum-other-base  in frame Dialog-Frame.
 if   tmp#zakaz.sum-transport-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-transport-rubl  <> tmp#zakaz.sum-transport-rubl  then apply "leave" to tmp#zakaz.sum-transport-rubl  in frame Dialog-Frame.
 if   tmp#zakaz.sum-other-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-other-rubl  <> tmp#zakaz.sum-other-rubl  then apply "leave" to tmp#zakaz.sum-other-rubl  in frame Dialog-Frame.
 if   tmp#zakaz.sum-cli:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-cli  <> tmp#zakaz.sum-cli  then apply "leave" to tmp#zakaz.sum-cli  in frame Dialog-Frame.
 if   tmp#zakaz.sum-base:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-base  <> tmp#zakaz.sum-base  then apply "leave" to tmp#zakaz.sum-base  in frame Dialog-Frame.
 if   tmp#zakaz.sum-rubl:sensitive in frame Dialog-Frame and input frame Dialog-Frame tmp#zakaz.sum-rubl  <> tmp#zakaz.sum-rubl  then apply "leave" to tmp#zakaz.sum-rubl  in frame Dialog-Frame.
  assign frame Dialog-Frame tmp#zakaz.cli-art tmp#zakaz.VAT-pc tmp#zakaz.cli-qnty tmp#zakaz.SLT-pc tmp#zakaz.qnty tmp#zakaz.price-cli tmp#zakaz.line-num tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type tmp#zakaz.prod-code tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base tmp#zakaz.sum-rubl tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl .
  if tmp#zakaz.cli-qnty:sensitive in frame Dialog-Frame and  (tmp#zakaz.cli-qnty = 0 or tmp#zakaz.cli-qnty = ?)  then do:
    message "Не указано количество в единицах поставщика." view-as alert-box error.
    if tmp#zakaz.cli-qnty:sensitive in frame Dialog-Frame then apply "entry" to tmp#zakaz.cli-qnty in frame Dialog-Frame.
                                                           else apply "entry" to b-cancel           in frame Dialog-Frame.
    return error.
  end.
  if tmp#zakaz.qnty:sensitive in frame Dialog-Frame and  (tmp#zakaz.qnty = 0 or tmp#zakaz.qnty = ?)  then do:
    message "Не указано количество  в учетных единицах." view-as alert-box error.
    return error.
  end.
  if  tmp#zakaz.qnty:sensitive in frame Dialog-Frame and
     lookup ( 'шту':U, tmp#zakaz.unit-type) > 0      and
     trunc ( tmp#zakaz.qnty, 0) <> tmp#zakaz.qnty then do:
      message "Базовая единица товара " tmp#zakaz.unit-base " - штучная." skip
              "Кол-во должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.
  find bf-units-cli where bf-units-cli.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  if  tmp#zakaz.cli-qnty:sensitive in frame Dialog-Frame and
      lookup('шту':U, bf-units-cli.type) > 0  and
      trunc (tmp#zakaz.cli-qnty, 0) <> tmp#zakaz.cli-qnty then do:
      message "Единица поставщика " tmp#zakaz.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.
  if tmp#zakaz.cli-base-rate:sensitive in frame Dialog-Frame and (tmp#zakaz.cli-base-rate = 0 or tmp#zakaz.cli-base-rate = ?) then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if tmp#zakaz.unit-cli = tmp#zakaz.unit-base and tmp#zakaz.cli-base-rate <> 1 then do:
    message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
    return error.
  end.
  if  loc-status <> ""  then do:
    if tmp#zakaz.price-cli:sensitive in frame Dialog-Frame and ( tmp#zakaz.price-cli = 0 or tmp#zakaz.price-cli = ?) then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-cli < 0  then do:
      message "Нельзя указывать отрицательные цены в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-base:sensitive in frame Dialog-Frame and (tmp#zakaz.price-base = 0 or tmp#zakaz.price-base = ?) then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-base < 0  then do:
      message "Отрицательная цена в базовой валюте."  view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-base > 5000 and base-code = 1 then
      message "Внимание !!!" skip (2)
              "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
              "Вы не ошиблись ?"  view-as alert-box question.
    if tmp#zakaz.price-rubl:sensitive in frame Dialog-Frame and (tmp#zakaz.price-rubl = 0 or tmp#zakaz.price-rubl = ?) then do:
      message "Не указана цена в рублях." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-rubl < 0 then do:
      message "Отрицательная цена в рублях."  view-as alert-box error.
      return error.
    end.
  end.
  if is-petrolium = true then do:
   if n-1 < tmp#zakaz.qnty then do:
   message "Внимание !!! Заказано  больше, чем общий объем мест хранения! "  view-as alert-box error  .
   end.
  end.
  assign
    tmp#zakaz.price-base =  tmp#zakaz.price-rubl  / loc-base-rate * loc-base-scale
    tmp#zakaz.qnty       =  tmp#zakaz.cli-qnty   * tmp#zakaz.cli-base-rate
    tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
    tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
    tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
  .
if ( is-edoc-nn-doc = false and shar_ord-doc.ord-int1 = int('0':U) )
  or ( is-edi-doc     = false and shar_ord-doc.ord-int1 = int('0':U)  )
  then do:
    define variable v-not-corr-op as character no-undo .
    define variable p-type as character no-undo .
    if (tmp#zakaz.qnty <> tmp#zakaz.initial-qnty and e-method <> "") then do:
      v-not-corr-op  = 'no' .
      run clntattr-value (
            input   loc-store-type
          , input   loc-store-code
          , input   'not-corr-op':U
          , output  v-not-corr-op
          , output  p-type
      ) no-error .
      if error-status :error then v-not-corr-op  = 'no' .
      if v-not-corr-op  = 'yes' then do:
        v-not-corr-op  = 'no' .
        run clntattr-value (
              input   loc-cli-type
            , input   loc-cli-code
            , input   'not-corr-op':U
            , output  v-not-corr-op
            , output  p-type
        ) no-error .
        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute ( "Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Поставщику &2&3 " ,
                  tmp#zakaz.initial-qnty ,
                  loc-cli-type ,
                  loc-cli-code ,
                  chr(10) )
          view-as alert-box information .
          return error.
        end.
        define buffer buf_goods for ub.goods  .
        find first  buf_goods no-lock where
                    buf_goods.artic = tmp#zakaz.artic and
                    buf_goods.prod-type = tmp#zakaz.prod-type and
                    buf_goods.prod-code = tmp#zakaz.prod-code no-error .
        assign
          tmp#zakaz.gds-code = buf_goods.gds-code
          v-not-corr-op  = 'no'
        .
        run ggoattr-value (
          input   buf_goods.grp-code
          ,input   v-cntxt-host-code-obj
          ,input   v-cntxt-obj-type
          ,input   v-cntxt-obj-code
          ,input   'NotCorrOP':U
          ,output  v-not-corr-op
          ,output  p-type ) no-error .
        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute("Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять расcчитанные количества  по Группе товаров (&2) &3 " ,
                  tmp#zakaz.initial-qnty ,
                  buf_goods.grp-code ,
                  buf_goods.grp-name ,
                  chr(10))
          view-as alert-box information .
          return error.
        end.
      end.
    end.
  end.
end.
end procedure.
PROCEDURE edoc-nn-proc :
if  (is-edoc-nn
and shar_ord-doc.whole-send-news = integer('1':U)
and
    ( shar_ord-doc.ord-int1 = int ('4':U) or
      shar_ord-doc.ord-int1 = int ('3':U)  or
      ( shar_ord-doc.ord-int1 = int ('0':U)  and
        shar_ord-doc.ord-int2 = int ('1':U))
      ) and
    ( shar_ord-doc.doc-type = 'ОП':U ) and
      shar_ord-doc.status_ = 'новый':U
      )
or  (is-edi
and shar_ord-doc.whole-send-news = integer('2':U)
and shar_ord-doc.ord-int1 = int ('3':U)
and shar_ord-doc.ord-int2 = int ('1':U)
and shar_ord-doc.doc-type = 'ОП':U
and shar_ord-doc.status_ = 'новый':U
)
 then do:
    display
      tmp#zakaz.order-cli-qnty
      tmp#zakaz.ord-dec1
      tmp#zakaz.sub-par
      with frame Dialog-Frame .
      if tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty then tmp#zakaz.order-cli-qnty:bgcolor = 12  .
         else tmp#zakaz.order-cli-qnty:bgcolor = 15  .
      if tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli then     tmp#zakaz.ord-dec1:bgcolor = 12 .
      else tmp#zakaz.ord-dec1:bgcolor = 15.
      .
  if shar_ord-doc.whole-send-news = integer('2':U) then do:
    disable
    tmp#zakaz.cli-art
    with frame Dialog-Frame .
  end.
end.
else do:
      hide
        tmp#zakaz.order-cli-qnty
        tmp#zakaz.ord-dec1
        tmp#zakaz.sub-par
        in frame Dialog-Frame .
end.
END PROCEDURE.
