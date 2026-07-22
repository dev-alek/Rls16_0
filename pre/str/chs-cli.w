define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор контрагента для документа пересортица".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
define input  parameter parparentproc         as handle               no-undo.
define input  parameter parobj-type           as character            no-undo.
define input  parameter parobj-code           as integer              no-undo.
define output parameter parno-change-cli-cntr as logical              no-undo.
define output parameter parcli-type           as character            no-undo.
define output parameter parcli-code           as integer              no-undo.
define output parameter parcontract-code      as integer              no-undo.
define output parameter parset-cli-contr      as logical   initial no no-undo.
define variable varwithout-obj-host-code like ub.sysconf.host-code      no-undo.
define variable varobj-type              like ub.clients.obj-type       no-undo.
define variable varobj-code              like ub.clients.obj-code       no-undo.
define variable varhost-code             like ub.clients.obj-code       no-undo.
define variable varcontract-code         like ub.contract.contract-code no-undo.
define variable varneed-contract         as logical   no-undo .
define variable varneed-contract-type    as   character                 no-undo.
define variable v-err as logical   no-undo .
define buffer bf-host_clients for ub.clients.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "&Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44.13 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(256)":U INITIAL "БЕЗ ДОГОВОРА"
     LABEL "&Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE b-choose AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По тем же контрагентам и договорам", 1,
"Выбор контрагента и договора", 2
     SIZE 38 BY 3 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11.5
     b-help AT ROW 1 COL 22
     b-choose AT ROW 2.75 COL 1.5 NO-LABEL
     varcli-code AT ROW 6 COL 11 COLON-ALIGNED
     varcli-type AT ROW 6 COL 21.5 COLON-ALIGNED NO-LABEL
     r-cli AT ROW 6 COL 28
     varcli-name AT ROW 7.25 COL 11 COLON-ALIGNED NO-LABEL
     varcontract-prn-code AT ROW 8.75 COL 11 COLON-ALIGNED
     r-contract AT ROW 8.75 COL 31
     SPACE(23.37) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор контрагента"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       r-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       r-contract:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcli-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcli-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcli-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcontract-prn-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    define buffer bf_clients  for ub.clients.
    define buffer bf_contract for ub.contract.
    if b-choose = 1 then do:
      assign
        parcli-type           = "":u
        parcli-code           = 0
        parcontract-code      = 0
        parno-change-cli-cntr = yes
        parset-cli-contr      = yes.
    end.
    else do:
      if varcli-code = ?  or
         varcli-code = 0  then do:
        message "Не указан контрагент." view-as alert-box.
        apply "entry" to varcli-code in frame Dialog-Frame.
        return no-apply.
      end.
      if varcli-type = ?  or
         varcli-type = "" then do:
          message "Не указан контрагент." view-as alert-box.
          apply "entry" to varcli-type in frame Dialog-Frame.
          return no-apply.
      end.
      find first bf_clients where bf_clients.obj-type = varcli-type and
                                  bf_clients.obj-code = varcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Не найден контрагент " bf_clients.obj-type " " bf_clients.obj-code " ." view-as alert-box.
        apply "entry" to varcli-type in frame Dialog-Frame.
        return no-apply.
      end.
      if bf_clients.obj-type = 'маг':U  or
         bf_clients.obj-type = 'скл':U then do:
        message "Контрагент не может иметь тип: " 'маг':U " или " 'скл':U " ." view-as alert-box.
        return no-apply.
      end.
      if varneed-contract = yes and
         not (bf_clients.obj-type = 'орг':U and bf_clients.obj-code = varhost-code) then do:
        if varcontract-code = 0 then do:
          message "В системе запрещено создание складских документов без договоров." skip
                  "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " не выбран договор для текущей фирмы."
          view-as alert-box.
          return no-apply.
        end.
      end.
      if varcontract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = varhost-code     and
                                     bf_contract.contract-code = varcontract-code no-lock no-error.
        if not available bf_contract then do:
          message "Не наден договор номер " varcontract-prn-code " внутренний номер " varcontract-code " по фирме " varhost-code " ." view-as alert-box.
          return no-apply.
        end.
        if bf_contract.cli-type = bf_clients.obj-type and
           bf_contract.cli-code = bf_clients.obj-code then do:
          assign
            parcontract-code     = bf_contract.contract-code.
        end.
        else do:
          message "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." skip
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." skip
                  "Вы выбрали контрагента: " bf_clients.obj-code "  " bf_clients.obj-type " ."
          view-as alert-box.
          return no-apply.
        end.
      end.
      assign
        parcli-type = bf_clients.obj-type
        parcli-code = bf_clients.obj-code.
      assign
        parno-change-cli-cntr = no
        parset-cli-contr      = yes.
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF b-choose IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
    b-choose.
  if b-choose = 1 then do:
    assign
      varcli-type          = ""
      varcli-code          = 0
      varcontract-code     = 0
      varcontract-prn-code = "БЕЗ ДОГОВОРА".
    hide varcli-type varcli-code r-cli r-contract varcontract-prn-code in frame Dialog-Frame.
  end.
  else do:
    assign
      varcli-type          = 'орг':U
      varcli-code          = varhost-code
      varcontract-code     = 0
      varcontract-prn-code = "БЕЗ ДОГОВОРА".
    view varcli-type varcli-code r-cli r-contract varcontract-prn-code in frame Dialog-Frame.
    enable varcli-type varcli-code r-cli r-contract with frame Dialog-Frame.
    display varcli-type varcli-code varcontract-prn-code with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varrec-list AS CHARACTER NO-UNDO.
  define variable varrid-list as character no-undo.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  DEFINE BUFFER bf_clients  FOR ub.clients.
  DEFINE BUFFER bf_contract FOR ub.contract.
  if transaction = yes then do:
    message "Критическая ошибка." skip
            "Вы находитесь в транзакции." skip
            "Работа со справочником клиентов невозможна."
    view-as alert-box error.
    return no-apply.
  end.
  run ref/cli-all.w (parparentproc
                , "b-sel,b-add"
                , 'все':U
                , ?
                , ?
                , ?
                , ?
                , ?
                , output varrec-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
  IF varrec-list <> "" THEN DO:
    ASSIGN
      varrecid = integer(ENTRY(1, varrec-list)).
    FIND FIRST bf_clients WHERE RECID(bf_clients) = varrecid NO-LOCK.
    IF bf_clients.obj-type = 'маг':U  OR
       bf_clients.obj-type = 'скл':U THEN DO:
       MESSAGE "Склад или магазин не может быть контрагентом в данном документе."
       VIEW-AS ALERT-BOX.
       RETURN NO-APPLY.
    END.
    IF bf_clients.obj-type = 'орг':U       AND
       bf_clients.obj-code = varhost-code THEN DO:
       ASSIGN
         varcontract-code     = 0
         varcontract-prn-code = "БЕЗ ДОГОВОРА"
       .
    END.
    ELSE DO:
      FIND FIRST bf_contract WHERE bf_contract.host-code = varhost-code        AND
                                   bf_contract.cli-type  = bf_clients.obj-type AND
                                   bf_contract.cli-code  = bf_clients.obj-code AND
                                   bf_contract.status_   = 'тек':U    NO-LOCK NO-ERROR.
      IF NOT AVAILABLE bf_contract THEN DO:
        IF varneed-contract = yes THEN DO:
          MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                  "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " нет ни одного открытого договора для текущей фирмы."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        run str/cont-all.w (input parparentproc,
                        input varhost-code,
                        input "b-sel",
                        input 'фирма':U ,
                        input bf_clients.obj-type,
                        input bf_clients.obj-code,
                        input ?,
                        input ?,
                        input "current":u,
                        input 'при':U,
                        input-output varrid-list ) no-error.
        if error-status:error then do:
          message "Ошибка при вызове справочника договоров." skip
                  return-value                skip
          view-as alert-box error.
          return no-apply.
        end.
        IF varrid-list <> "" THEN DO:
          assign
            varrecid = integer(entry(1, varrid-list)).
          find first bf_contract where recid(bf_contract) = varrecid no-lock.
          if bf_contract.cli-type = bf_clients.obj-type and
             bf_contract.cli-code = bf_clients.obj-code  then do:
            assign
              varcontract-code     = bf_contract.contract-code
              varcontract-prn-code = bf_contract.contract-prn-code.
          end.
          ELSE DO:
            MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                    "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                    "Вы выбрали контрагента: " bf_clients.obj-code "  " bf_clients.obj-type " ."
            VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.
        END.
        ELSE DO:
          IF varneed-contract = yes THEN DO:
            MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                    "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " не выбран договор для текущей фирмы."
            VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.
        END.
      END.
    END.
    ASSIGN
      varcli-type = bf_clients.obj-type
      varcli-code = bf_clients.obj-code
      varcli-name = bf_clients.obj-name.
    DISPLAY varcli-type varcli-code varcli-name varcontract-prn-code WITH FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf_contract FOR ub.contract.
  DEFINE VARIABLE varrid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  IF varcli-type <> ?    AND
     varcli-type <> "":u AND
     varcli-code <> 0    AND
     varcli-code <> ?    THEN DO:
    IF NOT (varcli-type = 'орг':U       AND
      INPUT FRAME Dialog-Frame varcli-code  = varhost-code) THEN DO:
      run str/cont-all.w (input parparentproc,
                      input varhost-code,
                      input "b-sel",
                      input 'фирма':U ,
                      input varcli-type,
                      input varcli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input 'при':U,
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
        view-as alert-box error.
        return NO-APPLY.
      end.
      IF varrid-list <> "" THEN DO:
        assign
          varrecid = integer(entry(1, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid NO-LOCK.
        if bf_contract.cli-type = varcli-type AND
           bf_contract.cli-code = varcli-code then do:
          assign
            varcontract-code     = bf_contract.contract-code
            varcontract-prn-code = bf_contract.contract-prn-code.
          DISPLAY varcontract-prn-code WITH FRAME Dialog-Frame.
        end.
        ELSE DO:
          MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                  "Вы выбрали контрагента: " varcli-code "  " varcli-type " ."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        IF varneed-contract = yes THEN DO:
          MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                  "По контрагенту " varcli-code " " varcli-type " нет ни одного открытого договора для текущей фирмы."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
        ASSIGN
          varcontract-code = 0
          varcontract-prn-code = "БЕЗ ДОГОВОРА".
      END.
    END.
    ELSE DO:
      ASSIGN
        varcontract-code = 0
        varcontract-prn-code = "БЕЗ ДОГОВОРА".
    END.
    DISPLAY varcontract-prn-code WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    MESSAGE "Выбрать договор можно только после указания контрагента." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
END.
ON LEAVE OF varcli-code IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME Dialog-Frame
    varcli-code.
  APPLY "entry" TO varcli-type IN FRAME Dialog-Frame.
  RETURN NO-APPLY.
END.
ON LEAVE OF varcli-type IN FRAME Dialog-Frame
DO:
 RUN find-cli IN THIS-PROCEDURE NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
   RETURN NO-APPLY.
 END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FIND FIRST bf-host_clients WHERE bf-host_clients.obj-type = parobj-type AND
                                   bf-host_clients.obj-code = parobj-code NO-LOCK.
  ASSIGN
    varhost-code = bf-host_clients.host-code
    .
define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-mastc           as logical   no-undo init false .
    run adm/shattri.p (
      input "get":U
      ,input parobj-type
      ,input parobj-code
      ,input 'contr-in':U
      ,input "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varneed-contract
      ,output varneed-contract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY b-choose
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help b-choose
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE find-cli :
DEFINE BUFFER bf_clients  FOR ub.clients.
  DEFINE BUFFER bf_contract FOR ub.contract.
  DEFINE VARIABLE varrid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrec-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = INPUT FRAME Dialog-Frame varcli-type AND
                              bf_clients.obj-code = varcli-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_clients THEN DO:
    MESSAGE "Нет контрагента " varcli-code " " INPUT FRAME Dialog-Frame varcli-type " ."
    VIEW-AS ALERT-BOX.
    run ref/cli-all.w (parparentproc
                  , "b-sel,b-add"
                  , 'все':U
                  , ?
                  , ?
                  , ?
                  , ?
                  , ?
                  , output varrec-list) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
    END.
    IF varrec-list <> "" THEN DO:
      ASSIGN
        varrecid = integer(ENTRY(1, varrec-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      ASSIGN
        varcli-code = bf_clients.obj-code.
      DISPLAY varcli-code bf_clients.obj-type @ varcli-type WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  IF varneed-contract = yes THEN DO:
    FIND FIRST bf_contract WHERE bf_contract.host-code = varhost-code     AND
                                 bf_contract.cli-type  = INPUT FRAME Dialog-Frame varcli-type      AND
                                 bf_contract.cli-code  = varcli-code      AND
                                 bf_contract.status_   = 'тек':U NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_contract THEN DO:
      MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
              "По контрагенту " bf_clients.obj-code " " INPUT FRAME Dialog-Frame varcli-type " нет ни одного открытого договора для текущей фирмы."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    ELSE DO:
      run str/cont-all.w (input parparentproc,
                      input varhost-code,
                      input "b-sel",
                      input 'фирма':U ,
                      input INPUT FRAME Dialog-Frame varcli-type,
                      input varcli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input 'при':U,
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
        view-as alert-box error.
        return NO-APPLY.
      end.
      IF varrid-list <> "" THEN DO:
        assign
          varrecid = integer(entry(1, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid NO-LOCK.
        if bf_contract.cli-type = INPUT FRAME Dialog-Frame varcli-type AND
           bf_contract.cli-code = varcli-code then do:
          assign
            varcontract-code     = bf_contract.contract-code
            varcontract-prn-code = bf_contract.contract-prn-code.
          DISPLAY varcontract-prn-code WITH FRAME Dialog-Frame.
        end.
        ELSE DO:
          MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                  "Вы выбрали контрагента: " varcli-code "  " INPUT FRAME Dialog-Frame varcli-type " ."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                "По контрагенту " bf_clients.obj-code " " INPUT FRAME Dialog-Frame varcli-type " не выбран договор по текущей фирмы."
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
      END.
    END.
  END.
  run ver-clients  (bf_clients.obj-type , bf_clients.obj-code , output v-err) .
  if  v-err then return NO-APPLY.
  ASSIGN FRAME Dialog-Frame varcli-type.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = varcli-type AND
                              bf_clients.obj-code = varcli-code NO-LOCK NO-ERROR.
  ASSIGN FRAME Dialog-Frame
    varcli-name.
  DISPLAY varcli-name WITH FRAME Dialog-Frame.
END PROCEDURE.
