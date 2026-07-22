define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры для накладных" .
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
define buffer ord_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-trn no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-trn as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-tth-trn = buffer thbjattr_thbj-attr-trn:table-handle .
if g#db-num <> 0 then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-2
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-3
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-4
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-5
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-6
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-7
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-contr-in-expense-CPT AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-contr-in-expense-NP AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-contr-in-income-CPT AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-contr-in-income-NP AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-contr-qnty-spec AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-contr-recount AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE IMAGE I-contr-in-expense-CPT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-contr-in-expense-NP
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-contr-in-income-CPT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-contr-in-income-NP
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-contr-qnty-spec
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-contr-recount
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE contr-in-expense-CPT AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE contr-in-expense-NP AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE contr-in-income-CPT AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE contr-in-income-NP AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE contr-qnty-spec AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE contr-recount AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     B-2 AT ROW 2.96 COL 3 WIDGET-ID 96
     contr-in-income-NP AT ROW 2.96 COL 5.88 WIDGET-ID 44
     B-3 AT ROW 3.96 COL 3 WIDGET-ID 124
     contr-in-income-CPT AT ROW 3.96 COL 5.88 WIDGET-ID 126
     B-4 AT ROW 4.96 COL 3 WIDGET-ID 98
     contr-in-expense-NP AT ROW 4.96 COL 5.88 WIDGET-ID 46
     B-5 AT ROW 5.96 COL 3 WIDGET-ID 116
     contr-in-expense-CPT AT ROW 5.96 COL 5.88 WIDGET-ID 118
     B-6 AT ROW 6.96 COL 3 WIDGET-ID 100
     contr-qnty-spec AT ROW 6.96 COL 5.88 WIDGET-ID 102
     B-7 AT ROW 7.96 COL 3 WIDGET-ID 108
     contr-recount AT ROW 7.96 COL 5.88 WIDGET-ID 110
     v-contr-in-income-NP AT ROW 2.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     v-contr-in-income-CPT AT ROW 3.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 130
     v-contr-in-expense-NP AT ROW 4.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     v-contr-in-expense-CPT AT ROW 5.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 122
     v-contr-qnty-spec AT ROW 6.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     v-contr-recount AT ROW 7.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     I-contr-in-income-NP AT ROW 3 COL 1 WIDGET-ID 10
     I-contr-in-expense-NP AT ROW 5 COL 1 WIDGET-ID 34
     I-contr-qnty-spec AT ROW 7 COL 1 WIDGET-ID 104
     I-contr-in-expense-CPT AT ROW 6 COL 1 WIDGET-ID 120
     I-contr-in-income-CPT AT ROW 4 COL 1 WIDGET-ID 128
     I-contr-recount AT ROW 8 COL 1 WIDGET-ID 112
     SPACE(83.12) SKIP(5.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для накладных"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-contr-qnty-spec:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-contr-recount:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
       'contr-in-income-NP':U
       ).
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
       'contr-in-income':U
       ).
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
       'contr-in-expense-NP':U
       ).
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
       'contr-in-expense':U
       ).
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
        'contr-qnty-spec':U
       ).
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('contr-in':U,
        'contr-recount':U
       ).
END.
ON MOUSE-SELECT-CLICK OF I-contr-in-expense-CPT IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-in-expense-CPT:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-contr-in-expense-NP IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-in-expense-NP:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-contr-in-income-CPT IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-in-income-CPT:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-contr-in-income-NP IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-in-income-NP:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-contr-qnty-spec IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-qnty-spec:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-contr-recount IN FRAME Dialog-Frame
DO:
  MESSAGE I-contr-recount:private-data  VIEW-AS ALERT-BOX INFORMATION.
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
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-trn_lookup':U
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
    run init-tt.
    run enable_UI.
    run init-proc.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY contr-in-income-NP contr-in-income-CPT contr-in-expense-NP
          contr-in-expense-CPT contr-qnty-spec contr-recount
          v-contr-in-income-NP v-contr-in-income-CPT v-contr-in-expense-NP
          v-contr-in-expense-CPT v-contr-qnty-spec v-contr-recount
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-contr-in-income-NP I-contr-in-expense-NP
         I-contr-qnty-spec I-contr-in-expense-CPT I-contr-in-income-CPT
         I-contr-recount B-2 contr-in-income-NP B-3 contr-in-income-CPT B-4
         contr-in-expense-NP B-5 contr-in-expense-CPT B-6 contr-qnty-spec B-7
         contr-recount v-contr-in-income-NP v-contr-in-income-CPT
         v-contr-in-expense-NP v-contr-in-expense-CPT v-contr-qnty-spec
         v-contr-recount
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
for each thbjattr_thbj-attr-trn:
  delete thbjattr_thbj-attr-trn.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input 'contr-in':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-trn
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr-trn  where
         thbjattr_thbj-attr-trn.obj-type =  p-obj-type and
         thbjattr_thbj-attr-trn.obj-code =  p-obj-code
:
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-in-income-NP':U THEN DO:
     contr-in-income-NP = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-income-NP:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-income-NP with frame Dialog-Frame .
  end.
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-in-income':U THEN DO:
     contr-in-income-CPT = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-income-CPT:PRIVATE-DATA IN FRAME Dialog-Frame  = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-income-CPT with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-in-expense-NP':U THEN DO:
     contr-in-expense-NP = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-expense-NP:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-expense-NP with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-in-expense':U THEN DO:
     contr-in-expense-CPT = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-expense-CPT:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-expense-CPT with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-qnty-spec':U THEN DO:
     contr-qnty-spec = thbjattr_thbj-attr-trn.property-value-logical.
     contr-qnty-spec:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-qnty-spec with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = 'contr-recount':U THEN DO:
     contr-recount = thbjattr_thbj-attr-trn.property-value-logical.
     contr-recount:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-recount with frame Dialog-Frame .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-trn to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-in-income-NP"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-income-NP:screen-value = entry(2,v-label,":") .
v-contr-in-income-NP:MOVE-TO-Top( ).
I-contr-in-income-NP:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-in-income"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-income-CPT:screen-value = entry(2,v-label,":") .
v-contr-in-income-CPT:MOVE-TO-Top( ).
I-contr-in-income-CPT:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-in-expense-NP"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-expense-NP:screen-value = entry(2,v-label,":") .
v-contr-in-expense-NP:MOVE-TO-Top( ).
I-contr-in-expense-NP:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-in-expense"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-expense-CPT:screen-value = entry(2,v-label,":") .
v-contr-in-expense-CPT:MOVE-TO-Top( ).
I-contr-in-expense-CPT:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-qnty-spec"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-qnty-spec:screen-value = entry(2,v-label,":") .
v-contr-qnty-spec:MOVE-TO-Top( ).
I-contr-qnty-spec:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   'contr-in':U
            ,input  "contr-recount"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-recount:screen-value = entry(2,v-label,":") .
v-contr-recount:MOVE-TO-Top( ).
I-contr-recount:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
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
    find first ord_thbj-attr exclusive-lock where
              ord_thbj-attr.obj-type = p-obj-type
        and   ord_thbj-attr.obj-code = p-obj-code
        and   ord_thbj-attr.upper-prop-code = 'contr-in':U
        and   ord_thbj-attr.prop-code = '':u no-wait no-error.
     if locked ord_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'contr-in':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first ord_thbj-attr no-lock where
          ord_thbj-attr.obj-type = p-obj-type
    and   ord_thbj-attr.obj-code = p-obj-code
    and   ord_thbj-attr.upper-prop-code = 'contr-in':U
    and   ord_thbj-attr.prop-code = '':u no-error.
  end.
  if not available ord_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Параметра &1 НЕТ в БД!&2Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                'contr-in':U,
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
        contr-in-income-CPT
        contr-in-income-NP
        contr-in-expense-CPT
        contr-in-expense-NP
        contr-qnty-spec
        contr-recount
        with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
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
define variable v-same as logical no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-trn_update':U
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
    contr-in-income-CPT FRAME Dialog-Frame
    contr-in-income-NP FRAME Dialog-Frame
    contr-in-expense-CPT FRAME Dialog-Frame
    contr-in-expense-NP FRAME Dialog-Frame
    contr-qnty-spec
    contr-recount
    .
assign
  fh = frame Dialog-Frame:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-trn where
              recid(thbjattr_thbj-attr-trn) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr-trn:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr-trn.obj-type = p-obj-type.
           thbjattr_thbj-attr-trn.obj-code = p-obj-code.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr-trn,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-trn.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-trn.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-trn.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-trn.prop-code:
   buffer-compare
   thbjattr_thbj-attr-trn
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input 'contr-in':U
      , input table thbjattr_thbj-attr-trn
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.
END PROCEDURE.
