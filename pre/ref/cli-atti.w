DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.clients-attr
       field user-can-edit as logical
       field output-display as logical
       field value_ as character
       field code as char
       INDEX attrc is
       UNIQUE PRIMARY
       obj-type
       obj-code
       code
       INDEX attrcl is UNIQUE
       attr-code
       obj-type
       obj-code
       index ioutput
       output-display.
DEFINE TEMP-TABLE tt0-clients-attr NO-UNDO LIKE ub.clients-attr.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-obj-type as char no-undo.
define input parameter p-obj-code as int no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-clients-attr.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты клиента ".
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
procedure clntattr-tank-farm-for :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tank-farm-for in g#attr-lib
      (input parparentproc
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
end procedure.
procedure clntattr-auto-tank-for :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-auto-tank-for in g#attr-lib
      (input parparentproc
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
end procedure.
procedure clntattr-owner-code :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-owner-code in g#attr-lib
      (input parparentproc
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
end procedure.
procedure clntattr-cli-for-close-fo :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-cli-for-close-fo in g#attr-lib
      (input parparentproc
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
end procedure.
procedure clntattr-cli-clim-grp :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-cli-clim-grp in g#attr-lib
      (input parparentproc
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
end procedure.
procedure clntattr-main-accholder :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
do
on error undo, return error
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-main-accholder in g#attr-lib
    (input  parparentproc
    ,input  p-obj-type
    ,input  p-obj-code
    ,input-output p-value
    ,output p-setted
    ) no-error .
  if error-status :error
  then do:
    message error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
end procedure.
procedure clntattr-veto-man-doc :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
do
on error undo, return error
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-veto-man-doc in g#attr-lib
    (input  parparentproc
    ,input  p-obj-type
    ,input  p-obj-code
    ,input-output p-value
    ,output p-setted
    ) no-error .
  if error-status :error
  then do:
    message error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-attr-property  no-undo
field upper-attr-code as character
field attr-code as character
field table-name as character
field edit-menu-section-num as integer
field attr-label as character
field menu-item-handle as widget-handle
field user-can-edit as logical
field menu-name as character
field parent-handle as handle
index pi is unique primary
table-name
menu-name
upper-attr-code
attr-code
index i-section
edit-menu-section-num
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure attr-pop-create-items :
define input parameter p-table-name as character no-undo .
define input parameter p-get-section-num-proc-name as character no-undo .
define input parameter p-get-attr-label-proc-name as character no-undo .
define input parameter p-attr-choose-proc-name as character no-undo .
define input parameter p-menu-handle as widget-handle no-undo .
define input parameter p-attr-list as character no-undo .
define variable ii as integer no-undo .
define variable V-CREATED as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-dop as character no-undo .
define variable v-attr-item as character no-undo .
define variable p-upper-attr-code as character no-undo .
define buffer buf_tt-attr-property for tt-attr-property.
  do
  on error undo, return error return-value
  :
     do ii = 1 to num-entries (p-attr-list):
       v-attr-item = entry(ii, p-attr-list) .
       find first tt-attr-property where
                 tt-attr-property.table-name = p-table-name
             and tt-attr-property.attr-code = v-attr-item
             and tt-attr-property.upper-attr-code = p-upper-attr-code
             and tt-attr-property.menu-name = p-menu-handle:name  no-error .
       if not available tt-attr-property then do:
         create tt-attr-property.
         assign
         tt-attr-property.table-name = p-table-name
         tt-attr-property.attr-code = v-attr-item
         tt-attr-property.upper-attr-code = p-upper-attr-code
         tt-attr-property.menu-name = p-menu-handle:name
         .
         run value ( p-get-section-num-proc-name) (
                                                   input tt-attr-property.attr-code
                                                  ,output tt-attr-property.edit-menu-section-num ) no-error .
         run value ( p-get-attr-label-proc-name ) (
                                        input tt-attr-property.attr-code
                                       ,output v-tool-tip
                                       ,output tt-attr-property.attr-label
                                      ) no-error .
         release tt-attr-property.
       end.
     end.
     for each tt-attr-property where tt-attr-property.menu-name = p-menu-handle:name
     break
     by  tt-attr-property.edit-menu-section-num
     by  tt-attr-property.attr-label
     :
       if tt-attr-property.edit-menu-section-num > 0
       then do:
          if not valid-handle(tt-attr-property.menu-item-handle) then do:
            if num-entries(tt-attr-property.attr-code, chr(4)) > 1
            and entry(2, tt-attr-property.attr-code, chr(4)) <> '':U
            then do:
              find first buf_tt-attr-property where
                        buf_tt-attr-property.table-name = p-table-name
                    and buf_tt-attr-property.menu-name = p-menu-handle:name
                    and buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                    and buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4)) no-error .
              if not available buf_tt-attr-property then do:
                create buf_tt-attr-property.
                assign
                buf_tt-attr-property.table-name = p-table-name
                buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4))
                buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                buf_tt-attr-property.menu-name = p-menu-handle:name
                .
                create sub-menu buf_tt-attr-property.menu-item-handle
                assign
                name = entry(1, tt-attr-property.attr-code, chr(4))  + chr(4)  + p-menu-handle:name
                parent = p-menu-handle.
              end.
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = tt-attr-property.attr-code  + chr(4)  + p-menu-handle:name
              parent = buf_tt-attr-property.menu-item-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name + "-2") (
                                                                         input  entry(1, tt-attr-property.attr-code, chr(4) )
                                                                        ,input entry(2, tt-attr-property.attr-code, chr(4) )
                                                                          ) .
              end triggers.
              assign
              v-created = yes.
            end.
            else do:
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = entry(1, tt-attr-property.attr-code, chr(4)) + chr(4)  + p-menu-handle:name
              parent = p-menu-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name) (
                                                                 input  entry(1, tt-attr-property.attr-code, chr(4) )) .
              end triggers.
              assign
              v-created = yes.
            end.
          end.
          if last-of(tt-attr-property.edit-menu-section-num)
            then do:
            find first buf_tt-attr-property where
                      buf_tt-attr-property.table-name = p-table-name
                 and  buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                         , p-table-name
                                                         , tt-attr-property.edit-menu-section-num
                                                         , p-menu-handle:name
                                                         )
                  and buf_tt-attr-property.menu-name = p-menu-handle:name  no-error .
            if not available buf_tt-attr-property then do:
              create buf_tt-attr-property.
              assign
              buf_tt-attr-property.table-name = p-table-name
              buf_tt-attr-property.edit-menu-section-num =  - 1
              buf_tt-attr-property.menu-name = p-menu-handle:name
              buf_tt-attr-property.upper-attr-code = ''
              buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                          , p-table-name
                                                          , tt-attr-property.edit-menu-section-num
                                                          , p-menu-handle:name
                                                          )
              .
              create menu-item buf_tt-attr-property.menu-item-handle
              assign
              subtype = "rule"
              parent = p-menu-handle
              .
            end.
          end.
       end.
     end.
     if not v-created then do:
        run attr-pop-clean-up in this-procedure ( input p-table-name).
     end.
  end.
end procedure.
procedure attr-pop-clean-up :
define input parameter p-table-name as character no-undo .
  for each tt-attr-property where
          tt-attr-property.table-name = p-table-name
    and tt-attr-property.edit-menu-section-num > 0:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
  for each tt-attr-property where
           tt-attr-property.table-name = p-table-name
       and tt-attr-property.edit-menu-section-num =  - 1:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
end procedure.
define variable updated as logical no-undo.
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE MENU MENU-b-ins .
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут клиента".
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут клиента".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут клиента".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE VARIABLE clients-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE clients-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 46.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE clients-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY BR-attr FOR
      Temp-hattr SCROLLING.
DEFINE BROWSE BR-attr
  QUERY BR-attr DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(255)":U WIDTH 50
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(255)":U WIDTH 48
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     b-help AT ROW 1 COL 95
     BR-attr AT ROW 4.47 COL 1
     clients-type AT ROW 3.3 COL 19 NO-LABEL
     clients-code AT ROW 3.3 COL 23.4 NO-LABEL
     clients-name AT ROW 3.3 COL 33.8 NO-LABEL
     SPACE(18.49) SKIP(15.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты клиента".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
OPEN QUERY BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BR-attr to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run clntattr-code in this-procedure (
                                        input  temp-hattr.code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для клиента " clients-name
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    DELETE temp-hattr.
    updated = yes.
   OPEN QUERY BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
   RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-attr :handle
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-attr :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if NOT (p-mode = 'ПРОСМОТР':U
        or p-mode = 'ИЗМЕНЕНИЕ':U
        or p-mode = 'ДОБАВЛЕНИЕ':U
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
    view-as alert-box ERROR.
    return error.
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input 'clients-attr':U ).
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY clients-type clients-code clients-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add b-chg b-del b-help clients-type clients-code
         clients-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
END PROCEDURE.
PROCEDURE init-proc :
define var  attr-type as character no-undo .
define var  attr-format as character no-undo .
define var  attr-label as character no-undo .
define var  attr-value as character no-undo .
define var  attr-user-can-edit as logical no-undo .
define var  attr-output-display as logical no-undo .
define var  attr-other as char no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.
for each  Temp-hattr:
  delete Temp-hattr.
end.
add-option = "".
IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
    find first buf_clients where buf_clients.obj-code =  p-obj-code
                   and buf_clients.obj-type =  p-obj-type
        no-lock no-error .
    Assign
        clients-type = buf_clients.obj-type
        clients-code = buf_clients.obj-code
        clients-name = buf_clients.obj-name
        .
  display
  clients-type
  clients-code
  clients-name
  with frame Dialog-Frame  .
END.
   For each tt0-clients-attr where
            tt0-clients-attr.obj-code = p-obj-code and
            tt0-clients-attr.obj-type  = p-obj-type
            no-lock :
    run clntattr-code in this-procedure (
                                          input tt0-clients-attr.attr-code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other ).
    run clntattr-value in this-procedure (
                          input tt0-clients-attr.obj-type
                        ,input tt0-clients-attr.obj-code
                        ,input tt0-clients-attr.attr-code
                        ,output attr-value
                        ,output attr-type ).
      create Temp-hattr.
      assign
      Temp-hattr.obj-type = tt0-clients-attr.obj-type
      Temp-hattr.obj-code = tt0-clients-attr.obj-code
      Temp-hattr.attr-code = (if attr-output-display
                              then attr-label
                              else tt0-clients-attr.attr-code)
      temp-hattr.value_ = attr-value
      Temp-hattr.attr-value = (if attr-type = 'L':U
                              then string(attr-value = "yes":U, attr-format)
                              else attr-value)
      Temp-hattr.user-can-edit = attr-user-can-edit
      Temp-hattr.output-display = attr-output-display
      Temp-hattr.code = tt0-clients-attr.attr-code
      .
    End.
    OPEN QUERY BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
b-add:POPUP-MENU IN FRAME Dialog-Frame  = MENU MENU-b-ins:HANDLE
b-add:MENU-MOUSE = 1
Temp-hattr.attr-code:RESIZABLE IN BROWSE br-attr = YES
Temp-hattr.attr-value:RESIZABLE IN BROWSE br-attr = YES
.
assign
v-tab-order = "b-exit,b-quit,b-add,b-chg,b-del,b-help,br-attr".
if p-mode <> 'ПРОСМОТР':U then do:
  run attr-pop-create-items in this-procedure  (
                                                 input 'clients-attr':U
                                                ,input 'clntattr-manual-edit'
                                                ,input 'clntattr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-ins:handle
                                                ,input 'doc-start,arh-detail,arh-start,ahsp-detail,ahsp-start,aht-detail,aht-start,arh-del,ahsp-del,aht-del,arh-calc,ahsp-calc,aht-calc,arh-recalc,ahsp-recalc,aht-recalc,is-inkassator,shftrep2,db,is-superviser,purch-code,als-gds,alien,envd,kpp,pharm,upd-date-time,holdfirm-code,vat-register,bge-incr-last-shift-date,bge-incr-last-shift-num,bge-sap-sng-last-shift,egrip-date,egrip-num,cli-local,cli-alc-producer,region-code,foreign-producer,main-accholder,not-corr-op,veto-man-doc,requisite-alc-decl,division-code,supp-np,own-supp,supp-lgas,tank-farm-for,NPZ,auto-tank-for,code-KSK,code-AIS,owner-code,cli-for-close-fo,cli-clim-grp,cli-decommissioned,exp-isPM-last-date':U
                                              ).
end.
ENABLE
b-exit when p-mode <> 'ПРОСМОТР':U
b-quit
b-del when p-mode <> 'ПРОСМОТР':U
b-add when p-mode <> 'ПРОСМОТР':U
b-chg when p-mode <> 'ПРОСМОТР':U
b-help BR-attr
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
OPEN QUERY BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
 if p-mode = 'ПРОСМОТР':U then do:
    hide
    b-exit
    in frame Dialog-Frame .
    assign
    b-quit:label = "&Выход"
    b-quit:col    = 1
    .
  end.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define var loc#log as logical no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
define variable jj as integer no-undo .
case p-add:
  when yes then do:
    run temp-clntattr-exist in this-procedure (
                                                input p-obj-type
                                                ,input p-obj-code
                                                ,input add-option
                                                ,output loc#log)  no-error.
    if error-status:error or loc#log then return error.
    run clntattr-code in this-procedure (
                                          input  add-option
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    CASE attr-type:
      when 'L':U then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when 'I':U or when 'D':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when 'T':U then do:
        assign
        v-attr-value = ?
        .
      end.
      when 'C':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run clntattr-code in this-procedure (
                                          input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении названия и типа атрибута клиента!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
    assign
    attr-value = temp-hattr.value_
    .
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
if v-spr = "":u then do:
  run gbl/d-prompt.w (
    'title=':u + "Изменение атрибута клиента" + '\':u
  + 'text1=':u + attr-label + '\':u
  + 'format=' + (if attr-type = 'L':U then "yes/no" else attr-format) + '\':u
  + 'type=' + attr-type + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=' + (if p-mode = 'ПРОСМОТР':U then 'yes':u else 'no':u) + '\':u
  , input-output attr-value
      ).
  if return-value = 'false':u then return error.
end.
else do:
  run  value(v-spr) in this-procedure (
                                       input p-obj-type
                                      ,input p-obj-code
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
  if not v-setted then return error.
end.
  run temp-clntattr-write in this-procedure (
                                    input p-obj-type
                                    ,input p-obj-code
                                    ,input (if p-add then add-option else temp-hattr.code)
                                    ,input attr-value
                                   ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
      br-attr:refresh() in frame Dialog-Frame no-error .
  END.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
for each temp-hattr NO-LOCK where
       temp-hattr.obj-type = p-obj-type
   AND temp-hattr.obj-code = p-obj-code :
  if temp-hattr.output-display = no then next.
   find first tt0-clients-attr NO-LOCK WHERE
          tt0-clients-attr.obj-type = temp-hattr.obj-type
    AND   tt0-clients-attr.obj-code = temp-hattr.obj-code
    AND   tt0-clients-attr.attr-code = temp-hattr.code no-error.
  assign
  v-updated = no.
  if available  tt0-clients-attr then do:
    BUFFER-COMPARE temp-hattr
                TO tt0-clients-attr
                case-sensitive
                SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    run tt0-clntattr-write in this-procedure (
                                     input p-obj-type
                                    ,input p-obj-code
                                    ,input temp-hattr.code
                                    ,input temp-hattr.value_)  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении атрибута клиента" skip
      "тип" p-obj-type SKIP
      "код" p-obj-code SKIP
      "Атрибут" temp-hattr.attr-code skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-clients-attr where
         tt0-clients-attr.obj-type = p-obj-type
    AND  tt0-clients-attr.obj-code = p-obj-code:
  FIND FIRST temp-hattr NO-LOCK WHERE
            temp-hattr.obj-type = tt0-clients-attr.obj-type
        AND temp-hattr.obj-code = tt0-clients-attr.obj-code
        AND temp-hattr.code = tt0-clients-attr.attr-code NO-ERROR.
    IF NOT AVAILABLE temp-hattr THEN DO:
      DELETE tt0-clients-attr.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/cli-atr1.p (
                     input p-mode
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-clients-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов клиента:&1&2&1&3"
               , chr(10)
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
    undo, return error .
  end.
end.
END PROCEDURE.
PROCEDURE temp-clntattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_temp-hattr for temp-hattr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure (
                                          input  p-code
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
    find first buf_temp-hattr no-lock
      where buf_temp-hattr.obj-type  = p-obj-type
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.attr-code = p-code
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.
END PROCEDURE.
PROCEDURE temp-clntattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .
    define buffer buf_temp-hattr for temp-hattr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure (
                                          input  p-code
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
    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.obj-type  = p-obj-type
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.code = p-code
      no-error .
    if not available buf_temp-hattr then do:
      create buf_temp-hattr .
      assign
        buf_temp-hattr.obj-type  = p-obj-type
        buf_temp-hattr.obj-code  = p-obj-code
        buf_temp-hattr.attr-code = v-label
        buf_temp-hattr.code      = p-code
        buf_temp-hattr.attr-value = (if v-type = 'L':U then string(logical(p-value), v-format) else p-value)
        buf_temp-hattr.value_ = p-value
        buf_Temp-hattr.output-display = v-output-display
      .
    end.
    assign
    buf_temp-hattr.value_ = p-value
    buf_temp-hattr.attr-value = (if v-type = 'L':U then string(logical(p-value), v-format) else p-value)
    .
    release buf_temp-hattr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 клиента &2&3: &4 &5"
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.
END PROCEDURE.
PROCEDURE tt0-clntattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .
    define buffer buf_tt0-clients-attr for tt0-clients-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run clntattr-code in this-procedure (
                                          input  p-code
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
    find first buf_tt0-clients-attr exclusive-lock
      where buf_tt0-clients-attr.obj-type  = p-obj-type
        and buf_tt0-clients-attr.obj-code  = p-obj-code
        and buf_tt0-clients-attr.attr-code = p-code
      no-error .
    if not available buf_tt0-clients-attr then do:
      create buf_tt0-clients-attr .
      assign
        buf_tt0-clients-attr.obj-type  = p-obj-type
        buf_tt0-clients-attr.obj-code  = p-obj-code
        buf_tt0-clients-attr.attr-code = p-code
      .
    end.
    assign
      buf_tt0-clients-attr.attr-value = p-value
    .
    release buf_tt0-clients-attr no-error.
    if error-status:error then do:
      return error RETURN-VALUE.
    end.
  end.
END PROCEDURE.
