using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
define input  parameter parparentproc as   handle    no-undo .
define input  parameter p-mode        as   character no-undo .
define input  parameter vsdsubsObj    as   class vsdsubs   no-undo .
define output parameter p-isSave      as   logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр/Редактирование партий".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define buffer buf_vsd for ub.vsd.
define variable v-page           as integer   no-undo.
define variable v-page-current   as integer   no-undo.
define variable maxsec           as integer   no-undo init 6.
define variable v-section-names  as character no-undo.
define variable lok              as logical   no-undo .
define variable up-image         as handle    no-undo.
define variable tab-type         as int       no-undo.
define variable char-hdl         as character no-undo.
define variable page-label       as handle    extent 20 no-undo.
define variable image-hdl        as handle    extent 20 no-undo.
define variable page-enabled     as logical   extent 20 no-undo.
define variable pos-x            as integer   no-undo init 5.
define variable pos-y            as integer   no-undo init 36.
define variable width-tab-values as int       init [110,72] extent 2 no-undo.
define variable number-of-pages  as integer   no-undo.
define variable vsdsubCurr       as class vsdsub    no-undo.
define variable vsdSts           as class vsdstatustype no-undo.
define variable v-scan-str       as character no-undo.
define variable v-timestap       as integer no-undo.
define variable iLang            as integer no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-isManualVcd     as logical   no-undo .
define variable vsdstrObj         as class vsdtostorage no-undo .
DEFINE BUTTON Btn_Cancel
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "Сохранить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Serv
     LABEL "Служебные"
     SIZE 15 BY 1.13.
DEFINE VARIABLE StatusChar AS CHARACTER FORMAT "X(256)":U
     LABEL "              Статус"
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 82.13 BY 4.33 NO-UNDO.
DEFINE VARIABLE Company AS CHARACTER FORMAT "X(256)":U
     LABEL "        Хоз. субъект"
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE DateCr AS DATE FORMAT "99/99/99":U
     LABEL "     Дата оформления"
     VIEW-AS FILL-IN
     SIZE 14.75 BY 1 NO-UNDO.
DEFINE VARIABLE DateOut AS CHARACTER FORMAT "X(256)":U
     LABEL "      Дата выработки"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE DateOut-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE DateOut-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE DateOut-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate AS CHARACTER FORMAT "X(256)":U
     LABEL "       Срок годности"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-2-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "-"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-2-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-2-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-2-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryDate-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryOutDate AS CHARACTER FORMAT "X(256)":U
     LABEL "-"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryOutDate-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryOutDate-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE ExpiryOutDate-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "ГОД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "ЧЧ"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "ММ"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "ДД"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "ММ"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "ДД"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "ГОД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "ЧЧ"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE Note AS CHARACTER FORMAT "X(256)":U
     LABEL "          Примечание"
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE NumberVSD AS CHARACTER FORMAT "X(256)":U
     LABEL "  Номер ВСД"
     VIEW-AS FILL-IN
     SIZE 25.63 BY 1 NO-UNDO.
DEFINE VARIABLE NumPart AS CHARACTER FORMAT "X(256)":U
     LABEL " Номер произ. партии"
     VIEW-AS FILL-IN
     SIZE 14.75 BY 1 NO-UNDO.
DEFINE VARIABLE Qnty AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "          Количество"
     VIEW-AS FILL-IN
     SIZE 14.75 BY 1 NO-UNDO.
DEFINE VARIABLE SubGrp AS CHARACTER FORMAT "X(256)":U
     LABEL "  Подгруппа"
     VIEW-AS FILL-IN
     SIZE 25.63 BY 1 NO-UNDO.
DEFINE VARIABLE TypeProd AS CHARACTER FORMAT "X(256)":U
     LABEL "       Тип продукции"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE UUID_VSD AS CHARACTER FORMAT "XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX":U
     LABEL "            UUID ВСД"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE RECTANGLE Rect-Bottom
     EDGE-PIXELS 0
     SIZE 33.63 BY .17
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Left
     EDGE-PIXELS 0
     SIZE .63 BY 4.25
     BGCOLOR 15 .
DEFINE RECTANGLE Rect-Main
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 33.75 BY 4.33
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE Rect-Right
     EDGE-PIXELS 0
     SIZE .63 BY 4.33
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Top
     EDGE-PIXELS 0
     SIZE 33.63 BY .17
     BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.17 COL 1.75
     Btn_Cancel AT ROW 1.17 COL 17.75
     Btn_Serv AT ROW 1.17 COL 33.63 WIDGET-ID 36
     UUID_VSD AT ROW 4.13 COL 22.25 COLON-ALIGNED WIDGET-ID 2
     StatusChar AT ROW 5.25 COL 22.25 COLON-ALIGNED WIDGET-ID 6
     NumberVSD AT ROW 5.25 COL 56.63 COLON-ALIGNED WIDGET-ID 4
     DateCr AT ROW 6.38 COL 22.25 COLON-ALIGNED WIDGET-ID 8
     Company AT ROW 7.5 COL 22.25 COLON-ALIGNED WIDGET-ID 10
     TypeProd AT ROW 8.63 COL 22.25 COLON-ALIGNED WIDGET-ID 12
     SubGrp AT ROW 8.63 COL 56.63 COLON-ALIGNED WIDGET-ID 34
     FILL-IN-1 AT ROW 9.75 COL 22.25 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     FILL-IN-3 AT ROW 9.75 COL 28.13 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     FILL-IN-4 AT ROW 9.75 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     FILL-IN-9 AT ROW 9.75 COL 33.88 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     FILL-IN-7 AT ROW 9.75 COL 40.38 COLON-ALIGNED NO-LABEL WIDGET-ID 76
     FILL-IN-5 AT ROW 9.75 COL 46.25 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     FILL-IN-6 AT ROW 9.75 COL 49.13 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     FILL-IN-10 AT ROW 9.75 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 86
     DateOut AT ROW 10.83 COL 22.25 COLON-ALIGNED WIDGET-ID 14
     DateOut-2 AT ROW 10.83 COL 28.13 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     DateOut-3 AT ROW 10.83 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     DateOut-4 AT ROW 10.83 COL 33.88 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     ExpiryOutDate AT ROW 10.83 COL 40.38 COLON-ALIGNED WIDGET-ID 28
     ExpiryOutDate-2 AT ROW 10.83 COL 46.25 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     ExpiryOutDate-3 AT ROW 10.83 COL 49.13 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     ExpiryOutDate-4 AT ROW 10.83 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     ExpiryDate AT ROW 11.96 COL 22.25 COLON-ALIGNED WIDGET-ID 16
     ExpiryDate-2 AT ROW 11.96 COL 28.13 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     ExpiryDate-3 AT ROW 11.96 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     ExpiryDate-4 AT ROW 11.96 COL 33.88 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     ExpiryDate-2-1 AT ROW 11.96 COL 40.38 COLON-ALIGNED WIDGET-ID 58
     ExpiryDate-2-2 AT ROW 11.96 COL 46.25 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     ExpiryDate-2-3 AT ROW 11.96 COL 49.13 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     ExpiryDate-2-4 AT ROW 11.96 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     Qnty AT ROW 13.08 COL 22.25 COLON-ALIGNED WIDGET-ID 18
     NumPart AT ROW 14.21 COL 22.25 COLON-ALIGNED WIDGET-ID 20
     Note AT ROW 15.33 COL 22.25 COLON-ALIGNED WIDGET-ID 22
     EDITOR-1 AT ROW 16.75 COL 2.13 NO-LABEL WIDGET-ID 32
     Rect-Main AT ROW 6.79 COL 6
     Rect-Bottom AT ROW 8.08 COL 3.5
     Rect-Left AT ROW 1.75 COL 1.25
     Rect-Right AT ROW 1.88 COL 34.25
     Rect-Top AT ROW 1.71 COL 1.25
     SPACE(51.49) SKIP(19.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ВСД" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       NumberVSD:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
ON any-printable OF Btn_Cancel IN FRAME Dialog-Frame
do:
  run proc-any-key.
end.
ON choose OF Btn_Cancel IN FRAME Dialog-Frame
do:
  if not v-scan-str = ""
    then return no-apply.
  delete object vsdSts no-error.
  delete object vsdstrObj no-error.
  apply "go" to frame Dialog-Frame.
end.
ON return OF Btn_Cancel IN FRAME Dialog-Frame
do:
  def var str as character no-undo.
  run str/qr2uuid.p (input v-scan-str, output str).
  run setscruuid (input str).
end.
ON any-printable OF Btn_OK IN FRAME Dialog-Frame
do:
  run proc-any-key.
end.
ON choose OF Btn_OK IN FRAME Dialog-Frame
do:
  if not v-scan-str = ""
    then return no-apply.
  if vsdsubCurr:StatusErr
    then return no-apply.
  p-isSave = true.
  delete object vsdSts no-error.
  delete object vsdstrObj no-error.
  apply "go" to frame Dialog-Frame.
end.
ON return OF Btn_OK IN FRAME Dialog-Frame
do:
  def var str as character no-undo.
  run str/qr2uuid.p (input v-scan-str, output str).
  run setscruuid (input str).
end.
ON choose OF Btn_Serv IN FRAME Dialog-Frame
do:
  if not v-scan-str = ""
    then return no-apply.
  run str/vsdserv.w (input vsdsubCurr).
end.
ON return OF Btn_Serv IN FRAME Dialog-Frame
do:
  def var str as character no-undo.
  run str/qr2uuid.p (input v-scan-str, output str).
  run setscruuid (input str).
end.
ON any-printable OF Btn_Serv IN FRAME Dialog-Frame
do:
  run proc-any-key.
end.
ON value-changed OF StatusChar IN FRAME Dialog-Frame
do:
  assign StatusChar.
  vsdsubCurr:Status_ = vsdSts:StatusInt(StatusChar).
end.
ON any-printable OF UUID_VSD IN FRAME Dialog-Frame
do:
  run proc-any-key.
end.
ON endkey OF UUID_VSD IN FRAME Dialog-Frame
do:
  assign UUID_VSD.
  vsdsubCurr:Changed = true.
  vsdsubCurr:UUID = UUID_VSD:screen-value.
end.
ON ENTRY OF UUID_VSD IN FRAME Dialog-Frame
DO:
  run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
END.
ON leave OF UUID_VSD IN FRAME Dialog-Frame
do:
  assign UUID_VSD.
  run setscruuid(input UUID_VSD:screen-value).
  vsdsubCurr:Changed = true.
end.
ON return OF UUID_VSD IN FRAME Dialog-Frame
do:
  def var str as character no-undo.
  run str/qr2uuid.p (input v-scan-str, output str).
  run setscruuid (input str).
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  def var ii as int no-undo.
  define variable v-host-code as integer   no-undo .
  vsdstrObj = new vsdtostorage ().
  vsdSts = new vsdstatustype ().
  v-page-current = 1.
  StatusChar:list-items = vsdSts:StatusList.
  run set-size(input frame Dialog-Frame:height-pixels - 73, input frame Dialog-Frame:width-pixels - 20).
  do ii = 1 to vsdsubsObj:GetItem(ii):
    vsdsubCurr = vsdsubsObj:VsdObjCurr.
    v-section-names = v-section-names + "|" + vsdsubCurr:VSDTypeLbl.
  end.
  v-section-names = trim (v-section-names, "|").
  if v-section-names = ""
    then do:
      vsdsubCurr = new vsdsub ().
      vsdsubCurr:VSDType = vsdSts:VSDIn.
      vsdsubsObj:AddItem(vsdsubCurr).
      v-section-names = vsdsubCurr:VSDTypeLbl.
      lok = yes.
    end.
    else do:
      if p-mode = 'ИЗМЕНЕНИЕ':U
      then do:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_mercury-chg-vsd':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  vsdsubCurr:ObjType
    ,input  vsdsubCurr:ObjCode
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output lok
    )  .
end.
      end.
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'mercur':U
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
    case thbjattr_thbj-attr.prop-code :
      when "manual-vcd" then
        v-isManualVcd = thbjattr_thbj-attr.property-value-logical .
      end case.
  end.
  run initialize-folder (v-section-names).
  run initialize-section.
  run show-current-page(input 1).
  run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
  run enable_UI.
  run hide-disp-page.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
PROCEDURE check-page :
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY UUID_VSD StatusChar NumberVSD DateCr Company TypeProd SubGrp FILL-IN-1
          FILL-IN-3 FILL-IN-4 FILL-IN-9 FILL-IN-7 FILL-IN-5 FILL-IN-6 FILL-IN-10
          DateOut DateOut-2 DateOut-3 DateOut-4 ExpiryOutDate ExpiryOutDate-2
          ExpiryOutDate-3 ExpiryOutDate-4 ExpiryDate ExpiryDate-2 ExpiryDate-3
          ExpiryDate-4 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3
          ExpiryDate-2-4 Qnty NumPart Note EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE Rect-Main Rect-Bottom Rect-Left Rect-Right Rect-Top Btn_OK Btn_Cancel
         Btn_Serv UUID_VSD StatusChar DateCr Company TypeProd SubGrp DateOut
         DateOut-2 DateOut-3 DateOut-4 ExpiryOutDate ExpiryOutDate-2
         ExpiryOutDate-3 ExpiryOutDate-4 ExpiryDate ExpiryDate-2 ExpiryDate-3
         ExpiryDate-4 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3
         ExpiryDate-2-4 Qnty NumPart Note EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE hide-disp-page :
  if v-isManualVcd = true and p-mode = 'ИЗМЕНЕНИЕ':U
    and vsdsubCurr:Status_ = vsdSts:IsNeedCheck
    and
    (entry (v-page-current, v-section-names, "|") = vsdSts:VSDInLbl or entry (v-page-current, v-section-names, "|") = vsdSts:VSDTransLbl)
  then do:
    enable UUID_VSD with frame Dialog-Frame.
  end.
  else do:
    disable UUID_VSD with frame Dialog-Frame.
  end.
  if vsdsubCurr:Status_ = vsdSts:isNeedCheck
  then do:
    hide
      NumberVSD DateCr Company TypeProd ExpiryOutDate ExpiryOutDate-2 ExpiryOutDate-3 ExpiryOutDate-4 DateOut DateOut-3 DateOut-4 DateOut-2
            Qnty NumPart ExpiryDate ExpiryDate-2 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3 ExpiryDate-2-4 ExpiryDate-3 ExpiryDate-4 Note
            EDITOR-1 FILL-IN-1  FILL-IN-3 FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7 FILL-IN-9 FILL-IN-10
      in frame Dialog-Frame.
  end.
  else do:
    display
      NumberVSD DateCr Company TypeProd ExpiryOutDate ExpiryOutDate-2 ExpiryOutDate-3 ExpiryOutDate-4 DateOut DateOut-3 DateOut-4 DateOut-2
            Qnty NumPart ExpiryDate ExpiryDate-2 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3 ExpiryDate-2-4 ExpiryDate-3 ExpiryDate-4 Note
      with frame Dialog-Frame.
  end.
  if vsdsubCurr:ExpiryOutDate = ""
    then hide ExpiryOutDate ExpiryOutDate-2 ExpiryOutDate-3 ExpiryOutDate-4 in frame Dialog-Frame.
  if vsdsubCurr:ExpiryOutDate = ""
    then hide ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3 ExpiryDate-2-4 in frame Dialog-Frame.
  if vsdsubCurr:ExpiryOutDate = "" and vsdsubCurr:ExpiryOutDate = ""
  then do:
    hide FILL-IN-5 FILL-IN-6 FILL-IN-7 FILL-IN-10.
  end.
  hide
    SubGrp
    NumberVSD
    in frame Dialog-Frame.
  disable
      NumberVSD DateCr Company TypeProd ExpiryOutDate ExpiryOutDate-2 ExpiryOutDate-3 ExpiryOutDate-4 DateOut DateOut-3 DateOut-4 DateOut-2
            Qnty NumPart ExpiryDate ExpiryDate-2 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3 ExpiryDate-2-4 ExpiryDate-3 ExpiryDate-4 Note StatusChar
    with frame Dialog-Frame.
  if entry (v-page-current, v-section-names, "|") = vsdSts:VSDInLbl or entry (v-page-current, v-section-names, "|") = vsdSts:VSDTransLbl
  then do:
    if (vsdsubCurr:Status_ = vsdSts:IsErrCheck or vsdsubCurr:Status_ = vsdSts:IsErrUtilized) and lok and p-mode = 'ИЗМЕНЕНИЕ':U
      then enable StatusChar UUID_VSD with frame Dialog-Frame.
  end.
  if UUID_VSD:edit-can-paste
  then do:
    apply "entry" to UUID_VSD in frame Dialog-Frame.
  end.
end procedure.
PROCEDURE initialize-section :
if vsdsubsObj:GetItem(v-page-current) = 0
    then return.
  vsdsubCurr = vsdsubsObj:VsdObjCurr.
  do with frame Dialog-Frame:
    UUID_VSD:screen-value =  vsdsubCurr:UUIDUsr.
    ExpiryOutDate :screen-value = entry(1, vsdsubCurr:ExpiryOutDate , ":") no-error.
    ExpiryOutDate-2 :screen-value = entry(2, vsdsubCurr:ExpiryOutDate , ":") no-error.
    ExpiryOutDate-3 :screen-value = entry(3, vsdsubCurr:ExpiryOutDate , ":") no-error.
    ExpiryOutDate-4 :screen-value = entry(4, vsdsubCurr:ExpiryOutDate , ":") no-error.
    DateOut :screen-value = entry(1, vsdsubCurr:DateOut , ":") no-error.
    DateOut-2 :screen-value = entry(2, vsdsubCurr:DateOut , ":") no-error.
    DateOut-3 :screen-value = entry(3, vsdsubCurr:DateOut , ":") no-error.
    DateOut-4 :screen-value = entry(4, vsdsubCurr:DateOut , ":") no-error.
    ExpiryDate  :screen-value = entry(1, vsdsubCurr:ExpiryDate , ":") no-error.
    ExpiryDate-2  :screen-value = entry(2, vsdsubCurr:ExpiryDate , ":") no-error.
    ExpiryDate-3  :screen-value = entry(3, vsdsubCurr:ExpiryDate , ":") no-error.
    ExpiryDate-4  :screen-value = entry(4, vsdsubCurr:ExpiryDate , ":") no-error.
    ExpiryDate-2-1  :screen-value = entry(1, vsdsubCurr:ExpiryDate2 , ":") no-error.
    ExpiryDate-2-2  :screen-value = entry(2, vsdsubCurr:ExpiryDate2 , ":") no-error.
    ExpiryDate-2-3  :screen-value = entry(3, vsdsubCurr:ExpiryDate2 , ":") no-error.
    ExpiryDate-2-4  :screen-value = entry(4, vsdsubCurr:ExpiryDate2 , ":") no-error.
    assign
      DateCr:screen-value = string (vsdsubCurr:DateCr)
      Company:screen-value = vsdsubCurr:EconomicSub
      TypeProd:screen-value = vsdsubCurr:TypeProd
      Note:screen-value = vsdsubCurr:Note
      NumberVSD:screen-value = vsdsubCurr:VsdNum
      Qnty:screen-value = string (vsdsubCurr:Qnty).
      NumPart:screen-value = string (vsdsubCurr:NumPart).
      SubGrp:screen-value = string (vsdsubCurr:SubProductGuid).
      StatusChar:screen-value = string (vsdsubCurr:StatusLbl).
    EDITOR-1 = vsdsubCurr:MsgErr.
    assign UUID_VSD NumberVSD DateCr Company TypeProd ExpiryOutDate ExpiryOutDate-2 ExpiryOutDate-3 ExpiryOutDate-4 DateOut DateOut-3 DateOut-4 DateOut-2
            Qnty NumPart ExpiryDate ExpiryDate-2 ExpiryDate-2-1 ExpiryDate-2-2 ExpiryDate-2-3 ExpiryDate-2-4 ExpiryDate-3 ExpiryDate-4 Note .
  end.
  run hide-disp-page.
end.
PROCEDURE proc-any-key :
  v-scan-str = v-scan-str + last-event:label.
end.
PROCEDURE trg-folder :
v-page-current = v-page.
  run initialize-section.
end.
PROCEDURE initialize-folder :
  define input parameter folder-labels as character no-undo.
  define variable i             as integer   no-undo.
  define variable temp-hdl      as handle    no-undo.
  define variable del-hdl       as handle    no-undo.
  define variable rebuild       as logical   no-undo init no.
  define variable sts           as logical   no-undo.
  assign
    tab-type = 1 .
  assign
    number-of-pages = num-entries(folder-labels,'|':U).
  if valid-handle(up-image) then
  do:
    temp-hdl = frame Dialog-Frame:HANDLE.
    temp-hdl = temp-hdl:first-child.
    temp-hdl = temp-hdl:first-child.
    do while valid-handle(temp-hdl):
      del-hdl = temp-hdl.
      temp-hdl = temp-hdl:next-sibling.
      if del-hdl:private-data = "Tab-Folder":U then delete widget del-hdl.
    end.
  end.
  create image up-image
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = 0 + pos-x
    y                 = 0 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25 + 4
    private-data      = "Tab-Folder":U
    hidden            = no.
  assign
    sts = up-image:load-image("adeicon/ts-up":U +
         STRING(width-tab-values[tab-type])).
  do i = 1 to number-of-pages:
    if entry(i,folder-labels,'|':U) ne "":U then
      run create-folder-label (i, entry(i, folder-labels,'|':U)).
  end.
  view frame Dialog-Frame.
  run change-folder-page.
  return.
end procedure.
PROCEDURE change-folder-page :
  define variable sts   as logical no-undo.
  define variable page# as integer no-undo.
  if page# > 0 and page# <= 20 and
    VALID-HANDLE (page-label[page#]) then
  do:
    assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  end.
  return.
end procedure.
PROCEDURE create-folder-label :
  define input parameter p-page#        as integer   no-undo.
  define input parameter p-page-label   as character no-undo.
  define variable sts as log no-undo.
  create image image-hdl[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = (p-page# - 1) * width-tab-values[tab-type] + pos-x
    y                 = 2 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25
    private-data      = "Tab-Folder":U
    sensitive         = yes
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  create text page-label[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    y                 = image-hdl[p-page#]:y + 2
    x                 = image-hdl[p-page#]:x + 9
    width-pixel       = image-hdl[p-page#]:WIDTH-PIXEL - 18
    height-pixel      = image-hdl[p-page#]:HEIGHT-PIXEL - 4
    format            = "X(13)":U
    sensitive         = yes
    font              = if tab-type = 1 then ? else 4
    bgcolor           = 8
    screen-value      = p-page-label
    private-data      = "Tab-Folder":U
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  assign
    sts = image-hdl[p-page#]:load-image("adeicon/ts-dn":U +
                STRING(width-tab-values[tab-type])).
  sts = image-hdl[p-page#]:move-to-top().
  sts = page-label[p-page#]:move-to-top().
  assign
    page-enabled[p-page#]      = yes
    image-hdl[p-page#]:hidden  = no
    page-label[p-page#]:hidden = no.
  return.
end procedure.
PROCEDURE create-folder-page :
  define input parameter p-page#      as integer   no-undo.
  define input parameter p-new-label  as character no-undo.
  define variable i          as integer   no-undo.
  define variable num-labels as integer   no-undo.
  define variable labels     as character no-undo.
  define variable new-labels as character no-undo init "".
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if labels = ? then labels = "".
  num-labels = num-entries(labels,'|':U).
  if p-page# <= num-labels then
  do i = 1 to num-labels:
    new-labels = new-labels +
      if i = p-page# then p-new-label
      else entry(i, labels, '|':U).
    if i < num-labels then new-labels = new-labels + '|':U.
  end.
  else
  do:
    new-labels = labels.
    do i = 1 to p-page# - num-labels - if num-labels = 0 then 1 else 0:
      new-labels = new-labels + '|':U.
    end.
    new-labels = new-labels + p-new-label.
  end.
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + new-labels).
  run initialize-folder.
  return.
end procedure.
PROCEDURE delete-folder-page :
  define input parameter p-page#  as integer no-undo.
  define variable i      as integer   no-undo.
  define variable pos1   as integer   no-undo init 0.
  define variable pos2   as integer   no-undo.
  define variable labels as character no-undo.
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if valid-handle (page-label[p-page#]) then
    delete widget page-label[p-page#].
  if valid-handle (image-hdl[p-page#]) then
    delete widget image-hdl[p-page#].
  do i = 1 to p-page# - 1:
    pos1 = index(labels,'|':U, pos1 + 1).
  end.
  pos2 = index(labels,'|':U, pos1 + 1).
  labels = if pos2 ne 0 then SUBSTR(labels, 1, pos1, "CHARACTER":U) +
    SUBSTR(labels, pos2, -1, "CHARACTER":U)
    else SUBSTR(labels, 1, pos1 - 1, "CHARACTER":U).
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + labels).
  return.
end procedure.
PROCEDURE disable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = no
    page-label[p-page#]:fgcolor = 7.
  return.
end procedure.
PROCEDURE enable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = yes
    page-label[p-page#]:fgcolor = ?.
  return.
end procedure.
PROCEDURE label-trigger :
  define input parameter p-page# as integer no-undo.
  v-page = p-page#.
  run trg-folder in this-procedure no-error.
  if error-status:error
    then return.
  run show-current-page(input p-page#).
  return.
end procedure.
PROCEDURE local-initialize :
  run initialize-folder.
  run dispatch in THIS-PROCEDURE ('initialize':U).
  return.
end procedure.
PROCEDURE set-size :
  define input parameter p-height as decimal no-undo.
  define input parameter p-width  as decimal no-undo.
  define variable sts as logical.
  if p-height < 1.35 then p-height = 1.35.
  do with frame Dialog-Frame:
    assign
      Rect-Main:X               = 0 + pos-x
      Rect-Main:Y               = 25 + pos-y
      Rect-Main:WIDTH-PIXELS    = p-width
      Rect-Main:HEIGHT-PIXELS   = p-height
                                     - 25
      Rect-Top:X                = 1 + pos-x
      Rect-Top:Y                = 25 + 1 + pos-y
      Rect-Top:WIDTH-PIXELS     = p-width
                                     - 3
      Rect-Top:HEIGHT-PIXELS    = 3
      Rect-Bottom:X             = 1 + pos-x
      Rect-Bottom:Y             = p-height - 4 + pos-y
      Rect-Bottom:HEIGHT-PIXELS = 3
      Rect-Bottom:WIDTH-PIXELS  = p-width
                                     - 2
      Rect-Left:X               = 1 + pos-x
      Rect-Left:Y               = 25 + 1 + pos-y
      Rect-Left:WIDTH-PIXELS    = 3
      Rect-Left:HEIGHT-PIXELS   = p-height
                                     - 25 - 2
      Rect-Right:X              = p-width + pos-x
                                     - 4
      Rect-Right:Y              = 25 + 4 + pos-y
      Rect-Right:WIDTH-PIXELS   = 3
      Rect-Right:HEIGHT-PIXELS  = p-height
                                     - 25 - 5
      Rect-Main:HIDDEN          = no
      Rect-Top:HIDDEN           = no
      Rect-Bottom:HIDDEN        = no
      Rect-Left:HIDDEN          = no
      Rect-Right:HIDDEN         = no.
  end.
  return.
end procedure.
PROCEDURE show-current-page :
  define input parameter page# as integer no-undo.
  define variable sts as logical no-undo.
  if page# > 0 and page# <= 20 and
    VALID-HANDLE (page-label[page#])
    then assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  else if number-of-pages > 0 then
      assign up-image:hidden = yes.
end procedure.
PROCEDURE state-changed :
  define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.
procedure LoadKeyboardLayoutA external "user32" :
  define input  parameter P1 as char.
  define input  parameter P2 as LONG.
  define return parameter pret as LONG.
end procedure.
procedure ActivateKeyboardLayout external "user32" :
    define input parameter P1 as LONG.
    define input parameter P2 as LONG.
end procedure.
procedure setscruuid :
  def input parameter str as character no-undo.
  def var uuid-back as character no-undo.
  do with frame Dialog-Frame:
    v-scan-str = "".
    uuid-back = vsdsubCurr:UUID.
    vsdsubCurr:UUID = str.
    if vsdstrObj:exsistuuidwithtrn(vsdsubCurr)
    then do:
      vsdsubCurr:UUID = uuid-back.
      message vsdstrObj:Msg view-as alert-box.
    end.
    UUID_VSD = vsdsubCurr:UUIDUsr.
    UUID_VSD:screen-value = UUID_VSD.
  end.
end procedure.
