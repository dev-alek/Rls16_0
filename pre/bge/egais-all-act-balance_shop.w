using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов ЕГАИС".
define variable th-act-header         as handle    no-undo.
define variable bh-act-header         as handle    no-undo.
define variable qh-act-header         as handle    no-undo.
define variable browse-hdl-act-header as handle    no-undo.
define variable bcol                as handle    extent 11 no-undo.
define variable calc-col-hndl       as handle    no-undo .
define variable calc-col-hndl2      as handle    no-undo .
define variable egais               as class     ActBalance_shop no-undo.
define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .
define variable qh-ab-gds-EG-header as handle    no-undo.
define variable qh-ab-gds-EG        as handle    no-undo.
define variable bh-ab-gds-EG-header as handle    no-undo.
define variable bh-ab-gds-EG        as handle    no-undo.
define variable v-RegID             as character no-undo .
define variable glog        as logical no-undo .
define variable v-act-num as character no-undo .
define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .
define buffer buf_clob-bind     for ub.clob-bind .
define buffer buf_clob-data     for ub.clob-data .
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
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
.
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
         Btn_Edit AT ROW 1.2 COL 52
     RADIO-SET-1 AT ROW 1.2 COL 80 NO-LABEL WIDGET-ID 2
     f-date AT ROW 2.5 COL 8.63 COLON-ALIGNED WIDGET-ID 22
     f-date-2 AT ROW 2.5 COL 22.75 COLON-ALIGNED WIDGET-ID 26
     SPACE(2) SKIP(22.2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акты постановки на баланс в торговом зале в ЕГАИС"
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
    run bge/egais-act-balance_shop.w (parparentproc, 'ПРОСМОТР':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
END.
ON CHOOSE OF Btn_Edit IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-ab_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    entry(3, buf_clob-bind.descr, chr(4)) = string(no) no-error .
    entry(4, buf_clob-bind.descr, chr(4)) = "" no-error .
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
ON CHOOSE OF Btn_create IN FRAME Dialog-Frame
DO:
    run bge/egais-act-balance_shop.w (parparentproc, 'ДОБАВЛЕНИЕ':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
    run refresh-query.
END.
ON CHOOSE OF Btn_chg IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    v-act-num = bh-act-header:buffer-field ("num"):buffer-value .
    run bge/egais-act-balance_shop.w (parparentproc, 'ИЗМЕНЕНИЕ':U, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
        run refresh-query.
END.
ON CHOOSE OF Btn_del IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-ab_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    delete buf_clob-bind .
    bh-act-header:buffer-delete () .
    run refresh-query.
END.
ON CHOOSE OF Btn_send IN FRAME Dialog-Frame
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = 'egais-ab_shop':U and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    os-delete "ActChargeOnShop_v2.xml".
    copy-lob
    from  object buf_clob-data.cdata
    to  file 'ActChargeOnShop_v2.xml'
    no-convert
    no-error .
    egais:inNum = bh-act-header:buffer-field ("num"):buffer-value .
    egais:SendRequestUTM() .
    glog = egais:IsSent .
    glog = egais:StatusErr .
    if glog then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    else do :
        entry (3, buf_clob-bind.descr, chr(4)) = "yes".
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
  def var ii as int no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  egais = new ActBalance_shop (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  egais:DbNum = v-db-num .
  egais:User_Id = v-user-id .
  bh-act-header = egais:GetHndlTable(3, "").
  create query qh-act-header.
  f-date = date (now) - 31.
  f-date-2 = ?.
  run refresh-query.
  create browse browse-hdl-act-header
    assign
      title     = 'Акты постановки на баланс в торговом зале ЕГАИС'
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
    do ii = 1 to bh-act-header:num-fields - 4:
      bcol[ii] = browse-hdl-act-header:add-like-column('tt-act-header' + '.' + bh-act-header:buffer-field (ii):name, 0, 'FILL-IN').
    end.
        bcol[3] = browse-hdl-act-header:add-like-column('tt-act-header.type_', 0, 'FILL-IN').
        calc-col-hndl = browse-hdl-act-header:add-calc-column("char", "X(10)", "", "Статус") .
        calc-col-hndl2 = browse-hdl-act-header:add-calc-column("char", "X(20)", "", "RegID") .
    browse-hdl-act-header:get-browse-column (1):width-chars = 26.
    browse-hdl-act-header:get-browse-column (2):width-chars = 10.
    browse-hdl-act-header:get-browse-column (3):width-chars = 34.
    browse-hdl-act-header:get-browse-column (4):width-chars = 10.
    browse-hdl-act-header:get-browse-column (5):width-chars = 17.
  end.
  run enable_UI.
  RADIO-SET-1 = 2 .
  apply "value-changed" to RADIO-SET-1 in frame Dialog-Frame.
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
