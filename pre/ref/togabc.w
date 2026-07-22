define input  parameter p-type as character no-undo .
define output parameter p-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор групп".
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
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE A AS CHARACTER FORMAT "X(256)":U INITIAL "A"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE B AS CHARACTER FORMAT "X(256)":U INITIAL "B"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE C AS CHARACTER FORMAT "X(256)":U INITIAL "C"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE D AS CHARACTER FORMAT "X(256)":U INITIAL "D"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE E AS CHARACTER FORMAT "X(256)":U INITIAL "E"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE F AS CHARACTER FORMAT "X(256)":U INITIAL "F"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE X AS CHARACTER FORMAT "X(256)":U INITIAL "X"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE Y AS CHARACTER FORMAT "X(256)":U INITIAL "Y"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE Z AS CHARACTER FORMAT "X(256)":U INITIAL "Z"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.
DEFINE VARIABLE T-AX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-AY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-AZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-BX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-BY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-BZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-CY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-CZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-DX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-DY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-DZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-EX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-EY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-EZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-FY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-FZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-CX  AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-FX  AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     T-AX AT ROW 4.25 COL 11
     T-AY AT ROW 4.25 COL 16
     T-AZ AT ROW 4.25 COL 21
     T-BX AT ROW 6.25 COL 11
     T-BY AT ROW 6.25 COL 16
     T-BZ AT ROW 6.25 COL 21
     T-CX  AT ROW 8.25 COL 11
     T-CY AT ROW 8.25 COL 16
     T-CZ AT ROW 8.25 COL 21
     T-DX AT ROW 10.25 COL 11
     T-DY AT ROW 10.25 COL 16
     T-DZ AT ROW 10.25 COL 21
     T-EX AT ROW 12.25 COL 11
     T-EY AT ROW 12.25 COL 16
     T-EZ AT ROW 12.25 COL 21
     T-FX  AT ROW 14.25 COL 11
     T-FY AT ROW 14.25 COL 16
     T-FZ AT ROW 14.25 COL 21
     X AT ROW 3 COL 11 NO-LABEL
     Y AT ROW 3 COL 16.5 NO-LABEL
     Z AT ROW 3 COL 21.5 NO-LABEL
     A AT ROW 4.25 COL 8 NO-LABEL
     B AT ROW 6.25 COL 8 NO-LABEL
     C AT ROW 8.25 COL 8 NO-LABEL
     D AT ROW 10.25 COL 8 NO-LABEL
     E AT ROW 12.25 COL 8 NO-LABEL
     F AT ROW 14.25 COL 8 NO-LABEL
     SPACE(21.87) SKIP(2.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор групп"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
  p-list = "".
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
p-list = "" .
assign
t-ax
T-AY
T-AZ
T-BX
T-BY
T-BZ
T-CX
T-CY
T-CZ
T-DX
T-DY
T-DZ
T-EX
T-EY
T-EZ
T-FX
T-FY
T-FZ
.
case caps(p-type) :
when "ABCXYZ" then do:
  if t-ax = true then p-list = p-list + "AX," .
  if T-AY = true then p-list = p-list + "AY," .
  if T-AZ = true then p-list = p-list + "AZ," .
  if T-BX = true then p-list = p-list + "BX," .
  if T-BY = true then p-list = p-list + "BY," .
  if T-BZ = true then p-list = p-list + "BZ," .
  if T-CX = true then p-list = p-list + "CX," .
  if T-CY = true then p-list = p-list + "CY," .
  if T-CZ = true then p-list = p-list + "CZ," .
  if T-DX = true then p-list = p-list + "DX," .
  if T-DY = true then p-list = p-list + "DY," .
  if T-DZ = true then p-list = p-list + "DZ," .
  if T-EX = true then p-list = p-list + "EX," .
  if T-EY = true then p-list = p-list + "EY," .
  if T-EZ = true then p-list = p-list + "EZ," .
  if T-FX = true then p-list = p-list + "FX," .
  if T-FY = true then p-list = p-list + "FY," .
  if T-FZ = true then p-list = p-list + "FZ," .
end.
when "ABC" then do:
  if t-ax = true then p-list = p-list + "A," .
  if T-BX = true then p-list = p-list + "B," .
  if T-CX = true then p-list = p-list + "C," .
  if T-DX = true then p-list = p-list + "D," .
  if T-EX = true then p-list = p-list + "E," .
  if T-FX = true then p-list = p-list + "F," .
end.
when "XYZ" then do:
  if t-ax = true then p-list = p-list + "X," .
  if T-AY = true then p-list = p-list + "Y," .
  if T-AZ = true then p-list = p-list + "Z," .
end.
end case.
 p-list = trim(p-list, ",").
 if p-list = ""  then do:
    message "Ни чего не выбрано !" .
    return no-apply.
 end.
 message "выбраны группы" p-list .
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
  run my-enable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E F
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit B-Help T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY
         T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E
         F
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-enable :
 ENABLE b-exit B-quit B-Help WITH FRAME Dialog-Frame.
    CASE caps(p-type):
        WHEN "ABC" THEN DO:
            DISPLAY T-AX  T-BX T-CX  T-DX T-EX T-FX  A B C D E F WITH FRAME Dialog-Frame.
            ENABLE  T-AX  T-BX T-CX  T-DX T-EX T-FX  A B C D E F WITH FRAME Dialog-Frame.
        END.
        WHEN "XYZ" THEN DO:
            DISPLAY T-AX T-AY T-AZ X Y Z  WITH FRAME Dialog-Frame.
            ENABLE  T-AX T-AY T-AZ X Y Z  WITH FRAME Dialog-Frame.
        END.
        WHEN "ABCXYZ" THEN DO:
            DISPLAY T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY T-CZ T-DX T-DY T-DZ T-EX
            T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E F
            WITH FRAME Dialog-Frame.
            ENABLE  T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY
            T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E
            F WITH FRAME Dialog-Frame.
        END.
    END CASE.
define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
   case par-abc-type :
      when 'ABC':U  then do:
         hide T-DX T-EX T-FX
              T-DY T-EY T-FY
              T-DZ T-EZ T-FZ
              D E F in frame dialog-frame.
      end.
      when 'ABCD':U  then do:
         hide T-EX T-FX T-EY T-FY T-EZ T-FZ E F in frame dialog-frame.
      end.
      when 'ABCDE':U  then do:
         hide  T-FX  T-FY T-FZ F in frame dialog-frame.
      end.
   end case.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
