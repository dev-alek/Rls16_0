DEFINE TEMP-TABLE x_thbj-attr NO-UNDO LIKE ub.thbj-attr
       field p1 as char
       field d1 as int
       field d2 as int
       field d3 as int
       field d4 as int
       field d5 as int
       field d6 as int
       field d7 as int
       .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры Ассортиментной политики" .
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
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer abc_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-abc no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-abc as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable p-mode as character no-undo .
define variable str-attr as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-tth-abc = buffer thbjattr_thbj-attr-abc:table-handle .
if g#db-num = 0 then p-mode = 'ИЗМЕНЕНИЕ':U.
   else p-mode = 'ПРОСМОТР':U .
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
DEFINE VARIABLE loc-a AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "A" NO-UNDO.
DEFINE VARIABLE loc-abc-one_1 AS DECIMAL FORMAT ">9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-one_2 AS DECIMAL FORMAT ">9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-one_3 AS DECIMAL FORMAT ">>9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-one_4 AS DECIMAL FORMAT ">>9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-one_5 AS DECIMAL FORMAT ">>9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-one_6 AS DECIMAL FORMAT ">>9.<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_1 AS DECIMAL FORMAT ">9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_2 AS DECIMAL FORMAT ">9.999":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_3 AS DECIMAL FORMAT ">9.9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_4 AS DECIMAL FORMAT ">9.9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_5 AS DECIMAL FORMAT ">9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE loc-abc-two_6 AS DECIMAL FORMAT ">>9":U INITIAL 100
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE loc-b AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "B" NO-UNDO.
DEFINE VARIABLE loc-c AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "C" NO-UNDO.
DEFINE VARIABLE loc-d AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "D" NO-UNDO.
DEFINE VARIABLE loc-e AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "E" NO-UNDO.
DEFINE VARIABLE loc-f AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 TOOLTIP "F" NO-UNDO.
DEFINE VARIABLE v-abc-mode AS CHARACTER FORMAT "X(256)":U INITIAL "Способ проведения АБС анализа"
      VIEW-AS TEXT
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-abc-one AS CHARACTER FORMAT "X(256)":U INITIAL "Проценты по умолчанию для простого АБС анализа .Уровни ранжирования"
      VIEW-AS TEXT
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-abc-sale-day AS CHARACTER FORMAT "X(256)":U INITIAL "Гарантийный запас по АВС в днях"
      VIEW-AS TEXT
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-abc-two AS CHARACTER FORMAT "X(256)":U INITIAL "Проценты по умолчанию для двухпроходного АБС анализа"
      VIEW-AS TEXT
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-abc-type AS CHARACTER FORMAT "X(256)":U INITIAL "Количество параметров для АБС анализа"
      VIEW-AS TEXT
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE I-abc-mode
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.5.
DEFINE IMAGE I-abc-one
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.
DEFINE IMAGE I-abc-sale-day
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.
DEFINE IMAGE I-abc-two
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.
DEFINE IMAGE I-abc-type
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 2.75.
DEFINE VARIABLE abc-mode AS CHARACTER INITIAL "simple"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Простой", "simple",
"Двухуровневый", "bimodal"
     SIZE 16 BY 1.75 NO-UNDO.
DEFINE VARIABLE abc-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "ABC", "ABC",
"ABCD", "ABCD",
"ABCDE", "ABCDE",
"ABCDEF", "ABCDEF"
     SIZE 9.5 BY 3 NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      X_thbj-attr SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      X_thbj-attr.p1 FORMAT "X(8)":U COLUMN-LABEL " "
      X_thbj-attr.obj-type FORMAT "X(3)":U
      X_thbj-attr.obj-code FORMAT ">>>>>>>>>":U
      X_thbj-attr.d1  COLUMN-LABEL "A" FORMAT ">>>>":U
      X_thbj-attr.d2  COLUMN-LABEL "B" FORMAT ">>>>":U
      X_thbj-attr.d3  COLUMN-LABEL "C" FORMAT ">>>>":U
      X_thbj-attr.d4  COLUMN-LABEL "D" FORMAT ">>>>":U
      X_thbj-attr.d5  COLUMN-LABEL "E" FORMAT ">>>>":U
      X_thbj-attr.d6  COLUMN-LABEL "F" FORMAT ">>>>":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 6.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     abc-mode AT ROW 3 COL 4.75 NO-LABEL WIDGET-ID 2
     abc-type AT ROW 6 COL 4.75 NO-LABEL WIDGET-ID 12
     loc-abc-one_1 AT ROW 9.75 COL 2.75 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     loc-abc-one_2 AT ROW 9.75 COL 8 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     loc-abc-one_3 AT ROW 9.75 COL 13.13 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     loc-abc-one_4 AT ROW 9.75 COL 19.25 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     loc-abc-one_5 AT ROW 9.75 COL 25.25 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     loc-abc-one_6 AT ROW 9.75 COL 31.25 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     loc-abc-two_1 AT ROW 12 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     loc-abc-two_2 AT ROW 12 COL 14 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     loc-abc-two_3 AT ROW 13.04 COL 8.75 NO-LABEL WIDGET-ID 46
     loc-abc-two_4 AT ROW 13.04 COL 12.13 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     loc-abc-two_6 AT ROW 13.04 COL 17.5 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     loc-abc-two_5 AT ROW 14.13 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     loc-a AT ROW 17 COL 2.75 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     loc-b AT ROW 17 COL 7.88 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     loc-c AT ROW 17 COL 12.88 COLON-ALIGNED NO-LABEL WIDGET-ID 76
     loc-d AT ROW 17 COL 17.88 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     loc-e AT ROW 17 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     loc-f AT ROW 17 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     BROWSE-2 AT ROW 17 COL 36.5 WIDGET-ID 200
     v-abc-mode AT ROW 2.25 COL 1.5 NO-LABEL WIDGET-ID 6
     v-abc-type AT ROW 5.25 COL 1.5 NO-LABEL WIDGET-ID 18
     v-abc-one AT ROW 9 COL 1.5 NO-LABEL WIDGET-ID 20
     v-abc-two AT ROW 11 COL 1.5 NO-LABEL WIDGET-ID 38
     v-abc-sale-day AT ROW 16 COL 1.5 NO-LABEL WIDGET-ID 68
     "IIa." VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 13.08 COL 4.75 WIDGET-ID 54
          FGCOLOR 4
     "IIb." VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 14.13 COL 4.75 WIDGET-ID 56
          FGCOLOR 4
     "%% ABC-анализа внутри первой группы" VIEW-AS TEXT
          SIZE 36.5 BY 1 AT ROW 13 COL 25 WIDGET-ID 66
          FGCOLOR 1
     "% Первой группы" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 12 COL 23.5 WIDGET-ID 64
          FGCOLOR 1
     "% отсекания" VIEW-AS TEXT
          SIZE 11.75 BY 1 AT ROW 14.13 COL 16.25 WIDGET-ID 62
          FGCOLOR 1
     "I." VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 12 COL 4.75 WIDGET-ID 52
          FGCOLOR 4
     I-abc-mode AT ROW 3.04 COL 2.5 WIDGET-ID 10
     I-abc-type AT ROW 6 COL 2.5 WIDGET-ID 34
     I-abc-one AT ROW 9.83 COL 2.38 WIDGET-ID 36
     I-abc-two AT ROW 12.13 COL 2.25 WIDGET-ID 40
     I-abc-sale-day AT ROW 17.13 COL 2.5 WIDGET-ID 70
     SPACE(82.62) SKIP(5.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки ассортиментной политики"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       loc-abc-two_2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       loc-abc-two_6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-abc-mode:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-abc-one:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-abc-sale-day:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-abc-two:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-abc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF abc-mode IN FRAME Dialog-Frame
DO:
  ASSIGN abc-mode .
  IF abc-mode = 'bimodal' THEN DO:
          abc-type = 'ABC'.
      DISPLAY abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME Dialog-Frame.
      DISABLE abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME Dialog-Frame.
      ENABLE loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
          WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
      ENABLE abc-type
          loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME Dialog-Frame .
      DISPLAY loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
              WITH FRAME Dialog-Frame.
      DISABLE
          loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
          WITH FRAME Dialog-Frame.
  END.
  APPLY "VALUE-CHANGED":U TO abc-type .
END.
ON VALUE-CHANGED OF abc-type IN FRAME Dialog-Frame
DO:
  ASSIGN abc-type.
  display loc-a loc-b loc-c loc-d loc-e loc-f  WITH FRAME Dialog-Frame .
  CASE abc-type:
      WHEN 'ABC' THEN DO:
          loc-abc-one_6 = 0 .
          loc-abc-one_5 = 0 .
          loc-abc-one_4 = 0 .
          loc-abc-one_3 = 100 .
          loc-e = 0.
          loc-d = 0.
          loc-f = 0.
          display loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-f loc-e loc-d WITH FRAME Dialog-Frame .
          DISABLE loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-f loc-e loc-d WITH FRAME Dialog-Frame .
          IF abc-mode = 'simple' THEN DO:
              ENABLE loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 WITH FRAME Dialog-Frame .
              ENABLE loc-a loc-b loc-c WITH FRAME Dialog-Frame .
           END.
           ELSE ENABLE loc-a loc-b loc-c loc-d loc-e WITH FRAME Dialog-Frame .
      END.
      WHEN 'ABCD' THEN DO:
       loc-abc-one_4 = 100 .
       loc-abc-one_5 = 0 .
       loc-abc-one_6 = 0 .
       loc-e = 0.
       loc-f = 0.
       DISplay loc-abc-one_5 loc-abc-one_6 loc-f loc-e  WITH FRAME Dialog-Frame .
       DISABLE loc-abc-one_5 loc-abc-one_6 loc-f loc-e  WITH FRAME Dialog-Frame .
       ENABLE  loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-a loc-b loc-c loc-d WITH FRAME Dialog-Frame .
      END.
      WHEN 'ABCDE' THEN DO:
       loc-abc-one_5 = 100 .
       loc-abc-one_6 = 0 .
       loc-f = 0.
       DISplay  loc-abc-one_6 loc-f  WITH FRAME Dialog-Frame .
       DISABLE  loc-abc-one_6 loc-f WITH FRAME Dialog-Frame .
       ENABLE loc-abc-one_5 loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-a loc-b loc-c loc-d loc-e WITH FRAME Dialog-Frame .
      END.
      WHEN 'ABCDEF' THEN DO:
          loc-abc-one_6 = 100 .
          ENABLE loc-abc-one_5 loc-abc-one_6 loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3
           loc-f loc-e loc-d loc-a loc-b loc-c
           WITH FRAME Dialog-Frame .
      END.
  END CASE.
  if  loc-abc-one_1 = 0 and loc-abc-one_1:SENSITIVE = false then hide loc-abc-one_1 in frame Dialog-Frame .
  if  loc-abc-one_2 = 0 and loc-abc-one_2:SENSITIVE = false then hide loc-abc-one_2 in frame Dialog-Frame .
  if  loc-abc-one_3 = 0 and loc-abc-one_3:SENSITIVE = false then hide loc-abc-one_3 in frame Dialog-Frame .
  if  loc-abc-one_4 = 0 and loc-abc-one_4:SENSITIVE = false then hide loc-abc-one_4 in frame Dialog-Frame .
  if  loc-abc-one_5 = 0 and loc-abc-one_5:SENSITIVE = false then hide loc-abc-one_5 in frame Dialog-Frame .
  if  loc-abc-one_6 = 0 and loc-abc-one_6:SENSITIVE = false then hide loc-abc-one_6 in frame Dialog-Frame .
END.
ON MOUSE-SELECT-CLICK OF I-abc-mode IN FRAME Dialog-Frame
DO:
  MESSAGE I-abc-mode:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-abc-one IN FRAME Dialog-Frame
DO:
  MESSAGE I-abc-one:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-abc-sale-day IN FRAME Dialog-Frame
DO:
  MESSAGE I-abc-sale-day:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-abc-two IN FRAME Dialog-Frame
DO:
  MESSAGE I-abc-two:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-abc-type IN FRAME Dialog-Frame
DO:
  MESSAGE I-abc-type:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON LEAVE OF loc-abc-two_1 IN FRAME Dialog-Frame
DO:
  ASSIGN loc-abc-two_1.
  loc-abc-two_2 = 100 - loc-abc-two_1.
  DISPLAY loc-abc-two_2 WITH FRAME Dialog-Frame.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-2 :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable loc#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-assort_lookup':U
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
  if loc#log <> yes then do: return . end.
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
  DISPLAY abc-mode abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3
          loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-abc-two_1 loc-abc-two_2
          loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 loc-abc-two_5 loc-a loc-b
          loc-c loc-d loc-e loc-f v-abc-mode v-abc-type v-abc-one v-abc-two
          v-abc-sale-day
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-abc-mode I-abc-type I-abc-one I-abc-two
         I-abc-sale-day abc-mode abc-type loc-abc-one_1 loc-abc-one_2
         loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-abc-two_1
         loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 loc-abc-two_5
         loc-a loc-b loc-c loc-d loc-e loc-f BROWSE-2 v-abc-mode v-abc-type
         v-abc-one v-abc-two v-abc-sale-day
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH X_thbj-attr        NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable temp-v-abc-one as character no-undo .
define variable temp-v-abc-two as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-abc:
  delete thbjattr_thbj-attr-abc.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'abc-sale-day':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'abc-global':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-abc
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  IF thbjattr_thbj-attr.prop-code = 'A':U THEN DO:
    loc-a = thbjattr_thbj-attr.property-value-integer.
    loc-a:private-data IN FRAME Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = 'B':U THEN DO:
    loc-b = thbjattr_thbj-attr.property-value-integer.
    loc-b:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = 'C':U THEN DO:
    loc-c = thbjattr_thbj-attr.property-value-integer.
    loc-c:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = 'D':U THEN DO:
    loc-d = thbjattr_thbj-attr.property-value-integer.
    loc-d:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = 'E':U THEN DO:
    loc-e = thbjattr_thbj-attr.property-value-integer.
    loc-e:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = 'F':U THEN DO:
    loc-f = thbjattr_thbj-attr.property-value-integer.
    loc-f:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
FOR EACH thbjattr_thbj-attr-abc:
  IF thbjattr_thbj-attr-abc.prop-code = 'abc-mode':U THEN DO:
     abc-mode = thbjattr_thbj-attr-abc.property-value-character.
     abc-mode:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-abc)).
     display abc-mode with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-abc.prop-code = 'abc-type':U THEN DO:
     abc-type = thbjattr_thbj-attr-abc.property-value-character.
     abc-type:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-abc)).
     display abc-type with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-abc.prop-code = 'abc-one':U THEN DO:
     temp-v-abc-one = thbjattr_thbj-attr-abc.property-value-character.
     loc-abc-one_1 = if num-entries (temp-v-abc-one,"/") >= 1 then decimal(entry(1,temp-v-abc-one,"/")) else 0.
     loc-abc-one_2 = if num-entries (temp-v-abc-one,"/") >= 2 then decimal(entry(2,temp-v-abc-one,"/")) else 0.
     loc-abc-one_3 = if num-entries (temp-v-abc-one,"/") >= 3 then decimal(entry(3,temp-v-abc-one,"/")) else 0.
     loc-abc-one_4 = if num-entries (temp-v-abc-one,"/") >= 4 then decimal(entry(4,temp-v-abc-one,"/")) else 0.
     loc-abc-one_5 = if num-entries (temp-v-abc-one,"/") >= 5 then decimal(entry(5,temp-v-abc-one,"/")) else 0.
     loc-abc-one_6 = if num-entries (temp-v-abc-one,"/") >= 6 then decimal(entry(6,temp-v-abc-one,"/")) else 0.
     display loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-abc.prop-code = 'abc-two':U THEN DO:
     temp-v-abc-two = thbjattr_thbj-attr-abc.property-value-character.
     loc-abc-two_1 = decimal(entry(1,entry(1,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_1 = 0 .
     loc-abc-two_2 = decimal(entry(2,entry(1,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_2 = 0 .
     loc-abc-two_3 = decimal(entry(1,entry(2,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_3 = 0 .
     loc-abc-two_4 = decimal(entry(2,entry(2,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_4 = 0 .
     loc-abc-two_6 = 100.
     loc-abc-two_5 = decimal(entry(3,temp-v-abc-two,";")) no-error .
     if error-status :error then loc-abc-two_5 = 0 .
     display loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6 with frame Dialog-Frame .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-abc to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
             input   'abc-sale-day':U
            ,input  ""
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-sale-day:screen-value = v-label .
i-abc-sale-day:private-data = v-tooltip .
run thbjattr_tooltip in this-procedure (
             input   'abc-global':U
            ,input  "abc-mode"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-mode:screen-value = entry(2,v-label,":") .
I-abc-mode:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'abc-global':U
            ,input  "abc-type"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-type:screen-value = entry(2,v-label,":") .
I-abc-type:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'abc-global':U
            ,input  "abc-one"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-one:screen-value = entry(2,v-label,":") .
I-abc-one:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'abc-global':U
            ,input  "abc-two"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-two:screen-value = entry(2,v-label,":") .
I-abc-two:private-data = v-tooltip-code .
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
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = ""
        and   buf_thbj-attr.obj-code = 0
        and   buf_thbj-attr.upper-prop-code = 'abc-sale-day':U
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'abc-sale-day':U skip
        "Запись Глобальных ПАРАМЕТРОВ занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first abc_thbj-attr exclusive-lock where
              abc_thbj-attr.obj-type = ""
        and   abc_thbj-attr.obj-code = 0
        and   abc_thbj-attr.upper-prop-code = 'abc-global':U
        and   abc_thbj-attr.prop-code = '':u no-wait no-error.
     if locked abc_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'abc-global':U skip
        "Запись Глобальных ПАРАМЕТРОВ abc занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = ""
    and   buf_thbj-attr.obj-code = 0
    and   buf_thbj-attr.upper-prop-code = 'abc-sale-day':U
    and   buf_thbj-attr.prop-code = '':u no-error.
    find first abc_thbj-attr no-lock where
          abc_thbj-attr.obj-type = ""
    and   abc_thbj-attr.obj-code = 0
    and   abc_thbj-attr.upper-prop-code = 'abc-global':U
    and   abc_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create  = true
      .
    message
    substitute ("Внимание!!!&1Параметра &1&2&1НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10),
                v-abc-sale-day:screen-value in frame Dialog-Frame  )
                 view-as alert-box warning.
  end.
  if not available abc_thbj-attr then do:
    assign
      v-to-create-abc  = true
      .
    message
    substitute ("Внимание!!!&1Параметра abc НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  apply "value-changed":u to abc-mode in frame Dialog-Frame.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable abc-mode abc-type with frame Dialog-Frame.
     loc-abc-one_1:read-only = true .
     loc-abc-one_2:read-only = true .
     loc-abc-one_3:read-only = true .
     loc-abc-one_4:read-only = true .
     loc-abc-one_5:read-only = true .
     loc-abc-one_6:read-only = true .
     loc-abc-two_1:read-only = true .
     loc-abc-two_2:read-only = true .
     loc-abc-two_3:read-only = true .
     loc-abc-two_4:read-only = true .
     loc-abc-two_5:read-only = true .
     loc-abc-two_6:read-only = true .
     loc-a:read-only = true .
     loc-b:read-only = true .
     loc-c:read-only = true .
     loc-d:read-only = true .
     loc-e:read-only = true .
     loc-f:read-only = true .
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
end procedure.
PROCEDURE init-tt :
define buffer buf_thbj-attr for ub.thbj-attr .
for each buf_thbj-attr no-lock where
         buf_thbj-attr.upper-prop-code = "abc-sale-day" and
         buf_thbj-attr.prop-code <> "" Break by buf_thbj-attr.obj-type by buf_thbj-attr.obj-code :
   find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .
        if not available x_thbj-attr then do:
          create  x_thbj-attr.
          assign
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code
          .
        end.
       if buf_thbj-attr.obj-type  = "" then
        assign
          x_thbj-attr.p1 = "глобально"
        .
       if buf_thbj-attr.obj-type  = 'орг':U then
        assign
          x_thbj-attr.p1 = "фирма"
        .
       if buf_thbj-attr.obj-type  <> 'орг':U and buf_thbj-attr.obj-type  <> "" then
        assign
          x_thbj-attr.p1 = "объект"
        .
       case buf_thbj-attr.prop-code :
       when "A" then
            assign
             x_thbj-attr.d1 = buf_thbj-attr.property-value-integer
            .
       when "B" then
            assign
             x_thbj-attr.d2 = buf_thbj-attr.property-value-integer
            .
       when "C" then
            assign
             x_thbj-attr.d3 = buf_thbj-attr.property-value-integer
            .
       when "D" then
            assign
             x_thbj-attr.d4 = buf_thbj-attr.property-value-integer
            .
       when "E" then
            assign
             x_thbj-attr.d5 = buf_thbj-attr.property-value-integer
            .
       when "F" then
            assign
             x_thbj-attr.d6 = buf_thbj-attr.property-value-integer
            .
       end case.
end.
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
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-assort_update':U
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
    abc-mode FRAME Dialog-Frame
    abc-type
    loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
    loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
    loc-a loc-b loc-c loc-d loc-e loc-f
    .
 if abc-mode = "simple" then do:
 if abc-type = "ABC"  then do:
     if loc-abc-one_3 <> 100 then message "Внимание! Меняю " loc-abc-one_3 " на 100% "  view-as alert-box information .
     loc-abc-one_3  = 100 .
     loc-abc-one_4 = 0 .
     loc-abc-one_5 = 0 .
     loc-abc-one_6 = 0 .
     loc-d = 0 .
     loc-e = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
 end.
 if abc-type = "ABCD"  then do:
     if loc-abc-one_4 <> 100 then message "Внимание! Меняю " loc-abc-one_4 " на 100% "  view-as alert-box information .
     loc-abc-one_4 = 100 .
     loc-abc-one_5 = 0 .
     loc-abc-one_6 = 0 .
     loc-e = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.
 end.
 if abc-type = "ABCDE"  then do:
     if loc-abc-one_5 <> 100 then message "Внимание! Меняю " loc-abc-one_5 " на 100% "  view-as alert-box information .
     loc-abc-one_5 = 100 .
     loc-abc-one_6 = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_4  <= 0  or loc-abc-one_4 >= loc-abc-one_5 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (4) " view-as alert-box error .
        return error.
     end.
 end.
 if abc-type = "ABCDEF"  then do:
     if loc-abc-one_6 <> 100 then message "Внимание! Меняю " loc-abc-one_6 " на 100% "  view-as alert-box information .
     loc-abc-one_6 = 100 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_4  <= 0  or loc-abc-one_4 >= loc-abc-one_5 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (4) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_5  <= 0  or loc-abc-one_5 >= loc-abc-one_6 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (5) " view-as alert-box error .
        return error.
     end.
 end.
 end.
assign
fh = frame Dialog-Frame:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-abc where
              recid(thbjattr_thbj-attr-abc) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr-abc:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
for each thbjattr_thbj-attr-abc,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-abc.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-abc.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-abc.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-abc.prop-code:
   buffer-compare
   thbjattr_thbj-attr-abc
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
find first  thbjattr_thbj-attr-abc where
  thbjattr_thbj-attr-abc.prop-code = "abc-one" no-error .
  thbjattr_thbj-attr-abc.property-value-character = string(loc-abc-one_1) + "/" +
  string(loc-abc-one_2)  + "/" +
  string(loc-abc-one_3)  + "/" +
  string(loc-abc-one_4)  + "/" +
  string(loc-abc-one_5)  + "/" +
  string(loc-abc-one_6) .
find first  thbjattr_thbj-attr-abc where
  thbjattr_thbj-attr-abc.prop-code = "abc-two" no-error .
  thbjattr_thbj-attr-abc.property-value-character =
  string(loc-abc-two_1) + "/" + string(loc-abc-two_2) + ";" +
  string(loc-abc-two_3) + "/" + string(loc-abc-two_4) + ";" +
  string(loc-abc-two_5) .
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
run adm/shattri.p (
      input "check":u
    , input ""
    , input 0
    , input 'abc-sale-day':U
    , input '':u
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .
if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input 'abc-sale-day':U
      ,input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input 'abc-global':U
      ,input table thbjattr_thbj-attr-abc
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.
END PROCEDURE.
