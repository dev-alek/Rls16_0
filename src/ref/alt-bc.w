&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-bar-code-attr NO-UNDO LIKE ub.bar-code-obj-attr
       field user-can-edit as logical
       field unit-cli like ub.bar-code.unit-cli
       field cli-base-rate like ub.bar-code.cli-base-rate
       field attr-label as character
       index pi is unique primary
       b-code
       attr-code
       obj-type
       obj-code
       index iattrc
       attr-code
       index iattrv
       attr-value.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_gds-prt FOR ub.gds-prt.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_prod-bc FOR ub.prod-bc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Бар-коды и ДопБК для товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter base-bc like ub.bar-code.b-code no-undo. /* основной код */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Бар-коды и ДопБК для товара".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ cmp/lcssshbl.i }
{ nws/db-rec.i }
{ gbl/key-rec.i }
{ gbl/getcntxt.i def }
{ gbl/get-regf.i }
{ ref/bc-oattr.i  interface parparentproc }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }

define variable rid as recid no-undo.
define variable add-option as character no-undo .
define variable attr-mode as character no-undo init "b-code".
define variable temp-doc-rec as recid no-undo.
define variable v-start as logical no-undo init yes.

define buffer base-bar-code for ub.bar-code.
define buffer lb-goods for ub.goods .
define buffer lb-gds-prt for ub.gds-prt .
define buffer lb-bar-code for ub.bar-code .
define buffer base_units for ub.units.

DEFINE MENU MENU-b-add-attr.
{ ref/send-ref.i }


FUNCTION stts-string RETURNS CHARACTER
  ( p-stts_ as integer):
define variable dops as character no-undo.
&scop hn-action-code string(p-stts_)
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */

END FUNCTION.

FUNCTION get-cr-db-num RETURNS INTEGER
  ( input p-b-code AS INTEGER, INPUT p-cr-db-num AS INTEGER):
  DEFINE BUFFER buf_code-range FOR ub.code-range.
  IF p-cr-db-num <> ? THEN
  RETURN p-cr-db-num.   /* Function return value. */
  FIND FIRST buf_code-range NO-LOCK WHERE
            buf_code-range.first-code <= p-b-code
       AND  buf_code-range.last-code >= p-b-code NO-ERROR.
  IF AVAILABLE buf_code-range THEN RETURN buf_code-range.db-num.
  RETURN ?.

END FUNCTION.

FUNCTION IS-GLOBAL returns logical ( buffer buf_prod-bc for ub.prod-bc):
define variable v-is-global as logical no-undo .
 { gbl/prodbcat.i
   buf_prod-bc
   "'global=request'"
   v-is-global
   no-error
   }
if error-status:error then return ?.
return v-is-global.
end function.
FUNCTION IS-NeedMark returns logical ( buffer buf_prod-bc for ub.prod-bc):
    DEFINE BUFFER buf_prod-bc-attr FOR ub.prod-bc-attr.
find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq buf_prod-bc.b-code
                              and buf_prod-bc-attr.b-str eq buf_prod-bc.b-str 
                              and buf_prod-bc-attr.attr-code eq {&mark}
  no-lock no-error. 
return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-bc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_bar-code temp-bar-code-attr X_prod-bc

/* Definitions for BROWSE br-bc                                         */
&Scoped-define FIELDS-IN-QUERY-br-bc X_bar-code.b-code X_bar-code.unit-cli X_bar-code.cli-base-rate stts-string(X_bar-code.stts_) get-cr-db-num(X_bar-code.b-code, X_bar-code.cr-db-num)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-bc
&Scoped-define SELF-NAME br-bc
&Scoped-define QUERY-STRING-br-bc FOR EACH X_bar-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-bc OPEN QUERY {&SELF-NAME} FOR EACH X_bar-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-bc X_bar-code
&Scoped-define FIRST-TABLE-IN-QUERY-br-bc X_bar-code


/* Definitions for BROWSE br-bc-attr                                    */
&Scoped-define FIELDS-IN-QUERY-br-bc-attr temp-bar-code-attr.b-code temp-bar-code-attr.unit-cli temp-bar-code-attr.cli-base-rate temp-bar-code-attr.attr-label temp-bar-code-attr.attr-value get-objregion(temp-bar-code-attr.obj-type, temp-bar-code-attr.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-bc-attr
&Scoped-define SELF-NAME br-bc-attr
&Scoped-define QUERY-STRING-br-bc-attr FOR EACH temp-bar-code-attr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-bc-attr OPEN QUERY {&SELF-NAME} FOR EACH temp-bar-code-attr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-bc-attr temp-bar-code-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-bc-attr temp-bar-code-attr


/* Definitions for BROWSE BR-pbc                                        */
&Scoped-define FIELDS-IN-QUERY-BR-pbc X_prod-bc.bc-on X_prod-bc.b-str X_prod-bc.cr-db-num X_prod-bc.bc-on-type eq {&gtin} or is-global(buffer X_prod-bc) if X_prod-bc.bc-on-type eq {&gtin} then {&gtin} else "" IS-NeedMark (buffer X_prod-bc)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pbc X_prod-bc.b-str   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pbc X_prod-bc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pbc X_prod-bc
&Scoped-define SELF-NAME BR-pbc
&Scoped-define QUERY-STRING-BR-pbc FOR EACH X_prod-bc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-pbc OPEN QUERY {&SELF-NAME} FOR EACH X_prod-bc NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-pbc X_prod-bc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pbc X_prod-bc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-bc}~
    ~{&OPEN-QUERY-br-bc-attr}~
    ~{&OPEN-QUERY-BR-pbc}
    
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_goods.artic X_goods.gds-name ~
X_prod-bc.b-str
&Scoped-define ENABLED-TABLES X_goods X_prod-bc
&Scoped-define FIRST-ENABLED-TABLE X_goods
&Scoped-define SECOND-ENABLED-TABLE X_prod-bc
&Scoped-Define ENABLED-OBJECTS b-quit B-Help b-chg-1 b-add b-chg b-del ~
b-print-2 b-hist-0 b-on b-dpl b-add-1 b-del-1 b-gtin-1 b-print-1 b-hist-2 ~
br-bc BR-pbc Rs-attr-mode b-add-attr b-chg-attr b-del-attr br-bc-attr 
&Scoped-Define DISPLAYED-FIELDS X_goods.artic X_goods.gds-name ~
X_prod-bc.b-str
&Scoped-define DISPLAYED-TABLES X_goods X_prod-bc
&Scoped-define FIRST-DISPLAYED-TABLE X_goods
&Scoped-define SECOND-DISPLAYED-TABLE X_prod-bc
&Scoped-Define DISPLAYED-OBJECTS Rs-attr-mode

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-add-1 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-add-attr 
     LABEL "Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg-1 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg-attr
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del-1
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del-attr
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-dpl
     LABEL "&Повтор"
     SIZE 10 BY 1.

DEFINE BUTTON b-gtin-1 
     LABEL "&GTIN" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist-0
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-hist-2
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-on
     LABEL "&Вкл"
     SIZE 10 BY 1.

DEFINE BUTTON b-print-1
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-print-2
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE Rs-attr-mode AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Бар-код", "1",
"Все бар-коды", "2"
     SIZE 24 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-bc FOR
      X_bar-code SCROLLING.

DEFINE QUERY br-bc-attr FOR
      temp-bar-code-attr SCROLLING.

DEFINE QUERY BR-pbc FOR
      X_prod-bc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-bc Dialog-Frame _FREEFORM
  QUERY br-bc NO-LOCK DISPLAY
      X_bar-code.b-code FORMAT "9999999999":U
      X_bar-code.unit-cli COLUMN-LABEL "Изм."
      X_bar-code.cli-base-rate COLUMN-LABEL "Коэф." FORMAT ">,>>9.<<<"
      stts-string(X_bar-code.stts_) COLUMN-LABEL "Статус" FORMAT "X(6)"
      get-cr-db-num(X_bar-code.b-code, X_bar-code.cr-db-num)  FORMAT ">>>>9" column-label "Соз.(БД)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39 BY 14.24
         TITLE "Собственные" FIT-LAST-COLUMN.

DEFINE BROWSE br-bc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-bc-attr Dialog-Frame _FREEFORM
  QUERY br-bc-attr NO-LOCK DISPLAY
      temp-bar-code-attr.b-code
    temp-bar-code-attr.unit-cli COLUMN-LABEL "Изм."
    temp-bar-code-attr.cli-base-rate COLUMN-LABEL "Коэф." FORMAT ">,>>9.<<<"
    temp-bar-code-attr.attr-label COlUMN-LABEL "Атрибут"  format "X(255)" width 35
    temp-bar-code-attr.attr-value COlUMN-LABEL "Значение" format "X(255)" width 30
    get-objregion(temp-bar-code-attr.obj-type, temp-bar-code-attr.obj-code)  COlUMN-LABEL "Действует"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.27 FIT-LAST-COLUMN.

DEFINE BROWSE BR-pbc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pbc Dialog-Frame _FREEFORM
  QUERY BR-pbc NO-LOCK DISPLAY
      X_prod-bc.bc-on FORMAT "+/"
X_prod-bc.b-str FORMAT "X(25)":U
X_prod-bc.cr-db-num FORMAT ">>>>9" column-label "Соз.(БД)"
X_prod-bc.bc-on-type eq {&gtin} or is-global(buffer X_prod-bc)  FORMAT "+/-" column-label "Глоб"
if X_prod-bc.bc-on-type eq {&gtin} then {&gtin} else  "" FORMAT "X(5)":U column-label "Тип"
IS-NeedMark (buffer X_prod-bc) FORMAT "+/" column-label "Требует!маркировку"
ENABLE
X_prod-bc.b-str
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60.6 BY 14.24
         TITLE "Дополнительные" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 95
     X_goods.artic AT ROW 2 COL 1 NO-LABEL WIDGET-ID 34 FORMAT "X(16)"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          BGCOLOR 8 FGCOLOR 4
     X_goods.gds-name AT ROW 3 COL 1 NO-LABEL WIDGET-ID 36 FORMAT "X(48)"
          VIEW-AS FILL-IN 
          SIZE 54.25 BY 1
          BGCOLOR 8 FGCOLOR 4 
     b-chg-1 AT ROW 3 COL 81 WIDGET-ID 42
     b-add AT ROW 4 COL 1 WIDGET-ID 2
     b-chg AT ROW 4 COL 11 WIDGET-ID 4
     b-del AT ROW 4 COL 21 WIDGET-ID 6
     b-print-2 AT ROW 4 COL 34 WIDGET-ID 12
     b-hist-0 AT ROW 4 COL 37 WIDGET-ID 14
     b-on AT ROW 4 COL 41 WIDGET-ID 20
     b-dpl AT ROW 4 COL 51 WIDGET-ID 22
     b-add-1 AT ROW 4 COL 61 WIDGET-ID 8
     b-del-1 AT ROW 4 COL 71 WIDGET-ID 10
     b-gtin-1 AT ROW 4 COL 81 WIDGET-ID 40
     b-print-1 AT ROW 4 COL 93 WIDGET-ID 16
     b-hist-2 AT ROW 4 COL 96 WIDGET-ID 18
     br-bc AT ROW 5 COL 1 WIDGET-ID 100
     BR-pbc AT ROW 5 COL 40 WIDGET-ID 200
     Rs-attr-mode AT ROW 14 COL 5 NO-LABEL WIDGET-ID 30
     b-add-attr AT ROW 14 COL 51 WIDGET-ID 24
     b-chg-attr AT ROW 14 COL 61 WIDGET-ID 26
     b-del-attr AT ROW 14 COL 71 WIDGET-ID 28
     br-bc-attr AT ROW 15 COL 1 WIDGET-ID 300
     X_prod-bc.b-str AT ROW 22 COL 1 NO-LABEL WIDGET-ID 38 FORMAT "X(40)"
          VIEW-AS FILL-IN 
          SIZE 66.6 BY 1
          BGCOLOR 8 FGCOLOR 4 
     SPACE(32.97) SKIP(0.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-bar-code-attr T "?" NO-UNDO ub bar-code-obj-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as logical
          field unit-cli like ub.bar-code.unit-cli
          field cli-base-rate like ub.bar-code.cli-base-rate
          field attr-label as character
          index pi is unique primary
          b-code
          attr-code
          obj-type
          obj-code
          index iattrc
          attr-code
          index iattrv
          attr-value
      END-FIELDS.
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_gds-prt B "?" ? ub gds-prt
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_prod-bc B "?" ? ub prod-bc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-bc b-hist-2 Dialog-Frame */
/* BROWSE-TAB BR-pbc br-bc Dialog-Frame */
/* BROWSE-TAB br-bc-attr b-del-attr Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN X_goods.artic IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN X_prod-bc.b-str IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN X_goods.gds-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-bc
/* Query rebuild information for BROWSE br-bc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_bar-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-bc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-bc-attr
/* Query rebuild information for BROWSE br-bc-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-bar-code-attr NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-bc-attr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pbc
/* Query rebuild information for BROWSE BR-pbc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_prod-bc NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-pbc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable glog as logical no-undo .
DEFINE BUFFER buf_units FOR ub.units.

   /* эта проверка просто дублирует аналогичную в форме - для удобства */
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    X_goods.grp-code
    0
    true
    glog
    }
  if glog then do :
    find buf_units where
        buf_units.unit-name = X_goods.unit-base no-lock.
    if lookup ({&petrolium}, buf_units.type) > 0 and
      lookup ({&divisional}, buf_units.type) > 0 AND
      X_goods.gds-type = {&gds-goods} then do:
      message "Нельзя добавить собственный код для топлива."
              view-as alert-box error.
      return no-apply.
    end.
    run ref/bc-form.w
      (input parparentproc
      ,input {&add-def}
      ,input base-bc
      ,input-output rid
      ).
    run Ui-on IN THIS-PROCEDURE.
    if rid = ? then
      return no-apply.
    apply "entry" to br-bc in frame {&frame-name}.
    reposition br-bc to recid rid no-error.
    apply "value-changed" to browse br-bc.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-1 Dialog-Frame
ON CHOOSE OF b-add-1 IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE case-num as integer no-undo .
  DEFINE VARIABLE vattr-codes as character no-undo .
  DEFINE VARIABLE vattr-labels as character no-undo .
  DEFINE VARIABLE voutput as character no-undo .
  DEFINE VARIABLE is-ean as logical no-undo init yes.
  DEFINE VARIABLE v-on as logical no-undo .
  DEFINE VARIABLE v-b-str like ub.prod-bc.b-str no-undo .
  define variable glog as logical no-undo .
  define variable glog2 as logical no-undo .
  define variable glog3 as logical no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .
  define variable unq-artc as logical no-undo .
  define variable v-cdrg-type as character no-undo .
  define variable v-main-b-code as integer no-undo .
  define variable v-rid as recid no-undo .
  define variable v-param-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  define buffer buf_code-range for ub.code-range.
  define buffer buf2_code-range for ub.code-range.
  define buffer goods_units for ub.units.
  DEFINE BUFFER buf_units FOR ub.units.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .

  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  X_goods.grp-code
  0
  true
  glog
  }
  if not glog then return no-apply.
  /*проверим не является ли этот товар весовым ? */
  find first buf_units no-lock where
             buf_units.unit-name = X_bar-code.unit-cli No-ERROR.
  if not avail buf_units then return no-apply.
  find first goods_units no-lock where
             goods_units.unit-name = X_goods.unit-base No-ERROR.
  if not avail goods_units then return no-apply.
  if lookup({&weight}, buf_units.type) > 0 then do:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_gbl-sc-code':U
    {&cntxt-global}
    0
    '':U
    0
    0
    X_goods.grp-code
    0
    true
    glog
    }

    if not glog then case-num = 2.
    else do:
      run gbl/d-askw.w
      (input "Создание дополнительного кода" /* Заголовок окна */
      ,input "Вы действительно хотите создать дополнительный код?" + {&new-line} /* Общее сообщение */
        + "(для весового товара здесь можно ввести только ГЛОБАЛЬНЫЙ ВЕСОВОЙ КОД)" + {&new-line}
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "Глоб.вес. код|Отказ" /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input "Весовой код, который будет передан по СПН во все БД - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
          + "Отказ от выполнения операции"
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output case-num /* выбор пользователя */
      ).
      if case-num = 2 then return no-apply.
      if case-num = 1 then do:
        v-rid = ?.
        run trg/prod-bc1.p ( input parparentproc
                            ,input no /*p-silent*/
                            ,input ? /* dif-pdbc */
                            ,input ? /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input {&gbl-sc-code}
                            ,input "" /*p-ean-type*/
                            ,buffer X_goods
                            ,input X_bar-code.b-code
                            ,input-output v-b-str /*p-b-str*/
                            ,output v-rid
                            ) no-error.
        if error-status :error
        or v-rid = ?
        then do:
          undo, return no-apply.
        end.
        else do:
          apply "entry" to br-pbc in frame {&frame-name}.
          apply "value-changed" to br-bc.
          return no-apply.
        end. /*удалось создать код*/
      end. /*case-num = 1*/
    end. /*case-num <> 2*/
  end. /*товар весовой*/
  { gbl/gdsbcode.i X_goods.gds-code ? v-main-b-code }
  if lookup({&pieces}, goods_units.type) > 0
  and buf_units.type = {&pieces}
  and X_bar-code.b-code = v-main-b-code
  then do:
    find first buf_code-range no-lock where
              buf_code-range.range-type = {&loc-pg-code}
          and buf_code-range.db-num = 0  no-error.
    if available buf_code-range then do:
      /*предполагается что штучный */
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_alt-barcode_loc-pg-code':U
      {&cntxt-global}
      0
      '':U
      0
      0
      X_goods.grp-code
      0
      true
      glog3
      }
    end.
    if glog3 then do:
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.

      run adm/shattri.p (
            input "get":U
          ,input  '':U
          ,input  0
          ,input  {&attr-gds-ref}
          ,input  "":U /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .

      IF error-status:error then do:
        delete object v-tth.
        message
        substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
        view-as alert-box error .
        undo, return no-apply .
      end.
      for each thbjattr_thbj-attr  where
              thbjattr_thbj-attr.obj-type = '':U
          and thbjattr_thbj-attr.obj-code = 0
          and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
      :
        case thbjattr_thbj-attr.prop-code:
          when {&attr-gds-ref_unq-artc} then do :
            unq-artc = thbjattr_thbj-attr.property-value-logical.
          end.
        end case.
      end.
      if unq-artc then do:
        message
        substitute("В Вашей конфигурации диапазон штучных кодов для весов&1" +
                    "уже используется несовместимым образом,&1"  +
                    "поэтому ввод таких кодов ЗАПРЕЩЕН!"
                    , {&new-line})
        view-as alert-box error .
        undo, return no-apply.
      end.
      run gbl/d-askw.w
      (input "Создание дополнительного кода" /* Заголовок окна */
      ,input substitute("Вы действительно хотите создать дополнительный код?&1" + /* Общее сообщение */
                        "(для штучного товара здесь можно ввести обычный Доп. БК&1" +
                        "или ЛОКАЛЬНЫЙ ШТУЧНЫЙ КОД ДЛЯ ВЕСОВ)", {&new-line})
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input substitute("Обычный Доп.БК|Лок.штучный|Отказ"
                        )
                        /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input ("Обычный Доп.БК производителя товара|" /* список описаний кнопок */
          +  "Локальный Код, по которому для товара будет печататься на весах этикетка с указанием количества - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
          + "Отказ от выполнения операции")
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 3 /* значение возвращаемое при нажатии escape */
      ,output case-num /* выбор пользователя */
      ).
      if case-num = 3 then return no-apply.
      if case-num = 2 then do:
        v-rid = ?.
        run trg/prod-bc1.p ( input parparentproc
                            ,input no /*p-silent*/
                            ,input ? /* dif-pdbc */
                            ,input ? /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input {&loc-pg-code}
                            ,input "" /*p-ean-type*/
                            ,buffer X_goods
                            ,input X_bar-code.b-code
                            ,input-output v-b-str /*p-b-str*/
                            ,output v-rid
                            ) no-error.
        if error-status :error
        or v-rid = ?
        then do:
          undo, return no-apply.
        end.
        else do:
          apply "entry" to br-pbc in frame {&frame-name}.
          apply "value-changed" to br-bc.
          return no-apply.
        end. /*удалось создать код*/
      end. /*case-num = 2*/
    end. /*if glog3*/
  end. /*if buf_units.type = {&pieces} then do:*/
  if lookup({&weight}, goods_units.type) > 0 and buf_units.type = {&divisional} then do:
    /*предполагается что взвешиваемый */
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_loc-ss-code':U
    {&cntxt-global}
    0
    '':U
    0
    0
    X_goods.grp-code
    0
    true
    glog
    }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_gbl-ss-code':U
    {&cntxt-global}
    0
    '':U
    0
    0
    X_goods.grp-code
    0
    true
    glog2
    }
    if not glog and not glog2 then case-num = 3.
    else do:
      run gbl/d-askw.w
      (input "Создание дополнительного кода" /* Заголовок окна */
      ,input "Вы действительно хотите создать дополнительный код?" + {&new-line} /* Общее сообщение */
        + "(для весового товара здесь можно ввести только ЛОКАЛЬНЫЙ ИЛИ ГЛОБАЛЬНЫЙ КОД ВЗВЕШИВАЕМОГО ТОВАРА)" + {&new-line}

      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input substitute("Лок.взвеш. код&1|Глоб.взвеш.код&2|Отказ"
                      , (if glog then "" else "^disable")
                      , (if glog2 then "" else "^disable")
                         )
                        /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input ("Локальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
          +  "Глобальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
          + "Отказ от выполнения операции")
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 3 /* значение возвращаемое при нажатии escape */
      ,output case-num /* выбор пользователя */
      ).
    end.
    if case-num = 3 then return no-apply.
    if case-num = 1
    or case-num = 2
    then do:
      /*вывести перечень всех дипазонов*/
      if case-num = 1 then v-cdrg-type = {&loc-ss-code}.
      if case-num = 2 then v-cdrg-type = {&gbl-ss-code}.
      FOR EACH buf2_code-range No-LOCK WHERE
          buf2_code-range.range-type = (if case-num = 1 then {&loc-ss-code} else {&gbl-ss-code})
      and buf2_code-range.db-num = (if case-num = 1 then 0 else v-cntxt-db-num):
        assign
        vattr-labels = vattr-labels +
                      (if vattr-labels = "":U
                        then "":U
                        else {&comma-char}) +
                        string(buf2_code-range.first-code, "999999999") + "-":U + string(buf2_code-range.last-code, "999999999") +
                        fill({&space-char}, 5) + "----->":U +
                        fill({&space-char}, 5) +
                        MakeShbl(buf2_code-range.first-code , buf2_code-range.last-code)
        vattr-codes =  vattr-codes +
                      (if vattr-codes = "":U
                        then "":U
                        else {&comma-char}) +
                        {&space-char} +
                        MakeShbl(buf2_code-range.first-code , buf2_code-range.last-code)
        .
      end.
      run gbl/d-list.w (
                    INPUT "b-sel":U
                   ,INPUT (if case-num = 1
                            then "Диапазоны и шаблоны локальных взвешиваемых кодов"
                            else "Диапазоны и шаблоны глобальных взвешиваемых кодов")
                   ,INPUT vattr-codes
                   ,INPUT vattr-labels
                   ,INPUT {&comma-char}
                   ,INPUT "":U
                   ,output voutput).
      IF voutput = "":u THEN RETURN NO-APPLY.
      is-ean = no.
    end.
  end. /*if lookup({&weight}, goods_units.type) > 0 and buf_units.type = {&divisional)) */
  if lookup({&petrolium}, goods_units.type) > 0
  and lookup({&divisional}, goods_units.type) > 0  then do:
    is-ean = no.
    v-cdrg-type = {&loc-pt-code}.
  end.
  run ref/pbc-form.w
    (input parparentproc
    ,input {&add-def}
    ,input X_bar-code.b-code
    ,input trim(voutput)
    ,input is-ean
    ,input v-cdrg-type
    ,input-output rid
    ).
  if rid = ? then
    return no-apply.
  apply "entry" to br-pbc in frame {&frame-name}.
  apply "value-changed" to br-bc.
  reposition br-pbc to recid rid no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-attr Dialog-Frame
ON CHOOSE OF b-add-attr IN FRAME Dialog-Frame /* Добавить */
DO:
  if attr-mode = {&all} then return no-apply.
  run proc-add-attr in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available X_bar-code then
  return no-apply.
if X_bar-code.unit-cli = X_goods.unit-base then do:
  message "Нельзя изменить основной код (собственный код с базовой единицей измерения)."
          view-as alert-box error.
  return no-apply.
end.
rid = recid (X_bar-code).
run ref/bc-form.w
  (input parparentproc
  ,input {&update}
  ,input base-bc
  ,input-output rid
  ).
display X_bar-code.cli-base-rate with browse br-bc.
apply "entry" to br-bc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-1 Dialog-Frame
ON CHOOSE OF b-chg-1 IN FRAME Dialog-Frame /* Изменить */
DO:

  DEFINE VARIABLE case-num as integer no-undo .
  DEFINE VARIABLE vattr-codes as character no-undo .
  DEFINE VARIABLE vattr-labels as character no-undo .
  DEFINE VARIABLE voutput as character no-undo .
  DEFINE VARIABLE is-ean as logical no-undo init yes.
  DEFINE VARIABLE v-on as logical no-undo .
  DEFINE VARIABLE v-b-str like ub.prod-bc.b-str no-undo .
  define variable glog as logical no-undo .
  define variable glog2 as logical no-undo .
  define variable glog3 as logical no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .
  define variable unq-artc as logical no-undo .
  define variable v-cdrg-type as character no-undo .
  define variable v-main-b-code as integer no-undo .
  define variable X_rid as recid no-undo .
  define buffer buf_code-range for ub.code-range.
  define buffer buf2_code-range for ub.code-range.
  define buffer goods_units for ub.units.
  DEFINE BUFFER buf_units FOR ub.units.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if not glog then return no-apply.
  if available (X_prod-bc) then do:   
     if X_prod-bc.bc-on-type = {&GTIN} then 
     do:
        message "Бар-код с типом GTIN изменить нельзя"
           view-as alert-box.
        return no-apply .
     end.   
  { gbl/gdsbcode.i X_goods.gds-code ? v-main-b-code }
  run ref/pbc-form.w
    (input parparentproc
    ,input {&update}
    ,input X_prod-bc.b-code
    ,input X_prod-bc.b-str
    ,input is-ean
    ,input v-cdrg-type
    ,input-output rid
    ).
  if rid = ? then
    return no-apply.
  find first ub.prod-bc where recid (ub.prod-bc) = rid .
  find first X_prod-bc where X_prod-bc.b-code = ub.prod-bc.b-code and X_prod-bc.b-str = ub.prod-bc.b-str no-error . 
  X_rid = recid (X_prod-bc) .
    
  apply "entry" to br-pbc in frame {&frame-name}.
  apply "value-changed" to br-bc.
  BR-pbc:refresh () .
  reposition br-pbc to recid X_rid no-error.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-attr Dialog-Frame
ON CHOOSE OF b-chg-attr IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-bar-code-attr then return no-apply.
  run proc-attr-add-chg in this-procedure ( input no
                                      ,input temp-bar-code-attr.obj-type
                                      ,input temp-bar-code-attr.obj-code
                                     ) no-error.
  if error-status:error then return no-apply.
  RUN init-attr-proc in this-procedure .
  run openbr-bc-attr in this-procedure ( input attr-mode) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable v-key-rec as character no-undo .
define variable v-param          as character no-undo .
define variable glog as logical no-undo .
DEFINE BUFFER LOCKED_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
if not available X_bar-code then
  return no-apply.
if X_bar-code.unit-cli = X_goods.unit-base then do:
  message "Нельзя удалить основной код (собственный код с основной единицей измерения)." view-as alert-box error.
  return no-apply.
end.
glog = no.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_main-barcode_deletion':U
  {&cntxt-global}
  0
  '':U
  0
  0
  X_goods.grp-code
  0
  true
  glog
  }

if not glog then return no-apply.
if can-find(first ub.db no-lock where ub.db.db-num > 0 ) then do:
  run gen-key-rec( input {&table_bar-code}
                  ,input ( buffer X_bar-code:handle )
                  ,output v-key-rec
                ) no-error.
  assign
  v-param = string(X_bar-code.b-code) + {&delim-par}  +
            string(X_bar-code.gds-code) + {&delim-par} +
            string(X_bar-code.node-code) + {&delim-par} +
            X_bar-code.part-code + {&delim-par} +
            X_bar-code.in-code + {&delim-par} +
            X_bar-code.unit-cli + {&delim-par} +
            string(X_bar-code.cli-base-rate) + {&delim-par} +
            string(X_bar-code.stts_)
  .
 if v-cntxt-db-num > 0 then do:
    define buffer buf_route for ub.route.
    /*на всякий случай проверим нет ли уже команды на запуск two-commit*/
    find first buf_route no-lock where
              buf_route.name-rec = ("command":U + {&delim-nws}
                                    + "inquiry-two-commit":U + {&delim-nws}
                                    + {&delete_nu-ucli-bar-code} + {&delim-nws}
                                    + v-key-rec + {&delim-nws}
                                    + v-param) no-error.
    if available buf_route then do:
      message
      substitute("Команда <Запуск удаления кода &1 из ГБД> уже отослана", X_bar-code.b-code)
      view-as alert-box warning.
      return no-apply.
    end.
  end.
  message
  "Удалить код:" X_bar-code.b-code
  "и все привязанные к нему дополнительные бар-коды? Вы уверены?" skip(0)
  (if v-cntxt-db-num = 0
   then  substitute("(Доп.БК будут удалены сразу же, а&1" +
                    "удаление собственного кода будет проведено только после подтверждения от всех БД)&1"
                    , {&new-line})
   else  substitute("(Будет отослана в ГБД команда <Запуск удаления кода &1 из ГБД>)&1", {&new-line})
   )
  view-as alert-box question buttons OK-Cancel update glog.
end.
else do:
  message "Удалить код:" X_bar-code.b-code
  "и все привязанные к нему дополнительные бар-коды? Вы уверены?"
  view-as alert-box question buttons OK-Cancel update glog.
end.
if not glog then return no-apply.
del-bc:
do on stop undo del-bc, return no-apply on error undo del-bc, return no-apply:
  find locked_bar-code EXCLUSIVE-LOCK WHERE recid(LOCKED_bar-code) = RECID(X_bar-code) no-error .
  if not available locked_bar-code then do:
    message
    "Запись уже отсутствует или недоступна"
    view-as alert-box warning.
    return no-apply.
  end.
  for each buf_prod-bc where
            buf_prod-bc.b-code = X_bar-code.b-code
      on stop undo del-bc, return no-apply on error undo del-bc, return no-apply:
      if buf_prod-bc.bc-on and send-ref then
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(buf_prod-bc)) + {&delim-par} + "D":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Удаление ДопБК с кассы') .
    delete buf_prod-bc.
  end.
  if can-find(first ub.db no-lock where ub.db.db-num > 0 ) then do:
    /*Теперь здесб будет стоять two-commit удаление*/

    run nws/db-rec.p ( input {&delete_nu-ucli-bar-code}
                  ,input v-key-rec
                  ,input v-param
                ) no-error .
    if not error-status:error
    and return-value = "":U
    then do:
      if send-ref then
      run str/diallog.w ( parparentproc
                  , this-procedure
                  , 'str/send-bc.p':U
                  , string(recid(X_bar-code)) + {&delim-par} + "D":U
                  , yes /*p-auto-go*/
                  , '':U
                  , 'Удаление бар-кода с кассы') .
    end.
    else do:
      message
      "Не удается послать на все БД команду удаления бар-кода" skip
      string(if error-status:error
      then (error-status:get-message(1) + {&new-line} + return-value )
      else return-value )
      view-as alert-box error .
   end.
  end.
  else do:
      if send-ref then
      run str/diallog.w ( parparentproc
                  , this-procedure
                  , 'str/send-bc.p':U
                  , string(recid(X_bar-code)) + {&delim-par} + "D":U
                  , yes /*p-auto-go*/
                  , '':U
                  , 'Удаление бар-кода с кассы') .
      delete locked_bar-code .
  end.
end.
run ui-on IN THIS-PROCEDURE .
apply "entry" to br-bc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-1 Dialog-Frame
ON CHOOSE OF b-del-1 IN FRAME Dialog-Frame /* Удалить */
DO:
 define variable glog as logical no-undo .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_units for ub.units.
if not available X_prod-bc then
  return no-apply.
find buf_bar-code where
     buf_bar-code.b-code = X_prod-bc.b-code no-lock.
find buf_units where
     buf_units.unit-name = buf_bar-code.unit-cli no-lock.
find first buf_prod-bc exclusive-lock where
          buf_prod-bc.b-str = X_prod-bc.b-str
      and buf_prod-bc.b-code = X_prod-bc.b-code .
if lookup ({&weight}, buf_units.type) > 0 then do:
  /*проверим тип*/
  if IS-GLOBAL(buffer buf_prod-bc) then do:
    message
    "Нельзя удалить ГЛОБАЛЬНЫЙ весовой код"
            view-as alert-box error.
    return no-apply.
  end.
end.
if buf_prod-bc.bc-on-type = {&loc-pg-code}
or (lookup ({&weight}, buf_units.type) > 0
    and  IS-GLOBAL(buffer buf_prod-bc) = no)
and buf_prod-bc.bc-on = yes
then do:
  message
  "Нельзя удалить ВКЛЮЧЕННЫЙ весовой код или штучный код для весов."
          view-as alert-box error.
  return no-apply.
end.
if (buf_prod-bc.bc-on-type = {&loc-pg-code}
or buf_prod-bc.bc-on-type = {&loc-sc-code}
or buf_prod-bc.bc-on-type = {&gbl-sc-code}
or lookup ({&weight}, buf_units.type) > 0)
and buf_prod-bc.cr-db-num <> v-cntxt-db-num
then do:
  message
  "Нельзя удалить весовой код или штучный код для весов, созданный в другой БД."
   view-as alert-box error.
  return no-apply.
end.

glog = no.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_alt-barcode_deletion':U
{&cntxt-global}
0
'':U
0
0
X_goods.grp-code
0
true
glog
}

if not glog then return no-apply.
glog = no.
message
"Удалить дополнительный бар-код:" X_prod-bc.b-str "? Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then  return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_alt-barcode_preparation':U
{&cntxt-global}
0
'':U
0
0
X_goods.grp-code
0
true
glog
}

if not glog then  return no-apply.

del-bc1:
do on stop undo del-bc1, return no-apply on error undo del-bc1, return no-apply:
  if X_prod-bc.bc-on AND send-ref then
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(X_prod-bc)) + {&delim-par} + "D":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Удаление ДопБК с кассы') .
  delete buf_prod-bc.
end.
run UI-on.
apply "entry" to br-pbc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-attr Dialog-Frame
ON CHOOSE OF b-del-attr IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-range as integer no-undo .  /*область действия*/
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
if attr-mode = {&all} then return no-apply.
if not avail temp-bar-code-attr then return no-apply.
run bc-oattr_name (
 input  temp-bar-code-attr.attr-code
,output attr-type
,output attr-format
,output attr-label
,output attr-range
,output attr-user-can-edit
,output attr-output-display
,output attr-other
) .
if not attr-user-can-edit then do:
message
"Атрибут нельзя удалить вручную"
view-as alert-box error .
return no-apply.
end.
glog = no.
message
substitute("Вы уверены, что хотите удалить атрибут &1 для бар-кода &2"
          ,temp-bar-code-attr.attr-label
          ,X_bar-code.b-code)
view-as alert-box QUESTIOn buttons YES-NO update glog.
if NOT glog then return no-apply.
run bc-oattr_delete in this-procedure(
                                 input X_bar-code.b-code
                                ,input temp-bar-code-attr.attr-code
                                ,input temp-bar-code-attr.obj-type
                                ,input temp-bar-code-attr.obj-code
                                ,output loc#log) no-error .
if error-status:error or not loc#log then do:
  message
  "Ошибка при удалении атрибута бар-кода" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  return no-apply.
end.
delete temp-bar-code-attr.
run init-attr-proc in this-procedure .
run openbr-bc-attr in this-procedure ( input attr-mode) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dpl Dialog-Frame
ON CHOOSE OF b-dpl IN FRAME Dialog-Frame /* Повтор */
DO:
def buffer prod-on for ub.prod-bc.
def buffer bc-on   for ub.bar-code.
define variable rid as recid no-undo.
define variable v-rep-rec as recid no-undo .

  if not available X_prod-bc then do:
    message "Неправильно выбран дополнительный бар-код."
            view-as alert-box error.
    return no-apply.
  end.
  v-rep-rec = recid (X_prod-bc).
  if not can-find (first prod-on where
                         prod-on.b-str = X_prod-bc.b-str and
                         recid (prod-on) <> v-rep-rec no-lock) then do:
    message "Для данного доп. бар-кода нет повторных."
            view-as alert-box .
    return no-apply.
  end.
  rid = recid (X_prod-bc).
  run ref/bc-rcnz.w (
                 input parparentproc,
                 input p-curr-obj-type,
                 input p-curr-obj-code,
                 input X_prod-bc.b-str,
                 input 0,
                 input (if transaction then {&lookup} else {&update}),
                 input-output rid).
  run UI-on.
  apply "entry" to br-pbc in frame {&frame-name}.
  reposition br-pbc to recid v-rep-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gtin-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gtin-1 Dialog-Frame
ON CHOOSE OF b-gtin-1 IN FRAME Dialog-Frame /* GTIN */
DO:
    define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  X_goods.grp-code
  0
  true
  glog
  }
  if not glog then return no-apply.
run ref/pbc-form.w
    (input parparentproc
    ,input {&add-def}
    ,input X_bar-code.b-code
    ,input ""
    ,input no
    ,input {&gtin}
    ,input-output rid
    ).
  if rid = ? then
    return no-apply.
  apply "entry" to br-pbc in frame {&frame-name}.
  apply "value-changed" to br-bc.
  reposition br-pbc to recid rid no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist-0 Dialog-Frame
ON CHOOSE OF b-hist-0 IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
if not avail X_bar-code then return no-apply.
run ref/cbarcods.w (
                  input parparentproc
                , input "":U /*bttns*/
                , "one":U /*p-mode*/
                , input X_goods.gds-code
                , input X_bar-code.b-code
                , input ? /* p-corr-user-db-num  */
                , input "":U /* p-corr-user-name  */
                , input v-cntxt-db-num /* p-db-num */
                , input-output v-rid-list  ) no-error .

  apply "entry" to br-pbc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist-2 Dialog-Frame
ON CHOOSE OF b-hist-2 IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
if not avail X_prod-bc then return no-apply.
run ref/cprodbcs.w (
                  input parparentproc
                , input "":U /*bttns*/
                , {&all} /*p-mode*/
                , input X_prod-bc.b-str
                , input X_prod-bc.b-code
                , input ? /* p-corr-user-db-num  */
                , input "":U /* p-corr-user-name  */
                , input v-cntxt-db-num /* p-db-num */
                , input-output v-rid-list  ) no-error .

  apply "entry" to br-pbc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-on Dialog-Frame
ON CHOOSE OF b-on IN FRAME Dialog-Frame /* Вкл */
DO:
define variable glog as logical no-undo .
  if not available X_prod-bc then do:
    message "Неправильно выбран дополнительный бар-код."
            view-as alert-box error.
    return no-apply.
  end.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_turn-on':U
  {&cntxt-global}
  0
  '':U
  0
  0
  X_goods.grp-code
  0
  true
  glog
  }

  if not glog then return no-apply.
  run trg/bc-upd.p (
                input parparentproc
               ,input X_prod-bc.b-code
               ,input X_prod-bc.b-str
               ,input (NOT X_prod-bc.bc-on)
               ,input no
               ,input send-ref
               ,input ?
               ,input ?
               ) no-error  .
  if error-status:error then do:
    if return-value <> "":U then do:
      message
      return-value
      view-as alert-box .
      return no-apply.
    end.
  end.
  /* все отсюда выносим в p-шку*/
  display X_prod-bc.bc-on with browse br-pbc.
  apply "entry" to br-pbc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print-1 Dialog-Frame
ON CHOOSE OF b-print-1 IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_prod-bc for ub.prod-bc.
if not available X_prod-bc then return no-apply.
find first buf_prod-bc no-lock where
            recid(buf_prod-bc) = recid(X_prod-bc) no-error.
if not available buf_prod-bc then return no-apply.
if buf_prod-bc.bc-on = no then do:
    message
    "Данный ДопБК выключен" skip
    "Вы действительно хотите напечать этикетку на него?"
    view-as alert-box QUestion buttons YEs-No update loc#log.
    if not loc#log then return no-apply.
end.
run rep/tick-pbc.p (       input parparentproc
                     ,input p-curr-obj-type
                     ,input p-curr-obj-code
                     ,input recid(buf_prod-bc)
                     ,input buf_prod-bc.b-code
                    ) no-error.
if error-status:error then return no-apply.
apply "entry" to br-pbc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print-2 Dialog-Frame
ON CHOOSE OF b-print-2 IN FRAME Dialog-Frame
DO:
  if not available X_bar-code then  return no-apply.
  run rep/tick-one.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code, recid (X_bar-code)).
  apply "entry" to br-bc in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-bc
&Scoped-define SELF-NAME br-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-bc Dialog-Frame
ON VALUE-CHANGED OF br-bc IN FRAME Dialog-Frame /* Собственные */
DO:
    open query br-pbc
  for each X_prod-bc no-lock where
           X_prod-bc.b-code = X_bar-code.b-code.
apply "value-changed" to br-pbc.
run openbr-bc-attr in this-procedure ( input attr-mode) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-pbc
&Scoped-define SELF-NAME BR-pbc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pbc Dialog-Frame
ON VALUE-CHANGED OF BR-pbc IN FRAME Dialog-Frame /* Дополнительные */
DO:
if available X_prod-bc then
  display X_prod-bc.b-str with frame {&frame-name}.
else
  display "" @ X_prod-bc.b-str with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-attr-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-attr-mode Dialog-Frame
ON VALUE-CHANGED OF Rs-attr-mode IN FRAME Dialog-Frame
DO:
  assign
  rs-attr-mode.
  attr-mode = rs-attr-mode.
  case rs-attr-mode:
    when {&all} then do:
      disable
      b-add-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      b-chg-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      b-del-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      with frame {&frame-name} .
    end.
    when "b-code" then do:
      enable
      b-add-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      b-chg-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      b-del-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
      with frame {&frame-name} .
    end.
  end case.
  run openbr-bc-attr in this-procedure ( input  attr-mode) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-bc
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

browse br-bc :SET-REPOSITIONED-ROW (5, "CONDITIONAL").
browse br-pbc :SET-REPOSITIONED-ROW (5, "CONDITIONAL").
browse br-bc-attr :SET-REPOSITIONED-ROW (5, "CONDITIONAL").

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i
  &disable_diasize_init=true &browse-name="br-bc"
}

{ gbl/brwrepos.i
  &browse-name=br-bc
  &line-num=5
}
{ gbl/brwrepos.i
  &browse-name=br-pbc
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
  /*кажется не из интерфейса тоже может вызываться?*/
  find base-bar-code no-lock where
       base-bar-code.b-code = base-bc no-error .
  if not available base-bar-code then do:
    message
    "Отсутствует бар-код" base-bc
    view-as alert-box error .
    undo, return error .
  end.
  find X_goods no-lock where
       X_goods.gds-code = base-bar-code.gds-code.
  find X_gds-prt no-lock where
       X_gds-prt.node-code = base-bar-code.node-code.
  DISPLAY X_goods.artic X_goods.gds-name WITH FRAME {&frame-name}.
  find first base_units no-lock where
            base_units.unit-name = X_goods.unit-base no-error.
  find ub.db where
       ub.db.db-num = v-cntxt-db-num no-lock.
  { ref/attr-pop.i prepare }
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  run UI-on in this-procedure .
  run diasize_add_browse in this-procedure
    (input  'height':u
    ,input  browse br-pbc :handle
    ) .
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
run attr-pop-clean-up in this-procedure ( input {&table_bar-code-attr} ).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add-attr in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY Rs-attr-mode
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.artic X_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_prod-bc THEN
    DISPLAY X_prod-bc.b-str
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help X_goods.artic X_goods.gds-name b-chg-1 b-add b-chg b-del 
         b-print-2 b-hist-0 b-on b-dpl b-add-1 b-chg-1 b-del-1 b-gtin-1 b-print-1 
         b-hist-2 br-bc BR-pbc Rs-attr-mode b-add-attr b-chg-attr b-del-attr 
         br-bc-attr X_prod-bc.b-str 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr-proc Dialog-Frame
PROCEDURE init-attr-proc :
define variable attr-type as character no-undo .          /* тип атрибута      */
define variable attr-format as character no-undo .        /* формат атрибута   */
define variable attr-label as character no-undo .         /* лабел атрибута    */
define variable attr-value as character no-undo .         /* значение атрибута */
define variable attr-range as integer no-undo .           /* область действия  */
define variable attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define variable attr-output-display as logical no-undo .  /* виден в броусе    */
define variable attr-other as char no-undo .              /* еще чего - нибудь */

define buffer buf_bar-code for ub.bar-code.
define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr.
for each  Temp-bar-code-attr share-lock:
   delete Temp-bar-code-attr.
 end.

add-option = "".
For each buf_bar-code-obj-attr where
        buf_bar-code-obj-attr.gds-code  = base-bar-code.gds-code
        no-lock :
  run bc-oattr_name in this-procedure (
                                       input  buf_bar-code-obj-attr.attr-code
                                      ,output attr-type
                                      ,output attr-format
                                      ,output attr-label
                                      ,output attr-range
                                      ,output attr-user-can-edit
                                      ,output attr-output-display
                                      ,output attr-other ).
  if attr-output-display = true then DO:
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_bar-code-obj-attr.b-code no-error.
    create temp-bar-code-attr.
    buffer-copy buf_bar-code-obj-attr
    to temp-bar-code-attr
    assign
    temp-bar-code-attr.attr-label = attr-label
    temp-bar-code-attr.user-can-edit = attr-user-can-edit
    temp-bar-code-attr.unit-cli = (if available buf_bar-code
                                   then buf_bar-code.unit-cli
                                   else {&question-mark})
    temp-bar-code-attr.cli-base-rate = (if available buf_bar-code
                                   then buf_bar-code.cli-base-rate
                                   else ?)
    .
    release temp-bar-code-attr.
  End.
End.   /* FOR EACH */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/* Проверка на разрешение работы с Дополнительными Баркодами. Добавлено по задаче ТН-3097. Арн. 2014г */
do: /* A */
    define variable v-tth as handle no-undo.  
    define variable v-chg-bcod as logical no-undo.
    define variable v-value-character as character no-undo.
    define variable v-value-date as date no-undo.
    define variable v-value-decimal as decimal no-undo.
    define variable v-value-integer as INTEGER no-undo.
    define variable v-value-logical AS LOGICAL no-undo.
    define variable v-param-type as character no-undo.
    define buffer buf_goods-attr for goods-attr.
    assign v-tth = buffer thbjattr_thbj-attr:table-handle.

    FOR EACH thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
    end.

    run adm/shattri.p (
              input "get":U
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input {&attr-gds-ref_obj}
            , input {&attr-gds-ref_obj_chg-bcod} /*p-param-code*/
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
    
     v-chg-bcod = v-value-logical.
end. /* A */

ENABLE
b-print-2 br-bc br-pbc b-quit b-help b-hist-2 b-hist-0 /*b-dpl - перенёс (см. ниже) для выполнения ТН-3097. Арн. 2014г*/
b-add-1 when v-cntxt-level = {&cntxt-object} and v-chg-bcod = no
b-gtin-1 when v-cntxt-level = {&cntxt-object} and v-chg-bcod = no
b-del-1 when v-cntxt-level = {&cntxt-object} and v-chg-bcod = no
b-chg-1 when v-cntxt-level = {&cntxt-object} and v-chg-bcod = no
b-on    when v-cntxt-level = {&cntxt-object} and v-chg-bcod = no
b-dpl   when v-chg-bcod = no
b-print-1 WITH FRAME {&frame-name}.
X_prod-bc.b-str:COLUMN-READ-ONLY IN BROWSE br-pbc = YES.
if not transaction then do:
    if ub.db.add-goods and v-cntxt-level = {&cntxt-object} then do:
      ENABLE
      b-add
      b-del
      b-chg
      WITH FRAME {&frame-name}.
    end.
end.
define variable hh as widget-handle no-undo .
assign
hh = b-print-1:handle in frame {&frame-name}.
hh:load-image("cmp/b-print.bmp":u).
hh:TOOLTIP = "Печать".
hh = b-print-2:handle in frame {&frame-name}.
hh:load-image("cmp/b-print.bmp":u).
hh:TOOLTIP = "Печать".
hh = b-hist-0:handle in frame {&frame-name}.
hh:load-image("cmp/b-hist.bmp":u).
hh:TOOLTIP = "История собственных кодов".
hh = b-hist-2:handle in frame {&frame-name}.
hh:load-image("cmp/b-hist.bmp":u).
hh:TOOLTIP = "История дополнительных кодов" .


/*пока не будем везде показывать броуз атрибутов*/
ASSIGN
b-add-attr:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-add-attr:HANDLE
b-add-attr:MENU-MOUSE = 1
.
if base-bar-code.unit-cli = X_goods.unit-base
and lookup(base_units.type, {&weight}) > 0 then do:
  run init-attr-proc in this-procedure.
  rs-attr-mode:radio-buttons in frame {&frame-name} = "Бар-код" + {&comma-char} + "b-code" + {&comma-char} +
                                                      "Все бар-коды" + {&comma-char} + {&all}.
  enable
  b-add-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
  b-chg-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
  b-del-attr when (ub.db.add-goods and v-cntxt-level = {&cntxt-object} )
  br-bc-attr
  rs-attr-mode
  with frame {&frame-name} .
  ASSIGN
  temp-bar-code-attr.attr-label:resizable in browse br-bc-attr = yes
  temp-bar-code-attr.attr-value:resizable in browse br-bc-attr = yes
  browse br-bc:height = 9
  browse br-pbc:height = 9
  .
  if ub.db.add-goods
  ThEN do:

    run attr-pop-create-items in this-procedure  (
                                                  input {&table_bar-code-attr}
                                                  ,input 'bc-oattr_manual-edit'   /*p-get-section-num-proc-name*/
                                                  ,input 'bc-oattr_tooltip'
                                                  ,input 'choose-to-edit'
                                                  ,input menu menu-b-add-attr:handle
                                                  ,input {&bc-attr-list}
                                                ).
  end.
end.
else do:
  hide
  b-add-attr in frame {&frame-name}
  b-chg-attr in frame {&frame-name}
  b-del-attr in frame {&frame-name}
  br-bc-attr in frame {&frame-name}
  rs-attr-mode in frame {&frame-name}
  .
end.
/*b-gtin-1:visible = can-find (first buf_goods-attr                              */
/*               where buf_goods-attr.gds-code   = X_goods.gds-code              */
/*                 and buf_goods-attr.attr-code  = {&attr-mark-type}             */
/*                 and buf_goods-attr.attr-value <> {&attr-mark-type_not-type} ).*/
if base-bar-code.in-code = "" then
  if X_gds-prt.upper-code = X_goods.prt-root then
    frame {&frame-name}:title = "Коды: ТОВАР".
  else
    frame {&frame-name}:title = "Коды: ПРИЗНАК: " + X_gds-prt.f-name.
else
  frame {&frame-name}:title = "Коды: ПАРТИЯ: ПН: " + base-bar-code.in-code +
                              " Номер: " + base-bar-code.part-code.

view frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-bc Dialog-Frame
PROCEDURE Openbr-bc :
OPEN QUERY br-bc
  FOR EACH  X_bar-code no-lock WHERE
            X_bar-code.gds-code  = base-bar-code.gds-code and
            X_bar-code.node-code = base-bar-code.node-code and
            X_bar-code.part-code = base-bar-code.part-code and
            X_bar-code.in-code   = base-bar-code.in-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-bc-attr Dialog-Frame
PROCEDURE Openbr-bc-attr :
define input parameter p-bc-attr-mode as character no-undo .
case p-bc-attr-mode:
  when {&all} then do:
    open query br-bc-attr
    for each temp-bar-code-attr no-lock.
  end.
  when "b-code" then do:
    if available X_bar-code then do:
      open query br-bc-attr
      for each temp-bar-code-attr where
      temp-bar-code-attr.b-code = X_bar-code.b-code no-lock.
    end.
    else do:
      open query br-bc-attr
      for each temp-bar-code-attr where
      false no-lock.

    end.
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-attr Dialog-Frame
PROCEDURE proc-add-attr :
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-range as integer no-undo . /*область действия*/
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable loc#log as logical no-undo.
define buffer buf_temp-bar-code-attr for temp-bar-code-attr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-attr-add-chg in this-procedure ( input yes
                                    ,input ?
                                    ,input ?
                                   ) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
Run init-attr-proc in this-procedure .
run openbr-bc-attr in this-procedure ( input attr-mode) no-error.
find first buf_temp-bar-code-attr no-lock where
                        buf_temp-bar-code-attr.attr-code = add-option no-error.
add-option = "":U.
if avail buf_temp-bar-code-attr then
    temp-doc-rec = recid(buf_temp-bar-code-attr).
    else temp-doc-rec = ?.
reposition br-bc-attr to recid temp-doc-rec no-error.
if error-status:error then return no-apply.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-attr-add-chg Dialog-Frame
PROCEDURE proc-attr-add-chg :
define input parameter p-add as logical no-undo.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-range as integer no-undo .         /*дейвствует */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
DEFINE VARIABLE v-attr-value as character no-undo .
define var loc#log as logical no-undo.
DEFINE VARIABLE v-init as character no-undo .
define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-local-option as character no-undo .
CASE p-add:
  when yes then do:
    v-local-option = add-option.
    run bc-oattr_name in this-procedure
      (input  v-local-option      /* p-code           */
      ,output attr-type           /* p-type           */
      ,output attr-format         /* p-format         */
      ,output attr-label          /* p-label          */
      ,output attr-range          /* p-range          */
      ,output attr-user-can-edit  /* p-user-can-edit  */
      ,output attr-output-display /* p-output-display */
      ,output attr-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      return error .
    end.
    case attr-range:
      when  0 then do:
        assign
        p-obj-type = ''
        p-obj-code = 0
        .
      end.
      when  2 then do:
        assign
        p-obj-type = v-cntxt-obj-type
        p-obj-code = v-cntxt-obj-code
        .
      end.
     end case.
     run bc-oattr_exist in this-procedure(
                                     input X_bar-code.b-code
                                    ,input v-local-option
                                    ,input p-obj-type
                                    ,input p-obj-code
                                    ,output loc#log)  no-error.
    if error-status:error then return error.
    if loc#log then do:
      message
      "Данный атрибут уже существует"
      view-as alert-box error .
      return error.
    end.
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        .
      end.
    end. /*jj*/
    if  v-init <> "":U then do:
      run  value(v-init)
                  in this-procedure ( input X_bar-code.b-code
                                    , input p-obj-type
                                    , input p-obj-code
                                    , output attr-value) no-error .
      if error-status:error then do:
        assign
        attr-value = "":U
        .
      end.
    end.
    CASE attr-type:
      when {&type-log} then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        v-attr-value = ?
        .
      end.
      when {&type-char} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end. /*when add*/
  when no then do:
    v-local-option = temp-bar-code-attr.attr-code.
    run bc-oattr_name in this-procedure ( input temp-bar-code-attr.attr-code
                                       ,output attr-type
                                       ,output attr-format
                                       ,output attr-label
                                       ,output attr-range
                                       ,output attr-user-can-edit
                                       ,output attr-output-display
                                       ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
     {&gdsoattr-type-get-error}
      return error.
    END.
    attr-value  = temp-bar-code-attr.attr-value.
  end. /*when chg*/
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-ext":U
    or entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check-ext":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
  if v-spr = "":U then do:
    run gbl/d-prompt.w (
      'title=':u + "Изменение атрибута бар-кода" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' + 'no':u + '\':u
    , input-output attr-value
    ).
    if return-value = 'false':u then return error.
  end.
  else do:
    if v-spr-param = "":U then do:
      run  value(v-spr) in this-procedure
                                    (
                                       input parparentproc
                                      ,input X_bar-code.b-code
                                      ,input p-obj-type
                                      ,input p-obj-code
                                      ,input-output attr-value
                                      ,output v-setted) no-error .

    end.
    else do:
      run  value(v-spr) in this-procedure
                                   (
                                       input parparentproc
                                      ,input X_bar-code.b-code
                                      ,input p-obj-type
                                      ,input p-obj-code
                                      ,input v-spr-param
                                      ,input-output attr-value
                                      ,output v-setted) no-error .


    end.
   if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input X_bar-code.b-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input attr-value
                      ,input (if p-add then {&add-def} else {&update})
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run bc-oattr_write in this-procedure (
       input X_bar-code.b-code
      ,input v-local-option
      ,input p-obj-type
      ,input p-obj-code
      ,input attr-value) no-error .
  IF not error-status:error then do:
     br-bc-attr:refresh() in frame {&frame-name} no-error .
  END.
  else do:
    message
    "Ошибка при сохранении атрибута бар-кодв" skip
    "бар-код" X_bar-code.b-code skip
    "Атрибут" v-local-option
    view-as alert-box  error .
    undo, return error  .
  end.

End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on Dialog-Frame
PROCEDURE ui-on :
RUN Openbr-bc IN THIS-PROCEDURE.
apply "entry"         to br-bc in frame {&frame-name}.
apply "value-changed" to br-bc in frame {&frame-name}.
if br-bc-attr:visible in frame {&frame-name} then do:
  run openbr-bc-attr in this-procedure ( input attr-mode) no-error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME