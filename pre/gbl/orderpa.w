define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры для системы ЗАКАЗОВ" .
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
define buffer bufglbl_thbj-attr for ub.thbj-attr.
define buffer bufobj_thbj-attr  for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table glbl_thbj-attr-ord no-undo like ub.thbj-attr.
define temp-table  obj_thbj-attr-ord no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-glbl as handle no-undo .
define variable v-tth-obj  as handle no-undo .
define variable v-to-create-glbl as logical no-undo.
define variable v-to-create-obj as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth      = buffer thbjattr_thbj-attr:table-handle .
v-tth-glbl = buffer glbl_thbj-attr-ord:table-handle .
v-tth-obj  = buffer obj_thbj-attr-ord:table-handle .
if p-obj-type = "" then do:
if g#db-num <> 0  and p-obj-type = "" then  p-mode = 'ПРОСМОТР':U .
end.
DEFINE BUTTON B-attr-ord-11
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-ord-askp
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-ord-comp-prc
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-ord-obj-rc
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-ord-wgt-div-prc
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE ord-comp-prc AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE ord-obj-rc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE ord-wgt-div-prc AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE ordshipd AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-11 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-askp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-comp-prc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 69 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-log AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-min-ost-day AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-obj-rc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-ofof AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-oobj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-op AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ord-wgt-div-prc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 69 BY 1 NO-UNDO.
DEFINE VARIABLE v-ordcyclg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-ordshipd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75 BY 1 NO-UNDO.
DEFINE IMAGE I-ord-11
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-askp
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-comp-prc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-log
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-ord-min-ost-day
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-obj-rc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-ofof
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-ord-oobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-ord-op
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ord-wgt-div-prc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ordcyclg
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE IMAGE I-ordshipd
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.
DEFINE VARIABLE ord-11 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE ord-askp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 1.75 BY 1 NO-UNDO.
DEFINE VARIABLE ord-log AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE ord-min-ost-day AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE ord-ofof AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE ord-oobj AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE ord-op AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE ordcyclg AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.63
     ord-log AT ROW 3 COL 4 WIDGET-ID 44
     ord-ofof AT ROW 3.96 COL 4 WIDGET-ID 46
     ord-oobj AT ROW 4.96 COL 4 WIDGET-ID 48
     ord-op AT ROW 5.92 COL 4 WIDGET-ID 50
     ord-min-ost-day AT ROW 6.88 COL 4 WIDGET-ID 54
     B-attr-ord-askp AT ROW 7.79 COL 3.63 WIDGET-ID 72
     ord-askp AT ROW 7.79 COL 6.75 WIDGET-ID 60
     B-attr-ord-obj-rc AT ROW 9.04 COL 3.63 WIDGET-ID 74
     B-cli AT ROW 9.04 COL 6.25 WIDGET-ID 76
     ordshipd AT ROW 10.21 COL 1.63 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     ordcyclg AT ROW 11.21 COL 4 WIDGET-ID 88
     B-attr-ord-wgt-div-prc AT ROW 12.29 COL 3.63 WIDGET-ID 98
     ord-wgt-div-prc AT ROW 12.29 COL 4.75 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     B-attr-ord-11 AT ROW 13.5 COL 3.38 WIDGET-ID 100
     ord-11 AT ROW 13.5 COL 6.63 WIDGET-ID 104
     B-attr-ord-comp-prc AT ROW 14.71 COL 3.63 WIDGET-ID 108
     ord-comp-prc AT ROW 14.71 COL 4.75 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     v-ord-log AT ROW 3 COL 6.63 NO-LABEL WIDGET-ID 6
     v-ord-ofof AT ROW 3.96 COL 6.63 NO-LABEL WIDGET-ID 18
     v-ord-oobj AT ROW 4.96 COL 6.63 NO-LABEL WIDGET-ID 20
     v-ord-op AT ROW 5.92 COL 6.63 NO-LABEL WIDGET-ID 38
     v-ord-min-ost-day AT ROW 6.88 COL 6.63 NO-LABEL WIDGET-ID 56
     v-ord-askp AT ROW 7.88 COL 9.63 NO-LABEL WIDGET-ID 62
     ord-obj-rc AT ROW 9.04 COL 7.63 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     v-ord-obj-rc AT ROW 9.04 COL 23.63 NO-LABEL WIDGET-ID 68
     v-ordshipd AT ROW 10.21 COL 8.63 NO-LABEL WIDGET-ID 82
     v-ordcyclg AT ROW 11.21 COL 6.63 NO-LABEL WIDGET-ID 90
     v-ord-wgt-div-prc AT ROW 12.29 COL 12.25 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     v-ord-11 AT ROW 13.5 COL 9.38 NO-LABEL WIDGET-ID 106
     v-ord-comp-prc AT ROW 14.71 COL 12.25 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     I-ord-log AT ROW 3 COL 1.63 WIDGET-ID 10
     I-ord-ofof AT ROW 3.96 COL 1.63 WIDGET-ID 34
     I-ord-oobj AT ROW 4.96 COL 1.63 WIDGET-ID 36
     I-ord-op AT ROW 5.92 COL 1.63 WIDGET-ID 40
     I-ord-min-ost-day AT ROW 6.88 COL 1.63 WIDGET-ID 52
     I-ord-askp AT ROW 7.88 COL 1.63 WIDGET-ID 58
     I-ord-obj-rc AT ROW 9.04 COL 1.63 WIDGET-ID 64
     I-ordshipd AT ROW 10.21 COL 1.63 WIDGET-ID 78
     I-ordcyclg AT ROW 11.21 COL 1.63 WIDGET-ID 86
     I-ord-wgt-div-prc AT ROW 12.29 COL 1.63 WIDGET-ID 92
     I-ord-11 AT ROW 13.5 COL 1.63 WIDGET-ID 102
     I-ord-comp-prc AT ROW 14.71 COL 1.63 WIDGET-ID 110
     SPACE(81.98) SKIP(3.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для заказов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ord-obj-rc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-11:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-askp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-comp-prc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-min-ost-day:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-obj-rc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-ofof:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-oobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-op:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ord-wgt-div-prc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ordcyclg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ordshipd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-attr-ord-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('ord-obj':U,
       'ord-11':U
       ).
END.
ON CHOOSE OF B-attr-ord-askp IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('ord-obj':U,
       'ord-askp':U
       ).
END.
ON CHOOSE OF B-attr-ord-comp-prc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('ord-obj':U,
       'ord-comp-prc':U
       ).
END.
ON CHOOSE OF B-attr-ord-obj-rc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('ord-obj':U,
       'ord-obj-rc':U
       ).
END.
ON CHOOSE OF B-attr-ord-wgt-div-prc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('ord-obj':U,
       'ord-wgt-div-prc':U
       ).
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
  define variable rid-list    as  char no-undo .
  def buffer buf_clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input 'объект':U,
      input ?,
      input ?,
      input ? ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .
    find first buf_clients where recid(buf_clients) = integer(rid-list) no-lock no-error.
    if available buf_clients
    then
        Assign
           ord-obj-rc = buf_clients.obj-type + string( buf_clients.obj-code)
           .
    else
        assign
          ord-obj-rc = ""
        .
    Display ord-obj-rc with frame Dialog-Frame .
END.
ON MOUSE-SELECT-CLICK OF I-ord-11 IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-11:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-askp IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-askp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-comp-prc IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-comp-prc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-log IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-log:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-min-ost-day IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-min-ost-day:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-obj-rc IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-obj-rc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-ofof IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-ofof:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-oobj IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-oobj:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-op IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-op:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ord-wgt-div-prc IN FRAME Dialog-Frame
DO:
  MESSAGE I-ord-wgt-div-prc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ordcyclg IN FRAME Dialog-Frame
DO:
  MESSAGE I-ordcyclg:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ordshipd IN FRAME Dialog-Frame
DO:
  MESSAGE I-ordshipd:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable loc#log as logical   no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-ord_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do:
     return.
  end.
  if p-obj-type <> "" then do:
     FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE + (if p-obj-type = 'орг':U then " фирма" else " маг") + STRING(p-obj-code) .
  end.
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ord-log ord-ofof ord-oobj ord-op ord-min-ost-day ord-askp ordshipd
          ordcyclg ord-wgt-div-prc ord-11 ord-comp-prc v-ord-log v-ord-ofof
          v-ord-oobj v-ord-op v-ord-min-ost-day v-ord-askp ord-obj-rc
          v-ord-obj-rc v-ordshipd v-ordcyclg v-ord-wgt-div-prc v-ord-11
          v-ord-comp-prc
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-ord-log I-ord-ofof I-ord-oobj I-ord-op
         I-ord-min-ost-day I-ord-askp I-ord-obj-rc I-ordshipd I-ordcyclg
         I-ord-wgt-div-prc I-ord-11 I-ord-comp-prc ord-log ord-ofof ord-oobj
         ord-op ord-min-ost-day B-attr-ord-askp ord-askp B-attr-ord-obj-rc
         B-cli ordshipd ordcyclg B-attr-ord-wgt-div-prc ord-wgt-div-prc
         B-attr-ord-11 ord-11 B-attr-ord-comp-prc ord-comp-prc v-ord-log
         v-ord-ofof v-ord-oobj v-ord-op v-ord-min-ost-day v-ord-askp ord-obj-rc
         v-ord-obj-rc v-ordshipd v-ordcyclg v-ord-wgt-div-prc v-ord-11
         v-ord-comp-prc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each glbl_thbj-attr-ord:
  delete glbl_thbj-attr-ord.
end.
for each obj_thbj-attr-ord:
  delete obj_thbj-attr-ord.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'ord-global':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-glbl
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input 'ord-obj':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-obj
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH glbl_thbj-attr-ord
  :
  IF glbl_thbj-attr-ord.prop-code = 'ord-log':U THEN DO:
     ord-log = glbl_thbj-attr-ord.property-value-logical.
     ord-log:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-log with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ord-ofof':U THEN DO:
     ord-ofof = glbl_thbj-attr-ord.property-value-logical.
     ord-ofof:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-ofof with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ord-oobj':U THEN DO:
     ord-oobj = glbl_thbj-attr-ord.property-value-logical.
     ord-oobj:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-oobj with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ord-op':U THEN DO:
     ord-op = glbl_thbj-attr-ord.property-value-logical.
     ord-op:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ord-op with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ordshipd':U THEN DO:
     ordshipd = glbl_thbj-attr-ord.property-value-integer.
     ordshipd:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ordshipd with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ordcyclg':U THEN DO:
     ordcyclg = glbl_thbj-attr-ord.property-value-logical.
     ordcyclg:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ordcyclg with frame Dialog-Frame .
  END.
  IF glbl_thbj-attr-ord.prop-code = 'ord-min-ost-day':U THEN DO:
     ord-min-ost-day = glbl_thbj-attr-ord.property-value-logical.
     ord-min-ost-day:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ord-min-ost-day with frame Dialog-Frame .
  END.
  create temp-thbj-attr.
  buffer-copy glbl_thbj-attr-ord to temp-thbj-attr.
END.
FOR EACH obj_thbj-attr-ord:
  IF obj_thbj-attr-ord.prop-code = 'ord-askp':U THEN DO:
     ord-askp = obj_thbj-attr-ord.property-value-logical.
     ord-askp:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-askp with frame Dialog-Frame .
  END.
  IF obj_thbj-attr-ord.prop-code = 'ord-obj-rc':U THEN DO:
     ord-obj-rc = obj_thbj-attr-ord.property-value-character.
     ord-obj-rc:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-obj-rc with frame Dialog-Frame .
  END.
  IF obj_thbj-attr-ord.prop-code = 'ord-wgt-div-prc':U THEN DO:
     ord-wgt-div-prc = obj_thbj-attr-ord.property-value-decimal.
     ord-wgt-div-prc:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-wgt-div-prc with frame Dialog-Frame .
  END.
  IF obj_thbj-attr-ord.prop-code = 'ord-comp-prc':U THEN DO:
     ord-comp-prc = obj_thbj-attr-ord.property-value-decimal.
     ord-comp-prc:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-comp-prc with frame Dialog-Frame .
  END.
  IF obj_thbj-attr-ord.prop-code = 'ord-11':U THEN DO:
     ord-11 = obj_thbj-attr-ord.property-value-logical.
     ord-11:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-11 with frame Dialog-Frame .
  END.
  create temp-thbj-attr.
  buffer-copy obj_thbj-attr-ord to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ord-log"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-log:screen-value = entry(2,v-label,":") .
I-ord-log:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ord-ofof"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-ofof:screen-value = entry(2,v-label,":") .
I-ord-ofof:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ord-oobj"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-oobj:screen-value = entry(2,v-label,":") .
I-ord-oobj:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ord-op"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-op:screen-value = entry(2,v-label,":") .
I-ord-op:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ordshipd"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ordshipd:screen-value = entry(2,v-label,":") .
I-ordshipd:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ordcyclg"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ordcyclg:screen-value = entry(2,v-label,":") .
I-ordcyclg:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-global':U
            ,input  "ord-min-ost-day"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-min-ost-day:screen-value = entry(2,v-label,":") .
I-ord-min-ost-day:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-obj':U
            ,input  "ord-askp"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-askp:screen-value = entry(2,v-label,":") .
I-ord-askp:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-obj':U
            ,input  "ord-11"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-11:screen-value = entry(2,v-label,":") .
I-ord-11:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'ord-obj':U
            ,input  "ord-obj-rc"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-obj-rc:screen-value = entry(2,v-label,":") .
I-ord-obj-rc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input  'ord-obj':U
            ,input  'ord-wgt-div-prc':U
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-wgt-div-prc:screen-value = entry(2,v-label,":") .
I-ord-wgt-div-prc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input  'ord-obj':U
            ,input  'ord-comp-prc':U
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-comp-prc:screen-value = entry(2,v-label,":") .
I-ord-comp-prc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
END PROCEDURE.
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first bufglbl_thbj-attr exclusive-lock where
              bufglbl_thbj-attr.obj-type = ""
        and   bufglbl_thbj-attr.obj-code = 0
        and   bufglbl_thbj-attr.upper-prop-code = 'ord-global':U
        and   bufglbl_thbj-attr.prop-code = '':u no-wait no-error.
     if locked bufglbl_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'ord-global':U skip
        "Запись Глобальных ПАРАМЕТРОВ ord занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first bufglbl_thbj-attr no-lock where
          bufglbl_thbj-attr.obj-type = ""
    and   bufglbl_thbj-attr.obj-code = 0
    and   bufglbl_thbj-attr.upper-prop-code = 'ord-global':U
    and   bufglbl_thbj-attr.prop-code = '':u no-error.
  end.
  if not available bufglbl_thbj-attr then do:
    assign
      v-to-create-glbl  = true
      .
    message
    substitute ("Внимание!!!&1Параметра ord-gbl НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
   find first bufobj_thbj-attr exclusive-lock where
              bufobj_thbj-attr.obj-type = p-obj-type
        and   bufobj_thbj-attr.obj-code = p-obj-code
        and   bufobj_thbj-attr.upper-prop-code = 'ord-obj':U
        and   bufobj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked bufobj_thbj-attr then do:
        message
        "Запись ПАРАМЕТРОВ ord-obj занята"
        view-as alert-box error .
        undo, return error.
  end.
  else do:
    find first bufobj_thbj-attr no-lock where
          bufobj_thbj-attr.obj-type = p-obj-type
    and   bufobj_thbj-attr.obj-code = p-obj-code
    and   bufobj_thbj-attr.upper-prop-code = 'ord-obj':U
    and   bufobj_thbj-attr.prop-code = '':u no-error.
  end.
  if not available bufobj_thbj-attr then do:
    assign
      v-to-create-obj  = true
      .
    message
    substitute ("Внимание!!!&1Параметра ord-obj НЕТ в БД &2&3 !&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10),
                p-obj-type ,
                p-obj-code
                )
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable ord-log ord-ofof ord-oobj ord-op ordshipd ord-min-ost-day  ord-askp ord-11 ord-obj-rc b-cli ordcyclg  with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  if p-obj-type <> "" then do:
     disable ord-log ord-ofof ord-oobj ord-op ord-min-ost-day ordshipd ordcyclg with frame Dialog-Frame.
  end.
end procedure.
PROCEDURE init-tt :
END PROCEDURE.
PROCEDURE save-proc :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same-glbl as logical no-undo .
define variable v-same-obj  as logical no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-ord_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
ASSIGN
    ord-log FRAME Dialog-Frame
    ord-ofof
    ord-oobj
    ord-op
    ordshipd
    ordcyclg
    ord-min-ost-day
    ord-askp
    ord-11
    ord-obj-rc
    .
assign
  fh = frame Dialog-Frame:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first glbl_thbj-attr-ord where
              recid(glbl_thbj-attr-ord) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer glbl_thbj-attr-ord:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  if wh:private-data begins "recid3=" then do:
    find first obj_thbj-attr-ord where
              recid(obj_thbj-attr-ord) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer obj_thbj-attr-ord:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
v-same-glbl = yes.
v-same-obj = yes.
for each glbl_thbj-attr-ord,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = glbl_thbj-attr-ord.obj-type
      and temp-thbj-attr.obj-code = glbl_thbj-attr-ord.obj-code
      and temp-thbj-attr.upper-prop-code = glbl_thbj-attr-ord.upper-prop-code
      and temp-thbj-attr.prop-code = glbl_thbj-attr-ord.prop-code:
   buffer-compare
   glbl_thbj-attr-ord
   to temp-thbj-attr
   save result in v-same-glbl.
   if not v-same-glbl then leave.
end.
v-same-glbl = no.
for each obj_thbj-attr-ord,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = obj_thbj-attr-ord.obj-type
      and temp-thbj-attr.obj-code = obj_thbj-attr-ord.obj-code
      and temp-thbj-attr.upper-prop-code = obj_thbj-attr-ord.upper-prop-code
      and temp-thbj-attr.prop-code       = obj_thbj-attr-ord.prop-code:
   buffer-compare
   obj_thbj-attr-ord
   to temp-thbj-attr
   save result in v-same-obj.
   if not v-same-obj then leave.
end.
v-same-obj = no.
do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input 'ord-global':U
      ,input table glbl_thbj-attr-ord
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  run thbjattr_set-section in this-procedure (
       input p-obj-type
      ,input p-obj-code
      ,input 'ord-obj':U
      ,input table obj_thbj-attr-ord
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.
END PROCEDURE.
