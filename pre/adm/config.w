DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_currency FOR ub.currency.
DEFINE BUFFER locked_firm FOR ub.firm.
DEFINE BUFFER locked_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-firm NO-UNDO LIKE ub.firm.
DEFINE TEMP-TABLE tt-sysconf NO-UNDO LIKE ub.sysconf.
define input parameter parParentProc  as   widget-handle        no-undo .
define input parameter p-host-code    like ub.sysconf.host-code no-undo .
define input parameter p-mode         as   character            no-undo .
define input parameter p-is-deploy    as   logical              no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Настройки фирмы":U .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-b-attr :
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-sts as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable ii as integer no-undo .
define variable v-attr-code like ub.clients-attr.attr-code no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable attr-value as char no-undo .
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-firm-code as integer   no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found as decimal no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
do
on error undo, return error
:
assign
vattr-codes = "":U
vattr-labels = "":U
.
_II:
DO ii = 1 to num-entries('autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U):
  run thbjattr_code (
                       input entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
                      ,input   '':U
                      ,output  attr-label
                      ,output  attr-user-can-edit
                      ,output  attr-output-display
                      ,output  attr-other
                      ,output v-prop-list
                      ,output v-prop-type-list
                      ,output v-prop-label-list
                      ,output v-global
                      ,output v-host
                      ,output v-shop
                      ,output v-store
                      ,output v-db
                    ) no-error.
    .
    if NOT error-status:error
    and attr-user-can-edit
    and index(attr-other, "spr-ext=") > 0
    anD (if p-obj-type = 'маг':U
         then v-shop
         else (if p-obj-type = 'скл':U
               then v-store
               else (if p-obj-type = 'орг':U
                     then v-host
                     else (if p-obj-type = 'БД':U
                          then v-db
                          else v-global)
                    )
               )
         ) then do:
      if entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U) = 'alias-tpsi':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
        if error-status:error
        or (conf-par <> "yes") then next _ii.
      end.
      assign
      vattr-codes = vattr-codes + chr(44) + entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
      vattr-labels = vattr-labels + chr(44) + attr-label
      .
    end.
end.
CASE p-mode:
  when 'ПРОСМОТР':U then do:
    assign
    v-title = "Выберите типы параметров для просмотра".
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для редактирования".
  end.
  when  'КОПИРОВАНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для копирования".
  end.
END CASE.
run gbl/d-list.w (
               INPUT (if p-mode = 'КОПИРОВАНИЕ':U then "b-sel,b-mark":U else "b-sel":U)
              ,INPUT v-title
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-attr-code).
IF v-attr-code = "":u THEN do:
  RETURN ''.
end.
if p-mode = 'ПРОСМОТР':U
or p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run thbjattr_code  in this-procedure (
       input   v-attr-code
      ,input   '':U
      ,output  attr-label
      ,output  attr-user-can-edit
      ,output  attr-output-display
      ,output  attr-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
  ).
  do ii = 1 to num-entries(attr-other, chr(47)):
    if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ).
end.
else do:
   if p-obj-type = 'маг':U then do:
    message
    "Выберите магазин для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/shops.w ( input parparentproc
                       ,input "b-sel"
                       ,input-output v-rid-list
                       ,no ).
     if v-rid-list = "":U then return.
     find first buf_shop no-lock where
              recid(buf_shop) = integer(v-rid-list) .
     v-from-obj-code = buf_shop.obj-code.
   end.
   if p-obj-type = 'орг':U then do:
      message
      "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
   end.
   if p-obj-type = 'скл':U then do:
    message
    "Выберите склад для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/stores.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output v-rid-list
                        ,input no ).
     if v-rid-list = "":U then return.
     find first buf_store no-lock where
              recid(buf_store) = integer(v-rid-list) .
     v-from-obj-code = buf_store.obj-code.
   end.
   if p-obj-type = 'БД':U then do:
      message
      "Выберите БД для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/dbs.w (
            input parParentProc
          , input 'ПРОСМОТР':U
          , output v-rec
      ) no-error.
      if v-rec = ? then return.
    find first buf_db no-lock
                      where recid(buf_db) = v-rec.
    v-from-obj-code = buf_db.db-num.
   end.
   if (p-obj-type = 'маг':U
   AND p-obj-code = buf_shop.obj-code )
   or (p-obj-type = 'скл':U
   AND p-obj-code = buf_store.obj-code )
   or (p-obj-type = 'орг':U
   AND p-obj-code = buf_sysconf.host-code )
   or (p-obj-type = 'БД':U
   AND p-obj-code = buf_db.db-num )
   or (p-obj-type = '':U
   AND p-obj-code = 0 )
   then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   run waitfram-show in this-procedure ( input "Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-ii = v-ii + 1.
      run thbjattr_get-section  in this-procedure (
           input  p-obj-type
          ,input  v-from-obj-code
          ,input  entry(ii, v-attr-code)
          ,input '':U
          ,input-output table thbjattr_thbj-attr
          ,output v-found
                                              ) no-error .
      if not error-status:error then do:
        run thbjattr_set-section in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input table thbjattr_thbj-attr ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
      end.
   end.
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5 на &2&3"
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с &3&4 на &5&6"
                 , v-ii
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box WARNING.
   end.
end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable conf-par as   character    no-undo .
define variable par-type as   character    no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable hold     as   character    no-undo .
define variable ref-list as   character    no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.
DEFINE BUFFER buf_curr-chk FOR ub.currency.
define buffer buf_cp_credit-pay for ub.cash-pay.
define buffer buf_pt_ret-credit-pay for ub.pay-type.
define buffer buf_pt_cash-pay for ub.pay-type.
define buffer buf_cli_sale-code for ub.clients.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
DEFINE MENU MENU-host-code
       MENU-ITEM m_choose       LABEL "Подобрать свободный код".
DEFINE BUTTON B-attr
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-base-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-cash-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-credit-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-hold-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ret-credit-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-sale-type-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.
DEFINE BUTTON B-transport
     LABEL "Т&ранспорт"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_trn-reason
     LABEL "Коды оснований (причин)"
     SIZE 25 BY 1 TOOLTIP "Код оснований (причин) создания документов по умолчанию на фирме".
DEFINE VARIABLE varpurch-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE base-code-name AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 6.6 BY 1 TOOLTIP "Аббревиатура базовой валюты"
     BGCOLOR 3 FGCOLOR 15 .
DEFINE VARIABLE cash-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE credit-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE fi-egrip-date AS DATE FORMAT "99.99.9999":U
     LABEL "ЕГРИП Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fi-egrip-num AS CHARACTER FORMAT "X(15)":U
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE hold-arh-title AS CHARACTER FORMAT "X(256)":U INITIAL "Межфирменные архивы"
      VIEW-AS TEXT
     SIZE 20.8 BY .57 NO-UNDO.
DEFINE VARIABLE main-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40.3 BY .87 NO-UNDO.
DEFINE VARIABLE main-obj-title AS CHARACTER FORMAT "X(256)":U INITIAL "Главный объект:"
      VIEW-AS TEXT
     SIZE 19.6 BY .77 NO-UNDO.
DEFINE VARIABLE ret-credit-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE sale-code-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 57 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.8 BY 7.53.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90.6 BY 1.3.
DEFINE VARIABLE varals-gds AS LOGICAL INITIAL no
     LABEL "Торговля чужим товаром"
     VIEW-AS TOGGLE-BOX
     SIZE 34.5 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-sysconf,
      tt-clients,
      tt-firm SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-transport AT ROW 1 COL 34
     Btn_trn-reason AT ROW 1 COL 44
     B-attr AT ROW 1 COL 69
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-sysconf.host-code AT ROW 2 COL 7 COLON-ALIGNED
          LABEL "Фирма" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 6 BY 1 TOOLTIP "Код текущей фирмы (доступен только при добавлении)"
          BGCOLOR 3 FGCOLOR 15
     tt-clients.obj-name AT ROW 2 COL 13.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 45.6 BY 1 TOOLTIP "Название фирмы (видно только для текущей фирмы)"
          BGCOLOR 3 FGCOLOR 15
     tt-sysconf.base-code AT ROW 2 COL 76 COLON-ALIGNED
          LABEL "Базовая валюта"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Код базовой валюты для текущей фирмы (доступен при добавлении фирмы)"
          BGCOLOR 3 FGCOLOR 15
     b-base-code AT ROW 2 COL 82.5 WIDGET-ID 4
     base-code-name AT ROW 2 COL 86.5 COLON-ALIGNED NO-LABEL
     tt-sysconf.sale-type AT ROW 3.27 COL 21 COLON-ALIGNED
          LABEL "Тип и код реализации"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Тип контрагента для розничных продаж"
     tt-sysconf.sale-code AT ROW 3.27 COL 26 COLON-ALIGNED NO-LABEL FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Код контрагента для розничных продаж"
     B-sale-type-code AT ROW 3.27 COL 38.5 WIDGET-ID 10
     tt-sysconf.cash-pay AT ROW 4.37 COL 15 COLON-ALIGNED
          LABEL "Опл. наличными"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     B-cash-pay AT ROW 4.37 COL 22.5 WIDGET-ID 8
     tt-sysconf.credit-pay AT ROW 4.37 COL 69 COLON-ALIGNED
          LABEL "Платеж в кредит на кассе"
          VIEW-AS FILL-IN
          SIZE 5 BY 1 TOOLTIP "Код оплаты товаров, продаваемых в кредит в розницу"
     B-credit-pay AT ROW 4.37 COL 76
     tt-sysconf.cons-vat-pc AT ROW 5.5 COL 21 COLON-ALIGNED
          LABEL "Консигнационный НДС"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-sysconf.ret-credit-pay AT ROW 5.5 COL 69 COLON-ALIGNED
          LABEL "Опл. долгов по кредиту" FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     B-ret-credit-pay AT ROW 5.5 COL 76
     tt-sysconf.osn-base AT ROW 6.5 COL 1.8
          LABEL "Учет ОС в баз. вал."
          VIEW-AS TOGGLE-BOX
          SIZE 27.8 BY .83 TOOLTIP "Учет ОС не только в abbr_rublyah, но и в баз. вал."
     tt-sysconf.negative-rest AT ROW 6.5 COL 31.3
          LABEL "Отрицательные остатки"
          VIEW-AS TOGGLE-BOX
          SIZE 24.3 BY .83 TOOLTIP "Начальное значение при добавлении новых товаров"
     varpurch-name AT ROW 6.5 COL 72 COLON-ALIGNED
     tt-sysconf.avrg-price AT ROW 7.5 COL 1.8
          LABEL "Посредник (для отчетов)"
          VIEW-AS TOGGLE-BOX
          SIZE 27.3 BY .83 TOOLTIP "Считать данную фирму посредником для отчетов"
     tt-sysconf.artic-disable AT ROW 7.5 COL 31.3
          LABEL "Автомат. артикул"
          VIEW-AS TOGGLE-BOX
          SIZE 24.8 BY .83 TOOLTIP "Начальное значение при добавлении новых товаров"
     varals-gds AT ROW 7.5 COL 56.6
     tt-sysconf.gen-s-f-office AT ROW 8.47 COL 56.6 WIDGET-ID 2
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .83
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     fi-egrip-date AT ROW 8.77 COL 12 COLON-ALIGNED
     fi-egrip-num AT ROW 8.77 COL 34 COLON-ALIGNED
     tt-firm.main-obj-code AT ROW 11.2 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11.9 BY 1
     tt-firm.main-obj-type AT ROW 11.2 COL 34.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 7.4 BY 1
     B-hold-obj AT ROW 11.2 COL 45.1
     tt-sysconf.head-position AT ROW 14.43 COL 19.6 COLON-ALIGNED
          LABEL "Должность рук-ля"
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     tt-sysconf.snr-accnt AT ROW 16.7 COL 28 COLON-ALIGNED
          LABEL "Главный бухгалтер"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-sysconf.cashier AT ROW 17.7 COL 28 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-sysconf.branch AT ROW 18.7 COL 28 COLON-ALIGNED
          LABEL "Отрасль (вид деятельности)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1 TOOLTIP "Отрасль (вид деятельности)"
     tt-sysconf.property AT ROW 19.7 COL 28 COLON-ALIGNED
          LABEL "Организ.-правовая форма"
          VIEW-AS FILL-IN
          SIZE 38.1 BY 1
     tt-sysconf.KOPF AT ROW 20.7 COL 28 COLON-ALIGNED
          LABEL "КОПФ"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-sysconf.SOEI AT ROW 21.7 COL 28 COLON-ALIGNED
          LABEL "СОЕИ"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     sale-code-name AT ROW 3.27 COL 39.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cash-pay-name AT ROW 4.37 COL 23.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     credit-pay-name AT ROW 4.37 COL 77.8 COLON-ALIGNED NO-LABEL
     ret-credit-pay-name AT ROW 5.5 COL 77.6 COLON-ALIGNED NO-LABEL
     hold-arh-title AT ROW 10.27 COL 1.5 NO-LABEL
     main-obj-title AT ROW 11.3 COL 2.9 NO-LABEL
     main-obj-name AT ROW 11.3 COL 48 COLON-ALIGNED NO-LABEL
     " Бухгалтерия" VIEW-AS TEXT
          SIZE 13.8 BY 1 AT ROW 15.5 COL 38
     RECT-1 AT ROW 15.77 COL 1
     RECT-2 AT ROW 11.03 COL 1
     SPACE(7.64) SKIP(11.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки фирмы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-sysconf.host-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-host-code:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF tt-sysconf.avrg-price IN FRAME Dialog-Frame
DO:
  assign
    tt-sysconf.avrg-price
  .
  display
    tt-sysconf.avrg-price
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
  run proc-b-attr in this-procedure
    (input 'ПРОСМОТР':U
    ,input 'орг':U
    ,input locked_sysconf.host-code
    ) no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON CHOOSE OF b-base-code IN FRAME Dialog-Frame
DO:
  RUN local-curr-chk in this-procedure ("base-code", "button").
  apply "entry" to tt-sysconf.base-code in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-cash-pay IN FRAME Dialog-Frame
DO:
  RUN local-payt-chk in this-procedure ("cash-pay", "button").
  apply "entry" to tt-sysconf.cash-pay in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-credit-pay IN FRAME Dialog-Frame
DO:
  RUN local-cp-chk in this-procedure ("credit-pay", "button").
  apply "entry" to tt-sysconf.credit-pay in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply.
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo .
  run ref/cclihist.w
    (input parparentproc
    ,input 0
    ,input '':U
    ,input 0
    ,input '':U
    ,input 'one':U
    ,input 'орг':U
    ,input tt-firm.firm-code
    ,input ?
    ,input ?
    ,input '':U
    ,input '':U
    ,input v-cntxt-db-num
    ,input-output v-rid-list
    ) no-error .
END.
ON CHOOSE OF B-hold-obj IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define buffer   buf_clients for ub.clients.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  p-host-code
  ,input  ''
  ,input  0
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
  end.
  else do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      .
    assign
      tt-firm.main-obj-code:screen-value = string(buf_clients.obj-code)
      tt-firm.main-obj-code
      main-obj-name:screen-value = buf_clients.obj-name
      main-obj-name
      tt-firm.main-obj-type:screen-value = buf_clients.obj-type
      tt-firm.main-obj-type
    .
  end.
END.
ON CHOOSE OF B-ret-credit-pay IN FRAME Dialog-Frame
DO:
  RUN local-payt-chk in this-procedure ("ret-credit-pay", "button").
  apply "entry" to tt-sysconf.ret-credit-pay in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-sale-type-code IN FRAME Dialog-Frame
DO:
  RUN local-cli-chk in this-procedure ("sale-code", "sale-type", "button").
  apply "entry" to tt-sysconf.sale-code in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-transport IN FRAME Dialog-Frame
DO:
  define variable v-transport-type as integer   no-undo .
  run adm/conftran.w
    (input  p-mode
    ,input  'sysconf':U
    ,input  p-host-code
    ,input  parParentProc
    ,input-output tt-sysconf.transport-cli-type
    ,input-output tt-sysconf.transport-cli-code
    ,input-output tt-sysconf.transport-host
    ,input-output tt-sysconf.transport-contract
    ,input-output tt-sysconf.transport-uslov
    ,input-output tt-sysconf.transport-value
    ,input-output v-transport-type
    ).
END.
ON LEAVE OF tt-sysconf.base-code IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-sysconf.base-code <> tt-sysconf.base-code then do:
    run local-curr-chk in this-procedure ("base-code", "leave").
  end.
END.
ON RETURN OF tt-sysconf.base-code IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.base-code IN FRAME Dialog-frame
DO:
  run local-curr-chk in this-procedure ("base-code", "ret-mouse").
  apply "entry" to tt-sysconf.base-code in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF Btn_trn-reason IN FRAME Dialog-Frame
DO:
  run str/host-rsn.w (
                   input parparentproc
                 , input p-host-code
                 , input ( if p-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'работа':U )
                 ) .
END.
ON LEAVE OF tt-sysconf.cash-pay IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame tt-sysconf.cash-pay <> tt-sysconf.cash-pay then do:
  end.
END.
ON RETURN OF tt-sysconf.cash-pay IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.cash-pay IN FRAME Dialog-frame
DO:
  run local-payt-chk in this-procedure ("cash-pay", "ret-mouse").
  apply "entry" to tt-sysconf.cash-pay in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-sysconf.credit-pay IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-sysconf.credit-pay <> tt-sysconf.credit-pay then do:
  end.
END.
ON RETURN OF tt-sysconf.credit-pay IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.credit-pay IN FRAME Dialog-frame
DO:
 run local-cp-chk in this-procedure ("credit-pay", "ret-mouse").
  apply "entry" to tt-sysconf.credit-pay in frame Dialog-Frame.
  return no-apply.
END.
ON VALUE-CHANGED OF tt-sysconf.gen-s-f-office IN FRAME Dialog-Frame
DO:
  assign tt-sysconf.gen-s-f-office .
  if tt-sysconf.gen-s-f-office = no then message
    "При установке данной настройки не будут формироваться С-Ф по ФО и Платежам на УБД"
    view-as alert-box INFORMATION TITLE "Внимание!" .
END.
ON CHOOSE OF MENU-ITEM m_choose
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
   run ref/chs-code.w
     (input  'орг':U
     ,input  v-cntxt-db-num
     ,output v-obj-code
     ) no-error .
  if not error-status :error
  and v-obj-code <> ?
  then do:
    if v-obj-code > 99999 then do:
      message
      "Кoд фирмы не может быть больше 99999"
      view-as alert-box error .
      return no-apply.
    end.
    display
      v-obj-code @ tt-sysconf.host-code
      with frame Dialog-Frame .
  end.
END.
ON LEAVE OF tt-sysconf.ret-credit-pay IN FRAME Dialog-Frame
DO:
 if input frame Dialog-Frame tt-sysconf.ret-credit-pay <> tt-sysconf.ret-credit-pay then do:
  end.
END.
ON RETURN OF tt-sysconf.ret-credit-pay IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.ret-credit-pay IN FRAME Dialog-frame
DO:
run local-payt-chk in this-procedure ("ret-credit-pay", "ret-mouse").
  apply "entry" to tt-sysconf.ret-credit-pay in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-sysconf.sale-code IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-sysconf.sale-code <> tt-sysconf.sale-code then do:
    run local-cli-chk in this-procedure ("sale-code", "sale-type", "leave").
  end.
END.
ON RETURN OF tt-sysconf.sale-code IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.sale-code IN FRAME Dialog-frame
DO:
  run local-cli-chk in this-procedure ("sale-code", "sale-type", "ret-mouse").
  apply "entry" to tt-sysconf.sale-code in frame Dialog-Frame.
  return no-apply.
END.
ON VALUE-CHANGED OF varals-gds IN FRAME Dialog-Frame
DO:
  ASSIGN
    FRAME Dialog-Frame varals-gds.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of fi-egrip-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of fi-egrip-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of fi-egrip-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of fi-egrip-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of fi-egrip-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of fi-egrip-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date13
    MENU-ITEM m-ed-date13-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date13-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date13-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date13-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fi-egrip-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      fi-egrip-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date13 :HANDLE
      fi-egrip-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle13 as handle no-undo .
  assign
    v-label-handle13 = fi-egrip-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle13)
  then do:
    if v-label-handle13 :tooltip = ""
    or v-label-handle13 :tooltip = ?
    then do:
      assign
        v-label-handle13 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date13-1 in menu m-ed-date13 DO:
    apply "ctrl-b":U to fi-egrip-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-2 in menu m-ed-date13 DO:
    apply "ctrl-d":U to fi-egrip-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-3 in menu m-ed-date13 DO:
    apply "ctrl-e":U to fi-egrip-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-4 in menu m-ed-date13 DO:
    apply "ctrl-f":U to fi-egrip-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if  p-mode <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error .
    undo, return error.
  end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  if p-mode <> 'ПРОСМОТР':U
  then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ФИРМЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-sysconf
  :
    delete tt-sysconf.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  for each tt-firm
  :
    delete tt-firm.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U
  then do:
    create tt-sysconf .
    create tt-clients .
    create tt-firm .
    if p-host-code = ?
    or p-host-code = 0
    then do:
      assign
        p-host-code = tt-sysconf.host-code
      .
    end.
    assign
      tt-sysconf.firm-db-num = 0
      tt-sysconf.ord-prt     = yes
      tt-sysconf.purch-code  = integer('1':U)
      tt-sysconf.sale-type = 'орг':U
    .
    if not p-is-deploy
    then do:
      message
        "Вам следует выбрать группу," skip
        "к которой будет относиться СВОЯ ФИРМА." skip
        view-as alert-box .
      assign
        ref-list = '':U
      .
      run ref/cli-grps.w
        (input  parparentproc
        ,input  "b-sel"
        ,input-output ref-list
        ) .
      if ref-list <> ""
      then do:
        find buf_cli-grp
          where recid( buf_cli-grp ) = integer( ref-list )
          .
        if can-find( first ub.cli-grp where
                          ub.cli-grp.upper-code = buf_cli-grp.node-code )
        then do:
          message
            "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !" skip
            view-as alert-box information .
          return .
        end.
        assign
          tt-clients.grp-code = buf_cli-grp.node-code
        .
      end.
      else do:
        return .
      end.
    end.
    else do:
      find first locked_clients exclusive-lock
        where locked_clients.obj-type = 'орг':U
        and (p-host-code = 0 or locked_clients.obj-code = p-host-code)
        no-wait
        no-error
        .
      if not available locked_clients
      then do:
        if locked locked_clients
        then do:
          find first locked_clients exclusive-lock
            where locked_clients.obj-type = 'орг':U
            no-error  .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись клиент для свой фирмы" skip
            view-as alert-box error .
        end.
        undo, return error .
      end.
      find first locked_firm exclusive-lock
        where locked_firm.firm-code = locked_clients.obj-code
        no-wait
        no-error
        .
      if not available locked_firm
      then do:
        if locked locked_firm
        then do:
          find first locked_firm exclusive-lock
            where locked_firm.firm-code = locked_clients.obj-code
            no-error
            .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись фирма для свой фирмы" skip
            view-as alert-box error .
        end.
        undo, return error.
      end.
      buffer-copy locked_clients to tt-clients .
      buffer-copy locked_firm to tt-firm .
      tt-sysconf.host-code = tt-clients.obj-code.
    end.
  end.
  else do:
    if p-mode = 'ИЗМЕНЕНИЕ':U
    then do:
      find first locked_sysconf exclusive-lock
        where locked_sysconf.host-code = p-host-code
        no-wait
        no-error .
      if not available locked_sysconf
      then do:
        if locked locked_sysconf
        then do:
          find first locked_sysconf exclusive-lock
            where locked_sysconf.host-code = p-host-code
            no-error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске фирмы" skip
            "Код фирмы" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error.
      end.
      find first locked_clients exclusive-lock
        where locked_clients.obj-code = locked_sysconf.host-code
          and locked_clients.obj-type = 'орг':U
        no-wait
        no-error .
      if not available locked_clients
      then do:
       if locked locked_clients
        then do:
          find first locked_clients exclusive-lock
            where locked_clients.obj-code = locked_sysconf.host-code
              and locked_clients.obj-type = 'орг':U
            no-error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись КЛИЕНТ для СВОЕЙ ФИРМЫ" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error.
      end.
      find first locked_firm exclusive-lock
        where locked_firm.firm-code = locked_sysconf.host-code
        no-wait
        no-error
        .
      if not available locked_firm
      then do:
        if locked locked_firm
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Запись ФИРМА для СВОЕЙ ФИРМЫ" p-host-code "занята"
            view-as alert-box error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись ФИРМА для СВОЕЙ ФИРМЫ" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error .
      end.
    end.
    if p-mode = 'ПРОСМОТР':U
    then do:
      find first locked_sysconf no-lock
        where locked_sysconf.host-code = p-host-code
        .
      find first locked_clients no-lock
        where locked_clients.obj-code = locked_sysconf.host-code
          and locked_clients.obj-type = 'орг':U
        .
      find first locked_firm no-lock
        where locked_firm.firm-code = locked_sysconf.host-code
        .
    end.
    if not available locked_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Недоступна запись текущей фирмы locked_sysconf" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first locked_currency no-lock
      where locked_currency.curr-code = locked_sysconf.base-code
      no-error .
    if not available locked_currency
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена базовая валюта для фирмы" locked_sysconf.host-code skip
        "Код валюты" locked_sysconf.base-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    create tt-clients.
    create tt-sysconf.
    create tt-firm.
    buffer-copy locked_clients to tt-clients.
    buffer-copy locked_sysconf to tt-sysconf.
    buffer-copy locked_firm to tt-firm.
  end.
  run myenable in this-procedure
    no-error .
  if error-status :error
  then do:
    return error return-value .
  end.
  view frame Dialog-Frame.
  wait-for go of frame Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY base-code-name varpurch-name varals-gds fi-egrip-date fi-egrip-num
          sale-code-name cash-pay-name credit-pay-name ret-credit-pay-name
          hold-arh-title main-obj-title main-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-firm THEN
    DISPLAY tt-firm.main-obj-code tt-firm.main-obj-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-sysconf THEN
    DISPLAY tt-sysconf.host-code tt-sysconf.base-code tt-sysconf.sale-type
          tt-sysconf.sale-code tt-sysconf.cash-pay tt-sysconf.credit-pay
          tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay tt-sysconf.osn-base
          tt-sysconf.negative-rest tt-sysconf.avrg-price
          tt-sysconf.artic-disable tt-sysconf.gen-s-f-office
          tt-sysconf.head-position tt-sysconf.snr-accnt tt-sysconf.cashier
          tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-transport Btn_trn-reason B-attr B-hist B-Help RECT-1
         RECT-2 b-base-code tt-sysconf.sale-type tt-sysconf.sale-code
         B-sale-type-code tt-sysconf.cash-pay B-cash-pay tt-sysconf.credit-pay
         B-credit-pay tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay
         B-ret-credit-pay tt-sysconf.negative-rest varpurch-name
         tt-sysconf.avrg-price tt-sysconf.artic-disable varals-gds
         tt-sysconf.gen-s-f-office fi-egrip-date fi-egrip-num
         tt-firm.main-obj-code tt-firm.main-obj-type B-hold-obj
         tt-sysconf.head-position tt-sysconf.snr-accnt tt-sysconf.cashier
         tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI
         sale-code-name cash-pay-name credit-pay-name ret-credit-pay-name
         hold-arh-title main-obj-title main-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE gen-code :
define output parameter p-firm-code like ub.firm.firm-code no-undo.
def variable ii as integer no-undo.
define buffer buf_firm for ub.firm.
do ii = 1 to 99999:
    find first buf_firm no-lock where
                buf_firm.firm-code = ii no-error.
    if not available buf_firm
    then do:
        assign
        p-firm-code = ii.
        return.
    end.
END.
END PROCEDURE.
PROCEDURE local-cli-chk :
define input parameter p-man    as character no-undo.
define input parameter p-man2 as character no-undo .
define input parameter p-action as character no-undo.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "ret-mouse" then do:
  define variable v-ref-rec16   as recid no-undo .
  define variable ref-list16 as character no-undo .
  find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                 and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
  if not available buf_cli_sale-code or lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) = 0 then do:
    if input frame Dialog-Frame tt-sysconf.sale-code <> ""
       and input frame Dialog-Frame tt-sysconf.sale-code <> ? then
      message substitute("Из справочника клиентов Вы должны выбрать &1.", ('орг':U + chr(44) + 'чел':U)).
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input ?
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec16
                  ,  input ",,,,,,NO"
                  ,  input ""
                  , output ref-list16 ) .
    assign v-ref-rec16 = integer( ref-list16 ).
    find buf_cli_sale-code where recid (buf_cli_sale-code) =
       v-ref-rec16
       no-lock no-error.
    if not available buf_cli_sale-code or lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) = 0 then
      find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                       and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
  end.
  if available buf_cli_sale-code and lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) > 0 then do:
    display buf_cli_sale-code.obj-code @ tt-sysconf.sale-code
            buf_cli_sale-code.obj-type @ tt-sysconf.sale-type
            buf_cli_sale-code.obj-name @ sale-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.sale-code.
  end.
  else do:
     display
     ? @ tt-sysconf.sale-code
     ? @ sale-code-name with frame Dialog-Frame.
  end.
  apply "entry" to b-sale-type-code in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "button" then do:
  define variable v-ref-rec17   as recid no-undo .
  define variable ref-list17 as character no-undo .
  find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                 and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
  assign v-ref-rec17 = ( if available buf_cli_sale-code then recid( buf_cli_sale-code ) else ? ).
  release buf_cli_sale-code.
  if not available buf_cli_sale-code or lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) = 0 then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input ?
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec17
                  ,  input ",,,,,,NO"
                  ,  input ""
                  , output ref-list17 ) .
    assign v-ref-rec17 = integer( ref-list17 ).
    find buf_cli_sale-code where recid (buf_cli_sale-code) =
       v-ref-rec17
       no-lock no-error.
    if not available buf_cli_sale-code or lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) = 0 then
      find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                       and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
  end.
  if available buf_cli_sale-code and lookup(buf_cli_sale-code.obj-type, ('орг':U + chr(44) + 'чел':U) ) > 0 then do:
    display buf_cli_sale-code.obj-code @ tt-sysconf.sale-code
            buf_cli_sale-code.obj-type @ tt-sysconf.sale-type
            buf_cli_sale-code.obj-name @ sale-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.sale-code.
  end.
  else do:
     display
     ? @ tt-sysconf.sale-code
     ? @ sale-code-name with frame Dialog-Frame.
  end.
  apply "entry" to b-sale-type-code in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "leave" then do:
  define variable v-ref-rec18   as recid no-undo .
  define variable ref-list18 as character no-undo .
  find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                 and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
if available buf_cli_sale-code then do:
    display
    buf_cli_sale-code.obj-code @ tt-sysconf.sale-code
    buf_cli_sale-code.obj-type @ tt-sysconf.sale-type
    buf_cli_sale-code.obj-name @ sale-code-name
    with frame Dialog-Frame.
        assign frame Dialog-Frame tt-sysconf.sale-code  tt-sysconf.sale-type.
end.
else do:
  display
  ? @ tt-sysconf.sale-code
  ? @ sale-code-name with frame Dialog-Frame.
end.
end.
END PROCEDURE.
PROCEDURE local-cp-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "credit-pay" and p-action = "ret-mouse" then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list20   as character no-undo .
  find buf_cp_credit-pay where buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
                 no-lock no-error.
  if not available buf_cp_credit-pay  then do:
    if input frame Dialog-Frame tt-sysconf.credit-pay <> ""
       and input frame Dialog-Frame tt-sysconf.credit-pay <> ? then
      message "Из справочника типов кассовых платежей Вы должны выбрать тип кассового платежа.".
   run ref/cashpays.w (
                       input parparentproc
                      ,input "b-sel"
                      ,input 'все':U
                      ,input 0
                      ,input ''
                      ,input 0
                      ,output v-rid-list20
                      ) no-error.
    find buf_cp_credit-pay where recid (buf_cp_credit-pay) = integer(v-rid-list20)  no-lock no-error.
    if not available buf_cp_credit-pay then
      find first buf_cp_credit-pay where
          buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
      no-lock no-error.
  end.
  if available buf_cp_credit-pay then do:
    display buf_cp_credit-pay.cdpay-code @ tt-sysconf.credit-pay
            buf_cp_credit-pay.obj-name @ credit-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.credit-pay.
  end.
  else display ? @ tt-sysconf.credit-pay
               ? @ credit-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "credit-pay" and p-action = "button" then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list22   as character no-undo .
  find buf_cp_credit-pay where buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
                  no-lock no-error.
  assign v-rid-list22 = ( if available buf_cp_credit-pay then string(recid( buf_cp_credit-pay )) else ? ).
  release buf_cp_credit-pay.
  if not available buf_cp_credit-pay  then do:
   run ref/cashpays.w (
                       input parparentproc
                      ,input "b-sel"
                      ,input 'все':U
                      ,input 0
                      ,input ''
                      ,input 0
                      ,output v-rid-list22
                      ) no-error.
    find buf_cp_credit-pay where recid (buf_cp_credit-pay) = integer(v-rid-list22)  no-lock no-error.
    if not available buf_cp_credit-pay then
      find first buf_cp_credit-pay where
          buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
      no-lock no-error.
  end.
  if available buf_cp_credit-pay then do:
    display buf_cp_credit-pay.cdpay-code @ tt-sysconf.credit-pay
            buf_cp_credit-pay.obj-name @ credit-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.credit-pay.
  end.
  else display ? @ tt-sysconf.credit-pay
               ? @ credit-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "credit-pay" and p-action = "leave" then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list24   as character no-undo .
  find buf_cp_credit-pay where buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
                 no-lock no-error.
if available buf_cp_credit-pay then do:
    display
    buf_cp_credit-pay.cdpay-code @ tt-sysconf.credit-pay
    buf_cp_credit-pay.obj-name @ credit-pay-name with frame Dialog-Frame.
        assign frame Dialog-Frame tt-sysconf.credit-pay.
end.
else display ? @ tt-sysconf.credit-pay ? @ credit-pay-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE local-curr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "base-code" and p-action = "ret-mouse" then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec26   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
                 no-lock no-error.
  if not available buf_curr-chk  then do:
    if input frame Dialog-Frame tt-sysconf.base-code <> ""
       and input frame Dialog-Frame tt-sysconf.base-code <> ? then
      message "Из справочника валют Вы должны выбрать валюту.".
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output v-ref-rec26) no-error .
    find buf_curr-chk where recid (buf_curr-chk) = v-ref-rec26  no-lock no-error.
    if not available buf_curr-chk then
      find first buf_curr-chk where
          buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
      no-lock no-error.
  end.
  if available buf_curr-chk then do:
    display buf_curr-chk.curr-code @ tt-sysconf.base-code
            buf_curr-chk.curr-abbr @ base-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.base-code.
  end.
  else display ? @ tt-sysconf.base-code
               ? @ base-code-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "base-code" and p-action = "button" then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec28   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
                  no-lock no-error.
  assign v-ref-rec28 = ( if available buf_curr-chk then recid( buf_curr-chk ) else ? ).
  release buf_curr-chk.
  if not available buf_curr-chk  then do:
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output v-ref-rec28) no-error .
    find buf_curr-chk where recid (buf_curr-chk) = v-ref-rec28  no-lock no-error.
    if not available buf_curr-chk then
      find first buf_curr-chk where
          buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
      no-lock no-error.
  end.
  if available buf_curr-chk then do:
    display buf_curr-chk.curr-code @ tt-sysconf.base-code
            buf_curr-chk.curr-abbr @ base-code-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.base-code.
  end.
  else display ? @ tt-sysconf.base-code
               ? @ base-code-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "base-code" and p-action = "leave" then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec30   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
                 no-lock no-error.
if available buf_curr-chk then do:
    display
    buf_curr-chk.curr-code @ tt-sysconf.base-code
    buf_curr-chk.curr-abbr @ base-code-name with frame Dialog-Frame.
        assign frame Dialog-Frame tt-sysconf.base-code.
end.
else display ? @ tt-sysconf.base-code ? @ base-code-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE local-payt-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "ret-credit-pay" and p-action = "ret-mouse" then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list32   as character no-undo .
  find buf_pt_ret-credit-pay where buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
                 no-lock no-error.
  if not available buf_pt_ret-credit-pay  then do:
    if input frame Dialog-Frame tt-sysconf.ret-credit-pay <> ""
       and input frame Dialog-Frame tt-sysconf.ret-credit-pay <> ? then
      message "Из справочника видов оплаты Вы должны выбрать вид оплаты.".
   run ref/paytype.w (
                       input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list32
                      ) no-error.
    find buf_pt_ret-credit-pay where recid (buf_pt_ret-credit-pay) = integer(v-rid-list32)  no-lock no-error.
    if not available buf_pt_ret-credit-pay then
      find first buf_pt_ret-credit-pay where
          buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
      no-lock no-error.
  end.
  if available buf_pt_ret-credit-pay then do:
    display buf_pt_ret-credit-pay.obj-code @ tt-sysconf.ret-credit-pay
            buf_pt_ret-credit-pay.obj-name @ ret-credit-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.ret-credit-pay.
  end.
  else display ? @ tt-sysconf.ret-credit-pay
               ? @ ret-credit-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "ret-credit-pay" and p-action = "button" then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list34   as character no-undo .
  find buf_pt_ret-credit-pay where buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
                  no-lock no-error.
  assign v-rid-list34 = ( if available buf_pt_ret-credit-pay then string(recid( buf_pt_ret-credit-pay )) else ? ).
  release buf_pt_ret-credit-pay.
  if not available buf_pt_ret-credit-pay  then do:
   run ref/paytype.w (
                       input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list34
                      ) no-error.
    find buf_pt_ret-credit-pay where recid (buf_pt_ret-credit-pay) = integer(v-rid-list34)  no-lock no-error.
    if not available buf_pt_ret-credit-pay then
      find first buf_pt_ret-credit-pay where
          buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
      no-lock no-error.
  end.
  if available buf_pt_ret-credit-pay then do:
    display buf_pt_ret-credit-pay.obj-code @ tt-sysconf.ret-credit-pay
            buf_pt_ret-credit-pay.obj-name @ ret-credit-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.ret-credit-pay.
  end.
  else display ? @ tt-sysconf.ret-credit-pay
               ? @ ret-credit-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "ret-credit-pay" and p-action = "leave" then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list36   as character no-undo .
  find buf_pt_ret-credit-pay where buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
                 no-lock no-error.
if available buf_pt_ret-credit-pay then do:
    display
    buf_pt_ret-credit-pay.obj-code @ tt-sysconf.ret-credit-pay
    buf_pt_ret-credit-pay.obj-name @ ret-credit-pay-name with frame Dialog-Frame.
        assign frame Dialog-Frame tt-sysconf.ret-credit-pay.
end.
else display ? @ tt-sysconf.ret-credit-pay ? @ ret-credit-pay-name with frame Dialog-Frame.
end.
if p-man = "cash-pay" and p-action = "ret-mouse" then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list38   as character no-undo .
  find buf_pt_cash-pay where buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
                 no-lock no-error.
  if not available buf_pt_cash-pay  then do:
    if input frame Dialog-Frame tt-sysconf.cash-pay <> ""
       and input frame Dialog-Frame tt-sysconf.cash-pay <> ? then
      message "Из справочника видов оплаты Вы должны выбрать вид оплаты.".
   run ref/paytype.w (
                       input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list38
                      ) no-error.
    find buf_pt_cash-pay where recid (buf_pt_cash-pay) = integer(v-rid-list38)  no-lock no-error.
    if not available buf_pt_cash-pay then
      find first buf_pt_cash-pay where
          buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
      no-lock no-error.
  end.
  if available buf_pt_cash-pay then do:
    display buf_pt_cash-pay.obj-code @ tt-sysconf.cash-pay
            buf_pt_cash-pay.obj-name @ cash-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.cash-pay.
  end.
  else display ? @ tt-sysconf.cash-pay
               ? @ cash-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "cash-pay" and p-action = "button" then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list40   as character no-undo .
  find buf_pt_cash-pay where buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
                  no-lock no-error.
  assign v-rid-list40 = ( if available buf_pt_cash-pay then string(recid( buf_pt_cash-pay )) else ? ).
  release buf_pt_cash-pay.
  if not available buf_pt_cash-pay  then do:
   run ref/paytype.w (
                       input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list40
                      ) no-error.
    find buf_pt_cash-pay where recid (buf_pt_cash-pay) = integer(v-rid-list40)  no-lock no-error.
    if not available buf_pt_cash-pay then
      find first buf_pt_cash-pay where
          buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
      no-lock no-error.
  end.
  if available buf_pt_cash-pay then do:
    display buf_pt_cash-pay.obj-code @ tt-sysconf.cash-pay
            buf_pt_cash-pay.obj-name @ cash-pay-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-sysconf.cash-pay.
  end.
  else display ? @ tt-sysconf.cash-pay
               ? @ cash-pay-name with frame Dialog-Frame.
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "cash-pay" and p-action = "leave" then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list42   as character no-undo .
  find buf_pt_cash-pay where buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
                 no-lock no-error.
if available buf_pt_cash-pay then do:
    display
    buf_pt_cash-pay.obj-code @ tt-sysconf.cash-pay
    buf_pt_cash-pay.obj-name @ cash-pay-name with frame Dialog-Frame.
        assign frame Dialog-Frame tt-sysconf.cash-pay.
end.
else display ? @ tt-sysconf.cash-pay ? @ cash-pay-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable hold-type as character no-undo.
define variable v-next-firm-code like ub.firm.firm-code.
define variable vartpsi      as character no-undo.
define variable vartpsi-type as character no-undo.
define variable varals-gds-str      as character no-undo.
define variable varals-gds-str-type as character no-undo.
define variable var-type            as character no-undo .
define variable var-tooltip         as character no-undo .
define variable v-egrip-date-str    as character    no-undo.
define buffer buf_sysconf for ub.sysconf.
define buffer buf1_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type.
assign
varpurch-name:LIST-ITEMS in frame Dialog-Frame = 'выкуп,консигнация,ответственное хранение':U
.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  run gen-code in this-procedure
    (output v-next-firm-code
    ) no-error .
  if error-status :error
  or v-next-firm-code = 0
  then do:
    message
      "Ошибка при генерации кода новой СВОЕЙ ФИРМЫ" skip
      "или нет свободного кода"
      view-as alert-box error.
      return error.
  end.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output hold
  ,output hold-type
  ) no-error .
if ( not error-status :error )
and hold = "yes"
then do:
  if p-mode = 'ИЗМЕНЕНИЕ':U
  then do:
    enable
      RECT-2
      B-hold-obj
      tt-firm.main-obj-code
      tt-firm.main-obj-type
      with frame Dialog-Frame.
  end.
  display
  hold-arh-title
  main-obj-title
  main-obj-name
  with frame Dialog-Frame.
  assign
  B-hold-obj:visible = yes
  RECT-2:visible     = yes
  tt-firm.main-obj-code:visible  = yes
  hold-arh-title:visible  = yes
  main-obj-title:visible  = yes
  main-obj-name:visible  = yes
  tt-firm.main-obj-type:visible  = yes
  .
end.
else do:
  assign
  B-hold-obj:visible = no
  RECT-2:visible     = no
  tt-firm.main-obj-code:visible  = no
  hold-arh-title:visible  = no
  main-obj-title:visible  = no
  main-obj-name:visible  = no
  tt-firm.main-obj-type:visible  = no
  .
end.
if tt-sysconf.base-code <> 0
then do:
  DISPLAY
  tt-sysconf.osn-base with frame Dialog-Frame.
  enable
  tt-sysconf.osn-base when (not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
                                and p-mode <> 'ПРОСМОТР':U)
  with frame Dialog-Frame.
end.
else do:
  HIDE
  tt-sysconf.osn-base
  in frame Dialog-Frame.
end.
assign
  tt-sysconf.osn-base :tooltip = "Учет ОС не только в рублях, но и в баз. вал."
.
assign varpurch-name =  entry (lookup (string(tt-sysconf.purch-code), '1,2,3':U), 'выкуп,консигнация,ответственное хранение':U).
display
varpurch-name
with frame Dialog-Frame.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vartpsi
  ,output vartpsi-type
  ) no-error .
if ( not error-status :error )
and vartpsi = "yes"
then do:
  run clntattr-value in this-procedure (
                                        input  'орг':U
                                        ,input  tt-sysconf.host-code
                                        ,input  'als-gds':U
                                        ,output varals-gds-str
                                        ,output varals-gds-str-type).
  if varals-gds-str = "yes"
  then do:
    assign
      varals-gds = yes
    .
  end.
  else do:
    assign
      varals-gds = no
    .
  end.
  display varals-gds with frame Dialog-Frame.
  if p-mode <> 'ПРОСМОТР':U
  then do:
    enable varals-gds with frame Dialog-Frame.
  end.
end.
else do:
  hide varals-gds in frame Dialog-Frame.
end.
run clntattr-value in this-procedure (
                                       input  'орг':U
                                      ,input  tt-sysconf.host-code
                                      ,input  'egrip-date':U
                                      ,output v-egrip-date-str
                                      ,output var-type) no-error .
if not error-status :error
then do:
    assign
        fi-egrip-date = date( v-egrip-date-str )
    no-error.
    if error-status :error
    then do:
        assign
            fi-egrip-date = ?
        .
    end.
end.
run clntattr-tooltip in this-procedure (
    input 'egrip-date':U
    ,output var-tooltip
    ,output var-type ).
assign
fi-egrip-date:tooltip = var-tooltip
no-error .
display
fi-egrip-date
with frame Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U
then do:
  enable
    fi-egrip-date
    with frame Dialog-Frame.
end.
run clntattr-value in this-procedure (
                                      input  'орг':U
                                      ,input  tt-sysconf.host-code
                                      ,input  'egrip-num':U
                                      ,output fi-egrip-num
                                      ,output var-type) no-error .
if error-status :error
then do:
    assign
        fi-egrip-num = "":U
    .
end.
run clntattr-tooltip in this-procedure (
    input 'egrip-num':U
    ,output var-tooltip
    ,output var-type ).
assign
fi-egrip-num:tooltip = var-tooltip
no-error .
display
fi-egrip-num
with frame Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U
then do:
  enable
    fi-egrip-num
    with frame Dialog-Frame.
end.
if hold = "yes"
then do:
  find first buf_clients no-lock
    where buf_clients.obj-code = tt-firm.main-obj-code
      and buf_clients.obj-type = tt-firm.main-obj-type
    no-error.
  if available buf_clients
  then do:
    assign
      tt-firm.main-obj-code:screen-value = string( buf_clients.obj-code )
      tt-firm.main-obj-code
      main-obj-name:screen-value = buf_clients.obj-name
      main-obj-name
      tt-firm.main-obj-type:screen-value = buf_clients.obj-type
      tt-firm.main-obj-type
    .
  end.
end.
DISPLAY
tt-clients.obj-name
(if p-mode = 'ДОБАВЛЕНИЕ':U and not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
then v-next-firm-code
else tt-sysconf.host-code) @
tt-sysconf.host-code
tt-sysconf.base-code
tt-sysconf.sale-code
tt-sysconf.sale-type
tt-sysconf.avrg-price
tt-sysconf.gen-s-f-office
tt-sysconf.cash-pay
tt-sysconf.credit-pay
tt-sysconf.ret-credit-pay
tt-sysconf.negative-rest
tt-sysconf.artic-disable
tt-sysconf.snr-accnt
tt-sysconf.cashier
tt-sysconf.head-position
tt-sysconf.branch
tt-sysconf.property
tt-sysconf.KOPF
tt-sysconf.SOEI
tt-sysconf.cons-vat-pc
with frame Dialog-Frame.
if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-ref-rec44   as recid no-undo .
  find buf_curr-chk where buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
                 no-lock no-error.
if not available buf_curr-chk then do:
  display tt-sysconf.base-code with frame Dialog-Frame.
  find buf_curr-chk no-lock where buf_curr-chk.curr-code = input frame Dialog-Frame tt-sysconf.base-code
                          no-error.
end.
if available buf_curr-chk then do:
    display
    buf_curr-chk.curr-code @ tt-sysconf.base-code
    buf_curr-chk.curr-abbr @ base-code-name with frame Dialog-Frame.
end.
else display ? @ tt-sysconf.base-code ? @ base-code-name with frame Dialog-Frame.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list46   as character no-undo .
  find buf_cp_credit-pay where buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
                 no-lock no-error.
if not available buf_cp_credit-pay then do:
  display tt-sysconf.credit-pay with frame Dialog-Frame.
  find buf_cp_credit-pay no-lock where buf_cp_credit-pay.cdpay-code = input frame Dialog-Frame tt-sysconf.credit-pay
                          no-error.
end.
if available buf_cp_credit-pay then do:
    display
    buf_cp_credit-pay.cdpay-code @ tt-sysconf.credit-pay
    buf_cp_credit-pay.obj-name @ credit-pay-name with frame Dialog-Frame.
end.
else display ? @ tt-sysconf.credit-pay ? @ credit-pay-name with frame Dialog-Frame.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list48   as character no-undo .
  find buf_pt_ret-credit-pay where buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
                 no-lock no-error.
if not available buf_pt_ret-credit-pay then do:
  display tt-sysconf.ret-credit-pay with frame Dialog-Frame.
  find buf_pt_ret-credit-pay no-lock where buf_pt_ret-credit-pay.obj-code = input frame Dialog-Frame tt-sysconf.ret-credit-pay
                          no-error.
end.
if available buf_pt_ret-credit-pay then do:
    display
    buf_pt_ret-credit-pay.obj-code @ tt-sysconf.ret-credit-pay
    buf_pt_ret-credit-pay.obj-name @ ret-credit-pay-name with frame Dialog-Frame.
end.
else display ? @ tt-sysconf.ret-credit-pay ? @ ret-credit-pay-name with frame Dialog-Frame.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-rid-list50   as character no-undo .
  find buf_pt_cash-pay where buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
                 no-lock no-error.
if not available buf_pt_cash-pay then do:
  display tt-sysconf.cash-pay with frame Dialog-Frame.
  find buf_pt_cash-pay no-lock where buf_pt_cash-pay.obj-code = input frame Dialog-Frame tt-sysconf.cash-pay
                          no-error.
end.
if available buf_pt_cash-pay then do:
    display
    buf_pt_cash-pay.obj-code @ tt-sysconf.cash-pay
    buf_pt_cash-pay.obj-name @ cash-pay-name with frame Dialog-Frame.
end.
else display ? @ tt-sysconf.cash-pay ? @ cash-pay-name with frame Dialog-Frame.
  define variable v-ref-rec51   as recid no-undo .
  define variable ref-list51 as character no-undo .
  find buf_cli_sale-code where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                 and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-lock no-error.
if not available buf_cli_sale-code then do:
  display tt-sysconf.sale-code with frame Dialog-Frame.
  find buf_cli_sale-code no-lock where buf_cli_sale-code.obj-code = input frame Dialog-Frame tt-sysconf.sale-code
                         and buf_cli_sale-code.obj-type = input frame Dialog-Frame tt-sysconf.sale-type no-error.
end.
if available buf_cli_sale-code then do:
    display
    buf_cli_sale-code.obj-code @ tt-sysconf.sale-code
    buf_cli_sale-code.obj-type @ tt-sysconf.sale-type
    buf_cli_sale-code.obj-name @ sale-code-name
    with frame Dialog-Frame.
end.
else do:
  display
  ? @ tt-sysconf.sale-code
  ? @ sale-code-name with frame Dialog-Frame.
end.
end.
if p-mode <> 'ПРОСМОТР':U
then do:
  enable
    tt-sysconf.host-code       when p-mode = 'ДОБАВЛЕНИЕ':U
    tt-sysconf.base-code       when p-mode = 'ДОБАВЛЕНИЕ':U
    b-base-code                when p-mode = 'ДОБАВЛЕНИЕ':U
    tt-clients.obj-name
    tt-sysconf.sale-code
    tt-sysconf.sale-type
    b-sale-type-code
    tt-sysconf.gen-s-f-office
    tt-sysconf.avrg-price      when not tt-sysconf.avrg-price
    tt-sysconf.cash-pay        when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    tt-sysconf.credit-pay      when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    tt-sysconf.ret-credit-pay  when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-cash-pay                 when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-credit-pay               when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-ret-credit-pay           when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    tt-sysconf.negative-rest
    tt-sysconf.artic-disable
    tt-sysconf.snr-accnt
    tt-sysconf.cashier
    tt-sysconf.head-position
    tt-sysconf.branch
    tt-sysconf.property
    tt-sysconf.KOPF
    tt-sysconf.SOEI
    tt-sysconf.cons-vat-pc
    varpurch-name
    b-exit
    b-quit
    b-attr
    Btn_trn-reason
    B-transport
    b-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
    b-help with frame Dialog-Frame
    .
end.
else do:
  assign
    b-quit:label = "&Выход"
    b-quit:column = 1
  .
  hide
    b-exit
    in frame Dialog-Frame.
  enable
    b-quit
    b-attr
    b-hist
    b-help
    Btn_trn-reason
    B-transport
    with frame Dialog-Frame .
end.
frame Dialog-Frame:title = "Настройки фирмы.             " + title-mode(p-mode).
END PROCEDURE.
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
do
with frame Dialog-Frame
:
    assign
        fi-egrip-date
        fi-egrip-num
    .
end.
assign
  v-rid = (if p-mode = 'ДОБАВЛЕНИЕ':U
          then ?
          else recid(locked_sysconf)
          )
  varpurch-name
  tt-clients.obj-name
  tt-sysconf.host-code      frame Dialog-Frame
  tt-sysconf.artic-disable
  tt-sysconf.avrg-price
  tt-sysconf.gen-s-f-office
  tt-sysconf.base-code
  tt-sysconf.branch
  tt-sysconf.cash-pay
  tt-sysconf.cashier
  tt-sysconf.cons-vat-pc
  tt-sysconf.credit-pay
  tt-sysconf.head-position
  tt-sysconf.KOPF
  tt-sysconf.negative-rest
  tt-sysconf.osn-base
  tt-sysconf.property
  tt-sysconf.purch-code = integer (lookup (varpurch-name, 'выкуп,консигнация,ответственное хранение':U))
  tt-sysconf.ret-credit-pay
  tt-sysconf.sale-type
  tt-sysconf.sale-code
  tt-sysconf.snr-accnt
  tt-sysconf.SOEI
  tt-firm.main-obj-type
  tt-firm.main-obj-code
  .
run adm/sysconf1.p
  (input-output v-rid
  ,input p-mode
  ,input no
  ,input p-is-deploy
  ,input tt-sysconf.host-code
  ,input tt-clients.grp-code
  ,input tt-clients.obj-name
  ,input tt-sysconf.avrg-price
  ,input tt-sysconf.artic-disable
  ,input tt-sysconf.base-code
  ,input tt-sysconf.branch
  ,input tt-sysconf.cash-pay
  ,input tt-sysconf.cashier
  ,input tt-sysconf.cons-vat-pc
  ,input tt-sysconf.credit-pay
  ,input tt-sysconf.firm-db-num
  ,input tt-sysconf.head-position
  ,input tt-sysconf.KOPF
  ,input tt-sysconf.negative-rest
  ,input tt-sysconf.ord-prt
  ,input tt-sysconf.osn-base
  ,input tt-sysconf.property
  ,input tt-sysconf.purch-code
  ,input tt-sysconf.ret-credit-pay
  ,input tt-sysconf.sale-type
  ,input tt-sysconf.sale-code
  ,input tt-sysconf.snr-accnt
  ,input tt-sysconf.SOEI
  ,input tt-sysconf.transport-cli-type
  ,input tt-sysconf.transport-cli-code
  ,input tt-sysconf.transport-host
  ,input tt-sysconf.transport-contract
  ,input tt-sysconf.transport-uslov
  ,input tt-sysconf.transport-value
  ,input tt-firm.main-obj-type
  ,input tt-firm.main-obj-code
  ,input varals-gds
  ,input fi-egrip-date
  ,input fi-egrip-num
  ,input tt-sysconf.gen-s-f-office
  ) no-error .
if error-status :error
then do:
message error-status:get-message(1) view-as alert-box .
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
