using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-select as logical   no-undo .
define output parameter p-RegID as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акты о списании из торгового зала ЕГАИС".
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
define variable th-act-header         as handle    no-undo.
define variable bh-act-header         as handle    no-undo.
define variable qh-act-header         as handle    no-undo.
define variable browse-hdl-act-header as handle    no-undo.
define variable bcol                as handle    extent 11 no-undo.
define variable calc-col-hndl       as handle    no-undo .
define variable calc-col-hndl2      as handle    no-undo .
define variable egais               as class     ActWriteOff_Shop no-undo.
define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .
define variable qh-ab-gds-EG-header as handle    no-undo.
define variable qh-ab-gds-EG        as handle    no-undo.
define variable bh-ab-gds-EG-header as handle    no-undo.
define variable bh-ab-gds-EG        as handle    no-undo.
define variable v-RegID             as character no-undo .
define variable glog        as logical no-undo .
define variable v-act-num as character no-undo .
define variable ii                  as integer no-undo .
define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .
define buffer buf_clob-bind     for ub.clob-bind .
define buffer buf_clob-data     for ub.clob-data .
define buffer buf_goods         for ub.goods .
define buffer buf_parts         for ub.parts .
define buffer x_ext-classif     for ub.ext-classif .
define buffer x_ext-classif-attr     for ub.ext-classif-attr .
define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field type_         as character        label "Основание списания" format "X(18)"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code
.
define new shared temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    index pi as primary unique
        mark
.
define variable sw as handle no-undo .
define variable v-file              as character no-undo initial "ActWriteOff_Shop1.xml".
DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.
procedure makeXML :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) no-error .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) no-error .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) no-error .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) no-error .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) no-error .
                        sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                        sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error .
                        sw:write-data-element ("alc-code", tt-gds-act.alc-code) no-error .
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("awr:MarkCodeInfo") .
                    sw:end-element ("awr:Position") .
    end.
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXMLegais_v2 :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOffShop_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOffShop_v2") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
                    if not available buf_goods and (tt-gds-act.gds-code = 0 or tt-gds-act.gds-code =?)
                    then do :
                        find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif.db-num = 0
                                                               and X_ext-classif.Key#_two = v-ext-sys
                                                               and X_ext-classif.Key#_three = 0
                                                               and X_ext-classif.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif.CharKey_two = ""
                                                               and X_ext-classif.CharKey_three = ""
                                                               and X_ext-classif.nonunique = 0
                                                               no-error .
                        if available X_ext-classif
                        then do :
                            tt-gds-act.gds-code = X_ext-classif.Key#_One .
                            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                        end.
                    end.
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("awr:Product") .
                            sw:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) .
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") .
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) .
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = 'goods':U
                                                               and X_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do :
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          def var v-err as logical no-undo.
                          def var v-err-impor as logical no-undo.
                          v-err = false .
                          v-prod = ''.
                          v-impor = ''.
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = ""
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                            v-err = true .
                          end.
                          if not v-err then do :
                            sw:start-element ("pref:Producer") .
                             sw:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw:end-element ("oref:address").
                             sw:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw:end-element ("pref:Producer") .
                          end.
                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        sw:end-element ("awr:Product") .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks and (tt-act-header.type_ = "Проверки" or tt-act-header.type_ = "Арест") then do :
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("awr:MarkCodeInfo") .
        end.
                    sw:end-element ("awr:Position") .
    end.
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOffShop_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure parseXML :
    define input parameter inFile as character no-undo .
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search(inFile),FALSE).
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    RUN GetChildren(hRoot, 1).
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
end procedure .
procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "awr:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "awr:ActNumber" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:ActDate" THEN
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "awr:TypeWriteOff" THEN assign tt-act-header.type_    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "awr:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "awr:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act.gds-code = integer(hText:node-value) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act.gds-name) = "" then assign tt-gds-act.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"     THEN assign tt-gds-act.alc-code = (hText:node-value) no-error .
        IF hNoderef:NAME = "awr:MarkCode" THEN do :
            create tt-marks.
            assign
                tt-marks.num                    = tt-gds-act.num
                tt-marks.gds-part-position_     = tt-gds-act.position_
                tt-marks.mark                   = hText:node-value
                tt-marks.gds-code               = tt-gds-act.gds-code
                tt-marks.gds-name               = tt-gds-act.gds-name
                tt-marks.alc-code               = tt-gds-act.alc-code
                ii = ii + 1.
            .
            assign tt-gds-act.marks-qnty = ii .
        end.
        run GetChildren (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
DEFINE BUTTON Btn_lkp
     LABEL "Просмотр"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_create
     LABEL "Создать"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_chg
     LABEL "Изменить"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_del
     LABEL "Удалить"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_send
     LABEL "Отправить"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Ans
     LABEL "Посмотреть ответ"
     SIZE 20 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Sel AUTO-GO
     LABEL "Выбор"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Edit
     LABEL "Редактировать"
     SIZE 15 BY 1.13 tooltip "Вернуть в 'Новые' для редактирования"
     BGCOLOR 8 .
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Новые", 1,
          "Отправленные", 2
     SIZE 27 BY 1.25 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.2 COL 2
     Btn_create at row 1.2 col 17
     Btn_chg at row 1.2 col 32
     Btn_del at row 1.2 col 47
     Btn_send at row 1.2 col 62
     Btn_Ans AT ROW 1.2 COL 32 WIDGET-ID 10
     Btn_lkp AT ROW 1.2 COL 17 WIDGET-ID 12
     Btn_Sel AT ROW 1.2 COL 17
     Btn_Edit AT ROW 1.2 COL 52
     RADIO-SET-1 AT ROW 1.2 COL 80 NO-LABEL WIDGET-ID 2
     f-date AT ROW 2.5 COL 8.63 COLON-ALIGNED WIDGET-ID 22
     f-date-2 AT ROW 2.5 COL 22.75 COLON-ALIGNED WIDGET-ID 26
     SPACE(2) SKIP(22.2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акты о списании товаров из торгового зала ЕГАИС"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
    delete object egais no-error .
  apply "END-ERROR":U to self.
end.
ON CHOOSE OF Btn_lkp IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    run bge/egais-act-writeOff_shop.w (parparentproc, 'ПРОСМОТР':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
END.
ON CHOOSE OF Btn_Edit IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-awo_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    entry(4, buf_clob-bind.descr, chr(4)) = string(no) no-error .
    entry(5, buf_clob-bind.descr, chr(4)) = "" no-error .
    entry(6, buf_clob-bind.descr, chr(4)) = "" no-error .
    bh-act-header:buffer-field ("is-sent"):buffer-value = string(no) no-error .
    bh-act-header:buffer-field ("answer_"):buffer-value = "" no-error .
    bh-act-header:buffer-field ("RegID"):buffer-value = "" no-error .
    find first ub.esys-all-attr
                where ub.esys-all-attr.table-name = "esys-pck-sent"
                and ub.esys-all-attr.attr-code = "egais"
                and ub.esys-all-attr.key2       = 4
                and ub.esys-all-attr.attr-value = buf_clob-bind.uniq-key-rec
                no-error.
    if available (ub.esys-all-attr )
    then do:
      delete ub.esys-all-attr .
    end.
    run refresh-query .
END.
ON CHOOSE OF Btn_Sel IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    assign p-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
    if p-RegID = "" or p-RegID = ? or num-entries(p-RegID, CHR(5)) <> 2 then do :
        message "Данный акт либо относится к старой версии ЕГАИС, либо по нему ещё не получен ответ (в этом случае нажмите кнопку 'Посмотреть ответ')." view-as alert-box .
        p-RegID = "" .
        return no-apply .
    end.
    if entry(2, p-RegID, CHR(5)) = "R" then do :
        message "Данный акт о списании был отклонён ЕГАИС. Чтобы узнать причину нажмите кнопку 'Посмотреть ответ'" view-as alert-box .
        p-RegID = "" .
        return no-apply .
    end.
    assign p-RegID = entry(1, p-RegID, CHR(5)) .
END.
ON CHOOSE OF Btn_create IN FRAME Dialog-Frame
DO:
    run bge/egais-act-writeOff_shop.w (parparentproc, 'ДОБАВЛЕНИЕ':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
    run refresh-query.
END.
ON CHOOSE OF Btn_chg IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    v-act-num = bh-act-header:buffer-field ("num"):buffer-value .
    run bge/egais-act-writeOff_shop.w (parparentproc, 'ИЗМЕНЕНИЕ':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
    run refresh-query.
END.
ON CHOOSE OF Btn_del IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-awo_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    delete buf_clob-bind .
    bh-act-header:buffer-delete () .
    run refresh-query.
END.
ON CHOOSE OF Btn_send IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-awo_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    os-delete "temp-ActWriteOff_shop.xml".
    copy-lob
    from  object buf_clob-data.cdata
    to  file 'temp-ActWriteOff_shop.xml'
    no-convert
    no-error .
    run parseXML in this-procedure (input "temp-ActWriteOff_shop.xml") .
    find first tt-act-header .
    v-file = 'ActWriteOff_Shop.xml' .
    os-delete "ActWriteOff_Shop.xml" .
    run makeXMLegais_v2 .
    egais:inNum = tt-act-header.num .
    egais:SendRequestUTM() .
    glog = egais:IsSent .
    glog = egais:StatusErr .
    if glog then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    else do :
        entry (4, buf_clob-bind.descr, chr(4)) = "yes".
        bh-act-header:buffer-field ("is-sent"):buffer-value = true.
    end.
    run refresh-query.
    message "Акт " egais:inNum " отправлен" view-as alert-box .
END.
ON CHOOSE OF Btn_Ans IN FRAME Dialog-Frame
DO:
  if not bh-act-header:available
    then return no-apply.
    v-act-num = bh-act-header:buffer-field ("num"):buffer-value .
      egais:inNum = bh-act-header:buffer-field ("num"):buffer-value .
      egais:GetHndlTable(2, bh-act-header:buffer-field ("num"):buffer-value) .
      glog = egais:StatusErr .
      if glog
      and (bh-act-header:buffer-field ("answer_"):buffer-value = ""
        or bh-act-header:buffer-field ("answer_"):buffer-value = ? )
      then do :
            message egais:Msg view-as alert-box.
            return no-apply.
      end.
      else message (bh-act-header:buffer-field ("answer_"):buffer-value) view-as alert-box information .
  run refresh-query.
END.
ON value-changed OF RADIO-SET-1 IN FRAME Dialog-Frame
do:
  assign RADIO-SET-1 .
  if RADIO-SET-1 = 1
  then do :
    ENABLE Btn_create Btn_chg Btn_del Btn_send
      WITH FRAME Dialog-Frame.
    HIDE Btn_Ans Btn_lkp Btn_Edit in FRAME Dialog-Frame.
  end.
  else do :
    ENABLE Btn_Ans Btn_lkp Btn_Edit
      WITH FRAME Dialog-Frame.
    HIDE Btn_create Btn_chg Btn_del Btn_send in FRAME Dialog-Frame.
  end.
  run refresh-query.
end.
ON leave OF f-date IN FRAME Dialog-Frame
do:
  run refresh-query.
end.
ON return OF f-date IN FRAME Dialog-Frame
do:
  run refresh-query.
end.
ON leave OF f-date-2 IN FRAME Dialog-Frame
do:
  run refresh-query.
end.
ON return OF f-date-2 IN FRAME Dialog-Frame
do:
  run refresh-query.
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-db-num
  ,output v-user-id
  ) no-error .
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'egais':U
      ,input 'egais-fsrar':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign
    v-fs-rar = v-value-character
  .
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input 'egais':U
      ,input 'egais-exsys':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .
  egais = new ActWriteOff_Shop (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  egais:DbNum = v-db-num .
  egais:User_Id = v-user-id .
  bh-act-header = egais:GetHndlTable(3, "").
  create query qh-act-header.
  f-date = date (now) - 31.
  f-date-2 = ?.
  run refresh-query.
  create browse browse-hdl-act-header
    assign
      title     = 'Акты о списании товара из торгового зала ЕГАИС'
      frame     = frame Dialog-Frame:handle
      query     = qh-act-header
      x         = 10
      y         = 60
      width     = 104
      height    = 22
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
      end triggers
  .
  on row-display of browse-hdl-act-header do :
      if valid-handle (calc-col-hndl) then do :
          if RADIO-SET-1 = 1 then calc-col-hndl:SCREEN-VALUE = "Новый" .
          else do :
            assign v-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
            if v-RegID = "" or v-RegID = ? or num-entries(v-RegID, CHR(5)) <> 2 then calc-col-hndl:SCREEN-VALUE = "Отправлен" .
            if num-entries(v-RegID, CHR(5)) = 2 then do :
                if entry(2, v-RegID, CHR(5)) = "R" then do :
                    calc-col-hndl:SCREEN-VALUE = "Отклонен" .
                    calc-col-hndl:bgcolor = red_color .
                end.
                if entry(2, v-RegID, CHR(5)) = "A" then do :
                    calc-col-hndl:SCREEN-VALUE = "Принят" .
                    calc-col-hndl:bgcolor = green_color .
                end.
            end.
          end.
      end.
      if valid-handle (calc-col-hndl2) then do :
          if RADIO-SET-1 = 1 then calc-col-hndl2:SCREEN-VALUE = " - " .
          else do :
            assign v-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
            calc-col-hndl2:SCREEN-VALUE = entry(1, v-RegID, CHR(5)) .
          end.
      end.
  end.
  ON value-changed OF browse-hdl-act-header
  do:
      if calc-col-hndl:SCREEN-VALUE = "Отклонен" then enable Btn_Edit with FRAME Dialog-Frame .
                                                 else disable Btn_Edit with FRAME Dialog-Frame .
  end.
  if not bh-act-header = ?
  then do:
    do ii = 1 to bh-act-header:num-fields - 3:
      bcol[ii] = browse-hdl-act-header:add-like-column('tt-act-header' + '.' + bh-act-header:buffer-field (ii):name, 0, 'FILL-IN').
    end.
    calc-col-hndl = browse-hdl-act-header:add-calc-column("char", "X(10)", "", "Статус") .
    calc-col-hndl2 = browse-hdl-act-header:add-calc-column("char", "X(20)", "", "RegID") .
    browse-hdl-act-header:get-browse-column (1):width-chars = 30.
    browse-hdl-act-header:get-browse-column (2):width-chars = 17.
    browse-hdl-act-header:get-browse-column (3):width-chars = 20.
    browse-hdl-act-header:get-browse-column (4):width-chars = 10.
    browse-hdl-act-header:get-browse-column (5):width-chars = 20.
  end.
  run enable_UI.
  apply "value-changed" to RADIO-SET-1 in frame Dialog-Frame.
  if not p-select then hide Btn_sel in FRAME Dialog-Frame.
  else do :
      hide Btn_create Btn_chg Btn_del Btn_send RADIO-SET-1 Btn_Edit in FRAME Dialog-Frame.
      assign
        Btn_lkp:x = Btn_lkp:x + 120
        Btn_Ans:x = Btn_Ans:x + 120
      .
      ENABLE Btn_Ans Btn_lkp Btn_sel WITH FRAME Dialog-Frame.
  end.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RADIO-SET-1 f-date f-date-2
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK RADIO-SET-1 f-date f-date-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE refresh-query :
def var v-proposition  as char no-undo.
if bh-act-header = ?
  then return .
  assign input frame Dialog-Frame
    f-date
    f-date-2
  .
  v-proposition =
    (if f-date <> ? then " and tt-act-header.date_ >= " + string (f-date) else "") +
    (if f-date-2 <> ? then " and tt-act-header.date_ <= " + string (f-date-2) else "")
    .
if p-select then do :
    qh-act-header:query-close.
    qh-act-header:set-buffers (bh-act-header).
    qh-act-header:query-prepare ( substitute ("for each tt-act-header where tt-act-header.is-sent and tt-act-header.type_ = 'Пересортица' &1 by tt-act-header.date_ descending", v-proposition) ).
    qh-act-header:query-open.
end.
else do :
  case RADIO-SET-1 :
    when 1  then
    do:
      qh-act-header:query-close.
      qh-act-header:set-buffers (bh-act-header).
      qh-act-header:query-prepare ( substitute ("for each tt-act-header where not tt-act-header.is-sent &1 by tt-act-header.date_ descending", v-proposition) ).
      qh-act-header:query-open.
      bh-act-header:find-first ( "where tt-act-header.num = " + "'" + v-act-num + "'" + v-proposition) no-error .
    end.
    when 2  then
    do:
      qh-act-header:query-close.
      qh-act-header:set-buffers (bh-act-header).
      qh-act-header:query-prepare ( substitute ("for each tt-act-header where tt-act-header.is-sent &1 by tt-act-header.date_ descending", v-proposition) ).
      qh-act-header:query-open.
      bh-act-header:find-first ( "where tt-act-header.num = " + "'" + v-act-num + "'" + v-proposition ) no-error .
    end.
  end case.
end.
if bh-act-header:available
  then qh-act-header:reposition-to-rowid ( bh-act-header:rowid ) no-error.
if valid-handle (browse-hdl-act-header) then apply "value-changed" to browse-hdl-act-header.
end.
PROCEDURE proc-row-leave :
  if false then do:
    do ii = 1 to extent (bcol).
      bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
end.
