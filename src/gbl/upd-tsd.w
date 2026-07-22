&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание и редактирование шаблона выгрузки на ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */
define input parameter  parparentproc as widget-handle no-undo .
define input parameter  p-obj-type  like ub.clients.obj-type no-undo .
define input parameter  p-obj-code  like ub.clients.obj-code no-undo .
define input parameter  c-point     as character no-undo .
define input parameter  list-tabls  as character no-undo .
define input parameter  list-buf    as character no-undo .
define input parameter  list-fields as character no-undo .
define input parameter  list-labels as character no-undo .
define input parameter  list-spr    as character no-undo .
define input parameter  list-size    as character no-undo .
define input parameter  list-size-min    as character no-undo .
define input parameter  list-format    as character no-undo .
define input parameter  list-dim    as character no-undo .
define input parameter  kl          as integer   no-undo .
define output parameter ident       as recid     no-undo .
define output parameter P-LENGTH       as INTEGER     no-undo .
define output parameter P-NUM-CLMN       as INTEGER     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и редактирование шаблона печати".
{ cmp/vssrevis.i substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,c-point,list-tabls,list-buf,list-fields,list-labels,list-spr,list-dim,kl)"}
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ trg/factord.i }
{ cmp/yearofst.i }

def new shared var undo_ as logical initial no.

define variable select3 AS CHARACTER INITIAL "" no-undo.
define variable select3-size as character no-undo .
define variable select3-size-min as character no-undo .
define variable select3-csize as character no-undo .
define variable select3-format as character no-undo .
define variable select3-type as character no-undo .
define variable select3-codes as character no-undo .
define variable select3-label as character no-undo .

/* Local Variable Definitions ---                                       */

{ str/tsdtmpdt.i }

define buffer sel_t-f for t-f.
define variable v-rb as character no-undo.
define variable ii AS INTEGER no-undo.
define variable jj AS INTEGER no-undo.
define variable kk AS INTEGER no-undo.
define variable ll AS INTEGER no-undo.
define variable id AS RECID no-undo.
define variable file-name LIKE _FILE-NAME no-undo.
define variable v-new as logical no-undo .
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.
define variable v-delim as character no-undo.
define variable v-rec-num as integer no-undo.
define variable v-scl-format as character NO-UNDO INIT "99999":U.
define variable v-pg-format as character NO-UNDO INIT "99999":U.
define variable v-host-code like ub.sysconf.host-code no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME BR-fields

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES t-f sel_t-f ubflt.filter

/* Definitions for BROWSE BR-fields                                     */
&Scoped-define FIELDS-IN-QUERY-BR-fields t-f.field-label t-f.field-size t-f.field-size-min
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-fields
&Scoped-define SELF-NAME BR-fields
&Scoped-define QUERY-STRING-BR-fields FOR EACH t-f no-lock where t-f.table-name = RS-tabs and t-f.field-order = 0 use-index itorder
&Scoped-define OPEN-QUERY-BR-fields OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock where t-f.table-name = RS-tabs and t-f.field-order = 0 use-index itorder.
&Scoped-define TABLES-IN-QUERY-BR-fields t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-fields t-f


/* Definitions for BROWSE BR-sel-fields                                 */
&Scoped-define FIELDS-IN-QUERY-BR-sel-fields sel_t-f.field-label sel_t-f.field-size sel_t-f.field-size-min sel_t-f.field-csize
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sel-fields sel_t-f.field-csize
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-sel-fields sel_t-f
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-sel-fields sel_t-f
&Scoped-define SELF-NAME BR-sel-fields
&Scoped-define QUERY-STRING-BR-sel-fields FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder
&Scoped-define OPEN-QUERY-BR-sel-fields OPEN QUERY {&SELF-NAME} FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
&Scoped-define TABLES-IN-QUERY-BR-sel-fields sel_t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sel-fields sel_t-f


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define FIELDS-IN-QUERY-DIALOG-1 ubflt.Filter.Naim
&Scoped-define ENABLED-FIELDS-IN-QUERY-DIALOG-1 ubflt.Filter.Naim
&Scoped-define ENABLED-TABLES-IN-QUERY-DIALOG-1 ubflt.Filter
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-DIALOG-1 ubflt.Filter
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-BR-sel-fields}
&Scoped-define QUERY-STRING-DIALOG-1 FOR EACH ubflt.filter SHARE-LOCK
&Scoped-define OPEN-QUERY-DIALOG-1 OPEN QUERY DIALOG-1 FOR EACH ubflt.filter SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-DIALOG-1 ubflt.filter
&Scoped-define FIRST-TABLE-IN-QUERY-DIALOG-1 ubflt.filter


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ubflt.Filter.Naim
&Scoped-define ENABLED-TABLES ubflt.Filter
&Scoped-define FIRST-ENABLED-TABLE ubflt.Filter
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help RECT-1 RS-tabs ~
f-delim S-delim f-rec-num CB-scl-format CB-pg-format BR-sel-fields ~
BR-fields
&Scoped-Define DISPLAYED-FIELDS ubflt.Filter.Naim
&Scoped-define DISPLAYED-TABLES Filter
&Scoped-define FIRST-DISPLAYED-TABLE ubflt.Filter
&Scoped-Define DISPLAYED-OBJECTS RS-tabs f-num-clmn f-delim S-delim ~
f-length f-rec-num CB-scl-format CB-pg-format FILL-IN-4 FILL-IN-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-down
     LABEL "Вни&з":L
     SIZE 8.5 BY 1 TOOLTIP "Понизить порядок выбранного поля".

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-up
     LABEL "Ввер&х":L
     SIZE 8.5 BY 1 TOOLTIP "Повысить порядок выбранного поля".

DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 8.5 BY 1 TOOLTIP "Добавить поле в список сортируемых полей".

DEFINE BUTTON btn-codes
     LABEL "&Коды":L
     SIZE 8.5 BY 1 TOOLTIP "Убрать поле из списка сортируемых полей".

DEFINE BUTTON btn-remove
     LABEL "У&брать":L
     SIZE 8.5 BY 1 TOOLTIP "Убрать поле из списка сортируемых полей".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный фильтр"
     BGCOLOR 8 .

DEFINE VARIABLE CB-pg-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE CB-scl-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-delim AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-rec-num AS INTEGER FORMAT ">>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 46 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE RS-tabs AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 97.38 BY .79 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 98.75 BY 1.88
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE S-delim AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 6.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-fields FOR
      t-f SCROLLING.

DEFINE QUERY BR-sel-fields FOR
      sel_t-f SCROLLING.

DEFINE QUERY DIALOG-1 FOR
      ubflt.filter SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-fields DIALOG-1 _FREEFORM
  QUERY BR-fields DISPLAY
      t-f.field-label format "X(30)" column-label "Название поля"
t-f.field-size format "X(3)":U column-label "Длина!поля!рекоменд"
t-f.field-size-min format "X(3)":U column-label "Длина!поля!миним"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 12.17
         BGCOLOR 15 .

DEFINE BROWSE BR-sel-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sel-fields DIALOG-1 _FREEFORM
  QUERY BR-sel-fields DISPLAY
      sel_t-f.field-label format "X(30)" column-label "Название поля"
sel_t-f.field-size format "X(3)":U column-label "Длина!поля!рекоменд"
sel_t-f.field-size-min format "X(3)":U column-label "Длина!поля!миним"
sel_t-f.field-csize format "X(3)":U column-label "Длина!поля!выбранная"
ENABLE
sel_t-f.field-csize
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46.5 BY 12.25
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ubflt.Filter.Naim AT ROW 2.67 COL 24.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 73.13 BY 1 TOOLTIP "Введите имя создаваемого шаблона печати"
          BGCOLOR 15
     RS-tabs AT ROW 4.5 COL 2 NO-LABEL
     f-num-clmn AT ROW 5.5 COL 56.88 COLON-ALIGNED NO-LABEL
     f-delim AT ROW 5.5 COL 76.75 COLON-ALIGNED NO-LABEL
     S-delim AT ROW 5.5 COL 93.38 NO-LABEL
     f-length AT ROW 5.54 COL 34.13 COLON-ALIGNED NO-LABEL
     f-rec-num AT ROW 6.71 COL 36.63 COLON-ALIGNED NO-LABEL
     CB-scl-format AT ROW 6.75 COL 64 COLON-ALIGNED NO-LABEL
     CB-pg-format AT ROW 6.75 COL 85 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     FILL-IN-4 AT ROW 8.04 COL 49.75 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 8.25 COL 2 NO-LABEL
     btn-add AT ROW 8.42 COL 42.38
     BR-sel-fields AT ROW 9.08 COL 51.5
     BR-fields AT ROW 9.25 COL 2
     btn-remove AT ROW 9.42 COL 42.38
     btn-codes AT ROW 10.42 COL 42.38
     b-up AT ROW 13.42 COL 42.5
     b-down AT ROW 14.42 COL 42.5
     "Формат вес. кода" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 7 COL 49.5
     "Количество выводимых записей" VIEW-AS TEXT
          SIZE 34.88 BY .67 AT ROW 6.92 COL 1.13
          BGCOLOR 1 FGCOLOR 15
     "Разделитель" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 5.63 COL 65.75
          BGCOLOR 1 FGCOLOR 15
     "ASCII" VIEW-AS TEXT
          SIZE 6.13 BY .67 AT ROW 5.63 COL 86
          BGCOLOR 1 FGCOLOR 15
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 5.63 COL 46.13
          BGCOLOR 1 FGCOLOR 15
     "Длина шаблона" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 5.71 COL 20.75
          BGCOLOR 1 FGCOLOR 15
     "штучн." VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 7 COL 79.5 WIDGET-ID 4
     RECT-1 AT ROW 2.25 COL 1
     SPACE(0.13) SKIP(17.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Редактирование шаблонов выгрузки в файл для ТСД":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-sel-fields btn-add DIALOG-1 */
/* BROWSE-TAB BR-fields BR-sel-fields DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-down IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-up IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON btn-add IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR BUTTON btn-codes IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR BUTTON btn-remove IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN f-length IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-num-clmn IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-fields
/* Query rebuild information for BROWSE BR-fields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock where t-f.table-name = RS-tabs
and t-f.field-order = 0 use-index itorder.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-fields */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sel-fields
/* Query rebuild information for BROWSE BR-sel-fields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-sel-fields */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX DIALOG-1
/* Query rebuild information for DIALOG-BOX DIALOG-1
     _TblList          = "ubflt.filter"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX DIALOG-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down DIALOG-1
ON CHOOSE OF b-down IN FRAME DIALOG-1 /* Вниз */
DO:
define variable v-order as integer no-undo.
define variable v-rec as recid no-undo.
define buffer buf_sel-t-f for t-f.
{ gbl/stdbtn.i }
  if not available sel_t-f then do:
    return no-apply.
end.
assign
v-rec = recid(sel_t-f).
find last buf_sel-t-f use-index iorder no-error.
if avail buf_sel-t-f then do:
    v-order = buf_sel-t-f.field-order.
end.
if sel_t-f.field-order = v-order then do:
    return no-apply.
end.
assign
v-order = sel_t-f.field-order.
find first buf_sel-t-f where
            buf_SEL-T-F.field-order > v-order
            and buf_sel-t-f.field-order > 0 use-index iorder no-error.
    if not available buf_sel-t-f then do:
        return no-apply.
    end.
assign
sel_t-f.field-order = buf_sel-t-f.field-order
buf_sel-t-f.field-order = v-order
.
  APPLY "VALUE-CHANGED" to Rs-tabs.
 {&OPEN-QUERY-br-sel-fields}
  run enable-buttons in this-procedure.
  REPOSITION br-sel-fields to recid v-rec no-error.
  apply "ENTRY" to br-sel-fields.
  APPLY "Value-changed" to BR-sel-fields.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up DIALOG-1
ON CHOOSE OF b-up IN FRAME DIALOG-1 /* Вверх */
DO:
define variable v-order as integer no-undo.
define variable v-rec as recid no-undo.
define buffer buf_sel-t-f for t-f.
{ gbl/stdbtn.i }
  if not available sel_t-f then do:
    return no-apply.
end.
if sel_t-f.field-order = 1 then do:
    return no-apply.
end.
assign
v-order = sel_t-f.field-order
v-rec = recid(sel_t-f).
.
find last buf_sel-t-f where
            buf_SEL-T-F.field-order < v-order
            and buf_sel-t-f.field-order > 0 use-index iorder  no-error.
    if not available buf_sel-t-f then do:
        return no-apply.
    end.
assign
sel_t-f.field-order = buf_sel-t-f.field-order
buf_sel-t-f.field-order = v-order
.
  APPLY "VALUE-CHANGED" to Rs-tabs.
 {&OPEN-QUERY-br-sel-fields}
 run enable-buttons in this-procedure.
REPOSITION br-sel-fields to recid v-rec no-error.
  apply "ENTRY" to br-sel-fields.
   APPLY "Value-changed" to BR-sel-fields.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-fields
&Scoped-define SELF-NAME BR-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-fields DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF BR-fields IN FRAME DIALOG-1
DO:
  APPLY "CHOOSE" to btn-add.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-sel-fields
&Scoped-define SELF-NAME BR-sel-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-sel-fields DIALOG-1
ON VALUE-CHANGED OF BR-sel-fields IN FRAME DIALOG-1
DO:
  if not avail sel_t-f then return no-apply.
  if sel_t-f.field-size = sel_t-f.field-size-min  then do:
    assign
    sel_t-f.field-csize:read-only in browse BR-sel-fields = yes.
  end.
  else do:
      assign
      sel_t-f.field-csize:read-only in browse BR-sel-fields = no.
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add DIALOG-1
ON CHOOSE OF btn-add IN FRAME DIALOG-1 /* Добавить */
DO:
define variable v-max-order as integer no-undo.
define buffer buf_t-f for t-f.
{ gbl/stdbtn.i }
if not avail t-f then return no-apply.
find last buf_t-f no-lock use-index iorder no-error.
if avail buf_t-f then do:
    assign
    v-max-order = buf_t-f.field-order
    .
end.
Find first buf_t-f where
             recid(buf_t-f) = recid(t-f).
assign
buf_t-f.field-order = v-max-order + 1
v-num-clmn = v-num-clmn +  1
v-length = v-length + INTEGER(t-f.field-SIZE)
.
APPLY "VALUE-CHANGED" to Rs-tabs.
{&OPEN-QUERY-br-sel-fields}
RUN PROC-N-L IN THIS-PROCEDURE.
run enable-buttons in this-procedure.
REPOSITION br-sel-fields to recid recid(buf_t-f) no-error.
apply "ENTRY" to br-sel-fields.
APPLY "Value-changed" to BR-sel-fields.
browse br-sel-fields:set-repositioned-row(5, "CONDITIONAL").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-codes DIALOG-1
ON CHOOSE OF btn-codes IN FRAME DIALOG-1 /* Коды */
DO:
{ gbl/stdbtn.i }
run adm/to-cd.w ( {&update} ,
INPUT v-host-code,
INPUT p-obj-type,
INPUT p-obj-code,
INPUT ("Типы кодов для вывода в файл ТСД" + {&space-char} + p-obj-type +
string(p-obj-code)),
INPUT-OUTPUT temp-shop.all-prt,
INPUT-OUTPUT temp-shop.cd-bc-alt,
INPUT-OUTPUT temp-shop.cd-bc-base,
INPUT-OUTPUT temp-shop.cd-loc-alt,
INPUT-OUTPUT temp-shop.cd-loc-base,
INPUT-OUTPUT temp-shop.cd-parts-all,
INPUT-OUTPUT temp-shop.cd-parts-not-blank,
INPUT-OUTPUT temp-shop.cd-parts-ser,
INPUT-OUTPUT temp-shop.cd-pb-alt,
INPUT-OUTPUT temp-shop.cd-pb-base,
INPUT-OUTPUT temp-shop.cd-sc-base) .
apply "ENTRY" to br-sel-fields.
   APPLY "Value-changed" to BR-sel-fields.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-remove
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-remove DIALOG-1
ON CHOOSE OF btn-remove IN FRAME DIALOG-1 /* Убрать */
DO:
define variable v-order as integer no-undo.
define buffer buf_t-f for t-f.
define buffer buf1_t-f for t-f.
{ gbl/stdbtn.i }
if not available sel_t-f then do:
    return no-apply.
end.
 find first buf_t-f where
         recid(buf_t-f) = recid(sel_t-f)
 .
 v-order = buf_t-f.field-order.
assign
buf_t-f.field-order = 0
v-num-clmn = v-num-clmn -  1
v-length = v-length - INTEGER(sel_t-f.field-SIZE)
.
for each buf_t-f where
             buf_t-f.field-order > v-order:
    find first buf1_t-f where
                recid(buf1_t-f) = recid(buf_t-f).
    assign
    buf1_t-f.field-order =   buf1_t-f.field-order - 1
    .
END.
APPLY "VALUE-CHANGED" to Rs-tabs.
{&OPEN-QUERY-br-sel-fields}
RUN PROC-N-L IN THIS-PROCEDURE.
run enable-buttons in this-procedure.
REPOSITION br-sel-fields to row v-order - 1 no-error.
apply "ENTRY" to br-sel-fields.
 APPLY "Value-changed" to BR-sel-fields.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel DIALOG-1
ON CHOOSE OF Btn_Cancel IN FRAME DIALOG-1 /* Выход  */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DIALOG-1
ON CHOOSE OF Btn_OK IN FRAME DIALOG-1 /* Сохранить */
DO:
define variable v-file-name as character no-undo.
define buffer buf_sel-t-f for t-f.
{ gbl/stdbtn.i }
if (can-find(ubflt.filter where ubflt.filter.call-point = c-point
       and ubflt.filter.naim = input frame {&frame-name} ubflt.filter.naim) and v-new) or
       input frame {&frame-name} ubflt.filter.naim = "" then do:
    if input frame {&frame-name} ubflt.filter.naim = ""
    then
    message "Пустое имя фильтра недопустимо".
    else message "Фильтр с таким именем уже сущестует".
    apply "entry" to ubflt.filter.naim.
    return no-apply.
end.
id = recid(ubflt.filter).
IDENT = RECID(ubflt.filter).
assign
select3 = "":U
select3-size = "":U
select3-size-min = "":U
select3-csize = "":U
select3-format = "":U
select3-type = "":U
select3-codes = "":U
select3-label = "":U
s-delim
f-rec-num
cb-scl-format
cb-pg-format
.
APPLY "Value-changed" to s-delim.
run check-delim in this-procedure (chr(int(s-delim))) no-error.
if error-status:error then return no-apply.
for each buf_sel-t-f no-lock where
         buf_sel-t-f.field-order > 0
by buf_sel-t-f.field-order
         :
  assign
  v-file-name = "":U.
  do ii = 1 to num-entries(buf_sel-t-f.field-name, '{&delim-flt}':U):
      assign
      v-file-name = v-file-name + '{&delim-flt}':U + buf_sel-t-f.table-name + ".":U + entry(ii, buf_sel-t-f.field-name, '{&delim-flt}':U)
      .
  end.
  assign
  v-file-name = left-trim(v-file-name , '{&delim-flt}':U)
  .
  assign
  select3 = select3 + {&comma-char} + v-file-name
  select3-size = select3-size + {&comma-char} + buf_sel-t-f.field-size
  select3-size-min = select3-size-min + {&comma-char} + buf_sel-t-f.field-size-min
  select3-csize = select3-csize + {&comma-char} + buf_sel-t-f.field-csize
  select3-format = select3-format + {&delim-par} + buf_sel-t-f.field-format
  select3-type = select3-type + {&comma-char} + buf_sel-t-f.field-type
  select3-label = select3-label + {&comma-char} + buf_sel-t-f.field-clabel
  .
end.
if lookup("function.b-code-tsd":U, select3) = 0 then do:
    message
    "Нельзя создать шаблон вывода без поля БАР-КОД"
    view-as alert-box error.
    return no-apply.
end.
assign
select3-codes =
                (if temp-shop.all-prt then "all-prt":U else "":U) + {&comma-char} +
                (if temp-shop.cd-bc-alt then "cd-bc-alt":U else "":U) + {&comma-char} +
                (if temp-shop.cd-bc-base then "cd-bc-base":U else "":U) + {&comma-char} +
                (if temp-shop.cd-loc-alt then "cd-loc-alt":U else "":U) + {&comma-char} +
                (if temp-shop.cd-loc-base then "cd-loc-base":U else "":U) + {&comma-char} +
                (if temp-shop.cd-parts-all then "cd-parts-all":U else "":U) + {&comma-char} +
                (if temp-shop.cd-parts-not-blank then "cd-parts-not-blank":U else "":U) + {&comma-char} +
                (if temp-shop.cd-parts-ser then "cd-parts-ser":U else "":U) + {&comma-char} +
                (if temp-shop.cd-pb-alt then "cd-pb-alt":U else "":U) + {&comma-char} +
                (if temp-shop.cd-pb-base then "cd-pb-base":U else "":U) + {&comma-char} +
                (if temp-shop.cd-sc-base then "cd-sc-base":U else "":U)
.
if trim(select3-codes, {&comma-char}) = "all-prt":u or trim(select3-codes, {&comma-char}) = "":U then do:
    message
    "Необходимо указать хотя бы один тип кода для вывода"
    view-as alert-box error.
    return no-apply.
end.
assign
Filter.naim = input frame {&frame-name} ubflt.filter.naim
Filter.call-point = c-point
Filter.Tbl = List-Tabls
Filter.Flds = List-Fields
Filter.Fields-sort = left-trim(SELECT3, {&comma-char})
Filter.Fields-sort-rus = left-trim(SELECT3-label, {&comma-char}) + {&delim-par} +
                         left-trim(SELECT3-codes, {&comma-char}) + {&delim-par} +
                         s-delim + {&delim-par} +
                         string(f-rec-num)  + {&delim-par} + cb-scl-format + {&delim-par} + cb-pg-format
Filter.Where-ysl = left-trim(select3-size, {&comma-char}) + {&delim-par} +
                                    left-trim(select3-size-min, {&comma-char}) + {&delim-par} +
                                    left-trim(select3-csize, {&comma-char})
Filter.Where-ysl-rus = left-trim(select3-format, {&delim-par})
Filter.lst-cend = left-trim(select3-type, {&comma-char})
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-tabs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-tabs DIALOG-1
ON VALUE-CHANGED OF RS-tabs IN FRAME DIALOG-1
DO:
if rs-tabs:visible in frame {&frame-name} then
  assign
  rs-tabs.
OPEN QUERY br-fields FOR EACH t-f no-lock where t-f.table-name = RS-tabs
and t-f.field-order = 0 use-index itorder.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-delim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-delim DIALOG-1
ON VALUE-CHANGED OF S-delim IN FRAME DIALOG-1
DO:

  assign
  S-delim
  .
  Assign
  f-delim = chr(int(s-delim))
  f-delim = (if f-delim = '':U then 'нет' else f-delim)
  .
  display f-delim
  with frame {&frame-name}
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-fields
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i
  &browse-name=br-sel-fields
}
{ gbl/brwrepos.i
  &browse-name=br-sel-fields
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
  fill-in-3 = 'Доступные поля'.
  fill-in-4 = 'Выбранные поля'.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if not avail temp-shop then
create temp-shop.
IF Kl <> 0 THEN DO:
   FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl.
   assign
   select3 = ubflt.filter.Fields-sort
   select3-label = entry(1, ubflt.filter.Fields-sort-rus, {&delim-par})
   select3-codes = entry(2, ubflt.filter.Fields-sort-rus, {&delim-par})
   select3-size = entry(1, ubflt.filter.Where-ysl, {&delim-par})
   select3-size-min = entry(2, ubflt.filter.Where-ysl, {&delim-par})
   select3-csize = entry(3, ubflt.filter.Where-ysl, {&delim-par})
   select3-format = ubflt.filter.Where-ysl-rus
   select3-type = ubflt.filter.lst-cend
   .
  assign
  temp-shop.all-prt              = (lookup("all-prt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
  temp-shop.cd-bc-alt            = (lookup("cd-bc-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  temp-shop.cd-bc-base           = (lookup("cd-bc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
  temp-shop.cd-loc-alt           = (lookup("cd-loc-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
  temp-shop.cd-loc-base          = (lookup("cd-loc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
  temp-shop.cd-parts-all         = (lookup("cd-parts-all":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
  temp-shop.cd-parts-not-blank   = (lookup("cd-parts-not-blank":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  temp-shop.cd-parts-ser         = (lookup("cd-part-ser":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  temp-shop.cd-pb-alt            = (lookup("cd-pb-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  temp-shop.cd-pb-base           = (lookup("cd-pb-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  temp-shop.cd-sc-base           = (lookup("cd-sc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
  .
END.
ELSE DO:
   CREATE ubflt.filter.
   assign
   ubflt.filter.call-point = c-point
   Kl = Num-flt
   .
   v-new = yes.
   if p-obj-type = {&shop} then do:
    find first ub.shop no-lock where
               ub.shop.obj-code = p-obj-code no-error .
    if avail ub.shop then do:
      buffer-copy ub.shop to temp-shop.
    end.
   end.
END.
assign
jj             = 0
.
run fill-table in this-procedure no-error.
RUN MYenable.
apply "VALUE-CHANGED" to RS-tabs.
RUN PROC-N-L IN THIS-PROCEDURE.
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-fields.
if undo_ then undo,retry.
/******************************************************************/
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-delim DIALOG-1
PROCEDURE check-delim :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-delim as character no-undo.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-buttons DIALOG-1
PROCEDURE enable-buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 if available t-f then do:
    enable
    btn-add
    with frame {&frame-name}.
  end.
  if available sel_t-f then do:
    enable
    btn-remove
    b-down b-up
    with frame {&frame-name}.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY RS-tabs f-num-clmn f-delim S-delim f-length f-rec-num CB-scl-format
          CB-pg-format FILL-IN-4 FILL-IN-3
      WITH FRAME DIALOG-1.
  IF AVAILABLE ubflt.Filter THEN
    DISPLAY ubflt.Filter.Naim
      WITH FRAME DIALOG-1.
  ENABLE Btn_OK Btn_Cancel b-help RECT-1 ubflt.Filter.Naim RS-tabs f-delim S-delim
         f-rec-num CB-scl-format CB-pg-format BR-sel-fields BR-fields
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table DIALOG-1
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-label as character no-undo .
list-tabls_block:
do ii = 1 to num-entries(List-Buf):
  assign
  file-name = entry(ii, List-tabls).
  list-dim_block:
  do kk = jj + 1 to jj + int(entry(ii,List-dim)):
    if file-name = "function":U OR index(entry(1, entry(kk, list-spr), '.'), "ATTR":u) > 0 then do:
      create t-f.
      assign
      t-f.table-name = file-name
      t-f.field-name = entry(kk, List-Fields)
      t-f.field-type  = entry(2, entry(kk, list-spr), '.')
      t-f.field-label = entry(kk,List-Labels)
      t-f.field-clabel = t-f.field-label
      t-f.field-spr = "":U
      t-f.field-size = entry(kk,List-Size)
      t-f.field-size-min = entry(kk,List-Size-min)
      t-f.field-format = entry(kk,List-format, {&delim-par})
      t-f.field-table-order = kk
      .
    end.
    else do:
      find first _File where _File-Name = file-name.
      id = recid(_File).
      do ll = 1 to num-entries(entry(kk, List-Fields),'{&delim-flt}'):
        find _Field no-lock where
            _Field._Field-name =  entry(ll,entry(kk, List-Fields),'{&delim-flt}')
        and _Field._File-Recid = id
        no-error .
        if not available _Field then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неизвестное поле" entry(ll,entry(kk, List-Fields),'{&delim-flt}') skip
          "Таблица" entry(ii, List-Tabls)
          view-as alert-box error .
          next list-dim_block .
        end.
        find first t-f where
                   t-f.table-name = _File._File-name
               AND t-f.field-name = entry(kk, List-Fields)
        no-error.
        if not available t-f then do:
          create t-f.
          assign
          t-f.table-name = _File._File-name
          t-f.field-name = entry(kk, List-Fields)
          t-f.field-spr = entry(kk,List-spr)
          t-f.field-size = entry(kk,List-Size)
          t-f.field-size = entry(kk,List-Size-min)
          t-f.field-format = entry(kk,List-format, {&delim-par})
          t-f.field-table-order = kk
          .
        end.
        if _field._label = ? then do:
          assign
          v-label = {&question-mark}
          .
        end.
        else do:
          if current-language = "english" or current-language = "romanian" then do:
            if current-language = "english" then
            v-label = (if entry(2,_field._desc,"`") <> ? then entry(2,_field._desc,"`") else {&question-mark}).
            else
            v-label = (if entry(3,_field._desc,"`") <> ? then entry(3,_field._desc,"`") else {&question-mark}).
          end.
          else do:
            v-label = (if _field._label <> ? then _field._label else {&question-mark}).
          end.
        end. /*if _field._label = ? then do:*/
        assign
        t-f.field-name-0 = t-f.field-name-0 +
                           (if t-f.field-name-0 = "":U
                            then "":U
                            else '{&delim-flt}':U) +
                           entry(ll,entry(kk, List-Fields), '{&delim-flt}':U)
        t-f.field-label  = if entry(kk,List-Labels) <> ""
                           then entry(kk,List-Labels)
                           else t-f.field-label  +
                           (if t-f.field-label = "":U
                            then "":U
                            else '{&delim-flt}':U) +
                            v-label
        t-f.field-clabel = t-f.field-label
        t-f.field-type   = t-f.field-type  +
                           (if t-f.field-type = "":U
                            then "":U
                            else '{&delim-flt}':U) +
                            _field._data-type
        t-f.field-format = entry(kk, list-format, {&delim-par})
        .
      end. /*do ll = 1 to num-entries(entry(kk, List-Fields),'{&delim-flt}'):*/
    end.
    if avail t-f then do:
      assign
      t-f.field-order =  lookup(t-f.table-name + ".":U + t-f.field-name, select3)
      t-f.field-csize = if v-new
                        then t-f.field-size
                        else  (if t-f.field-order > 0
                              then entry(t-f.field-order, entry(3, ubflt.filter.where-ysl, {&delim-par}))
                              else t-f.field-size)
      v-num-clmn = v-num-clmn +  (if   t-f.field-order > 0 then 1 else 0)
      v-length = v-length + (if   t-f.field-order > 0
                             then integer(entry(t-f.field-order, entry(3, ubflt.filter.where-ysl, {&delim-par})))
                             else 0)
      v-delim = if v-new then chr(int(entry(1, {&delim-ascii-codes}))) else chr(int(entry(3, ubflt.filter.fields-sort-rus, {&delim-par})))
      v-rec-num = if v-new then 50000 else int(entry(4, ubflt.filter.fields-sort-rus, {&delim-par}))
      v-scl-format = (IF v-new OR NUM-ENTRIES(ubflt.filter.fields-sort-rus, {&delim-par}) < 5
                THEN "99999":U
                ELSE ENTRY(5, ubflt.filter.fields-sort-rus, {&delim-par}))
      v-pg-format = (IF v-new OR NUM-ENTRIES(ubflt.filter.fields-sort-rus, {&delim-par}) < 6
                THEN "99999":U
                ELSE ENTRY(6, ubflt.filter.fields-sort-rus, {&delim-par}))

      .
    end.
  end. /** do k **/
  jj = jj + int(entry(ii,List-dim)).
end. /** do i **/

/*
output to hh.txt.
for each t-f no-lock:
display t-f.table-name t-f.field-name t-f.field-label t-f.field-table-order t-f.field-order.
end.
output close.
*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable DIALOG-1
PROCEDURE MyEnable :
define variable v-delim-str as character no-undo.
DEFINE VARIABLE v-cb-scl-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cb-pg-format AS CHARACTER NO-UNDO.

{ str/sclspref.i }
ASSIGN
v-cb-scl-format = ">>>>9":U + {&comma-char} +
                  "99999":U .
DO ii = 1 TO NUM-ENTRIES(varscales-pref):
   ASSIGN
   v-cb-scl-format = v-cb-scl-format + {&comma-char} + ENTRY(ii, varscales-pref) + "99999":U.
END.
ASSIGN
cb-scl-format:LIST-ITEMS IN FRAME {&FRAME-NAME}  = v-cb-scl-format
cb-scl-format = v-scl-format
.
ASSIGN
v-cb-pg-format = ">>>>9":U + {&comma-char} +
                  "99999":U .
DO ii = 1 TO NUM-ENTRIES(varpgscales-pref):
   ASSIGN
   v-cb-pg-format = v-cb-pg-format + {&comma-char} + substring(ENTRY(ii, varpgscales-pref), 1, 2) + "99999":U.
END.
ASSIGN
cb-pg-format:LIST-ITEMS IN FRAME {&FRAME-NAME}  = v-cb-pg-format
cb-pg-format = v-pg-format
.


do ii = 1 to num-entries(list-tabls):
assign
v-rb = v-rb +
           (if v-rb = "":U then "":U else {&comma-char}) +
            entry(ii, list-buf) + {&comma-char} + entry(ii, list-tabls) .
.
end.
assign rs-tabs:radio-buttons in frame {&frame-name} = v-rb.
if num-entries(list-tabls) > 1 then do:
display
 RS-tabs
with frame {&frame-name}.
Enable
Rs-tabs
with frame {&frame-name}.
end.
else do:
    assign
    rs-tabs = list-tabls.
    hide
    rs-tabs in frame {&frame-name}.
end.

assign s-delim:list-items in frame {&frame-name} = {&delim-ascii-codes}.
assign
s-delim = if v-delim = '':U then '0' else string(asc(v-delim))
.
 DISPLAY
 FILL-IN-3
 FILL-IN-4
 s-delim
  v-rec-num @ f-rec-num
 CB-SCL-FORMAT
 CB-pg-FORMAT
 WITH FRAME {&frame-name} .
  IF AVAILABLE ubflt.filter THEN
    DISPLAY ubflt.filter.Naim
      WITH FRAME DIALOG-1.
  hide b-down b-up
  in frame {&frame-name}.
  ENABLE
  Btn_OK
  RECT-1
  Btn_Cancel
  b-help
  ubflt.filter.Naim
  BR-fields
  BR-sel-fields
  S-delim
  btn-codes
  f-rec-num
  CB-SCL-FORMAT
  cb-pg-format
  WITH FRAME {&frame-name} .
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
  APPLY "Value-changed" to BR-sel-fields.
  if Rs-tabs:visible in frame {&frame-name} then
  APPLY "Value-changed" to rs-tabs.
  APPLY "Value-changed" to s-delim.
  run enable-buttons in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PROC-N-L DIALOG-1
PROCEDURE PROC-N-L :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display
string(v-num-clmn, ">>9") @ f-num-clmn
string(v-length, ">>>>9") @ f-length
(if v-delim = '':u then 'нет' else v-delim) @ f-delim
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME