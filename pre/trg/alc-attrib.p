block-level on error undo, throw.
define input parameter p-in-code   like ub.parts.in-code   no-undo .
define input parameter p-artic     like ub.parts.artic     no-undo .
define input parameter p-prod-type like ub.parts.prod-type no-undo .
define input parameter p-prod-code like ub.parts.prod-code no-undo .
define input parameter p-part-code like ub.parts.part-code no-undo .
define input parameter p-alc-mark-db-num         as integer   no-undo.
define input parameter p-alc-mark-code           as integer   no-undo.
define input parameter p-alc-bottling-date       as date      no-undo.
define input parameter p-alc-ref-ab-path         as character no-undo.
define input parameter p-alc-quality-certif-path as character no-undo.
define input parameter p-alc-certif-path         as character no-undo.
define input parameter p-alc-imp-type            as character no-undo.
define input parameter p-alc-imp-code            as integer   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение алкогольных аттрибутов для партии приходной накладной ".
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
define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_parts for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
main-block:
do transaction
on error undo main-block, return error
:
  for each ub.gds-obj no-lock
    where ub.gds-obj.artic     = p-artic
      and ub.gds-obj.prod-type = p-prod-type
      and ub.gds-obj.prod-code = p-prod-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
  for each ub.parts no-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.part-code = p-part-code
  on error undo main-block, return error
  :
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.mark-db-num = p-alc-mark-db-num
        buf_parts.mark-code = p-alc-mark-code
        buf_parts.alc-bottling-date = p-alc-bottling-date
        buf_parts.alc-ref-ab-path = p-alc-ref-ab-path
        buf_parts.alc-quality-certif-path = p-alc-quality-certif-path
        buf_parts.alc-certif-path = p-alc-certif-path
        buf_parts.alc-imp-type = p-alc-imp-type
        buf_parts.alc-imp-code = p-alc-imp-code
      .
  end.
end.
